--
--Author: ds_yangyumian
--Date: 2023-12-8 14:47
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local MusicPlayerCfg = require("TableCfg/MusicPlayerCfg")
local MusicTypeCfg = require("TableCfg/MusicTypeCfg")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local EventMgr = require("Event/EventMgr")
local CollectionAwardUtil = require("Game/Guide/CollectionAwardUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local DataReportUtil = require("Utils/DataReportUtil")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local AnimationUtil = require("Utils/AnimationUtil")
local AudioUtil = require("Utils/AudioUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local CommStatRecallID = ProtoCommon.CommStatID.CommStatRecall
local CommBehaviorRecallID = ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_MUSIC_RECALL
local MusicAtlasRevertPanelVM
local ClientReportType = ProtoCS.ReportType
local MusicPlayerMainPanelVM
local MusicAtlasMainVM
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.MusicOptCmd
local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr

local HotleID = 
{
	Map1 = 13009,	-- 利姆萨罗敏萨旅馆
	Map2 = 2006,	-- 乌尔达哈旅馆
	Map3 = 11009,   -- 格里达尼亚旅馆
}

local OtherState = {
	Combat = 1,          --战斗
	Dead = 2,            --死亡
	Fly = 3,             --飞行
	ChocoboTranspor = 4, --陆行鸟运输
	Revive = 5,          --复活
}

---@class MusicPlayerMgr : MgrBase
local MusicPlayerMgr = LuaClass(MgrBase)


function MusicPlayerMgr:OnInit()
	MusicPlayerMainPanelVM = require("Game/MusicPlayer/View/MusicPlayerMainPanelVM")
	MusicAtlasMainVM = require("Game/MusicAtlas/View/MusicAtlasMainVM")
	MusicAtlasRevertPanelVM = require("Game/MusicAtlas/View/MusicAtlasRevertPanelVM")
	self.CurPlayIndex = 0  --当前播放下标
	self.CurPlayMode = 1 --当前播放模式 1 顺序播放 2 单曲播放 3 随机播放
	self.AlreadyPlayTime = 0 --当前已播放时长
	self.CurPlayTime = nil --当前播放曲目时长
	self.AllMusicInfo = {} --全部已解锁的乐谱信息
	self.CurPlayListIDInfo = {} --当前查询的列表信息
	self.CurPlayListIndex = nil --当前处于的播放列表下标
	self.EditState = false --编辑状态
	self.RighListChoseIndex = nil --右侧界面选择的乐曲下标
	self.RighListChoseMusicID = nil --右侧界面选择的乐曲信息ID
	self.RightListChoseType = nil
	self.EditMusicInfo = {}
	self.AllPlayListInfo = {} --全部播放列表信息
	self.NewName = "" --列表新名字
	self.OldPlayListInfo = {} --旧列表信息
	self.IsCanSave = false --是否可以保存 列表发生变化后即可保存
	self.ListNameIsChanged = false --列表名字是否改变
	self.CurPlayerPlayingMusicID = nil --当前播放器正在播放的音乐ID
	self.MusicTotalTime = 0 --曲目总时长
	self.GatherList = {} --收录信息
	self.IsChoseRight = false  --是否选择了右侧编辑栏内的Item
	self.IsChoseLeft = false  --是否选择了左侧编辑栏内的Item
	self.LeftChosedID = nil  --左侧选择的ID
	self.PlayerPlayState = false -- 播放器播放状态
	self.CurPlayingListIndex = 1 --当前播放的歌曲处于的播放列表下标
	self.CurPlayingList = {} --当前播放的歌曲处于的播放列表
	self.PlaySoundID = nil --播放的声音ID
	self.MusicPlayerIsShow = false --播放器是否打开状态
	self.IsInHotel = false --是否在旅馆中
	self.IsStopTips = false
	--图鉴
	self.AllAtlasInfoList = {} --全部图鉴信息（包含已解锁和未解锁）
	self.CurChoseTypeIndex = 1 --当前选中的图鉴类型下标
	self.CurChoseAtlasID = nil
	self.PlayState = false --播放状态
	self.MusicAtalsTotalTime = nil --曲目总时长
	self.CurPlayingMusicID = nil --当前正在播放的音乐ID
	self.CurAtlasPlayingIndex = 1 --当前播放的歌曲处于的播放列表下标
	self.IsShowCurSlide = false
	self.IsDropSlide = false
	self.GatherInfo = {}
	self.CurAtalsPlayTime = nil --当前播放曲目时长
	self.CurTypeIndex = 1 --当前图鉴TAB选择下标
	self.AtlasPlaySoundID = nil
	self.AtlasPlayState = false
	self.AtlasItemList = {} --记录使用过的乐谱道具
	self.OpenType = 1 -- 1是打开乐谱图鉴 2 是打开乐谱播放器
	self.AtlasOpenType = 1 --1从图鉴入口打开 2 和交互物交互打开
	self.AtlasBgmState = false --通过图鉴设置的BGM播放状态
	self.AtlatsTimeID = nil
	self.AtlatsTimeID2 = nil
	self.RedDotList = {}
	self.RedDotName = "Root/MusicAtlas"
	self.AtlasTabTypeDotName = "Root/TabType"
	self.CheckRed = true
	self.AtlasEntrancerRedID = 6003
	self.PlayerIsSearch = false
	self.CurMusicIndex = nil   --图鉴当前选中的乐谱下标
	self.AllTypeMusic = {}
	self.AtlasTabList = nil

	--回想
	self.ReCallState = false --当前回想状态
	self.ReCallPlayState = false --回想播放状态
	self.CurPlayingRevertID = nil --当前回想播放的ID
	self.CurRevertPlayTime = nil --当前播放回想曲目时长
	self.RevertTotalTime = nil --回想曲目总时长
	self.CurPlayPercent = 0 --当前播放进度
	self.CurRevertPlayingMusicIndex = nil
	self.CurRevertPlayingTypeIndex = nil
	self.IsDragSlide = false
	self.RevertPlaySoundID = nil
	self.IsbReconnect = false
end

function MusicPlayerMgr:OnBegin()
	local AllAtlasCfg = MusicPlayerCfg:FindAllCfg()
	self.AllAtlasList = {}
	for _, v in ipairs(AllAtlasCfg) do
		self.AllAtlasList[v.MusicID] = v
	end
	self.AllTypeInfo = MusicTypeCfg:FindAllCfg()
	local function IsUnlockAtlas(ItemResID)
		return self:CheckAtlasOpenState(ItemResID)
	end
	_G.BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_ORCHESTRIONROLL, IsUnlockAtlas)
end

function MusicPlayerMgr:OnEnd()
	MusicPlayerMainPanelVM:StopPlayMusic()
	self:StopCurPlayerMusic()
end 

function MusicPlayerMgr:OnShutdown()

end

function MusicPlayerMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MUSIC, SUB_MSG_ID.MusicOptCmd_Query, self.OnNetMsgGetQueryList)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MUSIC, SUB_MSG_ID.MusicOptCmd_GET, self.OnNetMsgGetMusicList)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MUSIC, SUB_MSG_ID.MusicOptCmd_GetUnLockList, self.OnNetMsgGetUnLockList)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MUSIC, SUB_MSG_ID.MusicOptCmd_SavePlayList, self.OnNetMsgSaveList)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MUSIC, SUB_MSG_ID.MusicOptCmd_GetReward, self.OnNetMsgGetRecordReward)
	--self:RegisterGameNetMsg(CS_CMD.CS_CMD_MUSIC, SUB_MSG_ID.MusicOptCmd_GetRecordList, self.OnNetMsgGetRecordList)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MUSIC, SUB_MSG_ID.MusicOptCmd_UnlockNotify, self.OnNetMsgUpdateRedDot)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MUSIC, SUB_MSG_ID.MusicOptCmd_RedUpdate, self.OnNetMsgUpdateRedDotUpdate)
