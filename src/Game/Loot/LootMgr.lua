---
--- Author: anypkvcai
--- DateTime: 2021-09-14 10:11
--- Description:
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
--local GameNetworkMgr = require("Network/GameNetworkMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ProtoCS = require("Protocol/ProtoCS")
local BagMgr = require("Game/Bag/BagMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local ScoreCfg = require("TableCfg/ScoreCfg")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local ChatMgr
local LSTR = _G.LSTR
local LOOT_TYPE = ProtoCS.LOOT_TYPE
local CS_CMD = ProtoCS.CS_CMD
local FLOG_ERROR = _G.FLOG_ERROR
local DropReason = "Common"  --排查BUG用
--local SUB_MSG_ID = ProtoCS.CS_BAG_CMD

---@class LootMgr : MgrBase
local LootMgr = LuaClass(MgrBase)

function LootMgr:OnInit()
	self.CommonDropList = {}
	self.LastDropMsgList = {}
	self.SingleItemCacheList = {}
	self.IsSameTime = false
	self.IsDealyShow = false
end

function LootMgr:OnBegin()
	ChatMgr = require("Game/Chat/ChatMgr")
end

function LootMgr:OnEnd()
	self:UnRegisterAllTimer()
end

function LootMgr:OnShutdown()

end

function LootMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOOT, 0, self.OnNetMsgLoot)
	-- self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOOT, 0, self.OnNetMsgLoot)
end

function LootMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

function LootMgr:OnNetMsgLoot(MsgBody)
	--if SUB_MSG_ID.CS_CMD_BAG_USE_ITEM == SubMsgID then
	--	self:OnNetMsgBagUseItem(MsgBody)
	--end
	self:OnNetMsgLootItemUpdateRes(MsgBody)
end

function LootMgr:OnGameEventLoginRes(Params)
	print("LootMgr:OnGameEventLoginRes")
	self.IsDealyShow = false

	--self:SendMsgBagInfoReq()
end

-- 合并相同的货币
function LootMgr:MergeScoreItemIfSameResID(InLootList)
	if (InLootList == nil) then
		return {}
	end
	local Count = #InLootList
	if (Count <= 1) then
		return InLootList
	end

	local ResultList = {}
	table.insert(ResultList, InLootList[1])
	for Index = 2, Count do
		local ScoreData = InLootList[Index].Score
		if (ScoreData ~= nil) then
			local bSameScore = false
			for Key,Value in pairs(ResultList) do
				if (Value.Score ~= nil and Value.Score.ResID == ScoreData.ResID) then
					-- ResID 相同，则增加Number
					Value.Score.Value = Value.Score.Value + ScoreData.Value
					bSameScore = true
					break
				end
			end

			if (not bSameScore) then
				table.insert(ResultList, InLootList[Index])
			end
		else
			-- 不是货币，则不合并
			table.insert(ResultList, InLootList[Index])
		end
	end

	return ResultList
end

