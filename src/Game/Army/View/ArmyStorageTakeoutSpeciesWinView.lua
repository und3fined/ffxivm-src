---
--- Author: Administrator
--- DateTime: 2024-06-11 11:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyTextColor = ArmyDefine.ArmyTextColor
local GlobalCfgType = ArmyDefine.GlobalCfgType
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ArmyMgr
local CommBtnLView = require("Game/Common/Btn/CommBtnLView")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")
local TipsUtil = require("Utils/TipsUtil")
local MonthCardMgr = require("Game/MonthCard/MonthCardMgr")
local MonthcardGlobalCfg = require("TableCfg/MonthcardGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local MonthCardGlobalParamType = ProtoRes.MonthCardGlobalParamType
local UIViewMgr = _G.UIViewMgr
local TradeMarketSystemParamCfg = require("TableCfg/TradeMarketSystemParamCfg")
local HelpCfg = require("TableCfg/HelpCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local MarketMgr = require("Game/Market/MarketMgr")
local ItemUtil = require("Utils/ItemUtil")

---@class ArmyStorageTakeoutSpeciesWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArrowPanel2 UFCanvasPanel
---@field BG Comm2FrameMView
---@field BtnArrow UFButton
---@field BtnCancel CommBtnLView
---@field BtnInfo CommInforBtnView
---@field BtnNumber3 UFButton
---@field BtnPlus UFButton
---@field BtnReduce UFButton
---@field Btnsure CommBtnLView
---@field CommSlot CommBackpack126SlotView
---@field HorizontalTaxRate UFHorizontalBox
---@field InputText UEditableText
---@field MoneySlot1 CommMoneySlotView
---@field PanelExchangeSetting UFCanvasPanel
---@field TextCurrency01 UFTextBlock
---@field TextCurrency02 UFTextBlock
---@field TextNumber3 UFTextBlock
---@field TextSpecies UFTextBlock
---@field TextStorage UFTextBlock
---@field TextTakeOut UFTextBlock
---@field TextTaxRate UFTextBlock
---@field TextTaxRate02 UFTextBlock
---@field ToggleBtnStorage UToggleButton
---@field ToggleBtnTakeOut UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimToggleBtnStorageChecked UWidgetAnimation
---@field AnimToggleBtnTakeOutChecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyStorageTakeoutSpeciesWinView = LuaClass(UIView, true)

local ArmyMoneyMaxDepositNum = 999999999
local ArmyMoneySingleDepositMinNum = 100
local PlayerMoneyMaxNum =  999999999 

local Btn_Reduce_Disab = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Reduce_Disab_png.UI_Comm_Btn_Reduce_Disab_png'"
local Btn_Reduce_Normal = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Reduce_png.UI_Comm_Btn_Reduce_png'"
local Btn_Plus_Disab = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Plus_Disab_png.UI_Comm_Btn_Plus_Disab_png'"
local Btn_Plus_Normal = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Plus_png.UI_Comm_Btn_Plus_png'"
local Btn_Arrow_Disab = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Btn_AddQuantity_Grey_png.UI_Army_Btn_AddQuantity_Grey_png'"
local Btn_Arrow_Normal = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Btn_AddQuantity_png.UI_Army_Btn_AddQuantity_png'"

local ErrorTipsStr = 
{
	-- LSTR string:金币不足
	InsufficientGold = LSTR(910268),
	-- LSTR string:已超出最大储存数量
	StorageMaxNum = LSTR(910118),
	-- LSTR string:已超出持有金币上限
	PlayerMaxNum = LSTR(910117),
	-- LSTR string:已达到最大数量，不能再增加
	MaxNum = LSTR(910120),
	-- LSTR string:已达到最小数量，不能再减少
	MinNum = LSTR(910121),
	-- LSTR string:单笔金币低于最小值
	SingleDepositMinNum = LSTR(910078),
	-- LSTR string:已超出最大取出数量
	TakeoutMaxNum = LSTR(910119),
	-- LSTR string:储物柜金币不足
	--DepotGoldNumNotEnough = LSTR(910053),
}
function ArmyStorageTakeoutSpeciesWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArrowPanel2 = nil
	--self.BG = nil
	--self.BtnArrow = nil
	--self.BtnCancel = nil
	--self.BtnInfo = nil
	--self.BtnNumber3 = nil
	--self.BtnPlus = nil
	--self.BtnReduce = nil
	--self.Btnsure = nil
	--self.CommSlot = nil
	--self.HorizontalTaxRate = nil
	--self.InputText = nil
	--self.MoneySlot1 = nil
	--self.PanelExchangeSetting = nil
	--self.TextCurrency01 = nil
	--self.TextCurrency02 = nil
	--self.TextNumber3 = nil
	--self.TextSpecies = nil
	--self.TextStorage = nil
	--self.TextTakeOut = nil
	--self.TextTaxRate = nil
	--self.TextTaxRate02 = nil
	--self.ToggleBtnStorage = nil
	--self.ToggleBtnTakeOut = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimToggleBtnStorageChecked = nil
	--self.AnimToggleBtnTakeOutChecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyStorageTakeoutSpeciesWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.Btnsure)
	self:AddSubView(self.CommSlot)
	self:AddSubView(self.MoneySlot1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyStorageTakeoutSpeciesWinView:OnInit()
	---单笔可存入金币最小数量
	ArmyMoneySingleDepositMinNum = GroupGlobalCfg:GetValueByType(GlobalCfgType.GlobalCfgMoneyBagSingleDepositMinNum) or 100
	ArmyMoneyMaxDepositNum = GroupGlobalCfg:GetValueByType(GlobalCfgType.GlobalCfgMoneyBagDepositMaxNum) or 999999999
	local ScoreType = GroupGlobalCfg:GetValueByType(GlobalCfgType.GlobalCfgMoneyBagResID)
	PlayerMoneyMaxNum = ScoreMgr:GetScoreMaxValue(ScoreType) or 999999999
	self.ChangeNum = 100
	ArmyMgr = require("Game/Army/ArmyMgr")
	self.IsError = false
	self.ErrorStr = ""
	self.Num = 0
end

function ArmyStorageTakeoutSpeciesWinView:OnDestroy()

end

function ArmyStorageTakeoutSpeciesWinView:OnShow()
	self.CommSlot:SetIconChooseVisible(false)
	self.CommSlot:SetNumVisible(false)
	self.CommSlot:SetItemLevelVisible(false)
	local ScoreType = GroupGlobalCfg:GetValueByType(GlobalCfgType.GlobalCfgMoneyBagResID)
	local ColorIcon = ItemUtil.GetItemColorIcon(ScoreType)
	local IconID = ItemUtil.GetItemIcon(ScoreType)
    local ImgName = UIUtil.GetIconPath(IconID)
	self.CommSlot:SetQualityImg(ColorIcon)
	self.CommSlot:SetIconImg(ImgName)

	-- LSTR string:储物柜：
	self.TextCurrency01:SetText(LSTR(910326))
	-- LSTR string:交易税率：
	self.TextTaxRate:SetText(LSTR(910327))
	-- LSTR string:存入
	self.TextStorage:SetText(LSTR(910324))
	-- LSTR string:取出
	self.TextTakeOut:SetText(LSTR(910325))

	local Params = self.Params
	if Params then
		self:SetIsDepositPanel(true, Params.TotalNum)
	end
	self.BtnInfo:SetCallback(self, self.OnBtnInfoClickHelp)

	-- LSTR string:取  消
	self.BtnCancel:SetText(LSTR(910081))
	-- LSTR string:确  认
	self.Btnsure:SetText(LSTR(910181))
end

function ArmyStorageTakeoutSpeciesWinView:OnBtnInfoClickHelp()
	local tipsContent = nil
	if MonthCardMgr:GetMonthCardStatus() == true then
		if ArmyDefine.ArmyMoneyBagHelpTextID then
			local HelpCfgs = HelpCfg:FindAllHelpIDCfg(ArmyDefine.ArmyMoneyBagHelpTextID.TRADE_MAERKET_PARAM_TAX_DESC_WITHOUT_MONTHCARD)
			local HelpContent = HelpInfoUtil.ParseContent(HelpCfgs)
			local Ret = {}
			for k, v in ipairs(HelpContent) do
				local Title = v.SecTitle
				local Content = {}
				for index, value in ipairs(v.SecContent) do
					local SecContent = value.SecContent
					if index == 2 then
						SecContent = string.format(value.SecContent, (MarketMgr.MonthCardTradeTax*100).."%", math.ceil(MonthCardMgr:GetMonthCardRemainTime() / 86400))
					end
					table.insert(Content, SecContent)
				end
				table.insert(Ret, {Title = Title, Content = Content})
			end

			tipsContent = Ret
		end

	else
		if ArmyDefine.ArmyMoneyBagHelpTextID then
			local HelpCfgs = HelpCfg:FindAllHelpIDCfg(ArmyDefine.ArmyMoneyBagHelpTextID.TRADE_MAERKET_PARAM_TAX_DESC_WITH_MONTHCARD)
			tipsContent = HelpInfoUtil.ParseText(HelpInfoUtil.ParseContent(HelpCfgs))
		end
	end

	if tipsContent == nil then
		return
	end
	
	TipsUtil.ShowInfoTitleTips(tipsContent, self.BtnInfo, _G.UE.FVector2D(0, 15), _G.UE.FVector2D(0, 0))
end

function ArmyStorageTakeoutSpeciesWinView:UpdatePanel(TotalNum)
	self:SetIsDepositPanel(self.IsDeposit, TotalNum)
end

function ArmyStorageTakeoutSpeciesWinView:InitDepositPanel(TotalNum)
	--ArmyMgr:SendGroupMoneyBagQuery()
	self.ArmyTotalMoneyNum = TotalNum or 0
	self.LowerLimit = 1
	self.UpperLimit = ArmyMoneyMaxDepositNum
	local ScoreType = GroupGlobalCfg:GetValueByType(GlobalCfgType.GlobalCfgMoneyBagResID)
	self.PlayerMoneyNum = ScoreMgr:GetScoreValueByID(ScoreType) or 0
	self.IsError = false
	self.Num = 0
	if self.PlayerMoneyNum >= ArmyMoneySingleDepositMinNum and self.ArmyTotalMoneyNum + ArmyMoneySingleDepositMinNum <= ArmyMoneyMaxDepositNum then
		self:UpdateNum(ArmyMoneySingleDepositMinNum) 
	else
		self:UpdateNum(1) 
	end
	self.MoneySlot1:SetMoneyNum(self.PlayerMoneyNum)
	self.MoneySlot1:UpdateView(ScoreType, false, nil, true)
	self.TextCurrency02:SetText(ArmyMgr:FormatMoneyNumber(self.ArmyTotalMoneyNum))
	---金币为0处理 或者 仓库达到上限处理
	if self.PlayerMoneyNum == 0 or self.ArmyTotalMoneyNum == ArmyMoneyMaxDepositNum then
		UIUtil.ButtonSetBrush(self.BtnReduce, Btn_Reduce_Disab)
		UIUtil.ButtonSetBrush(self.BtnPlus, Btn_Plus_Disab)
		UIUtil.ButtonSetBrush(self.BtnArrow, Btn_Arrow_Disab)
		self.Btnsure:SetIsDisabledState(true, true)
		self.TextNumber3:SetText(1)
		-- LSTR string:金币
		self.TextSpecies:SetText(string.format("%sx%d",LSTR(910267), 1))
		self.Num = 0
		self.IsError = true

		if self.PlayerMoneyNum == 0 then
			self.ErrorStr = ErrorTipsStr.InsufficientGold
		else
			self.ErrorStr = ErrorTipsStr.StorageMaxNum
		end
	elseif self.Num  < ArmyMoneySingleDepositMinNum then
		self.Btnsure:SetIsDisabledState(true, true)
	else
		--UIUtil.ButtonSetBrush(self.BtnArrow, Btn_Arrow_Normal)
		self.Btnsure:SetIsRecommendState(true)
	end
	---取消按钮长驻
	UIUtil.SetIsVisible(self.BtnCancel, true, true)

	---税率逻辑
	local TaxRateStr
	local MonthCardState = MonthCardMgr:GetMonthCardStatus()
	local TaxRateData
	if MonthCardState then
		TaxRateData = MonthcardGlobalCfg:FindCfgByKey(MonthCardGlobalParamType.MonthCardGlobalValidTradeTax)
	else
		TaxRateData = MonthcardGlobalCfg:FindCfgByKey(MonthCardGlobalParamType.MonthCardGlobalInvalidTradeTax)
	end
	if TaxRateData then
		TaxRateStr = string.format("%d%%", TaxRateData.Value[1])
		self.TextTaxRate02:SetText(TaxRateStr)
	end
end

function ArmyStorageTakeoutSpeciesWinView:InitTakeOutPanel(TotalNum)
	--ArmyMgr:SendGroupMoneyBagQuery()
	self.ArmyTotalMoneyNum = TotalNum or 0
	local ScoreType = GroupGlobalCfg:GetValueByType(GlobalCfgType.GlobalCfgMoneyBagResID)
	self.PlayerMoneyNum = ScoreMgr:GetScoreValueByID(ScoreType) or 0
	self.LowerLimit = 1
	self.UpperLimit = PlayerMoneyMaxNum
	self.IsError = false
	self.Num = 0
	if self.ArmyTotalMoneyNum >= ArmyMoneySingleDepositMinNum and self.PlayerMoneyNum + ArmyMoneySingleDepositMinNum <= PlayerMoneyMaxNum then
		self:UpdateNum(ArmyMoneySingleDepositMinNum) 
	else
		self:UpdateNum(1) 
	end
	self.MoneySlot1:SetMoneyNum(self.PlayerMoneyNum)
	self.MoneySlot1:UpdateView(ScoreType, false, nil, true)
	self.TextCurrency02:SetText(ArmyMgr:FormatMoneyNumber(self.ArmyTotalMoneyNum))
	---存储为0处理 或者 自身金币达到上限处理
	if self.ArmyTotalMoneyNum == 0 or self.PlayerMoneyNum == PlayerMoneyMaxNum then
		UIUtil.ButtonSetBrush(self.BtnReduce, Btn_Reduce_Disab)
		UIUtil.ButtonSetBrush(self.BtnPlus, Btn_Plus_Disab)
		UIUtil.ButtonSetBrush(self.BtnArrow, Btn_Arrow_Disab)

		self.Btnsure:SetIsDisabledState(true, true)
		self.TextNumber3:SetText(1)
		-- LSTR string:金币
		self.TextSpecies:SetText(string.format("%sx%d",LSTR(910267), 1))
		self.Num = 0
		if self.ArmyTotalMoneyNum == 0 then
			self.ErrorStr = ErrorTipsStr.InsufficientGold
		else
			self.ErrorStr = ErrorTipsStr.PlayerMaxNum
		end
	else
		--UIUtil.ButtonSetBrush(self.BtnArrow, Btn_Arrow_Normal)
		self.Btnsure:SetIsRecommendState(true)
	end
	---取消按钮长驻
	UIUtil.SetIsVisible(self.BtnCancel, true, true)
end

function ArmyStorageTakeoutSpeciesWinView:OnHide()

end

function ArmyStorageTakeoutSpeciesWinView:UpdateNum(Num, IsNotCheckEqual)
	local TempNum = Num
	---去除非数字输入
	if type(TempNum) == "string" then
		TempNum = tonumber(TempNum)
		if nil == TempNum then
			self.TextNumber3:SetText(self.Num)
			return
		end
	end
	if self.Num == TempNum and not IsNotCheckEqual then
		return
	end
	local TextColor = "FFFFFFFF"
	--- 是否可以设置
	local IsCanInput = true
	if self.IsDeposit then
		if self.ArmyTotalMoneyNum + TempNum > ArmyMoneyMaxDepositNum or TempNum > self.PlayerMoneyNum or TempNum < 0 then
			IsCanInput = false
		end
	else
		if self.PlayerMoneyNum + TempNum > PlayerMoneyMaxNum or TempNum > self.ArmyTotalMoneyNum or TempNum < 0 then
			IsCanInput = false
		end
	end
	--- 数量变化时更新按钮状态
	if IsCanInput then
		self.Num = TempNum
		if self.IsDeposit then
			---加号和拉满按钮判断判断
			if self.ArmyTotalMoneyNum + self.Num >= ArmyMoneyMaxDepositNum or  self.Num >= self.PlayerMoneyNum or self.Num == 0 then
				UIUtil.ButtonSetBrush(self.BtnPlus, Btn_Plus_Disab)
				UIUtil.ButtonSetBrush(self.BtnArrow, Btn_Arrow_Disab)
			else
				UIUtil.ButtonSetBrush(self.BtnPlus, Btn_Plus_Normal)
				UIUtil.ButtonSetBrush(self.BtnArrow, Btn_Arrow_Normal)
			end
			---减号判断 
			if self.Num <= ArmyMoneySingleDepositMinNum then
				UIUtil.ButtonSetBrush(self.BtnReduce, Btn_Reduce_Disab)
				if self.Num < ArmyMoneySingleDepositMinNum then
					TextColor = "DC5868FF"
				end
			else
				UIUtil.ButtonSetBrush(self.BtnReduce, Btn_Reduce_Normal)
			end
			---确认按钮判断
			if self.Num < ArmyMoneySingleDepositMinNum then
				self.Btnsure:SetIsDisabledState(true, true)
			else
				self.Btnsure:SetIsRecommendState(true)
			end
		else
			---加号和拉满按钮判断判断
			if self.PlayerMoneyNum + self.Num >= PlayerMoneyMaxNum or  self.Num >= self.ArmyTotalMoneyNum or self.Num == 0 then
				UIUtil.ButtonSetBrush(self.BtnPlus, Btn_Plus_Disab)
				UIUtil.ButtonSetBrush(self.BtnArrow, Btn_Arrow_Disab)
			else
				UIUtil.ButtonSetBrush(self.BtnPlus, Btn_Plus_Normal)
				UIUtil.ButtonSetBrush(self.BtnArrow, Btn_Arrow_Normal)
			end
			---减号判断 
			if self.Num <= 1 then
				UIUtil.ButtonSetBrush(self.BtnReduce, Btn_Reduce_Disab)
			else
				UIUtil.ButtonSetBrush(self.BtnReduce, Btn_Reduce_Normal)
			end
			---确认按钮判断
			if self.Num <= 0 then
				self.Btnsure:SetIsDisabledState(true, true)
			else
				self.Btnsure:SetIsRecommendState(true)
			end
		end
	end
	--- 可操作数量为0时，显示为1
	if self.Num ~= 0 then
		self.TextNumber3:SetText(self.Num)
		local NumStr = ArmyMgr:FormatMoneyNumber(self.Num)
		-- LSTR string:金币
		self.TextSpecies:SetText(string.format("%sx%s",LSTR(910267), NumStr))
	else
		self.TextNumber3:SetText(1)
		-- LSTR string:金币
		self.TextSpecies:SetText(string.format("%sx%d",LSTR(910267),1))
		TextColor = "DC5868FF"
	end
	UIUtil.SetColorAndOpacityHex(self.TextNumber3, TextColor)
end

function ArmyStorageTakeoutSpeciesWinView:SetIsDepositPanel(IsDeposit, TotalNum)
	self.IsDeposit = IsDeposit
	self.ToggleBtnStorage:SetIsChecked(IsDeposit)
	self.ToggleBtnTakeOut:SetIsChecked(not IsDeposit)
	if self.IsDeposit then
		-- LSTR string:金币存入
		self.BG:SetTitleText(LSTR(910270))
		self:InitDepositPanel(TotalNum)
		UIUtil.SetIsVisible(self.HorizontalTaxRate, true)
	else
		-- LSTR string:金币取出
		self.BG:SetTitleText(LSTR(910269))
		self:InitTakeOutPanel(TotalNum)
		UIUtil.SetIsVisible(self.HorizontalTaxRate, false)
	end
end

function ArmyStorageTakeoutSpeciesWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btnsure, self.OnClickedSure)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedCanCel)
	UIUtil.AddOnClickedEvent(self, self.BtnPlus, self.OnClickedPlus)
	UIUtil.AddOnClickedEvent(self, self.BtnReduce, self.OnClickedReduce)
	UIUtil.AddOnClickedEvent(self, self.BtnArrow, self.OnClickedArrow)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnStorage, self.OnClickedStorage)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnTakeOut, self.OnClickedTakeOut)
	UIUtil.AddOnClickedEvent(self, self.BtnNumber3, self.OnClickedInputBtn)
	--UIUtil.AddOnTextCommittedEvent(self, self.InputText, self.OnTextCommitted)
