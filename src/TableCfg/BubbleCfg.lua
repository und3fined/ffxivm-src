-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BubbleCfg : CfgBase
local BubbleCfg = {
	TableName = "c_bubble_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BubbleCfg, { __index = CfgBase })

BubbleCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function BubbleCfg:FindAllCfgByNpcID(NpcID)
    local NpcSpecifier = "NPCID"
    return self:FindAllCfg(string.format("%s = %d", NpcSpecifier, NpcID))
end

function BubbleCfg:FindAllValueByNpcID(NpcID, ColumnName)
    local BubbleCfgs = self:FindAllCfgByNpcID(NpcID)

    if (BubbleCfgs == nil) then
        return nil
    end

    local Result = {}
    for _, Cfg in pairs(BubbleCfgs) do
        table.insert(Result, Cfg[ColumnName])
    end

    return Result
end

function BubbleCfg:FindAllIDsByNpcID(NpcID)
    local IDSpecifier = "ID"
    return self:FindAllValueByNpcID(NpcID, IDSpecifier)
end

function BubbleCfg:FindAllContentsByNpcID(NpcID)
    local ContentSpecifier = "BubbleContent"
    return self:FindAllValueByNpcID(NpcID, ContentSpecifier)
end

function BubbleCfg:FindAllOrdersByNpcID(NpcID)
    local OrderSpecifier = "BubbleOrder"
    return self:FindAllValueByNpcID(NpcID, OrderSpecifier)
end

function BubbleCfg:FindAllGroupIDsByNpcID(NpcID)
    local GroupSpecifier = "GroupID"
    return self:FindAllValueByNpcID(NpcID, GroupSpecifier)
end

function BubbleCfg:FindAllCfgByGroupID(GroupID)
    local AllCfgs = self:FindAllCfg(string.format("GroupID = %d", GroupID))
    return AllCfgs
end

function BubbleCfg:FindAllValueByGroupID(GroupID, ColumnName, Sorted)
    -- Get all configs
    local BubbleCfgs = self:FindAllCfgByGroupID(GroupID, Sorted)

    -- Extract column
    local Result = {}
    for _, Cfg in pairs(BubbleCfgs) do
        table.insert(Result, Cfg[ColumnName])
    end

    return Result
end

function BubbleCfg:FindAllContentsByGroupID(GroupID, Sorted)
    local ContentSpecifier = "BubbleContent"
    return self:FindAllValueByGroupID(GroupID, ContentSpecifier, Sorted)
end

function BubbleCfg:FindAllIDsByGroupID(GroupID, Sorted)
    local IDSpecifier = "ID"
    return self:FindAllValueByGroupID(GroupID, IDSpecifier, Sorted)
end

return BubbleCfg
