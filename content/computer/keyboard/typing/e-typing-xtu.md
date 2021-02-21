+++
title = "e-typingと小さい「っ」"
description = """
e-typingで小さい「っ」の単打が入力できなくなったことへの対応策
"""
date = 2021-01-31T08:41:39+09:00
toc = false
+++
<!--more-->
いつからか[e-typing][e]で小さい文字を「L」や「X」を利用して入力できなくなった。

[自作配列]({{< relref "../layout/tyoki-chord.md" >}})でタイピング練習をするのに、かなに対応するローマ字列を出力していたから、この仕様変更で小さい「っ」が入力できなくなって困ったんだよね。

{{< figure src="start.png" class="full" >}}

この開始画面でスペースキーではなくて「L」キーを使って練習を開始すると小さい文字を「L」や「X」を利用して入力できると[ヘルプ][xtu]に書いてあるのを見つけた。

「X」では練習がはじまらないので出力するローマ字列を「xtu」にしているとかな配列面に「L」がなくて練習をはじめることができない。出力するローマ字列を「ltu」にするといいかも。

または修飾キーを押しながらでも「L」が問題なく反応するので、修飾キーを押しながらだと英語配列面のアルファベットを出力するように作ってあればそれでも大丈夫。

[e]:https://www.e-typing.ne.jp/
[xtu]: https://www.e-typing.ne.jp/help/018.asp