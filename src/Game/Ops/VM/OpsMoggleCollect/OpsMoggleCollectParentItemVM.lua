--[[
Author: jususchen jususchen@tencent.com
Date: 2025-07-30 15:08:31
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-07-30 15:09:20
FilePath: \Script\Game\Ops\VM\OpsMoggleCollect\OpsMoggleCollectParentItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local OpsMoggleCollectNormalItemVM = require("Game/Ops/VM/OpsMoggleCollect/OpsMoggleCollectNormalItemVM")
local OpsMoggleCollectOrItemVM = require("Game/Ops/VM/OpsMoggleCollect/OpsMoggleCollectOrItemVM")
local OpsMoggleCollectNodeVM = require("Game/Ops/VM/OpsMoggleCollect/OpsMoggleCollectNodeVM")
local UIBindableList = require("UI/UIBindableList")

---@class OpsMoggleCollectParentItemVM : OpsMoggleCollectNodeVM
local OpsMoggleCollectParentItemVM = LuaClass(OpsMoggleCollectNodeVM)


function OpsMoggleCollectParentItemVM:Ctor()
    self.ItemVMList = nil
    self.OrItemVM = OpsMoggleCollectOrItemVM.New()
end

function OpsMoggleCollectParentItemVM:UpdateVM(Value)
    self.Super.UpdateVM(self, Value)

    if self.ItemVMList == nil then
        self.ItemVMList = UIBindableList.New(OpsMoggleCollectNormalItemVM)
    end
    self.ItemVMList:UpdateByValues(Value.SubNodes)
    local OrItemValue = table.clone(Value)
    OrItemValue.ItemList = self.ItemVMList
    self.OrItemVM:UpdateVM(OrItemValue)
end

function OpsMoggleCollectParentItemVM:AdapterOnGetIsCanExpand()
    return not self.bLock
end

function OpsMoggleCollectParentItemVM:AdapterOnGetCanBeSelected()
	return not self.bLock
end

function OpsMoggleCollectParentItemVM:AdapterOnGetWidgetIndex()
	return 0
end

function OpsMoggleCollectParentItemVM:AdapterOnGetChildren()
    return self:IsOrNode() and {self.OrItemVM} or (self.ItemVMList and self.ItemVMList:GetItems() or {})
end


return OpsMoggleCollectParentItemVM