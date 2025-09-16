---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-10-23 17:07
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CardCfg = require("TableCfg/FantasyCardCfg")
local CardStarCfg = require("TableCfg/FantasyCardStarCfg")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local CardRaceCfg = require("TableCfg/FantasyCardRaceCfg")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local EventID = require("Define/EventID")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local EventMgr = _G.EventMgr
local UE = _G.UE
local UEMath = UE.UKismetMathLibrary
local CardTypeEnum = LocalDef.CardItemType

---@class CardsRewardCardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field CardsNumber CardsNumberItemView
---@field ImgCardBG UFImage
---@field ImgFrame UFImage
---@field ImgFrame_Silver UFImage
---@field ImgIcon UFImage
---@field ImgRace UFImage
---@field ImgStar UFImage
---@field PanelCard UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field TextCardName UFTextBlock
---@field TextNameOnTop UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsRewardCardItemView = LuaClass(UIView, true)

function CardsRewardCardItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnClick = nil
    -- self.CardsNumber = nil
    -- self.ImgCardBG = nil
    -- self.ImgEmpty = nil
    -- self.ImgFrame = nil
    -- self.ImgIcon = nil
    -- self.ImgRace = nil
    -- self.ImgStar = nil
    -- self.PanelCard = nil
    -- self.PanelContent = nil
    -- self.TextCardName = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsRewardCardItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CardsNumber)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsRewardCardItemView:OnInit()
    local Binders = {
        {
            "CardId",
            UIBinderValueChangedCallback.New(self, nil, self.OnCardIDChanged)
        }
    }
    self.Binders = Binders
end

function CardsRewardCardItemView:OnDestroy()
end

function CardsRewardCardItemView:OnShow()
end

function CardsRewardCardItemView:OnHide()
end

function CardsRewardCardItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnBtnClick)
end

function CardsRewardCardItemView:OnBtnClick()
    if (self.ViewModel == nil) then
        return
    end
    ItemTipsUtil.ShowTipsByResID(self.ViewModel.CardId, self.BtnClick)
end

function CardsRewardCardItemView:OnRegisterGameEvent()
end

function CardsRewardCardItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end
    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self.ViewModel = ViewModel
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function CardsRewardCardItemView:OnCardIDChanged(NewCardId, OldCardId)
    if NewCardId == nil or NewCardId == 0 then
        UIUtil.SetIsVisible(self.PanelContent, false)
    else
        UIUtil.SetIsVisible(self.PanelContent, true)
        local ItemCfg = CardCfg:FindCfgByKey(NewCardId)
        if nil == ItemCfg then
            _G.FLOG_WARNING(string.format("CardDecksSlotItemView:OnCardIdChanged CardId error: [%d]", NewCardId))
            return
        end

        if (self.ViewModel ~= nil) then
            self.ViewModel.CardName = ItemCfg.Namesss
        end

        if (self.TextCardName ~= nil) then
            self.TextCardName:SetText(ItemCfg.Name)
        end

        if (self.TextNameOnTop ~= nil) then
            self.TextNameOnTop:SetText(ItemCfg.Name)
        end
        if (self.TextNameBottom ~= nil) then
            self.TextNameBottom:SetText(ItemCfg.Name)
        end

        if (ItemCfg.ShowImage == nil or ItemCfg.ShowImage == "") then
            UIUtil.SetIsVisible(self.ImgIcon, false)
        else
            UIUtil.SetIsVisible(self.ImgIcon, true)
            UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, ItemCfg.ShowImage)
        end

        local StarCfg = CardStarCfg:FindCfgByKey(ItemCfg.Star)
        if StarCfg ~= nil then
            UIUtil.ImageSetBrushFromAssetPath(self.ImgStar, StarCfg.StarImage)
        end

        -- 这里要处理一下大赛，会直接削弱数值
        -- 上限是A，下限是1，直接改
        self.CardsNumber:SetNumbes(ItemCfg.Up, ItemCfg.Down, ItemCfg.Left, ItemCfg.Right)

        if ItemCfg.Race == 0 then
            UIUtil.SetIsVisible(self.ImgRace, false)
        else
            local RaceCfg = CardRaceCfg:FindCfgByKey(ItemCfg.Race)
            if RaceCfg ~= nil then
                UIUtil.SetIsVisible(self.ImgRace, true)
                UIUtil.ImageSetBrushFromAssetPath(self.ImgRace, RaceCfg.RaceImage)
            end
        end

        if (ItemCfg.FrameType == 0) then
            UIUtil.SetIsVisible(self.ImgFrame, true)
            UIUtil.SetIsVisible(self.ImgFrame_Silver, false)
        elseif (ItemCfg.FrameType == 1) then
            UIUtil.SetIsVisible(self.ImgFrame, false)
            UIUtil.SetIsVisible(self.ImgFrame_Silver, true)
        else
            UIUtil.SetIsVisible(self.ImgFrame, true)
            UIUtil.SetIsVisible(self.ImgFrame_Silver, false)
            _G.FLOG_ERROR("未确认的边框类型：" .. ItemCfg.FrameType)
        end
    end
end

return CardsRewardCardItemView
