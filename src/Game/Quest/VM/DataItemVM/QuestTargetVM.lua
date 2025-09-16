---
--- Author: lydianwang
--- DateTime: 2021-11-11
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local QuestDefine = require("Game/Quest/QuestDefine")
local DialogueUtil = require("Utils/DialogueUtil")
local CommonUtil = require("Utils/CommonUtil")
local ColorUtil = require("Utils/ColorUtil")

local UIBindableList = require("UI/UIBindableList")
local ItemVM = require("Game/Item/ItemVM")

local TargetCfg = require("TableCfg/QuestTargetCfg")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local TARGET_STATUS = ProtoCS.CS_QUEST_NODE_STATUS
local QUEST_TARGET_TYPE = ProtoRes.QUEST_TARGET_TYPE

---@class QuestTargetVM : UIViewModel
local QuestTargetVM = LuaClass(UIViewModel)

function QuestTargetVM:Ctor()
	self:Reset()
	self:SetNoCheckValueChange("Count", true)
end

function QuestTargetVM:Reset()
	self.TargetID = nil
	self.GroupedTargetIDList = {}

	self.Desc = nil
	self.CountdownStr = nil

	self.Status = nil
	self.MaxCount = nil
	self.Count = 0

	self.ItemVMList = UIBindableList.New(ItemVM, {IsCanBeSelected = false, IsShowNumProgress = true})

	self.MapIDList = {} -- map< int MapID, bool >

	self.OwnerChapterVM = nil

	self.IsFocusTarget = nil

	self.IsShowItemView = nil
end

function QuestTargetVM:IsEqualVM(Value)
	return (self.TargetID == Value.TargetID) -- 对于不同目标组，TargetID有可能相等，导致创建TargetVM时检测到相似VM
		and (self.OwnerChapterVM ~= nil) and (Value.OwnerChapterVM ~= nil)
		and (self.OwnerChapterVM.ChapterID == Value.OwnerChapterVM.ChapterID)
		-- and (self.Desc == Value.Desc)
end

local function ParseRichText(Str)
	Str = DialogueUtil.ParseLabel(Str)
	Str = CommonUtil.GetTextFromStringWithSpecialCharacter(Str)
	Str = ColorUtil.ParseItemNameBrightStyle(Str)
	return Str
end

function QuestTargetVM:UpdateVM(Value)
	if Value == nil then self:Reset() return end
	local InTargetID = Value.TargetID
	if InTargetID == nil then return end

	if (self.TargetID ~= InTargetID)
	or (InTargetID < 1000) then -- 不同任务的目标组TargetID可能相同，这里牺牲一点性能
		self.TargetID = InTargetID

		if InTargetID == -1 then -- 任务可提交（无任务目标）时用于占位
			self.Desc = "提交任务"
		elseif _G.QuestFaultTolerantMgr:IsFaultTolerantTarget(InTargetID) then -- 容错任务目标
			self.Desc = ParseRichText(Value.Desc)
		elseif InTargetID < 1000 then -- 目标组索引
			self.Desc = ParseRichText(Value.Desc)
			self.GroupedTargetIDList = Value.GroupedTargetIDList
		else
			if not string.isnilorempty(Value.OverDesc) then
				self.Desc = Value.OverDesc
			else
				self:ReadTable()
			end
		end
	end

	self.Status = Value.Status
	self.MaxCount = Value.MaxCount
	self.Count = Value.Count
	self.IsShowItemView = Value.IsShowItemView

	local bFinished = (self.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED)
	if Value.GetMapIDList and (not bFinished) then
		self.MapIDList = Value:GetMapIDList()
	else
		self.MapIDList = {}
	end

	self.OwnerChapterVM = Value.OwnerChapterVM

	-- 物品提交
	self.ItemVMList:Clear()
	if Value.Cfg then
		if Value.Cfg.m_iTargetType == QUEST_TARGET_TYPE.QUEST_TARGET_TYPE_GET_ITEM then
			if Value.IsShowItemView then
				--target desc
				local Len = #Value.RequiredNumList
				if Len == 1 then
					self.MaxCount = Value.RequiredNumList[1] or 1
					self.Count = Value.OwnedItemCountList[1] or 0
				end

				--item view list
				local Items = {}
				for Index, ItemResID in ipairs(Value.RequiredItemList) do
					local NeedNum = Value.RequiredNumList[Index]
					local NeedMagic = Value.MagicsparList[Index]
					local IsNeedMagic = NeedMagic ~= nil
					local ItemVMData = {ResID = ItemResID, Num = NeedNum, IsShowNum = not IsNeedMagic}
					table.insert(Items, ItemVMData)
				end
				self.ItemVMList:UpdateByValues(Items)
			end
		end
	end
end

function QuestTargetVM:ReadTable()
	local Cfg = TargetCfg:FindCfgByKey(self.TargetID)
	if not Cfg then return end
	local TargetType = Cfg.m_iTargetType
	self.Desc = (Cfg.m_szTargetDesc == "")
		and QuestDefine.TargetClassParams[TargetType].Desc
		or ParseRichText(Cfg.m_szTargetDesc)
end

function QuestTargetVM:UpdateCountdown(Countdown)
	self.CountdownStr = (Countdown ~= nil)
		and _G.DateTimeTools.TimeFormat(Countdown, "smart-h:mm:ss", false)
		or nil
end

function QuestTargetVM:UpdateItemList()
	local ItemVMList = self.ItemVMList
	if ItemVMList then
		if ItemVMList:Length() > 0 then
			local Items = ItemVMList:GetItems()
			for _, ItemVM in ipairs(Items) do
				local Value = ItemVM.Item
				if Value then
					if Value.IsShowNum then
						local Num = _G.BagMgr:GetItemNum(Value.ResID)
						ItemVM:SetNumProgress(Num)
					end
				end
			end
		end
	end
end

---@return ChapterVM
function QuestTargetVM:GetChapterVM()
	return self.OwnerChapterVM
end

function QuestTargetVM:GetMapIDList()
	return self.MapIDList
end

return QuestTargetVM