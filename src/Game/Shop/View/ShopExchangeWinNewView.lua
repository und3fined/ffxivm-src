---
--- Author: Administrator
--- DateTime: 2023-11-21 09:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreConvertCfg = require("TableCfg/ScoreConvertCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ScoreMgr = _G.ScoreMgr
local LSTR = _G.LSTR


---@class ShopExchangeWinNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArrowPanel2 UFCanvasPanel
---@field BG Comm2FrameMView
---@field BtnArrow UFButton
---@field BtnBuyConfirm CommBtnLView
---@field BtnCancel CommBtnLView
---@field BtnGift CommBtnLView
---@field BtnNumber UFButton
---@field BtnNumber1 UFButton
---@field BtnNumber2 UFButton
---@field BtnNumber3 UFButton
---@field BtnNumberOk UFButton
---@field BtnPlus UFButton
---@field BtnReduce UFButton
---@field BtnSwitc UFButton
---@field HorizontalPrice UFHorizontalBox
---@field ImgCountBg UFImage
---@field ImgMoney UFImage
---@field Number0 ShopCountNumberItemNewView
---@field NumberPanel1 UFCanvasPanel
---@field NumberPanel2 UFCanvasPanel
---@field PanelCount UFCanvasPanel
---@field PanelExchangeSetting UFCanvasPanel
---@field Slot1 CommBackpackSlotView
---@field Slot2 CommBackpackSlotView
---@field TableViewNumber UTableView
---@field TextContent UFTextBlock
---@field TextContent2 UFTextBlock
---@field TextCurrentPrice UFTextBlock
---@field TextNumber1 UFTextBlock
---@field TextNumber2 UFTextBlock
---@field TextNumber3 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopExchangeWinNewView = LuaClass(UIView, true)

function ShopExchangeWinNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArrowPanel2 = nil
	--self.BG = nil
	--self.BtnArrow = nil
	--self.BtnBuyConfirm = nil
	--self.BtnCancel = nil
	--self.BtnGift = nil
	--self.BtnNumber = nil
	--self.BtnNumber1 = nil
	--self.BtnNumber2 = nil
	--self.BtnNumber3 = nil
	--self.BtnNumberOk = nil
	--self.BtnPlus = nil
	--self.BtnReduce = nil
	--self.BtnSwitc = nil
	--self.HorizontalPrice = nil
	--self.ImgCountBg = nil
	--self.ImgMoney = nil
	--self.Number0 = nil
	--self.NumberPanel1 = nil
	--self.NumberPanel2 = nil
	--self.PanelCount = nil
	--self.PanelExchangeSetting = nil
	--self.Slot1 = nil
	--self.Slot2 = nil
	--self.TableViewNumber = nil
	--self.TextContent = nil
	--self.TextContent2 = nil
	--self.TextCurrentPrice = nil
	--self.TextNumber1 = nil
	--self.TextNumber2 = nil
	--self.TextNumber3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopExchangeWinNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnBuyConfirm)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnGift)
	self:AddSubView(self.Number0)
	self:AddSubView(self.Slot1)
	self:AddSubView(self.Slot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopExchangeWinNewView:OnInit()

end

function ShopExchangeWinNewView:OnDestroy()

end

function ShopExchangeWinNewView:OnShow()
	UIUtil.SetIsVisible(self.BtnGift,false,true)
	UIUtil.SetIsVisible(self.BtnCancel,true,true)
	UIUtil.SetIsVisible(self.PanelCount,false)
	UIUtil.SetIsVisible(self.BtnSwitc,false,true)
	self.ScoreID = self.Params.ScoreID
	self.NeedCount = self.Params.NeedCount
	self.CurExNum = 1
	self.DeductNum2 = 0
	self:InitCoin()
end

function ShopExchangeWinNewView:OnHide()

end

function ShopExchangeWinNewView:InitCoin()
	local ScoreID = 0
	local IconName1 = ""
	local IconName2 = ""
	if self.ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_SILVER_CODE then
		ScoreID = ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
		IconName1 = LSTR(1200082)
		IconName2 = LSTR(1200083)
	elseif self.ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
		ScoreID = ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS
		IconName1 = LSTR(1200061)
		IconName2 = LSTR(1200082)
	end
	self.IconName1 = IconName1
	self.IconName2 = IconName2
	self.TextContent:SetText(IconName1)
	local ScoreIcon = ScoreMgr:GetScoreIconName(ScoreID)
	UIUtil.ImageSetBrushFromAssetPath(self.Slot1.FImg_Icon, ScoreIcon)
	self.TextContent2:SetText(IconName2)
	local ScoreIcon2 = ScoreMgr:GetScoreIconName(self.ScoreID)
	UIUtil.ImageSetBrushFromAssetPath(self.Slot2.FImg_Icon, ScoreIcon2)
	self.SourceScoreID = ScoreID
	local DeductNum,TargerNum, DeductNum2 = self:SetRecommendedExchange(ScoreID,self.ScoreID)
	self.DeductNum = DeductNum
	self.TargerNum = TargerNum
	UIUtil.ImageSetBrushFromAssetPath(self.ImgMoney, ScoreIcon)
	self:SetExchangeText(DeductNum2)
end

function ShopExchangeWinNewView:OnRegisterUIEvent()
	-- UIUtil.AddOnClickedEvent(self, self.BtnReduce, self.OnClickedBtnReduce)
	-- UIUtil.AddOnClickedEvent(self, self.BtnPlus, self.OnClickedBtnPlus)
	-- UIUtil.AddOnClickedEvent(self, self.BtnNumber1, self.OnClickedBtnNumber1)
	-- UIUtil.AddOnClickedEvent(self, self.BtnNumber2, self.OnClickedBtnNumber2)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnBuyConfirm, self.OnClickedBtnBuyConfirm)
