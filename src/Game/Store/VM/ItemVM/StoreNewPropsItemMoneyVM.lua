
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local StoreDefine = require("Game/Store/StoreDefine")
local StoreMgr = require("Game/Store/StoreMgr")

local FLOG_WARNING = _G.FLOG_WARNING

---@class StoreNewPropsItemMoneyVM: UIViewModel
local StoreNewPropsItemMoneyVM = LuaClass(UIViewModel)

function StoreNewPropsItemMoneyVM:Ctor()
	self.Img1 = nil
	self.Img2 = nil
	self.Img3 = nil
	self.MoneyVisible1 = false
	self.MoneyVisible2 = false
	self.MoneyVisible3 = false
	self.MoneyNum1 = ""
	self.MoneyNum2 = ""
	self.MoneyNum3 = ""
	--- 原价
	self.CostPricePanelVisible = false
	self.CostPriceNum = ""
end

function StoreNewPropsItemMoneyVM:IsEqualVM(Value)
	return nil ~= Value
end

function StoreNewPropsItemMoneyVM:UpdateVM(Value)
	if Value == nil then
		FLOG_WARNING("StoreNewPropsItemMoneyVM:InitVM, Value is nil")
		return
	end

	local Price = Value.Price
	if Price == nil then
		FLOG_WARNING("StoreNewPropsItemMoneyVM:SetPrice, Price is nil")
		return
	end
	
	
	-- 折扣相关
	local DisCount = Value.Discount
	local CurrentTime = TimeUtil.GetServerTime()
	local DiscountStart = StoreMgr:GetTimeInfo(Value.DiscountDurationStart)
	local DiscountEnd = StoreMgr:GetTimeInfo(Value.DiscountDurationEnd)
	local IsOnTime = CurrentTime > DiscountStart and CurrentTime < DiscountEnd


	if Price and #Price > 0 then
		for i = 1, #Price do
			self[string.format("Img%d", i)] = Price[i].ID
			self[string.format("MoneyNum%d", i)] = (DisCount < StoreDefine.DiscountMaxValue and DisCount > 0 and (IsOnTime or DiscountStart == 0)) and ScoreMgr.FormatScore(Value.DisCountedPrice) or ScoreMgr.FormatScore(Price[i].Count)
			self[string.format("MoneyVisible%d", i)] = true
		end
	end
end

return StoreNewPropsItemMoneyVM