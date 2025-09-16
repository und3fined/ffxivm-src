---
--- Author: Administrator
--- DateTime: 2023-12-08 11:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MusicPlayerCfg = require("TableCfg/MusicPlayerCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MusicPlayerMainPaneVM = require("Game/MusicPlayer/View/MusicPlayerMainPanelVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetButtonBrush = require("Binder/UIBinderSetButtonBrush")
local MusicPlayerMgr = require("Game/MusicPlayer/MusicPlayerMgr")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local EventMgr = require("Event/EventMgr")
local UIBinderCanvasSlotSetScale = require ("Binder/UIBinderCanvasSlotSetScale")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsID = require("Define/MsgTipsID")
local RichTextUtil = require("Utils/RichTextUtil")


local LSTR = _G.LSTR

--测试用
--local TestTime = 0

---@class MusicPlayerMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtmOpenList UFButton
---@field BtnCancel UFButton
---@field BtnCirculate UFButton
---@field BtnColse UFButton
---@field BtnEditList UFButton
---@field BtnEmpty UFButton
---@field BtnInput UFButton
---@field BtnNext UFButton
---@field BtnPlayPause UFButton
---@field BtnPrevious UFButton
---@field BtnSave UFButton
---@field CancelPanel UFCanvasPanel
---@field ClockEmpty CommBackpackEmptyView
---@field EFFPanel UFCanvasPanel
---@field EditListPanel UFCanvasPanel
---@field ImgArrow UFImage
---@field ImgArrow_1 UFImage
---@field ImgNote1 UFImage
---@field ImgNote2 UFImage
---@field ImgNote3 UFImage
---@field ImgNote4 UFImage
---@field ImgNote5 UFImage
---@field ImgNote6 UFImage
---@field ImgPlayBg UFImage
---@field ImgSaveAsh UFImage
---@field ImgSaveBg UFImage
---@field ImgStateBarL UFImage
---@field ImgStateBarR UFImage
---@field InputBox CommInputBoxView
---@field InputPanel UFCanvasPanel
---@field ListPanel MusicPlayerListPanelView
---@field MI_DX_ADD_Pariticle_MusicPlayer_4 UImage
---@field MI_DX_Page_MusicPlayer_1 UImage
---@field MainPlayerPanel UFCanvasPanel
---@field MusicDropDownListNew CommDropDownListView
---@field NoMusicPanelNew UFCanvasPanel
---@field NoteLPanel UFCanvasPanel
---@field NoteRPanel UFCanvasPanel
---@field OpenListPanel UFCanvasPanel
---@field PlayBarPanel UFCanvasPanel
---@field PlayPanel UFCanvasPanel
---@field PlayerPanel UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field PopUpBG1 CommonPopUpBGView
---@field ProbarBlue UProgressBar
---@field ProbarPanel UFCanvasPanel
---@field SavePanel UFCanvasPanel
---@field T_DX_Pariticle_MusicPlayer_1 UUIParticleEmitter
---@field T_DX_Pariticle_MusicPlayer_2 UUIParticleEmitter
---@field T_DX_Pariticle_MusicPlayer_3 UUIParticleEmitter
---@field TableViewList UTableView
---@field TextCancel UFTextBlock
---@field TextContent UFTextBlock
---@field TextEditList UFTextBlock
---@field TextMusicName UFTextBlock
---@field TextSave UFTextBlock
---@field TextSub UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---@field UI_MusicPlayer_Img_Bg1 UImage
---@field UI_MusicPlayer_Img_Bg2 UImage
---@field UI_MusicPlayer_Img_Bg3_a UImage
---@field UI_MusicPlayer_Img_Bg3_b UImage
---@field UI_MusicPlayer_Img_Bg5 UImage
---@field AnimClose UWidgetAnimation
---@field AnimExpand UWidgetAnimation
---@field AnimIn_1 UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut_1 UWidgetAnimation
---@field AnimPlayingLoop UWidgetAnimation
---@field AnimRefresh UWidgetAnimation
---@field AnimStop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicPlayerMainPanelView = LuaClass(UIView, true)

function MusicPlayerMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtmOpenList = nil
	--self.BtnCancel = nil
	--self.BtnCirculate = nil
	--self.BtnColse = nil
	--self.BtnEditList = nil
	--self.BtnEmpty = nil
	--self.BtnInput = nil
	--self.BtnNext = nil
	--self.BtnPlayPause = nil
	--self.BtnPrevious = nil
	--self.BtnSave = nil
	--self.CancelPanel = nil
	--self.ClockEmpty = nil
	--self.EFFPanel = nil
	--self.EditListPanel = nil
	--self.ImgArrow = nil
	--self.ImgArrow_1 = nil
	--self.ImgNote1 = nil
	--self.ImgNote2 = nil
	--self.ImgNote3 = nil
	--self.ImgNote4 = nil
	--self.ImgNote5 = nil
	--self.ImgNote6 = nil
	--self.ImgPlayBg = nil
	--self.ImgSaveAsh = nil
	--self.ImgSaveBg = nil
	--self.ImgStateBarL = nil
	--self.ImgStateBarR = nil
	--self.InputBox = nil
	--self.InputPanel = nil
	--self.ListPanel = nil
	--self.MI_DX_ADD_Pariticle_MusicPlayer_4 = nil
	--self.MI_DX_Page_MusicPlayer_1 = nil
	--self.MainPlayerPanel = nil
	--self.MusicDropDownListNew = nil
	--self.NoMusicPanelNew = nil
	--self.NoteLPanel = nil
	--self.NoteRPanel = nil
	--self.OpenListPanel = nil
	--self.PlayBarPanel = nil
	--self.PlayPanel = nil
	--self.PlayerPanel = nil
	--self.PopUpBG = nil
	--self.PopUpBG1 = nil
	--self.ProbarBlue = nil
	--self.ProbarPanel = nil
	--self.SavePanel = nil
	--self.T_DX_Pariticle_MusicPlayer_1 = nil
	--self.T_DX_Pariticle_MusicPlayer_2 = nil
	--self.T_DX_Pariticle_MusicPlayer_3 = nil
	--self.TableViewList = nil
	--self.TextCancel = nil
	--self.TextContent = nil
	--self.TextEditList = nil
	--self.TextMusicName = nil
	--self.TextSave = nil
	--self.TextSub = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--self.UI_MusicPlayer_Img_Bg1 = nil
	--self.UI_MusicPlayer_Img_Bg2 = nil
	--self.UI_MusicPlayer_Img_Bg3_a = nil
	--self.UI_MusicPlayer_Img_Bg3_b = nil
	--self.UI_MusicPlayer_Img_Bg5 = nil
	--self.AnimClose = nil
	--self.AnimExpand = nil
	--self.AnimIn_1 = nil
	--self.AnimLoop = nil
	--self.AnimOut_1 = nil
	--self.AnimPlayingLoop = nil
	--self.AnimRefresh = nil
	--self.AnimStop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicPlayerMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ClockEmpty)
	self:AddSubView(self.InputBox)
	self:AddSubView(self.ListPanel)
	self:AddSubView(self.MusicDropDownListNew)
	--self:AddSubView(self.PopUpBG)
	--self:AddSubView(self.PopUpBG1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicPlayerMainPanelView:OnInit()
	self.ViewModel = MusicPlayerMainPaneVM.New()
	self.MusicItemList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectChanged, true)
	self.Binders = {
		{ "CurMusicList", UIBinderUpdateBindableList.New(self, self.MusicItemList) },
		{ "MusicName", UIBinderSetText.New(self, self.TextMusicName) },
		{ "BtnPlayPauseState", UIBinderSetButtonBrush.New(self, self.BtnPlayPause) },
		{ "BtnCirculateState", UIBinderSetButtonBrush.New(self, self.BtnCirculate) },
		{ "Title", UIBinderSetText.New(self, self.TextTitle) },
		{ "TimeText", UIBinderSetText.New(self, self.TextTime) },	
		{ "PercentScale", UIBinderCanvasSlotSetScale.New(self, self.ProbarBlue)},
		{ "Percent", UIBinderSetPercent.New(self, self.ProbarBlue)},
		{ "OpenBtnText", UIBinderSetText.New(self, self.TextContent) },
		{ "BtnNextState", UIBinderSetButtonBrush.New(self, self.BtnNext) },
		{ "BtnPreviousState", UIBinderSetButtonBrush.New(self, self.BtnPrevious) },
		{ "BtnSaveState", UIBinderSetIsVisible.New(self, self.ImgSaveBg) },
		{ "PlayEffState", UIBinderValueChangedCallback.New(self, nil, self.OnPlayStateChange) },
	}

	--播放方式 
	self.PlayType = 1
	self.EditState = false
	self.IsCanClick = false
