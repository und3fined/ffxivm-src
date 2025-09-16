--
--Author: loiafeng
--Date: 2024-08-09 14:47
--Description: 运营需求。全服通告（走马灯），以横幅形式在主界面显示
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local AnnouncementDefine = require("Game/Announcement/AnnouncementDefine")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local CS_CMD = ProtoCS.CS_CMD
local CS_LANTERN_CMD = ProtoCS.Game.Lantern.CS_LANTERN_CMD

local ChatMgr ---@type ChatMgr
local MsgTipsUtil ---@type MsgTipsUtil

local ShowLanternTimeLimit = 30000  -- ms

---@class AnnouncementMgr : MgrBase
local AnnouncementMgr = LuaClass(MgrBase)

function AnnouncementMgr:OnInit()
    self.Announcements = {}
    self.UpdateTimerID = nil
    self.LastUpdateTime = 0
end

function AnnouncementMgr:OnBegin()
    ChatMgr = _G.ChatMgr
    MsgTipsUtil = _G.MsgTipsUtil
end

function AnnouncementMgr:OnEnd()
end

function AnnouncementMgr:OnShutdown()
    self:ClearAnnouncements()
end

function AnnouncementMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LANTERN, CS_LANTERN_CMD.LANTERN_GETLIST, self.OnNetMsgGetAllAnnouncements)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LANTERN, CS_LANTERN_CMD.LANTERN_NTF_ADD, self.OnNetMsgAnnouncementAdd)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LANTERN, CS_LANTERN_CMD.LANTERN_NTF_DEL, self.OnNetMsgAnnouncementRemove)
end

function AnnouncementMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

---@class AnnouncementObject
---@field ID number
---@field Type number
---@field Content string
---@field StartTime number UTC+8 单位ms
---@field EndTime number UTC+8 单位ms
---@field TimeInterval number 单位ms
---@field PlatID number 平台类型

---@param Lamp table
---@return AnnouncementObject
local function NewAnnouncementObject(Lamp)
    return {
        ID = Lamp.LampID,
        Type = Lamp.UIType,
        Content = Lamp.Content,
        StartTime = Lamp.StartTime,
        EndTime = Lamp.EndTime,
        TimeInterval = Lamp.TimeInterval * 1000,
        PlatID = Lamp.PlatID,
    }
end

function AnnouncementMgr:OnNetMsgGetAllAnnouncements(MsgBody)
    local GetListRsp = (MsgBody or {}).GetListRsp
    local Lamps = (GetListRsp or {}).Lamps
    if nil == Lamps then
        return
    end

    self:ClearAnnouncements()

    for _, Lamp in ipairs(Lamps) do
        local NewObject = NewAnnouncementObject(Lamp)
        self:AddAnnouncement(NewObject)
    end
end

function AnnouncementMgr:OnNetMsgAnnouncementAdd(MsgBody)
    local NtfAddRsp = (MsgBody or {}).NtfAddRsp
    local Lamp = (NtfAddRsp or {}).Lamp
    if nil == Lamp then
        return
    end

    local NewObject = NewAnnouncementObject(Lamp)
    NewObject.StartTime = math.max(NewObject.StartTime, TimeUtil.GetServerTime() * 1000)
    self:AddAnnouncement(NewObject)
end

function AnnouncementMgr:OnNetMsgAnnouncementRemove(MsgBody)
    local NtfDelRsp = (MsgBody or {}).NtfDelRsp
    local LampID = (NtfDelRsp or {}).LampID
    if nil == LampID then
        return
    end

    self:RemoveAnnouncement(LampID)
end

function AnnouncementMgr:OnGameEventLoginRes(Params)
    self:RequestAllAnnouncements()
end

---GetTriggerCount 计算在给定的时间段内，哪些时间点触发了广播
---@param UpdateStart number UTC+8 单位ms。该区间边界 不会 触发广播
---@param UpdateEnd number UTC+8 单位ms。该区间边界 会 触发广播
---@return table 触发的时间戳列表
local function GetTriggerTimestamps(Announcement, UpdateStart, UpdateEnd)
    local StartTime = Announcement.StartTime
    local EndTime = Announcement.EndTime
    local Interval = Announcement.TimeInterval
    
    local Result = {}
    
    if UpdateEnd < StartTime or UpdateStart >= EndTime or UpdateStart == UpdateEnd then
        return Result
    end

    -- _G.UE.FProfileTag.StaticBegin("AnnouncementMgr.GetTriggerTimestamps")
    
    local LastTriggerTime = math.max(UpdateStart - (UpdateStart - StartTime) % Interval, StartTime)
    for Timestamp = LastTriggerTime, EndTime, Interval do
        if Timestamp > UpdateStart and Timestamp <= UpdateEnd then
            table.insert(Result, Timestamp)
        elseif Timestamp > UpdateEnd then
            break
        end
    end

	-- _G.UE.FProfileTag.StaticEnd()

    return Result
end

