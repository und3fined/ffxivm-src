---
--- Author: usakizhang
--- DateTime: 2024-12-25 16:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MeetTradeVM = require("Game/MeetTrade/VM/MeetTradeVM")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetHead = require("Binder/UIBinderSetHead")
local UIBinderSetFrameIcon = require("Binder/UIBinderSetFrameIcon")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local CommonUtil = require("Utils/CommonUtil")
local TipsUtil = require("Utils/TipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local MonthCardMgr = require("Game/MonthCard/MonthCardMgr")
local HelpCfg = require("TableCfg/HelpCfg")
local MajorUtil = require("Utils/MajorUtil")
local FLinearColor = _G.UE.FLinearColor
local LSTR = _G.LSTR
local BagMgr = _G.BagMgr
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local MeetTradeMgr = _G.MeetTradeMgr

---@class MeetTradeMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg CommonBkg01View
---@field BtnClose CommonCloseBtnView
---@field BtnCondition CommBtnMView
---@field BtnStop CommBtnMView
---@field BtnTaxInfo CommInforBtnView
---@field Comm96Slot CommBackpack96SlotView
---@field Comm96Slot_1 CommBackpack96SlotView
---@field CommonTitle CommonTitleView
---@field EditQuantity CommEditQuantityItemView
---@field ImgCoin UFImage
---@field MoneyBar CommMoneySlotView
---@field Player1 MeetTradePlayerItemView
---@field Player2 MeetTradePlayerItemView
---@field TableViewSlot UTableView
---@field TableViewSlot_1 UTableView
---@field TextTax UFTextBlock
---@field TextTaxCost UFTextBlock
---@field Textchange UFTextBlock
---@field Textchange_1 UFTextBlock
---@field Textchange_2 UFTextBlock
---@field Textchange_3 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MeetTradeMainView = LuaClass(UIView, true)

function MeetTradeMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg = nil
	--self.BtnClose = nil
	--self.BtnCondition = nil
	--self.BtnStop = nil
	--self.BtnTaxInfo = nil
	--self.Comm96Slot = nil
	--self.Comm96Slot_1 = nil
	--self.CommonTitle = nil
	--self.EditQuantity = nil
	--self.ImgCoin = nil
	--self.MoneyBar = nil
	--self.Player1 = nil
	--self.Player2 = nil
	--self.TableViewSlot = nil
	--self.TableViewSlot_1 = nil
	--self.TextTax = nil
	--self.TextTaxCost = nil
	--self.Textchange = nil
	--self.Textchange_1 = nil
	--self.Textchange_2 = nil
	--self.Textchange_3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MeetTradeMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnCondition)
	self:AddSubView(self.BtnStop)
	self:AddSubView(self.BtnTaxInfo)
	self:AddSubView(self.Comm96Slot)
	self:AddSubView(self.Comm96Slot_1)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.EditQuantity)
	self:AddSubView(self.MoneyBar)
	self:AddSubView(self.Player1)
	self:AddSubView(self.Player2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MeetTradeMainView:OnInit()
	self.BtnTaxInfo:SetButtonStyle(4)
	---设置文字
	self.Textchange:SetText(LSTR(1490001)) ---"物品交易"
	self.Textchange_1:SetText(LSTR(1490002)) ---"金币交易"
	self.Textchange_2:SetText(LSTR(1490001)) ---"物品交易"
	self.Textchange_3:SetText(LSTR(1490002)) ---"金币交易"
	self.BtnStop.TextContent:SetText(LSTR(1490005)) ---"中止交易"
	self.BtnCondition.TextContent:SetText(LSTR(1490006)) ---"提出条件"

	---创建TableView的适配器
	self.OtherItemsTable = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.MajorItemTable = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot_1)
	---初始化Binders
	
	self.BindersOtherVM = {
		{ "Name", 				UIBinderSetText.New(self, self.Player1.TextPlayerName) },
	}
	self.BindersMajorVM = {
		{ "Name", 				UIBinderSetText.New(self, self.Player2.TextPlayerName) },
	}

	self.BinderMeetTradeVM = {
		{ "RoleTradeItemVMList", 			UIBinderUpdateBindableList.New(self, self.OtherItemsTable) },
		{ "MajorTradeItemVMList", 		UIBinderUpdateBindableList.New(self, self.MajorItemTable) },
		{ "MajorGoldForTrade", 		UIBinderSetItemNumFormat.New(self, self.Comm96Slot_1.RichTextQuantity) },
		{ "RoleGoldForTrade", 		UIBinderSetItemNumFormat.New(self, self.Comm96Slot.RichTextQuantity) },
		{ "MajorGoldTax", 		UIBinderSetItemNumFormat.New(self, self.TextTaxCost) },
		{ "MajorGoldTaxRateText", 		UIBinderSetText.New(self, self.TextTax) },
		{ "GlodNumForTradeVisible", 		UIBinderSetIsVisible.New(self, self.Comm96Slot.IconChoose) },
		{ "GlodNumForTradeVisible",		 UIBinderSetIsVisible.New(self, self.Comm96Slot_1.IconChoose) },

	}