end

function ArmyStorageTakeoutSpeciesWinView:OnRegisterGameEvent()

end

function ArmyStorageTakeoutSpeciesWinView:OnRegisterBinder()

end

---确认处理
function ArmyStorageTakeoutSpeciesWinView:OnClickedSure()
	if self.IsDeposit then
		if self.PlayerMoneyNum == 0 or self.ArmyTotalMoneyNum == ArmyMoneyMaxDepositNum or self.Num < ArmyMoneySingleDepositMinNum then
			---金币为0处理 或者 仓库达到上限处理
			self.IsError = true
			if self.PlayerMoneyNum == 0 then
				self.ErrorStr = ErrorTipsStr.InsufficientGold
			elseif self.ArmyTotalMoneyNum == ArmyMoneyMaxDepositNum then
				self.ErrorStr = ErrorTipsStr.StorageMaxNum
			elseif self.Num < ArmyMoneySingleDepositMinNum then
				self.ErrorStr = ErrorTipsStr.SingleDepositMinNum
			end
			MsgTipsUtil.ShowTips(self.ErrorStr)
		else
			---添加前置判断，如果未购买月卡，且未完成对应任务，不给点开
			ArmyMgr:SendGroupMoneyBagDepositAndCheck(self.Num, self.ArmyTotalMoneyNum)
		end
	else
		if self.ArmyTotalMoneyNum == 0 or self.PlayerMoneyNum == PlayerMoneyMaxNum then
			---存储为0处理 或者 自身金币达到上限处理
			self.IsError = true
			if self.ArmyTotalMoneyNum == 0 then
				self.ErrorStr = ErrorTipsStr.InsufficientGold
			else
				self.ErrorStr = ErrorTipsStr.PlayerMaxNum
			end
			MsgTipsUtil.ShowTips(self.ErrorStr)
		else
			---添加前置判断，如果未购买月卡，且未完成对应任务，不给点开
			ArmyMgr:SendGroupMoneyBagWithDrawAndCheck(self.Num, self.ArmyTotalMoneyNum)
		end
	end
	--存储失败不关闭界面
	--self:Hide()
