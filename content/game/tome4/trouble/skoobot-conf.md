+++
title = "ToME4アドオン「SkooBot」の設定の変更が反映されない"
description = """
tome4で設定を変更してもロードを挟むともとに戻る問題へのその場しのぎな対処法
"""
date = 2021-02-20T12:00:30+09:00
toc = true
syntax = true
+++
<!--more-->
## 問題
ToME4アドオン「[SkooBot](https://te4.org/games/addons/tome/skoobot)」は、雑魚敵を勝手に倒しながら自動探索して、強い敵に出会ったら操作をこちらに渡してくれるアドオン。

Game Optionでどの程度強い敵に出会ったら操作をこちらに渡すかなどを設定できるのだけど、数値を変更してもロードを挟むともとの設定に戻ってしまう。

また、初期設定のままだと中盤以降`MAX_INDIVIDUAL_POWER`(それぞれの敵をどの強さまで雑魚敵と判定するか)にほとんどの雑魚敵が引っかかるようになって、ただの自動探索としてしか機能しなくなる。

そんなわけでゲームを中断するたびに設定を変更することになって面倒だった。

## 解決策
`game/thirdparty/config.lua`に
```lua
settings.tome = settings.tome or {}
settings.tome.SkooBot = settings.tome.SkooBot or {}
```
を書き加えた。

## 試したこと
設定の変更がロード後も反映されたままの他のアドオンとSkooBotの設定関連のコードを比較してみたがおかしいところは見当たらない。

設定が保存されるディレクトリ、Linuxだと`/HOME/.t-engine/4.0/settings`を見てみると`tome.SkooBot.設定名.cfg`ファイルができていて、中身を見ると変更した値になっている。どうやら設定の保存は正常にできているが、読み込みがうまくいってないみたいだ。

文字種によってうまく読み込めなかったりするのかもしれないと思い、大文字のみ、小文字のみ、両方混じり、アンダースコアのありなしなどのファイル名や中身を作ってデバッグモードのLuaコンソールから読み込めているかどうか試してみたが、どれも読み込めていた。しかし`tome.SkooBot`からはじまるパターンだけはうまくいかない。

しょうがないので本体のLuaファイルを直接いじることにした。圧縮されていない生のLuaコードであればどれでも問題ないと思うが、設定と関連があるために目的の変数に辿り着きやすい`thirdparty/config.lua`をいじった。

```lua
settings.tome = settings.tome or {}
settings.tome.SkooBot = settings.tome.SkooBot or {}
settings.tome.SkooBot.MAX_INDIVIDUAL_POWER = settings.tome.SkooBot.MAX_INDIVIDUAL_POWER or 400
```

すると複数ある設定項目のうち1つしかいじってないのに他の設定項目が読み込まれるようになった。なんらかの原因で`settings.tome.SkooBot`のテーブルが初期化できていなくて、各設定項目の変数への代入がうまくいっていないのだと思う。テーブルを初期化するコードだけを残してもこのアドオンのすべての設定項目が読み込めている。

力不足でこれ以上の調査は断念。その場しのぎな対処で妥協することにした。
