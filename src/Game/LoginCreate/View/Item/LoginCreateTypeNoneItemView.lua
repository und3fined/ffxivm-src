---
--- Author: jamiyang
--- DateTime: 2023-10-09 16:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreateTypeNoneItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnText UFButton
---@field ImgNormal UFImage
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateTypeNoneItemView = LuaClass(UIView, true)

function LoginCreateTypeNoneItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnText = nil
	--self.ImgNormal = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateTypeNoneItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateTypeNoneItemView:OnInit()

end

function LoginCreateTypeNoneItemView:OnDestroy()

end

function LoginCreateTypeNoneItemView:OnShow()
	self.TextContent:SetText(_G.LSTR(1250040)) --"无"
end

function LoginCreateTypeNoneItemView:OnHide()

end

function LoginCreateTypeNoneItemView:OnRegisterUIEvent()

end

function LoginCreateTypeNoneItemView:OnRegisterGameEvent()

end

function LoginCreateTypeNoneItemView:OnRegisterBinder()

end

return LoginCreateTypeNoneItemView