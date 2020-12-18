+++
title = "ToME4アドオン「Quick Dig Targeting」を作った"
description = """ToME4で穴掘りのターゲットの確定を不要にするアドオンの紹介と実装
"""
date = 2020-12-18T11:21:56+09:00
toc = true
syntax = true
+++
<!--more-->
## 目的
穴を掘るときにいちいち確定させるのは面倒、必要なくない？\
ということで設定のquick melee targetingを有効にしたときの近接攻撃と同様、方向を指定したらすぐに掘り始めるアドオンを作ることにした。

[ダウンロードはこちら][dig]

## 実装
Digタレントの定義は`data/talents/misc/objects.lua`にあり、actionを見ると方向指定しているのは`getTarget()`の中っぽい。

`"^function _M:getTarget"`(^は行頭を表す)とgrepしてみると`getTarget()`は`mod/class/Player.lua`にあることが分かる。中をのぞいてみると引数typをいじって`game:targetGetForPlayer()`を呼んでいることが分かる。

`game:targetGetForPlayer()`をgrepで探してみるも見つからない。tomeモジュールではなくT-Engineの方のコードをgrepで探すと`engine/targeting/GameTargeting.lua`の中に見つけることができた。T-Engineのコードは`engines/te4-version.teae`を解凍すると見ることができる。

`game:targetGetForPlayer()`の中身を見てみると`typ.immediate`がtrueで`typ.nolock`がfalseだと目的の挙動が得られそう。

ここまでの情報から`mod/class/Player.lua`の`getTarget()`をsuperloadして引数typからDigを見分けて、typを目的の挙動が得られるように変更し、元の関数か`game:targetGetForPlayer()`を呼べば良さそう。

もう1度Digの定義を見てみると`getTarget()`に渡しているのは`{type="bolt", range=1, nolock=true}`であることが分かる。
その3つだけで判定するとWormholeと罠系のタレントも含んでしまう。これらは`simple_dir_request=true`となっているのでそれで判断できる。

```lua
local base_getTarget = _M.getTarget
function _M:getTarget(typ)
	-- Digタレントかどうかの判定
	-- not self:attr("encased_in_ice")は凍っているときそのまま元の関数に任せるため
	if type(typ) == "table" and typ.type and typ.type == "bolt" and typ.range and typ.range == 1 and typ.nolock and not simple_dir_request and not self:attr("encased_in_ice") then
		-- 渡されたのはテーブルへの参照なのでそのまま書き換えると他の処理に影響を与え続けてしまう。値をコピーしてそれを使う。
		typ = table.clone(typ)
		-- 渡されたテーブルを目的の挙動の分岐に入るように変更
		typ.nolock = false
		typ.immediate_keys = true
	end
	-- Digは渡されたテーブルをいじってから、ほかはそのまま元の関数に任せる
	return base_getTarget(self, typ)
end
```


[dig]:https://te4.org/games/addons/tome/quick-dig-targeting
