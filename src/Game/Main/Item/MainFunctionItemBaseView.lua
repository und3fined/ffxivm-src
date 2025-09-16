---
--- Author: loiafeng
--- DateTime: 2025-01-17 15:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MainFunctionUtil = require("Game/Main/FunctionPanel/MainFunctionUtil")

---@class MainFunctionItemBaseView : UIView
local MainFunctionItemBaseView = LuaClass(UIView, true)

function MainFunctionItemBaseView:Ctor()
    self._Icon = nil
    self._Panel = nil
    self._Button = nil
    self._UnlockAnim = nil
    self._RedDot = nil
end

---@protected
function MainFunctionItemBaseView:OverrideWidgets()
end

---@protected
function MainFunctionItemBaseView:OverrideUnlockAnim()
end

function MainFunctionItemBaseView:OnInit()
    self:OverrideWidgets()

	self.FunctionType = nil

	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self._Icon) },
		{ "IsVisible", UIBinderSetIsVisible.New(self, self._Panel, false, true) },
	}
end

function MainFunctionItemBaseView:OnDestroy()

end

function MainFunctionItemBaseView:OnShow()
	local ItemVM = (self.Params or {}).Data
	if nil == ItemVM then
		return
	end

	if ItemVM.RedDotID > 0 then
		UIUtil.SetIsVisible(self._RedDot, true)
		self._RedDot:SetRedDotIDByID(ItemVM.RedDotID)
	else
		UIUtil.SetIsVisible(self._RedDot, false)
	end

	self.FunctionType = ItemVM.Type
	self.RowIndex = ItemVM.RowIndex
	self.ColumnIndex = ItemVM.ColumnIndex

	self:OverrideUnlockAnim()
	if self._UnlockAnim then
		self:PlayAnimToEnd(self._UnlockAnim)
	end
end

function MainFunctionItemBaseView:OnHide()

end

function MainFunctionItemBaseView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self._Button, self.OnButtonClicked)
end

function MainFunctionItemBaseView:OnRegisterGameEvent()

end

function MainFunctionItemBaseView:OnRegisterBinder()
	local ItemVM = (self.Params or {}).Data
	if nil == ItemVM then
		return
	end

	self:RegisterBinders(ItemVM, self.Binders)
end

function MainFunctionItemBaseView:OnButtonClicked()
	MainFunctionUtil.OnPressed(self.FunctionType)
end

function MainFunctionItemBaseView:PlayUnlockAnim()
	if not self:IsAnimationPlaying(self._UnlockAnim) then
		self:PlayAnimation(self._UnlockAnim)
	end
end

return MainFunctionItemBaseView