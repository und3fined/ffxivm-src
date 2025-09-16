---
--- Author: loiafeng
--- DateTime: 2025-03-26 00:27
--- Description:
---

local MainFunctionItemBaseView = require("Game/Main/Item/MainFunctionItemBaseView")
local LuaClass = require("Core/LuaClass")
local ProtoCommon = require("Protocol/ProtoCommon")

local MainFunctionDefine = require("Game/Main/FunctionPanel/MainFunctionDefine")
local ButtonType = MainFunctionDefine.ButtonType

---@class MainOpsEntranceItemView : MainFunctionItemBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field CommonRedDot CommonRedDotView
---@field IconActor UFImage
---@field PanelActor UFCanvasPanel
---@field AnimDeparture UWidgetAnimation
---@field AnimFirst UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainOpsEntranceItemView = LuaClass(MainFunctionItemBaseView, true)

function MainOpsEntranceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.CommonRedDot = nil
	--self.IconActor = nil
	--self.PanelActor = nil
	--self.AnimDeparture = nil
	--self.AnimFirst = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainOpsEntranceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainOpsEntranceItemView:OverrideWidgets()
	self._Icon = self.IconActor
    self._Panel = self.PanelActor
    self._Button = self.Btn
    self._RedDot = self.CommonRedDot
end

function MainOpsEntranceItemView:OverrideUnlockAnim()
	if self.FunctionType == ButtonType.DEPART_OF_LIGHT then
		self._UnlockAnim = self.AnimDeparture
	else
    	self._UnlockAnim = self.AnimFirst
	end
end

return MainOpsEntranceItemView