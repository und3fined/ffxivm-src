--
-- Author: anypkvcai
-- Date: 2022-11-14 17:26
-- Description:
--

local LinkedList = require("Core/LinkedList")
local ObjectGCType = require("Define/ObjectGCType")

local FLOG_WARNING = _G.FLOG_WARNING
local UUIMgr = _G.UE.UUIMgr.Get()

---@class WidgetPool
---@field ActiveWidgets LinkedList<UUserWidget>
---@field InactiveWidgets LinkedList<UUserWidget>
local WidgetPool = {}

function WidgetPool.New(...)
	local Object = {}
	setmetatable(Object, { __index = WidgetPool })
	Object:Ctor(...)
	return Object
end

function WidgetPool:Ctor()
	self.BPPath = ""
	self.ActiveWidgets = LinkedList.New()
	self.InactiveWidgets = LinkedList.New()
end

function WidgetPool:GetWidget()
	local Widget = self.InactiveWidgets:RemoveHead()
	if not Widget then
		return
	end

	self.ActiveWidgets:AddTail(Widget)

	return Widget
end

function WidgetPool:SetBPPath(BPPath)
	self.BPPath = BPPath
end

function WidgetPool:GetBPPath()
	return self.BPPath
end

function WidgetPool:AddWidget(Widget, bActive)
	if bActive then
		self.ActiveWidgets:AddTail(Widget)
	else
		self.InactiveWidgets:AddTail(Widget)
	end

	--print("WidgetPool:AddWidget", Widget.Object)

	Widget:SetIsInPool(true)

	UUIMgr:AddChildWidget(Widget)
end

function WidgetPool:ReleaseAllWidgets()
	local InactiveWidgets = self.InactiveWidgets
	InactiveWidgets:Traverse(WidgetPool.ReleaseWidget)
	InactiveWidgets:Empty()
end

function WidgetPool.ReleaseAllWidgetsExceptHoldPredicate(Widget)
	return Widget:GetGCType() ~= ObjectGCType.Hold
end

function WidgetPool:ReleaseAllWidgetsExceptHold()
	local List = self.InactiveWidgets:RemoveAll(WidgetPool.ReleaseAllWidgetsExceptHoldPredicate)
	if nil == List then
		return
	end

	for i = 1, #List do
		WidgetPool.ReleaseWidget(List[i])
	end
end

function WidgetPool:ReleaseExpiredWidgets(Widget)
	if self.InactiveWidgets:Remove(Widget) then
		WidgetPool.ReleaseWidget(Widget)
	else
		FLOG_WARNING("WidgetPool:ReleaseExpiredWidgets Error, Name=%s", Widget.BPName)
	end
end

---RecycleWidget
---@param Widget UUserWidget
function WidgetPool:RecycleWidget(Widget)
	--print("WidgetPool:RecycleWidget", Widget.Object)
	Widget:HideView()
	Widget:UnloadView()

	if self.ActiveWidgets:Remove(Widget) then
		self.InactiveWidgets:AddTail(Widget)
	elseif Widget:GetGCType() ~= ObjectGCType.NoCache then
		FLOG_WARNING("WidgetPool:RecycleWidget Error, Name=%s", Widget.BPName)
	end
end

---ReleaseWidget
---@param Widget UUserWidget
function WidgetPool.ReleaseWidget(Widget)
	--print("WidgetPool.ReleaseWidget", Widget.ObjectName, Widget.AncestorName)

	Widget:SetIsInPool(false)
	Widget:DestroyView()

	UUIMgr:RemoveChildWidget(Widget)
end

---ForceReleaseWidget
---@param Widget UUserWidget
function WidgetPool:ForceReleaseWidget(Widget)
	if self.ActiveWidgets:Remove(Widget) then
		Widget:SetIsInPool(false)
		Widget:HideView()
		Widget:UnloadView()
		Widget:DestroyView()
		UUIMgr:RemoveChildWidget(Widget)
	else
		FLOG_WARNING("WidgetPool:ForceReleaseWidget Error, Name=%s", Widget.BPName)
	end
end

function WidgetPool:GetActiveWidgetsCount()
	return self.ActiveWidgets:GetNum()
end

function WidgetPool:GetInactiveWidgetsCount()
	return self.InactiveWidgets:GetNum()
end

function WidgetPool:GetWidgetCount()
	return self.ActiveWidgets:GetNum() + self.InactiveWidgets:GetNum()
end

return WidgetPool