---
--- Author: anypkvcai
--- DateTime: 2022-03-22 20:53
--- Description:
---弃用，待删除

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetItemColor = require("Binder/UIBinderSetItemColor")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetItemMicroIcon = require("Binder/UIBinderSetItemMicroIcon")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")


---@class ItemTipsContentView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonCraftInfo UFButton
---@field ButtonMagicspar UFButton
---@field ButtonStatus UFButton
---@field CommGetWayTips_UIBP CommGetWayTipsView
---@field EFF_Flowcomplex_Inst UFImage
---@field FButton_GetWay UFButton
---@field FImg_Slot01 UFImage
---@field FImg_Slot02 UFImage
---@field FImg_Slot03 UFImage
---@field FImg_Slot04 UFImage
---@field FImg_Slot05 UFImage
---@field HorizontalBox_0 UHorizontalBox
---@field IConItemGrade UFImage
---@field ImageBind UFImage
---@field ImageHQ UFImage
---@field ImageIcon UFImage
---@field ImageQuality UFImage
---@field ImageUnique UFImage
---@field JobBar UFCanvasPanel
---@field JobType URichTextBox
---@field LevelBar_1 UFCanvasPanel
---@field LevelNumber URichTextBox
---@field LevelPanel UFCanvasPanel
---@field P_EFF_Particle_001_C_6 UUIParticleEmitter
---@field PanelDesc UFCanvasPanel
---@field PanelEquipment UFCanvasPanel
---@field PanelMagicspar UFCanvasPanel
---@field PanelRoot UFCanvasPanel
---@field ProfSimpleIcon UFImage
---@field RichTextTextLevel URichTextBox
---@field ScrollBox_47 UScrollBox
---@field SizeBoxInfo USizeBox
---@field Status UFHorizontalBox
---@field TableViewMsg UTableView
---@field Text UFTextBlock
---@field TextAnd UFTextBlock
---@field TextDesc UFTextBlock
---@field TextHQNum UFTextBlock
---@field TextHeadingDesc UFTextBlock
---@field TextJob UFTextBlock
---@field TextLevel UFTextBlock
---@field TextLevelName UFTextBlock
---@field TextLv UFTextBlock
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---@field TextTypeName UFTextBlock
---@field ToggleBtnFavorite UToggleButton
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsContentView = LuaClass(UIView, true)

function ItemTipsContentView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonCraftInfo = nil
	--self.ButtonMagicspar = nil
	--self.ButtonStatus = nil
	--self.CommGetWayTips_UIBP = nil
	--self.EFF_Flowcomplex_Inst = nil
	--self.FButton_GetWay = nil
	--self.FImg_Slot01 = nil
	--self.FImg_Slot02 = nil
	--self.FImg_Slot03 = nil
	--self.FImg_Slot04 = nil
	--self.FImg_Slot05 = nil
	--self.HorizontalBox_0 = nil
	--self.IConItemGrade = nil
	--self.ImageBind = nil
	--self.ImageHQ = nil
	--self.ImageIcon = nil
	--self.ImageQuality = nil
	--self.ImageUnique = nil
	--self.JobBar = nil
	--self.JobType = nil
	--self.LevelBar_1 = nil
	--self.LevelNumber = nil
	--self.LevelPanel = nil
	--self.P_EFF_Particle_001_C_6 = nil
	--self.PanelDesc = nil
	--self.PanelEquipment = nil
	--self.PanelMagicspar = nil
	--self.PanelRoot = nil
	--self.ProfSimpleIcon = nil
	--self.RichTextTextLevel = nil
	--self.ScrollBox_47 = nil
	--self.SizeBoxInfo = nil
	--self.Status = nil
	--self.TableViewMsg = nil
	--self.Text = nil
	--self.TextAnd = nil
	--self.TextDesc = nil
	--self.TextHQNum = nil
	--self.TextHeadingDesc = nil
	--self.TextJob = nil
	--self.TextLevel = nil
	--self.TextLevelName = nil
	--self.TextLv = nil
	--self.TextName = nil
	--self.TextNum = nil
	--self.TextTypeName = nil
	--self.ToggleBtnFavorite = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsContentView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommGetWayTips_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsContentView:OnInit()
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewMsg)

	self.Binders = {
		{ "IsBind", UIBinderSetIsVisible.New(self, self.ImageBind) },
		{ "IsHQNumVisible", UIBinderSetIsVisible.New(self, self.ImageHQ) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImageIcon) },
		{ "IsUnique", UIBinderSetIsVisible.New(self, self.ImageUnique) },
		{ "IsAndVisible", UIBinderSetIsVisible.New(self, self.TextAnd) },
		{ "TypeName", UIBinderSetText.New(self, self.TextTypeName) },
		{ "Num", UIBinderSetTextFormat.New(self, self.TextNum, "%d") },
		{ "IsNumVisible", UIBinderSetIsVisible.New(self, self.TextHQNum) },
		{ "HQNum", UIBinderSetTextFormat.New(self, self.TextHQNum, "%d") },
		{ "IsHQNumVisible", UIBinderSetIsVisible.New(self, self.TextHQNum) },
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "LevelName", UIBinderSetText.New(self, self.TextLevelName) },
		{ "LevelText", UIBinderSetText.New(self, self.TextLevel) },
		{ "ItemColor", UIBinderSetItemColor.New(self, self.ImageQuality) },
		{ "IsShowLevel", UIBinderSetIsVisible.New(self, self.LevelPanel) },
		{ "Desc", UIBinderSetText.New(self, self.TextDesc) },
		{ "PanelDescVisible", UIBinderSetIsVisible.New(self, self.PanelDesc) },
		{ "InHeadingDescVisible", UIBinderSetIsVisible.New(self, self.TextHeadingDesc) },
		{ "IsEquipment", UIBinderSetIsVisible.New(self, self.PanelMagicspar, nil, true) },
		{ "InfoLstVisible", UIBinderSetIsVisible.New(self, self.TableViewMsg, nil, false) },
		{ "BindableListInfo", UIBinderUpdateBindableList.New(self, self.AdapterTableView) },
		{ "StatusButtonVisible", UIBinderSetIsVisible.New(self, self.ButtonStatus, false, true) },

		{ "EquipName", UIBinderSetText.New(self, self.TextName) },
		{ "EquipType", UIBinderSetText.New(self, self.TextTypeName) },
		{ "ProfNameTitle", UIBinderSetText.New(self, self.TextLevelName) },
		{ "ItemLevel", UIBinderSetText.New(self, self.RichTextTextLevel) },
		{ "ProfName", UIBinderSetText.New(self, self.JobType) },
		{ "ProfSimpleIcon", UIBinderSetBrushFromAssetPath.New(self, self.ProfSimpleIcon)},
		{ "Grade",  UIBinderSetText.New(self, self.LevelNumber) },
		{ "Slot01", UIBinderSetItemMicroIcon.New(self, self.FImg_Slot01) },
		{ "Slot02", UIBinderSetItemMicroIcon.New(self, self.FImg_Slot02) },
		{ "Slot03", UIBinderSetItemMicroIcon.New(self, self.FImg_Slot03) },
		{ "Slot04", UIBinderSetItemMicroIcon.New(self, self.FImg_Slot04) },
		{ "Slot05", UIBinderSetItemMicroIcon.New(self, self.FImg_Slot05) },

		{ "IsShowGetway", UIBinderSetIsVisible.New(self, self.FButton_GetWay, false , true, true)},
		{ "IsShowHorizontalBox", UIBinderSetIsVisible.New(self, self.HorizontalBox_0) },
		{ "IsShowItemGrade", UIBinderSetIsVisible.New(self, self.IConItemGrade) },
		{ "IsShowFavorite", UIBinderSetIsVisible.New(self, self.ToggleBtnFavorite, false, true) },
		{ "FavoriteToggle", UIBinderSetIsChecked.New(self, self.ToggleBtnFavorite) },
		{ "IsShowStatus", UIBinderSetIsVisible.New(self, self.Status) },
	}

