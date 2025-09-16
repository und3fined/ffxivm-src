--- Author: Administrator
--- DateTime: 2024-12-24 15:54
--- Description:

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local SavageRankCfg = require("TableCfg/SavageRankCfg")
local SavageRankGlobalCfg = require("TableCfg/SavageRankGlobalCfg")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local SaveKey = require("Define/SaveKey")
local DataReportUtil = require("Utils/DataReportUtil")
local CommonUtil = require("Utils/CommonUtil")
local ReportButtonType = require("Define/ReportButtonType")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")



local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Game.ZeroSceneRank.CS_ZEROSCENERANK_CMD
local LSTR = _G.LSTR

local RankIcon = {
    "PaperSprite'/Game/UI/Atlas/SavageRank/Frames/UI_Icon_SavageRank_Badge01_png.UI_Icon_SavageRank_Badge01_png'",
    "PaperSprite'/Game/UI/Atlas/SavageRank/Frames/UI_Icon_SavageRank_Badge02_png.UI_Icon_SavageRank_Badge02_png'",
    "PaperSprite'/Game/UI/Atlas/SavageRank/Frames/UI_Icon_SavageRank_Badge03_png.UI_Icon_SavageRank_Badge03_png'"
}

local BgImgList = {
    "Texture2D'/Game/UI/Texture/SavageRank/UI_Img_SavageRank_RankList_01.UI_Img_SavageRank_RankList_01'",
    "Texture2D'/Game/UI/Texture/SavageRank/UI_Img_SavageRank_RankList_02.UI_Img_SavageRank_RankList_02'",
    "Texture2D'/Game/UI/Texture/SavageRank/UI_Img_SavageRank_RankList_03.UI_Img_SavageRank_RankList_03'",
    "Texture2D'/Game/UI/Texture/SavageRank/UI_Img_SavageRank_RankList_04.UI_Img_SavageRank_RankList_04'",
}

--职业类型排序规则
local OrderProfessData = {[ProtoCommon.class_type.CLASS_TYPE_TANK] = 1, [ProtoCommon.class_type.CLASS_TYPE_HEALTH] = 2, [ProtoCommon.class_type.CLASS_TYPE_NEAR] = 3, [ProtoCommon.class_type.CLASS_TYPE_FAR] = 4, [ProtoCommon.class_type.CLASS_TYPE_MAGIC] = 5}

---@class SavageRankMgr : MgrBase
local SavageRankMgr = LuaClass(MgrBase)

---OnInit
function SavageRankMgr:OnInit()
	self.TeamInfoList = {}
	self.RankInfoName = {
		--LSTR(1450008), -- 全部排名
		LSTR(1450009), -- 1-100名
		LSTR(1450010), -- 101-200名
		LSTR(1450011), -- 201-300名
		LSTR(1450012), -- 301-400名
		LSTR(1450013), -- 401-500名
	}
	self.Wait = {}
	self.RankTeamInfo = {} --排行榜队伍信息
	self.CurChosedSceneID = nil 
	self.CurRankTeamRoleID = {}
	self.RankSlefIndexList = {} --记录自己榜单选择下标信息
	self.TimerList = {}
end

---OnBegin
function SavageRankMgr:OnBegin()
	self:InitSavageRankCfg()
end

function SavageRankMgr:InitSavageRankCfg()
	self.SavageRankCfg = {}
	local SavageRankGlobalCfg = SavageRankGlobalCfg:FindAllCfg()
	local SavageRankCfg = SavageRankCfg:FindAllCfg()
	for _, v in pairs(SavageRankCfg) do
		local Data = {}
		Data.ID = v.ID
		Data.SceneID = v.SceneID
		Data.Name = v.SceneName
		Data.OpenVersion = v.OpenVersion
		Data.OpenTime = v.OpenTime
		Data.RemoveVersion = v.RemoveVersion
		Data.RemoveTime = v.RemoveTime
		Data.Order = v.Order
		local IsOpen, IsEnd = self:CurRankIsOpen(v.OpenTime, v.RemoveTime)
		Data.IsOpen = IsOpen
		Data.IsEnd = IsEnd
		Data.Icon = v.Icon or ""
		Data.BackgroudImageIcon = SceneEnterCfg:FindCfgByKey(v.SceneID).BackgroudImageIcon or ""
		Data.BG = SceneEnterCfg:FindCfgByKey(v.SceneID).BG or ""
		self.SavageRankCfg[v.ID] = Data
	end
	table.sort(self.SavageRankCfg, self.SortRankCfg)

	self.OpenDay = SavageRankGlobalCfg[3].Value[1]  --上架天数
	self.OffDay = SavageRankGlobalCfg[4].Value[1]  --下架天数
	self.SustainTime = SavageRankGlobalCfg[6].Value[1]  --气泡持续时间
