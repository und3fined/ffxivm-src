---
--- Author: Administrator
--- DateTime: 2025-04-22 10:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GameNetMsgRegister = require("Register/GameNetMsgRegister")
local ChocoboRaceSkillDisplayCfg = require("TableCfg/ChocoboRaceSkillDisplayCfg")
local Json = require("Core/Json")
local ProtoCS = require ("Protocol/ProtoCS")
local TimeUtil = require("Utils/TimeUtil")
local SUB_MSG_ID = ProtoCS.ChocoboRaceCmd
local CS_CMD_CHOCOBO_RACE = ProtoCS.CS_CMD.CS_CMD_CHOCOBO_RACE

---@class ChocoboRaceGMTargetInfoView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Content URichTextBox
---@field FButton UFButton
---@field FButton_1 UFButton
---@field FButton_2 UFButton
---@field ImageMask UImage
---@field TextBlock UTextBlock
---@field TextBlock_1 UTextBlock
---@field TextBlock_99 UTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRaceGMTargetInfoView = LuaClass(UIView, true)

function ChocoboRaceGMTargetInfoView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Content = nil
	--self.FButton = nil
	--self.FButton_1 = nil
	--self.FButton_2 = nil
	--self.ImageMask = nil
	--self.TextBlock = nil
	--self.TextBlock_1 = nil
	--self.TextBlock_99 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRaceGMTargetInfoView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRaceGMTargetInfoView:OnInit()
    self.SelectedIndex = -1  -- -1 到 7

    local Register = self.GameNetMsgRegister
    if nil == Register then
        Register = GameNetMsgRegister.New()
        self.GameNetMsgRegister = Register
    end

    if nil ~= Register then
        Register:Register(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceDebugInfo, self, self.OnNetMsgRaceDebugInfo)
        Register:Register(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceAilog, self, self.OnNetMsgRaceAILog)
    end
    
    self.SkillName = {}
    local AllSkillCfg = ChocoboRaceSkillDisplayCfg:FindAllCfg()
    for _, Value in pairs(AllSkillCfg) do
        self.SkillName[Value.ID] = Value.Name
    end
    
    self.StateName = {
        [0] = "无效果",
        [1] = "冲刺速度",
        [2] = "体力减少无效",
        [3] = "体力之药",
        [4] = "英雄药",            
        [5] = "陆行鸟反射",
        [6] = "加重",
        [7] = "失控",
        [8] = "动摇",
        [9] = "能力封印",
        [10] = "道具封印",
        [11] = "荆棘种子预兆",
        [12] = "荆棘种子",
        [13] = "陆行鸟沉默预兆",
        [14] = "陆行鸟沉默",
        [15] = "陆行鸟震荡预兆",
        [16] = "陆行鸟震荡",
        [17] = "动摇前",
        [18] = "失控前",
        [19] = "陆行鸟吸收预兆",
        [20] = "陆行鸟吸收",
        [21] = "模仿",
        [22] = "鸟羽结界",
        [23] = "超级冲刺",
        [24] = "陆行鸟之罩",
        [25] = "减速网",
        [26] = "迷瘴",
        [27] = "失明",
        [28] = "陆行鸟偷取",
        [29] = "陆行鸟治疗",
        [30] = "陆行鸟康复",
        [31] = "陆行鸟活力",
        [32] = "陆行鸟镇静",
        [33] = "道具变换",
        [34] = "体力偷取",
        [35] = "陆行鸟恢复药",
        [36] = "陆行鸟以太药",
        [37] = "酒神之水",
        [38] = "重力球",
        [39] = "陆行鸟陨石",
        [40] = "体力互换",
        [41] = "蜘蛛丝",
        [42] = "绊脚石",
        [43] = "陆行鸟闪电",
        [44] = "魅惑之羽",
        [45] = "禁言",
    }

    self.BuffName = {
        [0] = "无效果",
        [1] = "亢奋",         -- RaceEffectExcited
        [2] = "振翅",         -- RaceEffectWing
        [3] = "治疗",         -- RaceEffectHealth
        [4] = "康复",         -- RaceEffectWell
        [5] = "活力",         -- RaceEffectActive
        [6] = "镇静",         -- RaceEffectCalm
        [7] = "反射",         -- RaceEffectReflex
        [8] = "偷取",         -- RaceEffectSteal
        [9] = "沉默",         -- RaceEffectSilence
        [10] = "震荡",        -- RaceEffectShock
        [11] = "吸收",        -- RaceEffectAbsorb
        [12] = "变换",        -- RaceEffectChange
        [13] = "模仿",        -- RaceEffectImpersonator
        [14] = "鸟羽",        -- RaceEffectWingField
        [15] = "超冲",        -- RaceEffectDash
        [16] = "吸能",        -- RaceEffectStealStamina
        [17] = "护罩",        -- RaceEffectGuard
        [18] = "加重",        -- RaceEffectHeavy
        [19] = "失控",        -- RaceEffectOutControl
        [20] = "恢复",        -- RaceEffectRecovery
        [21] = "经验",        -- RaceEffectExp
        [22] = "起冲",        -- RaceEffectBeginSprint
        [23] = "重生",        -- RaceEffectReborn
        [24] = "弱化",        -- RaceEffectWeaker
        [25] = "免疫",        -- RaceEffectImmunity
        [26] = "锁定",        -- RaceEffectLock
        [27] = "跑鞋",        -- RaceEffectSprint
        [28] = "以太",        -- RaceEffectHot
        [29] = "酒水",        -- RaceEffectWine
        [30] = "重力",        -- RaceEffectGravity
        [31] = "荆棘",        -- RaceEffectFireField
        [32] = "英雄",        -- RaceEffectInvincible
        [33] = "陨石",        -- RaceEffectStone
        [34] = "互换",        -- RaceEffectExchange
        [35] = "蜘蛛",        -- RaceEffectSpider
        [36] = "绊脚",        -- RaceEffectBlock
        [37] = "减速",        -- RaceEffectDeceleration
        [38] = "迷瘴",        -- RaceEffectMist
        [39] = "闪电",        -- RaceEffectLightning
        [40] = "魅惑",        -- RaceEffectCharm
        [41] = "失明",        -- RaceEffectBlind
        [42] = "减速网",      -- RaceEffectDecelerationWang
        [43] = "沉默结界",    -- RaceEffectMuteWang
        [44] = "充沛",        -- RaceEffectEnergyEnough
        [45] = "坚韧",        -- RaceEffectTough
        [46] = "震荡结界",    -- RaceEffectShockWang
        [47] = "超能冲刺",    -- RaceEffectSuperDash
        [48] = "失控耐性",    -- RaceEffectOutControlTolerance
        [49] = "加重耐性",     -- RaceEffectHeavyTolerance
        [100] = "加速状态",
        [101] = "疲惫状态",
        [103] = "無敵狀態",
        [104] = "踏板加速狀態",
        [105] = "禁言",
        [106] = "动摇",
        [107] = "虚弱",
    }
    
    self.GimmickNames = {
        [0] = "",
        [1] = "加速床",
        [2] = "加重床",
        [3] = "损害床",
        [4] = "回复床",
        [5] = "宝箱",
        [6] = "减速地带",
    }
    
    -- 初始化缓存
    self.SkillHistory = self.SkillHistory or { maxSize = 20, data = {} }
    self.BuffRecords = self.BuffRecords or { maxSize = 20, data = {} }
    self.GimmickLogs = self.GimmickLogs or { maxSize = 20, data = {} }
