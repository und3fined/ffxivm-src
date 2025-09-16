--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-03-04 15:03:47
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-03-04 16:27:12
FilePath: \Client\Source\Script\Game\CraftingLog\CraftingLogShopWinVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local CraftingLogShopItemVM = require("Game/CraftingLog/ItemVM/CraftingLogShopItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LSTR = _G.LSTR

local CraftingLogShopWinVM = LuaClass(UIViewModel)
function CraftingLogShopWinVM:Ctor()
    self.ShoppingList = UIBindableList.New(CraftingLogShopItemVM)
    self.CostNum = 0
    self.GoodsBuyNum = 0
    self.CostId = SCORE_TYPE.SCORE_TYPE_GOLD_CODE
    self.bShowExchange = false
    self.bActiveByView = false
    self.GroupNum = 1
    self.GroupNumText = "1"
    self.CanGroupBuy = true
    self.IsEnough = true
end

function CraftingLogShopWinVM:OnInit()
end

function CraftingLogShopWinVM:UpdataShoppingList()
    local ShoppingList = _G.CraftingLogMgr:GetShoppingList()
    self.ShoppingList:UpdateByValues(ShoppingList)
end

function CraftingLogShopWinVM:UpdataShoppingItemBagNum(UpdateItem)
    local Items = self.ShoppingList:GetItems()
    for _, Elem in pairs(UpdateItem) do
		local PstItem = Elem.PstItem
		local ResID = PstItem.ResID
        for _, value in pairs(Items) do
            if value.ItemID == ResID then
                value:SetNumRatio()
            end
        end
	end
end

function CraftingLogShopWinVM:SetGroupNum(Value)
    if self.CanGroupBuy == false and self.GroupNum == Value then
        self.GroupNum = 0 --用来触发self.GroupNum的ValueChangedCallBack
    end
    self.GroupNum = Value
    self.GroupNumText = tostring(Value)
end

function CraftingLogShopWinVM:SetCostNum()
    local CostNum = 0
    local GoodsBuyNum = 0
    local Items = self.ShoppingList:GetItems()
    for _, value in pairs(Items) do
        CostNum = CostNum + value.CostNum
        GoodsBuyNum = GoodsBuyNum + 1
    end
    self.CostNum = CostNum
    self.GoodsBuyNum = GoodsBuyNum
    local HaveNum = _G.ScoreMgr:GetScoreValueByID(self.CostId)
	self.IsEnough = HaveNum >= CostNum
end

function CraftingLogShopWinVM:SetGroupBuyEnable(CanGroupBuy)
    if CanGroupBuy == false then
        self.CanGroupBuy = false
        self.GroupNumText = "--"
        return
    end
    --全部都符合条件才亮
    local Items = self.ShoppingList:GetItems()
    for _, value in pairs(Items) do
	    if value.CanGroupBuy == false then
            self.CanGroupBuy = false
            self.GroupNumText = "--"
            return
        end
    end
    self.CanGroupBuy = true
    self.GroupNumText = tostring(self.GroupNum)
end

return CraftingLogShopWinVM