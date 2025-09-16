local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ActivityCfg = require("TableCfg/ActivityCfg")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local TimeZoneOffset = ProtoRes.Game.TimeZoneOffset
---@class OpsCommTabChildItemVM : UIViewModel
local OpsCommTabChildItemVM = LuaClass(UIViewModel)

--用于存储具体活动的所有数据
--单个活动的方法和数据可以写道这里哈，比如获取获得时间，活动奖励，等等
function OpsCommTabChildItemVM:Ctor()
	--self.Activity = nil -- 活动表格数据
	--self.ActivityID = nil
	--self.ParentVM = nil
	--self.NodeList = nil
	--self.Effected = nil
	--self.PageName = nil

	self.HotVisible = nil
	self.HourglassVisible = nil
end

--@ Value = {Activityfg, ActivityDetail}
function OpsCommTabChildItemVM:UpdateVM(Value, Parent)
	if Value == nil or Value.Activity == nil then
		return
	end

	local Activity = Value.Activity
	self.Activity = Activity
	self.ActivityID = Activity.ActivityID
	self.ParentVM = Parent
	self.NodeList = Value.Detail.NodeList -- 活动节点信息（存储服务器下方的节点数据）
	self.Effected = Value.Detail.Effected -- 活动是否有效
	self.PageName = Activity.PageName
	self.PageNameColor = "#d5d5d5"
	if self.Activity.BPName == "Ops/OpsActivity/OpsActivityTreasureChestPanel_UIBP" then
		self:UpdateTreasureChestRedDot(Activity,self.NodeList)
	end

	if self.Activity.ActivityType == ProtoRes.Game.ActivityType.ActivityTypePandora then
		self.AppId = self.Activity.Title
		self.OpenArgs = self.Activity.SubTitle
	else
		self.AppId = nil
		self.OpenArgs = nil
	end

	self.HotVisible = Activity.PageTag == OpsActivityDefine.ActivityPageTag.ActivityPageTagHot
	self.HourglassVisible = Activity.PageTag == OpsActivityDefine.ActivityPageTag.ActivityPageTagTimeLimit
end

function OpsCommTabChildItemVM:GetBPName()
	return self.Activity.BPName
end

function OpsCommTabChildItemVM:GetBGPicPath()
	return self.Activity.Icon
end

function OpsCommTabChildItemVM:GetKey()
	return self.ActivityID
end

function OpsCommTabChildItemVM:GetFirstActivityID()
	return self.ActivityID
end

function OpsCommTabChildItemVM:GetClasscifyID()
	local Cfg = ActivityCfg:FindCfgByKey(self.ActivityID)
	return Cfg.ClassifyID
end

----------------------------节点获取相关

function OpsCommTabChildItemVM:GetNodesByNodeType(NodeType)
	local TypeNodeList = {}
	if self.NodeList then
		for _, Node in ipairs(self.NodeList) do
			local NodeID  = Node.Head.NodeID
			local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
			if ActivityNode and ActivityNode.NodeType == NodeType then
				table.insert(TypeNodeList, Node)
			end
		end
	end
	return TypeNodeList
end


--------------------活动时间相关-----------------------
---
function OpsCommTabChildItemVM:GetActivityTimeDisplay()
	return self.Activity.TimeDisplay
end

--活动结束时间戳
function OpsCommTabChildItemVM:GetActivityTimeCountdown()
	local ActivityTime = self:GetActivityTime()
	if ActivityTime == nil then
		return 0
	end
	
	local EndTime = ActivityTime.EndTime
	local ZoneOffset = ActivityTime.TimeZoneOffset - TimeZoneOffset.TimeZoneOffset0

	local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
	
	local TimeTable = self:GetDataTable(EndTime)
	local EndServeTime = os.time(TimeTable) + (ZoneOffset - ServerZone) * 3600
	
	return EndServeTime
end

--活动完整时间显示
function OpsCommTabChildItemVM:GetActivityCompleteTime()
	local ActivityTime = self:GetActivityTime()
	if ActivityTime == nil then
		return ""
	end

	local StartTimeTable =self:GetDataTable(ActivityTime.StartTime)
	local EndTimeTable = self:GetDataTable(ActivityTime.EndTime)

	local StartDate = os.date("%Y/%m/%d", os.time(StartTimeTable))
	local EndDate = os.date("%Y/%m/%d", os.time(EndTimeTable))
	local ZoneOffset = ActivityTime.TimeZoneOffset - TimeZoneOffset.TimeZoneOffset0
	return _G.StringTools.Format("%s - %s(UTC%+d)", StartDate, EndDate, ZoneOffset)
end

--指定输入时间显示
function OpsCommTabChildItemVM:GetActivityAppointTime()
	local ActivityTime = self:GetActivityTime()
	if ActivityTime == nil then
		return ""
	end

	
	local StartTimeTable =self:GetDataTable(ActivityTime.StartTime)
	local TimeZoneOffset = ActivityTime.TimeZoneOffset - TimeZoneOffset.TimeZoneOffset0
	local StartDate = os.date("%Y/%m/%d %H:%M", os.time(StartTimeTable))
	return _G.StringTools.Format(_G.LSTR(970004), StartDate, TimeZoneOffset)
end

function OpsCommTabChildItemVM:GetDataTable(TimeText)
	local year, month, day, hour, min, sec = TimeText:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	return {year = year, month = month, day = day, hour = hour, min = min, sec = sec}
end