end

function ChocoboRaceGMTargetInfoView:OnDestroy()
    local Register = self.GameNetMsgRegister
    if Register then
        Register:UnRegisterAll()
    end
end

function ChocoboRaceGMTargetInfoView:OnShow()
    _G.GMMgr:ReqGM("entertain race racelogset")
    self.IsPaused = true
    self.TextBlock_99:SetText("切换监听目标")
    self.TextBlock:SetText("清空")
    self.TextBlock_1:SetText("开始")
    self.Content:SetText(_G.LSTR(1440024))

    self.MaxRacerNum = _G.ChocoboRaceMgr:GetRacerNum()
    self.GameBegin = self.MaxRacerNum > 0
    UIUtil.SetRenderOpacity(self.ImageMask, 0.5)
end

function ChocoboRaceGMTargetInfoView:OnHide()
end

function ChocoboRaceGMTargetInfoView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.FButton, self.OnListenSelectedTargetClick)
    UIUtil.AddOnClickedEvent(self, self.FButton_1, self.OnClearListenClick)
    UIUtil.AddOnClickedEvent(self, self.FButton_2, self.ToggleDataFlow)
end

function ChocoboRaceGMTargetInfoView:OnListenSelectedTargetClick()
    if not self.GameBegin then return end
    local Max = self.MaxRacerNum or 8

    self.ServerBuffCache = nil
    self.BuffCache = nil
    self.SelectedIndex = self.SelectedIndex + 1
    if self.SelectedIndex >= Max then
        self.SelectedIndex = -1
    end
