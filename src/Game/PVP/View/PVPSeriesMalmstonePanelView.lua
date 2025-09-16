---
--- Author: Administrator
--- DateTime: 2024-11-18 11:07
--- Description:
---

local UIView = require("UI/UIView")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local PVPInfoVM = require ("Game/PVP/VM/PVPInfoVM")
local PVPSeriesMalmstoneVM = require ("Game/PVP/VM/PVPSeriesMalmstoneVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local HelpInfoUtil = require("Utils/HelpInfoUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local PVPInfoMgr = _G.PVPInfoMgr
local UIViewMgr = _G.UIViewMgr
local LSTR = _G.LSTR

---@class PVPSeriesMalmstonePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnGetExp UFButton
---@field BtnReceiveAllReward CommBtnMView
---@field CommInforBtn CommInforBtnView
---@field CommMoneySlot CommMoneySlotView
---@field CommonTitle CommonTitleView
---@field ProgressBarExp UProgressBar
---@field RichTextExp URichTextBox
---@field TableViewReward UTableView
---@field TextDescribe UFTextBlock
---@field TextLevel UFTextBlock
---@field TextRewardName UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPSeriesMalmstonePanelView = LuaClass(UIView, true)

function PVPSeriesMalmstonePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnGetExp = nil
	--self.BtnReceiveAllReward = nil
	--self.CommInforBtn = nil
	--self.CommMoneySlot = nil
	--self.CommonTitle = nil
	--self.ProgressBarExp = nil
	--self.RichTextExp = nil
	--self.TableViewReward = nil
	--self.TextDescribe = nil
	--self.TextLevel = nil
	--self.TextRewardName = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPSeriesMalmstonePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnReceiveAllReward)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommMoneySlot)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPSeriesMalmstonePanelView:OnInit()
	self.BtnClose:SetCallback(self, self.OnClickBtnClose)
	self.CommInforBtn:SetButtonStyle(HelpInfoUtil.HelpInfoType.Tips)
	self.CommInforBtn:SetCallback(self, self.ShowSelectedRewardTips)
	self.ViewModel = PVPSeriesMalmstoneVM.New()
	self.RewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewReward, self.OnSelectReward, true)
	self.RewardList:SetItemChangedCallback(self.OnRewardListChanged)
	self.Binders = {
		{ "RewardVMList", UIBinderUpdateBindableList.New(self, self.RewardList) },
		{ "IsLevelMax", UIBinderSetIsVisible.New(self, self.BtnGetExp, true, true) },
	}
	self.InfoBinders = {
		{ "SeriesData", UIBinderValueChangedCallback.New(self, nil, self.OnSeriesDataChanged) },
		{ "HasSeriesReward", UIBinderValueChangedCallback.New(self, nil, self.OnHasSeriesRewardChanged) },
	}
end

function PVPSeriesMalmstonePanelView:OnDestroy()

end

function PVPSeriesMalmstonePanelView:OnShow()
	self:SetFixText()
	self.CommonTitle.CommInforBtn:SetHelpInfoID(11161)
	self.CommMoneySlot:UpdateView(PVPInfoMgr:GetPVPTrophyCrystalScoreType(), nil, nil, true, true)
	self.ViewModel:CheckLevelMax()
	self.ViewModel:ShowCurSeasonRewards()
	self:TryAddRemainTimeTimer()
end

function PVPSeriesMalmstonePanelView:OnHide()
    
end

function PVPSeriesMalmstonePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGetExp, self.OnClickBtnGetExp)
	UIUtil.AddOnClickedEvent(self, self.BtnReceiveAllReward, self.OnClickBtnReceiveAllReward)
end

function PVPSeriesMalmstonePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PVPSeriesRewardDataUpdate, self.OnPVPSeriesRewardDataUpdate)
end

function PVPSeriesMalmstonePanelView:OnRegisterBinder()
	if self.ViewModel then
		self:RegisterBinders(self.ViewModel, self.Binders)
	end
		
	if PVPInfoVM then
		self:RegisterBinders(PVPInfoVM, self.InfoBinders)
	end
end

function PVPSeriesMalmstonePanelView:ShowSelectedRewardTips()
	local SelectedReward = self.RewardList:GetSelectedItemData()
	if SelectedReward == nil then return end

	ItemTipsUtil.ShowTipsByResID(SelectedReward.ResID, self.CommInforBtn)
end

function PVPSeriesMalmstonePanelView:OnRewardListChanged()
	local RewardVMList = self.ViewModel.RewardVMList

	if RewardVMList then
		-- 默认选中第一个未领取的，如果全都领了则选中第一个
		local FindIsReceived = false
		if PVPInfoVM:GetHasSeriesReward() == false then
			if self.ViewModel.IsLevelMax then
				FindIsReceived = true
			end
		end

		local _, SelectIndex = RewardVMList:Find(function(VM)
			return VM.IsReceivedReward == FindIsReceived
		end)

		if SelectIndex then
			self.RewardList:SetSelectedIndex(SelectIndex)
			return
		end
	end

	self.RewardList:CancelSelected()