end

function MusicPlayerMainPanelView:OnDestroy()

end

function MusicPlayerMainPanelView:OnShow()
	if self.Params and self.Params.IsInHotel then
		self.IsInHotel = self.Params.IsInHotel
		UIUtil.SetIsVisible(self.TextSub, true)
		self.TextSub:SetText(LSTR(1190024)) --播放列表
		self.ViewModel:SetTitle()
		self:SetInputPanelAndDropList()
	else
		self.IsInHotel = false
		UIUtil.SetIsVisible(self.TextSub, false)
		self.ViewModel:SetTitle()
		self:SetInputPanelAndDropList(true)
	end
	self.TextEditList:SetText(LSTR(1190015))--编辑列表
	local ContentText = RichTextUtil.GetText(LSTR(1190017), "#6C6964FF")
	self.ClockEmpty:SetTipsContent(ContentText)--播放列表中没有乐曲
	self.ClockEmpty:SetBtnText(LSTR(1190016))--添加乐曲
	self.TextSave:SetText(LSTR(1190021))--保存
	self.TextCancel:SetText(LSTR(1190001))--保存
	--MusicPlayerMgr:SendMsgGetUnLockList()
	self:PlayAnimation(self.AnimIn_1)
	--MusicPlayerMgr:SendMsgGetMusicList()
	MusicPlayerMgr.MusicPlayerIsShow = true
	UIUtil.SetIsVisible(self.ImgArrow_1, false)
	UIUtil.SetIsVisible(self.ListPanel, false)
	UIUtil.SetIsVisible(self.SavePanel, false)
	UIUtil.SetIsVisible(self.CancelPanel, false)
	UIUtil.SetIsVisible(self.OpenListPanel, false, true)
	UIUtil.SetIsVisible(self.EFFPanel, false)
	UIUtil.SetIsVisible(self.BtnEmpty, false, true)
	UIUtil.SetIsVisible(self.EditListPanel, true)
	
	self:UpdateMusicInfo()
	if MusicPlayerMgr.CurPlayerPlayingMusicID ~= nil then
		local Name = MusicPlayerCfg:FindCfgByKey(MusicPlayerMgr.CurPlayerPlayingMusicID).MusicName
		self.ViewModel:UpdateMusicName(Name)
	end

	--延迟防止误点击
	local function DelayGo()
		self.IsCanClick = true
	end
	self.DelayTimerID = _G.TimerMgr:AddTimer(nil, DelayGo, 0.5)
	--测试
	--self:UpdateMusicInfo()
end

function MusicPlayerMainPanelView:OnHide()
	self.IsCanClick = false
	self.ViewModel:Clear()
end

function MusicPlayerMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.MusicDropDownListNew, self.OnSelectionChangedDropDownList)
	UIUtil.AddOnClickedEvent(self, self.BtnColse, self.Close)
	UIUtil.AddOnClickedEvent(self, self.BtnPlayPause, self.PlayCurMusic)
	UIUtil.AddOnClickedEvent(self, self.BtnCirculate, self.ChangedPlayMode)
	UIUtil.AddOnClickedEvent(self, self.BtnNext, self.PlayNextMusic)
	UIUtil.AddOnClickedEvent(self, self.BtnPrevious, self.PlayLastMusic)
	UIUtil.AddOnClickedEvent(self, self.ClockEmpty.Btn, self.ClickBtnAdd)
	UIUtil.AddOnClickedEvent(self, self.BtnEditList, self.ClickBtnEdit)
	UIUtil.AddOnClickedEvent(self, self.BtmOpenList, self.ClickBtnOpenList)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.ClickBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.ClickBtnSave)
	UIUtil.AddOnTextChangedEvent(self, self.InputBox.InputText, self.OnTextChangedInput)
	UIUtil.AddOnClickedEvent(self, self.BtnEmpty, self.ClickBtnEmpty)
end

function MusicPlayerMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateMusicInfo, self.UpdateMusicInfo)
	self:RegisterGameEvent(EventID.RightListChose, self.UpdateItemBtnState)
	self:RegisterGameEvent(EventID.UpdateEditMusicInfo, self.UpdateEditMusicInfo)
	self:RegisterGameEvent(EventID.UpdateInfoAfterSave, self.UpdateAfterSave)
	self:RegisterGameEvent(EventID.UpdatePlayerState, self.SetTimeTextAndBar)
	self:RegisterGameEvent(EventID.ClickDrop, self.SetBtnEmptyState)
	self:RegisterGameEvent(EventID.UpdateCanSaveState, self.SetBtnSaveState)
	self:RegisterGameEvent(EventID.UpdateMainPlayerState, self.UpdateMainPlayerState)
end

function MusicPlayerMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function MusicPlayerMainPanelView:OnPlayStateChange(NewValue)
	UIUtil.SetIsVisible(self.EFFPanel, NewValue)
	if NewValue then
		self:PlayAnimation(self.AnimPlayingLoop, 0, 0)
	else
		self:StopAnimation(self.AnimPlayingLoop)
	end
end

function MusicPlayerMainPanelView:OnTextChangedInput()
	if not self.EditState then
		return
	end 
	local InputName = self.InputBox:GetText()
	local InputLen = _G.CommonUtil.GetStrLen(InputName)
	_G.JudgeSearchMgr:QueryTextIsLegal(InputName, function( IsLegal )
		if not IsLegal then
			return
		end
	end)
	if InputName == "" or InputLen > self.InputBox.MaxNum  then
		MusicPlayerMgr.ListNameIsChanged = false
		MusicPlayerMgr.IsCanSave = false
		self:SetBtnSaveState(false)
		return
	end
	local IsSameName = false
	if InputName ~= "" then
		IsSameName = MusicPlayerMgr:IsSameName(InputName)
	end

	if not IsSameName then
		MusicPlayerMgr.IsCanSave = true
		self:SetBtnSaveState(true)
	else
		MusicPlayerMgr.IsCanSave = false
		self:SetBtnSaveState(false)
	end
	MusicPlayerMgr.ListNameIsChanged = true
	--MusicPlayerMgr.IsCanSave = true
	--self:SetSaveBtnEnable(true)
end

function MusicPlayerMainPanelView:OnSelectionChangedDropDownList(Index,ItemData,ItemView)
	if self.UpdateBySave then
		return
	end
	MusicPlayerMgr.CurPlayListIndex = Index
	MusicPlayerMgr.CurPlayListIDInfo = MusicPlayerMgr.AllPlayListInfo[Index]
	self:SetBtnEmptyState(false)
	local MusicList = MusicPlayerMgr.AllPlayListInfo[Index].MusicID
	if MusicList == nil or #MusicList == 0 then
		--self.ViewModel:UpdateMusicListInfoByEdit({})
		self:SetBtnState(false, true)
		self.ViewModel.CurIndexEmptyState = true
		if not MusicPlayerMgr.EditState then
			UIUtil.SetIsVisible(self.NoMusicPanelNew, true)
			UIUtil.SetIsVisible(self.TableViewList, false)
		end
	else
		self:SetBtnState(true, false)
		self.ViewModel.CurIndexEmptyState = false
		if not MusicPlayerMgr.EditState then
			UIUtil.SetIsVisible(self.NoMusicPanelNew, false)
			--FLOG_ERROR("UpdateMusicListInfo111 = %s", table_to_string(MusicPlayerMgr.CurPlayListIDInfo))
			self.ViewModel:UpdateMusicListInfo(MusicPlayerMgr.CurPlayListIDInfo)
			local CurPlayingListIndex = MusicPlayerMgr.CurPlayingListIndex
			local CurPlayListIndex = MusicPlayerMgr.CurPlayListIndex
			if CurPlayingListIndex == CurPlayListIndex then
				local MusicIndex = self:GetMusicIndex()
				self.MusicItemList:SetSelectedIndex(MusicIndex)
			else
				self.MusicItemList:SetSelectedIndex(0)
			end
			UIUtil.SetIsVisible(self.TableViewList, true)
		end
	end
end

function MusicPlayerMainPanelView:UpdateMainPlayerState(MusicID, IsPlay)
	if IsPlay then
		if self.ViewModel.PlaySoundID ~= nil then
			--self:PlayMusic(self.PlayType)
			self.ViewModel:StopPlayMusic()
		end
		self.ViewModel:PlayMusicTest(MusicID, IsPlay)
	else
		if self.ViewModel.PlaySoundID ~= nil and self.ViewModel.PlayTestSoundID ~= nil then
			self:PlayMusic(self.PlayType)
		end
		self.ViewModel:StopPlayTestMusic()
	end
end

