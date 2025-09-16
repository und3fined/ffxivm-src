---
--- Author: jamiyang
--- DateTime: 2023-10-09 16:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreateTypeSwitchItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextType1 UFTextBlock
---@field TextType2 UFTextBlock
---@field ToggleBtn1 UToggleButton
---@field ToggleBtn2 UToggleButton
---@field ToggleGroup_0 UToggleGroup
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateTypeSwitchItemView = LuaClass(UIView, true)

function LoginCreateTypeSwitchItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextType1 = nil
	--self.TextType2 = nil
	--self.ToggleBtn1 = nil
	--self.ToggleBtn2 = nil
	--self.ToggleGroup_0 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateTypeSwitchItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateTypeSwitchItemView:OnInit()

end

function LoginCreateTypeSwitchItemView:OnDestroy()

end

function LoginCreateTypeSwitchItemView:OnShow()
	self:SetSwitchState(true)
end

function LoginCreateTypeSwitchItemView:OnHide()

end

function LoginCreateTypeSwitchItemView:OnRegisterUIEvent()

end

function LoginCreateTypeSwitchItemView:OnRegisterGameEvent()

end

function LoginCreateTypeSwitchItemView:OnRegisterBinder()

end

function LoginCreateTypeSwitchItemView:SetTitleText(LeftText, RightText)
	self.TextType1:SetText(LeftText)
	self.TextType2:SetText(RightText)
end
function LoginCreateTypeSwitchItemView:SetSwitchState(IsLeftSelect)
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

return LoginCreateTypeSwitchItemView