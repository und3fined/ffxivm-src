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
local MusicAtlasRevertListItemVM = require("Game/MusicAtlas/View/Item/MusicAtlasRevertListItemVM")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")


local LSTR = _G.LSTR
local FadeOutTime = 2000
local FadeInTime = 2
local FadeCurve = _G.UE.AkCurveInterpolation.AkCurveInterpolation_Linear

---@class MusicAtlasRevertPanelVM : UIViewModel
local MusicAtlasRevertPanelVM = LuaClass(UIViewModel)

---Ctor
function MusicAtlasRevertPanelVM:Ctor()
	self.MusicAtlasList = UIBindableList.New(MusicAtlasRevertListItemVM)
	self.Subtitle = nil
	self.TimeText = nil
	self.MusicName = nil
	self.Percent = nil
	self.PanelEmptyVisible = nil
	self.TableViewListVisible = nil
	self.AllTypeList = nil
	self.AllUnLockList = {}
end

function MusicAtlasRevertPanelVM:OnInit()

end

function MusicAtlasRevertPanelVM:OnBegin()

end

function MusicAtlasRevertPanelVM:OnEnd()

end

function MusicAtlasRevertPanelVM:UpdateItemInfo(List)
	if List == nil then
		return
	end

	self.PanelEmptyVisible = #List <= 0
	self.TableViewListVisible = #List > 0
	self.MusicAtlasList:UpdateByValues(List)
end

function MusicAtlasRevertPanelVM:SetTitle()
	 return self.TitleName
end

function MusicAtlasRevertPanelVM:SetSubTitle(Type, IsSearch)
	if IsSearch then
		self.Subtitle = ""
		return
	end
	local Name = MusicTypeCfg:FindCfgByKey(Type).Name
	self.Subtitle = Name
end

function MusicAtlasRevertPanelVM:SetTimeTextAndBar(CurTime, AllTime)
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

function MusicAtlasRevertPanelVM:PlayChoseMusic(MusicID, Percent)
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local Cfg = MusicPlayerCfg:FindCfgByKey(MusicID)
	if Cfg == nil then
		FLOG_ERROR("MusicID Cfg = nil ")
		return
	end
	local MusicFile = Cfg.MusicFile
	MusicPlayerMgr:StopOtherBgm()
	self.PlaySoundID = AudioUtil.SyncLoadAndPlaySoundEvent(MajorEntityID, MusicFile, true)
	_G.UE.UAudioMgr:Get():PlayFadeInEffect(self.PlaySoundID, FadeInTime, FadeCurve)
	MusicPlayerMgr.RevertPlaySoundID = self.PlaySoundID
	self:SetMusicSlideByPrecent(Percent)
	if MusicPlayerMgr:GetMajorIdleStat() then
		--当前只是播放 思考 情感动作
		_G.EmotionMgr:PlayEmotionID(39, false, MajorEntityID)
	end
end

function MusicAtlasRevertPanelVM:StopPlayChoseMusic()
	AudioUtil.StopSound(self.PlaySoundID, FadeOutTime, FadeCurve)
	self.PlaySoundID = nil
end

function MusicAtlasRevertPanelVM:UpdateBtnMusicName(MusicID)
	local MusicName = MusicPlayerCfg:FindCfgByKey(MusicID).MusicName
	self.MusicName = MusicName
end

function MusicAtlasRevertPanelVM:UpdateChosedMusicName(MusicID)
	local MusicName = MusicPlayerCfg:FindCfgByKey(MusicID).MusicName
	self.ChosedMusicName = MusicName
	self.AtlasItemID = self:GetAtlasItemID(MusicID)
end

function MusicAtlasRevertPanelVM:SetMusicSlideByPrecent(Precent)
	local NewPrecent = Precent or 0
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local MusicID = MusicPlayerMgr.CurPlayingRevertID
	local MusicFile = MusicPlayerCfg:FindCfgByKey(MusicID).MusicFile
	AudioUtil.SeekOnEventPercent(MusicFile, self.PlaySoundID, NewPrecent, MajorEntityID)
	--改变播放进度后需要更新MGR计时器的时间
	local TotalTime = MusicPlayerMgr:GetMusicTime(MusicID)
	local CurTime = NewPrecent * TotalTime
	local StartTime = _G.TimeUtil:GetServerTime()
	--改变进度后 开始播放时间需要更新
	MusicPlayerMgr.RevertStartTime = StartTime - CurTime
	self:SetTimeTextAndBar(CurTime, TotalTime)
	MusicPlayerMgr.CurRevertPlayTime = CurTime
end

function MusicAtlasRevertPanelVM:ShowEmptyPanel(Value)
	self.PanelEmptyVisible = Value
	self.BtnPage01Visible = not Value
	self.BtnPage02Visible = not Value
	if Value then
		self.BtnMusicNameVisible = false
		self.JumpBtnEnabled = false
	end
end

function MusicAtlasRevertPanelVM:GetAtlasItemID(MusicID)
	local ItemID = MusicPlayerCfg:FindCfgByKey(MusicID).ItemID
	return ItemID
end

function MusicAtlasRevertPanelVM:MatchMusic(Input)
	local matches = {}
	local Params = tonumber(Input)
	if Params ~= nil then
		for Index, Info in pairs(self.AllTypeList) do
			--待优化
			local UnLockList = self:GetAllUnLockList(Index, Info.Type)
			for i, j in pairs(UnLockList) do
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
		
		for Index, Info in pairs(self.AllTypeList) do
			local UnLockList = self:GetAllUnLockList(Index, Info.Type)
			for i, j in pairs(UnLockList) do
				if j.Name:find(Input) then
					j.SearchID = i
					table.insert(matches, j)
				end
			end
		end
	end

	return matches
end

function MusicAtlasRevertPanelVM:GetUnLockAtlas(List)
	local NewList = {}
	for _, Info in ipairs(List) do
		if Info.IsUnLock then
			table.insert(NewList, Info)
		end
	end

	return NewList
end

function MusicAtlasRevertPanelVM:GetAllUnLockList(Index, Type)
	if self.AllUnLockList[Index] then
		return self.AllUnLockList[Index]
	else
		local CurAtlasList = MusicPlayerMgr:GetAtlasInfoByType(Type)
		local UnLockList = self:GetUnLockAtlas(CurAtlasList)
		self.AllUnLockList[Index] = UnLockList
		return UnLockList
	end
end

--获取搜索时选中的乐曲ID所属的TypeIndex 和 MusicIndex
function MusicAtlasRevertPanelVM:GetSearchMusicIDInfo(MusicID)
	for TypeIndex, MusicList in ipairs(self.AllUnLockList) do
		for MusicIndex, Info in ipairs(MusicList) do
			if Info.MusicID == MusicID then
				return TypeIndex, MusicIndex
			end
		end
	end
end

return MusicAtlasRevertPanelVM