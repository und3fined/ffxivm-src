---
--- Author: Administrator
--- DateTime: 2023-12-21 10:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MusicPlayerMgr = require("Game/MusicPlayer/MusicPlayerMgr")
local EventID = require("Define/EventID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MusicAtlasMainVM = require("Game/MusicAtlas/View/MusicAtlasMainVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ItemUtil = require("Utils/ItemUtil")
local MusicPlayerCfg = require("TableCfg/MusicPlayerCfg")
local MsgTipsID = require("Define/MsgTipsID")
local AudioUtil = require("Utils/AudioUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local TipsUtil = require("Utils/TipsUtil")
local RichTextUtil = require("Utils/RichTextUtil")



local LSTR = _G.LSTR
local OpenSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_book_open.Play_UI_book_open'"
local TurnSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_book_turn.Play_UI_book_turn'"


---@class MusicAtlasMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BtnComment UFButton
---@field BtnGather UFButton
---@field BtnGetWay UFButton
---@field BtnMusicName UFButton
---@field BtnPage01 UFButton
---@field BtnPage02 UFButton
---@field BtnRevert UFButton
---@field CommEmpty CommBackpackEmptyView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field GetWayBtnPanel UFCanvasPanel
---@field ImgGatherBG UFImage
---@field ImgGatherProbar URadialImage
---@field ImgMusic UFImage
---@field ImgPage01 UFImage
---@field ImgPage02 UFImage
---@field ImgPage03 UFImage
---@field ImgPage04 UFImage
---@field ImgPlay UFImage
---@field ImgStart UFImage
---@field ImgStop UFImage
---@field JumpBtn UFButton
---@field MI_DX_Common_MusicAtlas_1 UFImage
---@field MI_DX_Common_MusicAtlas_3 UFImage
---@field MusicAtlasProbarItem_UIBP MusicAtlasProbarItemView
---@field PanelBottomProbar UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelMusic UFCanvasPanel
---@field PanelRevert UFCanvasPanel
---@field SearchBar CommSearchBarView
---@field SingleBox CommSingleBoxView
---@field Spine_MusicAtlas_Page USpineWidget
---@field TableViewMusicList UTableView
---@field TableViewWayList UTableView
---@field TextAlreadyGet UFTextBlock
---@field TextEmpty UFTextBlock
---@field TextGather UFTextBlock
---@field TextGetWay UFTextBlock
---@field TextMusicName UFTextBlock
---@field TextName UFTextBlock
---@field TextPageNumber UFTextBlock
---@field TextRevert UFTextBlock
---@field TextSubtitle UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitleName UFTextBlock
---@field ToggleBtnStart UToggleButton
---@field VerIconTabs CommVerIconTabsView
---@field AnimIn_1 UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimNameContentIn UWidgetAnimation
---@field AnimNameContentSelect UWidgetAnimation
---@field AnimPageturnLeft UWidgetAnimation
---@field AnimPageturnRight UWidgetAnimation
---@field AnimPlay UWidgetAnimation
---@field AnimPlayStaff UWidgetAnimation
---@field AnimStop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicAtlasMainView = LuaClass(UIView, true)

function MusicAtlasMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BtnComment = nil
	--self.BtnGather = nil
	--self.BtnGetWay = nil
	--self.BtnMusicName = nil
	--self.BtnPage01 = nil
	--self.BtnPage02 = nil
	--self.BtnRevert = nil
	--self.CommEmpty = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonTitle = nil
	--self.GetWayBtnPanel = nil
	--self.ImgGatherBG = nil
	--self.ImgGatherProbar = nil
	--self.ImgMusic = nil
	--self.ImgPage01 = nil
	--self.ImgPage02 = nil
	--self.ImgPage03 = nil
	--self.ImgPage04 = nil
	--self.ImgPlay = nil
	--self.ImgStart = nil
	--self.ImgStop = nil
	--self.JumpBtn = nil
	--self.MI_DX_Common_MusicAtlas_1 = nil
	--self.MI_DX_Common_MusicAtlas_3 = nil
	--self.MusicAtlasProbarItem_UIBP = nil
	--self.PanelBottomProbar = nil
	--self.PanelEmpty = nil
	--self.PanelMusic = nil
	--self.PanelRevert = nil
	--self.SearchBar = nil
	--self.SingleBox = nil
	--self.Spine_MusicAtlas_Page = nil
	--self.TableViewMusicList = nil
	--self.TableViewWayList = nil
	--self.TextAlreadyGet = nil
	--self.TextEmpty = nil
	--self.TextGather = nil
	--self.TextGetWay = nil
	--self.TextMusicName = nil
	--self.TextName = nil
	--self.TextPageNumber = nil
	--self.TextRevert = nil
	--self.TextSubtitle = nil
	--self.TextTime = nil
	--self.TextTitleName = nil
	--self.ToggleBtnStart = nil
	--self.VerIconTabs = nil
	--self.AnimIn_1 = nil
	--self.AnimLoop = nil
	--self.AnimNameContentIn = nil
	--self.AnimNameContentSelect = nil
	--self.AnimPageturnLeft = nil
	--self.AnimPageturnRight = nil
	--self.AnimPlay = nil
	--self.AnimPlayStaff = nil
	--self.AnimStop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicAtlasMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.MusicAtlasProbarItem_UIBP)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.SingleBox)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicAtlasMainView:OnInit()
	self.ViewModel = MusicAtlasMainVM.New()
	self.GetWayAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewWayList)
	self.MusicAtlasList = UIAdapterTableView.CreateAdapter(self, self.TableViewMusicList, self.OnAtlasItemSelectChanged, true)
	self.SearchBar:SetCallback(self, nil, self.OnSearchCommit, self.OnCancelSearchClicked)
	self.Binders = {
		{ "CurMusicAtlasList", UIBinderUpdateBindableList.New(self, self.MusicAtlasList) },
		{ "PageText", UIBinderSetText.New(self, self.TextPageNumber) },
		{ "PageLastEnabled", UIBinderSetIsEnabled.New(self, self.BtnLast) },
		{ "PageNextEnabled", UIBinderSetIsEnabled.New(self, self.BtnNext) },
		{ "ImgPage01State", UIBinderSetIsVisible.New(self, self.ImgPage01) },
		{ "ImgPage03State", UIBinderSetIsVisible.New(self, self.ImgPage03) },
		{ "IsMinPageImg", UIBinderSetIsVisible.New(self, self.ImgPage02) },
		{ "IsMaxPageImg", UIBinderSetIsVisible.New(self, self.ImgPage04) },
		{ "MusicName", UIBinderSetText.New(self, self.TextMusicName) },	
		{ "TimeText", UIBinderSetText.New(self, self.TextTime) },
		{ "Percent", UIBinderSetSlider.New(self, self.MusicAtlasProbarItem_UIBP)},
		{ "BtnMusicNameVisible", UIBinderSetIsVisible.New(self, self.PanelMusic)},
		{ "Subtitle", UIBinderSetText.New(self, self.CommonTitle.TextSubtitle) },
		{ "PanelMaskVisible", UIBinderSetIsVisible.New(self, self.PanelMask)},	
		{ "ChosedMusicName", UIBinderSetText.New(self, self.TextName) },
		{ "BtnPage01Visible", UIBinderSetIsVisible.New(self, self.BtnPage01, false, true)},
		{ "BtnPage02Visible", UIBinderSetIsVisible.New(self, self.BtnPage02, false, true)},
		{ "PanelEmptyVisible", UIBinderSetIsVisible.New(self, self.CommEmpty)},
		{ "GatherText", UIBinderSetText.New(self, self.TextGather)},
		{ "GatherPercent", UIBinderSetPercent.New(self, self.ImgGatherProbar)},
		{ "JumpBtnEnabled", UIBinderSetIsEnabled.New(self, self.JumpBtn) },
		{ "AtlasItemID", UIBinderValueChangedCallback.New(self, nil, self.OnAtlasItemIDChange) },
		{ "TitleName", UIBinderSetText.New(self, self.TextTitleName)},
		{ "PanelRevertVisible", UIBinderSetIsVisible.New(self, self.PanelRevert)},
		
	}

	self.CurPage = 1
	self.MaxPage = 1
	self.CurTypeIndex = nil
	self.CurAtlasList = nil
	self.IsUnlock = 0
	self.PlayState = false
	self.CurPlayingMusicIsUnlock = false
	self.ChoseAtlasUnlock = false
	self.IsChanged = false
	self.OpenType = 1
	self.LastChosedList = {}
	self.IsSearching = false
	self.IsCanDeal = false
