---
--- Author: muyanli
--- DateTime: 2025-05-30 20:52
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLandInformationListItemVM = require("Game/House/VM/Item/HouseLandInformationListItemVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class HouseLandInformationListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconMoney UFImage
---@field ImgListBG UFImage
---@field ImgListBGRed UFImage
---@field ImgListSelected UFImage
---@field ImgListUnSelected UFImage
---@field PanelList UFCanvasPanel
---@field TextInfo UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandInformationListItemView = LuaClass(UIView, true)

function HouseLandInformationListItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.Icon = nil
    -- self.ImgListBG = nil
    -- self.ImgListBGRed = nil
    -- self.ImgListSelect = nil
    -- self.ImgListUnChecked = nil
    -- self.TextInfo = nil
    -- self.TextTitle = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandInformationListItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandInformationListItemView:OnInit()
    self.ViewModel = HouseLandInformationListItemVM.New()
    self.Binders = 
    {
        {"ImgItemBGIndex", UIBinderValueChangedCallback.New(self, nil, self.OnImgItemBGIndexChange)},
        {"IconMoneyVisible", UIBinderSetIsVisible.New(self, self.IconMoney)},
        {"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
        {"TextInfo", UIBinderSetText.New(self, self.TextInfo)},
        {"IconMoney", UIBinderSetBrushFromAssetPath.New(self, self.IconMoney)},
        {"TextInfoColor", UIBinderSetColorAndOpacityHex.New(self, self.TextInfo)},
        {"TextTitleColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTitle)}, 
        {"PanelVisible", UIBinderSetIsVisible.New(self, self.PanelList)},         
    }
end

function HouseLandInformationListItemView:OnDestroy()

end

function HouseLandInformationListItemView:OnShow()

end

function HouseLandInformationListItemView:OnHide()

end

function HouseLandInformationListItemView:OnRegisterUIEvent()

end

function HouseLandInformationListItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.HouseLandInfotmationItemAni, self.OnHouseLandInfotmationItemAni)
end

function HouseLandInformationListItemView:OnRegisterBinder()
    if nil == self.Params or nil == self.Params.Data then
        return
    end
    local ViewModel = self.Params.Data

    self.ViewModel = ViewModel
    self:RegisterBinders(self.ViewModel, self.Binders)
    local bVisible = false
    for i = 1, #HouseLocalDef.LandInfoItemBg do
        bVisible = self.ViewModel.ImgItemBGIndex == i
        UIUtil.SetIsVisible(self[HouseLocalDef.LandInfoItemBg[i]], bVisible, false)
    end
end

function HouseLandInformationListItemView:OnHouseLandInfotmationItemAni()
    self:RegisterTimer(function()
        self:PlayAnimation(self.AnimWin)
    end, 0.2)
end

function HouseLandInformationListItemView:OnImgItemBGIndexChange(NewValue)
end

return HouseLandInformationListItemView