function LootMgr:OnNetMsgLootItemUpdateRes(MsgBody, IgnoreCache)
	local Msg = MsgBody
	if nil == Msg then
		return
	end

	local LootList = Msg.LootList
	if (Msg.Reason ~= nil) then
		local LowerReasonStr = string.lower(Msg.Reason)
		DropReason = "Common"
		if (string.find(LowerReasonStr, "fate.mapach")) then
			DropReason = "fate.mapach"
			self:SetDealyState(true)
			self:ShowForCommonReward(LootList)
		elseif(string.find(LowerReasonStr, "fate.reward")) then
			-- Fate 结算的时候这里需求延时弹出显示
			DropReason = "fate.reward"
			-- 合并显示相同的货币
			local MergedList = self:MergeScoreItemIfSameResID(LootList)
			LootList = MergedList
			self:SetDealyState(true)
			_G.EventMgr:SendEvent(_G.EventID.FateLateShowLoot, LootList)
		elseif(string.find(LowerReasonStr,"gate.reward")) then
			-- 金碟机遇临门结算显示时机由内部的游戏控制
			DropReason = "gate.reward"
			self:SetDealyState(true)
		elseif(string.find(LowerReasonStr, "fantasycard.sell")) then
			DropReason = "fantasycard.sell"
		elseif(string.find(LowerReasonStr, "fantasycard.npcreward")) then
			DropReason = "fantasycard.npcreward"
			self:SetDealyState(true)
		elseif(string.find(LowerReasonStr, "role.buddy.exp")) then
			DropReason = "role.buddy.exp"
		elseif(string.find(LowerReasonStr, "fantasycard.tournamentcollect")) then
			DropReason = "fantasycard.tournamentcollect"
			_G.EventMgr:SendEvent(_G.EventID.MagicCardTourneyLateShowLoot, LootList)
			return
		elseif string.find(LowerReasonStr, "fairycolor.raffle") then
			DropReason = "fairycolor.raffle"
			_G.LootMgr:SetDealyState(true)
			if not _G.JumboCactpotLottoryCeremonyMgr:CheckHasLottoryList() then
				_G.JumboCactpotLottoryCeremonyMgr:SetRaffleRewardNum(LootList[1].Score.Value) 
			else
				local RoleIds = _G.JumboCactpotLottoryCeremonyMgr:GetCachLottoryList()
				self:RegisterTimer(function() _G.JumboCactpotLottoryCeremonyMgr:TryShowGetRewardPanel(RoleIds, LootList[1].Score.Value) end, 4)
			end
		elseif string.find(LowerReasonStr, "crystaltower.reward") then
			DropReason = "crystaltower.reward"
			_G.LootMgr:SetDealyState(true)
		elseif string.find(LowerReasonStr, "minicactpot.reward") then
			DropReason = "minicactpot.reward"
			_G.LootMgr:SetDealyState(true)
		elseif string.find(LowerReasonStr, "monsterbasketball.reward") then
			DropReason = "monsterbasketball.reward"
			_G.LootMgr:SetDealyState(true)
		elseif string.find(LowerReasonStr, "gilgamesh.reward") then
			DropReason = "gilgamesh.reward"
			_G.LootMgr:SetDealyState(true)
		elseif string.find(LowerReasonStr, "pvpcolosseumcrystal.reward") then
			DropReason = "pvpcolosseumcrystal.reward"
			_G.LootMgr:SetDealyState(true)
		elseif string.find(LowerReasonStr, "fairycolor.joinraffle") then
			DropReason = "fairycolor.joinraffle"
			_G.LootMgr:SetDealyState(true)
			self:RegisterTimer(function() _G.JumboCactpotLottoryCeremonyMgr:ShowGetRewardPanel(LootList[1].Score.Value) end, 3.5)
		elseif string.find(LowerReasonStr, "role.fog.reward") then
			DropReason = "role.fog.reward"
			local TempLootList = {}
			for i=1,#LootList do
				table.insert(TempLootList, LootList[i])
			end
			self:RegisterTimer(function()
				self:HandleMultipleDrop(TempLootList)
				self:ShowSysChatDropList(TempLootList)
			end, 2)
			return
        elseif string.find(LowerReasonStr, "fish.firstexp") then
			DropReason = "fish.firstExp"
			local Fish = _G.FishMgr:GetFishData()
			local FishName = Fish and Fish.ID and _G.FishNotesMgr:GetFishName(Fish.ID)
			if FishName ~= nil then
				_G.FishNotesMgr:FirstFishEXPBonus(FishName, LootList[1].Score)
                return
			end
		elseif string.find(LowerReasonStr, "gather.firstaward") or string.find(LowerReasonStr, "gather.firstcollectaward") then
			DropReason = LowerReasonStr
			local GatherItem = _G.CollectionMgr:GetGatherItem()
			local ResID = GatherItem and GatherItem.ResID
			local ItemName = ItemCfg:GetItemName(ResID)
			if ItemName then
				_G.GatheringLogMgr:FirstGatherEXPBonus(ItemName,LootList[1].Score)
				return
			end
		elseif string.find(LowerReasonStr, "crafter.firstmake") then
			DropReason = "crafter.firstmake"
			local Item = _G.CraftingLogMgr.NowPropData
			local ItemName = Item and Item.Name
			if ItemName then
				_G.CraftingLogMgr:FirstCraftEXPBonus(ItemName,LootList[1].Score)
				return
			end
		elseif(string.find(LowerReasonStr, "role.trade.buy")) then
			DropReason = "role.trade.Buy"
			self:HandleMultipleDrop(LootList)
			_G.MarketMgr:ShowSysChatObtainItemMsg(LootList[1].Item.ResID, LootList[1].Item.Value)
			return
		elseif(string.find(LowerReasonStr, "role.chocobo.racefinish")) then
			DropReason = "role.chocobo.racefinish"
		elseif (string.find(LowerReasonStr, "role.effect.directupgrade")) then
			DropReason = "role.effect.directupgrade"
			_G.UpgradeMgr:GetDirectUpgradeLoot(LootList)
			self:ShowSysChatDropList(LootList)
			return
		elseif(string.find(LowerReasonStr, "role.levelquest.submittask")) then
			DropReason = "role.levelquest.submittask"
			local ChatLootList = table.deepcopy(LootList)
			local TempLootList = LootList
			if not ProfUtil.IsProductionProf(MajorUtil.GetMajorProfID()) then
				for index, item in ipairs(LootList) do
					if item.Score and item.Score.ProfID ~= nil and item.Score.ProfID ~= 0 then
						if RoleInitCfg:FindProfSpecialization(item.Score.ProfID) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
							table.remove(TempLootList, index)
						end
					end
				end
			end
			LootList = TempLootList
			self:ShowSysChatDropList(ChatLootList)
			self:HandleMultipleDrop(LootList)
			return
		end
	end

	_G.EventMgr:SendEvent(_G.EventID.TreasureHuntGetItem)
	_G.EventMgr:SendEvent(_G.EventID.LootItemUpdateRes, Msg.LootList, Msg.Reason)

	self:HandleMultipleDrop(LootList)
	self:ShowSysChatDropList(LootList)
	-- self:ShowLootList(LootList)
