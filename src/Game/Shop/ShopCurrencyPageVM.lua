---
--- Author: Alex
--- DateTime: 2023-02-13 10:13:55
--- Description: 商店货币系统数据结构
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ShopCostItemVM = require("Game/Shop/ItemVM/ShopCostItemVM")
--local LSTR = _G.LSTR
local BagMgr = require("Game/Bag/BagMgr")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local UIViewID = require("Define/UIViewID")
local FLOG_ERROR = _G.FLOG_ERROR

---@class ShopCurrencyPageVM : UIViewModel

local ShopCurrencyPageVM = LuaClass(UIViewModel)

---Ctor
function ShopCurrencyPageVM:Ctor()
    -- Main Part
    self.ShopId = 0
    self.ShopCostItemVMs = UIBindableList.New(ShopCostItemVM)
end

function ShopCurrencyPageVM:IsEqualVM(Value)
    return self.ShopId == Value.ShopId
end

function ShopCurrencyPageVM:UpdateCostItemList(ShopCostItemVMs)
    local CostListVMs = self.ShopCostItemVMs
    if nil ~= CostListVMs and CostListVMs:Length() > 0 then
        CostListVMs:Clear()
    end

    local CostItemLenToUpdate = #ShopCostItemVMs
    -- 验证是否为商品配置内容导致没有货币栏
    if CostItemLenToUpdate <= 0 then
        FLOG_ERROR("ShopCurrencyPageVM:UpdateCostItemList", "CostItemLenToUpdate <= 0")
        return
    end

    for i = 1, CostItemLenToUpdate do
        local v = ShopCostItemVMs[i]
        if v.bShowOnTop then
            local CostId = v.CostId
            local IsItem = v.IsItem
            local tmpCostItemVM = {
                CostId = CostId,
                IsItem = IsItem,
                bActiveByView = v.bActiveByView,
                OnClickShowTips = v.OnClickShowTips,
                bShowExchange = false,
                LinkToViewID = 0,
            }
            if IsItem == true then
                tmpCostItemVM.CostNum = BagMgr:GetItemNum(CostId) or 0
            else
                tmpCostItemVM.CostNum = ScoreMgr:GetScoreValueByID(CostId) or 0
                tmpCostItemVM.bShowExchange = CostId == SCORE_TYPE.SCORE_TYPE_SILVER_CODE
                --FLOG_ERROR("ShopCurrencyPageVM:UpdateCostItemList bShowExchange == %s", tostring(tmpCostItemVM.bShowExchange))
                tmpCostItemVM.LinkToViewID = UIViewID.MarketExchangeWin
            end
            tmpCostItemVM.IsEnough = true
            tmpCostItemVM.bClick = v.bClick
            CostListVMs:AddByValue(tmpCostItemVM)
        end
    end
end

function ShopCurrencyPageVM:ChangeCanSelectState(IsCan)
    local List = self.ShopCostItemVMs
    if nil == List or List:Length() == 0 then
        return
    end
    for i = 1, List:Length() do
        local TmpShopCostItemVM = List:Get(i)
        TmpShopCostItemVM.bClick = IsCan
    end
end

return ShopCurrencyPageVM
