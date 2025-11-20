---
--- Author: skysong
--- DateTime: 2025-05-16 16:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MainFunctionItemBaseView = require("Game/Main/Item/MainFunctionItemBaseView")

---@class MainHouseItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonActor UFButton
---@field CommonRedDot2 CommonRedDotView
---@field IconActor UFImage
---@field PanelRedDot2 UFCanvasPanel
---@field AnimUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainHouseItemView = LuaClass(MainFunctionItemBaseView, true)

function MainHouseItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonActor = nil
	--self.CommonRedDot2 = nil
	--self.IconActor = nil
	--self.PanelRedDot2 = nil
	--self.AnimUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainHouseItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainHouseItemView:OverrideWidgets()
	self._Icon = self.IconActor
	self._Panel = self.ButtonActor
	self._Button = self.ButtonActor
	self._RedDot = self.CommonRedDot2
end

function MainHouseItemView:OverrideUnlockAnim()
	self._UnlockAnim = self.AnimUnlock
end

return MainHouseItemView