local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local TimeUtil = require("Utils/TimeUtil")

local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local LSTR = _G.LSTR
---@class NightGiftPrepareExchangeVM : UIViewModel
local NightGiftPrepareExchangeVM = LuaClass(UIViewModel)

---Ctor
function NightGiftPrepareExchangeVM:Ctor()
    self.TitleText = nil
	self.PrepareDesc = nil
	self.ExchangeDesc = nil
	self.DetailDesc = nil
	self.ProgressDesc = nil
	self.ButtonText = nil
	self.BtnEnabled = nil

	self.PutGiftLockVisible = nil
	self.GetGiftLockVisible = nil
	self.PutGiftButtonText = nil
	self.GetGiftButtonText = nil

	self.PutGiftButtonSelelcted = nil
	self.GetGiftButtonSelelcted = nil

	self.PutGiftTabColor = nil
	self.GetGiftTabColor = nil
end



function NightGiftPrepareExchangeVM:ShowPutGift(ActivityData)
	self.PutGiftNode,  self.PutGiftCfg = self:GetNodeInfoByType(ActivityData, ActivityNodeType.ActivityNodeTypeStarDayPutGift)
	if self.PutGiftNode == nil or self.PutGiftCfg == nil then
		return
	end

	local StarPutGift = self.PutGiftNode.Extra.StarPutGift or {}
	local PutGiftNum = StarPutGift.Gifts and #StarPutGift.Gifts or 0

	self.DetailDesc = self.PutGiftCfg.NodeDesc
	self.ButtonText = LSTR(1700007)
	self.ProgressDesc = string.format("%s%d/%d", LSTR(1700006), PutGiftNum, self.PutGiftCfg.Target)
	self.BtnEnabled = PutGiftNum < self.PutGiftCfg.Target
	self.PutGiftButtonSelelcted = true
	self.GetGiftButtonSelelcted = false

	self.PutGiftTabColor = "#fff5cb"
	self.GetGiftTabColor = "#313131"
end

function NightGiftPrepareExchangeVM:SetNormalInfo(ActivityData)
	self.TitleText = LSTR(1700001)
	self.PrepareDesc = LSTR(1700004)
	self.ExchangeDesc = self:GetGiftStartTime(ActivityData)
	self.GetGiftLockVisible = true
	self.PutGiftLockVisible = false
	self.PutGiftButtonText = LSTR(1700002)
	self.GetGiftButtonText = LSTR(1700003)
end

function NightGiftPrepareExchangeVM:StartGetGift()
	self.GetGiftLockVisible = false
end


function NightGiftPrepareExchangeVM:ShowGetGift(ActivityData)
	self.PutGiftNode,  self.PutGiftCfg = self:GetNodeInfoByType(ActivityData, ActivityNodeType.ActivityNodeTypeStarDayPutGift)
	if self.PutGiftNode == nil or self.PutGiftCfg == nil then
		return
	end
	local StarPutGift = self.PutGiftNode.Extra.StarPutGift or {}
	local PutGiftNum = StarPutGift.Gifts and #StarPutGift.Gifts or 0

	self.GetGiftNode, self.GetGiftCfg = self:GetNodeInfoByType(ActivityData, ActivityNodeType.ActivityNodeTypeStarDayGetGift)
	if self.GetGiftNode == nil or self.GetGiftCfg == nil then
		return
	end
	local StarGift = self.GetGiftNode.Extra.StarGift or {}
	local GetGiftNum = StarGift.Gifts and #StarGift.Gifts or 0

	self.DetailDesc = self.GetGiftCfg.NodeDesc
	self.ButtonText = LSTR(1700010)
	self.ProgressDesc = string.format("%s:%d", LSTR(1700050), PutGiftNum - GetGiftNum)
	self.BtnEnabled = PutGiftNum > GetGiftNum

	self.PutGiftButtonSelelcted = false
	self.GetGiftButtonSelelcted = true

	self.PutGiftTabColor = "#313131"
	self.GetGiftTabColor = "#fff5cb"
end

function NightGiftPrepareExchangeVM:GetGiftStartTime(ActivityData)
	local GetGiftNode, GetGiftCfg = self:GetNodeInfoByType(ActivityData, ActivityNodeType.ActivityNodeTypeStarDayGetGift)
	if GetGiftNode == nil or GetGiftCfg == nil then
		return 0
	end
	local ActivityTime = _G.OpsActivityMgr:GetActivityTime(ActivityData.Activity)
	local StartTime = GetGiftCfg.StartTime
	if StartTime == nil then
		return 0
	end
	
    return _G.OpsActivityMgr:GetTimeStampByTimeStr(GetGiftCfg.StartTime, ActivityTime.TimeZoneOffset)
end

function NightGiftPrepareExchangeVM:GetNodeInfoByType(ActivityData, Type)
	local NodeList = ActivityData:GetNodesByNodeType(Type)
    if NodeList then
		local Node = NodeList[1]
		if Node == nil then
			return
		end
		local NodeID  = Node.Head.NodeID
		return Node, ActivityNodeCfg:FindCfgByKey(NodeID)
    end

	return
end

--要返回当前类
return NightGiftPrepareExchangeVM