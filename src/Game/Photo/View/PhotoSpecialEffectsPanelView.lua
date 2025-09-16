---
--- Author: Administrator
--- DateTime: 2024-07-08 14:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")

local PhotoDefine = require("Game/Photo/PhotoDefine")
local PhotoMgr
local FVector2D = _G.UE.FVector2D
local PhotoVM
local PhotoCamVM
local PhotoFilterVM
local PhotoDarkEdgeVM
local PhotoRoleSettingVM
local PhotoSceneVM
local PhotoTemplateVM
local PhotoActionVM
local PhotoEmojiVM
local PhotoRoleStatVM

local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

local EDGE_MAX = 450

local AreaType = {
	Scale = 1,
	High = 2,
}

local TouchType = {
	Start = 1,
	End = 2,
}

---@class PhotoSpecialEffectsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgColor UFImage
---@field ImgMore UFImage
---@field PanelBtnScale UFCanvasPanel
---@field PanelColor UFCanvasPanel
---@field PanelColorProbar UFCanvasPanel
---@field PanelEffectsCircle UFCanvasPanel
---@field PanelMore UFCanvasPanel
---@field Slider_1 USlider
---@field Slider_2 USlider
---@field Slider_3 USlider
---@field TouchDarkEdge PhotoTouchItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoSpecialEffectsPanelView = LuaClass(UIView, true)

function PhotoSpecialEffectsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgColor = nil
	--self.ImgMore = nil
	--self.PanelBtnScale = nil
	--self.PanelColor = nil
	--self.PanelColorProbar = nil
	--self.PanelEffectsCircle = nil
	--self.PanelMore = nil
	--self.Slider_1 = nil
	--self.Slider_2 = nil
	--self.Slider_3 = nil
	--self.TouchDarkEdge = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoSpecialEffectsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.TouchDarkEdge)
	self:AddSubView(self.TouchDarkHightEdge)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoSpecialEffectsPanelView:OnInit()
	self.FTextBlock_119:SetText(_G.LSTR(630051))
	PhotoDarkEdgeVM = _G.PhotoDarkEdgeVM
	self.BinderDarkEdge = 
	{
		{ "RedValue", 		UIBinderSetSlider.New(self, self.Slider_1) },
		{ "GreenValue", 	UIBinderSetSlider.New(self, self.Slider_2) },
		{ "BlueValue", 		UIBinderSetSlider.New(self, self.Slider_3) },

		{ "OffInfo", 	UIBinderValueChangedCallback.New(self, nil, self.OnOffsetChg) },
		{ "ResetOPFlag", 	UIBinderValueChangedCallback.New(self, nil, self.ResetOP) },
		{ "Aspect", 		UIBinderSetText.New(self, self.TextAspect, function(v) 
			return _G.LSTR(630039) .. tostring(v)
		end) },

		{ "Power", 		UIBinderSetText.New(self, self.TextPower, function(v) 
			return _G.LSTR(630040) .. tostring(v)
		end) },
	}

	self:InitTouchDarkEdge()
end


function PhotoSpecialEffectsPanelView:InitTouchDarkEdge()
	self.TouchDarkEdge.View = self
	self.TouchDarkEdge.TouchStartCB = function(_, Pos)
		self:OnTouchStartDarkEdge(self.TouchDarkEdge, Pos)
	end
	
	self.TouchDarkEdge.TouchMoveCB = self.OnTouchMoveDarkEdge
	self.TouchDarkEdge.TouchEndCB = self.OnTouchEndDarkEdge

	self.TouchDarkEdge.CapCondFunc = function(_, Pos)
		return self:CheckPostion(self.TouchDarkEdge, Pos)
	end

	-- self.TouchDarkHightEdge.View = self
	-- self.TouchDarkHightEdge.TouchStartCB = function(_, Pos)
	-- 	self:OnTouchStartDarkEdge(self.TouchDarkHightEdge, Pos)
	-- end
	-- self.TouchDarkHightEdge.TouchMoveCB = self.OnTouchMoveDarkEdge
	-- self.TouchDarkHightEdge.TouchEndCB = self.OnTouchEndDarkEdge
	

	self.TouchDarkEdgeCenter = FVector2D(EDGE_MAX, EDGE_MAX)
	self.DarkEdgeMin = 200
	self.DarkEdgeMax = EDGE_MAX
	self.DarkEdgeArrowSize = 0