end

---取消处理
function ArmyStorageTakeoutSpeciesWinView:OnClickedCanCel()
	self:Hide()
end

---添加处理
function ArmyStorageTakeoutSpeciesWinView:OnClickedPlus()
	---特殊情况，持有0或存储0
	if (self.IsDeposit and self.PlayerMoneyNum == 0) or (not self.IsDeposit and self.ArmyTotalMoneyNum == 0) then
		MsgTipsUtil.ShowTips(ErrorTipsStr.InsufficientGold)
		return
	end
	if self.IsDeposit  then
		if self.Num >= self.PlayerMoneyNum then
			MsgTipsUtil.ShowTips(ErrorTipsStr.MaxNum)
			return
		elseif self.ArmyTotalMoneyNum + self.Num >= ArmyMoneyMaxDepositNum then
			MsgTipsUtil.ShowTips(ErrorTipsStr.StorageMaxNum)
			return
		end
	else
		if self.Num >= self.ArmyTotalMoneyNum or self.Num + self.PlayerMoneyNum >= PlayerMoneyMaxNum then
			MsgTipsUtil.ShowTips(ErrorTipsStr.MaxNum)
			return
		end
	end
	self:UpdateNum(self.Num + 1)
end

---减少处理
function ArmyStorageTakeoutSpeciesWinView:OnClickedReduce()
	---特殊情况，持有0或存储0
	if (self.IsDeposit and self.PlayerMoneyNum == 0) or (not self.IsDeposit and self.ArmyTotalMoneyNum == 0) then
		MsgTipsUtil.ShowTips(ErrorTipsStr.InsufficientGold)
		return
	end
	if self.IsDeposit  then
		if self.Num <= ArmyMoneySingleDepositMinNum then
			MsgTipsUtil.ShowTips(ErrorTipsStr.MinNum)
			return
		end
	else
		if self.Num <= 1 then
			MsgTipsUtil.ShowTips(ErrorTipsStr.MinNum)
			return
		end
	end
	self:UpdateNum(self.Num - 1)
