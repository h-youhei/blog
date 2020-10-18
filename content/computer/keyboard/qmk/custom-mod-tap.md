+++
title = "Mod Tapキーのタップで通常のキーコードではできないことをする"
description = """
Mod Tapキーのタップでは通常のキーコードしか送れない。Mod Tapを使いながら複雑な処理をしたいときはどうすればいいか。
"""
date = 2020-10-16T09:15:01+09:00
toc = true
syntax = true
+++
<!--more-->
## Mod Tapの使い方
長押しでシフトなどの修飾キー、タップで通常のキーを入力できるのがMod Tap。

keymap定義の中で`LSFT_T(KC_SPC)`のように使う。

`KC_SPC`の部分には通常のキーコードしか指定できない。

他の修飾キーは[公式ドキュメント](https://docs.qmk.fm/#/ja/mod_tap)に一覧がある。

## process_record_user
通常と違う処理をしたい場合は`process_record_user()`を使う。

引数で渡されたkeycodeが目当てのものをif文かswitch文で捕捉して、実行したい処理を書く。

`process_record_user()`内でtrueを返すと通常の処理が実行される。falseを返すと通常の処理は実行されない。

## 本題の解説
```c
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
	...
	switch(keycode) {
		...
		// MOD TAPのキーコードを捕捉
		case LSFT_T(KC_SPC):
		// 長押しの場合はtap.countが0
		// タップの場合は1以上
		if(record->tap.count > 0) {
			// タップの場合にしたい処理を書く。
			
			// タップの場合にしたい処理はもうおこなった。
			// falseを返すと通常の処理は実行されない。
			return false;
		}
		// 長押しの場合は通常通り修飾キーになってほしい。
		// trueを返すと通常の処理が実行される。
		return true;
		...
	}
	...
}
```

## タップでシフト側の文字を送る例
```c
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
	...
	switch(keycode) {
		...
		// MOD TAPのキーコードを捕捉
		// タップ側のキーコードは最後の8ビット以外は#defineマクロの展開のときに捨てられるのでJP_QUOTはKC_7と同じ扱いになってしまっている。
		case RGUI_T(JP_QUOT):
		// 長押しの場合はtap.countが0
		// タップの場合は1以上
		if(record->tap.count > 0) {
			// 押されたときの処理
			if(record->event.pressed) {
				add_mods(MOD_LSFT);
				register_code(KC_7);
			}
			// 離されたときの処理
			else {
				unregister_code(KC_7);
				del_mods(MOD_LSFT);
			}
			return false;
		}
		// 長押しの場合は通常通り修飾キーになってほしい。
		// trueを返すと通常の処理が実行される。
		return true;
		...
	}
	...
}
```

## 関連する部分のソースコードを読む助け
[公式のGithubリポジトリ](https://github.com/qmk/qmk_firmware)

MOD TAPの#defineマクロ定義は`qmk_firmware/quantum/quantum_keycode.h`の終わりの方にある`LT()`, `MT()`, `MODの種類_T()`

MOD TAPの実際の処理を行っている部分は`qmk_firmware/tmk_core/common/action_tapping.c`にある。

この記事で通常のキーコードと書いているのは`qmk_firmware/tmk_core/common/keycode.h`で定義されている0xFFまでのキーコード。

`qmk_firmware/tmk_core/common/action.c`の`process_record()`から`qmk_firmware/quantum/quantum.c`の`process_record_quantum()`, `process_record_kb()`, `process_record_user()`と呼ばれていく。

`process_record_quantum()`の中で、キーを処理してbool値を返すさまざまな関数を論理積の短絡評価(&&)でつなげている。論理積はすべてがtrueならtrue、1つでもfalseならfalse。短絡評価は全体のbool値が確定した段階で残りの処理を省略する。結局どこかでfalseが出るまで処理を続けて、falseが出たら終了ということになる。

`process_record_user()`にはweak属性が指定されている。weak属性がある関数は他の場所にも同じ名前の関数があればそちらに置き換えられる。各自のkeymapファイルで置き換えることを想定されている。
