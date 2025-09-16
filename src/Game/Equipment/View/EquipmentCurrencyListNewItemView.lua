---
--- Author: ds_tianjiateng
--- DateTime: 2025-04-08 14:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetButtonBrush = require("Binder/UIBinderSetButtonBrush")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local HelpCfg = require("TableCfg/HelpCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local BattlePassMgr = require("Game/BattlePass/BattlePassMgr")
local TimeUtil = require("Utils/TimeUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class EquipmentCurrencyListNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBP UFButton
---@field BtnInfo CommInforBtnView
---@field BtnShop UFButton
---@field FImage_445 UFImage
---@field HorizontalItem2 UFHorizontalBox
---@field IconBP UFImage
---@field ImgStyleIcon UFImage
---@field NewItemSlot EquipmentCurrencySlotItemView
---@field RichTextTimeLeft URichTextBox
---@field RichTextWeek URichTextBox
---@field TextCurrencyTitle UFTextBlock
---@field TextItemName UFTextBlock
---@field TextItemNum UFTextBlock
---@field AnimCurrencyIterationIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentCurrencyListNewItemView = LuaClass(UIView, true)

function EquipmentCurrencyListNewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBP = nil
	--self.BtnInfo = nil
	--self.BtnShop = nil
	--self.FImage_445 = nil
	--self.HorizontalItem2 = nil
	--self.IconBP = nil
	--self.ImgStyleIcon = nil
	--self.NewItemSlot = nil
	--self.RichTextTimeLeft = nil
	--self.RichTextWeek = nil
	--self.TextCurrencyTitle = nil
	--self.TextItemName = nil
	--self.TextItemNum = nil
	--self.AnimCurrencyIterationIn = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentCurrencyListNewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.NewItemSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentCurrencyListNewItemView:OnInit()
	self.IsNeedPlayConvertAnim = true
	self.Binders = {
		{ "TextItemName", 		UIBinderSetText.New(self, self.TextItemName) },
		{ "TextItemNum", 		UIBinderSetText.New(self, self.TextItemNum) },
		{ "JumpIconPath", 		UIBinderSetButtonBrush.New(self, self.BtnShop, nil) },
		{ "ImgInfoIsVisible", 	UIBinderSetIsVisible.New(self, self.BtnInfo) },
		{ "BtnShopIsVisible", 	UIBinderSetIsVisible.New(self, self.BtnShop, nil, true) },
		{ "WeekUpperVisible", 	UIBinderSetIsVisible.New(self, self.HorizontalItem2) },
		{ "WeekUpperText", 		UIBinderSetText.New(self, self.RichTextWeek) },
		{ "IconBPIconPath", 	UIBinderSetBrushFromAssetPath.New(self, self.IconBP)},
		{ "CurrencyTitle", 		UIBinderSetText.New(self, self.TextCurrencyTitle)},
		{ "IconSubType", 		UIBinderSetBrushFromAssetPath.New(self, self.ImgStyleIcon)},
	}
	self.NewItemSlot.Comm96Slot:SetClickButtonCallback(self, self.OnClickButtonItem)
end

function EquipmentCurrencyListNewItemView:OnDestroy()

end

function EquipmentCurrencyListNewItemView:OnShow()
	UIUtil.ImageSetBrushFromAssetPath(self.FImage_445, self.ViewModel.TargetIcon)
	self.IsNeedPlayConvertAnim = true
	-- EquipmentCurrencyVM:UpdateViewPossessScoreNum(self)
	if self.ViewModel.JumpIconPath == "" then
		UIUtil.ButtonSetBrush(self.BtnShop, "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Shop_png.UI_Comm_Btn_Shop_png'")
	end
	UIUtil.SetIsVisible(self.RichTextTimeLeft, false)
	UIUtil.SetIsVisible(self.FImage_445, false)
	if self.Timer == nil then
		self.Timer = self:RegisterTimer(self.OnSetCountDownNum, 0, 1, 0)
	end
	self.BtnInfo.HelpInfoID = self.ViewModel.Desc or -1

	self.NewItemSlot.Comm96Slot.ScoreID = self.ViewModel.ScoreID
	if self.ViewModel.ScoreTableCfg.TargetScore ~= 0 then
		if self.ViewModel.IsDuringConvertimeCD then
			UIUtil.ImageSetBrushFromAssetPath(self.FImage_445, self.ViewModel.TargetIcon)
		end
	end
	if self.ViewModel ~= nil then
		local TempItemVisible = self.ViewModel.WeekUpperNum ~= 0 or self.ViewModel.WeekUpperFixedNum ~= 0 or #(self.ViewModel.ScoreTableCfg.WeekUpper.CondValues or {}) > 0 
		UIUtil.SetIsVisible(self.HorizontalItem2, TempItemVisible)
	end
end

function EquipmentCurrencyListNewItemView:OnHide()
	if self.Timer ~= nil then
		self:UnRegisterTimer(self.Timer)
		self.Timer = nil
	end
	UIUtil.SetIsVisible(self.RichTextTimeLeft, false)
	UIUtil.SetIsVisible(self.FImage_445, false)
end

function EquipmentCurrencyListNewItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnShop, self.OnClickButtonShop)
	-- UIUtil.AddOnClickedEvent(self, self.BtnBP, self.OnClickButtonBP)
end

function EquipmentCurrencyListNewItemView:OnRegisterGameEvent()

end

function EquipmentCurrencyListNewItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = Params.Data
	if nil == Data then
		return
	end

	local ViewModel = Params.Data

	self.ViewModel = ViewModel

	
	self.BtnInfo.HelpInfoID = ViewModel.Desc or -1
	self:RegisterBinders(ViewModel, self.Binders)
end

function EquipmentCurrencyListNewItemView:OnSetCountDownNum()
	if self.ViewModel == nil or self.ViewModel.ScoreTableCfg.TargetScore == 0 then
		self:OnHide()
		return
	end
	local ScoreTableCfg = self.ViewModel.ScoreTableCfg
	local NextConvertTime = ScoreTableCfg.NextConvertTime
	if NextConvertTime ~= "" then
		local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
		local year, month, day, hour, min, sec = NextConvertTime:match(pattern)
		local timestamp = os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec})
		local servertime = _G.TimeUtil.GetServerTime()
		local TampTime =  timestamp - servertime
		if TampTime <= ScoreTableCfg.TimeInterval and TampTime > 0 then
			if self.IsNeedPlayConvertAnim then
				self.IsNeedPlayConvertAnim = false
				UIUtil.ImageSetBrushFromAssetPath(self.FImage_445, self.ViewModel.TargetIcon)
				self:PlayAnimation(self.AnimCurrencyIterationIn)
			end
			UIUtil.SetIsVisible(self.RichTextTimeLeft, true)
			UIUtil.SetIsVisible(self.FImage_445, true)
			local LocalLizationTime = LocalizationUtil.GetCountdownTimeForLongTime(TampTime, "hh:mm:ss") or ""
			local ContentLSTR = LSTR(1050005)
			self.RichTextTimeLeft:SetText(string.format(ContentLSTR, LocalLizationTime))
		else
			UIUtil.SetIsVisible(self.RichTextTimeLeft, false)
			UIUtil.SetIsVisible(self.FImage_445, false)
		end
	else
		-- 不存在转化目标积分
		UIUtil.SetIsVisible(self.RichTextTimeLeft, false)
		UIUtil.SetIsVisible(self.FImage_445, false)
	end