end

function MusicPlayerMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldEnter)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.MusicPlayerLoginRes)
	--self:RegisterGameEvent(EventID.CombatStateChanged, self.OnGameEventCombatStateChanged)
	self:RegisterGameEvent(EventID.AttackEffectChange, self.OnGameEventAttackEffectChange)
	self:RegisterGameEvent(EventID.BeginPlaySequence, self.OnGameBeginPlaySequence)
	self:RegisterGameEvent(EventID.EndPlaySequence, self.OnGameEndPlaySequence)
end

function MusicPlayerMgr:RestMusicPlayerInfo()
	self.EditState = false
	self.IsCanSave = false
	self.IsChoseRight = false
	self.IsChoseLeft = false
	self.LeftChosedID = nil
	self.RighListChoseIndex = nil
	self.RighListChoseMusicID = nil
	self.RightListChoseType = nil
	self.ListNameIsChanged = false
end

function MusicPlayerMgr:MusicPlayerLoginRes(Params)
	if Params.bReconnect then
		--延迟处理防止和BGM冲突
		if self.MusicPlayerIsShow and self.CurPlayerPlayingMusicID and self.PlayerPlayState then
			local function DelayPlay()
				self:StopOtherBgm()
				self:OpenMusicPlayer()
			end
			self:RegisterTimer(DelayPlay, 0.5, 0 ,1)
		elseif self.CurPlayerPlayingMusicID and self.PlayerPlayState then
			local function DelayPlay()
				self:StopOtherBgm()
			end
			self:RegisterTimer(DelayPlay, 0.5, 0 ,1)
		elseif self.ReCallPlayState then
			local function DelayPlay()
				AudioUtil.StopSound(self.RevertPlaySoundID, 0, 0)
				self:StopCurRevertMusic()  
				self:StopOtherBgm()
				self.IsbReconnect = true
				self:OpenRevertPanelView()
			end
			self:RegisterTimer(DelayPlay, 0.5, 0 ,1)
		end
	end


	self:SendMsgGetMusicList()
	--红点相关
	self:SendMsgGetUnLockList(1, 1, false)
	self:SendMsgMusicRedUpdate({})
	self:SendMsgGetRecordList({}, false)
end


