---
--- Author: Leo
--- DateTime: 2023-04-03 17:16:34
--- Description: 采集笔记搜索记录列表
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
---@class GatheringSearchRescordVM : UIViewModel
---@field Name string

local GatheringSearchRescordVM = LuaClass(UIViewModel)

---Ctor
function GatheringSearchRescordVM:Ctor()
    -- Main Part
    self.SearchText = ""
end

function GatheringSearchRescordVM:IsEqualVM(Value)
    return true
end


function GatheringSearchRescordVM:UpdateVM(Value)
    self.SearchText = Value.SearchText
end

---@type 是否可以展开树形控件子节点
function GatheringSearchRescordVM:AdapterOnGetIsCanExpand()
    return true
end

--- 设置返回的索引：0
function GatheringSearchRescordVM:AdapterOnGetWidgetIndex()
    return 0
end

function GatheringSearchRescordVM:AdapterOnGetCanBeSelected()
    return true
end

--- 返回子节点列表
function GatheringSearchRescordVM:AdapterOnGetChildren()
    return {}
end

return GatheringSearchRescordVM