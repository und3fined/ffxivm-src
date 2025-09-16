---
--- Author: Administrator
--- DateTime: 2024-07-08 14:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

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

---@class PhotoSetUpPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRotate UFButton
---@field ImgRotateLight UFImage
---@field ImgScaleNumberBG UFImage
---@field ImgScaleNumberBG02 UFImage
---@field PanelRotate UFCanvasPanel
---@field TextScaleNumber UFTextBlock
---@field TouchItem PhotoTouchItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoSetUpPanelView = LuaClass(UIView, true)

function PhotoSetUpPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRotate = nil
	--self.ImgRotateLight = nil
	--self.ImgScaleNumberBG = nil
	--self.ImgScaleNumberBG02 = nil
	--self.PanelRotate = nil
	--self.TextScaleNumber = nil
	--self.TouchItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoSetUpPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.TouchItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoSetUpPanelView:OnInit()
	PhotoCamVM = _G.PhotoCamVM

	self.BinderCamera = 
	{
		{ "CurAngle", 			UIBinderSetRenderTransformAngle.New(self, self.RotNode) },
		{ "UnitText", 			UIBinderSetText.New(self, self.TextScaleNumber) },
		{ "UnitText", 			UIBinderSetText.New(self, self.TextScaleNumber_1) },
		{ "IsShowActiveArw", 	UIBinderSetIsVisible.New(self, self.ImgScaleNumberBG02) },
	}

	self.BinderPhotoVM = 
	{
		{ "SubTabIdx", 			UIBinderValueChangedCallback.New(self, nil, self.OnBindTabSubIdx) },
	}

	self:InitTouchItem()
end

function PhotoSetUpPanelView:OnDestroy()

end

function PhotoSetUpPanelView:OnShow()
	self:UpdCamUI()
	UIUtil.SetIsVisible(self.ImgRotateLight, false)
end

function PhotoSetUpPanelView:UpdCamUI()
	PhotoCamVM:ResetCurUnit()
end

function PhotoSetUpPanelView:OnHide()

end

function PhotoSetUpPanelView:OnRegisterUIEvent()

end

function PhotoSetUpPanelView:OnRegisterGameEvent()

end

function PhotoSetUpPanelView:OnRegisterBinder()
	self:RegisterBinders(_G.PhotoVM, 				self.BinderPhotoVM)
	self:RegisterBinders(PhotoCamVM, 			self.BinderCamera)
end

function PhotoSetUpPanelView:InitTouchItem()
	self.TouchItem.View = self
	self.TouchItem.TouchStartCB = self.OnTouchStart
	self.TouchItem.TouchMoveCB = self.OnTouchMove
	self.TouchItem.TouchEndCB = self.OnTouchEnd

	self.TouchDelY = 0
	self.TouchY = 0
end

function PhotoSetUpPanelView:OnTouchStart(Pos)
	self.TouchDelY = 0
	self.TouchY = Pos.Y
	UIUtil.SetIsVisible(self.ImgRotateLight, true)
	UIUtil.SetIsVisible(self.PanelScaleNumber, false)
	UIUtil.SetIsVisible(self.PanelScaleNumber02, true)


	-- _G.FLOG_INFO('Andre.PhotoMainView:OnTouchStart X = ' .. tostring(Pos.X) .. " Y = " .. tostring(Pos.Y))
end

function PhotoSetUpPanelView:OnTouchMove(Pos)
	self.TouchDelY = Pos.Y - self.TouchY
	self.TouchY = Pos.Y

	local TouchYToUnit = PhotoDefine.TouchY2Unit

	local DelUnit = self.TouchDelY / TouchYToUnit
	-- self.TouchDelY = self.TouchDelY - DelUnit * TouchYToUnit

	PhotoCamVM:AddUnit(-DelUnit)
end

function PhotoSetUpPanelView:OnTouchEnd(Pos)
	self.TouchDelY = 0
	self.TouchY = 0
	UIUtil.SetIsVisible(self.ImgRotateLight, false)
	UIUtil.SetIsVisible(self.PanelScaleNumber, true)
	UIUtil.SetIsVisible(self.PanelScaleNumber02, false)
end

function PhotoSetUpPanelView:OnBindTabSubIdx()
	self:UpdCamUI()
end

return PhotoSetUpPanelView