function MusicPlayerMgr:SendMsgQuery()
	local MsgID = CS_CMD.CS_CMD_MUSIC
    local SubMsgID = SUB_MSG_ID.MusicOptCmd_Query

	local MsgBody = {}
    MsgBody.Cmd = SubMsgID 
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---获取已解锁乐谱列表
---@param Type number@用于区分打开乐谱图鉴还是播放器
---@param AtlasType number@区分乐谱图鉴打开方式，1是入口打开 2是交互物打开
function MusicPlayerMgr:SendMsgGetUnLockList(Type, AtlasType, IsClick)
    local MsgID = CS_CMD.CS_CMD_MUSIC
    local SubMsgID = SUB_MSG_ID.MusicOptCmd_GetUnLockList

	local MsgBody = {}
    MsgBody.Cmd = SubMsgID 
	self.OpenType = Type
	self.AtlasOpenType = AtlasType or 1
	self.IsClickAtlas = IsClick
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--查看播放列表
function MusicPlayerMgr:SendMsgGetMusicList()
    local MsgID = CS_CMD.CS_CMD_MUSIC
    local SubMsgID = SUB_MSG_ID.MusicOptCmd_GET

	local MsgBody = {}
    MsgBody.Cmd = SubMsgID 
	-- MsgBody.PlayList = {}
	-- MsgBody.PlayList.PlayListID = PlayListID
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MusicPlayerMgr:SendMsgSaveMusicList(NewMusicList)
	if NewMusicList == nil then
		FLOG_ERROR("SendMsgSaveMusicList = nil")
		return
	end
	local MsgID = CS_CMD.CS_CMD_MUSIC
    local SubMsgID = SUB_MSG_ID.MusicOptCmd_SavePlayList

	local MsgBody = {}
    MsgBody.Cmd = SubMsgID 
	MsgBody.SaveList = {}
	MsgBody.SaveList.PlayList = {}
	MsgBody.SaveList.PlayList.MusicID = {}
	for i = 1,#NewMusicList do
		table.insert(MsgBody.SaveList.PlayList.MusicID, NewMusicList[i].MusicID)
	end
	MsgBody.SaveList.PlayList.Name = self.NewName
	MsgBody.SaveList.PlayList.ID = self.CurPlayListIndex--NewMusicList[1].ID

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MusicPlayerMgr:SendMsgGetRecordReward(AwardID)
	local MsgID = CS_CMD.CS_CMD_MUSIC
    local SubMsgID = SUB_MSG_ID.MusicOptCmd_GetReward

	local MsgBody = {}
    MsgBody.Cmd = SubMsgID 
	MsgBody.RewardList = {}
	MsgBody.RewardList.ID = AwardID

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MusicPlayerMgr:SendMsgGetRecordList(List, IsClick)
	self.GatherList = List
	local MsgID = CS_CMD.CS_CMD_MUSIC
    local SubMsgID = SUB_MSG_ID.MusicOptCmd_GetRecordList

	local MsgBody = {}
    MsgBody.Cmd = SubMsgID 

	self.IsClickGather = IsClick
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MusicPlayerMgr:SendMsgMusicRedUpdate(List)
	local MsgID = CS_CMD.CS_CMD_MUSIC
    local SubMsgID = SUB_MSG_ID.MusicOptCmd_RedUpdate

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID 
    MsgBody.RedUpdate = {}
	MsgBody.RedUpdate.MusicIDs = List
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MusicPlayerMgr:OnNetMsgUpdateRedDotUpdate(MsgBody)
	--FLOG_ERROR("OnNetMsgUpdateRedDot = %s", table_to_string(MsgBody))
	local MusicIDs = MsgBody.RedUpdate.MusicIDs
	if #MusicIDs > 0 then
		if self.CheckRed then
			for i = 1, #MusicIDs do 
				self:AddAtlasRedDot(MusicIDs[i])
			end
			self.CheckRed = false
		end	
	end
end

function MusicPlayerMgr:OnNetMsgUpdateRedDot(MsgBody)
	--FLOG_ERROR("OnNetMsgUpdateRedDot = %s", table_to_string(MsgBody))
	local MusicIDs = MsgBody.UnlockNotify.MusicIDs
	local UpdateList = {}
	if #MusicIDs > 0 then
		for i = 1, #MusicIDs do
			local MusicID = MusicIDs[i]
			local Data = {}
			Data.MusicID = MusicID
			--GM现在会解锁非当前版本的，先临时处理 后续GM修改了删除
			local Onoff = self.AllAtlasList[MusicID].OnOff
			if Onoff == 1 then
				table.insert(self.AllMusicInfo, Data)
				self:AddAtlasRedDot(MusicIDs[i])
				DataReportUtil.ReportSystemFlowData("MusicFlow", tostring(1), tostring(MusicIDs[i]))
				for _, v in pairs(self.AtlasItemList) do
					if v.MusicID == MusicIDs[i] then
						v.IsUnLock = true
						table.insert(UpdateList, v.MusicID)
					end
				end
			end		
		end

		local AtlasViewVisible = UIViewMgr:IsViewVisible(UIViewID.MusicAtlasMainView)
		if #UpdateList > 0 and AtlasViewVisible then
			EventMgr:SendEvent(EventID.UpdateAtlasView, UpdateList)
		end
	end
end

function MusicPlayerMgr:OnNetMsgGetRecordReward(MsgBody)
	--FLOG_ERROR("OnNetMsgGetRecordReward = %s", table_to_string(MsgBody))
	if MsgBody.RewardList.ID then
		local RedDotName = _G.RedDotMgr:GetRedDotNameByID(self.AtlasEntrancerRedID)
		local NewRedName = RedDotName .. "/" .. tostring(MsgBody.RewardList.ID)
		_G.RedDotMgr:DelRedDotByName(NewRedName)
	end
end

function MusicPlayerMgr:OnNetMsgGetRecordList(MsgBody)
	--FLOG_ERROR("OnNetMsgGetRecordList = %s", table_to_string(MsgBody))
	self.GatherInfo = MsgBody.RecordInfoList.MusicRecordRewards
	local AwardList = {}
	local AwardCfg = MusicRewardCfg:FindAllCfg()
	local ViewID = UIViewID.MusicAtlasMainView
	local CurUnlockNum = #self.AllMusicInfo
	for i = 1, #AwardCfg do
		local Data = {}
		Data.CollectNum = AwardCfg[i].Num
		Data.AwardID = AwardCfg[i].ItemID[1]
		Data.AwardNum = AwardCfg[i].ItemNum[1]
		local IsHas = false
		if MusicPlayerMgr.GatherInfo[i] ~= nil then
			IsHas = MusicPlayerMgr.GatherInfo[i].Collected
		end
		Data.IsCollectedAward = IsHas
		if CurUnlockNum >= Data.CollectNum and not IsHas then
			local RedDotName = _G.RedDotMgr:GetRedDotNameByID(self.AtlasEntrancerRedID)
			local NewRedName = RedDotName .. "/" .. tostring(i)
			_G.RedDotMgr:AddRedDotByName(NewRedName, 1)
		end
		table.insert(AwardList, Data)	
	end

	if self.IsClickGather then
		local function OnGetAwardClicked(Index, ItemData, ItemView)
			MusicPlayerMgr:SendMsgGetRecordReward(Index)
		end
		CollectionAwardUtil.ShowCollectionAwardView(ViewID, self.GatherList.Progress, self.GatherList.MaxCount, AwardList, OnGetAwardClicked)
	else
		
	end