function MusicPlayerMainPanelView:UpdateAfterSave()
	MsgTipsUtil.ShowTipsByID(MsgTipsID.MusicSaveList)
	if MusicPlayerMgr.CurPlayerPlayingMusicID ~= nil and self.ViewModel.CurPlayState then
		MsgTipsUtil.ShowTipsByID(MsgTipsID.MusicSaveListTips)
		MusicPlayerMgr.PlayerPlayState = false
		MusicPlayerMgr.CurPlayerPlayingMusicID = nil
		MusicPlayerMgr.CurPlayIndex = 0
		MusicPlayerMgr.CurPlayTime = 0
		self.ViewModel:StopPlayMusic()
		MusicPlayerMgr:StopCurPlayerMusic()
		MusicPlayerMgr:RecoverBGM()
		self.ViewModel:UpdatePlayState(1)
		self.ViewModel:UpdateMusicName("")
		self.ViewModel:UpdateTimeInfo("")
		self.ViewModel:SetPercentScale(0)
	else
		MusicPlayerMgr.CurPlayIndex = 0
		MusicPlayerMgr.CurPlayerPlayingMusicID = nil
		self.ViewModel:SetPercentScale(0)
		self.ViewModel:UpdateTimeInfo("")
		self.ViewModel:UpdateMusicName("")
	end

	if self.ViewModel.PlayTestSoundID ~= nil then
		self.ViewModel:StopPlayTestMusic()
	end

	local CurMusicListLen
	if MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayingListIndex] then
		local MusicList = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayingListIndex].MusicID or {}
		CurMusicListLen = #MusicList
	else
		CurMusicListLen = 0
	end

	if CurMusicListLen == 0 then
		--self:SetBtnState(false, true)
		self.ViewModel:UpdateMusicName("")
		self.ViewModel:UpdateTimeInfo("")
	end

	UIUtil.SetIsVisible(self.EFFPanel, false)
	self.ViewModel.CurPlayState = false
	self:AfterCancelOrSaveClick()
	self:SetImgStateBar()
	self:SetDropDownPlayingIcon()
	-- if self.TimeID then
	-- 	self:UnRegisterTimer(self.TimeID)
	-- end
	-- self.ViewModel:StopPlayMusic()
	-- local Tips = LSTR(1190005)
	-- MsgTipsUtil.ShowTips(Tips)
end

function MusicPlayerMainPanelView:UpdateMusicInfo()
	--local MusicList = MusicPlayerMgr:GetTestData()
	local MusicList = MusicPlayerMgr.CurPlayListIDInfo
	--local MusicList = MusicPlayerMgr.CurPlayListIDInfo.MusicID
	local PlayMode = MusicPlayerMgr.CurPlayMode
	if MusicList.MusicID == nil or #MusicList.MusicID == 0 then
		self.EditState = false
		MusicPlayerMgr.EditState = self.EditState
		--self.IsOpenRightList = true
		--self:OpenMusicEditPanel()
		self:SetBtnState(false, true)
		UIUtil.SetIsVisible(self.NoMusicPanelNew, true)
		UIUtil.SetIsVisible(self.TableViewList, false)
	else
		self.EditState = false
		MusicPlayerMgr.EditState = self.EditState
		self.IsOpenRightList = false
		self:OpenMusicEditPanel()
		self:SetBtnState(true, false)
		UIUtil.SetIsVisible(self.NoMusicPanelNew, false)
		UIUtil.SetIsVisible(self.TableViewList, true)
		self.ViewModel:UpdateMusicListInfo(MusicList)
		local Index = self:GetMusicIndex()
		self.MusicItemList:SetSelectedIndex(Index)
	end
	if self.ViewModel.CurPlayState then
		self.ProbarBlue:SetPercent(1)
		local Time = {}
		Time.CurTime = MusicPlayerMgr.CurPlayTime
		Time.TotalTime = MusicPlayerMgr.MusicTotalTime
		self:SetTimeTextAndBar(Time)
	else
		self.ProbarBlue:SetPercent(0)
	end

	self:SetImgStateBar()
	self.ViewModel:UpdateDropList()
	self:InitDropList()
	self.ViewModel:InitPlayModeInfo(PlayMode)
	--self.MusicItemList:SetSelectedIndex(MusicPlayerMgr.CurPlayIndex)
end

function MusicPlayerMainPanelView:InitDropList()
	self.MusicDropDownListNew:UpdateItems(self.ViewModel.DropListInfo, MusicPlayerMgr.CurPlayingListIndex)
end

function MusicPlayerMainPanelView:OnSelectChanged(Index, ItemData, ItemView)
	--FLOG_ERROR("MusicPlayer Select INDEX = %d %d",Index , ItemData.CurIndex)
	if not self.IsCanClick then
		return
	end

	local IsNil = ItemData.IsNil
	if not IsNil and not MusicPlayerMgr.IsChoseRight then
		MusicPlayerMgr.CurPlayIndex = Index
	end

	if IsNil and self.EditState and not MusicPlayerMgr.IsChoseRight and not MusicPlayerMgr.IsChoseLeft then
		MsgTipsUtil.ShowTipsByID(MsgTipsID.MusicAddMusic)
		--空状态点击没有打开右边界面的情况下自动打开
		if not self.IsOpenRightList then
			self:ClickBtnOpenList()
		end
		return
	elseif IsNil and MusicPlayerMgr.IsChoseRight and self.EditState then
		EventMgr:SendEvent(EventID.MainChosedByRight, Index, true)
	elseif IsNil and MusicPlayerMgr.IsChoseLeft and self.EditState then
		EventMgr:SendEvent(EventID.MainChosedByRight, Index, false)
	elseif not IsNil and self.EditState then
		if MusicPlayerMgr.IsChoseRight then
			local function DelayGoPlay()
				self:UpdateMainPlayerState(MusicPlayerMgr.CurPlayerPlayingMusicID, true)
			end
			self.DelayTimerID = _G.TimerMgr:AddTimer(nil, DelayGoPlay, 0.5)
		end 
		MusicPlayerMgr.RighListChoseMusicID = nil
		MusicPlayerMgr.RightListChoseType = nil
		MusicPlayerMgr.IsChoseRight = false
		MusicPlayerMgr.IsChoseLeft = true
		MusicPlayerMgr.LeftChosedID = ItemData.MusicInfo.MusicID
		self.ListPanel:ClearIndex()
		EventMgr:SendEvent(EventID.LeftChosed)
	end

	if MusicPlayerMgr.CurPlayListIDInfo.MusicID == nil then
		return
	end
	
	local MusicID = MusicPlayerMgr.CurPlayListIDInfo.MusicID[MusicPlayerMgr.CurPlayIndex]
	if MusicID == MusicPlayerMgr.CurPlayerPlayingMusicID and MusicPlayerMgr.CurPlayListIndex == MusicPlayerMgr.CurPlayingListIndex and self.ViewModel.CurPlaingMusicIndex == MusicPlayerMgr.CurPlayIndex then
		return
	end

	-- if CurPlayIndex == Index then
	-- 	return
	-- end
	
	MusicPlayerMgr.CurPlayIndex = Index
	self.PlayType = 2

	if not MusicPlayerMgr.EditState then
		self:PlayMusic(self.PlayType, true)
	end
