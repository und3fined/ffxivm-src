---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-08-01 10:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local LSTR = _G.LSTR

---@class SeanceGrandPrizeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field BtnClick UFButton
---@field ImgIcon UFImage
---@field ImgLock UFImage
---@field ImgTagNormal UFImage
---@field ImgTagSelect UFImage
---@field PanelReceive UFCanvasPanel
---@field PanelTimeTag UFCanvasPanel
---@field TextCount UFTextBlock
---@field TextPhaseNormal UFTextBlock
---@field TextPhaseSelect UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SeanceGrandPrizeItemView = LuaClass(UIView, true)

function SeanceGrandPrizeItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.BtnClick = nil
	--self.ImgIcon = nil
	--self.ImgLock = nil
	--self.ImgTagNormal = nil
	--self.ImgTagSelect = nil
	--self.PanelReceive = nil
	--self.PanelTimeTag = nil
	--self.TextCount = nil
	--self.TextPhaseNormal = nil
	--self.TextPhaseSelect = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SeanceGrandPrizeItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SeanceGrandPrizeItemView:OnInit()
end

function SeanceGrandPrizeItemView:OnDestroy()
end

function SeanceGrandPrizeItemView:OnShow()
end

function SeanceGrandPrizeItemView:OnHide()
end

function SeanceGrandPrizeItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnClickBtnCheck)
    UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickBtnClick)
end

function SeanceGrandPrizeItemView:OnClickBtnClick()
    self.ClickCallbackFunc(self.ClickCallbackView, self.PhaseIndex)
end

function SeanceGrandPrizeItemView:OnClickBtnCheck()
    ItemTipsUtil.ShowTipsByResID(self.BigPrizeItemID, self.BtnCheck)
end

function SeanceGrandPrizeItemView:OnRegisterGameEvent()
end

function SeanceGrandPrizeItemView:OnRegisterBinder()
end

function SeanceGrandPrizeItemView:SetClickCallback(InCallbackView, InCallbackFunc)
    self.ClickCallbackView = InCallbackView
    self.ClickCallbackFunc = InCallbackFunc
end

function SeanceGrandPrizeItemView:PlayUnlockAnimation()
    self:PlayAnimation(self.AnimUnlock)
end

function SeanceGrandPrizeItemView:UpdateInfo(InData)
    self.TextPhaseNormal:SetText(InData.TitleText)
    self.TextPhaseSelect:SetText(InData.TitleText)
    self:SetIsGetted(InData.bGetBigPrize)
    local ShowDateTimeStr = TimeUtil.GetTimeFormat("%m/%d", InData.StartTimeStamp)
    local FinalTimeStr = string.format(LSTR(1720010), ShowDateTimeStr)
    self.TextTime:SetText(FinalTimeStr)
    self.BigPrizeItemID = InData.BigPrizeItemID
    self.PhaseIndex = InData.Index
    self:SetIsSelected(InData.bSelected)
    if (InData.BigPrizeItemNum and InData.BigPrizeItemNum > 1) then
        UIUtil.SetIsVisible(self.TextCount, true)
        self.TextCount:SetText(InData.BigPrizeItemNum)
    else
        UIUtil.SetIsVisible(self.TextCount, false)
    end
    if (not InData.bActivityOpen) then
        UIUtil.SetIsVisible(self.PanelTimeTag, true)
        UIUtil.SetIsVisible(self.ImgLock, true)
    else
        UIUtil.SetIsVisible(self.PanelTimeTag, false)
        UIUtil.SetIsVisible(self.ImgLock, false)
    end
    local IconPath = UIUtil.GetItemIconPath(self.BigPrizeItemID)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
end

function SeanceGrandPrizeItemView:SetIsGetted(InbGetted)
    if (InbGetted) then
        UIUtil.SetIsVisible(self.PanelReceive, true)
    else
        UIUtil.SetIsVisible(self.PanelReceive, false)
    end
end

function SeanceGrandPrizeItemView:SetIsSelected(InbSelected)
    if (InbSelected) then
        UIUtil.SetIsVisible(self.ImgTagNormal, false)
        UIUtil.SetIsVisible(self.ImgTagSelect, true)
        UIUtil.SetIsVisible(self.TextPhaseNormal, false)
        UIUtil.SetIsVisible(self.TextPhaseSelect, true)
        UIUtil.SetIsVisible(self.EFFSelect, true)
    else
        UIUtil.SetIsVisible(self.ImgTagNormal, true)
        UIUtil.SetIsVisible(self.ImgTagSelect, false)
        UIUtil.SetIsVisible(self.TextPhaseNormal, true)
        UIUtil.SetIsVisible(self.TextPhaseSelect, false)
        UIUtil.SetIsVisible(self.EFFSelect, false)
    end
end

return SeanceGrandPrizeItemView
