---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-11-01 19:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")
local ProtoRes = require("Protocol/ProtoRes")
local ItemUtil = require("Utils/ItemUtil")

---@class GateLeapOfFaithResultPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnExit CommBtnLView
---@field CommSlot CommBackpack96SlotView
---@field GateLeapOfFaithResultItem_Bronze GateLeapOfFaithResultItemView
---@field GateLeapOfFaithResultItem_Gold GateLeapOfFaithResultItemView
---@field GateLeapOfFaithResultItem_Result GateLeapOfFaithResultItemView
---@field GateLeapOfFaithResultItem_Silver GateLeapOfFaithResultItemView
---@field PanelFail UFCanvasPanel
---@field PanelSuccess UFCanvasPanel
---@field TextCoin UFTextBlock
---@field TextFail UFTextBlock
---@field TextProgress UFTextBlock
---@field TextReward UFTextBlock
---@field TextSuccess UFTextBlock
---@field TextTarget UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateLeapOfFaithResultPanelView = LuaClass(UIView, true)

function GateLeapOfFaithResultPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnExit = nil
    --self.CommSlot = nil
    --self.GateLeapOfFaithResultItem_Bronze = nil
    --self.GateLeapOfFaithResultItem_Gold = nil
    --self.GateLeapOfFaithResultItem_Result = nil
    --self.GateLeapOfFaithResultItem_Silver = nil
    --self.PanelFail = nil
    --self.PanelSuccess = nil
    --self.TextCoin = nil
    --self.TextFail = nil
    --self.TextProgress = nil
    --self.TextReward = nil
    --self.TextSuccess = nil
    --self.TextTarget = nil
    --self.AnimIn = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GateLeapOfFaithResultPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnExit)
    self:AddSubView(self.CommSlot)
    self:AddSubView(self.GateLeapOfFaithResultItem_Bronze)
    self:AddSubView(self.GateLeapOfFaithResultItem_Gold)
    self:AddSubView(self.GateLeapOfFaithResultItem_Result)
    self:AddSubView(self.GateLeapOfFaithResultItem_Silver)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateLeapOfFaithResultPanelView:OnInit()
end

function GateLeapOfFaithResultPanelView:OnDestroy()
end

function GateLeapOfFaithResultPanelView:OnShow()
    self.TextTarget:SetText(LSTR(1270021)) -- 目标
    self.TextProgress:SetText(LSTR(1270022)) -- 进度
    self.TextCoin:SetText(LSTR(1270023)) -- 获得金碟币
    self.TextFail:SetText(LSTR(1270024)) -- 挑战失败
    self.TextSuccess:SetText(LSTR(1270025)) -- 挑战成功
    self.TextReward:SetText(LSTR(1270026)) -- 奖励
    self.BtnExit:SetBtnName(LSTR(10010)) -- 退  出

    local Params = self.Params
    local LeapOfFaithMgr = _G.GoldSauserLeapOfFaithMgr
    local GoldSauserMgr = _G.GoldSauserMgr
    local bwin = Params.Type == GoldSauserDefine.PopType.Win
    if (bwin) then
        -- 赢了
        UIUtil.SetIsVisible(self.PanelSuccess, true)
        UIUtil.SetIsVisible(self.PanelFail, false)

        self.GateLeapOfFaithResultItem_Result:UpdateInfo(1, 0, 0, LeapOfFaithMgr.ReachEndRewardCoin)
    else
        -- 输了
        UIUtil.SetIsVisible(self.PanelSuccess, false)
        UIUtil.SetIsVisible(self.PanelFail, true)
        self.GateLeapOfFaithResultItem_Result:UpdateInfo(2, 0, 0, LeapOfFaithMgr.NoReachEndRewardCoin)
    end

    local IconID = ItemUtil.GetItemIcon(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
    local ItemCfg = require("TableCfg/ItemCfg")
    UIUtil.SetIsVisible(self.CommSlot.RichTextLevel, false)
    UIUtil.SetIsVisible(self.CommSlot.IconChoose, false)

    self.CommSlot:SetIconImg(ItemCfg.GetIconPath(IconID))
    self.CommSlot:SetNumVisible(true)
    self.CommSlot:SetNum(Params.AwardCoins)
    self.AwardCoins = LeapOfFaithMgr:GetTotalCoin(true)
    local CactusType = ProtoRes.Game.LeapOfFaithCactusType
    self.GateLeapOfFaithResultItem_Gold:UpdateInfo(
        3,
        CactusType.LeapOfFaithCactusTypeGold,
        LeapOfFaithMgr:GetGoldCount(),
        LeapOfFaithMgr:GetGoldCoin()
    )
    self.GateLeapOfFaithResultItem_Silver:UpdateInfo(
        3,
        CactusType.LeapOfFaithCactusTypeSilver,
        LeapOfFaithMgr:GetSilverCount(),
        LeapOfFaithMgr:GetSilverCoin()
    )
    self.GateLeapOfFaithResultItem_Bronze:UpdateInfo(
        3,
        CactusType.LeapOfFaithCactusTypeBronze,
        LeapOfFaithMgr:GetBronzeCount(),
        LeapOfFaithMgr:GetBronzeCoin()
    )
end

function GateLeapOfFaithResultPanelView:OnHide()
end

function GateLeapOfFaithResultPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnExit, self.OnBtnExitClicked)
end

function GateLeapOfFaithResultPanelView:OnBtnExitClicked()
    if (self.bClickedExitBtn) then
        return
    end

    self.bClickedExitBtn = true

    self:RegisterTimer(
        function()
            self.bClickedExitBtn = false
        end,
        2, -- 延迟2秒
        0, -- 间隔
        1  -- 触发次数
    )

    local RewardItemListVM = self.Params.RewardData

    local Title = LSTR(1270005)
    local CloseCallback = function()
        TimerMgr:AddTimer(
            nil,
            function()
                _G.GoldSauserLeapOfFaithMgr:LeaveWorld()
            end,
            0.5,
            0,
            1
        )
    end
    _G.GoldSauserMgr:ShowCommRewardPanel(RewardItemListVM, Title, CloseCallback)
end

function GateLeapOfFaithResultPanelView:OnRegisterGameEvent()
end

function GateLeapOfFaithResultPanelView:OnRegisterBinder()
end

return GateLeapOfFaithResultPanelView