end

function SavageRankMgr.SortRankCfg(L, R)
	local LOrder = L.Order
	local ROrder = R.Order
	if LOrder < ROrder then
        return true
    else
        return false
    end
end

function SavageRankMgr:OnEnd()

end

function SavageRankMgr:OnShutdown()

end

function SavageRankMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ZeroSceneRank, SUB_MSG_ID.ALLRANKS, self.OnNetMsgZeroRankAll)
end

function SavageRankMgr:OnRegisterGameEvent()

end

---OnGameEventLoginRes
---@param Params any
function SavageRankMgr:OnGameEventLoginRes(Params)
    if not Params.bReconnect then
		self.RankTeamInfo = {}
		self.CurRankTeamRoleID = {}
		self.RankSlefIndexList = {}
    end
end

function SavageRankMgr:SendZeroSceneRankAllReq(SceneResID)
	local Index = 1
	local function SendMsg()
		self.WaitIndex = Index
		if self.Wait[SceneResID] == true then
			return
		end
		if Index > 5 then
			self:UnRegisterTimer(self.TimerList[SceneResID])
			self.TimerList[SceneResID] = nil
			self.Wait[SceneResID] = false
			if self.CurChosedSceneID == SceneResID then
				EventMgr:SendEvent(EventID.SavageRankUpdateDrop, false)
			end
			return
		end
		local MsgID = CS_CMD.CS_CMD_ZeroSceneRank
		local SubMsgID = SUB_MSG_ID.ALLRANKS
	
		local MsgBody = {}
		MsgBody.Cmd = SubMsgID 
		MsgBody.ZeroSceneRankAllReq = {}
		MsgBody.ZeroSceneRankAllReq.SceneResID = SceneResID
		MsgBody.ZeroSceneRankAllReq.offset = 99 * (Index - 1)
		self.SendIndex = Index
		self.Wait[SceneResID] = true
		Index = Index + 1
		GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	end
	if not self.TimerList[SceneResID]  then
		self.TimerList[SceneResID] = self:RegisterTimer(SendMsg, 0, 0.1, 0)
	end


	-- local Index = 1
	-- local MsgID = CS_CMD.CS_CMD_ZeroSceneRank
	-- local SubMsgID = SUB_MSG_ID.ALLRANKS

	-- local MsgBody = {}
	-- MsgBody.Cmd = SubMsgID 
	-- MsgBody.ZeroSceneRankAllReq = {}
	-- MsgBody.ZeroSceneRankAllReq.SceneResID = SceneResID
	-- MsgBody.ZeroSceneRankAllReq.offset = 99 * (Index - 1)
	-- Index = Index + 1
	-- GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

end

function SavageRankMgr:OnNetMsgZeroRankAll(MsgBody)
	local _ <close> = _G.CommonUtil.MakeProfileTag("SavageRankMgr:OnNetMsgZeroRankAll")

	local SceneID = MsgBody.ZeroSceneRankAllRsp.SceneResID
	local Offset = MsgBody.ZeroSceneRankAllRsp.offset
	local TeamResults = MsgBody.ZeroSceneRankAllRsp.TeamResults
	self.RankTeamInfo[SceneID] = self.RankTeamInfo[SceneID] or {}
	table.insert(self.RankTeamInfo[SceneID], TeamResults)
	self.Wait[SceneID] = false
	self:SetRoleIDRankInfo(SceneID, true)
	if Offset == 0 then
		if self.CurChosedSceneID == SceneID then
			EventMgr:SendEvent(EventID.SavageRankUpdateDrop, true)
		end
	end
end

function SavageRankMgr:GetRoleIDRankInfo(RoleID)
	if self.CurRankTeamRoleID[RoleID] then
		return self.CurRankTeamRoleID[RoleID]
	end

	return {}
end

