---
--- Author: v_zanchang
--- DateTime: 2023-04-14 16:25
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
local BattlePassMgr = require("Game/BattlePass/BattlePassMgr")
local HelpCfg = require("TableCfg/HelpCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TipsUtil = require("Utils/TipsUtil")
local TimeUtil = require("Utils/TimeUtil")

---@class EquipmentCurrencyListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBP UFButton
---@field BtnInfo CommInforBtnView
---@field BtnShop UFButton
---@field Comm74Slot CommBackpack74SlotView
---@field HorizontalItem2 UFHorizontalBox
---@field IconBP UFImage
---@field ItemSlot CommBackpackSlotView
---@field ItemSlotConvert CommBackpackSlotView
---@field NewItemSlot EquipmentCurrencySlotItemView
---@field PanelCurrencyIteration UFCanvasPanel
---@field RichTextTimeLeft URichTextBox
---@field RichTextWeek URichTextBox
---@field TextItemName UFTextBlock
---@field TextItemNum UFTextBlock
---@field AnimCurrencyIterationIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentCurrencyListItemView = LuaClass(UIView, true)

function EquipmentCurrencyListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBP = nil
	--self.BtnInfo = nil
	--self.BtnShop = nil
	--self.Comm74Slot = nil
	--self.HorizontalItem2 = nil
	--self.IconBP = nil
	--self.ItemSlot = nil
	--self.ItemSlotConvert = nil
	--self.NewItemSlot = nil
	--self.PanelCurrencyIteration = nil
	--self.RichTextTimeLeft = nil
	--self.RichTextWeek = nil
	--self.TextItemName = nil
	--self.TextItemNum = nil
	--self.AnimCurrencyIterationIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentCurrencyListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.Comm74Slot)
	-- self:AddSubView(self.ItemSlot)
	-- self:AddSubView(self.ItemSlotConvert)
	self:AddSubView(self.NewItemSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentCurrencyListItemView:OnInit()
	self.IsNeedPlayConvertAnim = true
end

function EquipmentCurrencyListItemView:OnDestroy()

end

function EquipmentCurrencyListItemView:OnShow()
	UIUtil.ImageSetBrushFromAssetPath(self.Comm74Slot.Icon, self.ViewModel.TargetIcon)
	self.IsNeedPlayConvertAnim = true
	-- EquipmentCurrencyVM:UpdateViewPossessScoreNum(self)
	if self.ViewModel.JumpIconPath == "" then
		UIUtil.ButtonSetBrush(self.BtnShop, "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Shop_png.UI_Comm_Btn_Shop_png'")
	end
	UIUtil.SetIsVisible(self.RichTextTimeLeft, false)
	UIUtil.SetIsVisible(self.Comm74Slot, false)
	if self.Timer == nil then
		self.Timer = self:RegisterTimer(self.OnSetCountDownNum, 0, 1, 0)
	end
	self.BtnInfo.HelpInfoID = self.ViewModel.Desc or -1

	self.NewItemSlot.Comm96Slot.ScoreID = self.ViewModel.ScoreID
	if self.ViewModel.ScoreTableCfg.TargetScore ~= 0 then
		UIUtil.SetIsVisible(self.PanelCurrencyIteration, false, false)
		self.Comm74Slot.ScoreID = self.ViewModel.ScoreTableCfg.TargetScore
		if self.ViewModel.IsDuringConvertimeCD then
			UIUtil.ImageSetBrushFromAssetPath(self.Comm74Slot.Icon, self.ViewModel.TargetIcon)
			UIUtil.ImageSetBrushFromAssetPath(self.Comm74Slot.ImgQuanlity, self.ViewModel.TargetImgQuanlity)
		end
	end
end

function EquipmentCurrencyListItemView:OnHide()
	if self.Timer ~= nil then
		self:UnRegisterTimer(self.Timer)
		self.Timer = nil
	end
	UIUtil.SetIsVisible(self.PanelCurrencyIteration, false, false)
	UIUtil.SetIsVisible(self.RichTextTimeLeft, false)
	UIUtil.SetIsVisible(self.Comm74Slot, false)
end

function EquipmentCurrencyListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnShop, self.OnClickButtonShop)
	-- UIUtil.AddOnClickedEvent(self, self.NewItemSlot.FBtn_Item, self.OnClickButtonItem)
	-- UIUtil.AddOnClickedEvent(self, self.BtnBP, self.OnClickButtonBP)
	-- UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnClickButtonInfo)