end

function LootMgr:ShowForCommonReward(LootList)
	if (LootList == nil or type(LootList) ~= "table") then
		_G.FLOG_ERROR("LootMgr:ShowForCommonReward 错误，传入的 LootList 无效，请检查!")
		return
	end

	-- 这里去弹出通用显示
	local Cnt = #LootList
	if Cnt == 0 then
		return
	end

	local TempItemList = {}
	local Params = {}

	for Key, LootItem in pairs(LootList) do
		local Item = {}
		table.insert(TempItemList, Item)
		if (LootItem.Type == LOOT_TYPE.LOOT_TYPE_SCORE) then
			-- 钱币
			Item.ResID = LootItem.Score.ResID
			Item.Num = LootItem.Score.Value
		elseif (LootItem.Type == LOOT_TYPE.LOOT_TYPE_ITEM) then
			-- 物品
			Item.ResID = LootItem.Item.ResID
			Item.Num = LootItem.Item.Value
		else
			_G.FLOG_ERROR("错误的 LooItemType : "..LootItem.Type)
		end
	end

	Params.ItemList = TempItemList
	UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
end

--true 打开延迟显示 false 关闭
function LootMgr:SetDealyState(State)
	self.IsDealyShow = State
	if self.IsDealyShow then
		local function CloseDealyShow()
			self.IsDealyShow = false
			if self.DealyID then
				self:UnRegisterTimer(self.DealyID)
				self.DealyID = nil
			end
		end
		self.DealyID = self:RegisterTimer(CloseDealyShow, 30, 0, 1)
	end
end

function LootMgr:DoShowDropList()
	if self.LastDropMsgList and #self.LastDropMsgList > 0 then
		self:HandleMultipleDrop(self.LastDropMsgList, true)
		self:ShowSysChatDropList(self.LastDropMsgList)
		self.LastDropMsgList = {}
	end
end

