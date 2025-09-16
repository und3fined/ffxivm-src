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
    end
    
    self.SkillName = {}
    local AllSkillCfg = ChocoboRaceSkillDisplayCfg:FindAllCfg()
    for _, Value in pairs(AllSkillCfg) do
        self.SkillName[Value.ID] = Value.Name
    end

    self.BuffName = {
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
        [100] = "加速状态",
        [101] = "疲惫状态",
        [100] = "免疫效果100%",
        [100] = "无敌状态",
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
    self.SelectedIndex = self.SelectedIndex + 1
    if self.SelectedIndex >= 8 then
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
    self.Content:SetText("已清空")
end

function ChocoboRaceGMTargetInfoView:OnRegisterTimer()
    self:RegisterTimer(self.OnTimer, 0, 0.2, 0)
end

function ChocoboRaceGMTargetInfoView:OnTimer()
    self:SendReq(self.SelectedIndex)
end

function ChocoboRaceGMTargetInfoView:SendReq(Index)
    if self.IsPaused then return end
    
    local Params = {}
    Params.Cmd = SUB_MSG_ID.ChocoboRaceDebugInfo
    Params.debugdata = {}
    Params.debugdata.Index = Index
    Params.RaceID = _G.PWorldMgr:GetCurrPWorldInstID()
    _G.GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceDebugInfo, Params)
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
    local ContentText = SetColorFormat("【当前监听对象编号：" .. self.SelectedIndex + 1 ..  "】", COLOR_GIMMICK).."\n\n"
    ContentText = ContentText .. self:BuildRacerSection(jsonData.racers)
    ContentText = ContentText .. self:BuildBuffState(jsonData.buffDebug)
    ContentText = ContentText .. self:BuildSkillSection()
    ContentText = ContentText .. self:BuildBuffSection()
    ContentText = ContentText .. self:BuildGimmickSection()

    self.Content:SetText(ContentText)
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
    self.BuffActiveRecords = self.BuffActiveRecords or {}  -- 当前激活BUFF
    self.BuffHistoryCache = self.BuffHistoryCache or {     -- 历史观察记录
        maxHistory = 10,          -- 最大保留历史记录数
        keepDuration = 5000,      -- 历史记录保留时间（毫秒）
        data = {}
    }

    local section = SetColorFormat("【编号" .. self.SelectedIndex + 1 .. "BUFF状态】", COLOR_TITLE).."\n"
    local racer = _G.ChocoboRaceMgr:GetRacerByIndex(self.SelectedIndex + 1)
    if not racer then return section end

    local buffFlags = racer:GetBuffFlags()
    local currentTime = TimeUtil.GetServerLogicTimeMS()

    self:UpdateBuffRecords(buffFlags, currentTime)
    self:CleanHistoryRecords(currentTime)

    -- 构建显示内容（当前激活 + 近期历史）
    section = section .. self:BuildActiveBuffSection(currentTime)
    section = section .. self:BuildHistoryBuffSection(currentTime)

    return section
end

function ChocoboRaceGMTargetInfoView:UpdateBuffRecords(buffFlags, currentTime)
    for buffid, flag in pairs(buffFlags) do
        if flag then
            if not self.BuffActiveRecords[buffid] then
                self.BuffActiveRecords[buffid] = {
                    startTime = currentTime,
                    lastUpdate = currentTime,
                    duration = 0
                }
            end
            self.BuffActiveRecords[buffid].duration = currentTime - self.BuffActiveRecords[buffid].startTime
            self.BuffActiveRecords[buffid].lastUpdate = currentTime
        else
            if self.BuffActiveRecords[buffid] then
                table.insert(self.BuffHistoryCache.data, 1, {
                    buffid = buffid,
                    startTime = self.BuffActiveRecords[buffid].startTime,
                    endTime = currentTime,
                    duration = currentTime - self.BuffActiveRecords[buffid].startTime
                })
                self.BuffActiveRecords[buffid] = nil
            end
        end
    end
end

function ChocoboRaceGMTargetInfoView:CleanHistoryRecords(currentTime)
    while #self.BuffHistoryCache.data > self.BuffHistoryCache.maxHistory do
        table.remove(self.BuffHistoryCache.data)
    end

    for i = #self.BuffHistoryCache.data, 1, -1 do
        local record = self.BuffHistoryCache.data[i]
        if currentTime - record.endTime > self.BuffHistoryCache.keepDuration then
            table.remove(self.BuffHistoryCache.data, i)
        end
    end
end

function ChocoboRaceGMTargetInfoView:BuildActiveBuffSection(currentTime)
    local COLOR_ACTIVE = "#00FF00"
    local section = "\n"..SetColorFormat("=== 当前生效 ===", "#FFD700").."\n"
    section = section .. SetColorFormat(string.format("%-6s%-20s%-12s", "ID", "名称", "持续时间"), "#AAAAAA").."\n"

    for buffid, record in pairs(self.BuffActiveRecords) do
        local durationText = self:FormatDuration(record.duration)
        section = section..string.format("%s %s\n",
                SetColorFormat(string.format("[%-4d] %-20s", buffid, self:GetBuffName(buffid)), COLOR_BUFF),
                SetColorFormat(durationText, COLOR_ACTIVE)
        )
    end

    return section
end

function ChocoboRaceGMTargetInfoView:BuildHistoryBuffSection(currentTime)
    local COLOR_HISTORY = "#FF69B4"
    local section = "\n"..SetColorFormat("=== 近期结束 ===", "#FFD700").."\n"
    section = section .. SetColorFormat(string.format("%-6s%-20s%-12s", "ID", "名称", "总持续时间"), "#AAAAAA").."\n"

    for _, record in ipairs(self.BuffHistoryCache.data) do
        local durationText = self:FormatDuration(record.duration)
        section = section..string.format("%s %s\n",
                SetColorFormat(string.format("[%-4d] %-20s", record.buffid, self:GetBuffName(record.buffid)), COLOR_BUFF),
                SetColorFormat(durationText, COLOR_HISTORY)
        )
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
            "\n--------------------------------\n\n"
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
    local section = "\n"..SetColorFormat("【BUFF详细监控】", COLOR_TITLE).."\n"

    if not self.BuffRecords or #(self.BuffRecords.data or {}) == 0 then
        return section.."无BUFF\n"
    end

    for i = 1, #self.BuffRecords.data do
        local buff = self.BuffRecords.data[i] or {}

        section = section.."\n"..SetColorFormat(string.format("[%d] %s",
                buff.buffid or 0,
                self:GetBuffName(buff.buffid) or "未知BUFF"), COLOR_BUFF).."\n"

        section = section..table.concat({
            string.format("触发者: 编号%d(RoleID:%d)", buff.fromindex  + 1 or 0, buff.fromroleid or 0),
            string.format("目标: 编号%d(RoleID:%d)", buff.toindex + 1 or 0, buff.toroleid or 0),
            SetColorFormat(buff.time or "未知时间", COLOR_TIME),
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

function ChocoboRaceGMTargetInfoView:GetGimmickType(TypeCode)
    return self.GimmickNames[TypeCode] or ("未知Gimmick("..tostring(TypeCode)..")")
end

return ChocoboRaceGMTargetInfoView