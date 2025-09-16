local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FateItemSubmitVM = require("Game/Fate/VM/FateItemSubmitVM")
local FateStageInfoVM = require("Game/Fate/VM/FateStageInfoVM")
local FateVM = LuaClass(UIViewModel)

function FateVM:Ctor()
end

function FateVM:OnInit()
    self.StageInfoVM = FateStageInfoVM.New()
    self.FateItemSubmitVM = FateItemSubmitVM.New()
end

function FateVM:OnBegin()
    self.FateItemSubmitVM:OnBegin()
end

function FateVM:SetStageInfo(Value)
    if (self.StageInfoVM == nil) then
        self.StageInfoVM = FateStageInfoVM.New()
    end

    self.StageInfoVM:UpdateVM(Value)
end

function FateVM:GetStageInfo()
    return self.StageInfoVM
end

function FateVM:ShowItemSubmitView(InFateState, InTargetActionList, InNpcDialogCfg, FateCfg, NPCEntityID)
    if (self.FateItemSubmitVM == nil) then
        self.FateItemSubmitVM = FateItemSubmitVM.New()
    end

    self.FateItemSubmitVM:ShowItemSubmitView(InFateState, InTargetActionList, InNpcDialogCfg, FateCfg, NPCEntityID)
end

return FateVM
