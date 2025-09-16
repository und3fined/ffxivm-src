---
--- Author: loiafeng
--- DateTime: 2025-01-17 15:24
--- Description:
---

local MainFunctionItemBaseView = require("Game/Main/Item/MainFunctionItemBaseView")
local LuaClass = require("Core/LuaClass")

---@class MainFunctionItemView : MainFunctionItemBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonActor UFButton
---@field CommonRedDot2 CommonRedDotView
---@field IconActor UFImage
---@field PanelRedDot2 UFCanvasPanel
---@field AnimUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainFunctionItemView = LuaClass(MainFunctionItemBaseView, true)

function MainFunctionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonActor = nil
	--self.CommonRedDot2 = nil
	--self.IconActor = nil
	--self.PanelRedDot2 = nil
	--self.AnimUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainFunctionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainFunctionItemView:OverrideWidgets()
	self._Icon = self.IconActor
    self._Panel = self.ButtonActor
    self._Button = self.ButtonActor
    self._RedDot = self.CommonRedDot2
end

function MainFunctionItemView:OverrideUnlockAnim()
    self._UnlockAnim = self.AnimUnlock
end

return MainFunctionItemView