end

function MusicPlayerMgr:OnNetMsgGetUnLockList(MsgBody)
	local Info = MsgBody.UnlockList.UnlockMusicList
	if Info == nil then
		FLOG_ERROR("OnNetMsgGetUnLockList = nil")
		return
	end
	self.AllMusicInfo = Info

	if self.IsClickAtlas then
		if self.OpenType == 1 then
			MusicPlayerMgr:SetAtlasInfoByType()
			UIViewMgr:ShowView(UIViewID.MusicAtlasMainView)
		else
			EventMgr:SendEvent(EventID.UpdateUnLockInfo)
		end
	else
		MusicPlayerMgr:SetAtlasInfoByType()
	end
end

function MusicPlayerMgr:OnNetMsgGetQueryList(MsgBody)
	FLOG_ERROR("Test OnNetMsgGetQueryList = %s",MsgBody)
end

function MusicPlayerMgr:OnNetMsgGetMusicList(MsgBody)
	--FLOG_ERROR("Test OnNetMsgGetMusicList = %s",MsgBody)
	local Info = MsgBody.PlayList.PlayList
	if #Info == 0 then
		local List = {}
		for i = 1, 4 do
			local Data = {}
			local PlayListName = LSTR(1190019)
			Data.Name = string.format("%s%d", PlayListName, i)
			table.insert(List, Data)
		end
		self.CurPlayListIndex = 1
		self.CurPlayListIDInfo = List[1]
		self.AllPlayListInfo = List
	else
		local List = {}
		for i = 1, 4 do
			for j = 1, #Info do
				if i == Info[j].ID then 
					table.insert(List, Info[j])
				end
			end

			if List[i] == nil then
				local Data = {}
				Data.Name = string.format("%s%d", "播放列表", i)
				table.insert(List, Data)
			end
		end

		self.CurPlayListIndex = 1
		self.CurPlayListIDInfo = List[1]
		self.AllPlayListInfo = List
	end
	-- local Info = MsgBody.PlayList.PlayList
	-- self.CurPlayListIndex = Info.ID
	-- self.CurPlayListIDInfo = Info
	--EventMgr:SendEvent(EventID.UpdateMusicInfo)
end

function MusicPlayerMgr:OnNetMsgReplaceMusicList(MsgBody)
	FLOG_ERROR("Test OnNetMsgReplaceMusicList = %s",MsgBody)
end

function MusicPlayerMgr:OnNetMsgSaveList(MsgBody)
	--FLOG_ERROR("Test OnNetMsgSaveList = %s",MsgBody)
	if MsgBody.SaveList.PlayList == nil then
		FLOG_ERROR("Test OnNetMsgSaveList Error ")
		return
	end
	self.CurPlayListIDInfo = MsgBody.SaveList.PlayList
	self.AllPlayListInfo[self.CurPlayListIndex] = MsgBody.SaveList.PlayList
	self.IsCanSave = false
	EventMgr:SendEvent(EventID.UpdateInfoAfterSave)
end

function MusicPlayerMgr:OnGameEventPWorldEnter(Params)
	--FLOG_ERROR("OnGameEventPWorldEnter = %d", Params.CurrMapResID)
	if Params.CurrMapResID then
		for _, MapID in pairs(HotleID) do
			if Params.CurrMapResID == MapID then
				self.IsInHotel = true
				if self.CurPlayerPlayingMusicID then
					self.IsStopTips = true
					--如果设置了旅馆BGM 在进入旅馆的时候需要将原本BGM音量屏蔽，防止出现一段原本BGM后才开始播放手动设置的旅馆BGM
					_G.UE.UBGMMgr.Get():ChangeBGMVolume(0, 0)
					self:StopOtherBgm()
					MusicPlayerMainPanelVM:PlayMusic(2, true)
				end
				break
			else
				if self.IsInHotel then
					self.IsInHotel = false
					--退出旅馆后恢复原本BGM声音
					self:RegisterTimer(function() _G.UE.UBGMMgr.Get():ChangeBGMVolume(1, 2) end, 3, 0, 1)
				end
			end
		end
	end
end

--退出副本
function MusicPlayerMgr:OnGameEventPWorldExit()
	if self.PlayerPlayState and self.CurPlayerPlayingMusicID then
		MusicPlayerMainPanelVM:PlayMusic(1, true)
	end

	if self.ReCallState then
		self:ExitRevertState()
	end
end

function MusicPlayerMgr:OnGameEventAttackEffectChange(Params)
	if nil == Params then
		return
	end
	local BehitObjID = Params.BehitObjID
	local IsToMajor = MajorUtil.IsMajor(BehitObjID)
	if self.ReCallState and IsToMajor then
		self:ExitRevertState()
	end
end

function MusicPlayerMgr:OnGameBeginPlaySequence(Params)
	if self.ReCallState then
		self:ExitRevertState()
	end
end