end

function MeetTradeMainView:OnDestroy()

end

function MeetTradeMainView:OnShow()
	self.MoneyBar:UpdateView(BagMgr.RecoveryScoreID, false, UIViewID.BagMain, true)
	self.BtnClose:SetCallback(self,self.OnClickButtonStop)
	self.Comm96Slot:SetClickButtonCallback(self, self.OnClickGold)
	self.Comm96Slot_1:SetClickButtonCallback(self, self.OnClickGold)
	---设置玩家头像
	self.Player1.PlayerHeadSlot:SetInfo(self.RoleVM.RoleID)
	self.Player2.PlayerHeadSlot:SetInfo(self.MajorVM.RoleID)
	---设置数量编辑器
	local OnClickEditQuantityAddBtn = function(CurValue)
		CurValue = CurValue or 0
		--- 背包金币不足15时，数量不可增加，弹Tips
		if MeetTradeVM:GetMajorMaxGoldNumForTrade() < 15 then
			return MeetTradeVM:GetMajorMaxGoldNumForTrade()
		end
		---金币数量只有两种可能，0或大于等于15
		if CurValue < 15 then
			return 15
		else
			return CurValue + 1
		end
	end
	local OnClickEditQuantitySubBtn = function(CurValue)
		CurValue = CurValue or 0
		---金币数量只有两种可能，0或大于15
		if CurValue <= 15 then
			return 0
		else
			return CurValue - 1
		end
	end
	self:SetMajorLockState(false)
	self.EditQuantity:SetCurValue(0)
	self.EditQuantity:SetUnitSubCall(OnClickEditQuantitySubBtn)
	self.EditQuantity:SetUnitAddCall(OnClickEditQuantityAddBtn)
	self.EditQuantity:SetModifyValueCallback(function (Value)
		self:OnEditQuantityChangeNum(Value)
	end)
	self.EditQuantity:SetInputLowerLimit(0)
	---配置表中配置的最大金币交易数量
	local MaxGoldCountCanSet = MeetTradeMgr.GoldNumLimit
	---取该值和背包中的最大金币交易数量比较，取较小值
	if MaxGoldCountCanSet > MeetTradeVM:GetMajorMaxGoldNumForTrade() then
		MaxGoldCountCanSet = MeetTradeVM:GetMajorMaxGoldNumForTrade()
	end
	self.EditQuantity:SetInputUpperLimit(MaxGoldCountCanSet)
	---根据当前的月卡状态设置Help Info按钮状态
	self.BtnTaxInfo:SetCallback(self, self.OnInforBtnClickHelp)
	self:UpdateMajorAnimationEffect(false)
	self:UpdateRoleAnimationEffect(false)
	MeetTradeVM:Reset()
	---设置帮助按钮
	self.CommonTitle.CommInforBtn:SetHelpInfoID(11182)
	---设置角色名称的字色
	local LineColor = FLinearColor.FromHex("d1ba8e")
	self.Player2.TextPlayerName:SetColorAndOpacity(LineColor)
	---更新主面板上双方的物品表，初始拉起时都为空
	MeetTradeVM:UpdateMajorTradeItemListInfo()
	MeetTradeVM:UpdateRoleTradeItemListInfo()
end


--- 界面关闭时，强制停止交易
function MeetTradeMainView:OnHide(Params)
	--- 非确认交易导致的界面关闭都要发送交易取消消息
	if Params == nil or not Params.TradeIsEnd then
		MeetTradeMgr:SendMeetTradeCancel("1")
	end
	MeetTradeVM:ResetVMInfo()
	MeetTradeMgr:OnMeetTradeEnd()
end


function MeetTradeMainView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnStop, self.OnClickButtonStop)
	UIUtil.AddOnClickedEvent(self, self.BtnCondition, self.OnClickButtonCondition)
end

function MeetTradeMainView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MeetTradeLockStateChange, self.OnMeetTradeLockStateChange) 
end

function MeetTradeMainView:OnRegisterBinder()
	--玩家数据
	local RoleVM = MeetTradeVM.RoleVM
	self.RoleVM = RoleVM
	local MajorVM = MeetTradeVM.MajorVM
	self.MajorVM = MajorVM
	---
	self:RegisterBinders(RoleVM, self.BindersOtherVM)
	self:RegisterBinders(MajorVM, self.BindersMajorVM)
	self:RegisterBinders(MeetTradeVM, self.BinderMeetTradeVM)
end

function MeetTradeMainView:OnUnRegisterBinder()

