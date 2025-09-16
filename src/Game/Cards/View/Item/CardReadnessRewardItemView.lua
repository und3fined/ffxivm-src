---
--- Author: Administrator
--- DateTime: 2023-11-08 11:07
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CardStarCfg = require("TableCfg/FantasyCardStarCfg")
local CardCfg = require("TableCfg/FantasyCardCfg")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemCfg = require("TableCfg/ItemCfg")

---@class CardReadnessRewardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMount UFImage
---@field ImgStar UFImage
---@field PanelMountReward UFCanvasPanel
---@field PanelUnGetReward UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardReadnessRewardItemView = LuaClass(UIView, true)

function CardReadnessRewardItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.ImgMount = nil
    -- self.ImgStar = nil
    -- self.PanelMountReward = nil
    -- self.PanelUnGetReward = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardReadnessRewardItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardReadnessRewardItemView:OnInit()

end

function CardReadnessRewardItemView:OnStarChange()
end

function CardReadnessRewardItemView:OnDestroy()

end

function CardReadnessRewardItemView:OnShow()
    -- 这里直接刷新就好了，不需要监听任何 Binder，因为中途不会改变
    local _selfVM = self.ViewModel

    if (_selfVM.CardID <= 0 and _selfVM.IconImage == nil and _selfVM.Count == nil) then
        UIUtil.SetIsVisible(self.PanelUnGetReward, true)
        UIUtil.SetIsVisible(self.PanelMountReward, false)
    else
        UIUtil.SetIsVisible(self.PanelUnGetReward, false)
        UIUtil.SetIsVisible(self.PanelMountReward, true)

        if (_selfVM.IconImage ~= nil) then
            UIUtil.SetIsVisible(self.ImgStar, false)
            UIUtil.ImageSetBrushFromAssetPath(self.ImgMount, _selfVM.IconImage)
        else
            UIUtil.SetIsVisible(self.ImgStar, false)

            local CardCfg = CardCfg:FindCfgByKey(_selfVM.CardID)
            if nil == CardCfg then
                _G.FLOG_WARNING("CardDecksSlotItemView:OnCardIdChanged CardId error: [%d]", _selfVM.CardID)
                return
            end

            -- local StarCfg = CardStarCfg:FindCfgByKey(CardCfg.Star)
            -- if StarCfg ~= nil then
            --     UIUtil.ImageSetBrushFromAssetPath(self.ImgStar, StarCfg.StarImage)
            -- else
            --     _G.FLOG_ERROR("错误，无法获取星级数据，星级是：" .. tostring(CardCfg.Star))
            -- end

            local Cfg = ItemCfg:FindCfgByKey(_selfVM.CardID)
            if (Cfg ~= nil) then
                local AssetPath = UIUtil.GetIconPath(Cfg.IconID)
                UIUtil.ImageSetBrushFromAssetPath(self.ImgMount, AssetPath)
            else
                _G.FLOG_ERROR("错误，无法获取物品数据，ID是："..tostring(_selfVM.CardID))
            end
        end
    end

    if (_selfVM.Count ~= nil) then
        UIUtil.SetIsVisible(self.TextCount, true)
        self.TextCount:SetText(tostring(_selfVM.Count))
    else
        UIUtil.SetIsVisible(self.TextCount, false)
    end
end

function CardReadnessRewardItemView:OnHide()

end

function CardReadnessRewardItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnShowTips, self.OnClickBtnShowTips)
end

function CardReadnessRewardItemView:OnClickBtnShowTips()
    if self.ViewModel == nil then
        return
    end
    
    if (self.ViewModel.CardID and self.ViewModel.CardID > 0) then
        ItemTipsUtil.ShowTipsByResID(self.ViewModel.CardID, self.BtnShowTips)
    elseif(self.ViewModel.CurrencyID and self.ViewModel.CurrencyID > 0) then
        ItemTipsUtil.CurrencyTips(self.ViewModel.CurrencyID, false, self.BtnShowTips)
    end
end

function CardReadnessRewardItemView:OnRegisterGameEvent()

end

function CardReadnessRewardItemView:OnRegisterBinder()
    self.ViewModel = self.Params.Data -- Data 是 CardReadnessRewardItemVM
end

return CardReadnessRewardItemView