end

--PlayType 1 点击播放按钮播放 2 点击TableviewItem播放 IsClick true 通过点击TableviewItem切歌 false 通过下方按钮切歌
function MusicPlayerMainPanelView:PlayMusic(PlayType, IsClick)
	self.ViewModel:PlayMusic(PlayType, IsClick)
	if self.ViewModel.CurPlayState then
		self.ProbarBlue:SetPercent(1)
	end
	self:SetImgStateBar()
	self:SetDropDownPlayingIcon()
end

--设置播放列表Item的播放图标
function MusicPlayerMainPanelView:SetDropDownPlayingIcon()
	if self.ViewModel and self.ViewModel.DropListInfo then
		for Index, value in ipairs(self.ViewModel.DropListInfo) do
			local ItemVM = self.MusicDropDownListNew:GetDropDownItemVM(Index)
			if ItemVM then
				if Index == MusicPlayerMgr.CurPlayingListIndex and self.ViewModel.CurPlayState then
					ItemVM:SetIsShowPlayingIcon(true)
				else
					ItemVM:SetIsShowPlayingIcon(false)
				end
			end
		end
	end
end

function MusicPlayerMainPanelView:PlayCurMusic()
	local CurPlayingListIndex = MusicPlayerMgr.CurPlayingListIndex
	local CurPlayListIndex = MusicPlayerMgr.CurPlayListIndex
	if self.ViewModel.CurListIsNil then
		if MusicPlayerMgr.PlayerPlayState then
			if CurPlayingListIndex == CurPlayListIndex then
				return
			end
		else
			if MusicPlayerMgr.CurPlayerPlayingMusicID == nil then
				return
			end
		end
	else
		if not MusicPlayerMgr.PlayerPlayState and not MusicPlayerMgr.CurPlayerPlayingMusicID then
			self.MusicItemList:SetSelectedIndex(1)
			return
		end
		self.PlayType = 1
		self:PlayMusic(self.PlayType, true)
	end

	-- local Index = self:GetMusicIndex()
	-- self.MusicItemList:SetSelectedIndex(Index)
end

function MusicPlayerMainPanelView:PlayNextMusic()
	local MusicList = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayListIndex].MusicID
	local CurPlayingListIndex = MusicPlayerMgr.CurPlayingListIndex
	local CurPlayListIndex = MusicPlayerMgr.CurPlayListIndex
	if MusicList == nil or #MusicList == 0 then
		if MusicPlayerMgr.PlayerPlayState then
			if CurPlayingListIndex == CurPlayListIndex then
				return
			end
		else
			if MusicPlayerMgr.CurPlayerPlayingMusicID == nil then
				return
			end
		end
	end

	if MusicPlayerMgr.CurPlayListIDInfo.MusicID == nil and CurPlayingListIndex == CurPlayListIndex then
		return
	end

	self:PlayMusicByPlayMode(false)
	if self.ViewModel.CurPlayState then
		if CurPlayingListIndex == CurPlayListIndex then
			self.MusicItemList:SetSelectedIndex(MusicPlayerMgr.CurPlayIndex)
			self.MusicItemList:ScrollToIndex(MusicPlayerMgr.CurPlayIndex)
			return
		end
	else
		self.MusicItemList:SetSelectedIndex(MusicPlayerMgr.CurPlayIndex)
		self.MusicItemList:ScrollToIndex(MusicPlayerMgr.CurPlayIndex)
		return
	end
	-- self.PlayType = 2
	-- self:PlayMusic(self.PlayType, true)
end

function MusicPlayerMainPanelView:PlayLastMusic()
	local MusicList = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayListIndex].MusicID
	local CurPlayingListIndex = MusicPlayerMgr.CurPlayingListIndex
	local CurPlayListIndex = MusicPlayerMgr.CurPlayListIndex
	if MusicList == nil or #MusicList == 0 then
		if MusicPlayerMgr.PlayerPlayState then
			if CurPlayingListIndex == CurPlayListIndex then
				return
			end
		else
			if MusicPlayerMgr.CurPlayerPlayingMusicID == nil then
				return
			end
		end
	end
	
	if MusicPlayerMgr.CurPlayListIDInfo.MusicID == nil and CurPlayingListIndex == CurPlayListIndex then
		return
	end

	self:PlayMusicByPlayMode(true)
	if self.ViewModel.CurPlayState then
		if CurPlayingListIndex == CurPlayListIndex then
			self.MusicItemList:SetSelectedIndex(MusicPlayerMgr.CurPlayIndex)
			self.MusicItemList:ScrollToIndex(MusicPlayerMgr.CurPlayIndex)
		end
	else
		self.MusicItemList:SetSelectedIndex(MusicPlayerMgr.CurPlayIndex)
		self.MusicItemList:ScrollToIndex(MusicPlayerMgr.CurPlayIndex)
	end
	self.PlayType = 2
	self:PlayMusic(self.PlayType)
end

