--
-- Author: ds_yangyumian
-- Date: 2023-12-08 10:00
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MusicPlayerListItemVM = require("Game/MusicPlayer/View/Item/MusicPlayerListItemVM")
local MusicPlayerMgr = require("Game/MusicPlayer/MusicPlayerMgr")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local MusicPlayerCfg = require("TableCfg/MusicPlayerCfg")
local LocalizationUtil = require("Utils/LocalizationUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")
local MsgTipsID = require("Define/MsgTipsID")




local LSTR = _G.LSTR
local UAudioMgr = _G.UE.UAudioMgr
local UE = _G.UE
local FadeOutTime = 2000
local FadeInTime = 2
local FadeCurve = _G.UE.AkCurveInterpolation.AkCurveInterpolation_Linear
local MapDynType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
local MusicInID = 888 --旅馆播放器物件ID

local PlayBtnStateIcon = {
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Play_png.UI_MusicPlayer_Icon_Play_png'",
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Pause_png.UI_MusicPlayer_Icon_Pause_png'",
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Play2_png.UI_MusicPlayer_Icon_Play2_png'",
}

local CirculateBtnStateOnIcon = {
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Order_png.UI_MusicPlayer_Icon_Order_png'",
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Single_png.UI_MusicPlayer_Icon_Single_png'",
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Random_png.UI_MusicPlayer_Icon_Random_png'",
}

local CirculateBtnStateOffIcon = {
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Order2_png.UI_MusicPlayer_Icon_Order2_png'",
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Single2_png.UI_MusicPlayer_Icon_Single2_png'",
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Random2_png.UI_MusicPlayer_Icon_Random2_png'",
}

local BtnNextStateIcon = {
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Next_png.UI_MusicPlayer_Icon_Next_png'",
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Next2_png.UI_MusicPlayer_Icon_Next2_png'",
}

local BtnPreviousStateIcon = {
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Previous_png.UI_MusicPlayer_Icon_Previous_png'",
	"PaperSprite'/Game/UI/Atlas/MusicPlayer/Frames/UI_MusicPlayer_Icon_Previous2_png.UI_MusicPlayer_Icon_Previous2_png'",
}

---@class MusicPlayerMainPanelVM : UIViewModel
local MusicPlayerMainPanelVM = LuaClass(UIViewModel)

---Ctor
function MusicPlayerMainPanelVM:Ctor()
	self.CurMusicList = UIBindableList.New(MusicPlayerListItemVM)
	self.DropList = nil
	self.MusicName = ""
	self.BtnPlayPauseState = nil
	self.BtnCirculateState = nil
	self.BtnPreviousState = nil
	self.BtnNextState = nil
	self.DropListInfo = {}
	self.CurPlayState = false  --当前播放状态
	self.Title = nil
	self.TimeText = nil
	self.MusicInfo = {}
	self.PlaySoundID = nil
	self.PlayTestSoundID = nil
	self.TimeLen = nil
	self.Percent = nil
	self.OldPlayIndex = 0
	self.EditMusicInfo = {}
	self.OpenBtnText = LSTR(1190003)
	self.BtnSaveState = false
	self.PercentScale = nil
	self.CurListIsNil = false --当前列表是否为空
	self.PlayEffState = false
	self.CurIndexEmptyState = false  --当前播放列表是否为空状态
	self.CurPlaingMusicIndex = nil --当前正在播放的乐曲Index
end

function MusicPlayerMainPanelVM:OnInit()

end

function MusicPlayerMainPanelVM:OnBegin()

end

function MusicPlayerMainPanelVM:OnEnd()

end

