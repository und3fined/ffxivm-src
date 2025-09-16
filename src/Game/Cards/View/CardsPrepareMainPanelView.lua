---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-10-23 11:23
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CardsPrepareMainPanelVM = require("Game/Cards/VM/CardsPrepareMainPanelVM")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")

---@class CardsPrepareMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG UFImage
---@field BtnClose CommonCloseBtnView
---@field CardsDecksPage CardsDecksPanelView
---@field CommTabsModule CommVerIconTabsView
---@field PrepareEmoActPage CardsPrepareEmoActPanelView
---@field TextSubtitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsPrepareMainPanelView = LuaClass(UIView, true)

function CardsPrepareMainPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnClose = nil
    -- self.CardsDecksPage = nil
    -- self.CommTabsModule = nil
    -- self.PrepareEmoActPage = nil
    -- self.TextSubtitle = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

    self.ViewModel = CardsPrepareMainPanelVM.New()
end

function CardsPrepareMainPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnClose)
    self:AddSubView(self.CardsDecksPage)
    self:AddSubView(self.CommTabsModule)
    self:AddSubView(self.PrepareEmoActPage)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsPrepareMainPanelView:ShowCurSelectPanel()
    if (self.ViewModel.LeftTabSelectIndex == 1) then
        -- 显示卡组信息
        UIUtil.SetIsVisible(self.CardsDecksPage, true)
        UIUtil.SetIsVisible(self.PrepareEmoActPage, false)
        UIUtil.SetIsVisible(self.BG, true)
    else
        -- 显示表情编辑信息
        UIUtil.SetIsVisible(self.CardsDecksPage, false)
        UIUtil.SetIsVisible(self.PrepareEmoActPage, true)
        UIUtil.SetIsVisible(self.BG, false)
    end
end

function CardsPrepareMainPanelView:OnInit()
end

function CardsPrepareMainPanelView:OnClickButtonClose()
    _G.UIViewMgr:HideView(_G.UIViewID.MagicCardPrepareMainPanel)
end

function CardsPrepareMainPanelView:OnDestroy()

end

function CardsPrepareMainPanelView:OnShow()
    local Params = self.Params
    local _cardGroups = Params.CardGroups -- 编辑的卡组信息
    local _defaultIndex = Params.DefaultIndex -- 使用的下标，-1表示自动卡组
    UIUtil.SetIsVisible(self.PrepareEmoActPage, false)
    self.CommTabsModule:UpdateItems(self.ViewModel.LeftTablIconList, self.ViewModel.LeftTabSelectIndex)

    _G.ClientSetupMgr:SendQueryReq({ProtoCS.ClientSetupKey.FantacyCardEmoList})
end

function CardsPrepareMainPanelView:OnHide()

end

function CardsPrepareMainPanelView:OnRegisterUIEvent()
    UIUtil.AddOnSelectionChangedEvent(self, self.CommTabsModule, self.OnCommVerIconTabsChanged)
    self.BtnClose:SetCallback(self, self.OnClickButtonClose)
end

function CardsPrepareMainPanelView:OnRegisterGameEvent()

end

function CardsPrepareMainPanelView:ShowPanelWithIndex()
end

function CardsPrepareMainPanelView:OnRegisterBinder()

end

--- 左边的栏目选择变动了
function CardsPrepareMainPanelView:OnCommVerIconTabsChanged(CurIndex)
    self.ViewModel:SetLeftTabSelectIndex(CurIndex)
    self:ShowCurSelectPanel()
end

return CardsPrepareMainPanelView
