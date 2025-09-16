---
--- Author: qibaoyiyi
--- DateTime: 2023-05-20 10:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
--local UIViewID = require("Define/UIViewID")
--local ShopVM = require("Game/Shop/ShopVM")
local ScoreMgr = require("Game/Score/ScoreMgr")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")

local UIBinderSetIconItemAndScore = require("Binder/UIBinderSetIconItemAndScore")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local BagMgr = require("Game/Bag/BagMgr")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")

--local UIViewMgr = _G.UIViewMgr
--local UIViewID = _G.UIViewID

--- 通用货币槽组件
--- 因功能需要有两套刷新逻辑
--- 1. 通过UI直接刷新：调用控件实例的CommMoneySlotView:UpdateView方法即可。货币的数量刷新由监听事件更新（此方式暂时支持货币）
--- 2. 作为TableView等组件的子Item刷新：参照MVVM框架，绑定VM刷新。货币的数量刷新通过再次刷新VM更新（此方式支持货币与道具）
--- 方式2可参照VM：ShopCostItemVM
---@class CommMoneySlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnMoney UFButton
---@field ImgAdd UFImage
---@field ImgMoney UFImage
---@field PanelMoney UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextMoneyAmount UFTextBlock
---@field AnimCommGet UWidgetAnimation
---@field AnimCrystalGet UWidgetAnimation
---@field AnimGet1 UWidgetAnimation
---@field AnimGet2 UWidgetAnimation
---@field AnimGet3 UWidgetAnimation
---@field AnimGet4 UWidgetAnimation
---@field AnimGet5 UWidgetAnimation
---@field AnimGet6 UWidgetAnimation
---@field AnimGet7 UWidgetAnimation
---@field AnimGet8 UWidgetAnimation
---@field AnimGoldGet UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommMoneySlotView = LuaClass(UIView, true)

function CommMoneySlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnMoney = nil
	--self.ImgAdd = nil
	--self.ImgMoney = nil
	--self.PanelMoney = nil
	--self.RedDot = nil
	--self.TextMoneyAmount = nil
	--self.AnimCommGet = nil
	--self.AnimCrystalGet = nil
	--self.AnimGet1 = nil
	--self.AnimGet2 = nil
	--self.AnimGet3 = nil
	--self.AnimGet4 = nil
	--self.AnimGet5 = nil
	--self.AnimGet6 = nil
	--self.AnimGet7 = nil
	--self.AnimGet8 = nil
	--self.AnimGoldGet = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommMoneySlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommMoneySlotView:OnInit()
	self.ScoreID = 0
	self.LinkToViewID = 0
	self.IsTextWithMaxCount = false
	self.bUpdateCostValueByEvt = true
	self.bForceNotUpdateVal = false
	self.Binders = {
        {"CostNum", UIBinderSetTextFormatForMoney.New(self, self.TextMoneyAmount)},
        {"CostId", UIBinderSetIconItemAndScore.New(self, self.ImgMoney)},
		{"bShowExchange", UIBinderSetIsVisible.New(self, self.ImgAdd)},
		{"bShowExchange", UIBinderSetIsVisible.New(self, self.BtnAdd, false, true)},
    }
end

function CommMoneySlotView:OnDestroy()

end

function CommMoneySlotView:OnShow()
	local bVMValid = true
	local ViewModel = nil
	local Params = self.Params
    if nil == Params then
		bVMValid = false
	else
		ViewModel = Params.Data
		if nil == ViewModel then
			bVMValid = false
		else
			if ViewModel.bActiveByView == true then
				bVMValid = false
			end
		end
    end

	if bVMValid == false then
		self.bUpdateCostValueByEvt = true
		return
	end

	self.bUpdateCostValueByEvt = false
	if ViewModel.bShowExchange == true then
		self.ScoreID = ViewModel.CostId
		self.LinkToViewID = ViewModel.LinkToViewID
	end
end

function CommMoneySlotView:OnHide()
	
end

function CommMoneySlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnClickBtnAdd)
	UIUtil.AddOnClickedEvent(self, self.BtnMoney, self.OnClickBtnMoney)
end

