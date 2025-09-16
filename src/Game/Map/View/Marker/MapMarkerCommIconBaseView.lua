--
-- Author: anypkvcai
-- Date: 2022-12-13 16:55
-- Description:
--


local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderSetOpacity = require("Binder/UIBinderSetOpacity")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerBPType = MapDefine.MapMarkerBPType
local FVector2D = _G.UE.FVector2D


---@class MapMarkerCommIconBaseView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field ImgSmallIcon UFImage
---@field ImgSmallIcon02 UFImage
---@field ImgTextBG UFImage
---@field PanelAlignment UFCanvasPanel
---@field PanelIconS UFCanvasPanel
---@field PanelIconS02 UFCanvasPanel
---@field PanelTrack UFCanvasPanel
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerCommIconBaseView = LuaClass(UIView, true)

function MapMarkerCommIconBaseView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.PanelAlignment = nil
	--self.PanelTrack = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerCommIconBaseView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerCommIconBaseView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon, false, true, true) },
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.ImgIcon) },
		{ "NameVisibility", UIBinderSetVisibility.New(self, self.TextName) },
		{ "IsFollow", UIBinderValueChangedCallback.New(self, nil, self.OnFollowStateChange) },
		{ "Alpha", UIBinderSetOpacity.New(self, self.ImgIcon) },
		{ "Alpha", UIBinderSetOpacity.New(self, self.TextName) },
		{ "NameVisibility", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedNameVisibility) },
	}
end

function MapMarkerCommIconBaseView:OnDestroy()

end

function MapMarkerCommIconBaseView:OnShow()
	self:UpdateColor()
	self:UpdateIcon()
	self:UpdateExtraIcon()
end

function MapMarkerCommIconBaseView:OnHide()
	if self.TrackAnimView then
		self.TrackAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.TrackAnimView)
		self.TrackAnimView = nil
	end

	if self.HighlightAnimView then
		self.HighlightAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.HighlightAnimView)
		self.HighlightAnimView = nil
	end

	-- 通用标记因为有cache，这里将标记图标设置为默认图标，避免地图切换后仍引用资源
	local DefaultIconPath = MapDefine.MapIconConfigs.DefaultIcon
	UIUtil.ImageSetBrushFromAssetPathSync(self.ImgIcon, DefaultIconPath)
end

function MapMarkerCommIconBaseView:OnRegisterUIEvent()

end

function MapMarkerCommIconBaseView:OnRegisterGameEvent()

end

function MapMarkerCommIconBaseView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerCommIconBaseView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerCommIconBaseView:IsUnderLocation(ScreenPosition)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if not MapMarker:GetIsEnableHitTest() then
		return false
	end

	local Result = UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
	if Result then
		self:PlayClickAnim()
	end

	return Result
end

function MapMarkerCommIconBaseView:UpdateColor()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	local BPType = MapMarker:GetBPType()
	if BPType == MapMarkerBPType.WorldIcon then
		-- 一级地图标题，用蓝图里默认的显示
		return
	end

	local TextName = self.TextName
	local ColorHex, OutlineColorHex, FontSize = MapUtil.GetCommMarkerTextColor(MapMarker)

	UIUtil.TextBlockSetColorAndOpacityHex(TextName, ColorHex)
	UIUtil.TextBlockSetOutlineColorAndOpacityHex(TextName, OutlineColorHex)
	UIUtil.TextBlockSetFontSize(TextName, FontSize)

	local LineColor = TextName.Font.OutlineSettings.OutlineColor
	LineColor.A = ViewModel.Alpha
	UIUtil.TextBlockSetOutlineColorAndOpacity(TextName, LineColor.R, LineColor.G, LineColor.B, LineColor.A )
	TextName:SetOpacity(ViewModel.Alpha)
end

