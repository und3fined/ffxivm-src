---
--- Author: Administrator
--- DateTime: 2023-11-01 09:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

local ChocoboRaceMainVM = nil
local LSTR = _G.LSTR

---@class ChocoboRaceResultPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnExit CommBtnLView
---@field PanelReward UFCanvasPanel
---@field TableViewList UTableView
---@field TableViewRewards UTableView
---@field Text1st UFTextBlock
---@field Text5st UFTextBlock
---@field TextReward UFTextBlock
---@field AnimIn1 UWidgetAnimation
---@field AnimIn2 UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRaceResultPanelView = LuaClass(UIView, true)

function ChocoboRaceResultPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnExit = nil
	--self.PanelReward = nil
	--self.TableViewList = nil
	--self.TableViewRewards = nil
	--self.Text1st = nil
	--self.Text5st = nil
	--self.TextReward = nil
	--self.AnimIn1 = nil
	--self.AnimIn2 = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRaceResultPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnExit)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRaceResultPanelView:OnInit()
    ChocoboRaceMainVM = _G.ChocoboRaceMainVM
    self.AdpTableViewPlayerList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, nil)
    self.AdpTableViewRewards = UIAdapterTableView.CreateAdapter(self, self.TableViewRewards, nil,nil)
    self.AdpTableViewRewards:SetOnClickedCallback(self.OnTableViewRewardsAdapterChange)
end

function ChocoboRaceResultPanelView:OnDestroy()

end

function ChocoboRaceResultPanelView:OnShow()
    CommonUtil.DisableShowJoyStick(true)
    CommonUtil.HideJoyStick()
    ChocoboRaceMainVM:InitResultRankList()
    self:PlayAnimation(self.AnimLoop, 0, 0)
    -- LSTR string: 退  出
    self.BtnExit:SetText(_G.LSTR(430006))
    self.TextReward:SetText(_G.LSTR(430023))
end

function ChocoboRaceResultPanelView:OnHide()
    CommonUtil.DisableShowJoyStick(false)
    CommonUtil.ShowJoyStick()
end

function ChocoboRaceResultPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnExit, self.OnClickedBtnExit)
end

function ChocoboRaceResultPanelView:OnRegisterGameEvent()

end

function ChocoboRaceResultPanelView:OnRegisterBinder()
    self.ChocoboBinders =
    {
        { "Rank", UIBinderValueChangedCallback.New(self, nil, self.MajorRankNumChange) },
    }
    
    local Binders = {
        { "RaceResultRankList", UIBinderUpdateBindableList.New(self, self.AdpTableViewPlayerList) },
        { "MajorIndex", UIBinderValueChangedCallback.New(self, nil, self.IndexChange) },
        { "RewardVMs", UIBinderUpdateBindableList.New(self, self.AdpTableViewRewards) },
        { "IsShowPanelReward", UIBinderSetIsVisible.New(self, self.PanelReward) },
        { "IsShowResultTitleText1st", UIBinderSetIsVisible.New(self, self.Text1st) },
        { "IsShowResultTitleText5st", UIBinderSetIsVisible.New(self, self.Text5st) },
        { "ResultTitleText", UIBinderSetText.New(self, self.Text1st) },
        { "ResultTitleText", UIBinderSetText.New(self, self.Text5st) },
    }
    self:RegisterBinders(ChocoboRaceMainVM, Binders)
end

function ChocoboRaceResultPanelView:IndexChange(NewValue, OldValue)
    if nil ~= OldValue then
        local ViewModel = ChocoboRaceMainVM:FindChocoboRaceVM(OldValue)
        if nil ~= ViewModel then
            self:UnRegisterBinders(ViewModel, self.ChocoboBinders)
        end
    end

    if nil ~= NewValue then
        local ViewModel = ChocoboRaceMainVM:FindChocoboRaceVM(NewValue)
        if nil ~= ViewModel then
            self.ViewModel = ViewModel
            self:RegisterBinders(ViewModel, self.ChocoboBinders)
        end
    end
end

function ChocoboRaceResultPanelView:MajorRankNumChange(Value)
    if Value <= 3 then
        self:PlayAnimation(self.AnimIn1)
    else
        self:PlayAnimation(self.AnimIn2)
    end
end

function ChocoboRaceResultPanelView:OnTableViewRewardsAdapterChange(Index, ItemData, ItemView)
    ItemTipsUtil.ShowTipsByResID(ItemData.ID, ItemView)
end

function ChocoboRaceResultPanelView:OnClickedBtnExit()
    _G.PWorldMgr:SendLeavePWorld()
    self:Hide()
end

return ChocoboRaceResultPanelView