function MusicPlayerMainPanelVM:UpdateMusicListInfo(List)
	if List == nil or List.MusicID == nil then
		return
	end

	local NewList = {}
	for i = 1, #List.MusicID do
		local Data = {}
		Data.Index = i
		Data.MusicID = List.MusicID[i] or 0
		local MusicInfo = MusicPlayerCfg:FindCfgByKey(Data.MusicID)
		if MusicInfo then
			Data.Time = MusicInfo.Time
			Data.MusicName = MusicInfo.MusicName
			-- List[i].Time = MusicPlayerCfg:FindCfgByKey(Index).Time
			-- List[i].MusicName = MusicPlayerCfg:FindCfgByKey(Index).MusicName
			table.insert(NewList, Data)
		else
			FLOG_ERROR("UpdateMusicListInfo MusicID Error = %d", Data.MusicID)
		end
	end

	self.MusicInfo = NewList
	self.CurMusicList:UpdateByValues(NewList)
end

function MusicPlayerMainPanelVM:UpdateMusicListInfoByEdit(MusicInfo, IsUpdate)
	local List = {}
	local IsTrue = IsUpdate or false

	--待优化
	if IsTrue then
		for i = 1, 8 do
			if MusicInfo[i].MusicID ~= nil and  MusicInfo[i].MusicID ~= 0 then
				local MusicID =  MusicInfo[i].MusicID
				List[i] = {} 
				List[i].Time = MusicPlayerCfg:FindCfgByKey(MusicID).Time
				List[i].MusicName = MusicPlayerCfg:FindCfgByKey(MusicID).MusicName
				List[i].MusicID = MusicID
				List[i].Index = i
				List[i].IsNil = false
			else
				List[i] = {} 
				List[i].Time = 0
				List[i].MusicName = LSTR(1190009)
				List[i].MusicID = 0
				List[i].Index = i
				List[i].IsNil = true
			end
		end

		self.EditMusicInfo = List
		MusicPlayerMgr.EditMusicInfo = self.EditMusicInfo
		self.CurMusicList:UpdateByValues(List)
		return
	end


	if MusicInfo.MusicID == nil or #MusicInfo.MusicID == 0 then
	--if #MusicInfo == 0 then
		for i = 1, 8 do
			List[i] = {} 
			List[i].Time = 0
			List[i].MusicName = LSTR(1190009)
			List[i].MusicID = 0
			List[i].Index = i
			List[i].IsNil = true
		end
	else
		for i = 1, 8 do
			List[i] = {} 
			if MusicInfo.MusicID[i] ~= nil and  MusicInfo.MusicID[i] ~= 0 then
				local MusicID =  MusicInfo.MusicID[i] or 0
				local MusicInfo = MusicPlayerCfg:FindCfgByKey(MusicID)
				if MusicInfo then
					List[i].Time = MusicInfo.Time
					List[i].MusicName = MusicInfo.MusicName
					List[i].MusicID = MusicID
					List[i].Index = i
					List[i].IsNil = false
				else
					FLOG_ERROR("UpdateMusicListInfoByEdit MusicID Error = %d ", MusicID)
				end
			else
				List[i].Time = 0
				List[i].MusicName = LSTR(1190009)
				List[i].MusicID = 0
				List[i].Index = i
				List[i].IsNil = true
			end
		end
	end

	self.EditMusicInfo = List
	MusicPlayerMgr.EditMusicInfo = List
	self.CurMusicList:UpdateByValues(List)
end

function MusicPlayerMainPanelVM:UpdateMusicName(Name)
	self.MusicName = Name
end

function MusicPlayerMainPanelVM:UpdateDropList()
	-- for i = 1, 4 do
	-- 	local Data = {}
	-- 	Data.Name = string.format("%s%d", "播放列表", i)
	-- 	if self.DropListInfo == nil then
	-- 		self.DropListInfo = {}
	-- 	end
	-- 	table.insert(self.DropListInfo, Data)
	-- end
	--local TEST = self.DropListInfo
	local AllList = MusicPlayerMgr.AllPlayListInfo
	self.DropListInfo = AllList
end