function MapMarkerCommIconBaseView:UpdateIcon()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	-- 这几个蓝图里，图标尺寸会根据策划配置动态修改，对应响应区域、中心点都得同步修改
	local BPType = MapMarker:GetBPType()
	if BPType == MapMarkerBPType.CommIconLeft or BPType == MapMarkerBPType.CommIconRight
		or BPType == MapMarkerBPType.CommIconTop or BPType == MapMarkerBPType.CommIconBottom then
		local IconSize = FVector2D(64, 64)
		local IconScale = MapMarker.IconResize or 1
		IconSize = IconSize * IconScale
		UIUtil.CanvasSlotSetSize(self.ImgIcon, IconSize)

		local Position
		if BPType == MapMarkerBPType.CommIconLeft then
			Position = FVector2D(-IconSize.X / 2, 0)
		elseif BPType == MapMarkerBPType.CommIconRight then
			Position = FVector2D(IconSize.X / 2, 0)
		elseif BPType == MapMarkerBPType.CommIconTop then
			Position = FVector2D(0, -IconSize.Y / 2)
		elseif BPType == MapMarkerBPType.CommIconBottom then
			Position = FVector2D(0, IconSize.Y / 2)
		end
		UIUtil.CanvasSlotSetPosition(self.PanelAlignment, Position)
		--UIUtil.SetIsVisible(self.BtnRegion, true, true)
	end
end

-- 标记扩展图标，部分标记用到
function MapMarkerCommIconBaseView:UpdateExtraIcon()
	if self.ImgTextBG == nil or self.PanelIconS == nil or self.ImgSmallIcon == nil then
		return
	end

	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end
	---@type MapMarkerFixedPoint
	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	local ExtraIcon1Empty = string.isnilorempty(MapMarker.ExtraIconPath1)
	local ExtraIcon2Empty = string.isnilorempty(MapMarker.ExtraIconPath2)
	if (ExtraIcon1Empty and ExtraIcon2Empty) or not MapMarker:IsNameVisible(ViewModel.Scale)  then
		UIUtil.SetIsVisible(self.ImgTextBG, false)
		UIUtil.SetIsVisible(self.PanelIconS, false)
		UIUtil.SetIsVisible(self.PanelIconS02, false)
	else
		UIUtil.SetIsVisible(self.ImgTextBG, true)

		-- 标记扩展图标路径1
		if not ExtraIcon1Empty then
			UIUtil.SetIsVisible(self.PanelIconS, true)
			UIUtil.ImageSetBrushFromAssetPath(self.ImgSmallIcon, MapMarker.ExtraIconPath1)
		else
			UIUtil.SetIsVisible(self.PanelIconS, false)
		end

		-- 标记扩展图标路径2
		if not ExtraIcon2Empty then
			UIUtil.SetIsVisible(self.PanelIconS02, true)
			UIUtil.ImageSetBrushFromAssetPath(self.ImgSmallIcon02, MapMarker.ExtraIconPath2)
		else
			UIUtil.SetIsVisible(self.PanelIconS02, false)
		end
	end
end

-- 地图缩放比例变化时，标记点名字可见跟着变化，从而标记扩展图标要跟着变化
function MapMarkerCommIconBaseView:OnValueChangedNameVisibility(NewValue)
	self:UpdateExtraIcon()
end

function MapMarkerCommIconBaseView:OnFollowStateChange(NewValue)
	if NewValue then
		if self.TrackAnimView then
			self.TrackAnimView:PlayAnimLoop()
		else
			local View = MapUtil.CreateTrackAnimView()
			if self.PanelTrack then
				self.PanelTrack:AddChild(View)
				self.TrackAnimView = View
				self.TrackAnimView:PlayAnimLoop()
			end
		end
	else
		if self.TrackAnimView then
			self.TrackAnimView:StopAnimLoop()
		end
	end
end

function MapMarkerCommIconBaseView:PlayHighlightEffect()
	if self.HighlightAnimView == nil then
		local View = MapUtil.CreateHighlightAnimView()
		if self.PanelTrack then
			self.PanelTrack:AddChild(View)
			self.HighlightAnimView = View
		end
	end
	if self.HighlightAnimView then
		self.HighlightAnimView:PlayAnimIn()
	end
end

function MapMarkerCommIconBaseView:PlayClickAnim()
	if self.AnimClick then
		self:PlayAnimation(self.AnimClick)
	end
end

return MapMarkerCommIconBaseView