end

---拉满处理
function ArmyStorageTakeoutSpeciesWinView:OnClickedArrow()
	if self.IsDeposit then
		if self.Num >= self.PlayerMoneyNum then
			self.IsError = true
			self.ErrorStr = ErrorTipsStr.MaxNum
		elseif self.Num + self.ArmyTotalMoneyNum >= ArmyMoneyMaxDepositNum then
			self.IsError = true
			self.ErrorStr =  ErrorTipsStr.StorageMaxNum
		--- 如果全部存入超限，但可以部分存入，自动拉到最大
		elseif self.PlayerMoneyNum + self.ArmyTotalMoneyNum > ArmyMoneyMaxDepositNum then
			self.IsError = false
			self.ErrorStr = ErrorTipsStr.StorageMaxNum
			MsgTipsUtil.ShowTips(self.ErrorStr)
		else
			self.IsError = false
		end
	
		if not self.IsError  then
			if self.PlayerMoneyNum + self.ArmyTotalMoneyNum <= ArmyMoneyMaxDepositNum then
				self:UpdateNum(self.PlayerMoneyNum)
			else
				self:UpdateNum(ArmyMoneyMaxDepositNum - self.ArmyTotalMoneyNum)
			end
			
		end
	else
		if self.Num >= self.ArmyTotalMoneyNum then
			self.IsError = true
			self.ErrorStr =  ErrorTipsStr.MaxNum
		elseif self.Num + self.ArmyTotalMoneyNum >= PlayerMoneyMaxNum then
			self.IsError = true
			self.ErrorStr = ErrorTipsStr.PlayerMaxNum
		--- 如果全部取出超限，但可以部分取出，自动拉到最大
		elseif self.ArmyTotalMoneyNum + self.PlayerMoneyNum > PlayerMoneyMaxNum then
			self.IsError = false
			self.ErrorStr = ErrorTipsStr.PlayerMaxNum
			MsgTipsUtil.ShowTips(self.ErrorStr)
		else
			self.IsError = false
		end
		if not self.IsError  then
			if self.PlayerMoneyNum + self.ArmyTotalMoneyNum <= PlayerMoneyMaxNum then
				self:UpdateNum(self.ArmyTotalMoneyNum)
			else
				self:UpdateNum(PlayerMoneyMaxNum - self.PlayerMoneyNum)
			end
		end
	end
	---特殊情况，持有0或存储0
	if  (self.IsDeposit and self.PlayerMoneyNum == 0) or (not self.IsDeposit and self.ArmyTotalMoneyNum == 0)  then
		self.ErrorStr = ErrorTipsStr.InsufficientGold
	end
	if self.IsError then
		MsgTipsUtil.ShowTips(self.ErrorStr)
		self.IsError = false
	end
	UIUtil.ButtonSetBrush(self.BtnArrow, Btn_Arrow_Disab)
