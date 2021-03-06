+++
title = "ToME4アドオン「Free Respec」を作った"
description = """ToME4でステータス、タレント、カテゴリ、奥義を振り直せるようにするアドオンの紹介と実装
"""
date = 2020-12-11T10:05:32+09:00
syntax = true
toc = true
lastmod = 2021-02-20T11:58:51+09:00
+++
<!--more-->
## 目的
キャラクタービルドでいろいろ試したいことがあったりするとゲームをはじめからやり直さないといけないんだよね。また、キャラクタービルドでミスしてやる気をなくしたりとか。序盤だけ使いたいタレントがあると、他のタレントのレベルを上げるたびに、序盤だけ使いたいタレントのレベルを下げて上げ直さないといけなくて面倒だったりとか。

それを解決してくれるアドオンに「[Full Respecialization][full]」っていうステータス、タレント、カテゴリ、奥義を自由に振り直せるようにするアドオンがあるんだけど、ToME本体のバージョンが1.7系列に上がってから奥義を習得するときにエラーが出るようになってしまった。

バグ修正ついでに、ステータスを初期値以下にしてステータスポイント稼ぎができたり、はじめから覚えてるカテゴリや、イベントでカテゴリポイントを使わずに習得できるカテゴリを忘れてカテゴリポイント稼ぎができたり、Crefty Handsなど一時的に習得することで有利になる奥義を振り直しできたりと悪用できる部分を封じたアドオンを作ることにした。

[ダウンロードはこちら][free]

## 実装
superloadを使うと同じパスのファイルの中身を一部書き換えることができる。superloadでは`loadPrevious(...)`を使うことで元のファイルのモジュールを取得して変数に保存できる。慣習としてこの変数名には_Mがよく使われる。
```lua
-- 関数を書き換える例

local _M = loadPrevious(...)

-- 元の関数の処理を利用したい場合は関数を書き換える前に変数に保存する。
local base_元の関数名 = _M.元の関数名
-- 関数の書き換え
function _M:元の関数名(引数)
	-- 元の関数の前に追加したい処理

	base_元の関数名()

	-- 元の関数の後に追加したい処理
end

return _M
```

### ステータス
`mod/dialogs/LevelupDialog.lua`の`incStat()`がステータスを変更するときに呼ばれる関数。これをsuperloadする。

初めて呼ばれたときに初期ステータスを保存する。`self.actor.initial_stats`がステータスの保存に使っている変数。

引数のvには、振り分けのときは1が、振り直しのときは-1が入っている。

```lua
local base_incStat = _M.incStat
function _M:incStat(sid, v)
	-- 初期ステータスの保存
	if not self.actor.initial_stats then
		self.actor.initial_stats = {}
		-- kがステータスの種類, vがそれぞれのステータスの値
		for k, v in pairs(self.actor.stats) do
			self.actor.initial_stats[k] = v
		end
	end
	-- ステータス振り分けのときには元の関数を使う。
	if v == 1 then
		base_incStat(self, sid, v)
		return
	-- 振り直しのとき
	else
		-- ステータス初期値と比較して高い場合のみ振り直し処理を続行。
		if self.actor:getStat(sid, nil, nil, true) <= self.actor.initial_stats[sid] then
			self:subtleMessage(_t"Impossible", _t"You cannot take out more points!", subtleMessageErrorColor)
			return
		end
	end
	self.actor:incStat(sid, v)
	self.actor.unused_stats = self.actor.unused_stats - v
	self.stats_increased[sid] = (self.stats_increased[sid] or 0) + v
	self:updateTooltip()
end
```

### タレント
`mod/dialogs/LevelupDialog.lua`の`learnTalent()`がタレントを変更するときに呼ばれる関数。その中のタレントを忘れる処理で`isUnlearable()`を呼んでタレントを忘れてもいいか判定している。これをsuperloadする。

```lua
function _M:isUnlearnable(t, limit)
	-- 略

	-- This talent can alter the world in a permanent way ... と書かれている直近4ポイントでも振り直せないタレントの振り直し防止
	if t.no_unlearn_last and self.actor_dup:getTalentLevelRaw(t_id) >= self.actor:getTalentLevelRaw(t_id) then return nil end

	-- 基本的に許す
	return 1
end
```