end

function PhotoSpecialEffectsPanelView:OnDestroy()

end

function PhotoSpecialEffectsPanelView:OnShow()
	self:SetTouchBtnState(nil, TouchType.End)
end

function PhotoSpecialEffectsPanelView:OnHide()

end

function PhotoSpecialEffectsPanelView:OnRegisterUIEvent()
	UIUtil.AddOnValueChangedEvent(self, 		self.Slider_1, 				self.OnValueChangedRedSlider)
	UIUtil.AddOnValueChangedEvent(self, 		self.Slider_2, 				self.OnValueChangedGreenSlider)
	UIUtil.AddOnValueChangedEvent(self, 		self.Slider_3, 				self.OnValueChangedBlueSlider)
end

function PhotoSpecialEffectsPanelView:OnRegisterGameEvent()
end

function PhotoSpecialEffectsPanelView:OnRegisterBinder()
	self:RegisterBinders(PhotoDarkEdgeVM, 		self.BinderDarkEdge)
end

function PhotoSpecialEffectsPanelView:OnOffsetChg(Value)
	if not Value or table.empty(Value) then
		return
	end

	local Asp = Value.Asp
	local Rad = Value.Rad

	local OffsetH = self.DarkEdgeMax - Rad --w
	local OffsetV = self.DarkEdgeMax - Rad / Asp --h

	if OffsetV < 0 then
		OffsetV = 0
	end

	if OffsetH < 0 then
		OffsetH = 0
	end

	local Offsets = UIUtil.CanvasSlotGetOffsets(self.PanelEffectsCircle)
	if nil == Offsets then
		return
	end

	Offsets.Left = OffsetH
	Offsets.Right = OffsetH
	Offsets.Top = OffsetV
	Offsets.Bottom = OffsetV
	
	UIUtil.CanvasSlotSetOffsets(self.PanelTopRight, Offsets)
	UIUtil.CanvasSlotSetOffsets(self.PanelDown, Offsets)
	UIUtil.CanvasSlotSetOffsets(self.PanelEffectsCircle, Offsets)

	self:UpdMaskMat()
end

function PhotoSpecialEffectsPanelView:ResetOP(Value)
	if Value then
		local Offsets = UIUtil.CanvasSlotGetOffsets(self.PanelEffectsCircle)
		if nil == Offsets then
			return
		end
		local Offset = 0
		Offsets.Left = Offset
		Offsets.Right = Offset
		Offsets.Top = Offset
		Offsets.Bottom = Offset
		
		UIUtil.CanvasSlotSetOffsets(self.PanelTopRight, Offsets)
		UIUtil.CanvasSlotSetOffsets(self.PanelDown, Offsets)
		UIUtil.CanvasSlotSetOffsets(self.PanelEffectsCircle, Offsets)

		-- local Offsets = UIUtil.CanvasSlotGetOffsets(self.PanelEffectsCircle)
		-- if nil == Offsets then
		-- 	return
		-- end

		self:UpdMaskMat()

		PhotoDarkEdgeVM.ResetOPFlag = false
	end
end

function PhotoSpecialEffectsPanelView:OnValueChangedRedSlider(_, Value)
	PhotoDarkEdgeVM:SetRedValue(Value)
	_G.PhotoMgr:UpdateDarkEdgeEffect()
end

