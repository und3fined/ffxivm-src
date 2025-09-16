--
-- Author: anypkvcai
-- Date: 2020-11-10 21:30:49
-- Description: 为了扩展功能，把一个Widget适配为UIView
-- WiKi: 为了扩展功能，把一个Widget适配为UIView，UIAdapterBase是适配器的基类

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")

local ESlateVisibility = _G.UE.ESlateVisibility
local FLOG_ERROR = _G.FLOG_ERROR

---@class UIAdapterBase : UIView
local UIAdapterBase = LuaClass(UIView, true)

---Ctor
function UIAdapterBase:Ctor()
	self.View = nil
	self.Widget = nil
	self.Object = nil
end

function UIAdapterBase:OnDestroy()
	self.View = nil
	self.Widget = nil
	self.Object = nil
end

---InitAdapter
---@param View UIView
---@param Widget UWidget
---@return boolean
function UIAdapterBase:InitAdapter(View, Widget)
	if nil == View then
		FLOG_ERROR("UIAdapterBase:InitAdapter View is nil, %s", debug.traceback())
		return false
	end

	if nil == Widget then
		FLOG_ERROR("UIAdapterBase:InitAdapter Widget is nil, %s", debug.traceback())
		return false
	end

	rawset(self, "View", View)
	rawset(self, "Widget", Widget)
	rawset(self, "Object", Widget)
	rawset(self, "IsAdapterVisible", true)

	View:AddSubView(self)

	self:InitView(View.ViewID, View.Config)
	self:LoadView()

	return true
end

function UIAdapterBase:SetVisibility(Visibility)
	self.Super:SetVisibility(Visibility)
	self.IsAdapterVisible = ESlateVisibility.SelfHitTestInvisible or Visibility == ESlateVisibility.Visible
end

---SetVisible
---@param bVisible boolean
function UIAdapterBase:SetVisible(bVisible)
	self.Super:SetVisible(bVisible)
	self.IsAdapterVisible = bVisible
end

---IsVisible
---@return boolean
function UIAdapterBase:IsVisible()
	return self.IsAdapterVisible
end

function UIAdapterBase:PlayAnimIn()

end

function UIAdapterBase:GetAnimIn()

end

function UIAdapterBase:GetAnimInTime()
	return 0
end

function UIAdapterBase:PlayAnimOut()

end

function UIAdapterBase:GetAnimOut()

end

function UIAdapterBase:GetAnimOutTime()
	return 0
end

function UIAdapterBase:PlayAnimLoop()

end

function UIAdapterBase:GetAnimLoop()

end

function UIAdapterBase:StopAnimLoop()

end

function UIAdapterBase:PlayAnimationToEndTime()

end

function UIAdapterBase:PlayAllAnimationsToEnd()

end

function UIAdapterBase:StopAllAnimations()

end

function UIAdapterBase:GetName()
	if nil == self.Object then
		return
	end

	local GetName = self.Object.GetName
	if nil == GetName then
		return
	end

	return GetName(self.Object)
end

return UIAdapterBase