### カテゴリ
`mod/dialogs/LevelupDialog.lua`の`learnType()`がカテゴリを変更するときに呼ばれる関数。これをsuperloadする。

カテゴリをポイントを使って習得したときにそのことを覚えておいて、ポイントを使って習得したカテゴリに限って忘れることを許すことで、はじめから覚えてるカテゴリや、イベントでカテゴリポイントを使わずに習得できるカテゴリを忘れることを防いでいる。

```lua
local base_learnType = _M.learnType
function _M:learnType(tt, v)
	-- はじめてこの関数が呼ばれたときには、ポイントを使って習得したカテゴリを覚えておく変数を初期化する
	self.actor.talent_types_learned = self.actor.talent_types_learned or {}
	-- カテゴリ習得時
	if v then
		base_learnType(self, tt, v)
		-- ポイントを使って習得したかどうか一時的に覚えておく変数の値を永続させる
		if self.talent_types_learned[tt][1] then self.actor.talent_types_learned[tt] = true end
	-- カテゴリを忘れるとき
	else
		-- 習得していないものは忘れることができない
		self.talent_types_learned[tt] = self.talent_types_learned[tt] or {}
		if not self.actor:knowTalentType(tt) then
			self:subtleMessage(_t"Impossible", _t"You do not know this category!", subtleMessageErrorColor)
			return
		end
		if (self.actor.__increased_talent_types[tt] or 0) > 0 then
			-- 略 実行レベル補正の強化を取り消す処理
		else
			-- ポイントを使って習得したカテゴリに限って忘れることを許す
			if self.actor.talent_types_learned[tt] then
				self.actor:unlearnTalentType(tt)
				-- カテゴリ内のタレントを習得していないかチェック
				local ok, dep_miss = self:checkDeps(nil, true)
				if ok then
					self.actor.unused_talents_types = self.actor.unused_talents_types + 1
					self.new_talents_changed = true
					self.talent_types_learned[tt][1] = nil
					self.actor.talent_types_learned[tt] = nil
				else
					self:simpleLongPopup(_t"Impossible", _t"You cannot unlearn this category because of: "..dep_miss, game.w * 0.4)
					self.actor:learnTalentType(tt)
					return
				end
			else
				self:subtleMessage(_t"Impossible", _t"You cannot unlearn this category!", subtleMessageWarningColor)
				return
			end
		end
		self:triggerHook{"PlayerLevelup:subTalentType", actor=self.actor, tt=tt}
	end
	self:updateTooltip()
end
```

### 奥義
`mod/dialogs/UberTalent.lua`の`use()`が奥義を変更するときに呼ばれる関数。これをsuperloadする。

一時的に習得することで有利になる奥義の判定ではWrithing Ring of the Hunter(装備している間、奥義を一時的に習得できる指輪)のコードを参考にした。`tome-cults/overload/mod/dialogs/RingOfTheHunter.lua`

```lua
-- mod/dialogs/UberTalent.lua

local base_use = _M.use
function _M:use(item)
	-- 忘れるとき
	if self.actor:knowTalent(item.talent) then
		local t = self.actor:getTalentFromId(item.talent)
		-- 一時的に習得することで有利になる奥義の振り直しを封じる
		if t.cant_steal or (t.on_learn and not t.on_unlearn) or (t.on_unlearn and not t.on_learn) then
			-- 第1引数はダイアログのタイトル。奥義の名前を表示する
			engine.ui.Dialog:simplePopup(util.getval(item.rawname, item), "You cannot unlearn this talent!")
			return
		end

		-- 第3引数をnilにすると忘れた奥義がオンオフ系だったときに解除する
		self.actor:unlearnTalent(item.talent, nil, nil, {no_unlearn=true})
		-- 覚えていた奥義を忘れるのをやっぱりやめたときに覚え直すために、今開いているウィンドウで忘れたことを保存しておく
		self.unlearnedTalents[item.talent] = true
		-- 奥義を覚えるのをやっぱりやめたときの元の関数の処理と残りは同じ。その分岐に入るように変数を書き換えて元の関数を呼ぶ
		self.levelup_end_prodigies[item.talent] = true
		base_use(self, item)
	-- 覚えるとき
	else
		-- 基本的に元の関数に任せる
		base_use(self, item)
		-- 今開いてるウィンドウで忘れた奥義を覚え直す
		if self.unlearnedTalents[item.talent] then
			self.actor:learnTalent(item.talent, true, nil, {no_unlearn=true})
			self.unlearnedTalents[item.talent] = false
			self.levelup_end_prodigies[item.talent] = false
		end
	end
end
```