function MusicPlayerMainPanelVM:UpdatePlayState(Type, IsClick)
	local IsByClick = IsClick or false
	local Index = MusicPlayerMgr.CurPlayIndex	
	if MusicPlayerMgr.GoonPlaySoundID ~= nil then
		AudioUtil.StopSound(MusicPlayerMgr.GoonPlaySoundID, FadeOutTime, nil)
		MusicPlayerMgr.GoonPlaySoundID = nil
	end
	if Index == 0 then
		if self.PlayEffState then
			self.PlayEffState = false
		end
		return
	end

	local MajorEntityID = MajorUtil.GetMajorEntityID()
	--播放时要区分一下当前列表和正在播放的歌曲处于的列表情况
	-- if MusicPlayerMgr.CurPlayListIndex == MusicPlayerMgr.CurPlayingListIndex then
	-- 	if self.MusicInfo[Index] == nil then
	-- 		return
	-- 	end
	-- else
	-- 	if MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayingListIndex].MusicID == nil then
	-- 		return
	-- 	end
	-- end 

	if MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayingListIndex].MusicID == nil then
		return
	end

	if not self.CurListIsNil and IsByClick then
		MusicPlayerMgr.CurPlayingListIndex = MusicPlayerMgr.CurPlayListIndex
	end

	local MusicID

	--此处需要区分一下正在播放的列表和当前处于的列表是否同一个
	if MusicPlayerMgr.CurPlayListIndex == MusicPlayerMgr.CurPlayingListIndex then
		if MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayListIndex].MusicID then
			MusicID = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayListIndex].MusicID[Index]
		end
	else
		if MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayingListIndex].MusicID then
			MusicID = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayingListIndex].MusicID[Index]
		end
	end

	if MusicID == nil then
		self.BtnPlayPauseState = PlayBtnStateIcon[1]
		self.PlayEffState = false
		MusicPlayerMgr.PlayerPlayState = false
		return
	end
	local MusicFile = MusicPlayerCfg:FindCfgByKey(MusicID).MusicFile
	local Time = MusicPlayerCfg:FindCfgByKey(MusicID).Time
	local MusicName = MusicPlayerCfg:FindCfgByKey(MusicID).MusicName
	if Type == 1 then
		local State = not MusicPlayerMgr.PlayerPlayState
		self.CurPlayState =  State
		if State then
			MusicPlayerMgr:StopOtherBgm()
			if MusicPlayerMgr.PlaySoundID ~= nil then
				AudioUtil.StopSound(MusicPlayerMgr.PlaySoundID, FadeOutTime, nil)
				self.PlaySoundID = nil
				MusicPlayerMgr.PlaySoundID = nil
			end 
			self:UpdateTimeInfo(Time)
			self:UpdateMusicName(MusicName)
			MusicPlayerMgr.CurPlayTime = MusicPlayerMgr:GetMusicTime(MusicID)
			MusicPlayerMgr.CurPlayerPlayingMusicID = MusicID
			--回想状态下不进行声音播放
			if not MusicPlayerMgr.ReCallState then
				self.PlaySoundID = AudioUtil.SyncLoadAndPlaySoundEvent(MajorEntityID, MusicFile)
				_G.UE.UAudioMgr:Get():PlayFadeInEffect(self.PlaySoundID, FadeInTime, FadeCurve)
				MusicPlayerMgr.PlaySoundID = self.PlaySoundID
			end
			self.CurPlaingMusicIndex = MusicPlayerMgr.CurPlayIndex
			DataReportUtil.ReportSystemFlowData("MusicFlow", tostring(2), tostring(MusicID))  --上传播放埋点数据
		else
			AudioUtil.StopSound(MusicPlayerMgr.PlaySoundID, FadeOutTime, nil)
			if _G.MountMgr:IsInRide() then
				local DelayID 
				local function DelayRecoverMountBgm()
					MusicPlayerMgr:RecoverMountBGM()
					_G.TimerMgr:CancelTimer(DelayID)
				end
				DelayID = _G.TimerMgr:AddTimer(nil, DelayRecoverMountBgm, 1, 0, 1)
			end	
			MusicPlayerMgr:RecoverBGM()
		end
		
		self:SetShowTips(State, false)
	elseif Type == 2 then
		self:UpdateTimeInfo(Time)
		self:UpdateMusicName(MusicName)

		MusicPlayerMgr.CurPlayTime = MusicPlayerMgr:GetMusicTime(MusicID)
		MusicPlayerMgr.CurPlayerPlayingMusicID = MusicID
		if self.CurPlayState == false then
			self:SetShowTips(true, false)
		elseif self.CurPlayState and IsByClick then
			self:SetShowTips(true, false)
		end

		self.CurPlayState = true
		MusicPlayerMgr:StopOtherBgm()
		if MusicPlayerMgr.PlaySoundID ~= nil then
			AudioUtil.StopSound(MusicPlayerMgr.PlaySoundID, FadeOutTime, nil)
			self.PlaySoundID = nil
			MusicPlayerMgr.PlaySoundID = nil
		end 

		--回想状态下不进行声音播放
		if not MusicPlayerMgr.ReCallState then
			self.PlaySoundID = AudioUtil.SyncLoadAndPlaySoundEvent(MajorEntityID, MusicFile)
			DataReportUtil.ReportSystemFlowData("MusicFlow", tostring(2), tostring(MusicID))  --上传播放埋点数据
			_G.UE.UAudioMgr:Get():PlayFadeInEffect(self.PlaySoundID, FadeInTime, FadeCurve)
			MusicPlayerMgr.PlaySoundID = self.PlaySoundID
		end
		self.CurPlaingMusicIndex = MusicPlayerMgr.CurPlayIndex
	end

	if self.CurPlayState then
		self.BtnPlayPauseState = PlayBtnStateIcon[2]
		_G.PWorldMgr:LocalUpdateDynData(MapDynType, MusicInID, 1)
	else
		self.BtnPlayPauseState = PlayBtnStateIcon[1]
		_G.PWorldMgr:LocalUpdateDynData(MapDynType, MusicInID, 0)
	end

	self.PlayEffState = self.CurPlayState
	MusicPlayerMgr.PlayerPlayState = self.CurPlayState
	_G.EventMgr:SendEvent(EventID.UpdateMusicItemState)
