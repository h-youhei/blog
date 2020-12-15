+++
title = "ToME4アドオン「No Patrols」を作った"
description = """ToME4のワールドマップでパトロールが出現しなくなるアドオンの紹介と実装
"""
date = 2020-12-08T17:40:15+09:00
toc = true
+++
<!--more-->
## 目的
パトロールは注意してればまず避けれるんだけど、戦闘になるとかなり危険。何度もプレイしてるとマップ移動に神経をとがらせるのは面倒でしかないんだよね。\
それを解決してくれるアドオンに「[Opt-in Adventurers Parties][opt]」や「[Fuck Patrols Addon][fuck]」がある。\
「[Opt-in Adventurers Parties][opt]」はパトロールに遭遇したときの戦闘を回避してくれるアドオン。パトロールが近づくとクリックなどでの走りがキャンセルされるのが面倒だった。\
「[Fuck Patrols Addon][fuck]」はパトロールが出現しなくなるアドオン。走りのキャンセルも解決されるのだけどDLC「Embers of Rage」で追加されたOrcキャンペーンに対応していない。

ということでOrcキャンペーンに対応した、パトロールが出現しなくなるアドオンを作ることにした。

[ダウンロードはこちら][no]

## 実装
overloadを使うと同じパスのファイルを置き換えることができる。\
`data/general/encounters`以下にある`fareast-npcs.lua`と`maj-eyal-npcs.lua`の中の`newEntity{}`でパトロールを生成するための情報が登録されている。\
それらのファイルをoverloadの同じパスにコピーして、`newEntity{}`のうち生成されてほしくないものを削除すればいい。

DLCのzipを解凍してみると本体と同じパスに`fareast-npcs.lua`があってどうやってoverloadするか苦戦した。DLCの`overload/mod`以下のファイルを見てみると`data-orcs`から始まるパスがよく出てきていたので`data-orcs/general/encounters`以下に`fareast-npcs.lua`を置いてみるとoverloadできた。

[no]:https://te4.org/games/addons/tome/no-patrols
[opt]:https://te4.org/games/addons/tome/opt-adventurers-parties
[fuck]:https://te4.org/games/addons/tome/fuckpatrols
