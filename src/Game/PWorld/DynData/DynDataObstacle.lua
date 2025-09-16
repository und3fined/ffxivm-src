--
-- Author: haialexzhou
-- Date: 2021-9-16
-- Description:动态阻挡
--
local ProtoCommon = require("Protocol/ProtoCommon")
local LuaClass = require("Core/LuaClass")
local DynDataBase = require("Game/PWorld/DynData/DynDataBase")
local EffectUtil = require("Utils/EffectUtil")
---@class DynDataObstacle
local DynDataObstacle = LuaClass(DynDataBase, true)

function DynDataObstacle:Ctor()
    self.bIsLoading = false
    self.ModelPath = nil
    self.ModelBaseSize = nil
    self.ObstacleActorList = {}
    self.bIsHideEffect = false
    self.EffectBaseSize = nil
    self.DisappearEffectPath = nil
    self.EffectPath = nil
    self.TimerHandle = nil
    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_OBSTACLE
end

function DynDataObstacle:ClearTimer()
    if (self.TimerHandle ~= nil and self.TimerHandle ~= 0) then
		_G.TimerMgr:CancelTimer(self.TimerHandle)
		self.TimerHandle = nil
	end
end

function DynDataObstacle:Destroy()
    self.Super:Destroy()
    self:ClearTimer()
    self:DestroyAllObstacle()
end

function DynDataObstacle:UpdateState(NewState)
    self.Super:UpdateState(NewState)
    
    if (self.State == 0) then
        self:DestroyAllObstacle()
        if (self.DisappearEffectPath == nil or self.DisappearEffectPath == "") then
            self:BreakAllEffect()
        else
            if (self.EffectInstID > 0) then
                EffectUtil.StopVfx(self.EffectInstID)
                self.EffectInstID = -1
                self:Disappear()
            end

            if (self.TimerHandle == nil or self.TimerHandle == 0) then
                self.TimerHandle = _G.TimerMgr:AddTimer(nil, function()
                    self:BreakAllEffect()
                end, 2)
            end
        end

    elseif (self.State == 1) then
        self:ClearTimer()
        self:Show()

    elseif (self.State == 2) then
        self:DestroyAllObstacle()
    end
end


function DynDataObstacle:Show()

end

function DynDataObstacle:Disappear()

end

function DynDataObstacle:DestroyAllObstacle()
    for _, ObstacleActor in ipairs(self.ObstacleActorList) do
        _G.CommonUtil.DestroyActor(ObstacleActor)
    end
    self.ObstacleActorList = {}
end


return DynDataObstacle