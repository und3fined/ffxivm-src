---
--- Author: Administrator
--- DateTime: 2024-05-31 11:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyMgr
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyTextColor = ArmyDefine.ArmyTextColor
local CommBtnLView = require("Game/Common/Btn/CommBtnLView")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local GroupReputationLevelCfg = require("TableCfg/GroupReputationLevelCfg")
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")
local RichTextUtil = require("Utils/RichTextUtil")

---@class ArmyBuySpecialEffectsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field Btnsure CommBtnLView
---@field HorizontalEFPrice UFHorizontalBox
---@field ImgArmyIcon UFImage
---@field ImgIcon UFImage
---@field RichTextPrice URichTextBox
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field TextCurrency UFTextBlock
---@field TextName UFTextBlock
---@field TextNumber UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyBuySpecialEffectsWinView = LuaClass(UIView, true)

function ArmyBuySpecialEffectsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AmountSlider = nil
	--self.BG = nil
	--self.BtnCancel = nil
	--self.Btnsure = nil
	--self.HorizontalEFPrice = nil
	--self.ImgArmyIcon = nil
	--self.ImgIcon = nil
	--self.RichTextPrice = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.TextCurrency = nil
	--self.TextName = nil
	--self.TextNumber = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyBuySpecialEffectsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.Btnsure)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyBuySpecialEffectsWinView:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	----self.AmountSlider的Viewmodel是在OnInit里获取的，不能在OnInit操作AmountSlider
	--self.AmountSlider:SetSliderValueMaxMin(1 , 1)
	-- self.AmountSlider:SetValueChangedCallback(function (v)
	-- 	self:OnValueChangedAmountCountSlider(v)
	-- end)
	self.Num = 1
	--self.AmountSlider:SetSliderValue(self.Num)
end

function ArmyBuySpecialEffectsWinView:OnDestroy()

end

function ArmyBuySpecialEffectsWinView:OnShow()
	-- LSTR string:特效购买
	self.BG:SetTitleText(LSTR(910363))
	-- LSTR string:特效
	self.Text01:SetText(LSTR(910173))
	local Params = self.Params
	if Params then
		self.ID = Params.ID 
		self.Icon = Params.Icon 
		--self.BuyCallBack = Params.BuyCallBack
		--self.Owner = Params.Owner 
		self.Name = Params.Name
		self.Desc = Params.Desc
		self.Cost = Params.Cost
		if self.Name then
			self.TextName:SetText(self.Name)
		end
		if self.Desc then
			self.Text02:SetText(self.Desc)
		end
		if self.Icon then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, self.Icon)
		end
		self.Num = 1
		self.TextNumber:SetText(self.Num)
		self.AmountSlider:SetSliderValue(self.Num)
		self:UpdataCostNum()
		self.MaxNum = ArmyMgr:GetArmyMaxBonusStatesNum() or 0
		local CurNum = ArmyMgr:GetArmyBonusStatesNum() or 0
		self.MaxNum = self.MaxNum - CurNum
		if self.MaxNum <= 0 then
			self.Num = 0
			self.TextCurrency:SetText("0")
			self.Btnsure:SetIsDisabledState(true, true)
			UIUtil.SetIsVisible(self.AmountSlider, false)
			UIUtil.SetIsVisible(self.TextNumber, false)
		else
			UIUtil.SetIsVisible(self.AmountSlider, true, true)
			UIUtil.SetIsVisible(self.Btnsure, true, true)
			self.AmountSlider:SetSliderValueMaxMin(self.MaxNum , 1)
		end
	end
	---取消按钮长驻
	UIUtil.SetIsVisible(self.BtnCancel, true, true)
	-- LSTR string:取  消
	self.BtnCancel:SetText(LSTR(910081))
	-- LSTR string:确认购买
	self.Btnsure:SetText(LSTR(910193))
	---部队友好度关系
	self.Reputation = ArmyMgr:GetReputation() or {Level = 1, Exp = 0}
	local Level = self.Reputation.Level
	local Cfg = GroupReputationLevelCfg:FindCfgByKey(Level)
	if Cfg then
		local SaleNum =  Cfg.BonusStateDiscount ---百分制配置
		self.Cost = self.Cost * (100 - SaleNum) / 100
		local SaleStr = ""
        if SaleNum ~= 0 then
			SaleStr = string.format("-%s%%", SaleNum)
			local ReputationColor = Cfg.Color
			SaleStr = RichTextUtil.GetText(SaleStr, ReputationColor)
        end
		---LSTR:特效折扣
		local SaleText = LSTR(910400)
		self.SaleText = string.format("%s %s", SaleText, SaleStr)
		self.RichTextPrice:SetText(self.SaleText)
	end
	local GrandCompanyType = ArmyMgr:GetArmyUnionType()
	local GrandCompanyDataCfg = GrandCompanyCfg:FindCfgByKey(GrandCompanyType)
	self.GrandFlagIcon = GrandCompanyDataCfg.EditIcon
	UIUtil.ImageSetBrushFromAssetPath(self.ImgArmyIcon, self.GrandFlagIcon)
	---算完折扣再设价格
	self:UpdataCostNum()
