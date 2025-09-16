local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

local RideCfg = require("TableCfg/RideCfg")
local MountVM = require("Game/Mount/VM/MountVM")
local StoreDefine = require("Game/Store/StoreDefine")

local MountMgr = _G.MountMgr
---@class MountCustomMadeSlotVM : UIViewModel
local MountCustomMadeSlotVM = LuaClass(UIViewModel)

MountCustomMadeSlotVM.OwnState = {
    Invalid = 0,
    Owned = 1,
    OwnedNotUnlockedInBag = 2,
    OwnedNotUnlockedInMail = 3,
    NotOwnedCanBuy = 4,
    NotOwnedCanGet = 5,
    NotOwnedCannotGet = 6,
    Equiped = 7,
}

function MountCustomMadeSlotVM:Ctor()
    self.ID = nil
    self.Name = nil
    self.Icon = nil
    self.Order = nil
    self.MountID = nil
    self.GoodsID = nil
    self.JumpID = nil
    self.RedDotType = nil
    self.LaunchTime = nil
    self.RemovalTime = nil
    self.CameraGroupID = nil
    self.ItemID = nil
    self.ImeChanID = nil

    self.OwnState = 0
    self.IconMoneyVisible = nil
    self.TextpriceVisible = nil
    self.TextStateVisible = nil
    self.Price = nil
    self.PriceBeforeDiscounted = nil
    self.TextStateColor = nil
    self.PriceTextColor = nil
    self.StateText = nil

    self.bIsUnlocked = false
    self.bIsSelected = false
    self.bIsEquiped = false
    self.bIsNew = false
end

function MountCustomMadeSlotVM:Update(Params, UnlockInfo)
    if self.ID == Params.ID then return end
    self.ID = 				Params.ID
    self.Name = 			Params.Name
    self.Icon = 			Params.Icon
    self.Order = 			Params.Order
    self.MountID = 			Params.MountID
    self.GoodsID = 			Params.GoodsID
    self.JumpID = 		    Params.JumpID
    self.RedDotType = 		Params.RedDotType
    self.LaunchTime = 		Params.LaunchTime
    self.RemovalTime = 		Params.RemovalTime
    self.CameraGroupID = 	Params.CameraGroupID
    self.ItemID = 			Params.ItemID
    self.ImeChanID =        Params.ImeChanID

    self:UpdateOwnState(UnlockInfo)
end

function MountCustomMadeSlotVM:UpdateOwnState(UnlockInfo)
    if UnlockInfo == nil then
        self.bIsUnlocked = false
    else
        self.bIsUnlocked = UnlockInfo.Unlocked
    end

    if self.bIsEquiped then
        self.OwnState = MountCustomMadeSlotVM.OwnState.Equiped
    elseif UnlockInfo ~= nil and UnlockInfo.Unlocked then
        self.OwnState = MountCustomMadeSlotVM.OwnState.Owned
    elseif _G.BagMgr:GetItemByResID(self.ItemID) then
        self.OwnState = MountCustomMadeSlotVM.OwnState.OwnedNotUnlockedInBag
    elseif self.ItemID ~= nil and self.ItemID > 0 and _G.MailMgr:QueryMailAttachByItemID(self.ItemID) then
        self.OwnState = MountCustomMadeSlotVM.OwnState.OwnedNotUnlockedInMail
    elseif _G.StoreMgr:GetGoodCfg(self.GoodsID) ~= nil then
        self.OwnState = MountCustomMadeSlotVM.OwnState.NotOwnedCanBuy
        self:UpdatePrice()
    elseif self.JumpID ~= nil and self.JumpID > 0 and not self:IsFinished() then
        self.OwnState =  MountCustomMadeSlotVM.OwnState.NotOwnedCanGet
    else 
        self.OwnState = MountCustomMadeSlotVM.OwnState.NotOwnedCannotGet
    end
end

function MountCustomMadeSlotVM:UpdatePrice()
    local Price = 0
	local TempGoodData = _G.StoreMgr:GetProductDataByID(self.GoodsID)
	if TempGoodData == nil or TempGoodData.Cfg == nil then
		self.Price = Price
        self.PriceBeforeDiscounted = Price
        return 
	end
	local TempGoodCfg = TempGoodData.Cfg
	local Discount = TempGoodCfg.Discount
	local CfgPrice = TempGoodCfg.Price
	if Discount ~= StoreDefine.DiscountMaxValue and Discount ~= StoreDefine.DiscountMinValue then
		--- 折后价
		Price = TempGoodCfg.DisCountedPrice
	else
		Price = CfgPrice[StoreDefine.PriceDefaultIndex].Count
	end

    self.Price = Price
    self.PriceBeforeDiscounted = CfgPrice[StoreDefine.PriceDefaultIndex].Count
        -- 字体颜色
	local ScoreValue = _G.ScoreMgr:GetScoreValueByID(CfgPrice[StoreDefine.PriceDefaultIndex].ID)
	if self.Price > ScoreValue then
		self.PriceTextColor = "#af4c58"
	else
		self.PriceTextColor = "D5D5D5FF"
	end
end

function MountCustomMadeSlotVM:IsFinished()
    local RemovalTime = TimeUtil.GetTimeFromString(self.RemovalTime)
    local CurrentTime = TimeUtil.GetServerTime()
    return RemovalTime ~= nil and CurrentTime > RemovalTime
end

return MountCustomMadeSlotVM