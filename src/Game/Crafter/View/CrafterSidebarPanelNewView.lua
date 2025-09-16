---
--- Author: henghaoli
--- DateTime: 2024-09-09 15:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

local UIBinderCanvasSlotSetSize = require("Binder/UIBinderCanvasSlotSetSize")
local MajorUtil = require("Utils/MajorUtil")
local UIViewID = require("Define/UIViewID")

local ProtoCS = require("Protocol/ProtoCS")
local TipsUtil = require("Utils/TipsUtil")

local StartPercent = 0.01
local EndPercent = 0.99

---@class CrafterSidebarPanelNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnShowCrafterDetails UFButton
---@field CrafterProbarItem1 CrafterProbarItemView
---@field CrafterProbarItem2 CrafterProbarItemView
---@field CrafterProbarItem3 CrafterProbarItemView
---@field CrafterTitleItem CrafterTitleItemView
---@field FHorizontalFrequency UFCanvasPanel
---@field FHorizontalNum UFCanvasPanel
---@field FHorizontalValue UFCanvasPanel
---@field ImgCollect2 UFImage
---@field ImgSidebarBg UFImage
---@field ImgSidebarBg2 UFImage
---@field ImgSidebarLine1 UFImage
---@field ImgSidebarLine2 UFImage
---@field ItemSlot CommBackpack96SlotView
---@field MajorInfo MainMajorInfoPanelView
---@field ProBaSchedule UProgressBar
---@field ProBarDurable UProgressBar
---@field ProBarQuality UProgressBar
---@field QualityPanel UFCanvasPanel
---@field RichTextDurable URichTextBox
---@field RichTextQuality URichTextBox
---@field RichTextSchedule URichTextBox
---@field TextDurable UFTextBlock
---@field TextFrequency UFTextBlock
---@field TextFrequencyNumber UFTextBlock
---@field TextName URichTextBox
---@field TextName_2 UFTextBlock
---@field TextNum UFTextBlock
---@field TextNum1 UFTextBlock
---@field TextQuality UFTextBlock
---@field TextSchedule UFTextBlock
---@field TextValue UFTextBlock
---@field TextValueNumber UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBarQuality UWidgetAnimation
---@field AnimProBarQualityControl UWidgetAnimation
---@field AnimProBarSchedule UWidgetAnimation
---@field AnimProBarScheduleControl UWidgetAnimation
---@field CurveAnimProgressBar CurveFloat
---@field ValueAnimProBarScheduleStart float
---@field ValueAnimProBarScheduleEnd float
---@field ValueAnimProBarQualityStart float
---@field ValueAnimProBarQualityEnd float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterSidebarPanelNewView = LuaClass(UIView, true)

function CrafterSidebarPanelNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnShowCrafterDetails = nil
	--self.CrafterProbarItem1 = nil
	--self.CrafterProbarItem2 = nil
	--self.CrafterProbarItem3 = nil
	--self.CrafterTitleItem = nil
	--self.FHorizontalFrequency = nil
	--self.FHorizontalNum = nil
	--self.FHorizontalValue = nil
	--self.ImgCollect2 = nil
	--self.ImgSidebarBg = nil
	--self.ImgSidebarBg2 = nil
	--self.ImgSidebarLine1 = nil
	--self.ImgSidebarLine2 = nil
	--self.ItemSlot = nil
	--self.MajorInfo = nil
	--self.ProBaSchedule = nil
	--self.ProBarDurable = nil
	--self.ProBarQuality = nil
	--self.QualityPanel = nil
	--self.RichTextDurable = nil
	--self.RichTextQuality = nil
	--self.RichTextSchedule = nil
	--self.TextDurable = nil
	--self.TextFrequency = nil
	--self.TextFrequencyNumber = nil
	--self.TextName = nil
	--self.TextName_2 = nil
	--self.TextNum = nil
	--self.TextNum1 = nil
	--self.TextQuality = nil
	--self.TextSchedule = nil
	--self.TextValue = nil
	--self.TextValueNumber = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProBarQuality = nil
	--self.AnimProBarQualityControl = nil
	--self.AnimProBarSchedule = nil
	--self.AnimProBarScheduleControl = nil
	--self.CurveAnimProgressBar = nil
	--self.ValueAnimProBarScheduleStart = nil
	--self.ValueAnimProBarScheduleEnd = nil
	--self.ValueAnimProBarQualityStart = nil
	--self.ValueAnimProBarQualityEnd = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterSidebarPanelNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CrafterProbarItem1)
	self:AddSubView(self.CrafterProbarItem2)
	self:AddSubView(self.CrafterProbarItem3)
	self:AddSubView(self.CrafterTitleItem)
	self:AddSubView(self.ItemSlot)
	self:AddSubView(self.MajorInfo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterSidebarPanelNewView:OnInit()
	local LSTR = _G.LSTR
	self.TextDurable:SetText(LSTR(150003))
	self.TextFrequency:SetText(LSTR(150004))
	self.TextNum:SetText(LSTR(150005))
	self.TextSchedule:SetText(LSTR(150007))
end

function CrafterSidebarPanelNewView:OnDestroy()

end

function CrafterSidebarPanelNewView:OnShow()
	-- self.RichTextDurable
	UIUtil.SetIsVisible(self.MajorInfo.BtnSwitch, false)
	UIUtil.SetIsVisible(self.TextName_2, false)  -- # TODO - 重构删除这个控件
	self:SetupItemSlot()
	self.CrafterTitleItem:SetTitleByProf()
end

function CrafterSidebarPanelNewView:OnHide()
	self:StopAllAnimations()
end

local Handled = _G.UE.UWidgetBlueprintLibrary.Handled()

function CrafterSidebarPanelNewView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnShowCrafterDetails, self.OnShowCrafterDetails)
	self.ImgSidebarBg.OnMouseButtonDownEvent:Bind(self.Object, function()
		return Handled
	end)
	UIUtil.AddOnClickedEvent(self, self.BtnDurable, self.OnShowCrafterTips,ProtoCS.FeatureType.FEATURE_TYPE_DURABILITY)
	UIUtil.AddOnClickedEvent(self, self.BtnSchedule, self.OnShowCrafterTips,ProtoCS.FeatureType.FEATURE_TYPE_PROGRESS)
	UIUtil.AddOnClickedEvent(self, self.BtnQuality, self.OnShowCrafterTips,ProtoCS.FeatureType.FEATURE_TYPE_QUALITY)
