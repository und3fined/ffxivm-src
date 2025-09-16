
local ProtoCommon = require("Protocol/ProtoCommon")
local LuaClass = require("Core/LuaClass")
local DynDataBase = require("Game/PWorld/DynData/DynDataBase")
---@class DynDataMapSequence
local DynDataMapSequence = LuaClass(DynDataBase, true)

function DynDataMapSequence:Ctor()
    self.MapSequenceController = nil
    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_MAP_SEQUENCE
end

function DynDataMapSequence:Destroy()
    self.Super:Destroy()

    if (self.MapSequenceController ~= nil) then
        self.MapSequenceControllerRef = nil
        self.MapSequenceController = nil
    end
end

function DynDataMapSequence:CreateSequenceController(World)
    self.MapSequenceController = _G.NewObject(_G.UE.UMapSequenceController, World)
    self.MapSequenceControllerRef = UnLua.Ref(self.MapSequenceController)
end

function DynDataMapSequence:UpdateState(NewState)
    self.Super:UpdateState(NewState)
    --暂时不处理autoplay的sequence，不能被打断
    if (self.MapSequenceController ~= nil and _G.CommonUtil.IsObjectValid(self.MapSequenceController)) then
        self.MapSequenceController:UpdateState(self.State)
    end
end

function DynDataMapSequence:ReadyToPlay()
    if (self.MapSequenceController ~= nil) then
        self.MapSequenceController:OnReadyToPlay()
    end
end

return DynDataMapSequence