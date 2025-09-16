--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-02-24 15:25:18
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-02-24 15:55:25
FilePath: \Script\Game\Common\Frame\CommEasytoUseVM\CommEasyToUseSidebarVM.lua
Description: 
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CommEasyToUseSidebarVM = LuaClass(UIViewModel)
local EasyToUseSeletTabVM = require("Game/Common/Frame/CommEasytoUseVM/EasyToUseSeletTabVM")
local TimeUtil = require("Utils/TimeUtil")

function CommEasyToUseSidebarVM:Ctor()
    self.SideBarSelectVM = EasyToUseSeletTabVM.New()
    self.SideBarSelectVM.ParentVM = self
    self.SideBarSelectCallBack = nil
    self.CurSelectType = nil
    self.CurSelectIndex = nil
    self.SelectTime = nil
end

function CommEasyToUseSidebarVM:SetSelectTabData(Data)
    self.SideBarSelectVM:SetSelectTabData(Data)
end

function CommEasyToUseSidebarVM:SetTabSideBarSelectCallBack(SelectCallBack)
    self.SideBarSelectCallBack = SelectCallBack
end

--- 防止频繁点击 0.3s间隔切换
function CommEasyToUseSidebarVM:IsInClickInterval()
    local NowTime = TimeUtil.GetServerTimeMS()
    if not self.SelectTime or NowTime - self.SelectTime > 300 then
        self.SelectTime = NowTime
    else
       return true
    end

    return false
end

function CommEasyToUseSidebarVM:OnSelectChangedItem(InIndex, ItemData, ItemView)
    if self:IsInClickInterval() then return end
        
    --- 选中态更新
    local SelectItemVMList = self.SideBarSelectVM and self.SideBarSelectVM.PublicItemVMList or {}
    local IsLock = ItemData.IsLock
    if next(SelectItemVMList) then
        if self.CurSelectType and ItemData.Type ~= self.CurSelectType then
            local ViewModel = SelectItemVMList:Find(function(Item) return Item.Type == self.CurSelectType end)
            if ViewModel then
                ViewModel.bSelect = IsLock and _G.UE.ESlateVisibility.Visible or _G.UE.ESlateVisibility.Hidden
            end
        end

        local ViewModel = SelectItemVMList:Find(function(Item) return Item.Type == ItemData.Type end)
        if ViewModel then
            ViewModel.bSelect = IsLock and _G.UE.ESlateVisibility.Hidden or _G.UE.ESlateVisibility.Visible
        end
    end

    if not IsLock then
        self:SetCurSelectType(ItemData.Type)
        self:SetCurSelectIndex(InIndex)
    end

    local Callback = self.SideBarSelectCallBack
    if Callback then
        Callback(InIndex, ItemData, ItemView)
    end
end

--- 当前所选Type
function CommEasyToUseSidebarVM:SetCurSelectType(Type)
    self.CurSelectType = Type
end

function CommEasyToUseSidebarVM:SetCurSelectIndex(Index)
    self.CurSelectIndex = Index
end

return CommEasyToUseSidebarVM