end

function MusicAtlasMainView:OnDestroy()

end

function MusicAtlasMainView:OnShow()
	self.IsOrgin = true
	self.CurSearchList = {}
	self:SetSearchBarHintText()
	UIUtil.SetIsVisible(self.TableViewWayList, false)
	self.TextGetWay:SetText(LSTR(1170012)) --获取途径
	self.TextAlreadyGet:SetText(LSTR(1170013)) --已收录
	AudioUtil.LoadAndPlay2DSound(OpenSoundPath)
	self.ChangedPercent = 0
	self.OpenType = MusicPlayerMgr.AtlasOpenType
	self:PlayAnimation(self.AnimIn_1)
	self:InitTabInfo()
	local Title = self.ViewModel:SetTitle(self.OpenType)
	self.CommonTitle:SetTextTitleName(Title)
	self:PlayAnimation(self.AnimPlayStaff)
	self:PlayAnimation(self.AnimPlay)
	--不同打开方式的滑动条表现不一样
	self.MusicAtlasProbarItem_UIBP:SetSliderClickVisible(self.OpenType ~= 2)
	if self.Params then
		self.VerIconTabs:SetSelectedIndex(self.Params.Index)
	end
	--屏蔽试听功能
	-- self.MusicAtlasProbarItem_UIBP:SetCaptureBeginCallBack(function (v)
	-- 	self:OnBeginChangedSlider(v)
	-- end)
	-- self.MusicAtlasProbarItem_UIBP:SetValueChangedCallback(function (v)
	-- 	self:OnValueChangedSlider(v)
	-- end)
	-- self.MusicAtlasProbarItem_UIBP:SetCaptureEndCallBack(function (v)
	-- 	self:OnEndChangedSlider(v)
	-- end)

	-- if self.OpenType == 2 and MusicPlayerMgr.CurPlayingMusicID ~= nil then
	-- 	self:PlayAnimation(self.AnimPlayStaff)
	-- 	self:PlayAnimation(self.AnimPlay)
	-- 	self.ToggleBtnStart:SetChecked(true)
	-- end
end

function MusicAtlasMainView:OnHide()
	if #self.LastChosedList > 0 then
		MusicPlayerMgr:RemoveCurTabTypeAllRedDot(self.LastChosedList)
	end
	--MusicPlayerMgr.AtlasTabList = nil
end

function MusicAtlasMainView:OnRegisterUIEvent()
	self.BackBtn:AddBackClick(self, function(e) e:OnCloseView() end)
	UIUtil.AddOnClickedEvent(self, self.BtnPage01, self.ClickLastPage)
	UIUtil.AddOnClickedEvent(self, self.BtnPage02, self.ClickNextPage)
	--屏蔽试听播放功能
	--UIUtil.AddOnClickedEvent(self, self.ToggleBtnStart, self.ClickToggleBtnStart)
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnTabSelectChanged)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnSingleBoxClick)
	UIUtil.AddOnClickedEvent(self, self.JumpBtn, self.JumpToCurPlayMusic)
	UIUtil.AddOnClickedEvent(self, self.BtnRevert, self.OpenRevertPanelView)
	UIUtil.AddOnClickedEvent(self, self.BtnGetWay, self.OnClickBtnGetWay)
	--UIUtil.AddOnClickedEvent(self, self.BtnGather, self.ShowGatherPanel)
