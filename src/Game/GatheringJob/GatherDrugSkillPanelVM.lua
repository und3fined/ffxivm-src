local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local BindableVector2D = require("UI/BindableObject/BindableVector2D")

---@class GatherDrugSkillPanelVM : UIViewModel
local GatherDrugSkillPanelVM = LuaClass(UIViewModel)

function GatherDrugSkillPanelVM:Ctor()
    self.IsInHandleMode = SettingsHandleDefine.HandleModeType.Off
	self.CurInputAction = nil
    self.CurPosition = BindableVector2D.New()
end

function GatherDrugSkillPanelVM:OnInit()

end

function GatherDrugSkillPanelVM:OnBegin()
end

function GatherDrugSkillPanelVM:OnEnd()
end

function GatherDrugSkillPanelVM:OnShutdown()
end

function GatherDrugSkillPanelVM:SetCurPosition(Param)
    self.CurPosition:SetValue(Param.X, Param.Y)
end

function GatherDrugSkillPanelVM:UpdateSkillDrugPosition()
    self.IsInHandleMode = _G.SkillHandleMgr:IsInHandleMode()
	self.CurInputAction = _G.SkillHandleMgr.FunctionSkillInputAction
end

return GatherDrugSkillPanelVM