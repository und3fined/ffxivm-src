---
--- Author: chriswang
--- DateTime: 2023-08-31 17:24
--- Description: 已废弃
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

local HavePlayedAnimNames = {} --记录播放过的动画，show时进行reset
local StartPercent = 0.01
local EndPercent = 0.99

---@class CrafterSidebarPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CollectPanel_1 UFCanvasPanel
---@field ImgCollect UFImage
---@field ImgQualityBlue UFImage
---@field ImgQualityBlue1 UFImage
---@field ImgQualityGreen UFImage
---@field ImgQualityGreen1 UFImage
---@field ImgQualityYellow UFImage
---@field ImgQualityYellow1 UFImage
---@field ItemSlot CommBackpackSlotView
---@field MajorInfo MainMajorInfoPanelView
---@field ProBaSchedule UProgressBar
---@field ProBarDurable UProgressBar
---@field ProBarQuality UProgressBar
---@field RichTextDurable URichTextBox
---@field RichTextQuality URichTextBox
---@field RichTextSchedule URichTextBox
---@field TextArea UFTextBlock
---@field TextBlue UFTextBlock
---@field TextCollect UFTextBlock
---@field TextDurable UFTextBlock
---@field TextFrequency UFTextBlock
---@field TextFrequencyNumber UFTextBlock
---@field TextGreen UFTextBlock
---@field TextName UFTextBlock
---@field TextQuality UFTextBlock
---@field TextSchedule UFTextBlock
---@field TextTitleName UFTextBlock
---@field TextValue UFTextBlock
---@field TextValueNumber UFTextBlock
---@field TextYellow UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterSidebarPanelView = LuaClass(UIView, true)

function CrafterSidebarPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CollectPanel_1 = nil
	--self.ImgCollect = nil
	--self.ImgQualityBlue = nil
	--self.ImgQualityBlue1 = nil
	--self.ImgQualityGreen = nil
	--self.ImgQualityGreen1 = nil
	--self.ImgQualityYellow = nil
	--self.ImgQualityYellow1 = nil
	--self.ItemSlot = nil
	--self.MajorInfo = nil
	--self.ProBaSchedule = nil
	--self.ProBarDurable = nil
	--self.ProBarQuality = nil
	--self.RichTextDurable = nil
	--self.RichTextQuality = nil
	--self.RichTextSchedule = nil
	--self.TextArea = nil
	--self.TextBlue = nil
	--self.TextCollect = nil
	--self.TextDurable = nil
	--self.TextFrequency = nil
	--self.TextFrequencyNumber = nil
	--self.TextGreen = nil
	--self.TextName = nil
	--self.TextQuality = nil
	--self.TextSchedule = nil
	--self.TextTitleName = nil
	--self.TextValue = nil
	--self.TextValueNumber = nil
	--self.TextYellow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterSidebarPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ItemSlot)
	self:AddSubView(self.MajorInfo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterSidebarPanelView:OnInit()

end

function CrafterSidebarPanelView:OnDestroy()

end

local Handled = _G.UE.UWidgetBlueprintLibrary.Handled()

function CrafterSidebarPanelView:OnShow()
	-- self.RichTextDurable
	UIUtil.SetIsVisible(self.MajorInfo.BtnSwitch, false)
	self:ResetAnims()

	self.ImgSidebarBg.OnMouseButtonDownEvent:Bind(self.Object, function()
		return Handled
	end)
end

function CrafterSidebarPanelView:OnHide()
	self:StopAllAnimations()
end

function CrafterSidebarPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnShowCrafterDetails, self.OnShowCrafterDetails)
end

function CrafterSidebarPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
end

