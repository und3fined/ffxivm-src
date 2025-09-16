---
--- Author: Administrator
--- DateTime: 2024-11-07 11:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

local LSTR = _G.LSTR
local TreasureHuntHouseWinVM = nil

---@class TreasureHuntHouseWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnNo CommBtnSView
---@field BtnYes CommBtnSView
---@field CommSidebarFrame CommSidebarFrameSView
---@field TableViewList UTableView
---@field TableViewList02 UTableView
---@field TextCurrGet UFTextBlock
---@field TextGet UFTextBlock
---@field TextTime UFTextBlock
---@field TextWait UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TreasureHuntHouseWinView = LuaClass(UIView, true)

function TreasureHuntHouseWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnNo = nil
	--self.BtnYes = nil
	--self.CommSidebarFrame = nil
	--self.TableViewList = nil
	--self.TableViewList02 = nil
	--self.TextCurrGet = nil
	--self.TextGet = nil
	--self.TextTime = nil
	--self.TextWait = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TreasureHuntHouseWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnNo)
	self:AddSubView(self.BtnYes)
	self:AddSubView(self.CommSidebarFrame)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TreasureHuntHouseWinView:OnInit()
	TreasureHuntHouseWinVM = _G.TreasureHuntHouseWinVM

	local Value = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_TREASURE_HUNT_DOOR_RESID, "Value")
	self.ChallengeTimeLimit = Value and Value[5] or 100

	self.CurrRewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, nil)
	self.NextRewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewList02, nil, nil)
	self.CurrRewardList:SetOnClickedCallback(self.OnClickedRewardListItem)
	self.NextRewardList:SetOnClickedCallback(self.OnClickedRewardListItem)
end

function TreasureHuntHouseWinView:OnDestroy()

end

function TreasureHuntHouseWinView:OnShow()
    self.CommSidebarFrame:SetTitleText(LSTR(640050))
    self.TextCurrGet:SetText(LSTR(640051))
    self.TextWait:SetText(LSTR(640053))
    self.BtnNo:SetText(LSTR(640055))
    self.BtnYes:SetText(LSTR(640056))
	self.CommSidebarFrame.CommonTitle.CommInforBtn:SetHelpInfoID(21)
end

function TreasureHuntHouseWinView:OnHide()

end

function TreasureHuntHouseWinView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnNo, self.OnBtnAbandon)
    UIUtil.AddOnClickedEvent(self, self.BtnYes, self.OnBtnChallenge)
end

function TreasureHuntHouseWinView:OnRegisterGameEvent()

end

function TreasureHuntHouseWinView:OnRegisterBinder()
	self.Binders = 
	{
		{ "IsVisibleCloseBtn", UIBinderSetIsVisible.New(self, self.CommSidebarFrame.BtnClose) },
		{ "TextGet", UIBinderSetText.New(self, self.TextGet) },
		{ "IsShowAbandon", UIBinderSetIsVisible.New(self, self.BtnNo) },
		{ "IsShowChallenge", UIBinderSetIsVisible.New(self, self.BtnYes) },
		{ "IsShowTextWait", UIBinderSetIsVisible.New(self, self.TextWait) },
		{ "CurrRewardList", UIBinderUpdateBindableList.New(self, self.CurrRewardList) },
		{ "NextRewardList", UIBinderUpdateBindableList.New(self, self.NextRewardList) },
	}
	self:RegisterBinders(TreasureHuntHouseWinVM, self.Binders)
end

function TreasureHuntHouseWinView:OnRegisterTimer()
	self:RegisterTimer(self.CountDownChallengeTimer, 0, 0.5, -1)
end

function TreasureHuntHouseWinView:OnBtnChallenge()
	local OperateReq = 1 --挑战
	_G.TreasuryMgr:GuessCardReq(OperateReq)
	self:Hide()
end

function TreasureHuntHouseWinView:OnBtnAbandon()
	local OperateReq = 2 --放弃挑战
	_G.TreasuryMgr:GuessCardReq(OperateReq)
	self:Hide()
end

function TreasureHuntHouseWinView:CountDownChallengeTimer()
	local ServerTime = TimeUtil.GetServerLogicTime()
    local RemainTime = self.ChallengeTimeLimit - (ServerTime - TreasureHuntHouseWinVM.StartTime)
    if RemainTime == nil or RemainTime <= 0 then
		self:Hide()
        return
    end

	local TimerText =  LocalizationUtil.GetCountdownTimeForShortTime(RemainTime, "hh:mm:ss") or ""
    self.TextTime:SetText(string.format(LSTR(640054), TimerText))
end

function TreasureHuntHouseWinView:OnClickedRewardListItem(Index, ItemVM, ItemView)
	if ItemVM and ItemView then
		ItemTipsUtil.ShowTipsByResID(ItemVM.ResID, ItemView)
	end
end

return TreasureHuntHouseWinView