function PhotoSpecialEffectsPanelView:OnValueChangedGreenSlider(_, Value)
	PhotoDarkEdgeVM:SetGreenValue(Value)
	_G.PhotoMgr:UpdateDarkEdgeEffect()
end

function PhotoSpecialEffectsPanelView:OnValueChangedBlueSlider(_, Value)
	PhotoDarkEdgeVM:SetBlueValue(Value)
	_G.PhotoMgr:UpdateDarkEdgeEffect()
end

function PhotoSpecialEffectsPanelView:CheckPostion(TouchItem, Pos)
	local ScreenPosition = UIUtil.LocalToAbsolute(TouchItem, Pos)
	
	if UIUtil.IsUnderLocation(self.PanelMore, ScreenPosition) == true then
		return true
	elseif UIUtil.IsUnderLocation(self.PanelColor, ScreenPosition) == true then
		return true
	end

	return false
end




function PhotoSpecialEffectsPanelView:SetTouchBtnState(InAreaType, InTouchType)

	UIUtil.SetIsVisible(self.PanelMore, InTouchType == TouchType.End)
	UIUtil.SetIsVisible(self.PanelColor, InTouchType == TouchType.End)

	UIUtil.SetIsVisible(self.PanelSelect, InAreaType == AreaType.Scale and InTouchType == TouchType.Start)
	UIUtil.SetIsVisible(self.PanelGrey01, InAreaType == AreaType.Scale and InTouchType == TouchType.Start)
	
	UIUtil.SetIsVisible(self.PanelMoreSelect, InAreaType == AreaType.High and InTouchType == TouchType.Start)
	UIUtil.SetIsVisible(self.PanelGrey, InAreaType == AreaType.High and InTouchType == TouchType.Start)

end

function PhotoSpecialEffectsPanelView:OnTouchStartDarkEdge(TouchItem, Pos)
	local ScreenPosition = UIUtil.LocalToAbsolute(TouchItem, Pos)
	self.ScaleHightActivation = false
	self.ScaleAllActivation = false
	if UIUtil.IsUnderLocation(self.PanelMore, ScreenPosition) == true then
		self.ScaleHightActivation = true
		self:SetTouchBtnState(AreaType.High, TouchType.Start)
	elseif UIUtil.IsUnderLocation(self.PanelColor, ScreenPosition) == true then
		self.ScaleAllActivation = true
		self:SetTouchBtnState(AreaType.Scale, TouchType.Start)
	end
end

function PhotoSpecialEffectsPanelView:OnTouchMoveDarkEdge(Pos)
	-- print(string.format('OnTouchMoveDarkEdge Pos = %s, %s', tostring(Pos.X), tostring(Pos.Y)))
	if self.ScaleHightActivation == true then
		self:UpdateScaleHightDarkEdgeUI(Pos)	
	elseif self.ScaleAllActivation == true then
		self:UpdateScaleAllDarkEdgeUI(Pos)
	end
end

function PhotoSpecialEffectsPanelView:UpdMaskMat()
	local Offsets = UIUtil.CanvasSlotGetOffsets(self.PanelEffectsCircle)
	if nil == Offsets then
		return
	end

	PhotoDarkEdgeVM:SetDarkEdgeSize(Offsets.Right / (self.DarkEdgeMax - self.DarkEdgeMin), Offsets.Top / (self.DarkEdgeMax - self.DarkEdgeMin) )
	_G.PhotoMgr:UpdateDarkEdgeEffect()
end

