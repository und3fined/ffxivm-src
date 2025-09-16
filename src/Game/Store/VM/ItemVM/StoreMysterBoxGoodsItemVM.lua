---
---@author Lucas
---DateTime: 2023-05-6 14:20:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local MathUtil = require("Utils/MathUtil")
local StoreMgr = require("Game/Store/StoreMgr")
local StoreDefine = require("Game/Store/StoreDefine")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")

local StoreMall = ProtoRes.StoreMall
local FLOG_WARNING = _G.FLOG_WARNING

---@class StoreMysterBoxGoodsItemVM: UIViewModel
local StoreMysterBoxGoodsItemVM = LuaClass(UIViewModel)

function StoreMysterBoxGoodsItemVM:Ctor()
	self.GoodID = 0
	self.Items = nil
	self.LabelMain = nil
	self.Desc = ""
	self.GoodIcon = ""
	self.CrystalText = ""
    self.TimeSaleText = ""
	self.DiscountText = ""
    self.ItemNameText = ""
	self.GoodStateText = ""
	self.IsShowTimeSaleIcon = ""
	self.IsOwned = false
    self.PanelOriginalVisible = false
	self.DiscountPanelVisible = false
    self.DeadlinePanelVisible = false
	self.Type = StoreMall.STORE_MALL_MYSTERYBOX
	self.bSelected = false
	self.IsNeedRegisterDisCountTimer = false
	self.DiscountDurationEnd = 0
	self.DisCountTimerLoopNumber = 0
end

function StoreMysterBoxGoodsItemVM:IsEqualVM()
    return true
end

function StoreMysterBoxGoodsItemVM:UpdateVM(Value, Params)
    if Value == nil then
        FLOG_WARNING("StoreMysterBoxGoodsItemVM:InitVM Value is nil")
        return
    end
	self.Type = StoreMall.STORE_MALL_MYSTERYBOX
    local GoodData = Value.GoodData
    local GoodCfgData = GoodData.Cfg
	self.Items = GoodCfgData.Items
	self.GoodID = GoodCfgData.ID
	StoreMgr:SendGetMysterBoxList(GoodCfgData.ID)
	self.MysterID = GoodCfgData.MysterID
	self.LabelMain = GoodCfgData.LabelMain
    self.ItemNameText = GoodCfgData.Name
	local Discount = GoodCfgData.Discount
    self:UpdateIcon(GoodCfgData.Icon)
    local CurrentTime = TimeUtil.GetServerLogicTime()
	local DiscountStart = StoreMgr:GetTimeInfo(GoodCfgData.DiscountDurationStart)
	local DiscountEnd = StoreMgr:GetTimeInfo(GoodCfgData.DiscountDurationEnd)
	local IsOnTime = (DiscountStart ~= 0 and DiscountEnd ~= 0) and (CurrentTime >= DiscountStart and CurrentTime <= DiscountEnd)
	self.Desc = GoodCfgData.Desc
	local IsOwned = StoreMgr:CheckGoodsIsOwned(GoodCfgData)
	self.IsOwned = IsOwned
	self.StateTextVisible = IsOwned
	self.bSelected = false
	if IsOwned then
		self.GoodStateText = LSTR(StoreDefine.SecondScreenType.Owned)
	else
		self.DeadlinePanelVisible = false
		self:UpdateDiscount(Discount, IsOnTime)
		if Discount ~= 0 and CurrentTime >= DiscountStart and CurrentTime <= DiscountEnd then
			self.IsNeedRegisterDisCountTimer = DiscountEnd - CurrentTime <= 60
			self.DiscountDurationEnd = DiscountEnd
			self.DisCountTimerLoopNumber = DiscountEnd - CurrentTime
			self:UpdateTimeSale(DiscountEnd)
		end
	end
	self:UpdatePrice(GoodCfgData, IsOnTime)

	_G.EventMgr:SendEvent(_G.EventID.StoreUpdateMysterBoxRedDot)
end

---@type 更新图标
---@param Icon string @图标
---@param Background string @背景
function StoreMysterBoxGoodsItemVM:UpdateIcon(Icon)
	self.GoodIcon = Icon
end

---@type 更新显示的价格
function StoreMysterBoxGoodsItemVM:UpdatePrice(GoodCfgData, IsOnTime)
	if nil == GoodCfgData then
		return
	end

	local Price = GoodCfgData.Price
	local Discount = GoodCfgData.Discount
	
	if IsOnTime and Discount > StoreDefine.DiscountMinValue and StoreDefine.DiscountMaxValue > Discount then
		Price = GoodCfgData.DisCountedPrice
	end
	self.CrystalText = ScoreMgr.FormatScore(Price)
end

--- @type 更新显示的折扣
---@param Discount number @折扣
function StoreMysterBoxGoodsItemVM:UpdateDiscount(Discount, IsOnTime)
    if Discount == nil then
        return
    end

	if IsOnTime and Discount > StoreDefine.DiscountMinValue and StoreDefine.DiscountMaxValue > Discount then
        self.PanelOriginalVisible = true
		self.DiscountPanelVisible = true
		if Discount % 10 == 0 then
			self.DiscountText = string.format(_G.LSTR(950042), Discount / 10)	--- "%d折"
		else
			self.DiscountText = string.format(_G.LSTR(950080), Discount / 10)	--- "%.1f折"
		end
	else
        self.PanelOriginalVisible = false
		self.DiscountPanelVisible = false
    end
end

---@type 更新显示的限时
function StoreMysterBoxGoodsItemVM:UpdateTimeSale(Time)

    if Time == nil then
        FLOG_WARNING(string.format("StoreMysterBoxGoodsItemVM:UpdateTimeSale, Time is nil, ItemIndex: %d", self.ItemIndex))
        return
    end

    local IsShowTimeSaleIcon, ShowTime = StoreMgr:GetTimeLimit(Time)
    if ShowTime == nil then
        return
    end

	self.IsShowTimeSaleIcon = IsShowTimeSaleIcon
    self.DeadlinePanelVisible = true
    self.TimeSaleText = ShowTime
end

return StoreMysterBoxGoodsItemVM