---
--- Author: Administrator
--- DateTime: 2024-11-18 14:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local LeveQuestMgr = require("Game/LeveQuest/LeveQuestMgr")
local LeveQuestDefine = require("Game/LeveQuest/LeveQuestDefine")
local ItemUtil = require("Utils/ItemUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoCommon = require("Protocol/ProtoCommon")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")

---@class LeveQuestTaskInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btnpay CommBtnSView
---@field ImgCard UFImage
---@field RendeEffect UFCanvasPanel
---@field TableViewSlotMust UTableView
---@field TableViewSlotProbability UTableView
---@field TableViewSlotpay UTableView
---@field TextInfo URichTextBox
---@field TextInsufficientLevel UFTextBlock
---@field TextLevel UFTextBlock
---@field TextMust UFTextBlock
---@field TextProbability UFTextBlock
---@field TextSlot UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleBtnTagged UToggleButton
---@field AnimChangeHQ UWidgetAnimation
---@field AnimChangeNQ UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LeveQuestTaskInfoItemView = LuaClass(UIView, true)

function LeveQuestTaskInfoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btnpay = nil
	--self.ImgCard = nil
	--self.RendeEffect = nil
	--self.TableViewSlotMust = nil
	--self.TableViewSlotProbability = nil
	--self.TableViewSlotpay = nil
	--self.TextInfo = nil
	--self.TextInsufficientLevel = nil
	--self.TextLevel = nil
	--self.TextMust = nil
	--self.TextProbability = nil
	--self.TextSlot = nil
	--self.TextTitle = nil
	--self.ToggleBtnTagged = nil
	--self.AnimChangeHQ = nil
	--self.AnimChangeNQ = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LeveQuestTaskInfoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btnpay)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LeveQuestTaskInfoItemView:OnInit()
	-- 必定获得列表
	self.TableViewSlotMustAdpter =  UIAdapterTableView.CreateAdapter(self, self.TableViewSlotMust, self.OnItemSelectedItemChanged, true)

	-- 概率获得列表
	self.TableViewSlotProbabilityAdpter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlotProbability, self.OnItemSelectedItemChanged, true)

	-- 提交材料列表
	self.TableViewSlotpayAdpter =  UIAdapterTableView.CreateAdapter(self, self.TableViewSlotpay, self.OnPayListSelectedItemChanged, true)

	self.Binders = {
		{"Lv", UIBinderSetText.New(self, self.TextLevel)},
		{"Title", UIBinderSetText.New(self, self.TextTitle)},
		{"Content", UIBinderSetText.New(self, self.TextInfo)},
		{"ItemDesc", UIBinderSetText.New(self, self.TextSlot)},
		{"PayText", UIBinderSetText.New(self, self.Btnpay.TextContent)},
		{"Card", UIBinderSetBrushFromAssetPath.New(self, self.ImgCard)},

		{"RewardMustList", UIBinderUpdateBindableList.New(self, self.TableViewSlotMustAdpter)},
		{"RewardProbabilityList", UIBinderUpdateBindableList.New(self, self.TableViewSlotProbabilityAdpter)},
		{"RewardPayList", UIBinderUpdateBindableList.New(self, self.TableViewSlotpayAdpter)},

		{"TextProbabilityVisible", UIBinderSetIsVisible.New(self, self.TextProbability)},
		{"InsufficientLevelVisible",  UIBinderSetIsVisible.New(self, self.TextInsufficientLevel, true)},
		{"InsufficientLevelVisible",  UIBinderSetIsVisible.New(self, self.Btnpay)},
		{"EffectVisible",UIBinderSetIsVisible.New(self, self.RendeEffect)},
		
		-- {"PayListSelectedIndex", UIBinderSetSelectedIndex.New(self, self.TableViewSlotpayAdpter)},
		{"PayListSelectedIndex", UIBinderValueChangedCallback.New(self, nil, self.OnPayListSelectedIndexChanged)},
		{"PayBtnRecommendState", UIBinderValueChangedCallback.New(self, nil, self.OnPayBtnStateChanged)},

		{"IsMarked", UIBinderSetIsChecked.New(self, self.ToggleBtnTagged)},
	}
	
	self.PayItemID = nil
	self.LastResID = nil
