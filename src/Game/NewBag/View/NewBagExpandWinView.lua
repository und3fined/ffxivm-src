---
--- Author: Administrator
--- DateTime: 2023-09-07 19:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BagExpandWinVM = require("Game/NewBag/VM/BagExpandWinVM")
local BagEnlargeCfg = require("TableCfg/BagEnlargeCfg")
local ItemUtil = require("Utils/ItemUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local BagMgr = _G.BagMgr
local ScoreMgr = _G.ScoreMgr
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local EventID = _G.EventID
local LSTR = _G.LSTR
---@class NewBagExpandWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BagSlot BagSlotView
---@field BtnExpand CommBtnLView
---@field BtnIcon UFButton
---@field FHorizontalConsume UFHorizontalBox
---@field HorizonBox UFHorizontalBox
---@field ImgIcon UFImage
---@field Money1 CommMoneySlotView
---@field RichTextHint URichTextBox
---@field RichTextNumber URichTextBox
---@field TextCurrent UFTextBlock
---@field TextExpandto UFTextBlock
---@field TextNeed UFTextBlock
---@field TextNumber1 UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagExpandWinView = LuaClass(UIView, true)

function NewBagExpandWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BagSlot = nil
	--self.BtnExpand = nil
	--self.BtnIcon = nil
	--self.FHorizontalConsume = nil
	--self.HorizonBox = nil
	--self.ImgIcon = nil
	--self.Money1 = nil
	--self.RichTextHint = nil
	--self.RichTextNumber = nil
	--self.TextCurrent = nil
	--self.TextExpandto = nil
	--self.TextNeed = nil
	--self.TextNumber1 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagExpandWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BagSlot)
	self:AddSubView(self.BtnExpand)
	self:AddSubView(self.Money1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagExpandWinView:OnInit()
	self.Binders = {
		{ "ItemNumberText", UIBinderSetText.New(self, self.RichTextNumber) },

		{ "ConsumeScoreVisible", UIBinderSetIsVisible.New(self, self.FHorizontalConsume) },
		{ "CostScoreText", UIBinderSetTextFormatForMoney.New(self, self.TextNumber1) },
		{ "CostScoreColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNumber1) },
		{ "ScoreIconImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "ExpandBtnEnable", UIBinderSetIsEnabled.New(self, self.BtnExpand, false, true)},

		{ "CurrentNum", UIBinderSetText.New(self, self.TextCurrent)},
		{ "EnlargeNum", UIBinderSetText.New(self, self.TextExpandto)},
	
		{ "CostPropsVisible", UIBinderSetIsVisible.New(self, self.HorizonBox) },
	
		{ "TipsDecText", UIBinderSetText.New(self, self.RichTextHint) },
		
	}
end

function NewBagExpandWinView:OnDestroy()

end

function NewBagExpandWinView:OnShow()
	BagExpandWinVM:UpdateVM(BagMgr.Enlarge)
	if BagExpandWinVM.ConsumeScoreVisible == true then
		self.BtnExpand:SetButtonText(LSTR(10002))
	else
		self.BtnExpand:SetButtonText(LSTR(990077))
	end
	local ScoreID = BagExpandWinVM.ScoreID
	self.Money1:UpdateView(ScoreID, false, nil, true)
end

function NewBagExpandWinView:OnHide()

end

function NewBagExpandWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnExpand.Button, self.OnBtnExpandClick)
	UIUtil.AddOnClickedEvent(self, self.BagSlot.BtnSlot, self.OnBtnSlotClick)
	UIUtil.AddOnClickedEvent(self, self.BtnIcon, self.OnBtnMoneyIconClick)
end

function NewBagExpandWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ScoreUpdate, self.OnMoneyUpdate)
end

function NewBagExpandWinView:OnRegisterBinder()
	self:RegisterBinders(BagExpandWinVM, self.Binders)
	self.BagSlot:SetParams({Data = BagExpandWinVM.BagSlotVM})

	self.TextNeed:SetText(LSTR(990063))
	self.BG:SetTitleText(LSTR(990076))
end


function NewBagExpandWinView:OnBtnExpandClick()
	local NeedCost = BagExpandWinVM.CostScoreText
	local ScoreID = BagExpandWinVM.ScoreID
	local CurrentScore = ScoreMgr:GetScoreValueByID(ScoreID)
	if BagExpandWinVM.CostPropsVisible then
		if NeedCost > CurrentScore then
			local CostName = ScoreMgr:GetScoreNameText(ScoreID) or ""
			_G.MsgTipsUtil.ShowTips(string.format(_G.LSTR(990038), CostName))
			return
		end
	else
		if NeedCost > CurrentScore then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(100030), LSTR(100031), function ()
				RechargingMgr:ShowMainPanel()
			end)
			return
		end
	end
	BagMgr:SendMsgBagBuyReq()
	self:Hide()
end

function NewBagExpandWinView:OnBtnMoneyIconClick()
	local ScoreID = BagExpandWinVM.ScoreID
	ItemTipsUtil.ShowTipsByResID(ScoreID, self.ImgIcon)
end

function NewBagExpandWinView:OnBtnSlotClick()
	local CfgRow = BagEnlargeCfg:FindCfgByKey(BagMgr.Enlarge)
	if CfgRow then
		ItemTipsUtil.ShowTipsByResID(CfgRow.ItemID, self.BagSlot)
	end
end

function NewBagExpandWinView:OnMoneyUpdate()
	if BagExpandWinVM.ConsumeScoreVisible == true then
		BagExpandWinVM:UpdateVM(BagMgr.Enlarge)
	end
end

return NewBagExpandWinView