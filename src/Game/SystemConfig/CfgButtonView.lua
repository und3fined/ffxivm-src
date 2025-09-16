---
--- Author: chaooren
--- DateTime: 2021-10-22 19:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CfgButtonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CfgBtn UFButton
---@field StateImage UImage
---@field StateText UTextBlock
---@field SwitchText UTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CfgButtonView = LuaClass(UIView, true)

function CfgButtonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CfgBtn = nil
	--self.StateImage = nil
	--self.StateText = nil
	--self.SwitchText = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CfgButtonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CfgButtonView:OnInit()
	self.CurValue = nil
	self.bSwicthBtn = nil
	self.ButtonClicked = nil
	self.SaveKey = nil
end

function CfgButtonView:OnDestroy()

end

function CfgButtonView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	self.bSwicthBtn = Params.IsSwitch or false
	self.CurValue = Params.DefaultState or false
	self.SaveKey = Params.SaveKey
	if self.bSwicthBtn == true then
		UIUtil.SetIsVisible(self.StateImage, true)
		UIUtil.SetIsVisible(self.StateText, true)
		self:SwitchState(self.CurValue)
	else
		UIUtil.SetIsVisible(self.StateImage, false)
		UIUtil.SetIsVisible(self.StateText, false)
	end

	self:BindButtonClicked(Params.Callback)
	self.SwitchText:SetText(Params.Desc or "null")
end

function CfgButtonView:OnHide()

end

function CfgButtonView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CfgBtn, self.OnButtonClick)
end

function CfgButtonView:OnRegisterGameEvent()

end

function CfgButtonView:OnRegisterBinder()

end

function CfgButtonView:OnButtonClick()
	self:SwitchState(not self.CurValue)
	if self.ButtonClicked ~= nil then
		local CallBack = self.ButtonClicked
		local ButtonState = self:GetButtonState()
		CallBack(ButtonState)
		self:SaveData(ButtonState)
	end
end

function CfgButtonView:BindButtonClicked(Func)
	self.ButtonClicked = Func
end

--user for switch btn
function CfgButtonView:GetButtonState()
	return self.CurValue or false
end

function CfgButtonView:SwitchState(State)
	if State == true then
		self.StateText:SetText(LSTR("开"))
		self.CurValue = true
	else
		self.StateText:SetText(LSTR("关"))
		self.CurValue = false
	end
end

function CfgButtonView:SaveData(Data)
	if self.SaveKey then
		_G.UE.USaveMgr.SetInt(self.SaveKey, Data and 1 or 0, false)
	end
end

return CfgButtonView