end

function ChocoboRaceGMTargetInfoView:ToggleDataFlow()
    self.IsPaused = not self.IsPaused
    self.TextBlock_1:SetText(self.IsPaused and "继续" or "暂停")
end

function ChocoboRaceGMTargetInfoView:OnClearListenClick()
    self.SkillHistory = { maxSize = 20, data = {} }
    self.BuffRecords = { maxSize = 20, data = {} }
    self.GimmickLogs = { maxSize = 20, data = {} }
    self.ServerBuffCache = nil
    self.BuffCache = nil
    self.Content:SetText("已清空")
end

function ChocoboRaceGMTargetInfoView:OnRegisterTimer()
    self:RegisterTimer(self.OnTimer, 0, 0.2, 0)
end

function ChocoboRaceGMTargetInfoView:OnTimer()
    if not _G.ChocoboRaceMgr:IsChocoboRacePWorld() then
        return
    end
    
    self:SendReq(self.SelectedIndex)

    self.TimerCounter = (self.TimerCounter or 0) + 1
    if self.TimerCounter >= 5 then
        self:SendAILogReq(self.SelectedIndex)
        self.TimerCounter = 0
    end
end

function ChocoboRaceGMTargetInfoView:SendReq(Index)
    if not self.GameBegin or self.IsPaused then return end
    
    local Params = {}
    Params.Cmd = SUB_MSG_ID.ChocoboRaceDebugInfo
    Params.debugdata = {}
    Params.debugdata.Index = Index
    Params.RaceID = _G.PWorldMgr:GetCurrPWorldInstID()
    _G.GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceDebugInfo, Params)
end

function ChocoboRaceGMTargetInfoView:SendAILogReq(Index)
    if not self.GameBegin or self.IsPaused then return end
    
    local Params = {}
    Params.Cmd = SUB_MSG_ID.ChocoboRaceAilog
    Params.debugdata = {}
    Params.debugdata.Index = Index
    Params.RaceID = _G.PWorldMgr:GetCurrPWorldInstID()
    _G.GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceAilog, Params)
end


local function SetColorFormat(Text, Color)
    return string.format("<span color=\"%s\" size=\"20\">%s</>", Color, Text)
end

-- 颜色常量定义
local COLOR_TITLE = "#d1ba8e"    -- 金色
local COLOR_RACER = "#89bd88"    -- 绿色
local COLOR_SKILL = "#d1906d"    -- 橙色
local COLOR_BUFF = "#6fb1e9"     
local COLOR_GIMMICK = "#ac88dd"  
local COLOR_TIME = "#d5d5d5"     
local COLOR_WARNING = "#dc5868"  -- 红色
local COLOR_NORMAL = "#ffeebb"   -- 白色

