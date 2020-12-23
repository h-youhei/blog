+++
title = "ToME4アドオン「Which Items Are Restocked In Store」を作った"
description = """
ToME4で店の商品のうちどれが新入荷されたものなのか表示するアドオンの紹介と実装
"""
date = 2020-12-23T15:34:44+09:00
toc = true
syntax = true
+++
<!--more-->
## 目的
再入荷のたびに店の商品が多くなって、全部チェックするのが大変になっていくんだよね。このとき興味がある商品は、後から買おうと思ってた商品と再入荷した商品、それらだけ見ることができるといいなって。

後から買おうと思ってた商品は「[Store Wish List][wish]」っていうアドオンでメモして後で見れるからそれを使うとして、再入荷した商品がどれか分かるようにするアドオンを作ることにした。

[ダウンロードはこちら][restocked]

## 実装
まずは店の商品をハイライトしてみる。Store Wish Listのコードを見てみると`mod/dialogs/ShowStore.lua`の`init()`をsuperloadして、色を表す定数を返す関数を`self.c_store.special_bg`に代入すればいいことが分かる。また、ハイライトしないときは何も返さなければいいようだ。

```lua
local _M = loadPrevious(...)

local base_init = _M.init
function _M:init(title, store_inven, actor_inven, store_filter, actor_filter, action, desc, descprice, allow_sell, allow_buy, on_select, store_actor, actor_actor)
	base_init(self, title, store_inven, actor_inven, store_filter, actor_filter, action, desc, descprice, allow_sell, allow_buy, on_select, store_actor, actor_actor)
	self.c_store.special_bg = function(item)
		return colors.WHITE
	end
	self.c_store:generateList()
end

return _M
```

するとStore Wish Listでのハイライトが消えてしまう。Store Wish Listは他のアドオンによって`self.c_store.special_bg`が書き換えられることを想定したコードになってないので、Store Wish Listよりこのアドオンを後に読み込んで、Store Wish Listの`special_bg`を変数に退避して、このアドオンの`special_bg`から呼び出すことにする。

init.luaを見てみるとStore Wish Listのweightは50でこのアドオンのweightは100、weightが小さい方から読み込まれるのでこのままでいい。

```lua
local super_special_bg = self.c_store.special_bg
self.c_store.special_bg = function(item)
	local ret = super_special_bg(item)
	-- Store Wish List側でハイライトしてないときだけハイライトする
	if not ret then
		return colors.WHITE
	else
		return ret
	end
end
```

次にどの商品が再入荷したものなのか判定する。
「restock」でgrepしてみると`mod/class/Store.lua`に再入荷関連の処理があるっぽい。中を読んでみると`loadup()`から`engine/Store.lua`の`loadup()`が呼ばれている。その中を読むと実際の処理が行われているっぽい。

どちらの`loadup()`でもいいからsuperloadして、元の関数を呼ぶ前に再入荷前のインベントリの中身を保存しておいて、ハイライトするかの判定に使うことにする。アイテム名をキーにした連想配列として保存することにした。

```lua
local _M = loadPrevious(...)

local base_loadup = _M.loadup
function _M:loadup(level, zone, force_nb)
	if self.store then
		self.last_inven = {}
		for i,v in ipairs(self:getInven("INVEN")) do
			self.last_inven[v:getName{do_color=true, no_image=true}] = i
		end
	end
	return base_loadup(self, level, zone, force_nb)
end

return _M
```

`mod/dialogs/ShowStore.lua`の`init()`に戻ってハイライトの判定を加える。

```lua
self.c_store.special_bg = function(item)
	local ret = super_special_bg(item)
	if not ret then
		if store_actor and store_actor.last_inven then
			-- 前からあった商品ならハイライトしない
			if store_actor.last_inven[item.object:getName{do_color=true, no_image=true}] then return
			-- 新商品ならハイライトする
			else
				if store_actor.last_filled > 1 then return colors.WHITE
				-- 初めてその店を訪ねたときの入荷はすべて新商品なのでハイライトする必要はない
				else return
				end
			end
		else return
		end
	else
		return ret
	end
end
```

[wish]:https://te4.org/games/addons/tome/store-wish-list
[restocked]:https://te4.org/games/addons/tome/which-new-in-store
