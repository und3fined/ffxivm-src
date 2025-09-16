---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-3-28 19:00
--- Description: Fate通用方法
---

local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local MonsterCfgTable = require("TableCfg/MonsterCfg")
local BuffCfgTable = require("TableCfg/BuffCfg")
local NpcCfgTable = require("TableCfg/NpcCfg")
local SkillCfgTable = require("TableCfg/SkillMainCfg")
local EObjCfgTable = require("TableCfg/EObjCfg")
local WeatherCfgTable = require("TableCfg/WeatherCfg")
local ItemCfgTable = require("TableCfg/ItemCfg")
local FateAchievementCfgTable = require("TableCfg/FateAchievementCfg")
local FateAchievementEventCfgTable = require("TableCfg/FateAchievementEventCfg")
local FateDefine = require("Game/Fate/FateDefine")
local FateAchievementMultiEventCfg = require("TableCfg/FateAchievementMultiEventCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local LSTR = _G.LSTR
local CountText = "{Count}"
local AwardText = "{RequireAward}"
local FLOG_ERROR = _G.FLOG_ERROR
local HideText = LSTR(190115)

local MultiConId = 9000 -- 多条件了类型的ID

---@class FateUtil
local FateUtil = {}

function FateUtil.GetFateConditionNameByID(Params, ParamIndex, ConfigType)
    local ID = Params[ParamIndex]
    local SubText = LSTR(190115)
    if ConfigType == ProtoRes.FateConditionEventConfig.MONSTER_ID then
        local MonsterCfg = MonsterCfgTable:FindCfgByKey(ID)
        if MonsterCfg ~= nil and MonsterCfg.Name ~= nil then
            SubText = MonsterCfg.Name
        else
            FLOG_ERROR("Fate 危命目标中 , 怪物表获取数据出错 , ID : %s", ID)
        end
    elseif ConfigType == ProtoRes.FateConditionEventConfig.BUFF_ID then
        local BuffCfg = BuffCfgTable:FindCfgByKey(ID)
        if BuffCfg ~= nil and BuffCfg.BuffName ~= nil then
            SubText = BuffCfg.BuffName
        else
            FLOG_ERROR("Fate 危命目标中 , Buff表获取数据出错 , ID : %s", ID)
        end
    elseif ConfigType == ProtoRes.FateConditionEventConfig.GATHER_ID then
        local EObjCfg = EObjCfgTable:FindCfgByKey(ID)
        if EObjCfg ~= nil and EObjCfg.Name ~= nil then
            SubText = EObjCfg.Name
        else
            FLOG_ERROR("Fate 危命目标中 , EObj表获取数据出错 , ID : %s", ID)
        end
    elseif ConfigType == ProtoRes.FateConditionEventConfig.NPC_ID then
        local NpcCfg = NpcCfgTable:FindCfgByKey(ID)
        if NpcCfg ~= nil and NpcCfg.Name ~= nil then
            SubText = NpcCfg.Name
        else
            FLOG_ERROR("Fate 危命目标中 , NPC表获取数据出错 , ID : %s", ID)
        end
    elseif ConfigType == ProtoRes.FateConditionEventConfig.SKILL_ID then
        local CalcParamLength = #Params - ParamIndex + 1
        if (CalcParamLength == 2) then
            local SkillOneName = nil
            local SkillTwoName = nil

            local SkillCfg = SkillCfgTable:FindCfgByKey(Params[ParamIndex])
            if SkillCfg ~= nil and SkillCfg.SkillName ~= nil then
                SkillOneName = SkillCfg.SkillName
            else
                FLOG_ERROR("Fate 危命目标中 , Skill表获取数据出错 , ID : %s", ID)
                SkillOneName = ""
            end

            SkillCfg = SkillCfgTable:FindCfgByKey(Params[ParamIndex + 1])
            if SkillCfg ~= nil and SkillCfg.SkillName ~= nil then
                SkillTwoName = SkillCfg.SkillName
            else
                FLOG_ERROR("Fate 危命目标中 , Skill表获取数据出错 , ID : %s", ID)
                SkillTwoName = ""
            end

            SubText = string.format(LSTR(190067), SkillOneName, SkillTwoName)
        elseif (CalcParamLength == 1) then
            local SkillCfg = SkillCfgTable:FindCfgByKey(ID)
            if SkillCfg ~= nil and SkillCfg.SkillName ~= nil then
                SubText = SkillCfg.SkillName
            else
                FLOG_ERROR("Fate 危命目标中 , Skill表获取数据出错 , ID : %s", ID)
            end
        else
            FLOG_ERROR("FATE 隐藏条件中，技能参数配置超过2个")
        end
    elseif ConfigType == ProtoRes.FateConditionEventConfig.WEATHER_ID then
        local WeatherCfg = WeatherCfgTable:FindCfgByKey(ID)
        if WeatherCfg ~= nil and WeatherCfg.Name ~= nil then
            SubText = WeatherCfg.Name
        else
            FLOG_ERROR("Fate 危命目标中 , 天气表获取数据出错 , ID : %s", ID)
        end
    elseif ConfigType == ProtoRes.FateConditionEventConfig.TERRAIN_ID then
        SubText = tostring(ID)
    elseif ConfigType == ProtoRes.FateConditionEventConfig.ITEM_ID then
        local ItemCfg = ItemCfgTable:FindCfgByKey(ID)
        local ItemName = ItemCfgTable:GetItemName(ID)
        if ItemCfg ~= nil and ItemName ~= nil then
            SubText = ItemName
        else
            FLOG_ERROR("Fate 危命目标中 , Item表获取数据出错 , ID : %s", ID)
        end
    else
        SubText = tostring(ID)
    end
    return SubText
end

function FateUtil.GetPanelStatus(Value)
    if (Value == nil or Value == -1) then
        return FateDefine.HiddenCondiState.Hide
    end
    local ID = Value.ID
    local Progress = Value.Progress
    local TargetCount = Value.Target
    if (Progress == nil) then
        Progress = 0
    end
    if (TargetCount == nil) then
        TargetCount = 0
    end

    local EventCfg = FateAchievementEventCfgTable:FindCfgByKey(ID)
    if EventCfg == nil then
        return
    end
    local InGame = EventCfg.InGame
    local bInGameMatchType = InGame == ProtoRes.Game.FATE_ACHIEVEMENT_INGAME_OPTION.FATE_ACHIEVEMENT_INGAME_OPTION_MULTI
    if Progress == 0 and TargetCount == 0 then
        return FateDefine.HiddenCondiState.Hide
    elseif bInGameMatchType and Progress < TargetCount then
        return FateDefine.HiddenCondiState.Cycle
    elseif Progress == TargetCount then
        return FateDefine.HiddenCondiState.Complete
    else
        return FateDefine.HiddenCondiState.Cycle
    end
end

function FateUtil.GetConditionText(Value)
    if (Value == nil or Value == -1 or Value.ID == nil or Value.ID == -1) then
        return LSTR(190115)
    end
    local ID = Value.ID
    local Params = Value.Params
    local Progress = Value.Progress
    local TargetCount = Value.Target
    local TableCount = Value.TableCount
    local RequireReward = Value.RequireAward
    local EventCfg = FateAchievementEventCfgTable:FindCfgByKey(ID)
    if EventCfg == nil then 
        _G.FLOG_ERROR("危命目标事件未配置, ID是:"..tostring(ID))
        return LSTR(190115)
    end

    if TargetCount == nil or TargetCount == 0 then
        return HideText
    end

    local Text = EventCfg.Text
    local bIsMultiCondition = EventCfg.Type == MultiConId
    if (bIsMultiCondition) then
        if (Params == nil or #Params < 1) then
            FLOG_ERROR("无法获取 多条件数据，请检查")
            return HideText
        else
            -- 多条件，直接读表就行了
            for k,v in pairs(Params) do
                local TableData = FateAchievementMultiEventCfg:FindCfgByKey(v)
                if (TableData ~= nil) then
                    Text = TableData.DescriptionText
                    break
                end
            end
        end
    else
        -- 单条件        
        for ConfigIndex, ConfigType in ipairs(EventCfg.Config) do
            if ConfigType ~= nil then
                local SubText = FateUtil.GetFateConditionNameByID(Params, ConfigIndex, ConfigType)
                local Label = "{"..ConfigIndex.."}"
                Text = string.gsub(Text, Label, SubText)
            end
        end
    end

    Text = string.gsub(Text, CountText, TableCount)
    local bIsGold = RequireReward == ProtoRes.Game.FATE_ACHIEVEMENT_REQUIRE_AWARD.FATE_ACHIEVEMENT_REQUIRE_AWARD_GOLD
    if (bIsGold and not bIsMultiCondition) then
        Text = string.format("%s%s", Text, LSTR(190068))
    end

    local ConditionText = string.format("%s（%s/%s）", Text, Progress, TargetCount)
    return ConditionText
end

return FateUtil