function MusicPlayerMgr:OnGameEndPlaySequence()
	if self.ReCallState then
		self:ExitRevertState()
	end
end

function MusicPlayerMgr:OnGameEventCombatStateChanged()
	if self.ReCallState then
		self:ExitRevertState()
	end
end

--- 获取音乐文件时长
---@param MusicID number@乐谱id
function MusicPlayerMgr:GetMusicTime(MusicID)
	if MusicID == nil then
		return
	end
	
	local Time = MusicPlayerCfg:FindCfgByKey(MusicID).Time

	if Time == nil then
		return
	end

	-- local Min = os.date("%M",Time)
	-- local Second = os.date("%S",Time)
	-- local NewSecond = Min * 60 + Second
	local NewSecond = Time / 1000
	return NewSecond
end

--- 申请具体id的商店信息
---@param Tyep number @1 有最近收录栏 2 没有
--- 获取乐谱种类信息
function MusicPlayerMgr:GetMusicTypeInfo(Tyep)
	local Data = {}
	local MCfg = self.AllTypeInfo
	if Tyep == 1 then
		Data[1] = {}
		Data[1].Name = LSTR(1190008)
		Data[1].Sort = 1
		Data[1].IconPath = nil
		Data[1].ShowType = 0
		for i = 2, #MCfg + 1 do
			Data[i] = {}
			Data[i].Type = MCfg[i - 1].ID
			Data[i].Name = MCfg[i - 1].Name
			Data[i].Sort = MCfg[i - 1].Sort
			Data[i].IconPath = MCfg[i - 1].Icon
			Data[i].ShowType = MCfg[i - 1].ShowType
		end
	else
		for i = 1, #MCfg do
			Data[i] = {}
			Data[i].Type = MCfg[i].ID
			Data[i].Name = MCfg[i].Name
			Data[i].Sort = MCfg[i].Sort
			Data[i].IconPath = MCfg[i].Icon
			Data[i].ShowType = MCfg[i].ShowType
			Data[i].RedDotData = {}
			Data[i].Type = i
			-- Data[i].RedDotData.RedDotName = "Root/MusicAtlas/1"
			-- Data[i].RedDotData.IsStrongReminder = false
		end
	end
	

	table.sort(Data, self.SortListBySort)
	return Data
end

function MusicPlayerMgr.SortListBySort(Left, Right)
	if Left.Sort < Right.Sort then
		return true
	else
		return false
	end
end

--判断修改的名字是否重名
function MusicPlayerMgr:IsSameName(NewName)
	local IsSame = false
	for i = 1, #self.AllPlayListInfo do
		if self.AllPlayListInfo[i].Name == NewName then
			IsSame = true
			return IsSame
		end
	end

	return IsSame
end

function MusicPlayerMgr:SetSaveListInfo()
	local EditInfo = self.EditMusicInfo
	local List = {}
	for i = 1,#EditInfo do
		if EditInfo[i].IsNil == false then
			local Data = {}
			Data.ID = self.CurPlayListIndex or 1
			Data.MusicID = EditInfo[i].MusicID
			Data.Name = self.AllPlayListInfo[self.CurPlayListIndex].Name
			table.insert(List, Data)
		end
	end

	return List
end

function MusicPlayerMgr:SetOldPlayList(List)
	self.OldPlayListInfo = List
end

--播放列表是否有改变
function MusicPlayerMgr:PlayListIsChanged()
	local IsCanSave = false
	for i = 1, 8 do
		local CurMusicList = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayListIndex].MusicID
		local OriginMusicID
		
		if CurMusicList == nil then
			OriginMusicID = nil
		else
			OriginMusicID = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayListIndex].MusicID[i]
		end

		local NewMusicId = self.EditMusicInfo[i].MusicID
		if OriginMusicID == nil then
			OriginMusicID = 0
		end

		if OriginMusicID ~= NewMusicId then
			IsCanSave = true
			break
		end
	end

	self.IsCanSave = IsCanSave

	if self.ListNameIsChanged then
		self.IsCanSave = true
	end

	EventMgr:SendEvent(EventID.UpdateCanSaveState, self.IsCanSave)
end

function MusicPlayerMgr:GetTestData()
	return MusicPlayerCfg:FindAllCfg()
end

--打开播放器GM
function MusicPlayerMgr:OpenMusicPlayer()
	local Data = {}
	Data.IsInHotel = self.IsInHotel or false
	UIViewMgr:ShowView(UIViewID.MusicPlayerMainPanelView, Data)
end

--打开图鉴GM
function MusicPlayerMgr:OpenMusicAtlas(Value)
	MusicPlayerMgr:SendMsgGetUnLockList(1, Value, true)
end

--根据种类设置种类图谱信息
function MusicPlayerMgr:SetAtlasInfoByType()
	local AllAtlasList = self.AllAtlasList
	local AllTypeInfo = self.AllTypeInfo
	local AllUnlockList = self.AllMusicInfo
	local NewList = {}

	--处理全部乐谱信息和已解锁的信息
	for key, Value in pairs(AllAtlasList) do
		local Data = {}
		Data.Name = Value.MusicName
		Data.MusicID = Value.MusicID
		Data.Sort = Value.Sort
		Data.PlayType = Value.PlayType
		Data.ItemID = Value.ItemID
		Data.OnOff = Value.OnOff
		Data.IsUnLock = false

		for j = 1, #AllUnlockList do 
			if Value.MusicID == AllUnlockList[j].MusicID then
				Data.IsUnLock = true
			end
		end
		table.insert(NewList, Data)
	end

	self.AtlasItemList = NewList
	local NewAllList = {}
	for i = 1, #AllTypeInfo do
		NewAllList[i] = {}
		for j = 1, #NewList do
			if AllTypeInfo[i].ID == NewList[j].PlayType then
				table.insert(NewAllList[i], NewList[j])
			end
		end
	end

	self.AllAtlasInfoList = NewAllList