end

--PlayType 1为点击下方暂停播放按钮播放， 2为点击列表或自动切换播放或者点击下方上箭头 下箭头播放
function MusicPlayerMainPanelVM:PlayMusic(PlayType, IsClick)
	MusicPlayerMgr.CurPlayingList = MusicPlayerMgr.CurPlayListIDInfo
	local CurPlayListIndex
	if IsClick then
		CurPlayListIndex = MusicPlayerMgr.CurPlayListIndex
	else
		CurPlayListIndex = MusicPlayerMgr.CurPlayingListIndex
	end
	local CurPlayListInfo = MusicPlayerMgr.AllPlayListInfo and MusicPlayerMgr.AllPlayListInfo[CurPlayListIndex] or {}
	local MusicID = CurPlayListInfo.MusicID and CurPlayListInfo.MusicID[MusicPlayerMgr.CurPlayIndex] or 0
	if not MusicID or MusicID == 0 then
		FLOG_WARNING("MusicPlayerMainPanelVM:PlayMusic MusicID = nil")
		return
	end

	if PlayType == 1 then
		self:UpdatePlayState(PlayType, IsClick)
		if self.CurPlayState then
			MusicPlayerMgr:PlayPlayerMusic(MusicID)
		else
			MusicPlayerMgr:StopCurPlayerMusic()
		end
	elseif PlayType == 2 then
		self:UpdatePlayState(PlayType, IsClick)
		MusicPlayerMgr:StopCurPlayerMusic()
		MusicPlayerMgr:PlayPlayerMusic(MusicID)
	end

	if MusicPlayerMgr.IsStopTips then
		self.IsAutoPlay = false
		MusicPlayerMgr.IsStopTips = false
		return
	end

	if self.IsAutoPlay then
		self:SetShowTips(true, self.IsAutoPlay)
		self.IsAutoPlay = false
	end
