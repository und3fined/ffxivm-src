---
--- Author: Administrator
--- DateTime: 2024-12-20 16:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BattlePassMgr = require("Game/BattlePass/BattlePassMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local BattlePassBuyLevelWinVM = require("Game/BattlePass/VM/BattlePassBuyLevelWinVM")
local BattlepassGlobalCfg = require("TableCfg/BattlepassGlobalCfg")

local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ScoreMgr = require("Game/Score/ScoreMgr")

---@class BattlePassBuyLevelNewWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field BG Comm2FrameMView
---@field BtnBuy CommBtnLView
---@field ImgPriceIcon UFImage
---@field RichTextTips URichTextBox
---@field TableViewReward UTableView
---@field TextAmount UFTextBlock
---@field TextDescription UFTextBlock
---@field TextPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassBuyLevelNewWinView = LuaClass(UIView, true)

function BattlePassBuyLevelNewWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AmountSlider = nil
	--self.BG = nil
	--self.BtnBuy = nil
	--self.ImgPriceIcon = nil
	--self.RichTextTips = nil
	--self.TableViewReward = nil
	--self.TextAmount = nil
	--self.TextDescription = nil
	--self.TextPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassBuyLevelNewWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnBuy)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassBuyLevelNewWinView:OnInit()
	self.TableViewRewardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward, self.OnSelectedItem, true)
	self.VM = BattlePassBuyLevelWinVM.New()
	self.Binders = {
		{ "TipsText", UIBinderSetText.New(self, self.RichTextTips)},
		{ "CurLvText", UIBinderSetText.New(self, self.TextAmount)},
		{ "PriceText", UIBinderSetText.New(self, self.TextPrice)},
		{ "PriceTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextPrice)},
		{ "PriceIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuality) },
		{ "LevelRewardList", UIBinderUpdateBindableList.New(self, self.TableViewRewardAdapter)},
	}
	self.LastValue = nil
	self.Value = 0
	self.CanBuy = true
	self.FirstEnter = true

end

function BattlePassBuyLevelNewWinView:OnDestroy()

end

function BattlePassBuyLevelNewWinView:OnShow()
	--根据自身等级设置界面
	local MaxLevel = BattlePassMgr:GetBattlePassMaxLevel()
	local CfgReward = BattlepassGlobalCfg:FindCfgByKey(ProtoRes.BattlePassGlobalParamType.BattlePassGlobalParamTypeBuyLevelMax)
	if  CfgReward ~= nil then
		MaxLevel =  CfgReward.Value[1]
	end

	local CurLevel = BattlePassMgr:GetBattlePassLevel()
	
	self.VM:InitLevelRewardList()
	self.TableViewRewardAdapter:ClearChildren()
	self.AmountSlider:SetSliderValueMaxMin(MaxLevel - CurLevel , 1)
	self.AmountSlider:SetValueChangedCallback(function (v)
		self:OnValueChangedAmountCountSlider(v)
	end)
	self.FirstEnter = true
	self.AmountSlider:SetSliderValue(1)
	self.FirstEnter = false

	self:InitText()

end

function BattlePassBuyLevelNewWinView:InitText()
	self.BG:SetTitleText(_G.LSTR(850034))
	self.TextDescription:SetText(_G.LSTR(850032))
	self.BtnBuy:SetBtnName(_G.LSTR(850043))
end

function BattlePassBuyLevelNewWinView:OnHide()
	self.LastValue = nil
	self.Value = 0 

	self.CanBuy = true
end

function BattlePassBuyLevelNewWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBuy, self.OnClickedBtnBuy)
end

function BattlePassBuyLevelNewWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.BattlePassLevelUp, self.OnBattlePassLevelUp)
end

function BattlePassBuyLevelNewWinView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
end

function BattlePassBuyLevelNewWinView:OnBattlePassLevelUp()
	self:Hide()
end

function BattlePassBuyLevelNewWinView:OnValueChangedAmountCountSlider(Value)
	self.VM:SetBuyLevelWin(Value)
	local CurLevel = BattlePassMgr:GetBattlePassLevel()
	local Dir = self.LastValue == nil and 1 or Value - self.LastValue
	self.VM:UpdateLevelRewardList(CurLevel, CurLevel + Value, Dir)
	self.CanBuy = self.VM:SetBuyLevelPrice(Value)
	self.Value = Value
	self.LastValue = Value
end

function BattlePassBuyLevelNewWinView:OnClickedBtnBuy()
	if not self.CanBuy then
		local ScoreName = ProtoEnumAlias.GetAlias(ProtoRes.SCORE_TYPE, ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS)
		 ScoreMgr:GetScoreName(ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS)
		MsgBoxUtil.ShowMsgBoxTwoOp(self,
								   _G.LSTR(850011),
								   string.format(_G.LSTR(850012), ScoreName),
								   function ()  
									UIViewMgr:HideView(UIViewID.BattlePassBuyLevelWin)
									UIViewMgr:HideView(UIViewID.BattlePassMainView) 
									_G.RechargingMgr:ShowMainPanel()
									end,


								   nil,
								   _G.LSTR(850013),
								   _G.LSTR(850014))
		return
	end
	local UpLevel = BattlePassMgr:GetBattlePassLevel() + self.Value
	BattlePassMgr:SendBattlePassLevelUp(UpLevel)
end

function BattlePassBuyLevelNewWinView:OnSelectedItem(Index, ItemData, ItemView)
	local ID = ItemData.ResID
	-- self:RegisterTimer( function ()
		ItemTipsUtil.ShowTipsByResID(ID, ItemView, _G.UE.FVector2D(0, 0))
	-- end, 0.3, 0, 1)
end

return BattlePassBuyLevelNewWinView