function CrafterSidebarPanelView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local Binders = {
		{"ProfName", UIBinderSetText.New(self, self.TextArea)},
		{"RecipeName", UIBinderSetText.New(self, self.TextName)},
		{"ItemIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ItemSlot.FImg_Icon) },
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
		
		{"bHorizontalValue", UIBinderSetIsVisible.New(self, self.FHorizontalValue)},
		{"bQualityPanel", UIBinderSetIsVisible.New(self, self.QualityPanel)},
		
		--是否收藏品
		{"bShowImgCollect", UIBinderSetIsVisible.New(self, self.ImgCollect)},
		{"bShowImgCollect", UIBinderSetIsVisible.New(self, self.ImgCollect2)},
		{"bShowImgCollect", UIBinderSetIsVisible.New(self, self.PanelQualityBlue)},
		{"bShowImgCollect", UIBinderSetIsVisible.New(self, self.PanelQualityYellow)},
		{"bShowImgCollect", UIBinderSetIsVisible.New(self, self.PanelQualityGreen)},
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

function CrafterSidebarPanelView:OnShowCrafterDetails()
	local UIViewMgr = _G.UIViewMgr
	UIViewMgr:ShowView(UIViewID.CrafterDetailsPanel)
end

function CrafterSidebarPanelView:OnCollectAnimType(AnimType)
	if not table.is_nil_empty(HavePlayedAnimNames) and HavePlayedAnimNames[AnimType] then
		return
	end
	if AnimType == 1 then
		self:PlayAnimation(self.AnimQualityBlue)
		table.insert(HavePlayedAnimNames, "AnimQualityBlue")
	elseif AnimType == 2 then
		self:PlayAnimation(self.AnimQualityYellow)
		table.insert(HavePlayedAnimNames, "AnimQualityYellow")
	elseif AnimType == 3 then
		self:PlayAnimation(self.AnimQualityGreen)
		table.insert(HavePlayedAnimNames, "AnimQualityGreen")
	end
end

function CrafterSidebarPanelView:ResetAnims()
	if table.is_nil_empty(HavePlayedAnimNames) then
		return
	end
	for _, anim in pairs(HavePlayedAnimNames) do
		if self[anim] then
			self:PlayAnimationTimeRange(self[anim], 0.0, 0.01, 1, nil, 1.0, false)
		end
	end
	HavePlayedAnimNames = {}
end

function CrafterSidebarPanelView:OnSetDurableFillColor(FillColorType)
	if FillColorType == 1 then
		UIUtil.ProgressBarSetFillImage(self.ProBarDurable, "PaperSprite'/Game/UI/Atlas/Crafter/Frames/UI_Alchemist_Img_DurableBlue_png.UI_Alchemist_Img_DurableBlue_png'")
	elseif FillColorType == 2 then
		UIUtil.ProgressBarSetFillImage(self.ProBarDurable, "PaperSprite'/Game/UI/Atlas/Crafter/Frames/UI_Alchemist_Img_DurableYellow_png.UI_Alchemist_Img_DurableYellow_png'")
	elseif FillColorType == 3 then
		UIUtil.ProgressBarSetFillImage(self.ProBarDurable, "PaperSprite'/Game/UI/Atlas/Crafter/Frames/UI_Alchemist_Img_DurableRed_png.UI_Alchemist_Img_DurableRed_png'")
	end
end

function CrafterSidebarPanelView:OnSetImgQualityPos(CollectValues)
	if CollectValues and #CollectValues >= 3 then
		local MaxQuality = self.ViewModel.QualityMax
		local MaxX = 491 / self.ViewModel.ImgQualityGreenPercent
		local X = MaxX * CollectValues[1] / MaxQuality
		_G.UIUtil.CanvasSlotSetPosition(self.PanelQualityBlue, _G.UE4.FVector2D(X - 19, 57))
		-- _G.UIUtil.CanvasSlotSetPosition(self.EFF_ADD_Inst_a, _G.UE4.FVector2D(X, 45))
		-- _G.UIUtil.CanvasSlotSetPosition(self.EFF_ADD_Inst_b, _G.UE4.FVector2D(X, 76))
		X = MaxX * CollectValues[2] / MaxQuality
		_G.UIUtil.CanvasSlotSetPosition(self.PanelQualityYellow, _G.UE4.FVector2D(X - 19, 57))
		-- _G.UIUtil.CanvasSlotSetPosition(self.EFF_ADD_Inst_c, _G.UE4.FVector2D(X, 45))
		-- _G.UIUtil.CanvasSlotSetPosition(self.EFF_ADD_Inst_d, _G.UE4.FVector2D(X, 76))
	end
end

function CrafterSidebarPanelView:OnEventCrafterSkillRsp(MsgBody)
    if MsgBody and MsgBody.CrafterSkill then
        local MajorEntityID = MajorUtil.GetMajorEntityID()
		if MajorEntityID == MsgBody.ObjID then
			self.ViewModel:UpdateFeatures(MsgBody.CrafterSkill.Features)
        end
    end
end

return CrafterSidebarPanelView