end

function MusicPlayerMgr.SortAtlasList(Left, Right)
    if Left.Sort < Right.Sort then
        return true
    else
        return false
    end
end

--根据种类获取种类图谱信息
function MusicPlayerMgr:GetAtlasInfoByType(PlayType)
	local ShowType = self.AllTypeInfo[PlayType].ShowType
	local CurPlayTypeList = self.AllAtlasInfoList[PlayType] or {}
	if ShowType == 1 then
		local List = {}
		table.sort(CurPlayTypeList, self.SortAtlasList)
		for _, Info in ipairs(CurPlayTypeList) do
			if Info.IsUnLock and Info.OnOff == 1 then
				Info.Number = #List + 1
				table.insert(List, Info)
			end
		end

		return List
	else
		local List = {}
		table.sort(CurPlayTypeList, self.SortAtlasList)
		for _, Info in ipairs(CurPlayTypeList) do
			if Info.OnOff == 1 then
				Info.Number = #List + 1
				table.insert(List, Info)
			end
		end

		return List
	end
end

--获取图谱是否解锁
function MusicPlayerMgr:GetAtlasIsUnlock(Index, MusicID)
	local IsUnLock = false
	for i = 1, #self.AllAtlasInfoList[Index] do
		if self.AllAtlasInfoList[Index][i].MusicID == MusicID then
			IsUnLock = self.AllAtlasInfoList[Index][i].IsUnLock
			return IsUnLock
		end
	end

	return IsUnLock
end

--播放乐谱播放器的音乐
function MusicPlayerMgr:PlayPlayerMusic(MusicID)
	if MusicPlayerMgr.PlayerTimeID then
		self:UnRegisterTimer(MusicPlayerMgr.PlayerTimeID)
		MusicPlayerMgr.PlayerTimeID = nil
	end
	MusicPlayerMgr.CurPlayerPlayingMusicID = MusicID
	MusicPlayerMgr.MusicTotalTime = self:GetMusicTime(MusicID)
	MusicPlayerMgr.PlayerStartTime = _G.TimeUtil:GetServerTime()
	MusicPlayerMgr.CurPlayTime = 0
	MusicPlayerMgr.PlayerTimeID = self:RegisterTimer(self.UpdatePlayerTimeTextAndBar, 0, 1, 0)
end

function MusicPlayerMgr:UpdatePlayerTimeTextAndBar()
	local CurrentTime = _G.TimeUtil:GetServerTime()
	local ElapsedTime = CurrentTime - MusicPlayerMgr.PlayerStartTime
	local CurTime = math.min(ElapsedTime, MusicPlayerMgr.MusicTotalTime)

	--时间结束自动切歌
	if not CurTime or CurTime >= MusicPlayerMgr.MusicTotalTime then
		if self.MusicPlayerIsShow then
			local Time = {}
			Time.CurTime = CurTime
			Time.TotalTime = MusicPlayerMgr.MusicTotalTime
			EventMgr:SendEvent(EventID.UpdatePlayerState, Time)
			--self:UnRegisterTimer(MusicPlayerMgr.PlayerTimeID)
		else
			MusicPlayerMainPanelVM:PlayMusicByPlayMode(false, true)
			MusicPlayerMainPanelVM:PlayMusic(2)
		end
		return
	end


	local Time = {}
	Time.CurTime = CurTime
	Time.TotalTime = MusicPlayerMgr.MusicTotalTime
	MusicPlayerMgr.CurPlayTime = CurTime
	EventMgr:SendEvent(EventID.UpdatePlayerState, Time)
end

--播放乐谱图鉴的音乐
function MusicPlayerMgr:PlayAtlasMusic(MusicID, PlayingIndex)
	if self.AtlasOpenType == 1 then
	end
	if MusicPlayerMgr.TimeID then
		self:UnRegisterTimer(MusicPlayerMgr.TimeID)
	end
	MusicPlayerMgr.CurPlayingMusicID = MusicID
	MusicPlayerMgr.CurAtlasPlayingIndex = PlayingIndex
	self.IsShowCurSlide = true
	MusicPlayerMgr.CurAtalsPlayTime = 0
	MusicPlayerMgr.MusicAtalsTotalTime = self:GetMusicTime(MusicID) or 0
	MusicPlayerMgr.TimeID = self:RegisterTimer(self.UpdateAtlasTimeTextAndBar, 0, 1, 0)
end

function MusicPlayerMgr:UpdateAtlasTimeTextAndBar()
	local CurTime = MusicPlayerMgr.CurAtalsPlayTime

	if CurTime == nil or CurTime > MusicPlayerMgr.MusicAtalsTotalTime + 1 then
		--self:UnRegisterTimer(MusicPlayerMgr.TimeID)
		EventMgr:SendEvent(EventID.RestPlay)
		return
	elseif CurTime > 30 then
		--选择ID和播放ID不同时 计时器在执行但是未通知View层面
		if MusicPlayerMgr.CurPlayingMusicID ~= MusicPlayerMgr.CurChoseAtlasID then
			local CurPlayIsUnlock = self:GetAtlasIsUnlock(MusicPlayerMgr.CurAtlasPlayingIndex, MusicPlayerMgr.CurPlayingMusicID)
			if not CurPlayIsUnlock then
				EventMgr:SendEvent(EventID.RestPlay)
				return
			end
		end
	end

	local Time = {}
	Time.CurTime = CurTime
	Time.TotalTime = MusicPlayerMgr.MusicAtalsTotalTime

	if self.IsShowCurSlide and not self.IsDropSlide then
		EventMgr:SendEvent(EventID.UpdateAtlasPlayState, Time)
	end

	MusicPlayerMgr.CurAtalsPlayTime = MusicPlayerMgr.CurAtalsPlayTime + 1
	--MusicPlayerMgr.CurAtalsPlayTime = CurTime