end

function EquipmentCurrencyListItemView:OnRegisterGameEvent()

end

function EquipmentCurrencyListItemView:OnRegisterBinder()

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

	local Binders = {
	   { "TextItemName", UIBinderSetText.New(self, self.TextItemName) },
	   { "TextItemNum", UIBinderSetText.New(self, self.TextItemNum) },
	   { "IsShowTextLevel", UIBinderSetIsVisible.New(self, self.Comm74Slot.RichTextLevel) },
	   { "JumpIconPath", UIBinderSetButtonBrush.New(self, self.BtnShop, nil) },
	   { "ImgInfoIsVisible", UIBinderSetIsVisible.New(self, self.BtnInfo) },
	   { "BtnShopIsVisible", UIBinderSetIsVisible.New(self, self.BtnShop, nil, true) },
	   { "WeekUpperVisible", UIBinderSetIsVisible.New(self, self.HorizontalItem2) },
	   { "WeekUpperText", UIBinderSetText.New(self, self.RichTextWeek) },
	   { "IconBPIconPath", UIBinderSetBrushFromAssetPath.New(self, self.IconBP)}
	}
	self:RegisterBinders(ViewModel, Binders)
end

function EquipmentCurrencyListItemView:OnSetCountDownNum()
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
				UIUtil.SetIsVisible(self.PanelCurrencyIteration, true, false)
				UIUtil.ImageSetBrushFromAssetPath(self.Comm74Slot.Icon, self.ViewModel.TargetIcon)
				self:PlayAnimation(self.AnimCurrencyIterationIn)
			end
			UIUtil.SetIsVisible(self.RichTextTimeLeft, true)
			UIUtil.SetIsVisible(self.Comm74Slot, true)
			local LocalLizationTime = LocalizationUtil.GetCountdownTimeForLongTime(TampTime, "hh:mm:ss") or ""
			local ContentLSTR = LSTR(1050005)
			self.RichTextTimeLeft:SetText(string.format(ContentLSTR, LocalLizationTime))
		else
			UIUtil.SetIsVisible(self.RichTextTimeLeft, false)
			UIUtil.SetIsVisible(self.Comm74Slot, false)
			UIUtil.SetIsVisible(self.PanelCurrencyIteration, false, false)
		end
    else
        -- 不存在转化目标积分
		UIUtil.SetIsVisible(self.RichTextTimeLeft, false)
		UIUtil.SetIsVisible(self.Comm74Slot, false)
		UIUtil.SetIsVisible(self.PanelCurrencyIteration, false, false)
    end
end

function EquipmentCurrencyListItemView:OnClickButtonShop()
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

function EquipmentCurrencyListItemView:OnClickButtonItem()
	local ScoreID = self.ViewModel.ScoreID
	if ScoreID ~= nil then
		ItemTipsUtil.CurrencyTips(ScoreID, true, self.NewItemSlot)
	end
end

--- 弃用
function EquipmentCurrencyListItemView:OnClickButtonBP()
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

-- 已弃用 改为CommInforBtnView
function EquipmentCurrencyListItemView:OnClickButtonInfo()
	if true then
		return
	end
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	self.BtnShopClicked = false
	self.BtnInfoClicked = true
	Adapter:OnItemClicked(self, Params.Index)
end

return EquipmentCurrencyListItemView