なにか振り分けした後にダイアログを閉じると変更を確定するか取り消すか選択するポップアップがでてきて、変更を確定したら実際にタレントを習得する処理が走るのだけど、奥義の振り分けがあったかどうかの判定には振り分け可能なポイントの変更があったかどうかだけを見ている。振り直しを許さない場合はそれで問題ないのだけど、なにか奥義を忘れて他の奥義を覚えるとした場合、振り分け可能なポイントには変更がないけど振り分けが行われている。

| 振り分け | ポップアップ | 変数の変化 |
| --- | --- | --- |
| なにかに振り分けた | 必要 | `unused_prodigies`<br>`levelup_end_prodigies` |
| なにかを忘れた | 必要 | `unused_prodigies` |
| なにかに振り分けたが<br>やっぱりやめた | 不要 | なし |
| なにかを忘れたが<br>やっぱりやめた | 不要 | なし |
| なにかを忘れて<br>別のものに振り分けた | 必要 | `levelup_end_prodigies` |

また`mod/dialogs/LevelupDialog.lua`の`createDisplay`でProdigies(奥義)ボタンが押されたときに
```lua
require("mod.dialogs.ubertalent").new(self.actor, self.on_finish_prodigies)
```
で奥義習得ダイアログを生成していて、
`mod/dialogs/UberTalent.lua`の`init()`の第2引数は`levelup_end_prodigies`なので`on_finish_prodigies`と`levelup_end_prodigies`は同じものを指している。

よって奥義の振り分けが行われたかの判定に`on_finish_prodigies`も使えばいい。その判定は`mod/dialogs/LevelupDialog.lua`の`init()`の`key:addBinds{EXIT}`で行われている。これをsuperloadする。元の処理をコピーして判定部分を書き換えた。

```lua
local base_init = _M.init
function _M:init(actor, on_finish, on_birth)
	base_init(self, actor, on_finish, on_birth)
	self.key:addBinds{
		EXIT = function()
			local changed = --略
			-- 略 アドオンなしでも振り直し可能な直近のタレント振り分けに変化がないか。あればchanged = true
			
			-- on_finish_prodigiesの各要素がすべてfalseでも存在していたらon_finish_prodigies自体は中身のあるテーブルで真と判定されるのでループをかけて各要素を見る
			if self.on_finish_prodigies then
				for tid, ok in pairs(self.on_finish_prodigies) do
					if ok then
						changed = true
						break
					end
				end
			end
			if 略、ステータスやタレント、カテゴリに変化がある or self.actor.unused_prodigies ~= self.actor_dup.unused_prodigies or changed then
				-- 略 変更を確定するかキャンセルするかを選択するポップアップ
			else
				-- 略 ダイアログを閉じる
			end
		end,
	}
end
```

振り直せなくした奥義がどれなのかを表示するために`mod/dialogs/UberTalent.lua`の`getTalentDesc()`をsuperloadしている。

元の関数をそのままコピーしてタレント名と習得条件の間に以下のコードを入れた。
```lua
function _M:getTalentDesc(item)
	...
	local t = self.actor:getTalentFromId(item.talent)
	if t.cant_steal or (t.on_learn and not t.on_unlearn) or (t.on_unlearn and not t.on_learn) then
		text:add({"color","YELLOW"}, _t"This talent can alter the world in a permanent way; as such, you can never unlearn it once known.", {"color","LAST"}, true, true)
	end
	...
```

[full]:https://te4.org/games/addons/tome/FullRespec
[free]:https://te4.org/games/addons/tome/free-respec