end

function CrafterSidebarPanelNewView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
end

function CrafterSidebarPanelNewView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local Binders = {
		-- {"ProfName", UIBinderSetText.New(self, self.TextArea)},
		{"RecipeName", UIBinderSetText.New(self, self.TextName)},
		{"ItemIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ItemSlot.Icon) },
		{"TextValue", UIBinderSetText.New(self, self.TextValue)},
		{"TextValueNumber", UIBinderSetText.New(self, self.TextValueNumber)},
        
		{"DurableBarSize", UIBinderCanvasSlotSetSize.New(self, self.ProBarDurable, true)},
		{ "DurableBar", UIBinderSetPercent.New(self, self.ProBarDurable) },
		{ "ProgressBar", UIBinderSetPercent.New(self, self.ProBaSchedule, StartPercent, EndPercent) },	--进度
		{ "QualityBar", UIBinderSetPercent.New(self, self.ProBarQuality, StartPercent, EndPercent) },	--进度
		{ "SetDurableFillColorType", UIBinderValueChangedCallback.New(self, nil, self.OnSetDurableFillColor) },

		{"OpCountText", UIBinderSetText.New(self, self.TextFrequencyNumber)},
		{"bProductionNumVisible", UIBinderSetIsVisible.New(self, self.FHorizontalNum)},
		{"ProductionNumText", UIBinderSetText.New(self, self.TextNum1)},
		{"RichTextDurableText", UIBinderSetText.New(self, self.RichTextDurable)},
		{"ProgressText", UIBinderSetText.New(self, self.RichTextSchedule)},
		{"QualityText", UIBinderSetText.New(self, self.RichTextQuality)},
		{"QualityTitle", UIBinderSetText.New(self, self.TextQuality)},
		
		{"bHorizontalValue", UIBinderSetIsVisible.New(self, self.FHorizontalValue)},
		{"bQualityPanel", UIBinderSetIsVisible.New(self, self.QualityPanel)},
		
		--是否收藏品
		{"bShowImgCollect", UIBinderSetIsVisible.New(self, self.ImgCollect2)},
		{"bShowImgCollect", UIBinderSetIsVisible.New(self, self.CrafterProbarItem1)},
		{"bShowImgCollect", UIBinderSetIsVisible.New(self, self.CrafterProbarItem2)},
		{"bShowImgCollect", UIBinderSetIsVisible.New(self, self.CrafterProbarItem3)},
		{"bShowImgCollect", UIBinderSetIsVisible.New(self, self.CollectTopPanel)},
		{ "SetImgQualityPos", UIBinderValueChangedCallback.New(self, nil, self.OnSetImgQualityPos) },
		{"CollectTextBlue", UIBinderSetText.New(self, self.TextBlue)},
		{"CollectTextYellow", UIBinderSetText.New(self, self.TextYellow)},
		{"CollectTextGreen", UIBinderSetText.New(self, self.TextGreen)},
		{ "CollectAnimType", UIBinderValueChangedCallback.New(self, nil, self.OnCollectAnimType) },

	}

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, Binders)

end

