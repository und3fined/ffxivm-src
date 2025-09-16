--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-02-24 15:25:56
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-02-24 15:27:26
FilePath: \Script\Game\Common\Frame\CommEasytoUseVM\EasyToUseSeletTabVM.lua
Description: 
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EasyToUseSelectItemVM = require("Game/Common/Frame/CommEasytoUseVM/EasyToUseSelectItemVM")

---@class EasyToUseSeletTabVM : UIViewModel
local EasyToUseSeletTabVM = LuaClass(UIViewModel)

function EasyToUseSeletTabVM:Ctor()
    self.PublicItemVMList = self:ResetBindableList(self.PublicItemVMList, EasyToUseSelectItemVM)
end

function EasyToUseSeletTabVM:SetSelectTabData(Data)
    self.PublicItemVMList:UpdateByValues(Data)
end

function EasyToUseSeletTabVM:OnSelectChangedItem(InIndex, ItemData, ItemView)
    self.ParentVM:OnSelectChangedItem(InIndex, ItemData, ItemView)
end

return EasyToUseSeletTabVM