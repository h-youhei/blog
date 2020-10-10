+++
title = "チョキコード"
description = """
小指を使わないこと、薬指の使用率の低さ、打鍵数の少なさ、覚えやすさにこだわったかな入力。
"""
date = 2020-10-09T16:36:02+09:00
toc = true
+++
<!--more-->

{{< figure src="tyoki-chord-full.png" class="full" >}}

## 特徴
よく打つかなは単打なので打鍵効率がよい。\
そうでないかなは行段を組み合わせるので覚えやすく忘れにくい。\
9割以上の入力を人差し指と中指で打つため疲れにくい。\
小指を使わない。薬指を使わない選択もできる。

濁音や外来音も法則性があり、覚えやすく忘れにくい。\
濁音は中指で対応する段(母音)、人差し指でその隣のキーを同時押し。\
外来音は中指で対応する行(子音)、人差し指でその隣のキーを同時押し。

拗音と外来音を1動作で打ててリズムがいい。

人差し指と中指によるもの以外のアルペジオ(隣接キー高速打鍵)は、指への負担が大きいように感じるのであえて避けた。

よく出てくる二重母音は連続で打ちやすいように配置した。

親指を文字入力に使わないので親指シフト系列の配列だと親指が痛くなる人にもおすすめ。

## シフト方式
{{< figure src="tyoki-chord.png" >}}
配列図の各キー下のひらがなが単打したときの文字。\
各キー左上のカタカナがシフトの種類を表している。

清音とパ行は右手で行(子音)、左手で段(母音)を同時押し。

<div class="columns-2">
<figure class="column">
<figcaption>「ぱ」</figcaption>
<img src="pa.png" />
</figure>
<figure class="column">
<figcaption>「しゅ」</figcaption>
<img src="syu.png" />
</figure>
</div>

濁音は右手の中指で行(子音)、人差し指でその隣のキー、左手で段(母音)を同時押し。

<div class="columns-2">
<figure class="column">
<figcaption>「げ」</figcaption>
<img src="ge.png" />
</figure>
<figure class="column">
<figcaption>「づ」</figcaption>
<img src="du.png" />
</figure>
</div>

外来音は右手で行(子音)、左手の中指で段(母音)、人差し指でその隣のキーを同時押し。

<div class="columns-2">
<figure class="column">
<figcaption>「ファ」</figcaption>
<img src="fa.png" />
</figure>
<figure class="column">
<figcaption>「ディ」</figcaption>
<img src="dhi.png" />
</figure>
</div>

濁音シフトの単打で単打面の濁音を入力できる。\
右手の中指で行(子音)、人差し指でその隣のキーを同時押し。

<div class="columns-2">
<figure class="column">
<figcaption>「で」</figcaption>
<img src="de.png" />
</figure>
<figure class="column">
<figcaption>「ば」</figcaption>
<img src="ba.png" />
</figure>
</div>

外来音シフトの単打でわ行を入力する。\
左手の中指で段(母音)、人差し指でその隣のキーを同時押し。

<div class="columns-2">
<figure class="column">
<figcaption>「わ」</figcaption>
<img src="wa.png" />
</figure>
<figure class="column">
<figcaption>「を」</figcaption>
<img src="wo.png" />
</figure>
</div>

「させ」など同じ行が続くとき右手は押しっぱなしでいい。\
「みぎ」など同じ段が続くとき左手は押しっぱなしでいい。\
「みみ」など同じ文字が続くときは好きな方の手を押しっぱなしでいい。

外来音とわ行を合わせた頻度より濁音の頻度の方がかなり多いので左利きの方は配列を左右反転することをおすすめ。

## シフト表
{{< table file="seidakugai.csv" caption="行(子音)の組み合わせ一覧" >}}

{{< table file="gyoudan-tyoki.csv" caption="行段の組み合わせ一覧" v="t" >}}

外来音の拗音にはョ段を使う。\
中指で段を指定しながら隣の人差し指を押すことができるのが拗音の中ではョ段だけであること、外来音の拗音は「フュ」のようにュ段しかあらわれないことが理由。

## 変換
かなの入力中は常に変換候補を表示する。\
Spaceキーで選択中の候補を確定。\
Enterキーで変換せずに確定。\
数字キーで候補を選択して確定。\
左右キーで文節の移動。\
上下キーで文節の伸縮。\
PageUp/Downキーで変換候補のページ移動。\
ひらがなキーでひらがなに変換して確定。\
カタカナキーでカタカナに変換して確定。\
句読点のあと変換せずに確定。

かなの入力中以外は基本的にキーそのままを入力する。\
かなの入力中以外でひらがなキーやカタカナキーを押すと、かな直接入力モードを切り替える。かな直接入力モードではひらがなやカタカナを確定された状態で入力する。かなに関する表を作るときなどに役に立つ。

IMEの状態に合わせてキーボードの通知LEDを光らせることでIMEの状態が分からなくなることを防ぐ。\
モーダルエディタ(Vimなど)と連携してIMEの自動切り替え。

## アルファベット
{{< figure src="tyoki.png" class="full" >}}

