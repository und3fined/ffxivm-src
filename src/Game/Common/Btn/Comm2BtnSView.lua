---
--- Author: anypkvcai
--- DateTime: 2022-05-17 17:55
--- Description:
---

local LuaClass = require("Core/LuaClass")
local CommBtnBaseView = require("Game/Common/Btn/CommBtnBaseView")

---@class Comm2BtnSView : CommBtnBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field TextButton UTextBlock
---@field AnimPressed UWidgetAnimation
---@field AnimState01 UWidgetAnimation
---@field AnimState02 UWidgetAnimation
---@field AnimState03 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Comm2BtnSView = LuaClass(CommBtnBaseView, true)

function Comm2BtnSView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.TextButton = nil
	--self.AnimPressed = nil
	--self.AnimState01 = nil
	--self.AnimState02 = nil
	--self.AnimState03 = nil
	--self.PlayColorAnimation = function(self) end
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Comm2BtnSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Comm2BtnSView:OnInit()
	self.Super:OnInit()
end

function Comm2BtnSView:OnDestroy()
	self.Super:OnDestroy()
end

function Comm2BtnSView:OnShow()

end

function Comm2BtnSView:OnHide()

end

function Comm2BtnSView:OnRegisterUIEvent()

end

function Comm2BtnSView:OnRegisterGameEvent()

end

function Comm2BtnSView:OnRegisterBinder()

end

return Comm2BtnSView