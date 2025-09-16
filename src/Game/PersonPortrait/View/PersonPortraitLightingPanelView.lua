---
--- Author: xingcaicao
--- DateTime: 2023-11-29 12:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil") 
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")
local PersonPortraitUtil = require("Game/PersonPortrait/PersonPortraitUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local FVector2D = _G.UE.FVector2D
local UKismetInputLibrary = _G.UE.UKismetInputLibrary
local UWidgetLayoutLibrary = _G.UE.UWidgetLayoutLibrary
local USlateBlueprintLibrary = _G.UE.USlateBlueprintLibrary

local IntensityMaxValue = PersonPortraitDefine.IntensityMaxValue
local ColorMaxValue = PersonPortraitDefine.ColorChannelMaxValue
local WBL = _G.UE.UWidgetBlueprintLibrary
local LSTR = _G.LSTR

local DirMin = -180
local DirMax = 180
local DirRange = DirMax - DirMin

local TabType = {
	Ambient  = 1, -- 环境光
	Direct 	 = 2, -- 方向性灯光
	LightDir = 3, -- 灯光方向
}

---@class PersonPortraitLightingPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnReset UFButton
---@field CommTabsTop CommHorTabsView
---@field DragRangePanel UFCanvasPanel
---@field ImgDragIcon UFImage
---@field LightDirPanel UFCanvasPanel
---@field ProbarPanel UFCanvasPanel
---@field ProbarSliderBlue PersonPortraitSliderTwoView
---@field ProbarSliderBright PersonPortraitSliderTwoView
---@field ProbarSliderGreen PersonPortraitSliderTwoView
---@field ProbarSliderRed PersonPortraitSliderTwoView
---@field TextBright UFTextBlock
---@field TextDirX UFTextBlock
---@field TextDirY UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimRefresh UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonPortraitLightingPanelView = LuaClass(UIView, true)

function PersonPortraitLightingPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnReset = nil
	--self.CommTabsTop = nil
	--self.DragRangePanel = nil
	--self.ImgDragIcon = nil
	--self.LightDirPanel = nil
	--self.ProbarPanel = nil
	--self.ProbarSliderBlue = nil
	--self.ProbarSliderBright = nil
	--self.ProbarSliderGreen = nil
	--self.ProbarSliderRed = nil
	--self.TextBright = nil
	--self.TextDirX = nil
	--self.TextDirY = nil
	--self.AnimIn = nil
	--self.AnimRefresh = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonPortraitLightingPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommTabsTop)
	self:AddSubView(self.ProbarSliderBlue)
	self:AddSubView(self.ProbarSliderBright)
	self:AddSubView(self.ProbarSliderGreen)
	self:AddSubView(self.ProbarSliderRed)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonPortraitLightingPanelView:OnInit()
	local Size = UIUtil.CanvasSlotGetSize(self.DragRangePanel)
	local Widget = Size.X
	local Height = Size.Y

	self.DragRangeX = Widget 
	self.DragRangeY = Height 

	self.UnitDirX = DirRange/Widget 
	self.UnitDirY = DirRange/Height

	-- 亮度 
	self.ProbarSliderBright:SetValueChangedCallback(function(Value) self:OnValueChangedBright(Value) end)

	-- 颜色：Red 
	self.ProbarSliderRed:SetValueChangedCallback(function(Value) self:OnValueChangedColorR(Value) end)

	-- 颜色：Green 
	self.ProbarSliderGreen:SetValueChangedCallback(function(Value) self:OnValueChangedColorG(Value) end)

	-- 颜色：Blue 
	self.ProbarSliderBlue:SetValueChangedCallback(function(Value) self:OnValueChangedColorB(Value) end)

	self.TextBright:SetText(_G.LSTR(60033)) -- "亮度"
end

function PersonPortraitLightingPanelView:OnDestroy()

end

function PersonPortraitLightingPanelView:OnShow()
	self.CommonRender2DToImageView = self.ParentView:GetCommonRender2DToImageView()

	--默认选择第一个Tab
	self.CommTabsTop:SetSelectedIndex(TabType.Ambient)
end

function PersonPortraitLightingPanelView:OnHide()
	self.IsDraging = false
	self.CommonRender2DToImageView = nil

	self.CommTabsTop:CancelSelected()
end

function PersonPortraitLightingPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnReset, self.OnClickButtonReset)

	UIUtil.AddOnSelectionChangedEvent(self, self.CommTabsTop, self.OnSelectionChangedTabsTop)
end

function PersonPortraitLightingPanelView:OnRegisterGameEvent()

end

function PersonPortraitLightingPanelView:OnRegisterBinder()
	self.ProbarSliderBright:SetValueParam(0, IntensityMaxValue)
	self.ProbarSliderRed:SetValueParam(0, ColorMaxValue)
	self.ProbarSliderGreen:SetValueParam(0, ColorMaxValue)
	self.ProbarSliderBlue:SetValueParam(0, ColorMaxValue)
end

function PersonPortraitLightingPanelView:UpdateLightProbar(Bright, Color, IsRefreshModel)
	if nil == Bright or nil == Color then
		return
	end

	-- 亮度
	self.ProbarSliderBright:SetValue(Bright)

	-- 颜色 RGB
	local R = Color[1] or 0
	local G = Color[2] or 0
	local B = Color[3] or 0
	self.ProbarSliderRed:SetValue(R)
	self.ProbarSliderGreen:SetValue(G)
	self.ProbarSliderBlue:SetValue(B)

	if IsRefreshModel then
		-- 灯光强度、颜色
		self:SetLightBright(Bright)
		self:SetLightColors(R, G, B)
	end
end

function PersonPortraitLightingPanelView:UpdateLightDirCoordinate(Dir, IsRefreshModel)
	if nil == Dir then
		return
	end

	local X = Dir[1] or 0
	local Y = Dir[2] or 0

	local LocalPos = FVector2D(self:Dir2Location(X, Y))
	UIUtil.CanvasSlotSetPosition(self.ImgDragIcon, LocalPos)

	self.TextDirX:SetText(tostring(X))
	self.TextDirY:SetText(tostring(Y))

	if IsRefreshModel then
		self:SetLightDirection(X, Y)
	end
end

-- 设置灯光亮度（强度）
function PersonPortraitLightingPanelView:SetLightBright(Value)
	local ComImageView = self.CommonRender2DToImageView
	if nil == ComImageView then
		return
	end

	local Intensity = PersonPortraitUtil.NormalizedIntensity(Value)
	local CurModelEditVM = PersonPortraitVM.CurModelEditVM

	local Tab = self.CurTab
	if Tab == TabType.Ambient then
		ComImageView:SetAmbientLightIntensity(Intensity)
		CurModelEditVM:SetAmbientLightIntensity(Value)

	elseif Tab == TabType.Direct then
		ComImageView:SetDirectionalLightIntensity(Intensity)
		CurModelEditVM:SetDirectLightIntensity(Value)
	end
end

-- 设置灯光颜色
function PersonPortraitLightingPanelView:SetLightColors(R, G, B)
	local ComImageView = self.CommonRender2DToImageView
	if nil == ComImageView then
		return
	end

	local Tab = self.CurTab
	local CurModelEditVM = PersonPortraitVM.CurModelEditVM

	local Color = (Tab == TabType.Ambient) and CurModelEditVM.AmbientLightColor or CurModelEditVM.DirectLightColor
	R = R or (Color[1] or 0)
	G = G or (Color[2] or 0)
	B = B or (Color[3] or 0)

	if Tab == TabType.Ambient then
		ComImageView:SetAmbientLightColor(PersonPortraitUtil.NormalizedColor(R, G, B))
		CurModelEditVM:SetAmbientLightColor(R, G, B)

	else
		ComImageView:SetDirectionalLightColor(PersonPortraitUtil.NormalizedColor(R, G, B))
		CurModelEditVM:SetDirectLightColor(R, G, B)
	end
end

-- 设置灯光方向
function PersonPortraitLightingPanelView:SetLightDirection(X, Y)
	local ComImageView = self.CommonRender2DToImageView
	if nil == ComImageView then
		return
	end

	local CurModelEditVM = PersonPortraitVM.CurModelEditVM
	X = math.floor(X)
	Y = math.floor(Y)

	PersonPortraitUtil.SetDirectionalLightDir(ComImageView, X, Y)
	CurModelEditVM:SetDirectLightDir(X, Y)

	self.TextDirX:SetText(tostring(X))
	self.TextDirY:SetText(tostring(Y))
