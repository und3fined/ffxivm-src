---
--- Author: Alex
--- DateTime: 2023-02-15 16:33:40
--- Description: 商店搜索界面数据结构
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ShopSearchItemVM = require("Game/Shop/ItemVM/ShopSearchItemVM")
local ShopDefine = require("Game/Shop/ShopDefine")

---@class ShopSearchPageVM : UIViewModel
---@field ShopId number@商店ID
---@field ShopName string@商店名称
---@field SearchPageList UIBindableList@搜索记录列表
---@field SearchInputLastRecord string@搜索输入框最后一次记录
local ShopSearchPageVM = LuaClass(UIViewModel)

---Ctor
function ShopSearchPageVM:Ctor()
    -- Main Part
    self.ShopId = 0
    self.ShopName = ""
    self.SearchPageList = UIBindableList.New(ShopSearchItemVM)
    self.SearchInputLastRecord = ""
end

function ShopSearchPageVM:IsEqualVM(Value)
    return self.ShopId == Value.ShopId
end

function ShopSearchPageVM:UpdateShopSearchPageVM(Value)
    self.ShopId = Value.ShopId
    self.ShopName = Value.ShopName
end

--- 添加搜索记录
---@param NewContent string@新的搜索记录
function ShopSearchPageVM:AddSearchRecord(NewContent)
    local HistoryList = self.SearchPageList
    if nil ~= HistoryList and HistoryList:Length() > 0 then
        for i = 1, HistoryList:Length() do
            local SearchItemVM = HistoryList:Get(i)
            if SearchItemVM.Content == NewContent then
                return
            end
        end
    end

    local TmpShopSearchItemVM = ShopSearchItemVM.New()
    TmpShopSearchItemVM.Content = NewContent

    if HistoryList:Length() == ShopDefine.ShopMaxSearchRecordNum then
        HistoryList:RemoveAt(ShopDefine.ShopMaxSearchRecordNum)
    end

    HistoryList:Insert(TmpShopSearchItemVM, 1)
end

--- 删除搜索记录
---@param Content string@要删除的搜索记录
function ShopSearchPageVM:DeleteSearchRecord(Content)
    local HistoryList = self.SearchPageList
    local TargetIndex = 0
    if nil ~= HistoryList and HistoryList:Length() > 0 then
        for i = 1, HistoryList:Length() do
            local SearchItemVM = HistoryList:Get(i)
            if SearchItemVM.Content == Content then
                TargetIndex = i
                break
            end
        end
    end

    HistoryList:RemoveAt(TargetIndex)
end


return ShopSearchPageVM
