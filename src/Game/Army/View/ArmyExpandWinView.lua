---
--- Author: Administrator
--- DateTime: 2023-12-12 16:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyExpandWinVM = require("Game/Army/VM/ArmyExpandWinVM")
local BagEnlargeCfg = require("TableCfg/BagEnlargeCfg")
local ItemUtil = require("Utils/ItemUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local ArmyMgr = _G.ArmyMgr
local ScoreMgr = _G.ScoreMgr
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local EventID = _G.EventID

---@class ArmyExpandWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArmyDepotSlot ArmyDepotSlotView
---@field BG Comm2FrameSView
---@field BtnExpand CommBtnLView
---@field CheckBoxConsume CommCheckBoxView
---@field CheckBoxLack CommCheckBoxView
---@field FHorizontalConsume UFHorizontalBox
---@field ImgIcon UFImage
---@field RichTextNumber URichTextBox
---@field RichTextTitle URichTextBox
---@field TextName UFTextBlock
---@field TextNumber1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyExpandWinView = LuaClass(UIView, true)

function ArmyExpandWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArmyDepotSlot = nil
	--self.BG = nil
	--self.BtnExpand = nil
	--self.CheckBoxConsume = nil
	--self.CheckBoxLack = nil
	--self.FHorizontalConsume = nil
	--self.ImgIcon = nil
	--self.RichTextNumber = nil
	--self.RichTextTitle = nil
	--self.TextName = nil
	--self.TextNumber1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyExpandWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ArmyDepotSlot)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnExpand)
	self:AddSubView(self.CheckBoxConsume)
	self:AddSubView(self.CheckBoxLack)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyExpandWinView:OnInit()
	self.Binders = {
		{ "ItemNumberText", UIBinderSetText.New(self, self.RichTextNumber) },
		{ "NameText", UIBinderSetText.New(self, self.TextName) },
		{ "EnlargeTitleText", UIBinderSetText.New(self, self.RichTextTitle) },
		{ "ConsumeScoreVisible", UIBinderSetIsVisible.New(self, self.FHorizontalConsume) },
		{ "LackCheckBoxVisible", UIBinderSetIsVisible.New(self, self.CheckBoxLack) },
		{ "CostScoreText", UIBinderSetTextFormatForMoney.New(self, self.TextNumber1) },
		{ "CostScoreColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNumber1) },
		{ "ScoreIconImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "ExpandBtnEnable", UIBinderSetIsEnabled.New(self, self.BtnExpand)},
	}
end

function ArmyExpandWinView:OnDestroy()

end

function ArmyExpandWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	ArmyExpandWinVM:UpdateVM(Params.EnlargeID, Params.StoreID)
	if ArmyExpandWinVM.ExpandBtnEnable == false then
		self.CheckBoxLack:SetChecked(false)
	end

	local CfgRow = BagEnlargeCfg:FindCfgByKey(Params.EnlargeID)
	if CfgRow then
		-- LSTR string:材料不足消耗%s补足
		self.CheckBoxLack:SetText(string.format(_G.LSTR(910167), ItemUtil.GetItemName(CfgRow.ScoreID)))
	end
end

function ArmyExpandWinView:OnHide()

end

function ArmyExpandWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CheckBoxLack.ToggleButton, self.OnBtnLackClick)
	UIUtil.AddOnClickedEvent(self, self.CheckBoxConsume.ToggleButton, self.OnBtnConsumeClick)
	UIUtil.AddOnClickedEvent(self, self.BtnExpand.Button, self.OnBtnExpandClick)
end

function ArmyExpandWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ScoreUpdate, self.OnMoneyUpdate)
end

function ArmyExpandWinView:OnRegisterBinder()
	self:RegisterBinders(ArmyExpandWinVM, self.Binders)
	self.ArmyDepotSlot:SetParams({Data = ArmyExpandWinVM.ArmyDepotSlotVM})
end

function ArmyExpandWinView:OnBtnLackClick()
	ArmyExpandWinVM:SetConsumeScore()
	self.CheckBoxConsume:SetChecked(true)
end

function ArmyExpandWinView:OnBtnConsumeClick()
	ArmyExpandWinVM:SetConsumeItem()
	self.CheckBoxLack:SetChecked(false)
end

function ArmyExpandWinView:OnBtnExpandClick()
	local NeedCost = ArmyExpandWinVM.CostScoreText
	local ScoreID = ArmyExpandWinVM.ScoreID
	if NeedCost > ScoreMgr:GetScoreValueByID(ScoreID) then
        local Params = {ScoreID = ScoreID, RecommendedExchange = NeedCost}
		UIViewMgr:ShowView(UIViewID.MarketExchangeWin, Params)
		return
    end
	ArmyMgr:SendGroupStoreAddExtraGrid(ArmyExpandWinVM.StoreID)
	self:Hide()
end

function ArmyExpandWinView:OnMoneyUpdate()
	if ArmyExpandWinVM.ConsumeScoreVisible == true then
		local Params = self.Params
		if nil == Params then
			return
		end
		ArmyExpandWinVM:UpdateVM(Params.EnlargeID, Params.StoreID)
		self:OnBtnLackClick()
	end
end
return ArmyExpandWinView