end

function PVPSeriesMalmstonePanelView:OnSeriesDataChanged(NewValue, OldValue)
	local CurLevel = NewValue and NewValue.Level or 0
	local LevelText = string.format(LSTR(130006), CurLevel)
	self.TextLevel:SetText(LevelText)

	local CurSeasonCfg = PVPInfoMgr:GetCurSeasonSeriesMalmstoneCfg()
	if CurSeasonCfg then
		local ExpText = ""
		local Percent = 0
		if CurLevel >= CurSeasonCfg.LevelMax then
			ExpText = LSTR(130067)
			Percent = 1
		else
			local CurExp = PVPInfoMgr:GetCurSeriesMalmstoneExp()
			local NeedExp = PVPInfoMgr:GetCurSeriesMalmstoneLevelUpExp(CurLevel)
			
			if CurExp and NeedExp then
				ExpText = string.format(LSTR(130051), CurExp, NeedExp)

				if NeedExp ~= 0 then
					Percent = CurExp / NeedExp
				end
			end
		end

		self.RichTextExp:SetText(ExpText)
		self.ProgressBarExp:SetPercent(Percent)
	end
end

function PVPSeriesMalmstonePanelView:OnHasSeriesRewardChanged(NewValue, OldValue)
	if NewValue then
		self.BtnReceiveAllReward:SetIsRecommendState(true)
	else
		self.BtnReceiveAllReward:SetIsEnabled(false, true)
	end
end

function PVPSeriesMalmstonePanelView:OnClickBtnGetExp()
	local OptionList = {}
	for _, Cfg in pairs(self.ViewModel.GetExpCfgList) do
		local Option = {
			Title = Cfg.Title,
			Desc = Cfg.Description,
			IsDone = false,
			Callback = function()
				PWorldEntUtil.ShowPWorldEntView(Cfg.GameType)
			end,
		}
		table.insert(OptionList, Option)
	end
	local Params = {
		Title = LSTR(130007),
		OptionList = OptionList
	}
	UIViewMgr:ShowView(UIViewID.PVPOptionListPanel, Params)
end

function PVPSeriesMalmstonePanelView:OnClickBtnReceiveAllReward()
	if PVPInfoVM:GetHasSeriesReward() == false then
		MsgTipsUtil.ShowTipsByID(338042) -- 暂无可领取的奖励
		return
	end

	local RewardData = PVPInfoVM:GetSeriesMalmstoneRewardData()
	if RewardData == nil then return end

	local IDList = {}
	for ID, IsReceived in pairs(RewardData) do
		if ID ~= 0 and IsReceived == false then
			table.insert(IDList, ID)
		end
	end

	PVPInfoMgr:RequestReceiveReward(IDList)
end

function PVPSeriesMalmstonePanelView:OnClickBtnClose()
	self:Hide()
	UIViewMgr:ShowView(UIViewID.PVPInfoPanel)
end

function PVPSeriesMalmstonePanelView:OnPVPSeriesRewardDataUpdate(Params)
	if Params == nil or Params.UpdateRewards == nil then return end

	for _, ID in pairs(Params.UpdateRewards) do
		local RewardVM = self.RewardList:GetItemDataByPredicate(function(VM)
			return VM.ID == ID
		end)
		if RewardVM then
			RewardVM.IsReceivedReward = PVPInfoMgr:IsReceivedRewardByID(RewardVM.ID)
		end
	end
end

function PVPSeriesMalmstonePanelView:OnSelectReward(Index, ItemVM, ItemView, IsByClick)
	if ItemVM == nil then return end

	local Name = ItemCfg:GetItemName(ItemVM.ResID)
	local Desc = ItemCfg:GetItemDesc(ItemVM.ResID)
	self.TextRewardName:SetText(Name)
	self.TextDescribe:SetText(Desc)

	if IsByClick then
		local CurLevel = PVPInfoMgr:GetSeriesMalmstoneLevel()
		if CurLevel >= ItemVM.Level and ItemVM.IsReceivedReward == false then
			PVPInfoMgr:RequestReceiveReward({ ItemVM.ID })
		end
	end
end

function PVPSeriesMalmstonePanelView:SetFixText()
	self.CommonTitle.TextTitleName:SetText(LSTR(130039))
	self.BtnReceiveAllReward:SetText(LSTR(130040))
end

function PVPSeriesMalmstonePanelView:TryAddRemainTimeTimer()
	local function UpdateRemainTime()
		local RemainTime = PVPInfoMgr:GetCurSeasonSeriesMalmstoneRemainTime()
		if RemainTime > 0 then
			local TimeString = LocalizationUtil.GetCountdownTimeForLongTime(RemainTime)
			if TimeString then
				local Text = string.format(LSTR(130054), TimeString)
				self.TextTime:SetText(Text)
			end
		else
			self.TextTime:SetText(LSTR(130069))
		end
	end

	self:RegisterTimer(UpdateRemainTime, 0, 1, 0)
end

return PVPSeriesMalmstonePanelView