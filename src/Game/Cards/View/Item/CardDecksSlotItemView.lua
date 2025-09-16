---
--- Author: Administrator
--- DateTime: 2023-10-24 11:25
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CardCfg = require("TableCfg/FantasyCardCfg")
local CardStarCfg = require("TableCfg/FantasyCardStarCfg")

---@class CardDecksSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgStar UFImage
---@field PanelContent UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardDecksSlotItemView = LuaClass(UIView, true)

function CardDecksSlotItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.ImgIcon = nil
    -- self.ImgStar = nil
    -- self.PanelContent = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardDecksSlotItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardDecksSlotItemView:OnInit()
    local Binders = {
        {
            "CardId",
            UIBinderValueChangedCallback.New(self, nil, self.OnCardIdChanged)
        }
    }
    self.Binders = Binders
end

function CardDecksSlotItemView:OnDestroy()

end

function CardDecksSlotItemView:OnShow()

end

function CardDecksSlotItemView:OnHide()

end

function CardDecksSlotItemView:OnRegisterUIEvent()

end

function CardDecksSlotItemView:OnRegisterGameEvent()

end

function CardDecksSlotItemView:OnRegisterBinder()
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

function CardDecksSlotItemView:OnCardIdChanged(NewCardId, OldCardId)
    if NewCardId == 0 then
        UIUtil.SetIsVisible(self.ImgIcon, false)
        UIUtil.SetIsVisible(self.ImgStar, false)
    else
        UIUtil.SetIsVisible(self.ImgIcon, true)
        UIUtil.SetIsVisible(self.ImgStar, true)

        local ItemCfg = CardCfg:FindCfgByKey(NewCardId)
        if nil == ItemCfg then
            _G.FLOG_WARNING("CardDecksSlotItemView:OnCardIdChanged CardId error: [%d]", NewCardId)
            return
        end

        UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, ItemCfg.ShowHeadImg)
        local StarCfg = CardStarCfg:FindCfgByKey(ItemCfg.Star)
        if StarCfg ~= nil then
            -- print(StarCfg.StarImage)
            UIUtil.ImageSetBrushFromAssetPath(self.ImgStar, StarCfg.StarImage)
        end
    end
end

return CardDecksSlotItemView
