---
--- Author: chriswang
--- DateTime: 2023-10-20 14:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreateMonthItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMonth UFButton
---@field ImgSelect UFImage
---@field TextMonth UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateMonthItemView = LuaClass(UIView, true)

function LoginCreateMonthItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMonth = nil
	--self.ImgSelect = nil
	--self.TextMonth = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateMonthItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateMonthItemView:OnInit()

end

function LoginCreateMonthItemView:OnDestroy()

end

function LoginCreateMonthItemView:OnShow()
	if self.Params and self.Params.Data then
		if nil ~= self.TextMonth then
			self.TextMonth:SetText(self.Params.Data)
		end
	end
end

function LoginCreateMonthItemView:OnHide()

end

function LoginCreateMonthItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMonth, self.OnBtnMonthClick)
end

function LoginCreateMonthItemView:OnRegisterGameEvent()

end

function LoginCreateMonthItemView:OnRegisterBinder()

end

function LoginCreateMonthItemView:OnSelectChanged(IsSelected)
	if IsSelected then
		UIUtil.SetIsVisible(self.ImgSelect, true)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextMonth, "FFFFFFFF")
	else
		UIUtil.SetIsVisible(self.ImgSelect, false)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextMonth, "688FB6FF")
	end
end

function LoginCreateMonthItemView:OnBtnMonthClick()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

return LoginCreateMonthItemView