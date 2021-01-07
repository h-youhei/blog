+++
title = "日本語のみのサイトを生成する"
description = """Hugoで多言語サイトへの移行を考慮しながら日本語のみのサイトを生成する方法
"""
date = 2021-01-07T14:56:08+09:00
toc = true
+++
<!--more-->
## 目的
はじめは英語にも訳すつもりでサイトを作っていたけど、当面は日本語のみで公開することにした。トップページに言語切り替えとかその名残が残っていたのを将来多言語サイトにするためのコードを残したまま消すのにつまずいたので対処法を残しておく。

## うまくいった方法
config.tomlのうち関係ある部分はこうなっていた。
```
defaultContentLanguage = "ja"

[Languages.ja]
title = "福光洋平"
hasCJKLanguage = true
languageName = "日本語"
languageCode = "ja-jp"
dateformat = "2006年1月2日"

[Languages.en]
title = "Hukumitu Youhei"
languageName = "English"
languageCode = "en-us"
dateformat = "Jan 2, 2006"
```

これに
```
disableLanguages = ["en"]
```
をトップの階層に加えるとうまくいった。

```
defaultContentLanguage = "ja"
disableLanguages = ["en"]

[Languages.ja]
title = "福光洋平"
hasCJKLanguage = true
languageName = "日本語"
languageCode = "ja-jp"
dateformat = "2006年1月2日"

[Languages.en]
title = "Hukumitu Youhei"
languageName = "English"
languageCode = "en-us"
dateformat = "Jan 2, 2006"
```
## うまくいかなかった方法
`[Languages.en]`以下を消すとなぜか日本語のページが一切生成されない。
