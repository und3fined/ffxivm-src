--
-- Author: Alex
-- Date: 2025-03-04 19:15
-- Description:范围检测数据
-- 视野内才会触发引导
--


local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local RangeDataBase = require("Game/RangeCheckTrigger/RangeData/RangeDataBase")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType

---@class RangeDataAetherCurrentTutorial
local RangeDataAetherCurrentTutorial = LuaClass(RangeDataBase)

---Ctor
function RangeDataAetherCurrentTutorial:Ctor()
  
end

--- 处理相关进入范围逻辑
function RangeDataAetherCurrentTutorial:OnEnterTheRange()
    _G.AetherCurrentsMgr:NotifyTriggerTheTutorial()
end

--- 处理相关离开范围逻辑
function RangeDataAetherCurrentTutorial:OnExitTheRange()

end

------ 必须实现 ------
--- 获取所属功能类型
function RangeDataAetherCurrentTutorial:OnGetGamePlayType()
    return TriggerGamePlayType.AetherCurrentTutorial
end

function RangeDataAetherCurrentTutorial:GetLocation()
    local EntityID = self.EntityID
    if EntityID then
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if Actor then
            return Actor:FGetActorLocation()
        end
    end
end

--- 获取具体的胶囊体触发器数据
function RangeDataAetherCurrentTutorial:OnGetCylinderTriggerParams()
    local EntityID = self.EntityID
    if not EntityID then
        return
    end

    local PosInfo = self:GetLocation()
    if not PosInfo then
        return
    end

    local Cylinder = {
        Start = {
            X = PosInfo.X,
            Y = PosInfo.Y,
            Z = PosInfo.Z,
        },
        Radius = 100,
        Height = 10000, -- 默认胶囊体100m
    }

    
    local Range = AetherCurrentDefine.TutorialTriggerRange
    if Range then
        Cylinder.Radius = Range
    end

    return Cylinder
end

return RangeDataAetherCurrentTutorial