end

function MusicAtlasMainView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateAtlasPlayState, self.SetTimeTextAndBar)
	self:RegisterGameEvent(EventID.RestPlay, self.RestPlayCurMusic)
	self:RegisterGameEvent(EventID.ExitRevertState, self.OnCloseView)
	self:RegisterGameEvent(EventID.UpdateAtlasView, self.UpdateRedDot)
end

function MusicAtlasMainView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function MusicAtlasMainView:InitTabInfo()
	local AllTypeList = MusicPlayerMgr:GetMusicTypeInfo(2)
	local NewList = MusicPlayerMgr:GetCurTypeRedDot(AllTypeList)
	self.TabList = NewList
	MusicPlayerMgr.AtlasTabList = NewList
	self.VerIconTabs:UpdateItems(NewList, 1)
	local TotalNum = self:GetAllMusicNum(self.TabList)
	self.ViewModel:ShowGatherPercent(TotalNum)
end

function MusicAtlasMainView:OnBeginChangedSlider()
	MusicPlayerMgr.IsDropSlide = true
	self.IsChanged = true
end

function MusicAtlasMainView:OnValueChangedSlider(Percent)
	if self.IsChanged then
		self.ChangedPercent = Percent
		local TotalTime = MusicPlayerMgr:GetMusicTime(MusicPlayerMgr.CurChoseAtlasID)
		local CurTime = Percent * TotalTime
	
		self.ViewModel:SetTimeTextAndBar(CurTime, TotalTime)
	else
		local IsExceed = self.ViewModel:IsExceedLimit(Percent)
		if IsExceed and not self.ChoseAtlasUnlock and not self.PlayState then
			self.MusicAtlasProbarItem_UIBP:SetValue(0)
		elseif MusicPlayerMgr.CurPlayingMusicID ~= MusicPlayerMgr.CurChoseAtlasID then
			if IsExceed then
				self.MusicAtlasProbarItem_UIBP:SetValue(0)
			end
		end
	end

end

function MusicAtlasMainView:OnEndChangedSlider()
	self.IsChanged = false
	local IsExceed = false
	if not self.ChoseAtlasUnlock then
		IsExceed = self.ViewModel:IsExceedLimit(self.ChangedPercent)	
	end

	if not self.CurPlayingMusicIsUnlock and IsExceed then
		self.ChangedPercent = 0
		local Tips = LSTR(1170007) 
		MsgTipsUtil.ShowTips(Tips)
		local TotalTime = MusicPlayerMgr:GetMusicTime(MusicPlayerMgr.CurChoseAtlasID)
		local CurTime = 0
	
		self.ViewModel:SetTimeTextAndBar(CurTime, TotalTime)
		--self.ViewModel:SetPrecentValue(0)
		self.MusicAtlasProbarItem_UIBP:SetValue(0)
	end

	if self.PlayState then
		if MusicPlayerMgr.CurPlayingMusicID ~= MusicPlayerMgr.CurChoseAtlasID then
			if IsExceed then
				self.ChangedPercent = 0
			end
		else
			self.ViewModel:SetMusicSlideByPrecent(self.ChangedPercent)
		end
	else
		if IsExceed then
			self.ChangedPercent = 0
		end
	end

	MusicPlayerMgr.IsDropSlide = false
end

function MusicAtlasMainView:OnAtlasItemIDChange(NewValue)
	local GetWayList = ItemUtil.GetItemGetWayList(NewValue)
	if GetWayList and #GetWayList > 0 then
		UIUtil.SetIsVisible(self.GetWayBtnPanel, true)
		self.GetWayAdapterTableView:UpdateAll(GetWayList)
	else
		UIUtil.SetIsVisible(self.GetWayBtnPanel, false)
		UIUtil.SetIsVisible(self.TableViewWayList, false)
	end
end