function SavageRankMgr:SetRoleIDRankInfo(SceneID, IsUpdateChosed)
	local _ <close> = _G.CommonUtil.MakeProfileTag("SavageRankMgr:SetRoleIDRankInfo")

	local RoleID = MajorUtil.GetMajorRoleID()
	if self.RankTeamInfo and self.RankTeamInfo[SceneID] and self.RankTeamInfo[SceneID][self.SendIndex] then
		for i, Team in ipairs(self.RankTeamInfo[SceneID][self.SendIndex]) do
			for _, TeamInfo in ipairs(Team.TeamMembers) do
				if RoleID == TeamInfo.RoleID then
					if self.CurRankTeamRoleID[TeamInfo.RoleID] then
						local Data = {}
						Data.SceneID = SceneID
						Data.SendIndex = self.SendIndex --分段Index
						Data.RankIndex = i --排行Index
						Data.TeamInfo = Team
						table.insert(self.CurRankTeamRoleID[TeamInfo.RoleID], Data)
					else
						self.CurRankTeamRoleID[TeamInfo.RoleID] = {}
						local Data = {}
						Data.SceneID = SceneID
						Data.SendIndex = self.SendIndex --分段Index
						Data.RankIndex = i  --排行Index
						Data.TeamInfo = Team
						table.insert(self.CurRankTeamRoleID[TeamInfo.RoleID], Data)
					end	
				end		
			end
		end
	end
	

	if IsUpdateChosed then
		EventMgr:SendEvent(EventID.SavageRankUpdateData)
	end
end

function SavageRankMgr:ADDtestData()
	for i = 1, 320 do
		local RoleID = 100 + i
		local Time = 550 + i 
		local Cmdslist = string.format("%s %s %s", "entertain zeroscenerank reportranks 1205011", RoleID, Time)
		_G.GMMgr:ReqGM0(Cmdslist)
	end
end

function SavageRankMgr:OpenSavageRankMainPanel(ScenceID)
	local Data = {}
	Data.ScenceID = ScenceID
	UIViewMgr:ShowView(UIViewID.SavageRankMainView, Data)
	self:ReportOpenSavageRank()
end


function SavageRankMgr:GetRankTeamInfo()
	return self.TeamInfoList
end

function SavageRankMgr:GetDropDwonList()
	local DropDownData = {}
	local Ranklist = self.RankTeamInfo[self.CurChosedSceneID] or {}
	local MaxRank = 0
	for _, List in pairs(Ranklist) do
		if #List > 0 then
			MaxRank = MaxRank + 100
		end
	end
	local RangeCount = math.ceil(MaxRank / 100)

	for i = 1, RangeCount do
		local Name = self.RankInfoName[i]
		local Data = {}
		Data.Name = Name
		table.insert(DropDownData, Data)
	end

	return DropDownData
end

function SavageRankMgr:CurRankIsOpen(OpenTime, RemoveTime)
	local ServerTime = TimeUtil.GetServerLogicTime()
	local CurrentTime = os.date("%Y-%m-%d_%H:%M:%S", ServerTime)
	local IsOpen = false
	local IsEnd = false
	if OpenTime == "" or RemoveTime == "" then
		return false
	end
	

	if CurrentTime > OpenTime and CurrentTime <= RemoveTime then
		IsOpen = true
    	return IsOpen, IsEnd
	elseif CurrentTime < OpenTime then
		IsOpen = false
    	return IsOpen, IsEnd
	elseif CurrentTime > RemoveTime then
		IsOpen = false
		IsEnd = true
		return IsOpen, IsEnd
	end
end

function SavageRankMgr:GetSavageRankCfg()
	--更新一下时间状态 方便修改时间GM测试
	for _, v in pairs(self.SavageRankCfg) do
		local IsOpen, IsEnd = self:CurRankIsOpen(v.OpenTime, v.RemoveTime)
		v.IsOpen = IsOpen
		v.IsEnd = IsEnd
	end
	
	return self.SavageRankCfg
end

function SavageRankMgr:GetSceneRankAllInfo(SceneID)
	if self.RankTeamInfo[SceneID] then
		EventMgr:SendEvent(EventID.SavageRankUpdateDrop, true)
		EventMgr:SendEvent(EventID.SavageRankUpdateData)
		--return self.RankTeamInfo[SceneID]
	else
		self:SendZeroSceneRankAllReq(SceneID)
	end
end

function SavageRankMgr:GetCurRankTeamInfo(Index)
	if self.RankTeamInfo[self.CurChosedSceneID] then
		if self.RankTeamInfo[self.CurChosedSceneID][Index] then
			return self.RankTeamInfo[self.CurChosedSceneID][Index]
		end
	end
end

function SavageRankMgr:GetRankIcon(Rank)
	return RankIcon[Rank]
end

function SavageRankMgr:GetBgImg(Rank)
	return BgImgList[Rank]
end