end

function LeveQuestTaskInfoItemView:OnDestroy()

end

function LeveQuestTaskInfoItemView:OnShow()
	self.TextMust:SetText(_G.LSTR(880016))
	self.TextProbability:SetText(_G.LSTR(880017))
	self.TextInsufficientLevel:SetText(_G.LSTR(880018))
end	

function LeveQuestTaskInfoItemView:OnHide()

end

function LeveQuestTaskInfoItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btnpay, self.OnClickedBtnpay)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnTagged, self.OnClickedBtnMarked)
end

function LeveQuestTaskInfoItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LeveQuestMarkedItem, self.OnLeveQuestMarkedItem)
	self:RegisterGameEvent(EventID.LeveQuestCancelMarkedItem, self.OnLeveQuestMarkedItem)
end

function LeveQuestTaskInfoItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function LeveQuestTaskInfoItemView:UpdateSelectedImge()
	for i = 1, self.TableViewSlotpayAdpter:GetNum() do
		local ItemView =  self.TableViewSlotpayAdpter:GetChildWidget(i)
		if ItemView ~= nil then
			UIUtil.ImageSetBrushFromAssetPath(ItemView.ImgSelect, "Texture2D'/Game/UI/Texture/LeveQuest/UI_LeveQuest_Img_SlotFocus.UI_LeveQuest_Img_SlotFocus'")
		end
	end
end

function LeveQuestTaskInfoItemView:OnClickedBtnMarked(ToggleButton, State)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	local Cfg = ViewModel.Cfg

	if nil == Cfg then
		_G.FLOG_INFO(string.format(" LeveQuestTaskInfoItemView:OnClickedBtnMarked %s Cfg Is nil", tostring(ViewModel.ID) ))
		return
	end

	ViewModel.IsMarked = IsChecked

	if IsChecked then
		if not LeveQuestMgr:IsProfMarkedItem(Cfg.ProfType, ViewModel.ID) then
			MsgTipsUtil.ShowTips(string.format(_G.LSTR(880020), ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, Cfg.ProfType))) --%s理符道具标记中
		else
			MsgTipsUtil.ShowTips(string.format(_G.LSTR(880021), ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, Cfg.ProfType))) --已切换%s理符道具标记
		end
	else
		MsgTipsUtil.ShowTips(string.format(_G.LSTR(880022), ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, Cfg.ProfType))) --%s理符道具取消标记
	end

	if IsChecked then
		LeveQuestMgr:SetProfMarkedItem(Cfg.ProfType, ViewModel.ID, Cfg.RequireItem.ID)
		EventMgr:SendEvent(EventID.LeveQuestMarkedItem, {Cfg.RequireItem.ID})
	else
		LeveQuestMgr:ClearProfMarkedItem(Cfg.ProfType)
		EventMgr:SendEvent(EventID.LeveQuestCancelMarkedItem, {Cfg.RequireItem.ID})
	end

end

function LeveQuestTaskInfoItemView:OnItemSelectedItemChanged(Index, ItemData, ItemView)
	if ItemData.ResID ~= nil then
		if ItemUtil.ItemIsScore(ItemData.ResID) then
			ItemTipsUtil.CurrencyTips(ItemData.ResID, false, ItemView, _G.UE4.FVector2D(0, 0))
		else
			ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, _G.UE4.FVector2D(0, 0))
		end
	end
end

function LeveQuestTaskInfoItemView:OnPayListSelectedIndexChanged()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	if ViewModel.PayListSelectedIndex == nil then
		self.TableViewSlotpayAdpter:CancelSelected()
	else
		self.TableViewSlotpayAdpter:SetSelectedIndex(ViewModel.PayListSelectedIndex)
	end
end

