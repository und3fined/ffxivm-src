---
--- Author: Leo
--- DateTime: 2023-05-06 12:22:34
--- Description: 收藏品系统物品
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
---@class CollectablesPropItemVM : UIViewModel

---@field ID number @ID
---@field Icon string @图标路径
---@field CollectValue number @收藏价值
---@field bIsSelect boolean @是否选中
---@field GID number @GID全局唯一ID
local CollectablesPropItemVM = LuaClass(UIViewModel)

function CollectablesPropItemVM:Ctor()
   self.ID = 0
   self.Icon = ""
   self.CollectValue = 0
   self.bIsSelect = false
   self.GID = 0
end

function CollectablesPropItemVM:Init()

end

function CollectablesPropItemVM:OnBegin()

end

function CollectablesPropItemVM:OnEnd()

end

function CollectablesPropItemVM:IsEqualVM(Value)
    return true
end

function CollectablesPropItemVM:UpdateVM(Value)
    self.ID = Value.ResID
    self.GID = Value.GID
    local Cfg = ItemCfg:FindCfgByKey(self.ID)
    self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
    local Attr = Value.Attr
    local Collection = Attr.Collection
    self.CollectValue = Collection.CollectionValue
    self.Name = ItemCfg:GetItemName(self.ID)
end

--- 设置返回的索引：0
function CollectablesPropItemVM:AdapterOnGetWidgetIndex()
    return 0
end

function CollectablesPropItemVM:AdapterOnGetCanBeSelected()
    return true
end

--- 返回子节点列表
function CollectablesPropItemVM:AdapterOnGetChildren()
    return {}
end

return CollectablesPropItemVM