local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")

local NightGiftItemVM = require("Game/StarlightCelebration/VM/NightGift/NightGiftItemVM")
local NightGiftSlotVM = require("Game/StarlightCelebration/VM/NightGift/NightGiftSlotVM")

local ItemCfg = require("TableCfg/ItemCfg")
local BagMainVM = require("Game/NewBag/VM/BagMainVM")
local OpsStarlightDefine = require("Game/StarlightCelebration/OpsStarlightDefine")
local BagDefine = require("Game/Bag/BagDefine")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local LSTR = _G.LSTR
---@class StarlightCelebrationMainVM : UIViewModel
local StarlightCelebrationMainVM = LuaClass(UIViewModel)

---Ctor
function StarlightCelebrationMainVM:Ctor()
    self.TitleText = nil
    self.SubTitleText = nil
	self.TaskTitleText = nil
	self.TaskFinishVisible = nil
	self.TextDateText = nil
	self.RhythmGameLockVisible = nil
end

function StarlightCelebrationMainVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    self.TitleText = Activity.Title
    self.SubTitleText = Activity.SubTitle


    local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeCommClientReport)
    if NodeList then
        for _, Node in ipairs(NodeList) do
            local NodeID  = Node.Head.NodeID
		    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                if ActivityNode.NodeTitle == LSTR(1700045) then
					if self:IsStartNode(ActivityData, ActivityNode) then
						self.TextDateText = ""
					else
						self.TextDateText = self:GetNodeStartTimeText(ActivityNode)
					end
				end
            end
	    end
    end

	NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeStatistic)
    if NodeList then
		table.sort(NodeList, function(A, B)
			return A.Head.NodeID < B.Head.NodeID
		end )
        for i = 1, #NodeList do
			local Node = NodeList[i]
            local NodeID  = Node.Head.NodeID
			local Finished = Node.Head.Finished
		    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                if ActivityNode.NodeTitle == LSTR(1700047) then
					if Finished == false then
						self.TaskTitleText = LSTR(1700047)
						self.TaskFinishVisible = false
						break
					end
				elseif ActivityNode.NodeTitle == LSTR(1700048) then
					if Finished == false then
						self.TaskTitleText = LSTR(1700048)
						self.TaskFinishVisible = false
						break
					end
				elseif ActivityNode.NodeTitle == LSTR(1700049) then
					self.TaskTitleText = LSTR(1700049)
					self.TaskFinishVisible = Finished
				end
            end
	    end

		for i = 1, #NodeList do
			local Node = NodeList[i]
            local NodeID  = Node.Head.NodeID
			local Finished = Node.Head.Finished
		    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                if ActivityNode.NodeTitle == LSTR(1700048) then
					self.RhythmGameLockVisible = not Finished
					break
				end
            end
	    end
    end

end

function StarlightCelebrationMainVM:IsStartNode(ActivityData, ActivityNode)
	if ActivityNode == nil then
		return false
	end
	local ActivityTime = _G.OpsActivityMgr:GetActivityTime(ActivityData.Activity)
	if ActivityNode == nil or ActivityNode.StartTime == nil then
		return false
	end
	
    local StartTime = _G.OpsActivityMgr:GetTimeStampByTimeStr(ActivityNode.StartTime, ActivityTime.TimeZoneOffset)
	return StartTime <= TimeUtil.GetServerLogicTime()
end

function StarlightCelebrationMainVM:GetNodeStartTimeText(ActivityNode)
	if ActivityNode == nil then
		return false
	end

	local StartTime = ActivityNode.StartTime
	if StartTime == nil then
		return false
	end
	local year, month, day, hour, min, sec = StartTime:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	
	local TimeTable = {year = year, month = month, day = day, hour = hour, min = min, sec = sec}
    return string.format(LSTR(1700051), os.date("%Y/%m/%d %H:%M:%S", os.time(TimeTable)))
end



--要返回当前类
return StarlightCelebrationMainVM