--得到活动时间数据 TODO 备注：服务器还没有开发大区id。目前统一全部返回china时间
function OpsCommTabChildItemVM:GetActivityTime()
	if self.Activity  == nil then
		return
	end
	return self.Activity.ChinaActivityTime

	--[[local WorldID = _G.LoginMgr:GetWorldID()
	local ZoneIDs = self.Activity.ChinaActivityTime.ZoneIDs
	if ZoneIDs then
		for i = 1, #ZoneIDs do
			if WorldID == ZoneIDs[i] then
				return self.Activity.ChinaActivityTime
			end
		end
	end

	ZoneIDs = self.Activity.InternationActivityTime.ZoneIDs
	if ZoneIDs then
		for i = 1, #ZoneIDs do
			if WorldID == ZoneIDs[i] then
				return self.Activity.InternationActivityTime
			end
		end
	end]]--
end

--------------活动说明
-----得到活动时间数据 TODO 备注：服务器还没有开发大区id。目前统一全部返回china活动说明
function OpsCommTabChildItemVM:GetActivityHelpInfo()
	if self.Activity  == nil then
		return
	end
	return self.Activity.ChinaActivityHelpInfoID

	--[[local WorldID = _G.LoginMgr:GetWorldID()
	local ZoneIDs = self.Activity.ChinaActivityTime.ZoneIDs
	if ZoneIDs then
		for i = 1, #ZoneIDs do
			if WorldID == ZoneIDs[i] then
				return self.Activity.ChinaActivityHelpInfoID
			end
		end
	end

	ZoneIDs = self.Activity.InternationActivityTime.ZoneIDs
	if ZoneIDs then
		for i = 1, #ZoneIDs do
			if WorldID == ZoneIDs[i] then
				return self.Activity.InternationActivityHelpInfoID
			end
		end
	end]]--
end



--珍品宝箱红点
function OpsCommTabChildItemVM:UpdateTreasureChestRedDot(Cfg, Nodes)
	if Cfg == nil or Nodes == nil then
		return
	end
	for _, Node in ipairs(Nodes) do
		local Extra = Node.Extra
		local Head = Node.Head
		if Extra and Head and Extra.Lottery then
			local DrawNum = Extra.Lottery.DrawNum
			local DropedResID =  Extra.Lottery.DropedResID
			local NodeCfg = require("TableCfg/ActivityNodeCfg")
			local LotteryNode = NodeCfg:FindCfgByKey(Head.NodeID)
			if DrawNum == nil or LotteryNode == nil then
				return
			end
			local CommercializationRandConsumeCfg = require("TableCfg/CommercializationRandConsumeCfg")
			local CommercializationRandCfg = require("TableCfg/CommercializationRandCfg")
			local LotteryCousumeNode = CommercializationRandConsumeCfg:FindCfg("PoolID = "..LotteryNode.Params[1])
			local LotteryAwardNode = CommercializationRandCfg:FindAllCfg("PrizePoolID = "..LotteryNode.Params[1])
			if LotteryCousumeNode and LotteryAwardNode then
				local LotteryPropNum = _G.BagMgr:GetItemNum(LotteryCousumeNode.ConsumeResID)
				-- 当前拥有抽奖币大于下抽所需抽奖币有红点
				if DrawNum < #LotteryCousumeNode.ConsumeResNum and LotteryPropNum >= LotteryCousumeNode.ConsumeResNum[DrawNum + 1] then
					RedDotMgr:AddRedDotByName(OpsActivityMgr:GetRedDotName(Cfg.ClassifyID, Cfg.ActivityID))
				else
					RedDotMgr:DelRedDotByName(OpsActivityMgr:GetRedDotName(Cfg.ClassifyID, Cfg.ActivityID))
				end
				-- 大奖未抽出，活动结束倒数三天有每日红点
				table.sort(LotteryAwardNode, function(node1,node2)
					return node1.DropWeight < node2.DropWeight
				end)
				local FinalAwardDropResID = LotteryAwardNode[1].ID
				local IsDrawedFinalAward = false
				for _, ResID in ipairs(DropedResID) do
					if ResID == FinalAwardDropResID then
						IsDrawedFinalAward = true
						break
					end
				end
				if not IsDrawedFinalAward and self:IsActivityLastThreeDays()  then
					if OpsActivityMgr:DailyRedDot(Cfg) then
						RedDotMgr:AddRedDotByName(OpsActivityMgr:GetRedDotName(Cfg.ClassifyID, Cfg.ActivityID, "Daily"))
					end
				else
					RedDotMgr:DelRedDotByName(OpsActivityMgr:GetRedDotName(Cfg.ClassifyID, Cfg.ActivityID, "Daily"))
				end
			end
			break
		end
	end
end

function OpsCommTabChildItemVM:IsActivityLastThreeDays()
	local ActivityTime = self:GetActivityTime()
	if ActivityTime == nil then
		return false
	end
	local EndTimeStamp = os.time(self:GetDataTable(ActivityTime.EndTime))
	local three_days_in_seconds = 3 * 24 * 60 * 60
	local CurrentTimeStamp = TimeUtil:GetServerLogicTime()
	if CurrentTimeStamp >= EndTimeStamp - three_days_in_seconds and CurrentTimeStamp <= EndTimeStamp then
		return true
	else
		return false
	end
end

function OpsCommTabChildItemVM:IsEqualVM(Value)
    return Value ~= nil and self.ActivityID ~= nil and self.ActivityID == Value.Activity.ActivityID
end

function OpsCommTabChildItemVM:AdapterOnGetCanBeSelected()
	return true
end

function OpsCommTabChildItemVM:AdapterOnGetWidgetIndex()
	return 1
end

function OpsCommTabChildItemVM:AdapterOnGetIsCanExpand()
	return false
end

function OpsCommTabChildItemVM:AdapterOnGetChildren()
end

function OpsCommTabChildItemVM:AdapterOnExpansionChanged(IsExpanded)
end


--要返回当前类
return OpsCommTabChildItemVM