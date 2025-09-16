--
-- Author: haialexzhou
-- Date: 2021-9-16
-- Description:动态数据
--
local ProtoCommon = require("Protocol/ProtoCommon")
local LuaClass = require("Core/LuaClass")
local EffectUtil = require("Utils/EffectUtil")

---@class DynDataBase
local DynDataBase = LuaClass()

function DynDataBase:Ctor()
    self.ID = 0
    self.State = 0
    self.Location = nil
    self.Rotator = nil
    self.Scale = nil
    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_NONE
    self.EffectInstID = -1
    self.DisappearEffectInstID = -1
end

function DynDataBase:Destroy()
    self:BreakAllEffect()
end

function DynDataBase:UpdateState(NewState)
    self.State = NewState
end


function DynDataBase:PlayEffect(VfxParameter)
    if (VfxParameter == nil or VfxParameter.VfxRequireData == nil) then
        return -1
    end
    local EffectPath = VfxParameter.VfxRequireData.EffectPath
    if (EffectPath == nil or EffectPath == "") then
        return -1
    end
    return EffectUtil.PlayVfx(VfxParameter)
end


function DynDataBase:BreakAllEffect()
    local function LocalBreakEffect(InEffectInstID)
        if (InEffectInstID == nil or InEffectInstID <= 0) then
            return
        end
        EffectUtil.StopVfx(InEffectInstID)
    end

    LocalBreakEffect(self.EffectInstID)
    LocalBreakEffect(self.DisappearEffectInstID)
    self.EffectInstID = -1
    self.DisappearEffectInstID = -1
end

--需要获取最新值，不能异步缓存
function DynDataBase:GetWorldOriginLocation()
    return _G.PWorldMgr:GetWorldOriginLocation()
end

return DynDataBase