end

function ArmyBuySpecialEffectsWinView:OnHide()

end

function ArmyBuySpecialEffectsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btnsure, self.OnClickedBuy)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedCanCel)
	self.AmountSlider:SetValueChangedCallback(function (v)
		self:OnValueChangedAmountCountSlider(v)
	end)
end

function ArmyBuySpecialEffectsWinView:OnRegisterGameEvent()

end

function ArmyBuySpecialEffectsWinView:OnRegisterBinder()

end

function ArmyBuySpecialEffectsWinView:OnClickedBuy()
	self.MaxNum = self.MaxNum or 0 
	if self.MaxNum <= 0 then
		-- LSTR string:特效持有数量已达上限，无法购买
		MsgTipsUtil.ShowTips(LSTR(910174))
		return
	end
	local CurCost = self.Cost * self.Num
	local CurScoreValue = ArmyMgr:GetArmyScoreValue() or 0
	if CurCost <= CurScoreValue  then
		ArmyMgr:SendGroupBonusStateBuy(self.ID, self.Num or 1)
	end
end

function ArmyBuySpecialEffectsWinView:OnClickedCanCel()
	-- if self.MaxNum <= 0 then
	-- 	return
	-- end
	-- self.Num = 1
	-- self.AmountSlider:SetSliderValue(self.Num)
	-- self:UpdataCostNum()
	self:Hide()
end

function ArmyBuySpecialEffectsWinView:OnValueChangedAmountCountSlider(Value)
	self.Num = Value
	self:UpdataCostNum()
	self.TextNumber:SetText(self.Num)
	-- if self.Num ~= 1 then
	-- 	UIUtil.SetIsVisible(self.BtnCancel, true, true)
	-- else
	-- 	UIUtil.SetIsVisible(self.BtnCancel, false)
	-- end
end

function ArmyBuySpecialEffectsWinView:UpdataCostNum()
	local CurCost = self.Cost * self.Num
	self.TextCurrency:SetText(self:FormatNumber(CurCost))
	local CurScoreValue = ArmyMgr:GetArmyScoreValue() or 0
	local LinearColor
    if CurCost <= CurScoreValue  then
		self.Btnsure:SetIsRecommendState(true)
        LinearColor = _G.UE.FLinearColor.FromHex(ArmyTextColor.YellowHex)
    else
		self.Btnsure:SetIsDisabledState(true, true)
		LinearColor = _G.UE.FLinearColor.FromHex("FF0000FF")
    end
	self.TextCurrency:SetColorAndOpacity(LinearColor)

end

function ArmyBuySpecialEffectsWinView:FormatNumber(Number)
    
    local resultNum = Number
    if type(Number) == "number" then
        local inter, point = math.modf(Number)

        local StrNum = tostring(inter)
        local NewStr = ""
        local NumLen = string.len( StrNum )
        local Count = 0
        for i = NumLen, 1, -1 do
            if Count % 3 == 0 and Count ~= 0  then
                NewStr = string.format("%s,%s",string.sub( StrNum,i,i),NewStr) 
            else
                NewStr = string.format("%s%s",string.sub( StrNum,i,i),NewStr) 
            end
            Count = Count + 1
        end

        if point > 0 then
            --@desc 存在小数点，
            local strPoint = string.format( "%.2f", point )
            resultNum = string.format("%s%s",NewStr,string.sub( strPoint,2, string.len( strPoint ))) 
        else
            resultNum = NewStr
        end
    end
    
    return resultNum
end

return ArmyBuySpecialEffectsWinView