function ChocoboRaceGMTargetInfoView:OnNetMsgRaceDebugInfo(MsgBody)
    if not MsgBody or not MsgBody.debuginfo then return end

    local jsonData = Json.decode(MsgBody.debuginfo.debuginfo or "{}") or {}

    -- 更新缓存
    self:UpdateSkillCache(jsonData.skillDebug)
    self:UpdateBuffCache(jsonData.buffDebug)
    self:UpdateGimmickCache(jsonData.gimmickDebug)

    -- 构建显示内容
    local ContentText = "【当前监听对象编号：" .. SetColorFormat(tostring(self.SelectedIndex + 1), "#00FF00")..  "】\n\n"
    ContentText = ContentText .. self:BuildRacerSection(jsonData.racers)
    ContentText = ContentText .. self:BuildBuffState(jsonData.buffDebug)
    ContentText = ContentText .. self:BuildBuffSection()
    ContentText = ContentText .. self:BuildSkillSection()
    ContentText = ContentText .. self:BuildGimmickSection()

    self.Content:SetText(ContentText)
end

function ChocoboRaceGMTargetInfoView:OnNetMsgRaceAILog(MsgBody)
    if nil == MsgBody or not MsgBody.ailogdata then return end
    
    local DataList = MsgBody.ailogdata.logdata
    for __, Data in pairs(DataList) do
        local JsonData = Json.decode(Data or "{}") or {}
        _G.FLOG_INFO( "OnNetMsgRaceAILog: " .. _G.table_to_string_block(JsonData))
    end
end

--[[ 缓存管理方法 ]]--
function ChocoboRaceGMTargetInfoView:UpdateSkillCache(skillList)
    for _, skill in ipairs(skillList or {}) do
        table.insert(self.SkillHistory.data, 1, skill)
        while #self.SkillHistory.data > self.SkillHistory.maxSize do
            table.remove(self.SkillHistory.data)
        end
    end
end

function ChocoboRaceGMTargetInfoView:UpdateBuffCache(buffList)
    for _, buff in ipairs(buffList or {}) do
        table.insert(self.BuffRecords.data, 1, buff)
        while #self.BuffRecords.data > self.BuffRecords.maxSize do
            table.remove(self.BuffRecords.data)
        end
    end
end

function ChocoboRaceGMTargetInfoView:UpdateGimmickCache(gimmickList)
    for _, gimmick in ipairs(gimmickList or {}) do
        table.insert(self.GimmickLogs.data, 1, gimmick)
        while #self.GimmickLogs.data > self.GimmickLogs.maxSize do
            table.remove(self.GimmickLogs.data)
        end
    end
end

function ChocoboRaceGMTargetInfoView:BuildBuffState(buffList)
    _G.FLOG_INFO( "BuildBuffState: " .. table.tostring(buffList))
    self.ServerBuffCache = self.ServerBuffCache or  {
        maxRecords = 5,    -- 最大缓存记录数
        records = {}       -- 存储格式：{buffid, name, status, remain, source}
    }

    self.BuffCache = self.BuffCache or {
        maxSize = 5,  -- 最大缓存数量
        active = {},   -- 当前生效中的BUFF {id, name}
        history = {}   -- 已结束的BUFF {id, name}
    }

    local section = "\n"..SetColorFormat("【客户端状态】", COLOR_TITLE).."\n"
    self:UpdateClientState()
    section = section .. self:BuildClientStateDisplay()

    section = section .. "\n\n"..SetColorFormat("【服务器BUFF】", COLOR_TITLE).."\n"
    self:ProcessServerBuffs(buffList)
    section = section .. self:BuildServerBuffDisplay()
    
    return section
end