--点击播放
function MusicAtlasMainView:ClickToggleBtnStart()
	if self.OpenType == 2 and not self.ChoseAtlasUnlock then
		MsgTipsUtil.ShowTipsByID(MsgTipsID.MusicNoGetAtlasTips) 
		self.ToggleBtnStart:SetChecked(false)
		return
	end

	if MusicPlayerMgr.CurPlayingMusicID ~= nil then
		if MusicPlayerMgr.CurChoseAtlasID ~= MusicPlayerMgr.CurPlayingMusicID then
			--self.ChangedPercent = 0
			MusicPlayerMgr.AtlasPlayState = true
			self.PlayState = MusicPlayerMgr.AtlasPlayState
			self.ToggleBtnStart:SetChecked(MusicPlayerMgr.AtlasPlayState)
			self.ViewModel:StopPlayChoseMusic()
			MusicPlayerMgr:PlayAtlasMusic(MusicPlayerMgr.CurChoseAtlasID, self.CurTypeIndex)
			self.CurPlayingMusicIsUnlock = self.ChoseAtlasUnlock
			self.ViewModel:PlayChoseMusic(MusicPlayerMgr.CurChoseAtlasID, self.ChangedPercent)
			self:ShowTips(true)
			--self.ViewModel:SetMaskVisible(false)
			--self.MusicAtlasProbarItem_UIBP:SetSliderClickVisible(true)
			self:PlayAnimation(self.AnimPlay)
			self:PlayAnimation(self.AnimNameContentSelect)
			local Info = {}
			Info.Index = self:GetMusicIndex()
			Info.Page = self.CurPage
			Info.CurTypeIndex = self.CurTypeIndex
			self.ViewModel:SetCurPlayMusicPageAndIndex(Info)

			local Info2 = {}
			if MusicPlayerMgr.CurPlayingMusicID then
				Info2.IsShow = MusicPlayerMgr.IsShowCurSlide
				Info2.CurPlayMusicID = MusicPlayerMgr.CurPlayingMusicID
			else
				Info2.IsShow = true
			end

			self.ViewModel:UpdateBtnMusicName(Info2)
			if not Info2.IsShow then
				self:PlayAnimation(self.AnimNameContentIn)
			end
			return
		end
	end 

	MusicPlayerMgr.AtlasPlayState = not MusicPlayerMgr.AtlasPlayState
	self.PlayState = MusicPlayerMgr.AtlasPlayState
	MusicPlayerMgr.AtlasBgmState = self.OpenType == 2 and MusicPlayerMgr.AtlasPlayState or false
	self.ToggleBtnStart:SetChecked(MusicPlayerMgr.AtlasPlayState)

	if MusicPlayerMgr.AtlasPlayState then
		--self.ViewModel:SetMaskVisible(false)
		--self.MusicAtlasProbarItem_UIBP:SetSliderClickVisible(true)
		if self.OpenType == 2 and MusicPlayerMgr.CurChoseAtlasID == MusicPlayerMgr.CurPlayingMusicID then
			MusicPlayerMgr.AtlasPlayState = false
			self.PlayState = MusicPlayerMgr.AtlasPlayState
			self.ToggleBtnStart:SetChecked(MusicPlayerMgr.AtlasPlayState)
			MusicPlayerMgr.CurPlayingMusicID = nil
			MusicPlayerMgr:StopCurMusic()
			self.ViewModel:StopPlayChoseMusic()
			self:ShowTips(false)
			self:StopAnimation(self.AnimPlay)
			self:PlayAnimation(self.AnimStop)
			self:StopAnimation(self.AnimPlayLoop)
			return
		end
		MusicPlayerMgr:PlayAtlasMusic(MusicPlayerMgr.CurChoseAtlasID, self.CurTypeIndex)
		self.CurPlayingMusicIsUnlock = self.ChoseAtlasUnlock
		local Percent = self.OpenType == 2 and 0 or self.ChangedPercent
		self.ViewModel:PlayChoseMusic(MusicPlayerMgr.CurChoseAtlasID, Percent)
		self:ShowTips(true)
		self:PlayAnimation(self.AnimPlayStaff)
		self:PlayAnimation(self.AnimPlay)
		local Info = {}
		Info.Index = self:GetMusicIndex()
		Info.Page = self.CurPage
		Info.CurTypeIndex = self.CurTypeIndex
		self.ViewModel:SetCurPlayMusicPageAndIndex(Info)
	else
		--self.ViewModel:SetMaskVisible(true)
		--self.MusicAtlasProbarItem_UIBP:SetSliderClickVisible(false)
		--self.ChangedPercent = 0
		MusicPlayerMgr.CurPlayingMusicID = nil
		MusicPlayerMgr:StopCurMusic()
		self.ViewModel:StopPlayChoseMusic()
		self:ShowTips(false)
		self:StopAnimation(self.AnimPlay)
		self:PlayAnimation(self.AnimStop)
		self:StopAnimation(self.AnimPlayLoop)
	end
end

--选择图谱item
function MusicAtlasMainView:OnAtlasItemSelectChanged(Index, ItemData, ItemView)
	--FLOG_ERROR("CurChoseAtlasID = %d", ItemData.MusicID)
	if self.IsCanDeal then
		_G.MusicPlayerMgr:RemoveSingleRedDot(ItemData.MusicID)
	end
	self.IsCanDeal = true
	MusicPlayerMgr.CurChoseAtlasID = ItemData.MusicID
	MusicPlayerMgr.CurMusicIndex = Index
	self.CurMusicIndex = Index
	--搜索时选中
	if self.IsSearching then
		self.SearchChosedMusicID = ItemData.MusicID
	end
	local Time = {}
	Time.CurTime = 0
	Time.TotalTime = MusicPlayerMgr:GetMusicTime(MusicPlayerMgr.CurChoseAtlasID)
	--暂时屏蔽
	--UIUtil.SetIsVisible(self.PanelBottomProbar, true)
	local IsUnlock = ItemData.IsUnLock
	self.ChoseAtlasUnlock = IsUnlock
	self.ViewModel.PanelRevertVisible = IsUnlock
	self.MusicAtlasProbarItem_UIBP:SetSliderLineVisiable(not IsUnlock, Time.TotalTime)
	self.ViewModel:UpdateChosedMusicName(MusicPlayerMgr.CurChoseAtlasID)
	--选择的ID和正在播放ID不一样不显示正在播放的进度条
	if MusicPlayerMgr.CurChoseAtlasID ~= MusicPlayerMgr.CurPlayingMusicID then
		MusicPlayerMgr.IsShowCurSlide = false
		self.ToggleBtnStart:SetChecked(false)
		self:SetTimeTextAndBar(Time)
		-- if MusicPlayerMgr.CurPlayingMusicID == nil then
		-- 	self.ViewModel:SetMaskVisible(false)
		-- else
		-- 	self.ViewModel:SetMaskVisible(true)
		-- end
		--self.ViewModel:SetMaskVisible(true)
		--self.MusicAtlasProbarItem_UIBP:SetSliderClickVisible(false)
	else
		MusicPlayerMgr.IsShowCurSlide = true
		Time.CurTime = MusicPlayerMgr.CurAtalsPlayTime
		Time.TotalTime = MusicPlayerMgr:GetMusicTime(MusicPlayerMgr.CurPlayingMusicID)
		self:SetTimeTextAndBar(Time)
		self.ToggleBtnStart:SetChecked(MusicPlayerMgr.AtlasPlayState)
		--self.ViewModel:SetMaskVisible(false)
		--self.MusicAtlasProbarItem_UIBP:SetSliderClickVisible(true)
	end

	local Info = {}
	if MusicPlayerMgr.CurPlayingMusicID then
		Info.IsShow = MusicPlayerMgr.IsShowCurSlide
		Info.CurPlayMusicID = MusicPlayerMgr.CurPlayingMusicID
	else
		Info.IsShow = true
	end

	self.ViewModel:UpdateBtnMusicName(Info)
	if not Info.IsShow then
		self:PlayAnimation(self.AnimNameContentIn)
	end
