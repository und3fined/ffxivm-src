--
-- Author: anypkvcai
-- Date: 2020-08-20 15:05:47
-- Description:
--


local UIView = require("UI/UIView")
local UILayer = require("UI/UILayer")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local FLOG_ERROR = _G.FLOG_ERROR

---@class RootView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@field ObjectLayer table
local RootView = LuaClass(UIView, true)

function RootView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.ObjectLayer = nil
	self.LayerBit = 0
	self.ViewsStack = {}
end

function RootView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RootView:OnInit()
	self:InitLayer()
end

function RootView:OnDestroy()
	self.ObjectLayer = nil
end

function RootView:OnShow()
	self:ShowAllLayer()
end

function RootView:OnHide()

end

function RootView:InitLayer()
	self.ObjectLayer = {}
	for k, v in pairs(UILayer) do
		if v ~= UILayer.All then
			local Object = self[k]
			if nil ~= Object then
				self.ObjectLayer[v] = Object
			else
				FLOG_ERROR("RootView:InitLayer Object is nil, Layer=%d", v)
			end
		end
	end
end

function RootView:AddView(Layer, View)
	if nil == View then
		FLOG_ERROR("RootView:AddView View is nil, Layer=%d", Layer)
		return
	end

	local Object = self.ObjectLayer[Layer]
	if nil == Object then
		FLOG_ERROR("RootView:AddView Object is nil, Layer=%d", Layer)
		return
	end

	Object:AddChild(View.Object)

	self:AddToStack(View)

	local Slot = _G.UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(View.Object)

	Slot:SetZOrder(View:GetZOrder())

	-- local Anchor = Slot:GetAnchors()
	local Anchor = _G.UE.FAnchors()
	Anchor.Minimum = _G.UE.FVector2D(0, 0)
	Anchor.Maximum = _G.UE.FVector2D(1, 1)
	Slot:SetAnchors(Anchor)

	-- local Offset = Slot:GetOffsets()
	local Offset = _G.UE.FMargin()
	Offset.Left = 0
	Offset.Top = 0
	Offset.Right = 0
	Offset.Bottom = 0
	Slot:SetOffsets(Offset)
end

function RootView:RemoveView(Layer, View)
	if nil == View then
		FLOG_ERROR("RootView:RemoveView View is nil, Layer=%d", Layer)
		return
	end

	local Object = self.ObjectLayer[Layer]
	if nil == Object then
		FLOG_ERROR("RootView:RemoveView Object is nil, Layer=%d", Layer)
		return
	end

	Object:RemoveChild(View.Object)

	self:RemoveFromStack(View)
end

function RootView:GetTopView(Layer)
	local Stack = self.ViewsStack[Layer]
	if nil == Stack then
		return
	end

	return Stack[#Stack]
end

function RootView:AddToStack(View)
	local Layer = View:GetLayer()

	local Stack = self.ViewsStack[Layer]
	if nil == Stack then
		Stack = {}
		self.ViewsStack[Layer] = Stack
	end

	local TopView = Stack[#Stack]
	local TopZOrder = TopView and TopView.ZOrder or 0
	local ZOrder = TopZOrder + 10

	View:SetZOrder(ZOrder)

	table.insert(Stack, View)
end

function RootView:RemoveFromStack(View)
	local Stack = self.ViewsStack[View:GetLayer()]

	for i = 1, #Stack do
		if Stack[i] == View then
			table.remove(Stack, i)
			return
		end
	end
end

function RootView:ShowLayer(Layer)
	if self.LayerBit == Layer then
		return
	end

	self.LayerBit = Layer

	for k, v in pairs(self.ObjectLayer) do
		UIUtil.SetIsVisible(v, (Layer & k) ~= 0)
	end
end

function RootView:ShowAllLayer()
	if self.LayerBit == UILayer.All then
		return
	end

	self.LayerBit = UILayer.All

	for _, v in pairs(self.ObjectLayer) do
		UIUtil.SetIsVisible(v, true)
	end
end

function RootView:HideAllLayer()
	if self.LayerBit == 0 then
		return
	end

	self.LayerBit = 0

	for _, v in pairs(self.ObjectLayer) do
		UIUtil.SetIsVisible(v, false)
	end
end

function RootView:RreshAllLayer()
	for _, p in pairs(self.ObjectLayer) do
		local GetAllChildren = p:GetAllChildren()
		for _, v in pairs(GetAllChildren) do
			if v and v.ViewID ~= _G.UIViewID.NetworkWaiting then
				_G.UIViewMgr:HideView(v.ViewID)
				_G.UIViewMgr:ShowView(v.ViewID)
			end
		end
	end
end

return RootView