end

function ShopExchangeWinNewView:OnRegisterGameEvent()

end

function ShopExchangeWinNewView:OnRegisterBinder()

end

function ShopExchangeWinNewView:SetExchangeText(Value)
	local HasValue = ScoreMgr:GetScoreValueByID(self.SourceScoreID)

	self.CurExNum = Value
	self.TextNumber3:SetText(Value)
	self.TextCurrentPrice:SetText(Value)
	self.TextContent:SetText(string.format("%sX%d",self.IconName1, self.CurExNum * self.DeductNum))
	self.TextContent2:SetText(string.format("%sX%d",self.IconName2, self.CurExNum * self.TargerNum))
end

function ShopExchangeWinNewView:SetBtnState()
	-- local HasValue = ScoreMgr:GetScoreValueByID(self.SourceScoreID)
	-- if HasValue < 1 then
	-- 	self.BtnReduce:SetIsEnabled(false)
	-- 	self.BtnNumber1:SetIsEnabled(false)
	-- 	self.BtnPlus:SetIsEnabled(false)
	-- 	self.BtnNumber2:SetIsEnabled(false)
	-- elseif HasValue > 1 then
	-- 	if self.CurExNum == HasValue then
	-- 		self.BtnReduce:SetIsEnabled(true)
	-- 		self.BtnNumber1:SetIsEnabled(true)
	-- 		self.BtnPlus:SetIsEnabled(false)
	-- 		self.BtnNumber2:SetIsEnabled(false)
	-- 	else
	-- 		self.BtnReduce:SetIsEnabled(true)
	-- 		self.BtnNumber1:SetIsEnabled(true)
	-- 		self.BtnPlus:SetIsEnabled(false)
	-- 		self.BtnNumber2:SetIsEnabled(false)
	-- 	end
	-- end
end

function ShopExchangeWinNewView:SetRecommendedExchange(SourceScoreID, TargetID)
	local SearchConditions = string.format("DeductID = %d and TargetID = %d", SourceScoreID, TargetID)
	local ScoreConvertData = ScoreConvertCfg:FindCfg(SearchConditions)
	if ScoreConvertData ~= nil then
		local TargetNum = ScoreConvertData.TargetNum
		local DeductNum = ScoreConvertData.DeductNum
		local DeductNum2 = 0
		local NeedSourceScore =  math.ceil(self.NeedCount / TargetNum)
		local HasValue = ScoreMgr:GetScoreValueByID(SourceScoreID)
		if HasValue >= NeedSourceScore then
			DeductNum2 = NeedSourceScore
		else
			DeductNum2 = HasValue
		end
		self.DeductNum2 = DeductNum2
		return DeductNum,TargetNum,DeductNum2
	end
end

function ShopExchangeWinNewView:OnClickedBtnCancel()
	self:Hide()
end

function ShopExchangeWinNewView:OnClickedBtnBuyConfirm()
	if self.DeductNum2 == 0 then
		local Tips = ""
		Tips = LSTR(1200080)
		MsgTipsUtil.ShowTips(Tips)
		self:Hide()
		return
	end
	ScoreMgr:ConvertScoreByID(self.SourceScoreID, self.CurExNum, self.ScoreID)
	self:Hide()
end

return ShopExchangeWinNewView