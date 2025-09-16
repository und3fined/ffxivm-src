---
--- Author: jamiyang
--- DateTime: 2023-10-09 16:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreateTypeSwitch2ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextType1 UFTextBlock
---@field TextType2 UFTextBlock
---@field ToggleBtn1 UToggleButton
---@field ToggleBtn2 UToggleButton
---@field ToggleGroup_0 UToggleGroup
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateTypeSwitch2ItemView = LuaClass(UIView, true)

function LoginCreateTypeSwitch2ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextType1 = nil
	--self.TextType2 = nil
	--self.ToggleBtn1 = nil
	--self.ToggleBtn2 = nil
	--self.ToggleGroup_0 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateTypeSwitch2ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateTypeSwitch2ItemView:OnInit()

end

function LoginCreateTypeSwitch2ItemView:OnDestroy()

end

function LoginCreateTypeSwitch2ItemView:OnShow()
	self:SetSwitchState(true)
end

function LoginCreateTypeSwitch2ItemView:OnHide()

end

function LoginCreateTypeSwitch2ItemView:OnRegisterUIEvent()

end

function LoginCreateTypeSwitch2ItemView:OnRegisterGameEvent()

end

function LoginCreateTypeSwitch2ItemView:OnRegisterBinder()

end

function LoginCreateTypeSwitch2ItemView:SetTitleText(LeftText, RightText)
	self.TextType1:SetText(LeftText)
	self.TextType2:SetText(RightText)
end

function LoginCreateTypeSwitch2ItemView:SetSwitchState(IsLeftSelect)
	-- 文本颜色切换
	local SelectColor = _G.UE.FLinearColor.FromHex("#183F7BFF")
	local UnSelectColor = _G.UE.FLinearColor.FromHex("#FFFFFFFF")
	local LeftColor = IsLeftSelect == true and SelectColor or UnSelectColor
	local RightColor = IsLeftSelect == false and SelectColor or UnSelectColor
	self.TextType1:SetColorAndOpacity(LeftColor)
	self.TextType2:SetColorAndOpacity(RightColor)
	-- 状态
	local LeftState = IsLeftSelect == true and _G.UE.EToggleButtonState.Checked or _G.UE.EToggleButtonState.UnChecked
	local RightState = IsLeftSelect == false and _G.UE.EToggleButtonState.Checked or _G.UE.EToggleButtonState.UnChecked
	self.ToggleBtn1:SetCheckedState(LeftState, false)
	self.ToggleBtn2:SetCheckedState(RightState, false)
end
return LoginCreateTypeSwitch2ItemView