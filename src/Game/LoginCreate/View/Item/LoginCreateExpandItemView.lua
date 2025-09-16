---
--- Author: jamiyang
--- DateTime: 2023-10-09 16:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreateExpandItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnStretch UFButton
---@field ImgArrowExpand UFImage
---@field ImgArrowRetract UFImage
---@field TextStretch_1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateExpandItemView = LuaClass(UIView, true)

function LoginCreateExpandItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnStretch = nil
	--self.ImgArrowExpand = nil
	--self.ImgArrowRetract = nil
	--self.TextStretch_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateExpandItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateExpandItemView:OnInit()

end

function LoginCreateExpandItemView:OnDestroy()

end

function LoginCreateExpandItemView:OnShow()
	UIUtil.SetIsVisible(self.ImgArrowExpand, true)
	UIUtil.SetIsVisible(self.ImgArrowRetract,  false)
	self.TextStretch_1:SetText(_G.LSTR(980014))
end

function LoginCreateExpandItemView:OnHide()

end

function LoginCreateExpandItemView:OnRegisterUIEvent()

end

function LoginCreateExpandItemView:OnRegisterGameEvent()

end

function LoginCreateExpandItemView:OnRegisterBinder()

end

function LoginCreateExpandItemView:SetExpandState(IsExpanded)
	-- self.ImgArrowExpand:SetIsVisible(IsExpanded)
	-- self.ImgArrowRetract:SetIsVisible(not IsExpanded)
	UIUtil.SetIsVisible(self.ImgArrowExpand, not IsExpanded)
	UIUtil.SetIsVisible(self.ImgArrowRetract, IsExpanded)
	local Text = IsExpanded == true and _G.LSTR(980023) or _G.LSTR(980014)
	self.TextStretch_1:SetText(Text)
end
return LoginCreateExpandItemView