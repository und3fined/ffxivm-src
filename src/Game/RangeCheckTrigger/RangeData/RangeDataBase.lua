--
-- Author: Alex
-- Date: 2025-02-19 15:53
-- Description:范围检测数据
--

local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local DynDataTriggerRangeCheck = require("Game/PWorld/DynData/DynDataTriggerRangeCheck")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local AuthenticationType = RangeCheckTriggerDefine.AuthenticationType

local FLOG_ERROR = _G.FLOG_ERROR
---@class RangeDataBase
local RangeDataBase = LuaClass()

---Ctor
function RangeDataBase:Ctor()
    self.ListID = nil
    self.EntityID = nil
    self.ResID = nil
    self.CustomID = nil -- 特殊定义ID用于单独区分部分内容
    self.DynTriggerRangeCheck = nil
    self.CurMajorInRange = nil -- 目前主角位置，控制进出事件触发，防止重复触发
end

function RangeDataBase:Destroy()
    local DynTriggerRangeCheck = self.DynTriggerRangeCheck
    if DynTriggerRangeCheck and DynTriggerRangeCheck.Destroy then
        DynTriggerRangeCheck:Destroy()
        if self:OnIsNeedTriggerExitWhenDestroy() then
            self:ExitTheRange() -- 销毁时判定一次退出范围
        end
    end
 
    self.ListID = nil
    self.EntityID = nil
    self.ResID = nil
    self.CustomID = nil 
    self.DynTriggerRangeCheck = nil
end

function RangeDataBase:Init(Params)
    self.EntityID = Params.EntityID
    self.ListID = Params.ListID
    self.ResID = Params.ResID
    self.CustomID = Params.CustomID
    
    local GamePlayType = self:OnGetGamePlayType()
    if not GamePlayType then
        FLOG_ERROR("Need Implement OnGetGamePlayType In ChildClass")
        return
    end

    local Cylinder = self:OnGetCylinderTriggerParams()
    if not Cylinder then
        FLOG_ERROR("Need Implement OnGetCylinderTriggerParams In ChildClass")
        return
    end

    self:InitExtraInfo()

    local DynTriggerRangeCheck = DynDataTriggerRangeCheck.New()
    DynTriggerRangeCheck:InitBaseInfo(self, GamePlayType)
    DynTriggerRangeCheck:SetTheOverlapCallBack(self.EnterTheRange, self.ExitTheRange)
    DynTriggerRangeCheck:CreateCylinderTrigger(Cylinder)
    self.DynTriggerRangeCheck = DynTriggerRangeCheck

    self:OutOfRangeCheckInInit(Cylinder)
end

--- Trigger创建时若目标在范围外不会触发EndOverlap,故需要单独检测一次范围
function RangeDataBase:OutOfRangeCheckInInit(Cylinder)
    local Major = MajorUtil.GetMajor()
	if not Major then
		return
	end
	local MajorPos = Major:FGetActorLocation()
    local Pos = Cylinder.Start
    local Radius = Cylinder.Radius
    if ((MajorPos.X - Pos.X) ^ 2) + ((MajorPos.Y - Pos.Y) ^ 2) > Radius * Radius then
        self:ExitTheRange()
    else
        self:EnterTheRange()
    end
end

--- 处理相关进入范围逻辑
function RangeDataBase:EnterTheRange()
    local CurMajorState = self.CurMajorInRange
    if CurMajorState ~= nil and CurMajorState == true then
        return
    end
    self:OnEnterTheRange()
    self.CurMajorInRange = true
end

--- 处理相关离开范围逻辑
function RangeDataBase:ExitTheRange()
    local CurMajorState = self.CurMajorInRange
    if CurMajorState ~= nil and CurMajorState == false then
        return
    end
    self:OnExitTheRange()
    self.CurMajorInRange = false
end

--- 获取识别ID
function RangeDataBase:GetAuthenID()
    local CustomID = self.CustomID
    if CustomID then
        return CustomID, AuthenticationType.Custom
    else
        local ResID = self.ResID
        local ListID = self.ListID
        if ResID and ListID then
            return ListID, AuthenticationType.Editor -- 跟随地图的生命周期，同张地图内依赖关卡编辑器数据的data ListID 唯一
        else
            return self.EntityID, AuthenticationType.Entity
        end
    end 
end

--- 有实体的Actor直接使用EntityID，无实体的目标使用ResID + ListID，特殊功能使用特殊的确定位置的方法

------ 可选 ------

--- 子类实现可初始化额外的信息供逻辑使用
function RangeDataBase:InitExtraInfo()

end

--- 针对由ResID与ListID决定的范围检测使用获取关卡编辑器位置
function RangeDataBase:GetEActorType()
    
end

function RangeDataBase:GetLocation()
  
end

--- 子类处理相关进入范围逻辑
function RangeDataBase:OnEnterTheRange()
    
end

--- 子类处理相关离开范围逻辑
function RangeDataBase:OnExitTheRange()
    
end

--- 是否在销毁时触发离开范围事件
function RangeDataBase:OnIsNeedTriggerExitWhenDestroy()
    return true
end

------ 必须实现 ------
--- 获取所属功能类型
function RangeDataBase:OnGetGamePlayType()
   
end

--- 获取具体的胶囊体触发器数据
function RangeDataBase:OnGetCylinderTriggerParams()
    
end

return RangeDataBase