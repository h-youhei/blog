+++
title = "チョキコード第2版"
description = """
"""
date = 2021-01-04T23:14:23+09:00
toc = true
draft = false
+++
<!--more-->
[チョキコードのメインページはこちら]({{< relref "tyoki-chord.md" >}})

## 主な変更点
- 数字をレイヤーに移動し、テンキー状に配置
- それに伴い記号の配置を変更
- ファンクションキーを数字と同じキーで入力するため新レイヤーを用意
- 「が」と「で」を単打に移動
- それに伴い「も」と「つ」、ひらがなキー、カタカナキーを移動
- 「…」を追加
- クリックを左端に移動
- PageDown, PageUpを右端に移動
- ウェブブラウジング用のショートカットをクリック周辺に追加

## かな
{{< figure src="tyoki-chord.png" class="full" >}}

## アルファベット
{{< figure src="tyoki.png" class="full" >}}

## 数字、記号
{{< figure src="num-sign.png" class="full" >}}

レイヤーキーを押している手と同じ側で入力するのは難しく、レイヤーキーを左右切り替えながら入力するのも難しいので連続することが多い記号は同じ側にまとめている。

- 同じ種類のかっこは人差し指と中指のアルペジオになるようにした
- 「[, ]」は配列の添字として数字と一緒に使うことが多いので数字側
- プログラミング言語で「=」と組み合わされることが多い記号を同じ側にまとめた

覚えやすさのために関連性のあるものを近くにまとめている。

- 「$, #, %」は数字と強い関連があるので数字側にまとめた
- 「=, +, *」は算術演算子
- 記号側の中段と下段は論理演算やビット演算
- 「^, <, >」は形が似ている
- 「!, ?, :, `」は句読点つながり
- 「\\, `」はバックなんとか

## Fn
{{< figure src="fn.png" class="full" >}}

覚えやすさのためになるべく単打面と関連付けた

- Pauseの頭文字P
- PrintScreenはScreenshotの頭文字S
- ScrollLockはマウスのスクロール
- Appの機能は右クリックと似ている
- かなをローマ字にした頭文字のK、その近くに日本語入力関連
- 音量や輝度の増減を上下カーソルに
- 音楽などマルチメディア系のキーを音量の近くに

[前の版へ]({{< relref "tyoki-chord-v1.md" >}})