end

--播放回想音乐
function MusicPlayerMgr:PlayAtlasRevertMusic(MusicID)
	if self.RevertTimeID then
		self:UnRegisterTimer(self.RevertTimeID)
	end
	self.CurPlayingRevertID = MusicID
	self.RevertStartTime = _G.TimeUtil:GetServerTime()
	self.CurRevertPlayTime = 0
	self.RevertTotalTime = self:GetMusicTime(MusicID) or 0
	self.RevertTimeID = self:RegisterTimer(self.UpdateRevertTimeTextAndBar, 0, 1, 0)
end

function MusicPlayerMgr:UpdateRevertTimeTextAndBar()
	local CurrentTime = _G.TimeUtil:GetServerTime()
	local ElapsedTime = CurrentTime - MusicPlayerMgr.RevertStartTime
	local CurTime = math.min(ElapsedTime, MusicPlayerMgr.RevertTotalTime)
	self.CurRevertPlayTime = CurTime

	local Time = {}
	Time.CurTime = self.CurRevertPlayTime
	Time.TotalTime = self.RevertTotalTime
	if not self.IsDragSlide then
		EventMgr:SendEvent(EventID.UpdateRevertState, Time)
	end
end

function MusicPlayerMgr:StopCurMusic()
	if MusicPlayerMgr.TimeID then
		self:UnRegisterTimer(MusicPlayerMgr.TimeID)
		MusicPlayerMgr.TimeID = nil
	end
end

function MusicPlayerMgr:StopCurPlayerMusic()
	if MusicPlayerMgr.PlayerTimeID then
		self:UnRegisterTimer(MusicPlayerMgr.PlayerTimeID)
		MusicPlayerMgr.PlayerTimeID = nil
	end
end

function MusicPlayerMgr:StopCurRevertMusic()
	if MusicPlayerMgr.RevertTimeID then
		self:UnRegisterTimer(MusicPlayerMgr.RevertTimeID)
		MusicPlayerMgr.RevertTimeID = nil
	end
end

function MusicPlayerMgr:StopOtherBgm()
	_G.UE.UBGMMgr.Get():Pause()
	if _G.MountMgr:IsInRide() then
		_G.MountMgr:StopMountBGM()
	end
end

function MusicPlayerMgr:RecoverMountBGM()
	_G.MountMgr:PlayMountBGM()
end

function MusicPlayerMgr:SetNumber(Num, IsRight)
	local NewNum = ""
	if IsRight then
		if Num < 10 then
			NewNum = string.format("%s%d", "00", Num)
		elseif Num < 100 and Num >= 10 then
			NewNum = string.format("%s%d", "0", Num)
		else
			NewNum = string.format("%s", Num)
		end
	else
		if Num < 10 then
			NewNum = string.format("%s%d", "0", Num)
		else
			NewNum = string.format("%s", Num)
		end
	end

	return NewNum
end

function MusicPlayerMgr:ClearAtlasInfo()
	if MusicPlayerMgr.TimeID then
		self:UnRegisterTimer(MusicPlayerMgr.TimeID)
	end
	self.CurChoseAtlasID = nil
	self.CurPlayingMusicID = nil
	self.IsShowCurSlide = false
	self.IsDropSlide = false
end

function MusicPlayerMgr:AddAtlasRedDot(ID)
	if not table.contain(self.RedDotList, ID) then
		local RedDotName = self.RedDotName .. "/" .. tostring(ID)
		_G.RedDotMgr:AddRedDotByName(RedDotName, 1)
		table.insert(self.RedDotList, ID)
	end
end

function MusicPlayerMgr:RemoveSingleRedDot(ID)
	if table.contain(self.RedDotList, ID) then
		local RedDotName = self.RedDotName .. "/" .. tostring(ID)
		table.remove_item(self.RedDotList, ID)
		_G.RedDotMgr:DelRedDotByName(RedDotName)
		local List = {}
		table.insert(List, ID)
		self:SendMsgMusicRedUpdate(List)
	end
end

function MusicPlayerMgr:GetCurTypeRedDot(List)
	local NewList = {}
	for i = 1, #List do
		local CurTypeList = self:GetAtlasInfoByType(List[i].Type)
		if #CurTypeList > 0 then
			for j = 1, #CurTypeList do
				if table.contain(self.RedDotList, CurTypeList[j].MusicID) then
					local RedDotData = {}
					RedDotData.RedDotName = self.AtlasTabTypeDotName .. "/" .. i
					RedDotData.IsStrongReminder = false
					List[i].RedDotData = RedDotData
					_G.RedDotMgr:AddRedDotByName(RedDotData.RedDotName, nil, nil)

				end
			end
			table.insert(NewList, List[i])
		end
	end

	return NewList
end

function MusicPlayerMgr:RemoveCurTabTypeAllRedDot(List)
	local DelRedList = {}
	for i = 1, #List do
		if table.contain(self.RedDotList, List[i].MusicID) then
			local RedDotName = self.RedDotName .. "/" .. tostring(List[i].MusicID)
			table.remove_item(self.RedDotList, List[i].MusicID)
			_G.RedDotMgr:DelRedDotByName(RedDotName)
			table.insert(DelRedList, List[i].MusicID)
		end
	end

	if #DelRedList > 0 then
		self:SendMsgMusicRedUpdate(DelRedList)
	end
