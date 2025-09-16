local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local YellCfg = require("TableCfg/YellCfg")
local YellGroupCfg = require("TableCfg/YellGroupCfg")
local NpcCfg = require("TableCfg/NpcCfg")
local LSTR = _G.LSTR
---@class SpeechBubbleGroup
local SpeechBubbleGroup = LuaClass()

function SpeechBubbleGroup:Ctor()
    self.BubbleInfoList = {}
    self.IsPlaying = false
    self.TimerList = {}
    self.FirstEntityIDs = {}
    self.GroupType = ProtoRes.bubble_type.BUBBLE_TYPE_SINGLE
    self.LoopNum = 1
    self.DisplayMode = 1
    self.ActorEntityID = nil
    self.GroupID = nil
    self.ContantsNPC = {}
end

function SpeechBubbleGroup:InsertID(Order, BubbleID, EntityID)
    self.BubbleInfoList = self.BubbleInfoList or {}
    table.insert(self.BubbleInfoList, BubbleID)
    self.ContantsNPC[EntityID] = 1
    self.ActorEntityID = EntityID
    local Yell = YellCfg:FindCfgByKey(BubbleID)
    --记录气泡组第一个EntityID和气泡类型
    if (Order == 1) then
        if Yell then
            self.GroupType = Yell["OutputType"]
        end
        self:AddFirstEntityID(EntityID)
    end
end

function SpeechBubbleGroup:OnGroupLoop()
    self.LoopNum = self.LoopNum - 1
    --如果显示模式为权重，则需要重新随机ID
    if self.DisplayMode == 2 then
        self.BubbleInfoList = {}
        local YellIDlist = YellGroupCfg:FindAllIDsByGroupID(self.GroupID)
        for Index = 1, #YellIDlist do
            local NewBubbleID = YellIDlist[Index]["YellID"]
            table.insert(self.BubbleInfoList, NewBubbleID)
        end
    end
end

function SpeechBubbleGroup:CanGroupLoop()
    return self.LoopNum <= 0 or self.LoopNum >= 2
end

function SpeechBubbleGroup:SetGroupLoopNum(LoopNum)
    self.LoopNum = LoopNum
end

function SpeechBubbleGroup:SetGroupDisplayMode(Mode)
    self.DisplayMode = Mode
end

function SpeechBubbleGroup:EraseID(Index)
    self.BubbleInfoList[Index] = nil
end

function SpeechBubbleGroup:GetIDAt(Index)
    return self.BubbleInfoList[Index]
end

function SpeechBubbleGroup:GetSize()
    return #self.BubbleInfoList
end

function SpeechBubbleGroup:GetTimerList()
    return self.TimerList
end

function SpeechBubbleGroup:AddFirstEntityID(InEntityID)
    self.FirstEntityIDs[#self.FirstEntityIDs + 1] = InEntityID
end

function SpeechBubbleGroup:AddTimer(InTimer)
    self.TimerList[#self.TimerList + 1] = InTimer
end

function SpeechBubbleGroup:RemoveTimer(InTimer)
    for Index, Value in ipairs(self.TimerList) do
        if Value == InTimer then
            table.remove(self.TimerList, Index)
            return
        end
    end
end

function SpeechBubbleGroup:PlayReset()
    self.IsPlaying = false
    self.TimerList = {}
end

function SpeechBubbleGroup:ValidateIDList()
    -- Validate by checking whether the group is successive (no nils in-between)
    for Index = 1, self:GetSize() do
        if (self:GetIDAt(Index) == nil) then
            return false
        end
    end

    return true
end

function SpeechBubbleGroup:ValidateType(bTask)
    if bTask == true and self.GroupType == ProtoRes.bubble_type.BUBBLE_TYPE_TASK then
        return true
    end
    return self.GroupType ~= ProtoRes.bubble_type.BUBBLE_TYPE_TASK
end

return SpeechBubbleGroup