function LeveQuestTaskInfoItemView:OnPayListSelectedItemChanged(Index, ItemData, ItemView, bByClick)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:UpdateSelectedImge()

	-- Todo 更新选中的物品
	local IsHQ = ItemUtil.IsHQ(ItemData.ResID)
	self.PayItemID = ItemData.ResID
	_G.FLOG_INFO(string.format("self.PayItemID %s.. IsHQ %s", tostring(ItemData.ResID), IsHQ and "is HQ" or "No HQ"))
	ViewModel:UpdateRewardMustList(IsHQ)
	ViewModel:UpdateRewardProbabilityList(IsHQ)
	ViewModel:UpdatePayNum(ItemData.ResID)
	local IsSameResID = self.LastResID == nil and true or self.LastResID == ItemData.ResID

	if ViewModel.InitPayReady then
		if IsHQ then
			if  not IsSameResID then
				self:StopAnimation(self.AnimChangeNQ)
				self:PlayAnimation(self.AnimChangeHQ)
			end
		else
			if not IsSameResID  then
			self:StopAnimation(self.AnimChangeHQ)
			self:PlayAnimation(self.AnimChangeNQ)
			end
		end

		if IsSameResID and self.LastResID ~= nil then
			ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
		end
	end
	self.LastResID = ItemData.ResID
	ViewModel.InitPayReady = true
end

function LeveQuestTaskInfoItemView:OnPayBtnStateChanged()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local PayBtnState = ViewModel:GetPayBtnRecommendState()
	self.Btnpay:SetIsDisabledState(PayBtnState == 0, true)
end

function LeveQuestTaskInfoItemView:OnClickedBtnpay()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	--Todo
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_SUBMIT, true) then
		return
	end

	-- Todo 判断限额不足无法提交
	local LimitNum = LeveQuestMgr:GetRestoreNum()

	if not (LimitNum > 0) then
		MsgTipsUtil.ShowTips(_G.LSTR(880008))
		return
	end

	-- Todo 判断是否能够提交
	local PayBtnState = ViewModel:GetPayBtnRecommendState()
	if PayBtnState == 0 then
		MsgTipsUtil.ShowTips(_G.LSTR(880009))
		return
	end

	local Cfg = ViewModel.Cfg
	local ItemID = self.PayItemID ~= nil and self.PayItemID or Cfg.RequireItem.ID
	local MostPayNum = ViewModel.MostPayNum --交纳次数
	local PayItemNum = Cfg.RequireItem.Num * MostPayNum
	local TempGIDList = LeveQuestMgr:GetCanPayItemGIDs(ItemID)
	local GIDList = {}

	local function SendLeveQuest()
		if LeveQuestMgr:GetPaySingleOrMost() == LeveQuestDefine.PayType.Single then
			if not table.is_nil_empty(TempGIDList) then
				table.insert(GIDList, TempGIDList[1])
			end
		else
			for index, v in ipairs(TempGIDList) do
				if index <= PayItemNum then
					table.insert(GIDList, v)
				end
			end
		end
		LeveQuestMgr:SendLeveQuestSubmitTaskReq(ViewModel.ID, ItemID, PayItemNum, GIDList)
	end

	if LimitNum < MostPayNum and LeveQuestMgr:GetPaySingleOrMost() ~= LeveQuestDefine.PayType.Single then
		PayItemNum = Cfg.RequireItem.Num * LimitNum 
		MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(880004), 
											 string.format(_G.LSTR(880015),  LimitNum),
											 function ()
												 SendLeveQuest()
											 end,
											 nil,
											 _G.LSTR(1080043), _G.LSTR(1080044)
									   )
		return
	end

	SendLeveQuest()
end

function LeveQuestTaskInfoItemView:UpdatePayNum()
	if self.PayItemID == nil then
		return
	end

	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:UpdatePayNum(self.PayItemID)
end

function LeveQuestTaskInfoItemView:OnLeveQuestMarkedItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	ViewModel:SetMarkedItem()
end


return LeveQuestTaskInfoItemView