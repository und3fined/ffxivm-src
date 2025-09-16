---
--- Author: v_vvxinchen
--- DateTime: 2024-09-12 10:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetFormatTextValueWithCurve = require("Binder/UIBinderSetFormatTextValueWithCurve")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CollectInfoCfg = require("TableCfg/CollectInfoCfg")
local VM = _G.GatheringJobSkillPanelVM

---@class GatheringCollectionPanelNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnShowCrafterDetails UFButton
---@field CloseBtn CommonCloseBtnView
---@field CrafterProbarItem1 CrafterProbarItemView
---@field CrafterProbarItem2 CrafterProbarItemView
---@field CrafterProbarItem3 CrafterProbarItemView
---@field CrafterTitleItem CrafterTitleItemView
---@field ImgCollect2 UFImage
---@field ImgSidebarBg UFImage
---@field ImgSidebarBg2 UFImage
---@field ImgSidebarLine1 UFImage
---@field ImgYellow UFImage
---@field ItemSlot CommBackpack96SlotView
---@field ProBarCollection UProgressBar
---@field ProBarRed UProgressBar
---@field ProBarYellow UProgressBar
---@field QualityPanel UFCanvasPanel
---@field RichTextQuality URichTextBox
---@field RichTextValueNumber URichTextBox
---@field RichTextValueNumber_2 URichTextBox
---@field TextArea UFTextBlock
---@field TextBlue UFTextBlock
---@field TextItemName URichTextBox
---@field TextQuality UFTextBlock
---@field TextRed UFTextBlock
---@field TextTitleName UFTextBlock
---@field TextYellow UFTextBlock
---@field contant URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBarBlue UWidgetAnimation
---@field AnimProBarBlueControl UWidgetAnimation
---@field AnimProBarRed UWidgetAnimation
---@field AnimProBarRedControl UWidgetAnimation
---@field AnimProBarYellow UWidgetAnimation
---@field AnimProBarYellowControl UWidgetAnimation
---@field ValueAnimProBarRedStart float
---@field ValueAnimProBarRedEnd float
---@field CurveAnimProgressBar CurveFloat
---@field ValueAnimProBarYellowStart float
---@field ValueAnimProBarYellowEnd float
---@field ValueAnimProBarBlueStart float
---@field ValueAnimProBarBlueEnd float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringCollectionPanelNewView = LuaClass(UIView, true)

function GatheringCollectionPanelNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnShowCrafterDetails = nil
	--self.CloseBtn = nil
	--self.CrafterProbarItem1 = nil
	--self.CrafterProbarItem2 = nil
	--self.CrafterProbarItem3 = nil
	--self.CrafterTitleItem = nil
	--self.ImgCollect2 = nil
	--self.ImgSidebarBg = nil
	--self.ImgSidebarBg2 = nil
	--self.ImgSidebarLine1 = nil
	--self.ImgYellow = nil
	--self.ItemSlot = nil
	--self.ProBarCollection = nil
	--self.ProBarRed = nil
	--self.ProBarYellow = nil
	--self.QualityPanel = nil
	--self.RichTextQuality = nil
	--self.RichTextValueNumber = nil
	--self.RichTextValueNumber_2 = nil
	--self.TextArea = nil
	--self.TextBlue = nil
	--self.TextItemName = nil
	--self.TextQuality = nil
	--self.TextRed = nil
	--self.TextTitleName = nil
	--self.TextYellow = nil
	--self.contant = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProBarBlue = nil
	--self.AnimProBarBlueControl = nil
	--self.AnimProBarRed = nil
	--self.AnimProBarRedControl = nil
	--self.AnimProBarYellow = nil
	--self.AnimProBarYellowControl = nil
	--self.ValueAnimProBarRedStart = nil
	--self.ValueAnimProBarRedEnd = nil
	--self.CurveAnimProgressBar = nil
	--self.ValueAnimProBarYellowStart = nil
	--self.ValueAnimProBarYellowEnd = nil
	--self.ValueAnimProBarBlueStart = nil
	--self.ValueAnimProBarBlueEnd = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringCollectionPanelNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CrafterProbarItem1)
	self:AddSubView(self.CrafterProbarItem2)
	self:AddSubView(self.CrafterProbarItem3)
	self:AddSubView(self.CrafterTitleItem)
	self:AddSubView(self.ItemSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringCollectionPanelNewView:OnInit()
    self.Binders = {
        --head相关  只品质框品质色
        {"GatherIcon", UIBinderSetBrushFromAssetPath.New(self, self.ItemSlot.Icon)},
        {"QualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ItemSlot.ImgQuanlity)},
        {"GatherName", UIBinderSetText.New(self, self.TextItemName)},
        --环中间显示的收藏价值（长按显示预测值，否则显示当前值）**
        {"CollectionVal", UIBinderSetFormatTextValueWithCurve.New(self, self.RichTextValueNumber, nil, 0.1, nil, "%d", 0, true)},
        {"CollectionValColor", UIBinderSetColorAndOpacity.New(self, self.RichTextValueNumber)},
        {"CollectionRedVal", UIBinderSetFormatTextValueWithCurve.New(self, self.RichTextValueNumber_2, nil, 0.1, nil, "%d", 0, true)},
        {"CollectionRedValColor", UIBinderSetColorAndOpacity.New(self, self.RichTextValueNumber_2)},
        {"CollectionRedValVisible", UIBinderSetIsVisible.New(self, self.RichTextValueNumber_2)},
        {"CollectionRedValVisible", UIBinderSetIsVisible.New(self, self.contant)},
        --挡位动效亮
        {"CurrentVal", UIBinderValueChangedCallback.New(self, nil, self.SetColorAnim)}
    }
end

function GatheringCollectionPanelNewView:OnDestroy()

end

function GatheringCollectionPanelNewView:OnShow()
	self.TextQuality:SetText(_G.LSTR(150066)) --收藏价值
	self.TextBlue:SetText(_G.LSTR(160015)) --现在值
	self.TextYellow:SetText(_G.LSTR(160022)) --预测值
	self.TextRed:SetText(_G.LSTR(160016)) --最大值
	self.contant:SetText("~") 
	UIUtil.SetIsVisible(self.ItemSlot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.ItemSlot.RichTextQuantity, false)
	UIUtil.SetIsVisible(self.ItemSlot.IconChoose, false)

	--挡位信息
    local CollectionCfg = CollectInfoCfg:FindCfgByKey(_G.CollectionMgr:GetGatherItem().ResID)
    if CollectionCfg then
        local CollectValue = CollectionCfg.CollectValue
		self.CollectValue = CollectValue
        self.CrafterProbarItem1:SetParams({TextBlue = string.format("%d~", CollectValue[1])})
        self.CrafterProbarItem2:SetParams({TextBlue = string.format("%d~", CollectValue[2])})
        self.CrafterProbarItem3:SetParams({TextBlue = string.format("%d~", CollectValue[3])})
		local LocalPos = UIUtil.CanvasSlotGetPosition(self.CrafterProbarItem3)
        UIUtil.CanvasSlotSetOffsets(self.CrafterProbarItem1,  _G.UE.FVector2D(LocalPos.X * CollectValue[1]/CollectValue[3], 0))
        UIUtil.CanvasSlotSetOffsets(self.CrafterProbarItem2,  _G.UE.FVector2D(LocalPos.X * CollectValue[2]/CollectValue[3], 0))
    end
	
	local GatherPointTypeName = _G.GatherMgr:GetCurGatherPointTypeName()
	local TextTitleName = string.format("%s%s",GatherPointTypeName, _G.LSTR(150078))  -- 收藏品
	self.CrafterTitleItem:SetTitle(TextTitleName)
end

function GatheringCollectionPanelNewView:OnHide()
	self:StopAllAnimations()
end

function GatheringCollectionPanelNewView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnShowCrafterDetails, self.OnShowCrafterDetails)
end

function GatheringCollectionPanelNewView:OnShowCrafterDetails()
	local UIViewMgr = _G.UIViewMgr
	UIViewMgr:ShowView(_G.UIViewID.CrafterDetailsPanel)
end

function GatheringCollectionPanelNewView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.GatheringCollectionProBarDoMove, self.OnProBarDoMove)
end

function GatheringCollectionPanelNewView:OnRegisterBinder()
	self:RegisterBinders(VM, self.Binders)
end

function GatheringCollectionPanelNewView:SetColorAnim(NewValue, OldValue)
	if NewValue == nil then
		return
	end
	OldValue = OldValue or 0
	local CollectValue = self.CollectValue
	if CollectValue then
		if NewValue == CollectValue[3] then
			self.CrafterProbarItem3:PlayAnimLightIn()
		end
		if NewValue >= CollectValue[2] and OldValue < CollectValue[2] then
			self.CrafterProbarItem2:PlayAnimLightIn()
		end
		if NewValue >= CollectValue[1] and OldValue < CollectValue[1] then
			self.CrafterProbarItem1:PlayAnimLightIn()
		end
	end
end

function GatheringCollectionPanelNewView:OnProBarDoMove(Params)
	if table.is_nil_empty(Params) then
		return
	end
	if Params.Type == "R" then
		self:PlayAnimProBarRed(Params.Start, Params.Target)
	elseif Params.Type == "Y" then
		self:PlayAnimProBarYellow(Params.Start, Params.Target)
	elseif Params.Type == "G" then
		self:PlayAnimProBarBlue(Params.Start, Params.Target)
	end
end

return GatheringCollectionPanelNewView