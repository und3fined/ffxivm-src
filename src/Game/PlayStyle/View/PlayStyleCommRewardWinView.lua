---
--- Author: Administrator
--- DateTime: 2023-10-07 20:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local GoldSauserMgr = require("Game/Gate/GoldSauserMgr")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class PlayStyleCommRewardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field TableViewRewardList UTableView
---@field TextCloseTips UFTextBlock
---@field TextReward UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleCommRewardWinView = LuaClass(UIView, true)

function PlayStyleCommRewardWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.CommonPopUpBG = nil
    --self.TableViewRewardList = nil
    --self.TextCloseTips = nil
    --self.TextReward = nil
    --self.AnimIn = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleCommRewardWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommonPopUpBG)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleCommRewardWinView:OnInit()
    self.RewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewRewardList, nil, true)
    self.TextReward:SetText(LSTR(1270005))
    self.TextCloseTips:SetText(LSTR(1270006))
end

function PlayStyleCommRewardWinView:OnDestroy()
end

function PlayStyleCommRewardWinView:OnShow()
    local Params = self.Params
    if Params == nil then
        return
    end
    local Title = Params.Title
    if Title == nil then
        return
    end
    self.TextReward:SetText(Title)
    self.RewardList:UpdateAll(Params.RewardData)

    self.HideCallback = Params.HideCallback
end

function PlayStyleCommRewardWinView:OnHide()
    _G.MiniCactpotMgr:ChangCostCoin(true)
    _G.LootMgr:SetDealyState(false)
    _G.LootMgr:AddLootList()
	if (self.HideCallback ~= nil) then
		self.HideCallback()
		self.HideCallback = nil
	end
end

function PlayStyleCommRewardWinView:OnRegisterUIEvent()
end

function PlayStyleCommRewardWinView:OnRegisterGameEvent()
end

function PlayStyleCommRewardWinView:OnRegisterBinder()
end

return PlayStyleCommRewardWinView
