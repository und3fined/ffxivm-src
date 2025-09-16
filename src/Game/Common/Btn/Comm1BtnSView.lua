---
--- Author: anypkvcai
--- DateTime: 2022-01-23 14:35
--- Description:
---

local LuaClass = require("Core/LuaClass")
local CommBtnBaseView = require("Game/Common/Btn/CommBtnBaseView")

---@class Comm1BtnSView : CommBtnBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field TextButton UTextBlock
---@field AnimPressed UWidgetAnimation
---@field AnimState01 UWidgetAnimation
---@field AnimState02 UWidgetAnimation
---@field AnimState03 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Comm1BtnSView = LuaClass(CommBtnBaseView, true)

function Comm1BtnSView:Ctor()
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

function Comm1BtnSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Comm1BtnSView:OnInit()
	self.Super:OnInit()
end

function Comm1BtnSView:OnDestroy()
	self.Super:OnDestroy()
end

function Comm1BtnSView:OnShow()

end

function Comm1BtnSView:OnHide()

end

function Comm1BtnSView:OnRegisterUIEvent()

end

function Comm1BtnSView:OnRegisterGameEvent()

end

function Comm1BtnSView:OnRegisterBinder()

end

return Comm1BtnSView