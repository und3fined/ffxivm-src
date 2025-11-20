--[[
Author: jususchen jususchen@tencent.com
Date: 2025-08-05 15:31:14
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-08-05 16:09:50
FilePath: \Script\Game\Ops\VM\OpsMoggleCollect\OpsMoggleCollectOrItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local OpsMoggleCollectNodeVM = require("Game/Ops/VM/OpsMoggleCollect/OpsMoggleCollectNodeVM")

---@class OpsMoggleCollectOrItemVM: OpsMoggleCollectNodeVM
local OpsMoggleCollectOrItemVM = LuaClass(OpsMoggleCollectNodeVM)

function OpsMoggleCollectOrItemVM:Ctor()
    self.Item1 = nil
    self.Item2 = nil
end

function OpsMoggleCollectOrItemVM:UpdateVM(Value)
    self.Super.UpdateVM(self, Value)

    self.ItemList = Value.ItemList
    self.Item1 = self.ItemList:Get(1)
    self.Item2 = self.ItemList:Get(2)
end

function OpsMoggleCollectOrItemVM:AdapterOnGetCanBeSelected()
	return false
end

function OpsMoggleCollectOrItemVM:AdapterOnGetWidgetIndex()
	return 1
end


return OpsMoggleCollectOrItemVM