end

function MusicPlayerMainPanelVM:PlayMusicByPlayMode(IsLast, IsAuto)
	local IsAutoPlay = IsAuto or false
	self.IsAutoPlay = IsAutoPlay
	local Mode = MusicPlayerMgr.CurPlayMode
	local CurPlayIndex = MusicPlayerMgr.CurPlayIndex 
	local ListInfo = MusicPlayerMgr.AllPlayListInfo and MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayingListIndex]
	local MusicInfoLen = ListInfo and ListInfo.MusicID and #ListInfo.MusicID or 0
	if Mode == 1 then
		if IsLast then
			MusicPlayerMgr.CurPlayIndex = CurPlayIndex - 1

			if MusicPlayerMgr.CurPlayIndex < 1 then
				MusicPlayerMgr.CurPlayIndex = MusicInfoLen
			end
		else
			local CurPlayIndex = MusicPlayerMgr.CurPlayIndex 
			if MusicInfoLen < 1 then
				FLOG_ERROR("MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayingListIndex].MusicID = nil")
				MusicInfoLen = 1
			end
		
			MusicPlayerMgr.CurPlayIndex = CurPlayIndex + 1
		
			if MusicPlayerMgr.CurPlayIndex > MusicInfoLen then
				MusicPlayerMgr.CurPlayIndex = 1
			end
		end
	elseif Mode == 2 then
		if IsAutoPlay then
			self.PlayType = 2
			MusicPlayerMgr.CurPlayIndex = MusicPlayerMgr.CurPlayIndex
		else
			if IsLast then
				MusicPlayerMgr.CurPlayIndex = CurPlayIndex - 1
	
				if MusicPlayerMgr.CurPlayIndex < 1 then
					MusicPlayerMgr.CurPlayIndex = MusicInfoLen
				end
			else		
				MusicPlayerMgr.CurPlayIndex = CurPlayIndex + 1
			
				if MusicPlayerMgr.CurPlayIndex > MusicInfoLen then
					MusicPlayerMgr.CurPlayIndex = 1
				end
			end
		end
	elseif Mode == 3 then
		local RandomMax = MusicInfoLen or 1
		local Index = math.random(1, RandomMax)
		if Index == MusicPlayerMgr.CurPlayIndex then 
			local Add = math.random(1, RandomMax)
			Index = Index + Add
			if Index > MusicInfoLen then
				Index = 1
			end
		end
		MusicPlayerMgr.CurPlayIndex = Index
	end
end

function MusicPlayerMainPanelVM:StopPlayMusic()
	AudioUtil.StopSound(MusicPlayerMgr.PlaySoundID, FadeOutTime, nil)
end

function MusicPlayerMainPanelVM:RecoverCurPlayMusic(NewPrecent)
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local MusicID = MusicPlayerMgr.CurPlayerPlayingMusicID
	local MusicFile = MusicPlayerCfg:FindCfgByKey(MusicID).MusicFile
	self.PlaySoundID = AudioUtil.SyncLoadAndPlaySoundEvent(MajorEntityID, MusicFile, true)
	_G.UE.UAudioMgr:Get():PlayFadeInEffect(self.PlaySoundID, FadeInTime, FadeCurve)
	MusicPlayerMgr.PlaySoundID = self.PlaySoundID
	AudioUtil.SeekOnEventPercent(MusicFile, self.PlaySoundID, NewPrecent, MajorEntityID)
end

function MusicPlayerMainPanelVM:SetTitle()
	if MusicPlayerMgr.IsInHotel and not MusicPlayerMgr.EditState then
		self.Title = LSTR(1190023) --管弦乐琴设置
	elseif MusicPlayerMgr.EditState then
		self.Title = LSTR(1190012) --编辑管弦乐琴播放列表
	else
		self.Title = LSTR(1190011) ----管弦乐琴播放列表
	end
end