end

function PersonPortraitLightingPanelView:Location2Dir(X, Y)
	return DirMin + X * self.UnitDirX, DirMax - Y * self.UnitDirY
end

function PersonPortraitLightingPanelView:Dir2Location(DirX, DirY)
	return (DirX - DirMin)/DirRange * self.DragRangeX, (DirMax - DirY)/DirRange * self.DragRangeY
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function PersonPortraitLightingPanelView:OnMouseButtonDown(_, MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	self.IsDraging = UIUtil.IsUnderLocation(self.ImgDragIcon, MousePosition) 

	return WBL.Handled()
end

function PersonPortraitLightingPanelView:OnMouseMove(_, MouseEvent)
	if not self.IsDraging then
		return WBL.Handled()
	end

	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	local SelfGeometry = UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
	local ViewportPos = USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, MousePosition)
	local LocalPos = UIUtil.ViewportToLocal(self.DragRangePanel, ViewportPos) 
	local X = LocalPos.X
	local Y = LocalPos.Y
	X = math.max(X, 0)
	Y = math.max(Y, 0)

	X = math.min(X, self.DragRangeX)
	Y = math.min(Y, self.DragRangeY)

	LocalPos.X = X
	LocalPos.Y = Y

	self:SetLightDirection(self:Location2Dir(X, Y))
	UIUtil.CanvasSlotSetPosition(self.ImgDragIcon, LocalPos)

	return WBL.Handled()
end

function PersonPortraitLightingPanelView:OnMouseButtonUp()
	self.IsDraging = false

	return WBL.Handled()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function PersonPortraitLightingPanelView:OnClickButtonReset()
	local Tab = self.CurTab 
	if Tab == TabType.Ambient or Tab == TabType.Direct then
		local IsAmbient = Tab == TabType.Ambient
		local Bright = IsAmbient and PersonPortraitUtil.GetDefaultAmbientLightIntensity() or PersonPortraitUtil.GetDefaultDirectLightIntensity()
		local Color = IsAmbient and PersonPortraitUtil.GetDefaultAmbientLightColor() or PersonPortraitUtil.GetDefaultDirectLightColor()
		self:UpdateLightProbar(Bright, Color, true)

	elseif Tab == TabType.LightDir then
		self:UpdateLightDirCoordinate(PersonPortraitUtil.GetDefaultDirectLightDir(), true)
	end

	MsgTipsUtil.ShowTips(LSTR(60013)) -- "灯光参数已重置"
end

function PersonPortraitLightingPanelView:OnSelectionChangedTabsTop(Index)
	self.CurTab = Index

	local b1, b2 = false, false
	local CurModelEditVM = PersonPortraitVM.CurModelEditVM

	if Index == TabType.Ambient or Index == TabType.Direct then	
		b1 = true

		-- 更新灯光颜色
		local IsAmbient = Index == TabType.Ambient
		local Bright = IsAmbient and CurModelEditVM.AmbientLightIntensity or CurModelEditVM.DirectLightIntensity
		local Color = IsAmbient and CurModelEditVM.AmbientLightColor or CurModelEditVM.DirectLightColor
		self:UpdateLightProbar(Bright, Color)

	elseif Index == TabType.LightDir then
		b2 = true

		-- 更新灯光方向坐标
		self:UpdateLightDirCoordinate(CurModelEditVM.DirectLightDir)
	end

	UIUtil.SetIsVisible(self.ProbarPanel, b1)
	UIUtil.SetIsVisible(self.LightDirPanel, b2, true)

	-- 播放动效
	self:PlayAnimation(self.AnimRefresh)
end

-- 亮度
function PersonPortraitLightingPanelView:OnValueChangedBright(Value)
	self:SetLightBright(Value)
end

-- 颜色：Red 
function PersonPortraitLightingPanelView:OnValueChangedColorR(Value)
	self:SetLightColors(Value)
end

-- 颜色：Green 
function PersonPortraitLightingPanelView:OnValueChangedColorG(Value)
	self:SetLightColors(nil, Value)
end

-- 颜色：Blue 
function PersonPortraitLightingPanelView:OnValueChangedColorB(Value)
	self:SetLightColors(nil, nil, Value)
end

return PersonPortraitLightingPanelView