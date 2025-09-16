--
-- Author: sammrli
-- Date: 2023-11-28 9:54
-- Description:剧情设置
--

local MajorUtil = require("Utils/MajorUtil")

local ClientSetupID = require("Game/ClientSetup/ClientSetupID")

local MAX_TABLE_LENGTH = 512 --服务器字符串最大1024，预留一半插入新的过场动画

---@class StroySetting
---@field AutoSkipBrowsedCutScene boolean
---@field AutoSkipQuestSequence boolean
---@field CutSceneBrowsedTable table<number, table<number>> @table<副本id, talbe<SequenceID>>
local StorySetting = {
    AutoSkipBrowsedCutScene = nil,
    AutoSkipQuestSequence = nil,
    CutSceneBrowsedTableList = {},   --记录看过的过场动画table列表
}


local function TableToString(Table)
    local Result = ""
    if not Table then
        return Result
    end
    local i = 0
    for K, V in pairs(Table) do
         if i > 0 then
            Result = Result..( string.format("|%d:%s", K, table.concat(V, ",")))
         else
            Result = string.format("%d:%s", K, table.concat(V, ","))
         end
         i = i + 1
    end
    return Result
end

local function StringToTable(String)
    local Result = {}
    local Splits = string.split(String, "|")
    for i=1, #Splits do
        local KeyValue = string.split(Splits[i], ":")
        if #KeyValue == 2 then
            local Key = tonumber(KeyValue[1])
            local Value = {}
            local ValueSplit = string.split(KeyValue[2], ",")
            for j=1,#ValueSplit do
                table.insert(Value, tonumber(ValueSplit[j]))
            end
            Result[Key] = Value
        end
    end
    return Result
end

-- ==================================================
-- 外部系统接口
-- ==================================================

function StorySetting.Init()
    StorySetting.AutoSkipQuestSequence = true -- 切角色要重置设置
end

---获取是否跳过浏览过的过场动画设置
---@return boolean
function StorySetting.GetAutoSkipCutScene()
    return true --StorySetting.AutoSkipBrowsedCutScene
end

---设置是否跳过浏览过的过场动画
---@param IsSkip boolean
---@param IsSave boolean
function StorySetting.SetAutoSkipCutScene(IsSkip, IsSave)
    if IsSkip == StorySetting.AutoSkipBrowsedCutScene then
        return
    end
    StorySetting.AutoSkipBrowsedCutScene = IsSkip

    -- if IsSave then
    --     _G.ClientSetupMgr:SendSetReq(ClientSetupKey.CSKAutoSkipCutScene, tostring(IsSkip and 2 or 1))
    -- end
end

---监听客户端设置初始化
function StorySetting.OnGameEventClientSetupPost(StoryMgr, Params)
    local IsSet = Params.BoolParam1
	if IsSet then
		return
	end
    -- if Params.IntParam1 == ClientSetupKey.CSKAutoSkipCutScene then
    --     local RoleID = MajorUtil.GetMajorRoleID()
    --     if Params.ULongParam1 ~= RoleID then
    --         return
    --     end
    --     local Val = tonumber(Params.StringParam1)
    --     StorySetting.AutoSkipBrowsedCutScene = Val == 1
    -- end

    local RoleID = MajorUtil.GetMajorRoleID()
    if Params.ULongParam1 ~= RoleID then
        return
    end

    local SetupKey = Params.IntParam1

    if SetupKey == ClientSetupID.AutoSkipQuestSequence then
        local Val = tonumber(Params.StringParam1)
        StorySetting.AutoSkipQuestSequence = true --Val == 2
    end

    if SetupKey >= ClientSetupID.MinBrowsedCutScene and SetupKey <= ClientSetupID.MaxBrowsedCutScene then
        StorySetting.CutSceneBrowsedTableList[SetupKey] = StringToTable(Params.StringParam1)
    end
end

---是否阅览过
---@param SequenceID SequenceID
---@return boolean
function StorySetting.IsBrowsed(SequenceID)
    if _G.PWorldMgr:CurrIsInSingleDungeon() then
        return false -- 单人本不适用此设置
    end

    local CurrPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    --[[
    local WorldTable = StorySetting.CutSceneBrowsedTable[CurrPWorldResID]
    if WorldTable then
        for i=1,#WorldTable do
            if WorldTable[i] == SequenceID then
                return true
            end
        end
    end
    return false
    ]]
    for _, Container in pairs(StorySetting.CutSceneBrowsedTableList) do
        local BrowsedTable = Container[CurrPWorldResID]
        if BrowsedTable then
            for i=1, #BrowsedTable do
                if BrowsedTable[i] == SequenceID then
                    return true
                end
            end
        end
    end
    return false
end

---同步阅览设置给服务器
---@param SequenceID SequenceID
function StorySetting.SendBrowsedSetup(SequenceID)
    --判断是否副本类型
    if not _G.PWorldMgr:CurrIsInDungeon()
    or _G.PWorldMgr:CurrIsInSingleDungeon() then -- 单人本不适用此设置
        return
    end

    if StorySetting.IsBrowsed(SequenceID) then
        return
    end

    local Length = math.max(1, table.length(StorySetting.CutSceneBrowsedTableList))
    local Key = ClientSetupID.MinBrowsedCutScene + Length

    local CurrPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local BrowsedTable = nil
    local Container = nil
    for _, V in pairs(StorySetting.CutSceneBrowsedTableList) do
        if V[CurrPWorldResID] then
            Container = V
            BrowsedTable = Container[CurrPWorldResID]
            break
        end
    end
    if not BrowsedTable then
        BrowsedTable = {}
        Container = StorySetting.CutSceneBrowsedTableList[Key]
        if Container then
            local Str = TableToString(Container)
            if string.len(Str) >= MAX_TABLE_LENGTH then --超出长度,新增容器
                Key = Key + 1
                StorySetting.CutSceneBrowsedTableList[Key] = {}
                Container = StorySetting.CutSceneBrowsedTableList[Key]
            end
        else
            StorySetting.CutSceneBrowsedTableList[Key] = {}
            Container = StorySetting.CutSceneBrowsedTableList[Key]
        end
        Container[CurrPWorldResID] = BrowsedTable
    end
    table.insert(BrowsedTable, SequenceID)

    local SetupValue = TableToString(Container)
    _G.ClientSetupMgr:SendSetReq(Key, SetupValue)
end

---是否跳过
---@param SequenceID SequenceID
---@return boolean
function StorySetting.IsSkip(SequenceID)
    if not SequenceID then
        return
    end
    if StorySetting.GetAutoSkipCutScene() then
        return StorySetting.IsBrowsed(SequenceID)
    end
    return false
end

---获取是否跳过任务剧情动画设置
---@return boolean
function StorySetting.GetAutoSkipQuestSequence()
    return true --StorySetting.AutoSkipQuestSequence
end

---设置是否跳过任务剧情动画（包括单人本过场）
---@param IsSkip boolean
---@param IsSave boolean
function StorySetting.SetAutoSkipQuestSequence(IsSkip, IsSave)
    local OldValue = StorySetting.AutoSkipQuestSequence
    if IsSkip == OldValue then
        return
    end
    if not IsSkip then
        _G.QuestMgr:ClearCountSkipQuestSequence()
    end
    StorySetting.AutoSkipQuestSequence = IsSkip
end

return StorySetting