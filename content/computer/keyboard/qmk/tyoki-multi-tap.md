+++
title = "複数キー同時打鍵とチョキコードでの実装"
description = """
"""
date = 2020-10-23T11:06:10+09:00
toc = true
syntax = true
+++
<!--more-->
[チョキコードのGithubリポジトリ](https://github.com/h-youhei/qmk_keymap)

[QMK FirmwareのGithubリポジトリ](https://github.com/qmk/qmk_firmware)

## キーコードの確保
文字や行段シフトの位置を変えたときにkeymapだけいじればいいように`行段シフトの種類(かな文字の種類)`という形で定義したかった。

QMK Firmwareの`quantum/quantum_keycodes.h`を見ると、複数機能を持ったキーコードを定義するのに、最初の8bitを1つ目の機能の種類を表すために使い、最後の8bitをもう1つの機能、多くの場合は0xFFまでの通常のキーコードを表すために使っていることが分かる。例としてMod Tapを解説する。

```c
// quantum/quantum_keycodes.h

// tmk_core/common/action_code.hのmods_bit列挙体を見るとShift, Alt, Ctrl, Winそれぞれのオンオフで各1bit、左右の区別で1bit、合計5bitをmodを表すのに使っていることが分かる。
// 5bitは2進数で00011111。16進数にすると1F。QK_MOD_TAPに最初の8bit分で0x1F確保することになる。QK_MOD_TAP_MAXとの差は0x7FFF - 0x6000で0x1FFF。最初の8bitは0x1F。
enum quantum_keycodes {
	...
	QK_MOD_TAP = 0x6000,
	QK_MOD_TAP_MAX = 0x7FFF,
	...
};
...
// 間違えてmod以外のものを渡してしまったときに違う機能を実行してしまわないように「(mod)&0x1F」でQK_MOD_TAPの範囲内に収める。16bit中の最初の8bitに移すために「<< 8」で左に8bitずらす。
// 0xFFを超えるキーコードを渡してしまったときに最初の8bitに影響を与えないように「(kc)&0xFF」で範囲外のbitを捨てる。
// 論理和でQK_MOD_TAPと組み合わせるとQK_MOD_TAPからQK_MOD_TAP_MAXまでの範囲のキーコードになる。
#define MT(mod, kc) (QK_MOD_TAP | (((mod)&0x1F) << 8) | ((kc)&0xFF))

#define LCTL_T(kc) MT(MOD_LCTL, kc)
...
```

ここからチョキコードでの実装。

行のシフトの個数は「あかさたなはまらぱ」の9個、段のシフトの個数は「あいうえおやゆよいぇ」の9個、合計で18個。\
行段それぞれのオンオフに1bit使うと8bitに収まらない。\
2の4乘だと16で足りない、2の5乘は32で多少シフトの数が増えても足りる。ということで5bit用意して、使うときに行段それぞれのオンオフに1bit使う形に変換することにする。

かな文字は`SAFE_RANGE`以降に定義することになるのでそのままでは8bitに収まらない。2の8乘は256でかな文字自体の数はそれに収まるので、かな文字のキーコードから1つ目のかな文字のキーコードを引いておいて、使うときに戻すことにする。

```c
// kana_chord.h

enum kana_notes {
	VOWEL_A,
	...
	CONSONANT_A,
	...
};

// 行段シフトに使う5bitの確保
enum kana_chord_keycodes {
// quantum_keycodesですでに16bit分すべて使われているので適当な機能の範囲を利用する。その機能と同時に使われることがないように配慮する。
#if defined(UNICODE_ENABLE)
#error "UNICODE_ENABLEとは同時に使えない。
#endif
	KANA_CHORD = 0x8000,
	KANA_CHORD_MAX = 0x9FFF
};

// 行段それぞれのオンオフに1bit使う形
#define BIT_VOWEL_A (1UL << VOWEL_A)
...
#define BIT_CONSONANT_A(1UL << CONSONANT_A)
...

// 「(kc - KANA_RANGE)」でかな文字のキーコードから1つ目のかな文字のキーコードを引いている。
// 「(notes & 0x1F)」でKANA_CHORDの範囲内に収める。16bit中の最初の8bitに移すために「<< 8」で左に8bitずらす。
// 論理和でKANA_CHORDと組み合わせるとKANA_CHORDからKANA_CHORD_MAXまでの範囲のキーコードになる。
#define KANA_CHORD(notes, kc) ( (kc - KANA_RANGE) | KANA_CHORD | ((notes & 0x1F) << 8) )
#define VOWEL_A(kc) KANA_CHORD(VOWEL_A, kc)
```
```c
// kana_chord.c

// キーコードからVOWEL_段やCONSONANT_行への変換
uint16_t get_kana_note_from_keycode(uint16_t keycode) {
// 「(keycode ^ KANA_CHORD)」でキーコードからKANA_CHORDのbitを削除。
// 最初の8bitを取得するため「>> 8」で右に8bitずらす。
// 念のため「& 0x1F」で行段シフトの種類を表す5bit以外を削除。
	return ((keycode ^ KANA_CHORD) >> 8) & 0x1F;
}

// VOWEL_段やCONSONANT_行からBIT_VOWEL_段やBIT_CONSONANT_行への変換
uint32_t kana_note_to_bit(uint16_t chord) {
	...
	return (1UL << chord);
}

// 「(keycode & 0xFF)」でキーコードからかな文字を表す部分以外を削除
// 8bitに収めるために引いておいた数字を戻してかな文字のキーコードに戻す。
uint16_t get_kana_from_keycode(uint16_t keycode) {
	return (keycode & 0xFF) + KANA_RANGE;
}
```

## 同時打鍵
### 基本
キーを押したとき何のキーが押されているのか変数に格納する。

キーを離したとき押されているキーがいま離したキーだけであれば、そのキーの単打として入力。押されているキーを格納する変数から離したキーを削除する。

他に押されているキーがあればその組み合わせでの同時打鍵として入力。その組み合わせが定義されてなければ何も入力しない。押されているキーを格納する変数から離したキーを削除する。

### 連続シフトのための工夫
例えば行段同時打鍵の場合、「させ」など同じ行が連続したときにサ行キーを押しっぱなしで入力できるようにしたい。

同時打鍵し終えた複数のキーを離すときは、キーを離すのが連続する。\
連続シフトのときは、同時打鍵したうちの一部のキーを離した後、なにかキーが押されてから押しているキーを離すのが連続する。

結局、直前のキーイベントが押す動作のときにだけ、キーを離したときに入力処理をすればいいということになる。

コード上では、キーを押したとき直前のキーイベントが押す動作だというフラグを立てて、キーを離したときにフラグを折ればいい。

```c
// kana_chord.c

// いま押されている行段シフトキーを格納する変数。
// BIT_行段の組み合わせの形で格納。
static uint32_t kana_chord_bit = 0;

void add_kana_chord(uint32_t kana_chord) {
	kana_chord_bit |= kana_chord;
}
// kana_chordのbitを「~」で反転すると目的の行段を表すbitだけが0、ほかは1になる。
// 論理積をとると、1はそのまま、0はbitをオフにする。
void del_kana_chord(uint32_t kana_chord) {
	kana_chord_bit &= ~kana_chord;
}

// 行段の組み合わせを表すbitからかな文字を表すキーコードへ変換。
uint16_t get_kana_from_chord(uint32_t kana_chord) {
	...
	else if(kana_chord == (BIT_CONSONANT_K | BIT_VOWEL_A)) {
		return KANA_KA;
	}
	...
}

// 直前のキーイベントが押す動作だったか保存する変数
static bool is_recently_pressed = false;

void process_kana_chord(uint16_t keycode, keyrecord_t *record) {
	keyevent_t event = record->event;
// キーコード → 行段 → bit
	uint32_t note_bit = kana_note_to_bit(get_kana_note_from_keycode(keycode));
	if(event.pressed) {
// 修飾キーを押しているときはアルファベットの配列面を使いたい。
		if(keyboard_report->mods || IS_HOST_LED_ON(USB_LED_CAPS_LOCK)) {
			process_capital_letter(keycode, record);
		}
		else {
// 直前のキーイベントが押す動作だったというフラグを立てる。
			is_recently_pressed = true;
// キーを押したとき何のキーが押されているのか変数に格納する。
// 単打で扱いやすい形で保存
			tapping = keycode;
// 行段シフトで扱いやすい形で保存
			add_kana_chord(note_bit);
		}
	}
	else {
// 直前のキーイベントが押す動作のときにだけ、キーを離したときに入力処理をする。
		if(is_recently_pressed) {
// bitpop32()はbitがONの数を返す関数。qmkのtmk_core/common/util.cで定義されている。ここでは現在押している行段シフトの数を知るために使っている。
			uint8_t c = bitpop32(kana_chord_bit);
// 単打
			if(c == 1) {
				tap_kana(get_kana_from_keycode(tapping), event);
			}
// 行段シフト
			else if(c > 1) {
				tap_kana(get_kana_from_chord(kana_chord_bit), event);
			}
// 直前のキーイベントは押す動作ではない。
			is_recently_pressed = false;
		}
// 押されているキーを格納するキーから離したキーを削除。
		del_kana_chord(note_bit);
	}
}
```