end

---@type 检查某个乐谱图鉴是否解锁
function MusicPlayerMgr:CheckAtlasOpenState(ResID)
    local Cfg = ItemCfg:FindCfgByKey(ResID)
    if Cfg == nil then
        return false
    end

    if (Cfg.ItemType ~= ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_ORCHESTRIONROLL) then
        return false
    end

	for _, v in pairs(self.AtlasItemList) do
		if v.ItemID == ResID then
			return v.IsUnLock
		end
	end

    return false
end

function MusicPlayerMgr:GetMusicIDOnOff(MusicID)

end

----------------------------乐谱回想---------------------------------

--检查当前状态是否冲突
function MusicPlayerMgr:CheckOtherEnterState()
	local MajorActor = MajorUtil.GetMajor()
	local IsFly = MajorActor:IsInFly()                                          --飞行
	local IsChocoboTranspor = _G.ChocoboTransportMgr:GetIsTransporting()        --陆行鸟运输


	if IsFly then
		_G.MsgTipsUtil.ShowTipsByID(109701)
		return false
	elseif IsChocoboTranspor then
		_G.MsgTipsUtil.ShowTipsByID(109700)
		return false
	end

	return true
end

-- function MusicPlayerMgr:GetTipsByType(Type)
-- 	if Type == OtherStat[1] then
-- 		return LSTR("战斗状态下，无法使用")
-- 	elseif Type == OtherStat[2] then
-- 		return LSTR("死亡状态下，无法使用")
-- 	elseif Type == OtherStat[3] then
-- 		return LSTR("飞行状态下，无法使用")
-- 	elseif Type == OtherStat[4] then
-- 		return LSTR("陆行鸟运输状态下，无法使用")
-- 	elseif Type == OtherStat[5] then
-- 		return LSTR("复活状态下，无法使用")
-- 	end
-- end

function MusicPlayerMgr:SetRecallState(Value)
	self.ReCallState = Value
	CommonStateUtil.SetIsInState(CommStatRecallID, Value)
	_G.ClientReportMgr:SendClientReport(ClientReportType.ReportTypeRecollect, {Recollect = {IsRecollect = Value}})
	--进入回想后BGM不随场景切换
	_G.UE.UBGMMgr.Get():SetKeepBGMWhenWorldChange(false)
	if not Value then
		if self.PlayerPlayState and self.CurPlayerPlayingMusicID then
			local Percent = MusicPlayerMgr.CurPlayTime / MusicPlayerMgr.MusicTotalTime
			MusicPlayerMainPanelVM:RecoverCurPlayMusic(Percent)
		else
			self:RecoverBGM()
		end
	end
end

function MusicPlayerMgr:CheckCurRecallState()
	return self.ReCallState or false
end

--获取角色当前是否是站立状态
function MusicPlayerMgr:GetMajorIdleStat()
	local EntityID = MajorUtil.GetMajorEntityID()
	local PlayerAnimInst = AnimationUtil.GetAnimInst(EntityID)
	if PlayerAnimInst == nil then
		return
	end
	-- 获取Idle类型
    local IdleType = PlayerAnimInst.PrevIdleType
	--站立状态
	if IdleType == ProtoRes.StanceType.NORMAL_STAND then
		return true
	end

	return false
end

function MusicPlayerMgr:OpenRevertPanelView()
	local CommState = CommonStateUtil.CheckBehavior(CommBehaviorRecallID, true)
	if not CommState then
		return
	end
	local OtherState = self:CheckOtherEnterState()
	if CommState and OtherState then
		local Data = {}
		if not self.IsbReconnect then
			Data.CurChoseAtlasID = MusicPlayerMgr.CurChoseAtlasID
			Data.TypeIndex = MusicPlayerMgr.CurTypeIndex
		else
			Data.CurChoseAtlasID = MusicPlayerMgr.CurPlayingRevertID
			Data.TypeIndex = MusicPlayerMgr.CurRevertPlayingTypeIndex
		end
		--如果在播放器状态下进入试听，停止播放器的声音，计时器继续走，后续退出回想需要根据当前时间恢复播放器进度
		if self.PlayerPlayState and self.CurPlayerPlayingMusicID then
			AudioUtil.StopSound(self.PlaySoundID, 2000, 2)
		end
		UIViewMgr:ShowView(UIViewID.MusicAtlasRevertPanelView, Data)
		MusicPlayerMgr:SetRecallState(true)
		local Major = MajorUtil.GetMajor()
		if Major == nil then return end
		local RideCom = Major:GetRideComponent()
		if RideCom == nil then return end
		local bIsRiding = RideCom:IsInRide()
		if bIsRiding then
			_G.MountMgr:GetDownMount(false)
		end
	end
end

--恢复背景音乐
function MusicPlayerMgr:RecoverBGM()
	_G.UE.UBGMMgr.Get():Resume()
end

function MusicPlayerMgr:GetTypeIndexByTabList(TabList, Type)
	for K, V in pairs(TabList) do
		if V.Type == Type then
			return K
		end
	end
end

function MusicPlayerMgr:ExitRevertState()
	EventMgr:SendEvent(EventID.ExitRevertState)
	_G.MsgTipsUtil.ShowTips(LSTR(1170015))
	local GuideMain = _G.UIViewMgr:FindView(UIViewID.GuideMainPanelView)
	if GuideMain then
		_G.UIViewMgr:HideView(UIViewID.GuideMainPanelView)
	end
end

function MusicPlayerMgr:SetInHotleState(Value)
	self.IsInHotel = Value
end

--要返回当前类
return MusicPlayerMgr