function MusicPlayerMainPanelView:SetTimeTextAndBar(Time)
	if Time.CurTime == nil then
		return
	end

	local ElapsedTime = math.min(math.ceil(Time.CurTime), Time.TotalTime) --经过的时间
	local RemainingTime = math.max(0, Time.TotalTime - math.ceil(Time.CurTime)) --剩余的时间

    if ElapsedTime >= Time.TotalTime then
        MusicPlayerMgr:StopCurPlayerMusic()
        self:PlayMusicByPlayMode(false, true)
        self.PlayType = 2
        self:PlayMusic(self.PlayType)
        
        if MusicPlayerMgr.CurPlayListIndex == MusicPlayerMgr.CurPlayingListIndex 
           and not MusicPlayerMgr.EditState then
            self.MusicItemList:SetSelectedIndex(MusicPlayerMgr.CurPlayIndex)
            self.MusicItemList:ScrollToIndex(MusicPlayerMgr.CurPlayIndex)
        end
        return
    end

	local Percent = ElapsedTime / Time.TotalTime
	self.ViewModel:SetTimeTextAndBar(RemainingTime, Percent)
	local EffVisible = UIUtil.IsVisible(self.EFFPanel)
	if not self.EditState and not EffVisible and self.IsCanClick then
		UIUtil.SetIsVisible(self.EFFPanel, true)
	end

	UIUtil.CanvasSlotSetPosition(self.EFFPanel, _G.UE4.FVector2D(-438 + (876 / 100) * Percent * 100, 273.38))

	-- if ElapsedTime % 2 == 0 then
	-- 	self:PlayAnimation(self.AnimPlayingLoop)
	-- end

end

function MusicPlayerMainPanelView:GoOnPlaye()
	--TO DO根据当前正在播放的列表进行继续播放
	local MusicID = MusicPlayerMgr.CurPlayingList.MusicID[MusicPlayerMgr.CurPlayIndex]
	MusicPlayerMgr.CurPlayTime =  MusicPlayerMgr:GetMusicTime(MusicID)
	self.ViewModel:UpdatePlayState(2)
	MusicPlayerMgr:PlayPlayerMusic(MusicID)
end

function MusicPlayerMainPanelView:ClickBtnAdd()
	local State = self.EditState
	State = not State
	self.EditState = State
	MusicPlayerMgr.EditState = self.EditState
	self.IsOpenRightList = true
	self:PlayAnimation(self.AnimRefresh)
	self:PlayAnimation(self.AnimExpand)
	self:OpenMusicEditPanel()
end

function MusicPlayerMainPanelView:ClickBtnEdit()
	local MusicList = MusicPlayerMgr.CurPlayListIDInfo
	if MusicList.MusicID == nil or #MusicList.MusicID == 0 then
		self.IsOpenRightList = true
		self:PlayAnimation(self.AnimExpand)
	else
		self.IsOpenRightList = false
	end
	self.EditState = true
	MusicPlayerMgr.EditState = self.EditState
	self:OpenMusicEditPanel()
	self:PlayAnimation(self.AnimRefresh)
end

function MusicPlayerMainPanelView:ClickBtnOpenList()
	self.IsOpenRightList = not self.IsOpenRightList
	if self.IsOpenRightList then
		self:PlayAnimation(self.AnimExpand)
		MusicPlayerMgr:SendMsgGetUnLockList(2, nil, true)
		self.TextContent:SetText(LSTR(1190006))
		UIUtil.SetIsVisible(self.ImgArrow, false)
		UIUtil.SetIsVisible(self.ImgArrow_1, true)
	else
		self:PlayAnimation(self.AnimClose)
		self.TextContent:SetText(LSTR(1190003))
		UIUtil.SetIsVisible(self.ImgArrow, true)
		UIUtil.SetIsVisible(self.ImgArrow_1, false)
	end
	UIUtil.SetIsVisible(self.ListPanel, self.IsOpenRightList)
end

function MusicPlayerMainPanelView:ClickBtnCancel()
	local IsCanSave = MusicPlayerMgr.IsCanSave
	self:JundgedIsCanSave()
	if not MusicPlayerMgr.IsCanSave then
		self.IsOpenRightList = false
	end
	self.TextContent:SetText(LSTR(1190003))
	UIUtil.SetIsVisible(self.ImgArrow, true)
	UIUtil.SetIsVisible(self.ImgArrow_1, false)
	if not IsCanSave then
		EventMgr:SendEvent(EventID.UpdateMainPlayerState, nil, false)
	end
end

function MusicPlayerMainPanelView:AfterCancelOrSaveClick()
	self.UpdateBySave = true
	local State = self.EditState
	State = not State
	self.EditState = State
	MusicPlayerMgr.EditState = self.EditState
	MusicPlayerMgr.IsCanSave = false
	MusicPlayerMgr.ListNameIsChanged = false
	self:SetBtnSaveState(MusicPlayerMgr.IsCanSave)

	if self.IsOpenRightList then
		self:PlayAnimation(self.AnimClose)
	end

	self.IsOpenRightList = false
	local MusicList = MusicPlayerMgr.CurPlayListIDInfo or {}
	self:OpenMusicEditPanel()
	self.ViewModel:UpdateDropList()
	self:InitDropList()
	self.ViewModel:UpdateMusicListInfo(MusicList)
	local Index = self:GetMusicIndex()
	self.MusicItemList:SetSelectedIndex(Index)

	if not MusicList.MusicID or #MusicList.MusicID == 0 then
		UIUtil.SetIsVisible(self.NoMusicPanelNew, true)
		UIUtil.SetIsVisible(self.TableViewList, false)
		self:SetBtnState(false, true)
	else
		UIUtil.SetIsVisible(self.NoMusicPanelNew, false)
		UIUtil.SetIsVisible(self.TableViewList, true)
		self:SetBtnState(true, false)
	end

	local Data = {}
	Data.Name = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayListIndex].Name
	self.MusicDropDownListNew:SetSelectedIndex(MusicPlayerMgr.CurPlayListIndex, Data)
	self.UpdateBySave = false