function LootMgr:CancelWait()
	self:UnRegisterAllTimer()
	self.SingleItemCacheList = {}
	self.TimeID = nil
end

--- 一起计算堆叠显示	废弃没用的了
function LootMgr:DoShowTotalDropList()
	local LastDropMsgList = self.LastDropMsgList
	if table.is_nil_empty(LastDropMsgList) then
		return
	end
	--如果不重复就正常显示
	local Len = #LastDropMsgList
	if Len == 1 or (Len == 2 and LastDropMsgList[1].Type ~= LastDropMsgList[2].Type) then
		self:DoShowDropList()
		return
	end

	local ScoreMsg = nil
	local ItemMsg = nil
	for _, value in pairs(LastDropMsgList) do
		if value.Type == 0 then
			if ScoreMsg == nil then
				ScoreMsg = value
			else
				if ScoreMsg.Score.ResID ~= value.Score.ResID then
					--如果有不一样的也正常显示
					self:DoShowDropList()
					return
				end
				local ScoreValue = ScoreMsg.Score.Value
				ScoreMsg.Score.Value = ScoreValue + value.Score.Value
			end
		elseif value.Type == 1 then
			if ItemMsg == nil then
				ItemMsg = value
			else
				if ItemMsg.Item.ResID ~= value.Item.ResID then
					--如果有不一样的也正常显示
					self:DoShowDropList()
					return
				end
				local ItemValue = ItemMsg.Item.Value
				ItemMsg.Item.Value = ItemValue + value.Item.Value
			end
		end
	end
	local TotalDropMsgList = {}
	if ScoreMsg ~= nil then
		table.insert(TotalDropMsgList,ScoreMsg)
	end
	if ItemMsg ~= nil then
		table.insert(TotalDropMsgList,ItemMsg)
	end
	self:HandleMultipleDrop(TotalDropMsgList, true)
	self:ShowSysChatDropList(TotalDropMsgList)
	self.LastDropMsgList = {}
end

function LootMgr:ShowLootItem(LootItem)
	local View = UIViewMgr:FindView(UIViewID.DropTips)
	if nil == View then
		View = UIViewMgr:ShowView(UIViewID.DropTips)
	end

	if nil ~= View then
		View:AddLootItem(LootItem)
	end
end

--多物品掉落现在也改成了单个逐渐出现的表现
function LootMgr:HandleMultipleDrop(LootList)
	local Cnt = #LootList
	if Cnt == 0 then
		FLOG_ERROR("HandleMultipleDrop LootList Cnt = 0  Reason = %s", DropReason)
		return
	end

	if Cnt > 1 then
		for i = 1, Cnt do
			local List = {}
			table.insert(List, LootList[i])
			table.insert(self.SingleItemCacheList, List)
		end
	else
		table.insert(self.SingleItemCacheList, LootList)
	end

	self:ShowCommonDropList()
end

-- function LootMgr:Test()
-- 	local LootList = {}

-- 	for _ = 1, 5 do
-- 		local LootItem = { Type = 1, Item = { GID = 0, ResID = 60000001, Value = 1 } }
-- 		table.insert(LootList, LootItem)
-- 	end

