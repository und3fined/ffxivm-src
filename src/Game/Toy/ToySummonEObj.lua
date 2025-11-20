-- Author: MichaelYang_LightPaw
-- Date: 2025-07-28 20:45
-- Description:玩具-怪物眼镜，客户端表现，怪物都会变成同一个指定模型，怪物在进入战斗或者玩具时间到，变回原模型
--

local LuaClass = require("Core/LuaClass")
local ToyBase = require("Game/Toy/ToyBase")
local ActorUtil = require("Utils/ActorUtil")
local ProtoRes = require("Protocol/ProtoRes")

local FLOG_ERROR = _G.FLOG_ERROR

---@class GoldGameNewBase
local ToySummonEObj = LuaClass(ToyBase)

function ToySummonEObj:Ctor()
end

-- 子类继承函数 --
function ToySummonEObj:OnInit(InToyID)
    if (self.ToyCfg == nil) then
        FLOG_ERROR("OnInit 失败，ToyCfg 为空")
        return false
    end

    if(self.ToyCfg.ParamInt == nil or self.ToyCfg.ParamInt[1] == nil) then
        FLOG_ERROR("Onint 失败， ParamInt参数无效")
        return false
    end
    self.ToyType = ProtoRes.ToyType.ToyTypeSceneObj
    return true
end

function ToySummonEObj:OnToyBegin(InSceneID)
    if (self.ToyCfg == nil) then
        return
    end

    _G.FLOG_INFO("场景的ObjID : %s", InSceneID)
end

function ToySummonEObj:OnToyExit()

end

-- END --

return ToySummonEObj