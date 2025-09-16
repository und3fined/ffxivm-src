local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FateMainCfgTable = require("TableCfg/FateMainCfg")
local FateTargetCfgTable = require("TableCfg/FateTargetCfg")
local UIBindableList = require("UI/UIBindableList")
local FateFinishRewardItemVM = require("Game/Fate/VM/FateFinishRewardItemVM")
local FateConditionVM = require("Game/Fate/VM/FateConditionVM")
local FateDefine = require("Game/Fate/FateDefine")
local LootCfg = require("TableCfg/LootCfg")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local ProtoRes = require("Protocol/ProtoRes")
local FateAchievementCfgTable = require("TableCfg/FateAchievementCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local LSTR = _G.LSTR
local AchievementType = ProtoRes.Game.FATE_ACHIEVEMENT_TYPE

local FateFinishVM = LuaClass(UIViewModel)

function FateFinishVM:Ctor()
    self.bFinished = false
    self.FateName = ""
    self.HideConditionText = ""
    self.IconPath = ""
    self.RewardList = UIBindableList.New(FateFinishRewardItemVM)
    self.ConditionList = UIBindableList.New(FateConditionVM)
end

function FateFinishVM:OnBegin()

end

function FateFinishVM.CreateVM(Params)
    local VM = FateFinishVM.New()
    VM:UpdateVM(Params)
    return VM
end

function FateFinishVM:UpdateVM(InValue)
    if (InValue.Rewards == nil) then
        InValue.Rewards = {}
    end

    self.bFinished = InValue.bFinished
    self.FateName = InValue.FateName
    self.FateID = InValue.FateId
    self.IconPath = FateDefine.GetIconByFateID(self.FateID)
    local RewardCount = #InValue.Rewards
    local FateCfgData = _G.FateMgr:GetFateCfg(InValue.FateId)
    local RevealCount = 0

    local OldAchsState = InValue.OldAchsState
    local NewAchsState = InValue.NewAchsState

    if (OldAchsState == nil) then
        OldAchsState = {}
    end
    if (NewAchsState == nil) then
        NewAchsState = {}
    end

    if (InValue.Achievement == nil) then
        InValue.Achievement = {}
    end

    local TotalCount = 0
    local NewFinishedCount = 0

    for Index = 1, #NewAchsState do
        TotalCount = TotalCount + 1

        if (NewAchsState[Index] == 2) then
            NewFinishedCount = NewFinishedCount + 1
        end

        if (NewAchsState[Index] ~= OldAchsState[Index] and NewAchsState[Index] ~= 0) then
            local Data = InValue.Achievement[Index]
            if (Data ~= nil) then
                Data.ShowEffect = true
            end
        end
    end

    if (NewFinishedCount > 0 and TotalCount > 0 and (NewFinishedCount >= TotalCount)) then
        -- 这里全部完成，测试一下
        --MsgTipsUtil.ShowTips(LSTR("全部完成"))

        for Index, Data in pairs(InValue.Achievement) do
            Data.ShowEffect = true
        end
    end

    -- 策划需求，如果没有奖励，那么读取FATE表中的铜牌奖励，但是数量为0 -- by MichaelYang
    if (RewardCount < 1) then
        local ExpData = {}
        -- 新增需求 2025-07-01，如果没有奖励，那么显示经验0，以及铜牌奖励0
        ExpData.ItemResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP
        ExpData.Num = 0
        table.insert(InValue.Rewards, ExpData)

        if (FateCfgData == nil) then
            _G.FLOG_ERROR("无法获取 Fate 表格数据，ID是"..tostring(InValue.FateId))
        else
            if (FateCfgData.RewardCfg ~=nil and #FateCfgData.RewardCfg > 0) then
                local LootMapId = FateCfgData.RewardCfg[1].LootID
                local SearchStr = string.format("ID == %d", LootMapId)
                local LootMapping = LootMappingCfg:FindCfg(SearchStr)
                if (LootMapping==nil)then
                    _G.FLOG_ERROR("无法获取 LootMappingCfg 表格数据，ID是"..LootMapId)
                else
                    local LootId = LootMapping.Programs[1].ID
                    local LootTableData = LootCfg:FindCfgByKey(LootId)
                    if (LootTableData == nil) then
                        _G.FLOG_ERROR("无法获取 LootCfg 表格数据，ID是"..LootId)
                    else
                        local GemData = {}
                        GemData.ItemResID = LootTableData.Produce[1].ID
                        GemData.Num = 0
                        table.insert(InValue.Rewards, GemData)
                    end
                end
            else
                _G.FLOG_ERROR("无法获取 Fate 表格数据中的Reward，ID是"..InValue.FateId)
            end
        end
    end

    local EventCfg = FateAchievementCfgTable:FindCfgByKey(InValue.FateId)
    for Idx, Event in ipairs(InValue.Achievement) do
        Event.idx = Idx
        local bTargetValid = Event.Target ~= nil and Event.Target > 0
        if bTargetValid and Event.Progress ~= nil and Event.Progress >= Event.Target then
            RevealCount = RevealCount + 1
        end

        if (EventCfg ~= nil) then
            Event.RequireAward = EventCfg.Achievements[Idx].RequireAward
            Event.TableCount = EventCfg.Achievements[Idx].Count
        else
            _G.FLOG_ERROR("FateAchievementCfgTable:FindCfgByKey 无法找到数据，KEY ： %s", InValue.FateId)
        end

        -- 因为服务器没有存ID，无法判断是否多条件隐藏事件，因此在客户端做判断，多条件的隐藏事件都是1/1
        local IsMultiEvent = Event.ID == AchievementType.FATE_ACHIEVEMENT_TYPE_GENERAL_MUTLI_EVENT
        if (IsMultiEvent) then
            local bFinished = Event.Target ~= nil and Event.Target > 0 and Event.Progress >= Event.Target
            if (bFinished) then
                Event.Progress = 1
                Event.Target = 1
            else
                Event.Progress = 0
            end
        end
    end

    self.RewardList:UpdateByValues(InValue.Rewards)
    self.ConditionList:UpdateByValues(InValue.Achievement)
    self.HideConditionText = string.format(LSTR(190077), RevealCount)
end

return FateFinishVM