function MusicPlayerMainPanelVM:InitPlayModeInfo(PlayMode)
	local MusicList = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayListIndex].MusicID
	local Icon
	if MusicList == nil or #MusicList == 0 then
		Icon = CirculateBtnStateOffIcon[PlayMode]
	else
		Icon = CirculateBtnStateOnIcon[PlayMode]
	end

	self.BtnCirculateState = Icon
end

function MusicPlayerMainPanelVM:UpdatePlaymodeState()
	local PlayMode = MusicPlayerMgr.CurPlayMode
	PlayMode = PlayMode + 1
	if PlayMode > 3 then
		PlayMode = 1
	end
	MusicPlayerMgr.CurPlayMode = PlayMode

	if PlayMode == 1 then
		self.BtnCirculateState = CirculateBtnStateOnIcon[1]
	elseif PlayMode == 2 then
		self.BtnCirculateState = CirculateBtnStateOnIcon[2]
	elseif PlayMode == 3 then
		self.BtnCirculateState = CirculateBtnStateOnIcon[3]
	end
end

function MusicPlayerMainPanelVM:UpdateTimeInfo(Time)
	if Time == "" then
		self.TimeText = ""
		return
	end
	self.TimeText = LocalizationUtil.GetCountdownTimeForShortTime(math.floor(Time), "mm:ss")
end

function MusicPlayerMainPanelVM:UpdateConfirmBtnState()
	MusicPlayerMgr:PlayListIsChanged()
end

function MusicPlayerMainPanelVM:UpdateBtnOpenListInfo()

end

function MusicPlayerMainPanelVM:SetPercent(Value)
	self.Percent = Value
end

function MusicPlayerMainPanelVM:SetTimeTextAndBar(RemainingTime, Percent)
	self.Percent = 1
	self.TimeText = LocalizationUtil.GetCountdownTimeForShortTime(math.floor(RemainingTime), "mm:ss")

	if RemainingTime <= 0 then
		self.PercentScale = UE.FVector2D(1, 1)
		return
	else
		self.PercentScale = UE.FVector2D(Percent, 1)
	end
end

function MusicPlayerMainPanelVM:SetPercentScale(Value)
	self.Percent = 1
	self.PercentScale = UE.FVector2D(Value, 1)
end

function MusicPlayerMainPanelVM:SetBtnState(State, IsNil)
	self.CurListIsNil = IsNil
	if not MusicPlayerMgr.PlayerPlayState then
		if State then
			self.BtnPlayPauseState = PlayBtnStateIcon[1]
			self.BtnNextState = BtnNextStateIcon[1]
			self.BtnPreviousState = BtnPreviousStateIcon[1]
	
			if MusicPlayerMgr.CurPlayMode == 1 then
				self.BtnCirculateState = CirculateBtnStateOnIcon[1]
			elseif MusicPlayerMgr.CurPlayMode == 2 then
				self.BtnCirculateState = CirculateBtnStateOnIcon[2]
			else
				self.BtnCirculateState = CirculateBtnStateOnIcon[3]
			end
		else
			if MusicPlayerMgr.CurPlayerPlayingMusicID == nil and self.CurListIsNil then
				self.BtnPlayPauseState = PlayBtnStateIcon[3]
				self.BtnNextState = BtnNextStateIcon[2]
				self.BtnPreviousState = BtnPreviousStateIcon[2]
			
				if MusicPlayerMgr.CurPlayMode == 1 then
					self.BtnCirculateState = CirculateBtnStateOffIcon[1]
				elseif MusicPlayerMgr.CurPlayMode == 2 then
					self.BtnCirculateState = CirculateBtnStateOffIcon[2]
				else
					self.BtnCirculateState = CirculateBtnStateOffIcon[3]
				end
			end
		end
	else
		self.BtnPlayPauseState = PlayBtnStateIcon[2]
	end
	

	-- if MusicPlayerMgr.PlayerPlayState then
	-- 	self.BtnPlayPauseState = PlayBtnStateIcon[2]
	-- else
	-- 	self.BtnPlayPauseState = PlayBtnStateIcon[1]
	-- end
	-- if MusicPlayerMgr.PlayerPlayState and not IsNil then
	-- 	self.BtnPlayPauseState = PlayBtnStateIcon[2]
	-- elseif MusicPlayerMgr.PlayerPlayState and IsNil then
	-- 	self.BtnPlayPauseState = PlayBtnStateIcon[3]
	-- end