頻度が低いアルファベットは薬指。
頻度が高い子音は人差し指。
頻度が高い母音は中指。
残りを内側。

アルファベットは26音。小指を使わない3段4列を両手で24キー。キーが足りない。数字はあまり使わないので端に追いやって、空いた最上段を利用する。はみ出たZQと記号、よく使う機能キーが候補。

## 機能キー、数字
最上段と親指のキーの一部は修飾キーと役割を兼ねている。長押しすると各キー右上に書かれている修飾キーとなり、すぐ離すと各キー下に書かれたキーが押されたことになる。

小指の2列(カーソル、数字など)と最下段の薬指(3と6)はホームポジションごと動かして人差し指と中指で打つ。これらの位置には、使うときには連続して使うことが多く、文字と行ったり来たりすることが少ないキーを置いている。レイヤーに高頻度のキーを置かないことに繋がり、親指の負担軽減になる。

BSとDelは長押しすることがあるので修飾キーと併用できない、連打することが多いので人差し指で打ちたい、カーソルキーと同時に使うことが多いのでその反対の手がいい、ということであの場所。

左上の4つのキーはマウスのスクロール。\
左親指の右上3つのキーはマウスのクリック。親指だと打ちにくいのでホームポジションごと動かして人差し指と中指で打つ。\
マウスをクリックしたりスクロールすると手の甲が痛いので用意している。

## 記号
かな入力中の記号は英数入力に準ずる。\
単打面にない記号はFnレイヤー(Enterを押しながら)にある。

{{< figure src="tyoki-fn.png" class="full" >}}

シフトとレイヤーに散らばっていると混乱するのでシフトで入力できるものもレイヤー側に用意してレイヤー側で入力するようにしている。

レイヤーキーを押している手と同じ側で入力するのは難しく、レイヤーキーを左右切り替えながら入力するのも難しいので連続することが多い記号は同じ側にまとめている。同じ種類のかっこは同じ側にまとめた。プログラミング言語で「=」と組み合わされることが多い記号を同じ側にまとめた。

少しでも覚えやすいように、論理演算子としてよく使われる記号(|, &)を「!」と同じ側に置いた。累乗としてよく使われる記号(^)、剰余としてよく使われる記号(%)を「+, *」と同じ側に置いた。

## 実装例
### [QMK Firmware][qmk firmware]

[Ergodox EZでの実装例][qmk ergodox]

**そのまま使う場合**
1. [QMK Firmware][qmk firmware]本体をクローンする。
1. qmk_firmware/layouts/community/ergodoxにディレクトリを作成する。
1. 作ったディレクトリに[実装例][qmk ergodox]をクローンする。
1. write.shを実行する。

**改造して使う場合**
1. [QMK Firmware][qmk firmware]本体をクローンする。
1. qmk_firmware/keyboards/キーボード名/keymapsにディレクトリを作成する。
1. [実装例][qmk ergodox]のkana.c, kana.h, kana_chord.c, kana_chord.h, ime.c, ime.h, util_user.c, util_user.hを作ったディレクトリへコピーする。
1. rules.mkのSRCにkana.c, kana_chord.c, ime.c, util_user.cを追加する。
1. my.hを参考にヘッダファイルを作成する。
1. my.cを参考にkeymap.cを作成する。
1. write.shを参考にしてビルド用のスクリプトを作って実行する。もしくは[公式ドキュメント](https://docs.qmk.fm/#/ja/newbs_getting_started?id=set-up-your-environment)を参考にして環境を構築する。

### 他の方法で実装された方へ
[よろしければ連絡をください。](#comment)リンクを貼らせていただきます。

## 謝辞
[100万字日本語かなn-gramデータ][100man]を使わせていただきました。ありがとうございます。

多くの既存の配列を参考にさせていただきました。ありがとうございます。

- [新JIS配列][new jis]: 単打面の配列
- [カタナ式][katana]、[薙刀式][naginata]: 人差し指と中指を重視すること
- [よだか配列][yodaka]: かな入力と行段入力の組み合わせ
- [けいならべ][keinarabe]: 二重母音を打ちやすいように配置すること

アルファベットの配列を作成するのに[この文字頻度表][mayzner]を使わせていただきました。ありがとうございます。

記号の配置を決めるのに[この文字頻度表][punctuation]を使わせていただきました。ありがとうございます。

[qmk firmware]:https://github.com/qmk/qmk_firmware
[qmk ergodox]:https://github.com/h-youhei/qmk_keymap
[100man]:https://kouy.exblog.jp/9731073
[new jis]:https://ja.wikipedia.org/wiki/%E6%96%B0JIS%E9%85%8D%E5%88%97
[katana]:http://oookaworks.seesaa.net/article/455391788.html
[naginata]:http://oookaworks.seesaa.net/article/456099128.html
[yodaka]:https://github.com/semialt/yodaka
[keinarabe]:http://web1.nazca.co.jp/kouy/keinarabe/

[mayzner]:http://norvig.com/mayzner.html
[punctuation]:https://mdickens.me/typing/letter_frequency.html
