--
-- Author: ds_yangyumian
-- Date: 2023-12-08 10:00
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MusicPlayerMgr = require("Game/MusicPlayer/MusicPlayerMgr")
local MusicPlayerCfg = require("TableCfg/MusicPlayerCfg")
local MusicTypeCfg = require("TableCfg/MusicTypeCfg")
local MusicAtlasMainItemVM = require("Game/MusicAtlas/View/Item/MusicAtlasMainItemVM")
local MajorUtil = require("Utils/MajorUtil")
local UAudioMgr = _G.UE.UAudioMgr
local AudioUtil = require("Utils/AudioUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")


local LSTR = _G.LSTR
local FadeOutTime = 2000
local FadeInTime = 2
local FadeCurve = _G.UE.AkCurveInterpolation.AkCurveInterpolation_Linear

---@class MusicAtlasMainVM : UIViewModel
local MusicAtlasMainVM = LuaClass(UIViewModel)

---Ctor
function MusicAtlasMainVM:Ctor()
	self.CurMusicAtlasList = UIBindableList.New(MusicAtlasMainItemVM)
	self.PageText = nil
	self.MaxPage = nil
	self.IsMinPage = false
	self.IsMaxPage = false
	self.IsMinPageImg = true
	self.IsMaxPageImg = true
	self.CurPage = 1
	self.MusicName = nil
	self.CurPageAtlasList = nil
	self.TimeText = nil
	self.Percent = nil
	self.BtnMusicNameVisible = false
	self.BtnMusicNameText = nil
	self.Subtitle = nil
	self.CurPlayMusicPage = nil
	self.CurPlayMusicIndex = nil
	self.CurPlayTypeIndex = nil
	self.PanelMaskVisible = false
	self.ChosedMusicName = nil
	self.PanelEmptyVisible = false
	self.BtnPage01Visible = true
	self.BtnPage02Visible = true
	self.GatherText = nil
	self.GatherPercent = nil
	self.AllAtalsNum = nil
	self.AllUnlockAtalsNum = nil
	self.JumpBtnEnabled = false
	self.AtlasItemID = nil
	self.ImgPage01State = false
	self.ImgPage03State = false
	self.TitleName = nil
	self.IsPlaying = false
	self.PanelRevertVisible = nil
	self.ResID = nil
	self.Source = 1
end

function MusicAtlasMainVM:OnInit()

end

function MusicAtlasMainVM:OnBegin()

end

function MusicAtlasMainVM:OnEnd()

end

function MusicAtlasMainVM:UpdateItemInfo(List, CurPage)
	if List == nil then
		return
	end

	local NewList = {}
	for i = 1, #List do
		if math.ceil(i / 10) == CurPage then
			table.insert(NewList, List[i])
		end
	end

	self.CurPageAtlasList = NewList
	self.CurMusicAtlasList:UpdateByValues(NewList)
end

function MusicAtlasMainVM:SetPageInfo(CurPage, MaxPage)
	self:UpdatePageInfo(CurPage, MaxPage)
end

function MusicAtlasMainVM:UpdatePageInfo(CurPage,MaxPage)
	self.PageText = string.format("%d/%d", CurPage, MaxPage)

	if CurPage == 1 and MaxPage == 1 then
		self.IsMinPage = true
		self.IsMaxPage = true
		self.IsMinPageImg = false
		self.IsMaxPageImg = false
		self.BtnPage01Visible = false
		self.BtnPage02Visible = false
		return
	end

	if CurPage <= 1 then
		self.IsMinPage = true
		self.IsMaxPage = false
		self.IsMinPageImg = false
		self.BtnPage01Visible = false
		self.IsMaxPageImg = true
		self.BtnPage02Visible = true
	elseif CurPage >= MaxPage then
		self.IsMinPage = false
		self.IsMaxPage = true
		self.IsMinPageImg = true
		self.BtnPage01Visible = true
		self.IsMaxPageImg = false
		self.BtnPage02Visible = false
	else
		self.IsMinPageImg = true
		self.IsMaxPageImg = true
		self.BtnPage01Visible = true
		self.BtnPage02Visible = true
	end
end

function MusicAtlasMainVM:SetTitle(OpenType)
	 if OpenType == 1 then
		self.TitleName = LSTR(1170009)
	 else
		self.TitleName = LSTR(1170010)
	 end
	 return self.TitleName
end

function MusicAtlasMainVM:SetSubTitle(Type, IsSearch)
	if IsSearch then
		self.Subtitle = ""
		return
	end
	local Name = MusicTypeCfg:FindCfgByKey(Type).Name
	self.Subtitle = Name
end

function MusicAtlasMainVM:SetTimeTextAndBar(CurTime, AllTime)
	self.CurTime = LocalizationUtil.GetCountdownTimeForShortTime(math.floor(CurTime), "mm:ss")
	self.TotalTime = LocalizationUtil.GetCountdownTimeForShortTime(math.floor(AllTime), "mm:ss")

	self.TimeText = string.format("%s/%s", self.CurTime, self.TotalTime)

	if CurTime >= AllTime then
		self.Percent = 1
		return
	else
		self.Percent = CurTime / AllTime
	end
end