end

function MeetTradeMainView:OnClickButtonStop()
	local OkBtnCallback = function ()
		self:StopTradeCallback()
	end
	---拉起弹窗
	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1490016), LSTR(1490017), OkBtnCallback, nil, nil, nil, nil)
end

function MeetTradeMainView:OnClickButtonCondition()
	--- 发送提出条件的消息
	MeetTradeMgr:SendMeetTradeLock()
end

function MeetTradeMainView:OnMeetTradeLockStateChange(Member)
	if not Member or not Member.RoleID then
		return
	end
	---检查是否是自身的状态
	if Member.RoleID == MajorUtil.GetMajorRoleID() then
		self:SetMajorLockState(Member.State == 1)
	else
		self:SetRoleLockState(Member.State == 1)
	end
end

function MeetTradeMainView:SetMajorLockState(IsLock)
	self:UpdateMajorAnimationEffect(IsLock)
	---交易锁定，相关按钮禁用
	self.BtnCondition:SetIsEnabled(not IsLock, not IsLock)
	self.EditQuantity:SetAllBtnIsEnabled(not IsLock)
	--- 我方交易锁定
	MeetTradeVM:SetIsLock(IsLock)
end

function MeetTradeMainView:SetRoleLockState(IsLock)
	self:UpdateRoleAnimationEffect(IsLock)
end

function MeetTradeMainView:UpdateMajorAnimationEffect(IsReadyForTrade)
	self.Player2:UpdateAnimationEffect(IsReadyForTrade)
end

function MeetTradeMainView:UpdateRoleAnimationEffect(IsReadyForTrade)
	self.Player1:UpdateAnimationEffect(IsReadyForTrade)
end

function MeetTradeMainView:StopTradeCallback()
	---关闭自身,可能出现收到交易结束的消息，该界面已经被销毁
    ---交易面板关闭
    if UIViewMgr:IsViewVisible(UIViewID.MeetTradeMainView) then
		self:Hide()
    end
end

function MeetTradeMainView:FinishTradeCallback()
    ---交易面板关闭
    if UIViewMgr:IsViewVisible(UIViewID.MeetTradeMainView) then
		self:Hide()
    end
end

function MeetTradeMainView:OnEditQuantityChangeNum(Value)
	if CommonUtil.IsObjectValid(self) then
		--- 数量可以为0，或大于15
		if Value > 0 and Value < 15 then
			self.EditQuantity:SetCurValue(0)
			_G.MsgTipsUtil.ShowTips(LSTR(1490052)) --金币太少了，不满足扣税条件
			return
		end
		local LinearColor
		MeetTradeVM:SendMajorGoldNumForTrade(Value)
		---设置的数量和交易税不足时，提出条件按钮置灰，税额数字置红色
		if Value + MeetTradeVM:GetMajorGoldTax() > MeetTradeVM:GetMajorMaxGoldNumForTrade() then
			self.BtnCondition:SetIsEnabled(false, false)
			LinearColor = FLinearColor.FromHex("DC5868FF")
		else
			self.BtnCondition:SetIsEnabled(true, true)
			LinearColor = FLinearColor.FromHex("D5D5D5FF")
		end
		self.TextTaxCost:SetColorAndOpacity(LinearColor)
	end
end

function MeetTradeMainView:OnClickGold()
	ItemTipsUtil.CurrencyTips(BagMgr.RecoveryScoreID, true, self.Comm96Slot)
end

function MeetTradeMainView:OnInforBtnClickHelp()
	local TipsContent = nil
	if MonthCardMgr:GetMonthCardStatus() == true then
		local FilterFunction = function (Index, Value)
			return Index == 2
		end
		local HelpCfgs = HelpCfg:FindAllHelpIDCfg(20)
		local HelpContent = HelpInfoUtil.ParseContent(HelpCfgs)
		local RemainTime = math.floor(MonthCardMgr:GetMonthCardRemainTime() / 86400)
		local RemainTimeText = tostring(RemainTime)
		if RemainTime < 1 then
			RemainTimeText = LSTR(1490053)
		end
		local TaxRate = string.format("%s", MeetTradeVM.MajorGoldTaxRate*100).."%"
		TipsContent = HelpInfoUtil.ParseTextWithPlaceholders(HelpContent, FilterFunction, TaxRate, RemainTimeText)
	else
		local HelpCfgs = HelpCfg:FindAllHelpIDCfg(19)
		TipsContent = HelpInfoUtil.ParseText(HelpInfoUtil.ParseContent(HelpCfgs))
	end

	if TipsContent == nil then
		return
	end
	TipsUtil.ShowInfoTitleTips(TipsContent, self.BtnTaxInfo, _G.UE.FVector2D(0, 15), _G.UE.FVector2D(0, 0))
end

return MeetTradeMainView