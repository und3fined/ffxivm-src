---
--- Author: henghaoli
--- DateTime: 2025-05-23 14:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local MainControlPanelVM = require("Game/Main/VM/MainControlPanelVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class SkillHandleStateRSView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillHandleStateRSView = LuaClass(UIView, true)

function SkillHandleStateRSView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillHandleStateRSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillHandleStateRSView:OnInit()

end

function SkillHandleStateRSView:OnDestroy()

end

function SkillHandleStateRSView:OnShow()

end

function SkillHandleStateRSView:OnHide()

end

function SkillHandleStateRSView:OnRegisterUIEvent()
	--UIUtil.AddOnReleasedEvent(self, self.ImgBg, self.OnSwitchSkillClick)
end

function SkillHandleStateRSView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.GamePadSwitchSkillPanel, self.OnGamePadSwitchSkillPanel)
end

function SkillHandleStateRSView:OnRegisterBinder()

end

function SkillHandleStateRSView:OnSwitchSkillClick()
	_G.EventMgr:SendEvent(EventID.SwitchPeacePanel)
end

function SkillHandleStateRSView:OnGamePadSwitchSkillPanel()
	if MainControlPanelVM:AllowHandleSkill(false, true) then
		local TipsID = MainControlPanelVM:GetBtnSwitchTips()
		if TipsID > 0 then
			MsgTipsUtil.ShowTipsByID(TipsID)
			return
		end
		_G.EventMgr:SendEvent(EventID.SwitchPeacePanel)
	end
end

return SkillHandleStateRSView