function CommMoneySlotView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateScore, self.OnUpdateScoreValue)
	self:RegisterGameEvent(EventID.PlayGetScoreAni, self.PlayScoreAni)
end

function CommMoneySlotView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

	if ViewModel.bActiveByView == false then
		self:RegisterBinders(ViewModel, self.Binders)
	end
end

---@type 刷新界面参数
---@param ScoreID number 积分表ID
---@param bLinkToView boolean 是否关联到界面
---@param UIViewID number UIViewID参数
---@param IsScore boolean 是否是积分类型
---@param IsTextWithMaxCount boolean 是否显示上限
function CommMoneySlotView:UpdateView(ScoreID, bLinkToView, UIViewID, IsScore, IsTextWithMaxCount)
	local IsItem = false
	if not IsScore then
		IsItem = true
	end
	self.IsScore = IsScore
	self.ScoreID = ScoreID
	self.IsTextWithMaxCount = IsTextWithMaxCount
	if not IsItem then
		local ScoreIcon = ScoreMgr:GetScoreIconName(ScoreID)
		if ScoreIcon then
			UIUtil.SetIsVisible(self.ImgMoney, true, false, false)
			UIUtil.ImageSetBrushFromAssetPath(self.ImgMoney, ScoreIcon)
		else
			UIUtil.SetIsVisible(self.ImgMoney, false, false, false)
		end
	
		local ScoreValue = self:GetScoreValueText(ScoreID)
		self.TextMoneyAmount:SetText(ScoreValue)
	else
		UIUtil.SetIsVisible(self.ImgMoney, true, false, false)
		local Cfg = ItemCfg:FindCfgByKey(ScoreID)
		if nil ~= Cfg then
			local Path = UIUtil.GetIconPath(Cfg.IconID)
			if nil == Path then
				return
			end
			
			UIUtil.ImageSetBrushFromAssetPath(self.ImgMoney, Path)
			local ScoreValue = BagMgr:GetItemNum(ScoreID)
			self.TextMoneyAmount:SetText(ScoreMgr.FormatScore(ScoreValue))
		end
	end


	if bLinkToView == true then
		self.LinkToViewID = UIViewID
		UIUtil.SetIsVisible(self.ImgAdd, true, false, false)
		UIUtil.SetIsVisible(self.BtnAdd, true, true, true)
	else
		self.LinkToViewID = 0
		UIUtil.SetIsVisible(self.ImgAdd, false, false, false)
		UIUtil.SetIsVisible(self.BtnAdd, false, true, true)
	end
end

function CommMoneySlotView:OnClickBtnAdd()
	if self.ScoreID == SCORE_TYPE.SCORE_TYPE_STAMPS then
		RechargingMgr:ShowMainPanel() 
		return
	end

	if self.ScoreID == SCORE_TYPE.SCORE_TYPE_KING_DEE then
		local ScoreValue = ScoreMgr:GetScoreValueByID(self.ScoreID)
		local Cfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_GOLD_SAUCER_QUICK_EXANGE)
		if Cfg ~= nil then
			if tonumber(ScoreValue) < tonumber(Cfg.Value[3]) then
				_G.GoldSauserMainPanelMgr:ShowKingDeeQuickExchangePanel()
				return
			else
				_G.GoldSauserMainPanelMgr:ShowKingDeeExchangeTipsPanel()
			end
		end
		
	end

	if type(self.LinkToViewID) ~= "number" then
		FLOG_WARNING("CommMoneySlotView:OnClickBtnAdd, LinkViewID is error")
		return
	end

	if self.LinkToViewID <= 0 then
		FLOG_WARNING("CommMoneySlotView:OnClickBtnAdd, LinkViewID <= 0")
		return
	end

	local Params = {ScoreID =  self.ScoreID}
	UIViewMgr:ShowView(self.LinkToViewID, Params)
end

