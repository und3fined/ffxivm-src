---
--- Author: Administrator
--- DateTime: 2023-11-14 09:54
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CardCfg = require("TableCfg/FantasyCardCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local CardsSingleCardVM = require("Game/Cards/VM/CardsSingleCardVM")
local CardsRewardSingleCardVM = require("Game/Cards/VM/CardsRewardSingleCardVM")

---@class CardRewardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field TableViewRewardList UTableView
---@field TextCloseTips UFTextBlock
---@field TextReward UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardRewardWinView = LuaClass(UIView, true)

function CardRewardWinView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.CommonPopUpBG = nil
    -- self.TableViewRewardList = nil
    -- self.AnimIn = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardRewardWinView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommonPopUpBG)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardRewardWinView:OnInit()
    self.TableAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRewardList, nil, true)
    self.ServerData = nil
end

function CardRewardWinView:OnDestroy()

end

function CardRewardWinView:OnShow()
    self.TextReward:SetText(_G.LSTR(1130038))--1130038("首次获得")
    self.TextCloseTips:SetText(_G.LSTR(10056))--1130038("点击空白处关闭")
    local RewardCardIDList = nil
    
    if(self.Params ~= nil and self.Params.Data~= nil)then
        self.ServerData = self.Params.Data
        RewardCardIDList = self.Params.CardsList
    end
    if (RewardCardIDList == nil or #RewardCardIDList < 1) then
        self:Hide()
        return
    end
    local rewardCardVMList = {}
    for i = 1, #RewardCardIDList do
        local _newVM = CardsRewardSingleCardVM.New()
		_newVM:SetCardId(RewardCardIDList[i])
        rewardCardVMList[i] = _newVM
    end
    
    self.TableAdapter:UpdateAll(rewardCardVMList)
end

function CardRewardWinView:OnHide()
    _G.UIViewMgr:HideView(_G.UIViewID.MagicCardFirstSeenCardView)
    _G.UIViewMgr:ShowView(_G.UIViewID.MagicCardGameFinishPanel,
        {
            Data = self.ServerData
        }
    )
end

function CardRewardWinView:OnRegisterUIEvent()

end

function CardRewardWinView:OnRegisterGameEvent()

end

function CardRewardWinView:OnRegisterBinder()

end

return CardRewardWinView