function SavageRankMgr:GetSavageRankOverTime()
	local Day = self.OffDay
	local ServerTime = TimeUtil.GetServerLogicTime()
	local Data = {}

	for _, value in pairs(self.SavageRankCfg) do
		local ReaminList = {}
		local OverTime = value.RemoveTime
		local OverTimeStamp = os.time({
			year = tonumber(string.sub(OverTime, 1, 4)),
			month = tonumber(string.sub(OverTime, 6, 7)),
			day = tonumber(string.sub(OverTime, 9, 10)),
			hour = tonumber(string.sub(OverTime, 12, 13)),
			min = tonumber(string.sub(OverTime, 15, 16)),
			sec = tonumber(string.sub(OverTime, 18, 19))
		})
		local RemainSeconds = os.difftime(OverTimeStamp, ServerTime)
		if RemainSeconds <= Day * 86400 and RemainSeconds > 0 then
			ReaminList.Name = value.Name
			ReaminList.RemainSeconds = RemainSeconds
			table.insert(Data, ReaminList)
		end
	end

	return Data
end

function SavageRankMgr:SetTipsShowTime()
	local CurServerTime = tostring(TimeUtil.GetServerLogicTime())
	_G.UE.USaveMgr.SetString(SaveKey.SavageRankTips, CurServerTime, true)
end

function SavageRankMgr:IsShowTips()
	local SaveTime = tonumber(_G.UE.USaveMgr.GetString(SaveKey.SavageRankTips, "", true))
	if not SaveTime then
		return true
	end

	local CurServerTime = TimeUtil.GetServerLogicTime()
	local CurDay = self:GetDatePart(CurServerTime)
	local SaveDay = self:GetDatePart(SaveTime)

	if CurDay ~= SaveDay then
		return true
	else
		return false
	end
end

function SavageRankMgr:GetDatePart(Time)
	local Part = os.date("*t", Time)
	return Part.day
end

--获取通关时间 "分:秒.毫秒"（毫秒固定2位）
function SavageRankMgr:GetElapsedTime(Time)
	if not Time then
		return ""
	end
	local TimeText = ""
	local TimeStamp = Time

    local Minutes = math.floor(TimeStamp / 60000)
    TimeStamp = TimeStamp % 60000
    local Seconds = math.floor(TimeStamp / 1000)
    local Milliseconds = TimeStamp % 1000
    
    -- 毫秒只保留2位（十毫秒精度）
    Milliseconds = math.floor(Milliseconds / 10)
    
    -- 格式化为 "分:秒.毫秒"（毫秒固定2位）
    TimeText = string.format("%d:%02d.%02d", Minutes, Seconds, Milliseconds)

	return TimeText
end

function SavageRankMgr:ReportOpenSavageRank()
	local GameSerID = _G.LoginMgr:GetWorldID() or 0
	local ServerTime = TimeUtil.GetServerLogicTime()
	local EventTime = os.date("%Y-%m-%d %H:%M:%S", ServerTime)
	local GameAppid = _G.UE.UTDMMgr.Get():GetGameAppId()
	local Platform = CommonUtil.GetPlatformName()
	local PlatID
	local ZoneID = _G.LoginMgr:GetWorldID() or 0
	local OpenID = _G.LoginMgr:GetOpenID()
	local RoleID = MajorUtil.GetMajorRoleID()
	local WorldID = _G.LoginMgr:GetWorldID() or 0
	if Platform == "Android" then
		PlatID = 1
	elseif Platform == "IOS" then
		PlatID = 0
	end
	DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.OpenSavageRank), "0", GameSerID, 
	EventTime, GameAppid, PlatID, ZoneID, OpenID, RoleID, 
	WorldID)
end

function SavageRankMgr:GetSortProfList(TeamInfo)
	local _ <close> = _G.CommonUtil.MakeProfileTag("SavageRankMgr:GetSortProfList")

	local Data = {}
	for Index, value in ipairs(TeamInfo) do
		local ProfClass = RoleInitCfg:FindProfClass(value.Prof) or 0
		TeamInfo[Index].ProfClassSort = OrderProfessData[ProfClass] or 99
		Data[Index] = TeamInfo[Index]
	end

	table.sort(Data, self.SortProf)
	return Data
end

function SavageRankMgr.SortProf(L, R)
	local LProfClass = L.ProfClassSort
    local RProfClass = R.ProfClassSort
	if LProfClass ~= RProfClass then
		return LProfClass < RProfClass
	else
		return L.RoleID < R.RoleID
	end
end

function SavageRankMgr:CheckScenceID(SceneID)
	for _, Value in ipairs(self.SavageRankCfg) do
		if SceneID == Value.SceneID then
			return true
		end
	end

	return false
end

function SavageRankMgr:ClearWaitInfo()
	for SceneID, TimeID in pairs(self.TimerList) do
		if TimeID then
			self:UnRegisterTimer(TimeID)
			self.TimerList[SceneID] = nil
		end
	end
	
	self.RankTeamInfo = {}
	self.CurRankTeamRoleID = {}
	self.RankSlefIndexList = {}
	self.Wait = {}
end


--要返回当前类
return SavageRankMgr
