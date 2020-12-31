+++
title = "ToME4アドオン「QuickTome QoL Changes mod. Grouping」を作った"
description = """ToME4でゾーン間をテレポートするアドオンの目的地を選択しやすくするアドオンの紹介と実装
"""
date = 2020-12-31T16:42:27+09:00
toc = true
syntax = true
+++
<!--more-->
## 目的
店の商品が入荷した後の店巡りのためにいくつもの街を移動するのが面倒だった。

「[QuickTome QoL Changes][qt]」というRod of Recallでどこのゾーンにもテレポートできるようにしたり、穴掘りモードを追加したり、錬金術クエストのNPCなどとどこからでも話せるアイテムを追加したりするアドオンがある。\
それを使えば店巡りの面倒がある程度解決されるんだけど、以前使ったときゾーンの選択肢が多すぎて目的のゾーンを見つけにくいのが不満だった。

ということで「[QuickTome QoL Changes][qt]」のゾーン選択部分を階層化して目的のゾーンを見つけやすくするアドオンを作ることにした。

街など何度も行くことになるゾーンは階層化することなく直接選び、ダンジョンは階層化された選択肢から選ぶようにしている。\
メインキャンペーンではダンジョンを東西の大陸で分けている。\
Embers of Rageキャンペーンではダンジョンを橋を渡る前と後で分けている。

Tinkerエスコート報酬で出現するAncient CaveとYeti Mussle Tissueとの交換ができるOld Psi-Machineがいる階層もテレポート先に追加した。

[ダウンロードはこちら][mod]

注意：単体では機能しません。オリジナルの「[QuickTome QoL Changes][qt]」とともに有効にしてください。

## 実装
オリジナルのアドオンではRod of Recallを使った後につくエフェクトの効果時間が過ぎたとき、各ゾーンの入口からワールドマップに出たときに`require("engine.Chat").new("qt-recall", 略):invoke()`が呼ばれて`data/chats`以下のnewの第1引数と同名のファイルをもとに対話形式のダイアログが作られるようになっている。よって`data/chats/qt-recall.lua`をoverloadすることで実装することになる。

overloadはファイルの中身を置き換える以外にも特定のパスにファイルを置くことにも使うようで、オリジナルのアドオンでも`overload/data/chats/qt-recall.lua`に目的の処理が実装されている。これをoverloadするにはオリジナルのアドオンより後に読み込まれる必要がある。`init.lua`のweightが小さいほど先に読み込まれるのでオリジナルのアドオンよりweightを大きい値にする。

### チャットダイアログの定義
ToME本体の`data/chats`以下のファイルも見てみるとこのような感じでチャットを定義するようだ。またファイルの最後で返すidで定義されたものがはじめに表示される。慣習でwelcomeというidをつけているみたいだ。
```lua
newChat{ id="welcome",
	text = "example text",
	answers = answerList,
}

return "welcome"
```
answersには表示名と選択したときの挙動を含んだテーブルの羅列を入れる。チャットを終了するならテーブルの中身は表示名だけでいい。
```lua
answerList = {
	{_t"Cancel"},
}
```
jumpでチャットを遷移できる。
```lua
newChat{ id="welcome",
	text = "略",
	answers = {
		{_t"Cancel"},
		{"Dungeons", jump="dungeons"},
	}
}
newChat{ id="dungeons",
	text = "略",
	answers = {
		{_t"Cancel", jump="welcome"},
	}
}
```
actionで任意の関数を実行できる。
```lua
local function changeZone(zone)
	-- マップ移動をする処理
end

answerList = {
	{_t"Last Hope", action=changeZone(zone) },
}
```