-- 	LootMgr:ShowLootList(LootList)
-- end
-- local sd = 1
-- function LootMgr:Test1()
-- 	local LootList = {}
-- 	if false then
-- 		local LootItem = { Type = LOOT_TYPE.LOOT_TYPE_ITEM, Item = { GID = 0, ResID = 50211082, Value = sd } }
-- 		table.insert(LootList, LootItem)
-- 		for _ = 1, 2 do
-- 			local LootItem = { Type = LOOT_TYPE.LOOT_TYPE_ITEM, Item = { GID = 0, ResID = 50170011, Value = sd } }
-- 			table.insert(LootList, LootItem)
-- 		end
-- 		for _ = 1, 13 do
-- 			local LootItem = { Type = LOOT_TYPE.LOOT_TYPE_ITEM, Item = { GID = 0, ResID = 50180011, Value = sd } }
-- 			table.insert(LootList, LootItem)
-- 		end
-- 		for _ = 1, 3 do
-- 			local LootItem = { Type = LOOT_TYPE.LOOT_TYPE_SCORE, Score = { ResID = 19000099, Value = 99999999,  ProfID = 9 }}
-- 			table.insert(LootList, LootItem)
-- 		end
-- 		table.insert(LootList, { Type = LOOT_TYPE.LOOT_TYPE_SCORE, Score = { ResID = 19000099, Value = 1000231, Percent = 200, ProfID = 10 }})
-- 		LootMgr:ShowSysChatDropList(LootList)
-- 		LootMgr:ShowCommonDropList(LootList, true)
-- 	elseif true then
-- 		if sd%2 == 0 then
-- 			local LootItem = { Type = LOOT_TYPE.LOOT_TYPE_SCORE, Index = sd, Score = { ResID = 19000099, Value = sd,  ProfID = 9 }}
-- 			table.insert(LootList, LootItem)
-- 			LootMgr:ShowCommonDropList(LootList,false)
-- 		else
-- 			for i = 1, 5 do
-- 				local LootItem = { Type = LOOT_TYPE.LOOT_TYPE_SCORE, Index = sd +i-1, Score = { ResID = 19000099, Value = sd +i-1,  ProfID = 9 }}
-- 				table.insert(LootList, LootItem)
-- 			end
-- 			LootMgr:ShowCommonDropList(LootList,true)
-- 		end
-- 		sd = sd + 4
-- 		LootMgr:ShowSysChatDropList(LootList)
-- 	elseif sd% 5 ==0 then
-- 		for _ = 1, 3 do
-- 			local LootItem = { Type = LOOT_TYPE.LOOT_TYPE_SCORE, Score = { ResID = 19000004, Value = sd } }
-- 			table.insert(LootList, LootItem)
-- 		end
-- 		LootMgr:ShowCommonDropList(LootList)
-- 	elseif sd%3 == 0  then
-- 		for _ = 1, 2 do
-- 			local LootItem = { Type = LOOT_TYPE.LOOT_TYPE_ITEM, Item = { GID = 0, ResID = 50170011, Value = sd } }
-- 			table.insert(LootList, LootItem)
-- 		end

-- 		LootMgr:ShowCommonDropList(LootList)
-- 	elseif sd%4 == 0 then
-- 		local LootItem = { Type = LOOT_TYPE.LOOT_TYPE_ITEM, Item = { GID = 0, ResID = 50140270, Value = sd } }
-- 		table.insert(LootList, LootItem)

-- 		LootMgr:ShowCommonDropList(LootList)
-- 	else
-- 		for _ = 1, sd do
-- 			local LootItem = { Type = LOOT_TYPE.LOOT_TYPE_SCORE, Score = { ResID = 19000002, Value = sd } }
-- 			table.insert(LootList, LootItem)
-- 		end
-- 		LootMgr:ShowCommonDropList(LootList)
-- 	end
-- 	sd = sd + 1
-- 	if sd > 50 then
-- 		sd  = 1
-- 	end
-- end

-- 排序规则：物品品质，物品ID，积分ID
function LootMgr.SortDropList(DropList)
	local SortScoreList = {}
	local SortItemList = {}
	for _, Drop in ipairs(DropList) do
		if Drop.Type == LOOT_TYPE.LOOT_TYPE_SCORE then
			table.insert(SortScoreList, Drop)
		else
			table.insert(SortItemList, Drop)
		end
	end
	local SortByResID = function (Drop1, Drop2)
		if Drop1.Score.ResID < Drop2.Score.ResID then
			return true
		else
			return false
		end
	end
	table.sort(SortScoreList, SortByResID)
	local SortByItemQuality = function (Drop1, Drop2)
		if Drop2 == nil then
			 return true
		end
		local Cfg1 = BagMgr:FindEquipCfgByKey(Drop1.Item.ResID)
		local Cfg2 = BagMgr:FindEquipCfgByKey(Drop2.Item.ResID)

		if Cfg1 == nil or Cfg2 == nil then
			return true
		end

		if Cfg1.ItemLevel > Cfg2.ItemLevel then
			return true
		else
			return false
		end
	end
	local SortByItemResID = function (Drop1, Drop2)
		if Drop2 == nil then
			 return true
		end
		local Cfg1 = BagMgr:FindEquipCfgByKey(Drop1.Item.ResID)
		local Cfg2 = BagMgr:FindEquipCfgByKey(Drop2.Item.ResID)

		if Cfg1 == nil or Cfg2 == nil then
			return true
		end

		if Drop1.Item.ResID < Drop2.Item.ResID and Cfg1.ItemLevel > Cfg2.ItemLevel then
			return true
		else
			return false
		end
	end
	if #SortItemList > 0 then
		table.sort(SortItemList, SortByItemQuality)
		table.sort(SortItemList, SortByItemResID)
		for _, Score in ipairs(SortScoreList) do
			table.insert(SortItemList, Score)
		end
		return SortItemList
	else
		return SortScoreList
	end
