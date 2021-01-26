+++
title = "ToME4アドオン「Use Base Stat for Prerequisites」を作った"
description = """
ToME4で要求ステータスを満たすのにベースステータスのみを使うことでステータス増加付き装備集め及び着替えの面倒をなくすアドオンの紹介と実装
"""
date = 2021-01-25T09:35:31+09:00
toc = true
syntax = true
+++
<!--more-->
## 目的
装備の装備条件やタレントの習得条件でステータスが一定以上ないといけない条件がある。それを満たすのに、そのキャラクターで特に有用なステータス以外はステータスが上昇する装備を一時的に装備するのが常套手段。だけどそのために装備を集めたり、使わない種類の装備の性能にまで気をつけたり、条件を満たすための装備に着替えて戦闘用の装備に戻すなんてかなり面倒なんだよね。

それを解決するために装備条件やタレント習得条件にベースステータスだけを使うアドオンを作ることにした。そのままでは条件が厳しくなってしまうから要求ステータスを下げることに。初期ステータスは10が基本になっているみたいなので要求ステータスの内10を超える分を半分にした値を使った。
```
  要求ステ - ((要求ステ - 10) / 2)
= 要求ステ - (要求ステ / 2 - 5)
= (要求ステ / 2) + 5
```

[ダウンロードはこちら](https://te4.org/games/addons/tome/base-stat-prereq)

## 実装
### 装備条件とタレント習得条件の判定
装備条件は`engine/interface/ActorInventory.lua`の`canWearObject()`で、タレント習得条件は`engine/interface/ActorTalents.lua`の`canLearnTalent()`で判定している。

それらをsuperloadして要求ステータスを満たすかどうか判定し、満たさなければ満たさなかった旨を返し、満たすのならば他の条件を満たしているか判定するため元の処理に任せる。ただし元の処理には要求ステータスの判定は無視してもらう。

```lua
-- ActorInventory.lua

local _M = loadPrevious(...)

local baseCanWearObject = _M.canWearObject
function _M:canWearObject(o, try_slot)
	local req = rawget(o, "require")
	if req then
		if req.stat then
			-- 要求ステータスが複数あるものもある
			for s, v in pairs(req.stat) do
				v = math.floor(v/2) + 5
				-- gatStat()の第4引数にtrueを指定するとベースステータスが取得できる
				local stat = self:getStat(s, nil, nil, true)
				if stat < v then return nil, _t"not enough stat" end
			end
			-- 元の処理でもif req.stat thenで要求ステータスの判定に入る。ステータスは無視してほしいからreq.statをfalseにするといい。
			-- req.stat = falseだとうまくいかないのでメタテーブルを使って同じことをする。
			local _o = o
			local _req = setmetatable({stat = false}, {__index = req})
			o = setmetatable({require = _req}, {__index = _o})
		end
	end
	return baseCanWearObject(self, o, try_slot)
end

return _M
```
```lua
-- ActorTalents.lua

local _M = loadPrevious(...)

local baseCanLearnTalent = _M.canLearnTalent
function _M:canLearnTalent(t, offset, ignore_special)
	if rawget(t, "require") then
		local req = t.require
		local tlev = self:getTalentLevelRaw(t) + (offset or 1)
		if type(req) == "function" then req = req(self, t) end
		if req.stat then
			for s, v in pairs(req.stat) do
				v = util.getval(v, tlev)
				v = math.floor(v/2) + 5
				local stat = self:getStat(s, nil, nil, true)
				if stat < v then return nil, ("not enough stat: %s"):tformat(s:upper()) end
			end
			local _t = t
			local _req = setmetatable({stat = false}, {__index = req})
			t = setmetatable({require = _req}, {__index = _t})
		end
	end
	return baseCanLearnTalent(self, t, offset, ignore_special)
end

return _M
```

### 装備やタレントの説明に表示される要求ステータス
タレントの説明を表示するとき、タレント習得条件の部分の説明は`engine/interface/ActorTalents.lua`の`getTalentReqDesc()`で生成されている。この関数はステータスの部分だけ変えて元の処理に任せることができるようには作られていないのでコピー＆ペーストしてステータスの部分だけ書き換えた。
```lua
function _M:getTalentReqDesc(t_id,levmod)
	...
	if req.stat then
		for s, v in pairs(req.stat) do
			v = util.getval(v, tlev)
			v = math.floor(v/2) + 5
			local stat = self:getStat(s, nil, nil, true)
			local c = (stat >= v) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
			str:add(c, ("- %s %d"):format(self.stats_def[s].name, v), true)
		end
	end
	...
```

装備の説明を表示するとき、装備条件の部分の説明は`engine/Object.lua`の`getRequirementDesc()`で生成されている。この関数もステータスの部分だけ変えて元の処理に任せることができるようには作られていない。また、[Cleaner Item Description][cleaner]や[Better Item Description][better]といったアドオンでもsuperloadして書き換えられている。
`game.__mod_info.addons["アドオン名"] ~= nil`を用いて条件分岐をして、アドオンなしおよびそれぞれのアドオンで想定通りの表示がされるようにコピー＆ペーストでつぎはぎした。

```lua
function _M:getRequirementDesc(who)
	local hasCleanerDesc = game.__mod_info.addons["cleaner-descriptions"] ~= nil
	local hasBetterDesc = game.__mod_info.addons["better_item_desc"] ~= nil
	local hasDescMod = hasCleanerDesc or hasBetterDesc
	...
	if req.stat then
		for s, v in pairs(req.stat) do
			v = math.floor(v/2) + 5
			local stat = who:getStat(s, nil, nil, true)
			local c = (stat >= v) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
			if hasDescMod then
				if stat < v or is_ctrl then
					if hasCleanerDesc then
						str:add(num>0 and "," or "",c,("%s %d"):format(who.stats_def[s].short_name:capitalize(), v), {"color", "LAST"})
					else
						str:add(c,num>0 and mod_align_stat() or "",("%s %d"):tformat(who.stats_def[s].short_name:capitalize(), v), {"color", "LAST"})
					end
					num = num + 1
				end
			else
				str:add(c, "- ", ("%s %d"):format(who.stats_def[s].name, v), {"color", "LAST"}, true)
			end
		end
		if hasDescMod and num>0 then str:add(true) end
	end
	...
end
```

[cleaner]:https://te4.org/games/addons/tome/cleaner-descriptions
[better]:https://te4.org/games/addons/tome/better_item_desc