--- 点击显示货币tips
function CommMoneySlotView:OnClickBtnMoney()
	--[[local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

	if not ViewModel.bClick then
        return
    end

    local ParamsData = {
        CurrencyIsItem = ViewModel.IsItem,
        CurrencyIdShow = ViewModel.CostId
    }

	local ClickFunc = ViewModel.OnClickShowTips
	if ClickFunc ~= nil then
		ClickFunc(ParamsData)
	end]]--
	if self.IsScore then
		ItemTipsUtil.CurrencyTips(self.ScoreID, true, self, nil, nil, self.IsHidePanelOwn)
	else
		ItemTipsUtil.ShowTipsByResID(self.ScoreID, self)
	end

    --[[local ParentViewID = Params.Adapter.ViewID
    if ParentViewID == UIViewID.ShopSearchResultPanelView then
        ShopVM.ShopSearchResultPanelVM:ShowCurrencyTipsPanel(ParamsData)
    else
        ShopVM:ShowCurrencyTipsPanel(ParamsData)
    end--]]
end

---@type 刷新界面积分数据
---@param ScoreID number 积分表ID
function CommMoneySlotView:OnUpdateScoreValue(ScoreID)
	if type(ScoreID) == "number" and ScoreID == self.ScoreID and self.bUpdateCostValueByEvt == true and not self.bForceNotUpdateVal then
		local ScoreValue = self:GetScoreValueText(ScoreID)
		self.TextMoneyAmount:SetText(ScoreValue)
	end
end

function CommMoneySlotView:SetbForceNotUpdateVal(bForceNotUpdateVal)
    self.bForceNotUpdateVal = bForceNotUpdateVal
end

function CommMoneySlotView:SetTextMoneyColorAndOpacity(InColorAndOpacity)
    self.TextMoneyAmount:SetColorAndOpacity(InColorAndOpacity)
end

function CommMoneySlotView:SetMoneyNum( Num )
	self.TextMoneyAmount:SetText(tostring(Num) or "0")
end

function CommMoneySlotView:GetScoreValueText(ScoreID)
	local NewText = ""
	local CurHas = ScoreMgr:GetScoreValueByID(ScoreID)
	local MaxCount = ScoreMgr:GetScoreMaxValue(ScoreID)
	if ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_MAELSTROM or ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_TWINADDER or ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_IMMORTALFLAMES then
		local CompanysealInfo = CompanySealMgr.CompanyRankList[CompanySealMgr.GrandCompanyID]
		if CompanysealInfo then
			local MilitaryLevel = CompanySealMgr:GetMilitaryLeveByScoreID(ScoreID)
			if CompanysealInfo[MilitaryLevel] then
				local Max = CompanysealInfo[MilitaryLevel].CompanySealMax or 0
				local Limit = ScoreMgr.FormatScore(Max)
				local Cur = ScoreMgr.FormatScore(CurHas)
				NewText = string.format("%s/%s", Cur, Limit)
				return NewText
			end
		end
	end
	if self.IsTextWithMaxCount then
		local CurHasText = ScoreMgr.FormatScore(CurHas)
		local MaxCountText = ScoreMgr.FormatScore(MaxCount)
		NewText = string.format("%s/%s", CurHasText, MaxCountText)
	else
		NewText = ScoreMgr.FormatScore(CurHas)
	end
	return NewText
end

function CommMoneySlotView:PlayScoreAni(ScoreID)
	--当获得积分的ID和显示的积分ID相同时再播放
	if self.ScoreID ~= ScoreID or self.bForceNotUpdateVal then
		return
	end
	if ScoreID == SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
		self:PlayAnimation(self.AnimGoldGet)
	elseif ScoreID == SCORE_TYPE.SCORE_TYPE_STAMPS then
		self:PlayAnimation(self.AnimCrystalGet)
	else
		self:PlayAnimation(self.AnimCommGet)
	end
end

function CommMoneySlotView:SetIsHideTipsPanelOwn(IsHidePanelOwn)
	self.IsHidePanelOwn = IsHidePanelOwn
end

function CommMoneySlotView:SetMoneyIconByID( ScoreID )
	local ScoreIcon = ScoreMgr:GetScoreIconName(ScoreID)
		if ScoreIcon then
			UIUtil.SetIsVisible(self.ImgMoney, true, false, false)
			UIUtil.ImageSetBrushFromAssetPath(self.ImgMoney, ScoreIcon)
		else
			UIUtil.SetIsVisible(self.ImgMoney, false, false, false)
		end
end

return CommMoneySlotView