function MusicAtlasMainVM:PlayChoseMusic(MusicID, Percent)
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local Cfg = MusicPlayerCfg:FindCfgByKey(MusicID)
	if Cfg == nil then
		FLOG_ERROR("MusicID Cfg = nil ")
		return
	end
	local MusicFile = Cfg.MusicFile
	MusicPlayerMgr:StopOtherBgm()
	--临时防止重叠
	if MusicPlayerMgr.PlaySoundID ~= nil then
		AudioUtil.StopSound(MusicPlayerMgr.PlaySoundID)
	end

	if MusicPlayerMgr.AtlasPlaySoundID ~= nil then
		AudioUtil.StopSound(MusicPlayerMgr.AtlasPlaySoundID)
	end

	self.PlaySoundID = AudioUtil.SyncLoadAndPlaySoundEvent(MajorEntityID, MusicFile)
	_G.UE.UAudioMgr:Get():PlayFadeInEffect(self.PlaySoundID, FadeInTime, FadeCurve)
	MusicPlayerMgr.AtlasPlaySoundID = self.PlaySoundID
	self.IsPlaying = true
	self:SetMusicSlideByPrecent(Percent)
end

function MusicAtlasMainVM:StopPlayChoseMusic()
	-- AudioUtil.StopSound(self.PlaySoundID, FadeOutTime, FadeCurve)
	-- self.IsPlaying = false
	-- local function DelayPlay()
	-- 	if self.IsPlaying then
	-- 		return
	-- 	end

	-- 	if _G.MountMgr:IsInRide() then
	-- 		MusicPlayerMgr:RecoverMountBGM()
	-- 	else
	-- 		local CurrMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
	-- 		if CurrMapEditCfg then
	-- 			local MapTableCfg = _G.PWorldMgr:GetMapTableCfg(CurrMapEditCfg.MapID)
	-- 			if MapTableCfg then
	-- 				_G.PWorldMgr:SwitchMapDefaultBGMusic(MapTableCfg.BGMusic)
	-- 			end
	-- 		end
	-- 	end

	-- end
	-- self.DelayTimerID = _G.TimerMgr:AddTimer(nil, DelayPlay, 1.5)
end

function MusicAtlasMainVM:UpdateBtnMusicName(Info)
	self.BtnMusicNameVisible = not Info.IsShow
	self.JumpBtnEnabled = not Info.IsShow
	if not Info.IsShow then
		local MusicID = Info.CurPlayMusicID
		local MusicName = MusicPlayerCfg:FindCfgByKey(MusicID).MusicName
		self.MusicName = MusicName
	end
end

function MusicAtlasMainVM:UpdateChosedMusicName(MusicID)
	local MusicName = MusicPlayerCfg:FindCfgByKey(MusicID).MusicName
	self.ChosedMusicName = MusicName
	self.AtlasItemID = self:GetAtlasItemID(MusicID)
	self.ResID = self.AtlasItemID
end

function MusicAtlasMainVM:SetMusicSlideByPrecent(Precent)
	local NewPrecent = Precent or 0
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local MusicID = MusicPlayerMgr.CurChoseAtlasID
	local MusicFile = MusicPlayerCfg:FindCfgByKey(MusicID).MusicFile
	AudioUtil.SeekOnEventPercent(MusicFile, self.PlaySoundID, NewPrecent, MajorEntityID)
	--改变播放进度后需要更新MGR计时器的时间
	local TotalTime = MusicPlayerMgr:GetMusicTime(MusicID)
	local CurTime = NewPrecent * TotalTime
	self:SetTimeTextAndBar(CurTime, TotalTime)
	MusicPlayerMgr.CurAtalsPlayTime = CurTime
end

function MusicAtlasMainVM:SetMaskVisible(Value)
	self.PanelMaskVisible = Value
end

function MusicAtlasMainVM:SetCurPlayMusicPageAndIndex(Info)
	self.CurPlayMusicPage = Info.Page
	self.CurPlayMusicIndex = Info.Index
	self.CurPlayTypeIndex = Info.CurTypeIndex
end

function MusicAtlasMainVM:ShowEmptyPanel(Value)
	self.PanelEmptyVisible = Value
	self.BtnPage01Visible = not Value
	self.BtnPage02Visible = not Value
	if Value then
		self.BtnMusicNameVisible = false
		self.JumpBtnEnabled = false
	end
end

function MusicAtlasMainVM:ShowGatherPercent(TotalNum)
	self.AllAtalsNum = TotalNum
	self.AllUnlockAtalsNum = math.min(#MusicPlayerMgr.AllMusicInfo, TotalNum)
	self.GatherText = string.format("%s:%d/%d", LSTR(1170003), self.AllUnlockAtalsNum, self.AllAtalsNum)
	self.GatherPercent = self.AllUnlockAtalsNum / self.AllAtalsNum
end

function MusicAtlasMainVM:IsExceedLimit(Precent)
	local IsExceed = false
	local MusicID = MusicPlayerMgr.CurChoseAtlasID
	local TotalTime = MusicPlayerMgr:GetMusicTime(MusicID)
	local CurTime = Precent * TotalTime
	if CurTime >= 30 then
		IsExceed = true
	end

	return IsExceed
end

function MusicAtlasMainVM:GetAtlasItemID(MusicID)
	local ItemID = MusicPlayerCfg:FindCfgByKey(MusicID).ItemID
	return ItemID
end

function MusicAtlasMainVM:MatchMusic(Input)
	local matches = {}
	local Params = tonumber(Input)
	if Params ~= nil then
		for _, MusicList in pairs(MusicPlayerMgr.AllTypeMusic) do
			for i, j in pairs(MusicList) do
				if j.Number == Params then
					j.SearchID = i
					table.insert(matches, j)
				end
			end
		end
	else
		_G.JudgeSearchMgr:QueryTextIsLegal(Input, function( IsLegal )
			if not IsLegal then
				return
			end
		end)
		
		for _, MusicList in pairs(MusicPlayerMgr.AllTypeMusic) do
			for i, j in pairs(MusicList) do
				if j.Name:find(Input) then
					j.SearchID = i
					table.insert(matches, j)
				end
			end
		end
	end


	return matches
end

return MusicAtlasMainVM