function PhotoSpecialEffectsPanelView:UpdateScaleAllDarkEdgeUI(Pos)
	local Radius = math.sqrt((Pos.X - self.TouchDarkEdgeCenter.X)*(Pos.X - self.TouchDarkEdgeCenter.X)+ (Pos.Y - self.TouchDarkEdgeCenter.Y)*(Pos.Y - self.TouchDarkEdgeCenter.Y)) - self.DarkEdgeArrowSize
	local RadiusMax = self.DarkEdgeMax - self.DarkEdgeArrowSize
	local RadiusMin = self.DarkEdgeMin - self.DarkEdgeArrowSize
	if Radius < RadiusMin then
		Radius = RadiusMin
	end

	if Radius > RadiusMax then
		Radius = RadiusMax
	end

    -- UIUtil.CanvasSlotSetSize(self.PanelBtnScale, _G.UE.FVector2D(Size.X, Radius))

	local Power = (Radius - RadiusMin)/(RadiusMax - RadiusMin)
	PhotoDarkEdgeVM.Power = math.floor(Power * 10 + 0.5) / 10
	-- print('testinfo offset = ', tostring(Offset))
	-- local OR = Offsets.Right
	-- local HightOffR = Offset / OR

	-- local Offset = self.DarkEdgeMax - Radius - self.DarkEdgeArrowSize
	-- PhotoDarkEdgeVM.ScaleOffset = Offset

	PhotoDarkEdgeVM.OffInfo = {
		Rad = Radius,
		Asp = PhotoDarkEdgeVM.OffInfo.Asp or 1
	}
end

function PhotoSpecialEffectsPanelView:UpdateScaleHightDarkEdgeUI(Pos)
	local OffsetY = math.sqrt((Pos.X - self.TouchDarkEdgeCenter.X)*(Pos.X - self.TouchDarkEdgeCenter.X)+ (Pos.Y - self.TouchDarkEdgeCenter.Y)*(Pos.Y - self.TouchDarkEdgeCenter.Y))
	if OffsetY < self.DarkEdgeMin then
		OffsetY = self.DarkEdgeMin
	end

	if OffsetY > self.DarkEdgeMax then
		OffsetY = self.DarkEdgeMax
	end

	local Offset = self.DarkEdgeMax - OffsetY
	local Offsets = UIUtil.CanvasSlotGetOffsets(self.PanelEffectsCircle)
	if nil == Offsets then
		return
	end

	-- PhotoDarkEdgeVM.HighOffset = Offset

	local RadiusY = self.DarkEdgeMax - Offset
	local RadiusX = self.DarkEdgeMax - Offsets.Right

	local RadiusMax = self.DarkEdgeMax - self.DarkEdgeArrowSize
	local RadiusMin = self.DarkEdgeMin - self.DarkEdgeArrowSize
	if RadiusY < RadiusMin then
		RadiusY = RadiusMin
	end

	if RadiusY > RadiusMax then
		RadiusY = RadiusMax
	end

	if RadiusX < RadiusMin then
		RadiusX = RadiusMin
	end

	if RadiusX > RadiusMax then
		RadiusX = RadiusMax
	end

	local Aspect = RadiusX/RadiusY

	PhotoDarkEdgeVM.OffInfo = {
		Rad = PhotoDarkEdgeVM.OffInfo.Rad or 450,
		Asp = Aspect
	}

	PhotoDarkEdgeVM.Aspect = math.floor(Aspect * 10 + 0.5) / 10

	-- if RadiusY > RadiusX then
	-- 	local Size = UIUtil.CanvasSlotGetSize(self.PanelBtnScale)
    -- 	UIUtil.CanvasSlotSetSize(self.PanelBtnScale, _G.UE.FVector2D(Size.X, RadiusX))
	-- else
	-- 	local Size = UIUtil.CanvasSlotGetSize(self.PanelBtnScale)
    -- 	UIUtil.CanvasSlotSetSize(self.PanelBtnScale, _G.UE.FVector2D(Size.X, RadiusY))
	-- end

end

function PhotoSpecialEffectsPanelView:OnTouchEndDarkEdge(Pos)
	self:SetTouchBtnState(self.ScaleHightActivation and AreaType.High or AreaType.Scale, TouchType.End)

	self.ScaleHightActivation = false
	self.ScaleAllActivation = false

end

return PhotoSpecialEffectsPanelView