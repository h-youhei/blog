+++
title = "ToME4アドオン「Preset Timed Rest」を作った"
description = """ToME4であらかじめ設定したターン数だけ休憩するアドオンの紹介と実装
"""
date = 2020-12-15T15:26:57+09:00
toc = true
syntax = true
+++
<!--more-->
## 目的
角に隠れて敵をおびき寄せて分断するのに、足踏みしては敵が視界に入ったか確認してを繰り返すのが面倒だった。通常の休憩ではすでにリソースが回復済みだと休憩が始まらず、使えない。

「[Timed Rest][zizzo]」というターンを指定して休憩するアドオンを試してみたらうまく機能したのだが、指定するターン数が変わらないのに毎回毎回指定するのが面倒。

ということで設定であらかじめターン数を指定して休憩するアドオンを作ることにした。

[ダウンロードはこちら][preset]

## 実装
`hooks/load.lua`はゲーム開始時に自動で読み込まれる。

### 設定
`hooks/load.lua`で`GameOptions:generateList`にフックさせる。

```lua
class:bindHook("ToME:load", function(self, data)
	config.settings.youhei = config.settings.youhei or {}
	config.settings.youhei.waiting_turns_1 = config.settings.youhei.waiting_turns_1 or 10

	...
end)

local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local GetQuantity = require "engine.dialogs.GetQuantity"

class:bindHook("GameOptions:generateList", function(self, data)
	-- 表示させたいタブ
	if data.kind == "gameplay" then
		-- リストの要素数+1、つまりリストの最後に要素を追加する
		data.list[#data.list+1] = {
			-- 設定ウィンドウ右側の説明欄
			zone = Textzone.new{
				width = self.c_desc.w,
				height = self.c_desc.h,
				text = (_t"Duration for Preset Timed Rest (slot1)."):toTString()},
			-- 設定ウィンドウ左側の黄色い各項目
			-- #で囲むと色などテキストの属性を変えることができる
			name = (_t"#GOLD##{bold}#Preset Timed Rest (slot1)#WHITE##{normal}#"):toTString(),
			-- 各項目の値をどう表示するか
			status = function(item)
				return tostring(config.settings.youhei.waiting_turns_1)
			end,
			-- 各項目をクリックして値を変更するときの挙動
			fct = function(item)
				-- 数字を入力するタイプはGetQuantity
				-- 第1引数はダイアログのタイトル
				-- 第2引数は入力欄左の説明
				-- 第3、4引数は第5引数のクロージャ内でも同じ役割っぽいのがあって謎。第4引数を変えてみると入力可能な最大値が変わるのは確認した。
				-- 第6引数は分からない
				game:registerDialog(GetQuantity.new(_t"Preset Timed Rest Duration (slot1)", _t"Turns", config.settings.youhei.waiting_turns_1, 999, function(qty)
					qty = util.bound(qty, 1, 999)
					game:saveSettings("youhei.waiting_turns_1", ("youhei.waiting_turns_1 = %d\n"):format(qty))
					config.settings.youhei.waiting_turns_1 = qty
					self.c_list:drawItem(item)
				end, 1))
			end
		}
		-- 略 スロット2
	end
end)
```

本体の`mod/dialogs/GameOptions.lua`で他にもたくさんの例を見ることができる。

### キー割当可能なアクション
`hooks/load.h`でアクションを登録して
```lua
local KeyBind = require 'engine.KeyBind'

class:bindHook("ToME:load", function(self, data)
	...

	KeyBind:defineAction {
		default = { 'sym:_r:false:true:false:false' },
		type = 'REST_TIMED_PRESET1',
		group = 'actions',
		name = _t'Preset Timed Rest (slot1)',
	}
	-- 略 スロット2
end)
```

`mod/class/Game.lua`の`setupCommands()`をsuperloadして実装を追加する。
```lua
local _M = loadPrevious(...)

local base_setupCommands = _M.setupCommands
function _M:setupCommands()
	-- 元からあるアクションを消してしまわないように
	base_setupCommands(self)
	game.key:addBinds {
		-- defineActionのtypeと対応させる
		REST_TIMED_PRESET1 = function()
			local turns = config.settings.youhei.waiting_turns_1 or 10
			if turns > 1 then game.player:restInit(turns - 1) end
		end
	}
	-- 略 スロット2
end

return _M
```

[zizzo]:https://te4.org/games/addons/tome/timed-rest
[preset]:https://te4.org/games/addons/tome/preset-timed-rest