end

function LootMgr:ShowSysChatDropList(CommonDropList)
	print("DropList Reason =", DropReason)
	local MajorProfID = MajorUtil.GetMajorProfID()
	local CommonDropListSorted = self.SortDropList(CommonDropList)
	if #CommonDropListSorted == 0 then
		FLOG_ERROR("CommonDropList len = 0 ")
	end
	for _, Drop in ipairs(CommonDropListSorted) do
		if Drop.Type == LOOT_TYPE.LOOT_TYPE_ITEM then --物品
			-- local ad = BagVM:GetItemsVMByResID(59990054)[1]
			ChatMgr:ShowGetGoodsTipsInSystemChannel(Drop.Item.ResID, Drop.Item.Value, Drop.Item.GID)
		elseif Drop.Type == LOOT_TYPE.LOOT_TYPE_SCORE then -- 积分<span color="#00FD2BFF">5</>Cfg.NameText   Drop.Score.Value                  Drop.Score.Percent
			--【“[职业名称]”职业】获得了[图标][金币]×[99,00](+ 200%)
			local Text = ""
			local ScoreInfo = ScoreCfg:FindCfgByKey(Drop.Score.ResID)
			if ScoreInfo == nil then
				FLOG_ERROR("LootMgr:ScoreInfo == Nil Check")
				return
			end

			local GetRitchText = RichTextUtil.GetText(string.format("%s", LSTR(1550001)), "d1ba8e", 0, nil)--获得了
			if DropReason == "fantasycard.sell" then
				GetRitchText = MagicCardMgr:GetUseCardSuccStr() or GetRitchText
			elseif DropReason == "role.chocobo.racefinish" then
				if ScoreInfo.ID == ProtoRes.SCORE_TYPE.SCORE_TYPE_CHOCOBO_RACE_EXP then
					GetRitchText = string.format("%s", _G.ChocoboMgr:GetRaceChocoboName()) .. GetRitchText
				end
			elseif DropReason == "role.buddy.exp" then
				if ScoreInfo.ID == ProtoRes.SCORE_TYPE.SCORE_TYPE_BUDDY_EXP then
					GetRitchText = string.format("%s", _G.BuddyMgr:GetBuddyName()) .. GetRitchText
				end
			end
			local IconRichText = RichTextUtil.GetTexture(ScoreInfo.IconName, 40, 40, -10)--EEDC83FF
			local ScoreRichText = RichTextUtil.GetText(string.format("[%s]", ScoreInfo.NameText), "DAB53AFF", 0, nil)
			local SoceNumRichText = RichTextUtil.GetText(string.format("x%s", LootMgr.FormatCurrency(Drop.Score.Value)), "d1ba8e", 0, nil)
			if ScoreInfo.ID == 19000099 then --经验有加成

				if Drop.Score.ProfID == 0 then
					FLOG_ERROR("LootMgr:ShowSysChatDropList csloot.proto Drop.Score.ProfID = 0 Error")
				else
					local ProfInfo = RoleInitCfg:FindCfgByKey(Drop.Score.ProfID)
					Text = string.format(LSTR(1550002), ProfInfo.ProfName)--职业
				end

				if Drop.Score.Percent ~= 0 then
					Text = string.format("%s%s%s%s%s  ( + %d%s)", Text, GetRitchText, IconRichText, ScoreRichText, SoceNumRichText, Drop.Score.Percent, "%")
				else
					Text = string.format("%s%s%s%s%s", Text, GetRitchText, IconRichText, ScoreRichText, SoceNumRichText)
				end
			else
				Text = string.format("%s%s%s%s", GetRitchText, IconRichText, ScoreRichText, SoceNumRichText)
			end
			ChatMgr:AddSysChatMsg(Text)
		end
	end
