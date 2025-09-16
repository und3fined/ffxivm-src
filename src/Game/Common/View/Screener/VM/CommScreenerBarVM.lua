---
--- Author: sammrli
--- DateTime: 2023-11-7 10:32
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CommScreenerTagItemVM = require ("Game/Common/View/Screener/VM/CommScreenerTagItemVM")

local UIBindableList = require("UI/UIBindableList")

---@class CommScreenerBarVM : UIViewModel
---@field TagVMList UIBindableList
local CommScreenerBarVM = LuaClass(UIViewModel)

---Ctor
function CommScreenerBarVM:Ctor()
    self.TagVMList = UIBindableList.New(CommScreenerTagItemVM)
end

---更新界面
---@param TagParams table<CommScreenerTagItemVMParam> @标签参数
function CommScreenerBarVM:UpdateView(TagParams)
    self.TagVMList:UpdateByValues(TagParams)
end

return CommScreenerBarVM