function ChocoboRaceGMTargetInfoView:UpdateClientState()
    local racer = _G.ChocoboRaceMgr:GetRacerByIndex(self.SelectedIndex + 1)
    if not racer then return end

    local buffFlags = racer:GetBuffFlags()

    -- 阶段1：更新激活状态
    for stateid, flag in pairs(buffFlags) do
        if flag then
            -- 新增或更新激活状态
            if not self.BuffCache.active[stateid] then
                self.BuffCache.active[stateid] = {
                    id = stateid,
                    name = self:GetStateName(stateid),
                    startTime = racer:GetBuffTimeDataByID(stateid).StartTime or 0
                }
            end
        else
            -- 移出激活状态到历史记录
            if self.BuffCache.active[stateid] then
                table.insert(self.BuffCache.history, 1, {
                    id = stateid,
                    name = self.BuffCache.active[stateid].name,
                    duration = (racer:GetBuffTimeDataByID(stateid).EndTime or 0) - (racer:GetBuffTimeDataByID(stateid).StartTime or 0)
                })
                self.BuffCache.active[stateid] = nil
            end
        end
    end

    -- 阶段2：清理历史记录
    while #self.BuffCache.history > self.BuffCache.maxSize do
        table.remove(self.BuffCache.history)
    end
end

function ChocoboRaceGMTargetInfoView:BuildClientStateDisplay()
    local currentTime = TimeUtil.GetServerLogicTimeMS()
    local section = ""
    local formatStr = "%s | %s | %s | %s"
    local header = SetColorFormat(string.format(formatStr, "ID", "名称", "持续时间", "状态"), "#AAAAAA")

    -- 表头
    section = section .. header .. "\n"

    -- 合并激活和最近的历史记录
    local displayList = {}

    -- 添加激活状态（按持续时间排序）
    for _, buff in pairs(self.BuffCache.active) do
        table.insert(displayList, {
            type = "active",
            data = buff,
            duration = currentTime - buff.startTime
        })
    end

    -- 添加历史记录（最多补足到最大数量）
    for i = 1, math.min(#self.BuffCache.history, self.BuffCache.maxSize) do
        table.insert(displayList, {
            type = "history",
            data = self.BuffCache.history[i],
            duration = self.BuffCache.history[i].duration
        })
    end

    -- 显示处理（最多显示5条）
    for i = 1, 5 do
        local item = displayList[i]
        if item then
            local stateText, stateColor, durationText
            if item.type == "active" then
                stateText = "持续中"
                stateColor = "#00FF00"
                durationText = self:FormatDuration(item.duration)
            else
                stateText = "已结束"
                stateColor = "#FF0000"
                durationText = self:FormatDuration(item.duration)
            end

            section = section .. string.format(formatStr.."\n",
                    SetColorFormat(string.format("[%d]", item.data.id), "#00BFFF"),
                    SetColorFormat(item.data.name, "#FFFFFF"),
                    SetColorFormat(durationText, "#00FF00"),
                    SetColorFormat(stateText, "#FFFFFF")
            )
        else
            -- 补充空行
            section = section .. SetColorFormat(
                    string.format(formatStr, " -", " -", " -", " -"),
                    "#AAAAAA"
            ).."\n"
        end
    end

    return section
end

-- BUFF数据处理方法
function ChocoboRaceGMTargetInfoView:ProcessServerBuffs(buffList)
    if not buffList then return end

    -- 插入新数据到缓存头部
    for _, buff in ipairs(buffList) do
        -- 计算剩余时间（单位：MS）
        local remain = buff.lasttime

        -- 确定状态
        local status
        if buff.buffend == 1 then
            status = "已结束"
        else
            status = remain > 0 and "触发" or "持续中"
        end

        -- 插入到缓存头部
        table.insert(self.ServerBuffCache.records, 1, {
            id = buff.buffid,
            name = self:GetBuffName(buff.buffid),  -- 假设有获取名称的方法
            status = status,
            remain = self:FormatDuration(remain),
            source = buff.fromindex + 1
        })
    end

    -- 清理旧数据（保留最新5条）
    while #self.ServerBuffCache.records > self.ServerBuffCache.maxRecords do
        table.remove(self.ServerBuffCache.records)
    end
end

-- 数据显示方法
function ChocoboRaceGMTargetInfoView:BuildServerBuffDisplay()
    local section = ""

    -- 表头
    section = section .. SetColorFormat("ID | 名称 | 持续时间 | 状态 | 来源", "#AAAAAA").."\n"

    -- 数据行（始终显示5行）
    for i = 1, 5 do
        local record = self.ServerBuffCache.records[i]
        if record then
            section = section .. string.format("%s | %s | %s | %s | %s\n",
                    SetColorFormat(string.format("[%d]", record.id), "#00BFFF"),
                    SetColorFormat(record.name, "#FFFFFF"),
                    SetColorFormat(record.remain, "#00FF00"),
                    SetColorFormat(record.status, "#FFFFFF"),
                    SetColorFormat(string.format("%d号", record.source), "#00BFFF")
            )
        else
            -- 补充空行
            section = section .. SetColorFormat("-  |  -  |  -  |  -  |  -", "#AAAAAA").."\n"
        end
    end

    return section
end

-- 毫秒转可读时间格式
function ChocoboRaceGMTargetInfoView:FormatDuration(ms)
    if not ms then return "0ms" end
    if ms < 1000 then
        return string.format("%dms", ms)
    end
    local seconds = math.floor(ms / 1000)
    if seconds < 60 then
        return string.format("%.1fs", ms/1000)
    end
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    return string.format("%dm%02ds", minutes, seconds)
end

function ChocoboRaceGMTargetInfoView:BuildRacerSection(racers)
    local section = SetColorFormat("【陆行鸟赛手详细数据】", COLOR_TITLE).."\n\n"

    for _, racer in ipairs(racers or {}) do
        local index = (racer.index and (racer.index + 1)) or 0

        local raceData = _G.ChocoboRaceMgr:GetRacerDataByIndex(index) or nil

        local name = (raceData and raceData.Name) or "未知赛手"
        local color = (raceData and raceData.Color) or COLOR_NORMAL
        local level = (raceData and raceData.Level) or "1"

        local armor = (raceData and raceData.Armor) or {}
        local armorStr = string.format("头部:%d 身体:%d 脚部:%d",
                armor.Head or 0,
                armor.Body or 0,
                armor.Feet or 0)

        local speed = racer.speed or 0
        local acc = racer.acc or 0
        local speedColor = acc > 0 and COLOR_RACER or COLOR_WARNING

        local abilities = (raceData and raceData.Abilities) or {}
        local abilityStr = ""
        if #abilities > 0 then
            abilityStr = "\n技能: "..table.concat(abilities, ", ")
        end

        local aidInfo = ""
        if racer.aid then
            aidInfo = string.format("\nAI信息: ID=%d 个性=%d 能力值=%d",
                    racer.aid.aiid or 0,
                    racer.aid.personality or 0,
                    racer.aid.abilityhold or 0)
        end

        local attr = racer.attr or {}
        local attrStr = string.format(
                "\n属性: 技能强度=%d 最高速度=%d 冲刺速度=%d 适应力=%d 能力参数=%d",
                attr.accAbility or 0,
                attr.maxSpeedParam or 0,
                attr.sprintParam or 0,
                attr.adaptParam or 0,
                attr.abilityParam or 0
        )

        local positionInfo = string.format("\n位置: 赛道=%d 区域=%d",
                racer.track or 0,
                racer.divisionIndex or 0)

        local treasureInfo = (racer.treasureId and racer.treasureId ~= 0) and
                string.format("\n携带宝物: %d", racer.treasureId) or ""

        section = section .. table.concat({
            SetColorFormat(string.format("编号%d: %s", index, name), COLOR_WARNING),
            " 等级: "..level,
            " 颜色: "..color,
            "\n装备: "..armorStr,
            abilityStr,
            "\n速度: "..SetColorFormat(tostring(speed), speedColor),
            " 加速度: "..SetColorFormat(tostring(acc), speedColor),
            "\n体力: "..(racer.statima or 0),
            attrStr,
            racer.Rank and string.format("\n当前排名: %d", racer.Rank) or "",
            aidInfo,
            positionInfo,
            treasureInfo,
            "\n--------------------------------\n"
        })
    end

    return section
end

function ChocoboRaceGMTargetInfoView:BuildSkillSection()
    local section = "\n"..SetColorFormat("【技能触发详情】", COLOR_TITLE).."\n"

    if not self.SkillHistory or #(self.SkillHistory.data or {}) == 0 then
        return section.."无近期技能记录\n"
    end

    for i = 1, #self.SkillHistory.data do
        local skill = self.SkillHistory.data[i] or {}

        section = section..table.concat({
            string.format("[编号%d]", skill.index + 1 or 0),
            string.format("%d", skill.skillid or 0),
            SetColorFormat(self:GetSkillName(skill.skillid) or "未知技能", COLOR_SKILL),
            SetColorFormat(skill.time or "未知时间", COLOR_TIME),
            "\n"
        }, "\t")
    end

    return section.."\n"
end

function ChocoboRaceGMTargetInfoView:BuildBuffSection()
    local section = "\n"..SetColorFormat("【BUFF日志】", COLOR_TITLE).."\n"

    if not self.BuffRecords or #(self.BuffRecords.data or {}) == 0 then
        return section.."无BUFF\n"
    end

    for i = 1, #self.BuffRecords.data do
        local buff = self.BuffRecords.data[i] or {}

        section = section.."\n"..SetColorFormat(string.format("[%d] %s",
                buff.buffid or 0,
                self:GetBuffName(buff.buffid) or "未知BUFF"), "#00FF00").."\n"

        --{1={buffid=10,toindex=7,fromroleid=0,time=2025-06-19T18:38:13.944762857+08:00,toroleid=9693168007654421,fromindex=4,lasttime=1200,buffend=1}}
        section = section..table.concat({
            string.format("触发者: 编号%d(RoleID:%d)",
                    (buff.fromindex and buff.fromindex + 1) or 0,
                    buff.fromroleid or 0),
            string.format("目标: 编号%d(RoleID:%d)",
                    (buff.toindex and buff.toindex + 1) or 0,
                    buff.toroleid or 0),
            SetColorFormat(string.format("持续时间: %s", tostring(buff.lasttime) or "未知"), "#00FF00"),
            string.format("BUFF状态: %s", tostring(buff.buffend) or "未知"),
            string.format("触发时间: %s", tostring(buff.time)  or "未知"),
            "\n"
        }, "\t")
    end

    return section.."\n"
end

function ChocoboRaceGMTargetInfoView:BuildGimmickSection()
    local section = "\n"..SetColorFormat("【动态物件】", COLOR_TITLE).."\n"

    if not self.GimmickLogs or #(self.GimmickLogs.data or {}) == 0 then
        return section.."无触发记录\n"
    end

    for _, gimmick in ipairs(self.GimmickLogs.data or {}) do
        section = section .. string.format(
                "%s 触发类型%s %s\n",
                SetColorFormat(string.format("编号%d(%d)",
                        gimmick.index + 1 or 0,
                        gimmick.roleid or 0), COLOR_RACER),
                SetColorFormat(self:GetGimmickType(gimmick.gimmicktype or 0) or "未知类型", COLOR_GIMMICK),
                SetColorFormat(gimmick.time or "未知时间", COLOR_TIME)
        )
    end

    return section
end

-- 辅助函数
function ChocoboRaceGMTargetInfoView:GetSkillName(SkillId)
    return self.SkillName[SkillId] or ("未知技能("..tostring(SkillId)..")")
end

function ChocoboRaceGMTargetInfoView:GetBuffName(BuffId)
    return self.BuffName[BuffId] or ("未知Buff("..tostring(BuffId)..")")
end

function ChocoboRaceGMTargetInfoView:GetStateName(StateId)
    return self.StateName[StateId] or ("未知State("..tostring(StateId)..")")
end

function ChocoboRaceGMTargetInfoView:GetGimmickType(TypeCode)
    return self.GimmickNames[TypeCode] or ("未知Gimmick("..tostring(TypeCode)..")")
end

return ChocoboRaceGMTargetInfoView