end

--点击已收录
function MusicAtlasMainView:OnSingleBoxClick(View, State)
	self.IsUnlock = State
	if self.IsUnlock == 1 then
		self:GetLockAtlasInfo()
		return
	else
		local List
		if self.IsSearching then
			List = self.CurSearchList or {}
		else
			List = self.CurAtlasList or {}
		end
		
		if #List > 0 then
			UIUtil.SetIsVisible(self.TableViewMusicList, true)
			self.ViewModel:ShowEmptyPanel(false)
			self.CurPage = 1
			self.MaxPage = math.ceil(#List / 10)
			self.ViewModel:UpdateItemInfo(List, self.CurPage)
			self.ViewModel:UpdatePageInfo(self.CurPage, self.MaxPage)
			--local Index = self:GetMusicIndex() or 1
			self.MusicAtlasList:SetSelectedIndex(1)
		else
			self.CurPage = 1
			self.ViewModel:UpdatePageInfo(1, 1)
		end
	end
end

--Tab栏选择
function MusicAtlasMainView:OnTabSelectChanged(Index, ItemData, ItemView)
	self.IsCanDeal = false
	if ItemData.RedDotData.RedDotName and ItemData.RedDotData.RedDotName ~= "" and self.CurTypeIndex ~= nil then
		_G.RedDotMgr:DelRedDotByName(ItemData.RedDotData.RedDotName)
	end
	if self.LastTabData and self.LastTabData.RedDotData.RedDotName and self.LastTabData.RedDotData.RedDotName ~= "" then
		_G.RedDotMgr:DelRedDotByName(self.LastTabData.RedDotData.RedDotName)
	end
	self.CurTypeIndex = Index
	MusicPlayerMgr.CurTypeIndex = Index
	if self.IsSearching then
		self:OnCancelSearchClicked(true)
		self.SearchBar:OnClickButtonCancel()
	end
	self:UpdateAtlasInfo()
	self.LastTabData = ItemData
	if self.RedUpdateList and #self.RedUpdateList > 0 then
		local CurType = self.TabList[self.CurTypeIndex].Type
		if not self.RedUpdateList[CurType] or #self.RedUpdateList[CurType] < 0 then
			return
		end
		local List = self.RedUpdateList[CurType]
		for i = 1, #List do
			for _, Info in ipairs(self.ViewModel.CurMusicAtlasList.Items) do
				local Item = Info
				if Item.MusicID == List[i] then
					Item.IsUnLock = true
					Item:SetPanel(Item.IsUnLock, Item.Number)
					Item:SetItemBGImgType(Item.IsUnLock, Item.Number)
					Item:SetName(Item.Number, Item.Name, Item.IsUnLock)
					_G.EventMgr:SendEvent(EventID.UpdateAtlasItemRed, Item.MusicID)
					local AllTypeList = MusicPlayerMgr:GetMusicTypeInfo(2)
					local NewList = MusicPlayerMgr:GetCurTypeRedDot(AllTypeList)
					self.TabList = NewList
					MusicPlayerMgr.AtlasTabList = NewList
					self.VerIconTabs:UpdateItems(NewList)
					local TotalNum = self:GetAllMusicNum(self.TabList)
					self.ViewModel:ShowGatherPercent(TotalNum)
				end
			end
		end
		self.RedUpdateList = nil
	end

end

function MusicAtlasMainView:UpdateAtlasInfo()
	if #self.LastChosedList > 0 then
		MusicPlayerMgr:RemoveCurTabTypeAllRedDot(self.LastChosedList)
	end
	local CurAtlasList = {}
	local TabListType = self.TabList and self.TabList[self.CurTypeIndex] or {}
	local CurType = TabListType.Type or 1
	if TabListType and CurType then
		CurAtlasList = MusicPlayerMgr:GetAtlasInfoByType(CurType)
	end

	local ListLen 
	if not CurAtlasList then
		ListLen = 0
	else
		ListLen = #CurAtlasList
	end
	self.CurAtlasList = CurAtlasList
	self.CurPage = 1

	if ListLen == 0 then
		self.ViewModel:ShowEmptyPanel(true)
	else
		self.ViewModel:ShowEmptyPanel(false)
	end
	if not self.SearchChosedMusicID then
		self.MaxPage = math.ceil(ListLen / 10)
		self.ViewModel:UpdateItemInfo(CurAtlasList, self.CurPage)
		self.ViewModel:SetPageInfo(self.CurPage, self.MaxPage)
		local Index = self:GetMusicIndex() or 1
		self.MusicAtlasList:SetSelectedIndex(Index)
	else
		local PageIndex
		local SelectIndex
		for i = 1, #CurAtlasList do
			if self.SearchChosedMusicID == CurAtlasList[i].MusicID then
				PageIndex = math.ceil(i / 10)
				SelectIndex = i - (PageIndex - 1) * 10
			end
		end
		self.SearchChosedMusicID = nil
		self.CurPage = PageIndex
		self.MaxPage = math.ceil(#CurAtlasList / 10)
		self.ViewModel:UpdateItemInfo(CurAtlasList, self.CurPage)
		self.ViewModel:SetPageInfo(self.CurPage, self.MaxPage)
		self.MusicAtlasList:SetSelectedIndex(SelectIndex)
	end
	self.ViewModel:SetSubTitle(CurType)
	self.LastChosedList = CurAtlasList
	
	if not self.IsOrgin then
		MusicPlayerMgr:RemoveCurTabTypeAllRedDot(CurAtlasList)
	end
	--MusicPlayerMgr:RemoveCurTabTypeAllRedDot(CurAtlasList)
	self.IsOrgin = false
end

--打开图鉴界面下解锁了新图鉴的话更新红点数据和图鉴状态
function MusicAtlasMainView:UpdateRedDot(List)
	local Len = #List
	local CurType = self.TabList[self.CurTypeIndex].Type
	for i = 1, Len do
		-- for _, Info in ipairs(self.ViewModel.CurMusicAtlasList.Items) do
		-- 	local Item = Info
		-- 	if Item.MusicID == List[i] then
		-- 		Item.IsUnLock = true
		-- 		Item:SetPanel(Item.IsUnLock, Item.Number)
		-- 		Item:SetItemBGImgType(Item.IsUnLock, Item.Number)
		-- 		Item:SetName(Item.Number, Item.Name, Item.IsUnLock)
		-- 		_G.EventMgr:SendEvent(EventID.UpdateAtlasItemRed, Item.MusicID)
		-- 		local AllTypeList = MusicPlayerMgr:GetMusicTypeInfo(2)
		-- 		local NewList = MusicPlayerMgr:GetCurTypeRedDot(AllTypeList)
		-- 		self.TabList = NewList
		-- 		MusicPlayerMgr.AtlasTabList = NewList
		-- 		self.VerIconTabs:UpdateItems(NewList)
		-- 		local TotalNum = self:GetAllMusicNum(self.TabList)
		-- 		self.ViewModel:ShowGatherPercent(TotalNum)
		-- 	end
		-- end

		for _, V in ipairs(MusicPlayerMgr.AllTypeMusic) do
			for Index, Value in ipairs(V) do
				if Value.MusicID == List[i] then
					if CurType == Value.PlayType then
						local Item = self.ViewModel.CurMusicAtlasList.Items[Index]
						if Item then
							self:UpdateItemsRed(Item, Value.MusicID)
						end
					else
						self.RedUpdateList = {}
						self.RedUpdateList[CurType] = {}
						table.insert(self.RedUpdateList[CurType], Value.MusicID)
						_G.EventMgr:SendEvent(EventID.UpdateAtlasItemRed, Value.MusicID)
						local AllTypeList = MusicPlayerMgr:GetMusicTypeInfo(2)
						local NewList = MusicPlayerMgr:GetCurTypeRedDot(AllTypeList)
						self.TabList = NewList
						MusicPlayerMgr.AtlasTabList = NewList
						self.VerIconTabs:UpdateItems(NewList)
						local TotalNum = self:GetAllMusicNum(self.TabList)
						self.ViewModel:ShowGatherPercent(TotalNum)
					end
				end
			end
		end
	end
end

function MusicAtlasMainView:UpdateItemsRed(Item, MusicId)
	Item.IsUnLock = true
	Item:SetPanel(Item.IsUnLock, Item.Number)
	Item:SetItemBGImgType(Item.IsUnLock, Item.Number)
	Item:SetName(Item.Number, Item.Name, Item.IsUnLock)
	if MusicPlayerMgr.CurChoseAtlasID ~= MusicId then
		Item.NormalSelect = false
	end
	_G.EventMgr:SendEvent(EventID.UpdateAtlasItemRed, Item.MusicID)
	local AllTypeList = MusicPlayerMgr:GetMusicTypeInfo(2)
	local NewList = MusicPlayerMgr:GetCurTypeRedDot(AllTypeList)
	self.TabList = NewList
	MusicPlayerMgr.AtlasTabList = NewList
	self.VerIconTabs:UpdateItems(NewList)
	local TotalNum = self:GetAllMusicNum(self.TabList)
	self.ViewModel:ShowGatherPercent(TotalNum)
end

function MusicAtlasMainView:ClickLastPage()
	self.CurPage = self.CurPage - 1
	if self.CurPage < 1 then
		self.CurPage = 1
		-- local Tips = LSTR(1170002)
		-- MsgTipsUtil.ShowTips(Tips)
		return
	end
	AudioUtil.LoadAndPlay2DSound(TurnSoundPath)
	self:PlayAnimation(self.AnimPageturnRight)
	local function AfterAnimFinish()
		self.ViewModel:UpdateItemInfo(self.CurAtlasList, self.CurPage)
		self.ViewModel:UpdatePageInfo(self.CurPage, self.MaxPage)
		local Index = self:GetMusicIndex()
		self.MusicAtlasList:SetSelectedIndex(Index)
		self.AnimTimerID = nil
    end
    self.AnimTimerID = _G.TimerMgr:AddTimer(nil, AfterAnimFinish, 0.25, 0, 1)
end

function MusicAtlasMainView:ClickNextPage()
	self.CurPage = self.CurPage + 1
	if self.CurPage > self.MaxPage then
		self.CurPage = self.MaxPage
		-- local Tips = LSTR(1170001)
		-- MsgTipsUtil.ShowTips(Tips)
		return
	end
	AudioUtil.LoadAndPlay2DSound(TurnSoundPath)
	self:PlayAnimation(self.AnimPageturnLeft)

    local function AfterAnimFinish()
		self.ViewModel:UpdateItemInfo(self.CurAtlasList, self.CurPage)
		self.ViewModel:UpdatePageInfo(self.CurPage, self.MaxPage)
		local Index = self:GetMusicIndex()
		self.MusicAtlasList:SetSelectedIndex(Index)
		self.AnimTimerID = nil
    end
    self.AnimTimerID = _G.TimerMgr:AddTimer(nil, AfterAnimFinish, 0.25, 0, 1)

end

function MusicAtlasMainView:OnCloseView()
	self:ClearInfo()
	self:Hide()
end

function MusicAtlasMainView:GetMusicIndex()
	local Index = nil
	local CurChoseAtlasID = MusicPlayerMgr.CurChoseAtlasID
	local List = self.ViewModel.CurPageAtlasList
	
	if List == nil or CurChoseAtlasID == nil then
		return nil
	end

	for i = 1, #List do
		if CurChoseAtlasID == List[i].MusicID then
			Index = i
			return Index
		end
	end

	return Index
end

function MusicAtlasMainView:SetTimeTextAndBar(Time)
	if Time == nil then
		return
	end
	local CurTime = Time.CurTime
	local TotalTime = Time.TotalTime

	self.ViewModel:SetTimeTextAndBar(CurTime, TotalTime)
	self.ChangedPercent = self.ViewModel.Percent
	if CurTime % 5 == 0 and MusicPlayerMgr.AtlasPlayState and CurTime ~= 0 then
		self:PlayAnimation(self.AnimPlayLoop)
	end
	--FLOG_ERROR("TestTime = %d", CurTime)
	--需要配置试听时间
	local LimitTime 
	if self.CurPlayingMusicIsUnlock then
		LimitTime = TotalTime
		if CurTime > LimitTime then
			--MusicPlayerMgr.CurPlayingMusicID = nil
			--MusicPlayerMgr:StopCurMusic()
			--self.ViewModel:StopPlayChoseMusic()
			--self.PlayState = not self.PlayState
			--self.ToggleBtnStart:SetChecked(self.PlayState)
			MusicPlayerMgr.CurAtalsPlayTime = 0
			self.ViewModel:SetMusicSlideByPrecent(0)
			return
		end
	else
		LimitTime = 30
		if CurTime > LimitTime then
			MusicPlayerMgr.CurAtalsPlayTime = 0
			self.ViewModel:SetMusicSlideByPrecent(0)
			--local Tips = LSTR(1170008)
			--MsgTipsUtil.ShowTips(Tips)
			return
		end
	end
end

function MusicAtlasMainView:RestPlayCurMusic()
	MusicPlayerMgr.CurAtalsPlayTime = 0
	self.ViewModel:SetMusicSlideByPrecent(0)
end

function MusicAtlasMainView:JumpToCurPlayMusic()
	self:PlayAnimation(self.AnimNameContentSelect)
	local CurAtlasList = MusicPlayerMgr:GetAtlasInfoByType(self.TabList[self.ViewModel.CurPlayTypeIndex].Type)
	self.CurAtlasList = CurAtlasList
	self.CurTypeIndex = self.ViewModel.CurPlayTypeIndex
	self.VerIconTabs:SetSelectedIndex(self.CurTypeIndex)
	self.CurPage = self.ViewModel.CurPlayMusicPage
	if #CurAtlasList == 0 then
		self.ViewModel:ShowEmptyPanel(true)
	else
		self.ViewModel:ShowEmptyPanel(false)
	end
	self.MaxPage = math.ceil(#CurAtlasList / 10)
	self.ViewModel:UpdateItemInfo(CurAtlasList, self.ViewModel.CurPlayMusicPage)
	self.ViewModel:SetPageInfo(self.ViewModel.CurPlayMusicPage, self.MaxPage)

	self.MusicAtlasList:SetSelectedIndex(0)
	local Index = 1
	local CurPlayingMusicID = MusicPlayerMgr.CurPlayingMusicID
	local CurPageAtlasList = self.ViewModel.CurPageAtlasList
	for i = 1, #CurPageAtlasList do
		if CurPlayingMusicID == CurPageAtlasList[i].MusicID then
			Index = i
		end
	end

	self.MusicAtlasList:SetSelectedIndex(Index)
	-- if self.IsSearching then
	-- 	self.SearchBar:OnClickButtonCancel()
	-- end
end

function MusicAtlasMainView:ShowGatherPanel()
	local GatherList = {}
	GatherList.Progress = self.ViewModel.AllUnlockAtalsNum
	GatherList.MaxCount = self.ViewModel.AllAtalsNum
	MusicPlayerMgr:SendMsgGetRecordList(GatherList, true)
end

function MusicAtlasMainView:GetLockAtlasInfo()
	local HasUnlockList = {}
	local List
	if self.IsSearching then
		List = self.CurSearchList
	else
		List = self.CurAtlasList
	end


	if List then
		for i = 1, #List do
			if not List[i].IsUnLock then
				table.insert(HasUnlockList, List[i])
			end
		end
	end

	if #HasUnlockList == 0 then
		self.ViewModel:UpdatePageInfo(1, 1)
		self.ViewModel:ShowEmptyPanel(true)
		local Tips = RichTextUtil.GetText(LSTR(1170016), "#313131FF")
		self.CommEmpty:SetTipsContent(LSTR(1170016))--暂无未收录的乐谱，快去找找吧库啵!
		UIUtil.SetIsVisible(self.TableViewMusicList, false)
	else
		UIUtil.SetIsVisible(self.TableViewMusicList, true)
		self.CurPage = 1
		self.MaxPage = math.ceil(#HasUnlockList / 10)
		self.ViewModel:UpdatePageInfo(self.CurPage, self.MaxPage)
		self.ViewModel:ShowEmptyPanel(false)
		self.ViewModel:UpdateItemInfo(HasUnlockList, self.CurPage)
		local Index = self:GetMusicIndex() or 1
		self.MusicAtlasList:SetSelectedIndex(Index)
	end
end


function MusicAtlasMainView:GetUnlockAtlasInfo()
	local HasUnlockList = {}
	local List
	if self.IsSearching then
		List = self.CurSearchList
	else
		List = self.CurAtlasList
	end

	if List then
		for i = 1, #List do
			if List[i].IsUnLock then
				table.insert(HasUnlockList, List[i])
			end
		end
	end

	if #HasUnlockList == 0 then
		self.ViewModel:UpdatePageInfo(1, 1)
		self.ViewModel:ShowEmptyPanel(true)
		UIUtil.SetIsVisible(self.TableViewMusicList, false)
	else
		UIUtil.SetIsVisible(self.TableViewMusicList, true)
		self.CurPage = 1
		self.MaxPage = math.ceil(#HasUnlockList / 10)
		self.ViewModel:UpdatePageInfo(self.CurPage, self.MaxPage)
		self.ViewModel:ShowEmptyPanel(false)
		self.ViewModel:UpdateItemInfo(HasUnlockList, self.CurPage)
		local Index = self:GetMusicIndex() or 1
		self.MusicAtlasList:SetSelectedIndex(Index)
	end
end

function MusicAtlasMainView:ClearInfo()
	self:StopAnimation(self.AnimPlay)
	self:StopAnimation(self.AnimPlayLoop)
	self:StopAnimation(self.AnimPlayStaff)
	MusicPlayerMgr.AtlasPlayState = false
	self.PlayState = false
	local Time = {}
	Time.CurTime = 0
	Time.TotalTime = 0
	self.SetTimeTextAndBar(Time)

	if self.OpenType ~= 2 then
		self.ViewModel:StopPlayChoseMusic()
		MusicPlayerMgr:ClearAtlasInfo()
	end
end

function MusicAtlasMainView:ShowTips(Value)
	if self.OpenType == 2 then
		if Value then
			local Name = MusicPlayerCfg:FindCfgByKey(MusicPlayerMgr.CurChoseAtlasID).MusicName
			MsgTipsUtil.ShowTipsByID(MsgTipsID.MusicPlay, nil, Name)	
		else
			local Name = MusicPlayerCfg:FindCfgByKey(MusicPlayerMgr.CurChoseAtlasID).MusicName
			MsgTipsUtil.ShowTipsByID(MsgTipsID.MusicStop, nil, Name)
		end
	end
end 

function MusicAtlasMainView:OnSearchCommit(Text)
	if Text == "" or Text == nil then
		return
	end
	self.IsSearching = true
	local result = self.ViewModel:MatchMusic(Text)
	self.CurSearchList = result
	if #result > 0 then
		local EmptyVisible = UIUtil.IsVisible(self.PanelEmpty)
		if EmptyVisible then
			UIUtil.SetIsVisible(self.TableViewMusicList, true)
			self.ViewModel:ShowEmptyPanel(false)
		end
		self.VerIconTabs:SetSelectedIndex(0)
		self.MaxPage = math.ceil(#result / 10)
		self.ViewModel:UpdatePageInfo(1, self.MaxPage)
		self.ViewModel:UpdateItemInfo(result, 1)
		self.MusicAtlasList:SetSelectedIndex(1)
		self.ViewModel:SetSubTitle(self.CurTypeIndex, true)
	else
		UIUtil.SetIsVisible(self.TableViewMusicList, false)
		self.ViewModel:ShowEmptyPanel(true)
	end

	local SingleBoxState = self.SingleBox:GetChecked()
	if SingleBoxState then
		self.SingleBox:SetChecked(false)
		self:OnSingleBoxClick(self, false)
	end
end

function MusicAtlasMainView:SetSearchBarHintText()
	self.SearchBar:SetHintText(LSTR(1170011)) --搜索乐谱或编号
	self.CommEmpty:SetTipsContent(LSTR(1170006))
end

function MusicAtlasMainView:OnCancelSearchClicked(IsUpdateList)
	if not self.IsSearching then
		return
	end
	self.IsSearching = false
	local EmptyVisible = UIUtil.IsVisible(self.PanelEmpty)
	local TableViewMusicList = UIUtil.IsVisible(self.TableViewMusicList)
	if EmptyVisible then
		self.ViewModel:ShowEmptyPanel(false)
		self.TextEmpty:SetText(LSTR(1170004))
	end

	if not TableViewMusicList then
		UIUtil.SetIsVisible(self.TableViewMusicList, true)
		local SingleBoxState = self.SingleBox:GetChecked()
		if SingleBoxState then
			self.SingleBox:SetChecked(false)
			self:OnSingleBoxClick(self, false)
		end
	else
		if self.SearchChosedMusicID then
			self:JumpToSeachMusic()
			self.SearchBar:OnClickButtonCancel()
			return
		end
		if IsUpdateList then
			self.SearchBar:OnClickButtonCancel()
		end
	end
end

function MusicAtlasMainView:UpdateCurSearchPage()
	-- self.ViewModel:UpdateItemInfo(self.CurAtlasList, self.CurPage)
	-- if #self.CurSearchList < 1 then
	-- 	self.ViewModel:SetSubTitle(self.CurTypeIndex)
	-- 	self.MusicAtlasList:SetSelectedIndex(1)
	-- end
end

function MusicAtlasMainView:JumpToSeachMusic()
	for _, V in ipairs(MusicPlayerMgr.AllAtlasInfoList) do
		for _, Info in pairs(V) do
			if Info.MusicID == self.SearchChosedMusicID then
				self.CurTypeIndex = MusicPlayerMgr:GetTypeIndexByTabList(self.TabList, Info.PlayType) or 1
				self.VerIconTabs:SetSelectedIndex(self.CurTypeIndex)
				return
			end
		end
	end
end

function MusicAtlasMainView:GetAllMusicNum(TabList)
	local TotalNam = 0
	for _, Info in pairs(TabList) do
	    local CurAtlasList = MusicPlayerMgr:GetAtlasInfoByType(Info.Type)
		MusicPlayerMgr.AllTypeMusic[Info.Type] = CurAtlasList
		TotalNam = TotalNam + #CurAtlasList
	end
	return TotalNam
end

function MusicAtlasMainView:OnClickBtnGetWay()
	if UIViewMgr:IsViewVisible(UIViewID.CommGetWayTipsView) then
		UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
	else
		local BtnSize = UIUtil.CanvasSlotGetSize(self.BtnGetWay)
		TipsUtil.ShowGetWayTips(self.ViewModel, nil, self.BtnGetWay, _G.UE.FVector2D(BtnSize.X, -30), _G.UE.FVector2D(1, -0.5), false)
	end
end

function MusicAtlasMainView:OpenRevertPanelView()
	MusicPlayerMgr:OpenRevertPanelView()
end

return MusicAtlasMainView