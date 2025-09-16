--
-- Author: Alex
-- Date: 2025-02-18
-- Description:动态创建范围判断Trigger
--

local LuaClass = require("Core/LuaClass")
local DynDataTriggerBase = require("Game/PWorld/DynData/DynDataTriggerBase")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType

---@class DynDataTriggerRangeCheck
local DynDataTriggerRangeCheck = LuaClass(DynDataTriggerBase, true)

function DynDataTriggerRangeCheck:Ctor()
    self.GamePlayType = TriggerGamePlayType.None
    self.Owner = nil
    self.OverlapBeginCallBack = nil
    self.OverlapEndCallBack = nil
end

--- 初始化基础标识信息，用于Overlap事件中传递
function DynDataTriggerRangeCheck:InitBaseInfo(Owner, GamePlayType)
    if not Owner then
        return
    end
    self.Owner = Owner
    self.GamePlayType = GamePlayType
end

---  设定触发器进出回调
---@param BeginCallBack function@进入范围回调
---@param EndCallBack function@离开范围回调
function DynDataTriggerRangeCheck:SetTheOverlapCallBack(BeginCallBack, EndCallBack)
    self.OverlapBeginCallBack = BeginCallBack
    self.OverlapEndCallBack = EndCallBack
    if BeginCallBack and EndCallBack then
        self:UpdateState(1)
    end
end

function DynDataTriggerRangeCheck:OnTriggerBeginOverlap(Trigger, Target)
    if (not self:IsNeedTrigger(Trigger, Target)) then
        return
    end

    if not self:IsNeedTriggerExtra(Target) then
        return
    end
    
    local Owner = self.Owner
    local BeginCallBack = self.OverlapBeginCallBack
    if not Owner or not BeginCallBack then
        return
    end

    BeginCallBack(Owner)
end

function DynDataTriggerRangeCheck:OnTriggerEndOverlap(Trigger, Target)
    self.bIsTriggering = false
    if (not self:IsNeedTrigger(Trigger, Target, true)) then
        return
    end

    if not self:IsNeedTriggerExtra(Target) then
        return
    end

    local Owner = self.Owner
    local EndCallBack = self.OverlapEndCallBack
    if not Owner or not EndCallBack then
        return
    end

    EndCallBack(Owner)
end

--- 功能用于代替计算范围检测，只支持主角的碰撞判断
function DynDataTriggerRangeCheck:IsNeedTriggerExtra(Target)
    local GamePlayType = self.GamePlayType
    if not GamePlayType or GamePlayType == TriggerGamePlayType.None then
        return false
    end
    
    local TargetEntityID = ActorUtil.GetActorEntityID(Target)
    if not TargetEntityID then
        return false
    end

    return MajorUtil.IsMajor(TargetEntityID)
end

return DynDataTriggerRangeCheck