end

---切换到存入
function ArmyStorageTakeoutSpeciesWinView:OnClickedStorage()
	self.IsDeposit = true
	ArmyMgr:SendGroupMoneyBagQuery()
	--self:SetIsDepositPanel(true, self.ArmyTotalMoneyNum)
end

---切换到取出
function ArmyStorageTakeoutSpeciesWinView:OnClickedTakeOut()
	self.IsDeposit = false
	ArmyMgr:SendGroupMoneyBagQuery()
	--self:SetIsDepositPanel(false, self.ArmyTotalMoneyNum)
end

---输入处理
function ArmyStorageTakeoutSpeciesWinView:OnInputCommitted(Num)
	local TempNum = Num
	if type(TempNum) == "string" then
		TempNum = tonumber(TempNum)
		if nil == TempNum then
			return
		end
	end
	local ErrorStr
	if self.IsDeposit then
		---小于最小单笔允许输入，但不允许提交
		if TempNum >= self.PlayerMoneyNum then
			self.IsError = true
			ErrorStr = ErrorTipsStr.PlayerMaxNum
		elseif TempNum + self.ArmyTotalMoneyNum > ArmyMoneyMaxDepositNum then
			self.IsError = true
			ErrorStr = ErrorTipsStr.StorageMaxNum
		else
			self.IsError = false
		end
		if self.IsError  then
			MsgTipsUtil.ShowTips(ErrorStr)
			if self.PlayerMoneyNum + self.ArmyTotalMoneyNum <= ArmyMoneyMaxDepositNum then
				self:UpdateNum(self.PlayerMoneyNum, true)
			else
				self:UpdateNum(ArmyMoneyMaxDepositNum - self.ArmyTotalMoneyNum, true)
			end
		else
			self:UpdateNum(TempNum)
		end
	else
		if TempNum >= self.ArmyTotalMoneyNum then
			self.IsError = true
			ErrorStr = ErrorTipsStr.TakeoutMaxNum
		elseif TempNum + self.ArmyTotalMoneyNum > PlayerMoneyMaxNum then
			self.IsError = true
			ErrorStr = ErrorTipsStr.PlayerMaxNum
		else
			self.IsError = false
		end
		if self.IsError  then
			MsgTipsUtil.ShowTips(ErrorStr)
			if self.PlayerMoneyNum + self.ArmyTotalMoneyNum <= PlayerMoneyMaxNum then
				self:UpdateNum(self.ArmyTotalMoneyNum, true)
			else
				self:UpdateNum(PlayerMoneyMaxNum - self.PlayerMoneyNum, true)
			end
		else
			self:UpdateNum(TempNum)
		end
	end
end

function ArmyStorageTakeoutSpeciesWinView:OnClickedInputBtn()
	local ConfirmCallback =
	function(Num)
	 	self:OnInputCommitted(Num)
	end
	local ShowCallback = 
	function(Num)
		self.TextNumber3:SetText(Num)
		-- LSTR string:金币
		--self.TextSpecies:SetText(string.format("%sx%d",LSTR(910267),Num))
   	end

	local Params = { CutValue = self.Num, ConfirmCallback = ConfirmCallback , 
					ShowCallback = ShowCallback, LowerLimit = self.LowerLimit, UpperLimit = self.UpperLimit, }
	local View = UIViewMgr:ShowView(UIViewID.CommMiniKeypadWin, Params)
	local KetpadSize = UIUtil.CanvasSlotGetSize(View.FCanvasPanel_3)
	local BtnSize = UIUtil.GetWidgetSize(self.BtnNumber3)
	local InOffset = _G.UE.FVector2D( -BtnSize.X - KetpadSize.X - 20, -KetpadSize.Y + 100)
	TipsUtil.AdjustTipsPosition(View.FCanvasPanel_3, self.BtnNumber3, InOffset, _G.UE.FVector2D(0, 0))
end

return ArmyStorageTakeoutSpeciesWinView