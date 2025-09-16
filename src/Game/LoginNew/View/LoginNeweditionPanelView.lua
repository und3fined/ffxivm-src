---
--- Author: richyczhou
--- DateTime: 2024-06-25 10:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginNeweditionPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnVolume UFButton
---@field ImgBg UFImage
---@field LoginNewProBar LoginNewProBarItemView
---@field TextHealthy UFTextBlock
---@field TextNum UFTextBlock
---@field TextNum1 UFTextBlock
---@field TextNum2 UFTextBlock
---@field TextPrepare UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNeweditionPanelView = LuaClass(UIView, true)

function LoginNeweditionPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnVolume = nil
	--self.ImgBg = nil
	--self.LoginNewProBar = nil
	--self.TextHealthy = nil
	--self.TextNum = nil
	--self.TextNum1 = nil
	--self.TextNum2 = nil
	--self.TextPrepare = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNeweditionPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.LoginNewProBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNeweditionPanelView:OnInit()

end

function LoginNeweditionPanelView:OnDestroy()

end

function LoginNeweditionPanelView:OnShow()

end

function LoginNeweditionPanelView:OnHide()

end

function LoginNeweditionPanelView:OnRegisterUIEvent()

end

function LoginNeweditionPanelView:OnRegisterGameEvent()

end

function LoginNeweditionPanelView:OnRegisterBinder()

end

return LoginNeweditionPanelView