end

function MusicPlayerMainPanelView:ClickBtnSave()
	local NewList = MusicPlayerMgr:SetSaveListInfo()
	local InputName = self.InputBox:GetText() 
	if InputName ~= "" and MusicPlayerMgr.ListNameIsChanged then
		local IsSameName = MusicPlayerMgr:IsSameName(InputName)
		if IsSameName then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.MusicListNameRepetition)
			return
		end

		MusicPlayerMgr.NewName = InputName
	else
		MusicPlayerMgr.NewName = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayListIndex].Name
	end


	local IsCanSave = MusicPlayerMgr.IsCanSave

	if IsCanSave then
		MusicPlayerMgr:SendMsgSaveMusicList(NewList)
	else
		if InputName == "" then
			local Tips = LSTR(1190013)
			MsgTipsUtil.ShowTips(Tips)

			return
		end
		
		MsgTipsUtil.ShowTipsByID(MsgTipsID.MusicSaveListFail) 
	end
end

function MusicPlayerMainPanelView:OpenMusicEditPanel()
	if self.EditState then
		local CurName = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayListIndex].Name
		self.InputBox:SetText(CurName)
		self.InputBox:RefreshTextColorAndOpacity(true)
		self.ViewModel:SetTitle()
		UIUtil.SetIsVisible(self.SavePanel, true)
		--self:SetSaveBtnEnable(false)
		UIUtil.SetIsVisible(self.CancelPanel, true)
		UIUtil.SetIsVisible(self.PlayBarPanel, false)
		UIUtil.SetIsVisible(self.EditListPanel, false)
		UIUtil.SetIsVisible(self.OpenListPanel, true)
		UIUtil.SetIsVisible(self.NoMusicPanelNew, false)
		UIUtil.SetIsVisible(self.TableViewList, true)
		UIUtil.SetIsVisible(self.EFFPanel, false)
		self:SetInputPanelAndDropList(false)

		if self.IsOpenRightList then
			self.TextContent:SetText(LSTR(1190006))
			UIUtil.SetIsVisible(self.ImgArrow, false)
			UIUtil.SetIsVisible(self.ImgArrow_1, true)
		end

		MusicPlayerMgr.ListNameIsChanged = false
	else
		--关闭编辑状态后 清楚选择的信息
		MusicPlayerMgr.RighListChoseMusicID = nil
		MusicPlayerMgr.RightListChoseType = nil
		MusicPlayerMgr.IsChoseRight = false
		MusicPlayerMgr.IsChoseLeft = false
		self.ListPanel:ClearIndex()
		self.ViewModel:SetTitle()
		UIUtil.SetIsVisible(self.SavePanel, false)
		UIUtil.SetIsVisible(self.CancelPanel, false)
		UIUtil.SetIsVisible(self.PlayBarPanel, true)
		UIUtil.SetIsVisible(self.EditListPanel, true)
		UIUtil.SetIsVisible(self.OpenListPanel, false)
		self:SetInputPanelAndDropList(true)

		self.TextContent:SetText(LSTR(1190003))
		UIUtil.SetIsVisible(self.ImgArrow, true)
		UIUtil.SetIsVisible(self.ImgArrow_1, false)
		if MusicPlayerMgr.CurPlayerPlayingMusicID ~= nil and self.ViewModel.CurPlayState and not self.ViewModel.CurListIsNil then
			UIUtil.SetIsVisible(self.EFFPanel, true)
		end
	end

	if self.EditState and self.IsOpenRightList then
		MusicPlayerMgr:SendMsgGetUnLockList(2, nil, true)
		UIUtil.SetIsVisible(self.ListPanel, true)
		local MusicList = MusicPlayerMgr.CurPlayListIDInfo
		self.ViewModel:UpdateMusicListInfoByEdit(MusicList)
		self.MusicItemList:SetSelectedIndex(0)
	elseif self.EditState then
		local MusicList = MusicPlayerMgr.CurPlayListIDInfo
		self.ViewModel:UpdateMusicListInfoByEdit(MusicList)
		self.MusicItemList:SetSelectedIndex(0)
	elseif not self.EditState then
		UIUtil.SetIsVisible(self.ListPanel, false)
		self.ViewModel:UpdateMusicListInfoByEdit({})
		self.MusicItemList:SetSelectedIndex(0)
	end
end

function MusicPlayerMainPanelView:ChangedPlayMode()
	local MusicList = MusicPlayerMgr.AllPlayListInfo[MusicPlayerMgr.CurPlayListIndex].MusicID
	local CurPlayingListIndex = MusicPlayerMgr.CurPlayingListIndex
	local CurPlayListIndex = MusicPlayerMgr.CurPlayListIndex
	if MusicList == nil or #MusicList == 0 then
		if MusicPlayerMgr.PlayerPlayState then
			if CurPlayingListIndex == CurPlayListIndex then
				return
			end
		else
			if MusicPlayerMgr.CurPlayerPlayingMusicID == nil then
				return
			end
		end
	end
	self.ViewModel:UpdatePlaymodeState()
	local PlayMode = MusicPlayerMgr.CurPlayMode
	local Tips = nil

	if PlayMode == 1 then
		Tips = MsgTipsID.MusicOrderMode
	elseif PlayMode == 2 then
		Tips = MsgTipsID.MusicSingleMode
	elseif PlayMode == 3 then
		Tips = MsgTipsID.MusicRandomMode
	end
	MsgTipsUtil.ShowTipsByID(Tips)
end

function MusicPlayerMainPanelView:SetSaveBtnEnable(Value)
	self.BtnSave:SetIsEnabled(Value)
end

function MusicPlayerMainPanelView:SetImgStateBar()
	if self.ViewModel.CurPlayState then
		UIUtil.SetIsVisible(self.ImgStateBarR, true)
		UIUtil.SetIsVisible(self.ImgStateBarL, true)
	end