end

function LootMgr:ShowCommonDropList(CommonDropList, IsSameTime)
	if not self.TimeID then
		self.TimeID = self:RegisterTimer(self.AddLootList, 0, 0.7, 0)
	end
end

--采用先掉先飘后掉后飘，排队往前挤的方案
function LootMgr:AddLootList()
	if self.IsDealyShow then
		return
	end

	local View = UIViewMgr:FindView(UIViewID.CommonDropTips)
	if nil == View then
		View = UIViewMgr:ShowView(UIViewID.CommonDropTips)
	end

	if #self.SingleItemCacheList <= 0 then
		self:UnRegisterTimer(self.TimeID)
		self.TimeID = nil
		return
	end

	local LootItem = table.remove(self.SingleItemCacheList, 1)
	if (LootItem == nil) then
		return
	end

	local ShouldAdd = true
	-- 策划需求，如果在游戏中，并且获得的是幻卡或者金碟币，那么等结算界面弹出才显示，这里就先屏蔽了
	if (MagicCardMgr.CardGameId > 0 and not MagicCardMgr.IsGameEnd) then
		if (LootItem.Type == LOOT_TYPE.LOOT_TYPE_SCORE) then
			-- 钱币
			if (LootItem.Score.ResID == ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE) then
				ShouldAdd = false
			end
		elseif(LootItem.Type == LOOT_TYPE.LOOT_TYPE_ITEM) then
			-- 幻卡
			if (self:IsItemFantacyCard(LootItem.Item.ResID)) then
				ShouldAdd = false
			end
		end
	end
	if (ShouldAdd) then
		_G.EventMgr:SendEvent(_G.EventID.DealLootItem, LootItem[1])
	end
end

function LootMgr.FormatCurrency(CurrencyNum)
    local Result = tostring(CurrencyNum)
    Result = string.reverse(Result)
    local NewStr = ""
    local SubStepLen = 3
    local Index = 1
    local Len = string.len(Result)
    for _ = 1, Len do
        if Index > Len then
            break
        end
        if Index > SubStepLen then
            NewStr = string.format("%s%s", NewStr, ",")
        end
        NewStr = string.format("%s%s", NewStr, string.char(string.byte(Result, Index)))
        if Index + 1 > Len then
            break
        end
        NewStr = string.format("%s%s", NewStr, string.char(string.byte(Result, Index + 1)))
        if Index + 2 > Len then
            break
        end
        NewStr = string.format("%s%s", NewStr, string.char(string.byte(Result, Index + 2)))
        Index = Index + SubStepLen
    end
    return string.reverse(NewStr)
end

function LootMgr:GetCommonDropList(DropList,IsinitialTab)
	if IsinitialTab then
		for k,v in pairs(DropList) do
			self.CommonDropList[k] = v
		end
	else
		for _,v in pairs(DropList) do
			self.CommonDropList[#self.CommonDropList] = v
		end
	end
end

function LootMgr:IsItemFantacyCard(ItemID)
	if (ItemID <= 0) then
		return false
	end
	-- 这里看一下，是否为幻卡物品，如果是幻卡物品，那么判断一下，是否完成了任务，如果完成了任务，那么自动使用
	local Cfg = ItemCfg:FindCfgByKey(ItemID)
	if Cfg == nil then
		return false
	end

	if (Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_TRIPLETRIADCARD) then
		return true
	end

	return false
end

return LootMgr