function CrafterSidebarPanelNewView:OnShowCrafterDetails()
	local UIViewMgr = _G.UIViewMgr
	UIViewMgr:ShowView(UIViewID.CrafterDetailsPanel)
end

local ProbarItemNum <const> = 3

function CrafterSidebarPanelNewView:ResetCollectAnim()
	for i = 1, ProbarItemNum do
		local Item = self["CrafterProbarItem" .. i]
		if Item then
			Item:ResetAnimLightIn()
		end
	end
end

function CrafterSidebarPanelNewView:OnCollectAnimType(AnimType, LastAnimType)
	if AnimType == 0 then
		self:ResetCollectAnim()
		return
	end

	if LastAnimType == nil then
		LastAnimType = 0
		self:ResetCollectAnim()
	end

	if LastAnimType >= AnimType then
		FLOG_ERROR("[CrafterSidebarPanelNewView:OnCollectAnimType] AnimType not valid!")
		return
	end

	for i = LastAnimType + 1, AnimType do
		local Item = self["CrafterProbarItem" .. i]
		Item:PlayAnimLightIn()
	end
end

function CrafterSidebarPanelNewView:OnSetDurableFillColor(FillColorType)
	if FillColorType == 1 then
		UIUtil.ProgressBarSetFillImage(self.ProBarDurable, "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Img_ConditionBlue.UI_Crafter_Img_ConditionBlue'")
	elseif FillColorType == 2 then
		UIUtil.ProgressBarSetFillImage(self.ProBarDurable, "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Img_ConditionYellow.UI_Crafter_Img_ConditionYellow'")
	elseif FillColorType == 3 then
		UIUtil.ProgressBarSetFillImage(self.ProBarDurable, "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Img_ConditionRed.UI_Crafter_Img_ConditionRed'")
	end
end

local CollectionBarXMin <const> = -10
local CollectionBarXMax <const> = 290
local CollectionBarWidth <const> = CollectionBarXMax - CollectionBarXMin
local CollectionBarYPos <const> = -3
local FVector2D <const> = _G.UE.FVector2D

local function SetCollectionBarPosAndText(MaxQuality, Item, Value)
	Item.CollectValue = Value
	local X = CollectionBarWidth * Value / MaxQuality
	UIUtil.CanvasSlotSetPosition(Item, FVector2D(X + CollectionBarXMin, CollectionBarYPos))
	Item.TextBlue:SetText(tostring(Value) .. "~")
end

function CrafterSidebarPanelNewView:OnSetImgQualityPos(CollectValues)
	if CollectValues and #CollectValues >= 3 then
		local MaxQuality = self.ViewModel.QualityMax

		SetCollectionBarPosAndText(MaxQuality, self.CrafterProbarItem1, CollectValues[1])
		SetCollectionBarPosAndText(MaxQuality, self.CrafterProbarItem2, CollectValues[2])
		SetCollectionBarPosAndText(MaxQuality, self.CrafterProbarItem3, CollectValues[3])
	end
end

function CrafterSidebarPanelNewView:OnEventCrafterSkillRsp(MsgBody)
    if MsgBody and MsgBody.CrafterSkill then
        local MajorEntityID = MajorUtil.GetMajorEntityID()
		if MajorEntityID == MsgBody.ObjID then
			self.ViewModel:UpdateFeatures(MsgBody.CrafterSkill.Features)
        end
    end
end

function CrafterSidebarPanelNewView:SetupItemSlot()
	local ItemSlot = self.ItemSlot
	UIUtil.SetIsVisible(ItemSlot.RichTextLevel, false)
	UIUtil.SetIsVisible(ItemSlot.RichTextQuantity, false)
	UIUtil.SetIsVisible(ItemSlot.IconChoose, false)
end

function CrafterSidebarPanelNewView:OnShowCrafterTips(Param)
	if Param == ProtoCS.FeatureType.FEATURE_TYPE_DURABILITY then
		TipsUtil.ShowSimpleTipsView({Title = _G.LSTR(150003), Content = _G.LSTR(150081)},
		self.BtnDurable, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0), true)
	elseif Param == ProtoCS.FeatureType.FEATURE_TYPE_PROGRESS then
		TipsUtil.ShowSimpleTipsView({Title = _G.LSTR(150007), Content = _G.LSTR(150082)},
		self.BtnSchedule, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0), true)
	elseif Param == ProtoCS.FeatureType.FEATURE_TYPE_QUALITY then
		local Tipsname = 150006
		local TipsContent = 150083
		if self.ViewModel.bShowImgCollect then
			Tipsname = 150066
			TipsContent = 150085
		end
		TipsUtil.ShowSimpleTipsView({Title = _G.LSTR(Tipsname), Content = _G.LSTR(TipsContent)},
		self.BtnQuality, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0), true)
	end
end

return CrafterSidebarPanelNewView