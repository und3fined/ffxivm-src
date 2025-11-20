
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local MathUtil = require("Utils/MathUtil")
local StoreDefine = require("Game/Store/StoreDefine")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")

local StoreMysteryBoxMgr = _G.StoreMysteryBoxMgr
local StoreMall = ProtoRes.StoreMall
local FLOG_WARNING = _G.FLOG_WARNING

---@class StoreMysteryBoxGoodsItemVM: UIViewModel
local StoreMysteryBoxGoodsItemVM = LuaClass(UIViewModel)

function StoreMysteryBoxGoodsItemVM:Ctor()
	self.BlindBoxID = 0
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
    self.GoodCfgData = nil
	self.BoxType = nil
	self.GoodID = 0
end

function StoreMysteryBoxGoodsItemVM:IsEqualVM()
    return true
end

function StoreMysteryBoxGoodsItemVM:UpdateVM(Value)
    if Value == nil or Value.Cfg == nil then
        FLOG_WARNING("StoreMysteryBoxGoodsItemVM:InitVM Value is nil")
        return
    end
	self.Type = StoreMall.STORE_MALL_MYSTERYBOX
    local GoodCfgData = Value.Cfg
	self.BoxType = GoodCfgData.Type
    self.GoodCfgData = GoodCfgData
	self.Items = GoodCfgData.Items
	self.BlindBoxID = GoodCfgData.ID
	StoreMysteryBoxMgr:SendGetMysteryBoxList(GoodCfgData.ID)
	self.GoodID = GoodCfgData.ID
	self.LabelMain = GoodCfgData.LabelMain
    self.ItemNameText = GoodCfgData.Name
	local Discount = GoodCfgData.Discount
    self:UpdateIcon(GoodCfgData.PictureAddr)
    local CurrentTime = TimeUtil.GetServerLogicTime()
	local DiscountStart = StoreMysteryBoxMgr:GetTimeInfo(GoodCfgData.DiscountDurationStart)
	local DiscountEnd = StoreMysteryBoxMgr:GetTimeInfo(GoodCfgData.DiscountDurationEnd)
	local IsOnTime = (DiscountStart ~= 0 and DiscountEnd ~= 0) and (CurrentTime >= DiscountStart and CurrentTime <= DiscountEnd)
	self.Desc = GoodCfgData.Desc
	local IsOwned = StoreMysteryBoxMgr:CheckGoodsIsOwned(GoodCfgData)
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

	_G.EventMgr:SendEvent(_G.EventID.StoreUpdateMysteryBoxRedDot)
end

---@type 更新图标
---@param Icon string @图标
---@param Background string @背景
function StoreMysteryBoxGoodsItemVM:UpdateIcon(Icon)
	self.GoodIcon = Icon
end

---@type 更新显示的价格
function StoreMysteryBoxGoodsItemVM:UpdatePrice(GoodCfgData, IsOnTime)
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
function StoreMysteryBoxGoodsItemVM:UpdateDiscount(Discount, IsOnTime)
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
function StoreMysteryBoxGoodsItemVM:UpdateTimeSale(Time)

    if Time == nil then
        FLOG_WARNING(string.format("StoreMysteryBoxGoodsItemVM:UpdateTimeSale, Time is nil, ItemIndex: %d", self.ItemIndex))
        return
    end

    local IsShowTimeSaleIcon, ShowTime = StoreMysteryBoxMgr:GetTimeLimit(Time)
    if ShowTime == nil then
        return
    end

	self.IsShowTimeSaleIcon = IsShowTimeSaleIcon
    self.DeadlinePanelVisible = true
    self.TimeSaleText = ShowTime
end

return StoreMysteryBoxGoodsItemVM