end

--临时处理
function MusicPlayerMainPanelVM:GoOnPlay()
	if MusicPlayerMgr.PlayerPlayState then
		MusicPlayerMgr:StopOtherBgm()
		if self.PlaySoundID ~= nil then
			AudioUtil.StopSound(self.PlaySoundID, FadeOutTime, nil)
			self.PlaySoundID = nil
		end 

		local MajorEntityID = MajorUtil.GetMajorEntityID()
		local MusicID = MusicPlayerMgr.CurPlayerPlayingMusicID
		local MusicFile = MusicPlayerCfg:FindCfgByKey(MusicID).MusicFile
		local Time = MusicPlayerCfg:FindCfgByKey(MusicID).Time
		self:UpdateTimeInfo(Time)
		local MusicName = MusicPlayerCfg:FindCfgByKey(MusicID).MusicName
		self:UpdateMusicName(MusicName)
		MusicPlayerMgr.CurPlayTime = MusicPlayerMgr:GetMusicTime(MusicID)
		MusicPlayerMgr.CurPlayerPlayingMusicID = MusicID
		self.PlaySoundID = AudioUtil.SyncLoadAndPlaySoundEvent(MajorEntityID, MusicFile)
		_G.UE.UAudioMgr:Get():PlayFadeInEffect(self.PlaySoundID, FadeInTime, FadeCurve)
		MusicPlayerMgr.PlaySoundID = self.PlaySoundID
	end
end

function MusicPlayerMainPanelVM:PlayMusicTest(MusicID, IsPlay)
	MusicPlayerMgr:StopOtherBgm()
	if self.PlayTestSoundID ~= nil then
		AudioUtil.StopSound(self.PlayTestSoundID, FadeOutTime, nil)
		self.PlayTestSoundID = nil
	end
	if self.PlaySoundID ~= nil then
		AudioUtil.StopSound(self.PlaySoundID, FadeOutTime, nil)
		MusicPlayerMgr:StopCurPlayerMusic()
	end
	if IsPlay and MusicID ~= nil then
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		local MusicFile = MusicPlayerCfg:FindCfgByKey(MusicID).MusicFile
		self.PlayTestSoundID = AudioUtil.SyncLoadAndPlaySoundEvent(MajorEntityID, MusicFile)
		_G.UE.UAudioMgr:Get():PlayFadeInEffect(self.PlaySoundID, FadeInTime, FadeCurve)
	end
end

function MusicPlayerMainPanelVM:StopPlayTestMusic()
	if self.PlayTestSoundID then
		AudioUtil.StopSound(self.PlayTestSoundID, FadeOutTime, nil)
		self.PlayTestSoundID = nil
	end
end

function MusicPlayerMainPanelVM:SetBtnSaveState(State)
	self.BtnSaveState = State
end


function MusicPlayerMainPanelVM:SetShowTips(State, IsAuToPlay)
	if not MusicPlayerMgr.IsInHotel or not MusicPlayerMgr.CurPlayerPlayingMusicID then
		return
	end

	local MusicName = self.MusicName

	if State and not IsAuToPlay then
		_G.MsgTipsUtil.ShowTipsByID(156012, nil, MusicName)--开始播放
	elseif not State then
		_G.MsgTipsUtil.ShowTipsByID(156013, nil, MusicName)--停止了XX的播放
	elseif State and IsAuToPlay then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.MusicPlay, nil, MusicName)--播放了
	end
end

function MusicPlayerMainPanelVM:Clear()
	self.DropListInfo = nil

end

return MusicPlayerMainPanelVM