end

function ItemTipsContentView:OnDestroy()

end

function ItemTipsContentView:OnShow()
	if self.AnimSelect ~= nil then
		self:PlayAnimation(self.AnimSelect)
	end
	if self.Params ~= nil and self.Params.GetAccessOffset ~= nil then
		local GetAccessOffset = self.Params.GetAccessOffset
		UIUtil.CanvasSlotSetPosition(self.CommGetWayTips_UIBP, _G.UE.FVector2D(GetAccessOffset[1], GetAccessOffset[2]))
	end
	if self.ScrollBox_47 then
		self.ScrollBox_47:ScrollToStart()
	end
end

function ItemTipsContentView:OnHide()
	_G.UIViewMgr:HideView(_G.UIViewID.ItemTipsStatus)
	UIUtil.SetIsVisible(self.CommGetWayTips_UIBP, false)
end

function ItemTipsContentView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonStatus, self.OnClickedStatus)
	UIUtil.AddOnClickedEvent(self, self.FButton_GetWay, self.OnClickedGetWay)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnFavorite, self.OnBtnFavoriteClick)
end

function ItemTipsContentView:OnRegisterGameEvent()

end

function ItemTipsContentView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.ViewModel
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel
	self.Source = ViewModel.Source

	
	self:RegisterBinders(ViewModel, self.Binders)
end

function ItemTipsContentView:OnClickedStatus()
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.ItemTipsStatus) then
		_G.UIViewMgr:HideView(_G.UIViewID.ItemTipsStatus)
	else
		local ClickPos = _G.UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(FWORLD())
		local Params = { ViewModel = self.ViewModel, ItemView = self.PanelRoot, ClickPos = ClickPos }
		_G.UIViewMgr:ShowView(_G.UIViewID.ItemTipsStatus, Params)
	end
end

function ItemTipsContentView:OnClickedGetWay()
	if UIUtil.IsVisible(self.CommGetWayTips_UIBP) then
		UIUtil.SetIsVisible(self.CommGetWayTips_UIBP, false)
	else
		UIUtil.SetIsVisible(self.CommGetWayTips_UIBP, true)
	end

end

function ItemTipsContentView:OnBtnFavoriteClick(ToggleButton, ButtonState)
	if self.ViewModel.OnBtnFavoriteClick then
		self.ViewModel:OnBtnFavoriteClick(ButtonState)
	end
end

return ItemTipsContentView