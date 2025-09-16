---
--- Author: Leo
--- DateTime: 2023-05-05 12:22:34
--- Description: 收藏品系统物品
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CollectablesMgr = require("Game/Collectables/CollectablesMgr")

---@class CollectablesTransactionItemVM : UIViewModel
---@field CollectValue string @收藏品价值
---@field TicketIcon string @工票图标
---@field TicketReward number @工票报酬
---@field ExperienceReward number @经验报酬
---@field LowTicketReward number @低级工票报酬
---@field HighTicketReward number @高级工票报酬
---@field bIsMaxLevelCollect bool @是否满级收藏品
local CollectablesTransactionItemVM = LuaClass(UIViewModel)

function CollectablesTransactionItemVM:Ctor()
    self.CollectValue = ""
    self.TicketIcon = ""
    self.TicketReward = 0
    self.ExperienceReward = 0
    self.LowTicketReward = 0
    self.HighTicketReward = 0
end

function CollectablesTransactionItemVM:Init()

end

function CollectablesTransactionItemVM:OnBegin()

end

function CollectablesTransactionItemVM:OnEnd()

end

function CollectablesTransactionItemVM:IsEqualVM(Value)
    return true
end

function CollectablesTransactionItemVM:UpdateVM(Value)
    self.CollectValue = Value.CollectValue
    self.LowTicketReward = Value.LowTicketReward
    self.HighTicketReward = Value.HighTicketReward
    self.bIsMaxLevelCollect = Value.bIsMaxLevelCollect
    if self.bIsMaxLevelCollect == 1 then
        self.TicketReward = self.HighTicketReward
    else
        self.TicketReward = self.LowTicketReward
    end
    self.ExperienceReward = Value.ExperienceReward

     --确定工票图标
    local LastSelectData = CollectablesMgr.LastSelectData
    local SelectProfIndex = LastSelectData.ProfIndex or 1
    local ProfessionData = CollectablesMgr.ProfessionData
    self.TicketIcon = Value.TicketIcon

    local SelectProfessLevel = ProfessionData[SelectProfIndex].Level
    local ProfID = LastSelectData.ProfID or ProfessionData[1].ProfID
    local DropFilterIndex = LastSelectData.DropFilterIndexMap[ProfID] or 1
    local DropFilterTabData = CollectablesMgr:GetDropFilterData(SelectProfessLevel)
    local MaxLevel = DropFilterTabData[DropFilterIndex].MaxValue
    --如果不是选择已解锁最高等级字段，则职业等级超过当前等级范围 经验值变为1000
    local DefaultExperienceReward = 1000
    if SelectProfessLevel > MaxLevel then
        self.ExperienceReward = DefaultExperienceReward
    end
end

--- 设置返回的索引：0
function CollectablesTransactionItemVM:AdapterOnGetWidgetIndex()
    return 0
end

function CollectablesTransactionItemVM:AdapterOnGetCanBeSelected()
    return true
end

--- 返回子节点列表
function CollectablesTransactionItemVM:AdapterOnGetChildren()
    return {}
end

return CollectablesTransactionItemVM