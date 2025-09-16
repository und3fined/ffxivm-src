---
--- Author: henghaoli
--- DateTime: 2024-08-02 18:57
--- Description: 红点树状结构定义
---

local LuaClass = require("Core/LuaClass")

local ENodeType = {
	Prof = 1,               -- 职业图标, 根节点, ID = ProfID
	Label = 2,              -- 技能页签, ID = 0
	Tab = 3,                -- ETabType作为ID
	Button = 4,             -- ButtonIndex作为ID
    MultiChoice = 5,        -- 多选一技能的根节点, 使用多选一技能母技能的SkillID作为ID
    MultiChoiceButton = 6,  -- 多选一的按钮, 因为多选一共用26~29的Index, 使用SkillID作为ID
    AdvancedPanel = 7,      -- 高级技能, 用技能按钮的Index作为ID
	Skill = 8,              -- 技能, SkillID作为ID
}

local ETabType = {
    Active = 1,   -- 主动技能
    Passive = 2,  -- 被动技能
}

local ENodeState = {
    NonLeaf = 1,    -- 非叶子节点
    Unchecked = 2,  -- 学习了但是没用过
    Checked = 3,    -- 学习了且用过
    Unlearned = 4,  -- 未学习
}



---@class SkillSystemRedDotNode
---@field Type ENodeType 枚举, 当前节点的类型
---@field ChildNodeList table<_, SkillSystemRedDotNode> 子节点
---@field UncheckedNum number 子节点没有点掉红点的数量
---@field ID numer 用于和相同深度其他节点区分的ID, 比如Skill类型的节点对应的ID就是SkillID
---@field NodeState number 节点的状态
local SkillSystemRedDotNode = LuaClass()

function SkillSystemRedDotNode:Ctor(Type, ID)
    self.Type = Type
    self.ChildNodeList = {}
    self.UncheckedNum = 0
    self.ID = ID or 0
    self.NodeState = ENodeState.NonLeaf
end

--- 红点是否被点掉
---@return bool
function SkillSystemRedDotNode:IsChecked()
    return self.UncheckedNum == 0
end

--- 添加子节点
---@param ChildNode SkillSystemRedDotNode
function SkillSystemRedDotNode:AddChildNode(ChildNode)
    if not ChildNode then
        return
    end

    table.insert(self.ChildNodeList, ChildNode)
    if not ChildNode:IsChecked() then
        self.UncheckedNum = self.UncheckedNum + 1
    end
end

--- 删除子节点
---@param ChildNode SkillSystemRedDotNode
function SkillSystemRedDotNode:RemoveChildNode(ChildNode)
    if not ChildNode then
        return
    end
    for i = #self.ChildNodeList, 1, -1 do
        if self.ChildNodeList[i].Type == ChildNode.Type and self.ChildNodeList[i].ID == ChildNode.ID then
            table.remove(self.ChildNodeList, i)
            self.UncheckedNum = self.UncheckedNum - 1
            break
        end
    end
end

function SkillSystemRedDotNode:SetDataByNode(Node)
    if not Node then
        return
    end
    self.Type = Node.Type
    self.ChildNodeList = {}
    for _, ChildNode in ipairs(Node.ChildNodeList) do
        self:AddChildNode(ChildNode)
    end
    self.UncheckedNum = Node.UncheckedNum or 0
    self.ID = Node.ID or 0
    self.NodeState = Node.NodeState or ENodeState.NonLeaf
end

SkillSystemRedDotNode.ENodeType = ENodeType
SkillSystemRedDotNode.ETabType = ETabType
SkillSystemRedDotNode.ENodeState = ENodeState

return SkillSystemRedDotNode