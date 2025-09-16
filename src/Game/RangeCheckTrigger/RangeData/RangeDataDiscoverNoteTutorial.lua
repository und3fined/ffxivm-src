--
-- Author: Alex
-- Date: 2025-02-19 15:53
-- Description:范围检测数据
-- 进入视野后控制特效才有意义 所以EntityID不为nil
--


local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local DiscoverNoteDefine = require("Game/SightSeeingLog/DiscoverNoteDefine")
local RangeDataBase = require("Game/RangeCheckTrigger/RangeData/RangeDataBase")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

---@class RangeDataDiscoverNoteTutorial
local RangeDataDiscoverNoteTutorial = LuaClass(RangeDataBase)

---Ctor
function RangeDataDiscoverNoteTutorial:Ctor()
  
end

--- 处理相关进入范围逻辑
function RangeDataDiscoverNoteTutorial:OnEnterTheRange()
    _G.DiscoverNoteMgr:NotifyTriggerTheTutorial()
end

--- 处理相关离开范围逻辑
function RangeDataDiscoverNoteTutorial:OnExitTheRange()

end

------ 必须实现 ------
--- 获取所属功能类型
function RangeDataDiscoverNoteTutorial:OnGetGamePlayType()
    return TriggerGamePlayType.DiscoverNoteTutorial
end

function RangeDataDiscoverNoteTutorial:GetLocation()
    local EntityID = self.EntityID
    if EntityID then
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if Actor then
            return Actor:FGetActorLocation()
        end
    end
end

--- 获取具体的胶囊体触发器数据
function RangeDataDiscoverNoteTutorial:OnGetCylinderTriggerParams()
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

    
    local Range = DiscoverNoteDefine.TutorialTriggerRange
    if Range then
        Cylinder.Radius = Range
    end

    return Cylinder
end

return RangeDataDiscoverNoteTutorial