---
--- Author: Leo
--- DateTime: 2023-04-06 18:16:34
--- Description: 采集笔记
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MapCfg = require("TableCfg/MapCfg")
---@class GatheringLogMapItemVM : UIViewModel

local GatheringLogMapItemVM = LuaClass(UIViewModel)

---Ctor
function GatheringLogMapItemVM:Ctor()
    -- Main Part
    self.MapID = 0
    self.TabName = ""
    self.bSpaceVisible = true
end

function GatheringLogMapItemVM:IsEqualVM(Value)
    return self.MapID == Value.MapID
end

function GatheringLogMapItemVM:UpdateVM(Value)
    self.bSpaceVisible = true
    self.MapID = Value.MapID
    local MapID = self.MapID
    local Cfg = MapCfg:FindCfgByKey(MapID)
    self.TabName = Cfg.DisplayName
end

---@type 是否可以展开树形控件子节点
function GatheringLogMapItemVM:AdapterOnGetIsCanExpand()
    return false
end

---@type 设置返回的索引：0
function GatheringLogMapItemVM:AdapterOnGetWidgetIndex()
    return 0
end

function GatheringLogMapItemVM:AdapterOnGetCanBeSelected()
    return true
end

---@type 返回子节点列表
function GatheringLogMapItemVM:AdapterOnGetChildren()
    return {}
end

---@type 设置分类
function GatheringLogMapItemVM:AdapterSetCategory(ItemCategory)
    local MapID = self.MapID
    if ItemCategory == MapID then
        return
    end
	self:UpdateVM({MapID = ItemCategory})
end

return GatheringLogMapItemVM