end

function MusicPlayerMainPanelView:SetBtnState(Value, IsNil)
	self.ViewModel:SetBtnState(Value, IsNil)
	-- self.BtnPrevious:SetIsEnabled(Value)
	-- self.BtnPlayPause:SetIsEnabled(Value)
	-- self.BtnNext:SetIsEnabled(Value)
	-- self.BtnCirculate:SetIsEnabled(Value)
end

function MusicPlayerMainPanelView:UpdateItemBtnState()
	--local MusicList = MusicPlayerMgr.CurPlayListIDInfo
	-- local Info = MusicPlayerMgr.EditMusicInfo
	-- self.ViewModel:UpdateMusicListInfoByEdit(Info)

	local MusicList = MusicPlayerMgr.EditMusicInfo
	self.ViewModel:UpdateMusicListInfoByEdit(MusicList, true)
	self.MusicItemList:SetSelectedIndex(0)
end

function MusicPlayerMainPanelView:UpdateEditMusicInfo()
	local Info = MusicPlayerMgr.EditMusicInfo
	local IsUpdate = true
	self.ViewModel:UpdateMusicListInfoByEdit(Info, IsUpdate)
	self.MusicItemList:SetSelectedIndex(0)
	
end

function MusicPlayerMainPanelView:PlayMusicByPlayMode(IsLast, IsAuto)
	self.ViewModel:PlayMusicByPlayMode(IsLast, IsAuto)
end

function MusicPlayerMainPanelView:JundgedIsCanSave()
	local IsCanSave = MusicPlayerMgr.IsCanSave
	local IsCancel = false
	if IsCanSave then
		local Content = LSTR(1190002)
		local function  Callback()
			self:AfterCancelOrSaveClick()
			EventMgr:SendEvent(EventID.UpdateMainPlayerState, nil, false)
		end
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1190004), Content, Callback, nil, LSTR(1190001),  LSTR(1190010))
	else
		self:AfterCancelOrSaveClick()
	end

	return IsCancel
end

function MusicPlayerMainPanelView:SetInputPanelAndDropList(Value)
	if self.IsInHotel then
		UIUtil.SetIsVisible(self.InputPanel, false)
		UIUtil.SetIsVisible(self.MusicDropDownListNew, false)
		return
	end
	UIUtil.SetIsVisible(self.InputPanel, not Value)
	UIUtil.SetIsVisible(self.MusicDropDownListNew, Value)
end

function MusicPlayerMainPanelView:GetMusicIndex()
	local Index = nil
	local CurPlayingMusicID = MusicPlayerMgr.CurPlayerPlayingMusicID
	local List = MusicPlayerMgr.CurPlayListIDInfo
	
	if List == nil or CurPlayingMusicID == nil then
		return nil
	end

	if List.MusicID == nil then
		return nil
	end

	for i = 1, #List.MusicID do
		if CurPlayingMusicID == List.MusicID[i] and MusicPlayerMgr.CurPlayIndex == i then
			Index = i
			return Index
		end
	end

	return Index
end

function MusicPlayerMainPanelView:SetBtnSaveState(State)
	self.ViewModel:SetBtnSaveState(State)
end

function MusicPlayerMainPanelView:SetBtnEmptyState(State)
	UIUtil.SetIsVisible(self.BtnEmpty, State, true)
end

function MusicPlayerMainPanelView:ClickBtnEmpty()
	EventMgr:SendEvent(EventID.UpdateDropState, false)
	UIUtil.SetIsVisible(self.BtnEmpty, false, true)
end

function MusicPlayerMainPanelView:RestByClose()
	self.ListPanel:ClearIndex()
	EventMgr:SendEvent(EventID.UpdateMainPlayerState, nil, false)
	if self.IsOpenRightList then
		self:PlayAnimation(self.AnimClose)
		self.IsOpenRightList = false
		UIUtil.SetIsVisible(self.ListPanel, false)
		UIUtil.SetIsVisible(self.ImgArrow, true)
		UIUtil.SetIsVisible(self.ImgArrow_1, false)
		local function EnterAnimFinish()
			self:PlayAnimation(self.AnimOut_1)
			self.DelayTimerID = nil
		end
		self.DelayTimerID = _G.TimerMgr:AddTimer(nil, EnterAnimFinish, 0.3)

		local function EnterAnimFinish2()
			UIUtil.SetIsVisible(self.EFFPanel, false)
			self.EditState = false
			MusicPlayerMgr:RestMusicPlayerInfo()
			self:SetBtnSaveState(MusicPlayerMgr.IsCanSave)
			self:Hide()
			self:OpenMusicEditPanel()
			self.ViewModel:SetPercent(0)
			self.DelayTimerID2 = nil
		end
		self.DelayTimerID2 = _G.TimerMgr:AddTimer(nil, EnterAnimFinish2, 0.7)
	else
		self:PlayAnimation(self.AnimOut_1)
	
		local function EnterAnimFinish()
			UIUtil.SetIsVisible(self.EFFPanel, false)
			self.EditState = false
			MusicPlayerMgr:RestMusicPlayerInfo()
			self:SetBtnSaveState(MusicPlayerMgr.IsCanSave)
			self:Hide()
			self:OpenMusicEditPanel()
			self.ViewModel:SetPercent(0)
			self.DelayTimerID = nil
		end
		self.DelayTimerID = _G.TimerMgr:AddTimer(nil, EnterAnimFinish, 0.4)
	end
end

function MusicPlayerMainPanelView:Close()
	local IsCanSave = MusicPlayerMgr.IsCanSave
	MusicPlayerMgr.MusicPlayerIsShow = false
	if IsCanSave then
		local Content = LSTR(1190002)
		local function  Callback()
			self:RestByClose()
		end
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1190004), Content, Callback, nil, LSTR(1190001),  LSTR(1190010))
	else
		self:RestByClose()
	end
end

return MusicPlayerMainPanelView