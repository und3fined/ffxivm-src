---
--- Author: kanohchen
--- DateTime: 2025-07-29 09:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local EventID = require("Define/EventID")

---@class SkillHandleCloseBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelClose UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillHandleCloseBtnView = LuaClass(UIView, true)

function SkillHandleCloseBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelClose = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillHandleCloseBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillHandleCloseBtnView:OnInit()
	self.CurHandleActionID = nil
end

function SkillHandleCloseBtnView:OnDestroy()

end

function SkillHandleCloseBtnView:OnShow()
	self:OnInputActionTypeChange()
end

function SkillHandleCloseBtnView:OnHide()
	_G.SettingsHandleMgr:UnRegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.SpeedSkill)
end

function SkillHandleCloseBtnView:OnRegisterUIEvent()

end

function SkillHandleCloseBtnView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.GamePadClose, self.OnGamePadClose)
	self:RegisterGameEvent(EventID.InputActionTypeChange, self.OnInputActionTypeChange)
end

function SkillHandleCloseBtnView:OnRegisterBinder()

end

function SkillHandleCloseBtnView:OnGamePadClose()
	local BtnSize = UIUtil.GetLocalSize(self)
	if BtnSize then
		local BtnPosition = UIUtil.LocalToAbsolute(self, _G.UE.FVector2D(BtnSize.X/2, BtnSize.Y/2))
		_G.EventMgr:SendEvent(EventID.SimulatedTouchStartClickConfirm, BtnPosition)
		_G.EventMgr:SendEvent(EventID.SimulatedTouchEndClickConfirm, BtnPosition)
	end
end

function SkillHandleCloseBtnView:OnInputActionTypeChange(IsHandleAttached)
    if nil == IsHandleAttached then
		IsHandleAttached = _G.SettingsHandleMgr:GetIsHandleAttached()
	end
    if IsHandleAttached then
		_G.SettingsHandleMgr:RegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.SpeedSkill)
	else
		_G.SettingsHandleMgr:UnRegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.SpeedSkill)
	end
end

return SkillHandleCloseBtnView