### 選択肢の生成
繰り返し処理しやすい形でゾーンの情報をテーブルに保存しておいて、後で`table.insert`を使って選択肢の一覧を表す変数`answerList`に追加していく。\
`name`は表示名。\
`cond`は[選択肢のフィルタリング](#選択肢のフィルタリング)で使う。\
`zone`は[ゾーンを移動する処理](#ゾーンを移動する処理)で使う。\
`wildx`と`wildy`は[ワールドマップ上でのプレイヤーの座標を移動したゾーンに合わせる](#ゾーンを移動する処理)のに使う。
```lua
zones = {
	{
		name = _t"Last Hope",
		cond = westCond,
		zone = "town-last-hope",
		wildx = 60,
		wildy = 39,
	},
	-- 他いろいろなゾーン
}
for i,z in pairs(zones) do
	if z.cond then
		table.insert(answerList,
			{ z.name, action = changeZone(z)})
	end
end
```

### 選択肢のフィルタリング
- 東の大陸に到達した後は、ワープ装置を完成させるまで西側の大陸に行くことができない。
- 特定の種族やクラスでしか入れないゾーンがある。
- Zigurは魔法を習得していると入れない。

などアドオンなしでは入れないゾーンは入れないままにしておきたいのでテレポートの選択肢から外す。

`engine/dialogs/Chat.lua`を見ると、選択肢を表示するかどうか判定する関数をanswersのcondに指定できるみたいだけど、オリジナルのアドオンではanswersに指定するテーブルanswerListの生成時にあらかじめ関数を評価してanswerListから弾いている。何度も同じ関数を評価するのもなんなのでこのアドオンでは関数ではなくbool値を使うことにした。

判定に利用できるものをあげると
```lua
-- アドオンやDLCが入っているかの判定
-- アドオン名にはinit.luaのshort_nameを使う
-- Ashes of Urh'Rokはashes-urhrok
-- Embers of Rageはorcs
-- Forbidden Cultsはcults、
game.__mod_info.addons["アドオン名"]

-- 現在遊んでいるキャンペーンの判定
-- メインキャンペーンはMaj'Eyal
-- Embers of RageキャンペーンはOrcs
game:isCampaign("キャンペーン名")

-- すでに生成されたユニークNPCやユニークアイテムが入った配列
game.uniques["mod.class.NPC/NPC名"]
game.uniques["mod.class.Object/アイテム名"]
game.uniques["mod.class.Encounter/イベント名"]
-- といった形で値が帰ってくるかで判定に使う

-- プレイヤーキャラクターの情報が入ったテーブルの取得
local player = game:getPlayer(true)
player.level
-- 種族
player.descriptor.subrace
-- クラス
player.descriptor.subclass
-- タレントを習得しているか
player:knowTalent(player.T_タレントの識別子)
-- アイテムを持っているか
player:findInAllInventoriesBy("define_as","アイテムの識別子")
-- 魔法を習得しているか
player:attr("has_arcane_knowledge")
-- 反魔法フォロワーか
player:attr("forbid_arcane")

-- Lore
game.party:knownLore("Lore名")

-- クエスト関連
-- クエストの情報が入ったテーブルの取得。そのクエストが発生していなければnilが帰ってくる。
player:hasQuest("クエスト名")
-- クエストが完了しているか
player:hasQuest("クエスト名"):isStatus(engine.Quest.DONE)
-- クエストがいくつかの区切りに分かれているとき、その区切りまで完了しているか
player:hasQuest("クエスト名"):isCompleted("区切り名")
-- エスコートクエストなどクエスト名がその度に変わって名前からは探しにくいときは、発生しているクエストの配列が利用できる。
player.quests
-- エスコートクエストでAncient Caveの場所を教えてもらったかどうかの例
local tinkerCond = false
	for i,q in pairs(player.quests) do
		if q.reward_message and q.reward_message == "gained knowledge of tinker technology" then
			tinkerCond = true
		end
	end
```

### ゾーンを移動する処理
``` lua
function changeZone(zone) return function()
	if not zone.dontAdjustWildpos then
		-- ここでは省いているgame.state.qt_recall_onLevelLoadCountはonLevelLoadを登録した後ワールドマップに移動する前に他のonLevelLoadが登録されて…以下繰り返しの対処みたい。実際どうなるのかは分かってない
		-- ワールドマップ上のプレイヤーの座標をテレポートしたゾーンの入口に合わせる処理
		game:onLevelLoad("wilderness-1", function(_zone, level)
			local p = game:getPlayer(true)
			-- 新しくゲームを始める度に違う場所に生成されるゾーンはワールドマップの全座標を総当りしてそのゾーンの入口を見つけて、その座標にプレイヤーを移動する
			if zone.rand then
				for x=0,game.level.map.w-1 do
					for y=0,game.level.map.h-1 do
						local grid = game.level.map:checkAllEntities(x,y,"change_zone")
						if grid == zone.zone then
							p.wild_x = x
							p.wild_y = y
							goto loopend
						end
					end
				end
				::loopend::
			-- 生成場所が決まっているゾーンはあらかじめゲーム内のデバッグモードで座標を調べて書いておき、直接座標を指定する。
			else
				if zone.wildx and zone.wildy then
					p.wild_x = zone.wildx
					p.wild_y = zone.wildy
				end
			end
			if p.level >= 14 and isMajEyal and not p:hasQuest("lightning-overload") then
				p:grantQuest("lightning-overload")
			end
		end)
	end
	-- 実際にテレポートする処理、第1引数はゾーンの階層
	game:changeLevel(zone.level or 1, zone.zone)
end end
```

### 目的の選択肢を探しやすくする
ゾーンをアルファベット順に並べる。
特別先に表示されてほしいゾーンは[ゾーンの情報を保存するテーブル](#選択肢の生成)でsortに0より小さい数字を入れる。sortが小さいほど先に表示されて、同じ場合はアルファベット順になる。
```lua
local function compareDestinations(dest1,dest2)
	local sort1 = dest1.sort or 0
	local sort2 = dest2.sort or 0
	if sort1 > sort2 then
		return false
	elseif sort1 < sort2 then
		return true
	else
		return string.lower(dest1.name) < string.lower(dest2.name)
	end
end

table.sort(zones,compareDestinations)
```

ダンジョンを階層化して一度に表示される選択肢を減らす。

- [ゾーンの情報を保存するテーブルの羅列](#選択肢の生成)をいくつかのグループに分ける。
- [チャットダイアログの遷移](#チャットダイアログの定義)を利用して表示するグループを切り替える。
- グループごとに[選択肢の生成](#選択肢の生成)をする。

という形で実現している。

[qt]:https://te4.org/games/addons/tome/qt-improved-recall
[mod]:https://te4.org/games/addons/tome/qt-qol-grouping