function AnnouncementMgr:OnTimerUpdateAnnouncements()
	-- _G.UE.FProfileTag.StaticBegin("AnnouncementMgr:OnTimerUpdateAnnouncements")

    local ServerTime = TimeUtil.GetServerTime() * 1000  -- ms

    local SystemMsgs = {}  ---@type table<Timestamp, table<AnnouncementObject>>
    local Lanterns = {}  ---@type table<Timestamp, table<AnnouncementObject>>
    local IDsToRemove = {}

    for _, Announcement in pairs(self.Announcements) do
        -- 如果更新间隔太久（比如锁屏后重开），广播触发了多次，都要显示在系统消息中
        local SystemMsgTimestamps = GetTriggerTimestamps(Announcement, self.LastUpdateTime, ServerTime)
        for _, Timestamp in ipairs(SystemMsgTimestamps) do
            if nil == SystemMsgs[Timestamp] then
                SystemMsgs[Timestamp] = {}
            end

            table.insert(SystemMsgs[Timestamp], Announcement)
        end

        local bShouldShowLantern = false
        if Announcement.Type == AnnouncementDefine.ShowType.All then
            bShouldShowLantern = true
        else
            local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
            bShouldShowLantern = Announcement.Type == AnnouncementDefine.ShowType.Dungeon and IsInDungeon or
                Announcement.Type == AnnouncementDefine.ShowType.OutsideDungeon and not IsInDungeon
        end

        if bShouldShowLantern then
            -- 走马灯只需要考虑在最近这段时间内触发的广播即可。若触发多次，也只显示一次
            local LanternTimestamps = GetTriggerTimestamps(Announcement, math.max(self.LastUpdateTime, ServerTime - ShowLanternTimeLimit), ServerTime)
            if #LanternTimestamps > 0 then
                local Timestamp = LanternTimestamps[#LanternTimestamps]
                if nil == Lanterns[Timestamp] then
                    Lanterns[Timestamp] = {}
                end

                table.insert(Lanterns[Timestamp], Announcement)
            end
        end

        -- 如果广播已经过期，则移除
        if ServerTime >= Announcement.EndTime then
            table.insert(IDsToRemove, Announcement.ID)
        end
    end

    -- 按时间顺序进行广播
    local function BroadcastInOrder(TriggeredAnnouncements, Callback)
        local SortedTimestamps = {}
        for Timestamp in pairs(TriggeredAnnouncements) do
            table.insert(SortedTimestamps, Timestamp)
        end
        table.sort(SortedTimestamps)

        for _, Timestamp in ipairs(SortedTimestamps) do
            -- 同时触发的按照ID排序
            local Announcements = TriggeredAnnouncements[Timestamp]
            table.sort(Announcements, function(lhs, rhs) return lhs.ID < rhs.ID end)

            for _, Announcement in ipairs(Announcements) do
                Callback(Announcement)
            end
        end
    end

    -- _G.UE.FProfileTag.StaticBegin("AnnouncementMgr.BroadcastChatMsgs")

    BroadcastInOrder(SystemMsgs, function(Announcement)
        ChatMgr:AddSysChatMsg(Announcement.Content)
    end)

	-- _G.UE.FProfileTag.StaticEnd()

    BroadcastInOrder(Lanterns, function(Announcement)
        MsgTipsUtil.ShowRunningTips(Announcement.Content)
    end)

    for _, ID in pairs(IDsToRemove) do
        self:RemoveAnnouncement(ID)
    end

    self.LastUpdateTime = ServerTime

	-- _G.UE.FProfileTag.StaticEnd()
end

---@private
function AnnouncementMgr:RequestAllAnnouncements()
    local MsgID = CS_CMD.CS_CMD_LANTERN
	local SubMsgID = CS_LANTERN_CMD.LANTERN_GETLIST
	local MsgBody = {
		Cmd = SubMsgID,
        GetListReq = {TempID = 0, WorldID = _G.LoginMgr:GetWorldID()}
	}

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@private
function AnnouncementMgr:ClearAnnouncements()
    self.Announcements = {}

    if self.UpdateTimerID ~= nil then
        self:UnRegisterTimer(self.UpdateTimerID)
        self.UpdateTimerID = nil
    end
end

local function CheckPlatform(PlatID)
    return PlatID == AnnouncementDefine.PlatformType.All or
           PlatID == AnnouncementDefine.PlatformType.IOS and CommonUtil.IsIOSPlatform() or
           PlatID == AnnouncementDefine.PlatformType.Android and CommonUtil.IsAndroidPlatform()
end

---@param NewObject AnnouncementObject
---@private
function AnnouncementMgr:AddAnnouncement(NewObject)
    -- 根据平台过滤通告
    if not CheckPlatform(NewObject.PlatID) then
        FLOG_INFO("AnnouncementMgr.AddAnnouncement(): filter announcement by platform. PlatID: " .. tostring(NewObject.PlatID))
        -- loiafeng: 暂不启用改功能，故注释掉
        -- return
    end

    self.Announcements[NewObject.ID] = NewObject

    if not self.UpdateTimerID then
        self.LastUpdateTime = TimeUtil.GetServerTime() * 1000 - 1
        self.UpdateTimerID = self:RegisterTimer(self.OnTimerUpdateAnnouncements, 0, 4, 0)
    end
end

---@param ID number
---@private
function AnnouncementMgr:RemoveAnnouncement(ID)
    self.Announcements[ID] = nil

    if table.empty(self.Announcements) and self.UpdateTimerID ~= nil then
        self:UnRegisterTimer(self.UpdateTimerID)
        self.UpdateTimerID = nil
    end
end

-----------------------------------------------------------------------------
--- Debug

function AnnouncementMgr:DebugAddAnnouncement(ID, Type, Content, StartTime, EndTime, Interval, PlatID)
    self:AddAnnouncement({
        ID = ID,
        Type = Type,
        Content = Content,
        StartTime = StartTime,
        EndTime = EndTime,
        TimeInterval = Interval,
        PlatID = PlatID,
    })
end

-----------------------------------------------------------------------------

return AnnouncementMgr