end

function EquipmentCurrencyListNewItemView:OnClickButtonShop()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	self.BtnShopClicked = true
	self.BtnInfoClicked = false
	Adapter:OnItemClicked(self, Params.Index)
end

function EquipmentCurrencyListNewItemView:OnClickButtonItem()
	local ScoreID = self.ViewModel.ScoreID
	if ScoreID ~= nil then
		ItemTipsUtil.CurrencyTips(ScoreID, true, self.NewItemSlot, {X = 25, Y = 0})
	end
end

--- 弃用
function EquipmentCurrencyListNewItemView:OnClickButtonBP()
	if true then
		return
	end
	local VM = self.ViewModel
	local tipsContent = nil
	local FilterFunction = function (Index, Value)
		return Index == 1
	end
	local HelpCfgInfo = nil
	---根据战令等级读取不同的帮助说明表内容
	if BattlePassMgr:GetBattlePassGrade() == 3 then
		HelpCfgInfo = HelpCfg:FindAllHelpIDCfg(10021)
		local HelpContent = HelpInfoUtil.ParseContent(HelpCfgInfo)
		local EndTime = BattlePassMgr:GetBattlePassEndTime()
		local RemainTime = 0
		if EndTime ~= "" then
			local Timestamp = TimeUtil.GetTimeFromString(EndTime)
			local Servertime = TimeUtil.GetServerTime()
			RemainTime =  Timestamp - Servertime
		end
		if RemainTime <= 0 then
			RemainTime = 0
		end
		local BattlePassRemainTime = LocalizationUtil.GetCountdownTimeForLongTime(RemainTime)
		tipsContent = HelpInfoUtil.ParseTextWithPlaceholders(HelpContent, FilterFunction, VM.WeekUpperFloatNum, BattlePassRemainTime)
	else
		HelpCfgInfo = HelpCfg:FindAllHelpIDCfg(10020)
		local HelpContent = HelpInfoUtil.ParseContent(HelpCfgInfo)
		tipsContent = HelpInfoUtil.ParseTextWithPlaceholders(HelpContent, FilterFunction, VM.WeekUpperFloatNum)
	end

	if tipsContent == nil then
		return
	end
	if HelpCfgInfo ~= nil then
		local Dir = HelpCfgInfo[1].Direction and HelpCfgInfo[1].Direction or 1
		local Offset, Alignment = HelpInfoUtil.GetOffsetAndAlignment(self.BtnBP, Dir)
		TipsUtil.ShowInfoTitleTips(tipsContent, self.BtnBP, Offset, Alignment)
	end
end

return EquipmentCurrencyListNewItemView