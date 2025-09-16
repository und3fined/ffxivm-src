---
--- Author: Administrator
--- DateTime: 2024-03-19 11:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local DiscoverNoteVM = require("Game/SightSeeingLog/DiscoverNoteVM")
local DiscoverNoteMgr = require("Game/SightSeeingLog/DiscoverNoteMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetMaterialTextureFromAssetPath = require("Binder/UIBinderSetMaterialTextureFromAssetPath")
local UIBinderSetMaterialVectorParameterValue = require("Binder/UIBinderSetMaterialVectorParameterValue")
local UIBinderSetMaterialScalarParameterValue = require("Binder/UIBinderSetMaterialScalarParameterValue")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local DiscoverNoteDefine = require("Game/SightSeeingLog/DiscoverNoteDefine")
local DiscoverNoteCfg = require("TableCfg/DiscoverNoteCfg")
local NoteClueType = DiscoverNoteDefine.NoteClueType

local LSTR = _G.LSTR

---@class SightSeeingLogMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field BtnSkip UFButton
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonGuideBG CommonGuideBkgView
---@field FImagePhoto UFImage
---@field FImagePhotoDark UFImage
---@field ImgAct UFImage
---@field ImgLock01 UFImage
---@field ImgLock02 UFImage
---@field ImgLock03 UFImage
---@field ImgPhotoFrameNormal UFImage
---@field ImgWeather UFImage
---@field ImgWeather_1 UFImage
---@field MI_DX_Transform_SightSeeing_1a UFImage
---@field MI_DX_Transform_SightSeeing_1b UFImage
---@field MI_DX_Transform_SightSeeing_1c UFImage
---@field PanelAct UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelLeftPhoto UFCanvasPanel
---@field PanelLocalicon UFCanvasPanel
---@field PanelRecord UFCanvasPanel
---@field PanelRightEmpty UFCanvasPanel
---@field PanelTime UFCanvasPanel
---@field PanelUnlock01 UFCanvasPanel
---@field PanelUnlock02 UFCanvasPanel
---@field PanelUnlock03 UFCanvasPanel
---@field PanelWeather UFCanvasPanel
---@field SingleBox CommSingleBoxView
---@field SizeBoxWeather01 USizeBox
---@field SizeBoxWeather02 USizeBox
---@field TableViewList UTableView
---@field TextAct UFTextBlock
---@field TextLeftEmpty UFTextBlock
---@field TextNone UFTextBlock
---@field TextPlace UFTextBlock
---@field TextRecord UFTextBlock
---@field TextRecord02 UFTextBlock
---@field TextRecord03 UFTextBlock
---@field TextServer UFTextBlock
---@field TextSubtitle UFTextBlock
---@field TextTime UFTextBlock
---@field TextTime_1 UFTextBlock
---@field TextTitleName UFTextBlock
---@field TextUnlock01 UFTextBlock
---@field TextUnlock02 UFTextBlock
---@field TextUnlock03 UFTextBlock
---@field TextWeather UFTextBlock
---@field ToggleButton_57 UToggleButton
---@field VerIconTabs CommVerIconTabsView
---@field AnimIn UWidgetAnimation
---@field AnimIn_0 UWidgetAnimation
---@field AnimRefresh UWidgetAnimation
---@field AnimUnlock1 UWidgetAnimation
---@field AnimUnlock2 UWidgetAnimation
---@field AnimUnlock3 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SightSeeingLogMainView = LuaClass(UIView, true)

function SightSeeingLogMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.BtnSkip = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonGuideBG = nil
	--self.FImagePhoto = nil
	--self.FImagePhotoDark = nil
	--self.ImgAct = nil
	--self.ImgLock01 = nil
	--self.ImgLock02 = nil
	--self.ImgLock03 = nil
	--self.ImgPhotoFrameNormal = nil
	--self.ImgWeather = nil
	--self.ImgWeather_1 = nil
	--self.MI_DX_Transform_SightSeeing_1a = nil
	--self.MI_DX_Transform_SightSeeing_1b = nil
	--self.MI_DX_Transform_SightSeeing_1c = nil
	--self.PanelAct = nil
	--self.PanelInfo = nil
	--self.PanelLeftPhoto = nil
	--self.PanelLocalicon = nil
	--self.PanelRecord = nil
	--self.PanelRightEmpty = nil
	--self.PanelTime = nil
	--self.PanelUnlock01 = nil
	--self.PanelUnlock02 = nil
	--self.PanelUnlock03 = nil
	--self.PanelWeather = nil
	--self.SingleBox = nil
	--self.SizeBoxWeather01 = nil
	--self.SizeBoxWeather02 = nil
	--self.TableViewList = nil
	--self.TextAct = nil
	--self.TextLeftEmpty = nil
	--self.TextNone = nil
	--self.TextPlace = nil
	--self.TextRecord = nil
	--self.TextRecord02 = nil
	--self.TextRecord03 = nil
	--self.TextServer = nil
	--self.TextSubtitle = nil
	--self.TextTime = nil
	--self.TextTime_1 = nil
	--self.TextTitleName = nil
	--self.TextUnlock01 = nil
	--self.TextUnlock02 = nil
	--self.TextUnlock03 = nil
	--self.TextWeather = nil
	--self.ToggleButton_57 = nil
	--self.VerIconTabs = nil
	--self.AnimIn = nil
	--self.AnimIn_0 = nil
	--self.AnimRefresh = nil
	--self.AnimUnlock1 = nil
	--self.AnimUnlock2 = nil
	--self.AnimUnlock3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SightSeeingLogMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonGuideBG)
	self:AddSubView(self.SingleBox)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SightSeeingLogMainView:InitConstStringInfo()
	self.TextTitleName:SetText(LSTR(330015))
	self.TextLeftEmpty:SetText(LSTR(330016))
	self.TextServer:SetText(LSTR(330019))
	self.TextNone:SetText(LSTR(330020))
end

function SightSeeingLogMainView:InitSubViewConstStringInfo()
	self.SingleBox:SetText(LSTR(330017))
end

function SightSeeingLogMainView:OnInit()
	self.TableViewListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectedLocationIconChanged, true)
	self.Binders = {
		{"NoteIconItems", UIBinderUpdateBindableList.New(self, self.TableViewListAdapter)},
		{"RegionName", UIBinderSetText.New(self, self.TextSubtitle)},
		{"NoteMapName", UIBinderSetText.New(self, self.TextPlace)},
		{"TypeTitle", UIBinderSetText.New(self, self.TextRecord)},
		{"NoteTitle", UIBinderSetText.New(self, self.TextRecord02)},
		{"NoteContentText", UIBinderSetText.New(self, self.TextRecord03)},
		{"DiscoverNumAndTotalText", UIBinderSetText.New(self, self.TextTime)},
		{"bShowNotCompleted", UIBinderSetIsChecked.New(self, self.SingleBox)},
		{"bShowNoteRecord", UIBinderSetIsChecked.New(self, self.ToggleButton_57, nil, true)},
		{"bCheckBoxShowRecordVisible", UIBinderSetIsVisible.New(self, self.ToggleButton_57, nil, true)},
		{"bShowPanelRecord", UIBinderSetIsVisible.New(self, self.PanelRecord)},
		{"bLeftPhotoShow", UIBinderSetIsVisible.New(self, self.PanelLeftPhoto)},
		{"bShowNoteRecord", UIBinderSetIsVisible.New(self, self.TextRecord02)},
		{"bShowNoteRecord", UIBinderSetIsVisible.New(self, self.ImgPhotoFrameNormal, true)},
		{"bPanelHintShow", UIBinderSetIsVisible.New(self, self.PanelInfo)},
		{"bLeftPhotoShow", UIBinderSetIsVisible.New(self, self.TextLeftEmpty, true)},
		{"LocationImgPath", UIBinderSetMaterialTextureFromAssetPath.New(self, self.FImagePhoto, "MainTexture")},
		{"bEnterFromGuideMain", UIBinderSetIsVisible.New(self, self.BtnBack, nil, true)},
		{"bEnterFromGuideMain", UIBinderSetIsVisible.New(self, self.BtnClose, true, true)},
		{"bShowRightListEmpty", UIBinderSetIsVisible.New(self, self.PanelRightEmpty)},
		{"RefreshRightListAnimSwitch", UIBinderValueChangedCallback.New(self, nil, self.OnPlayAnimNotify)},
		{"NoteListScrollIndex", UIBinderValueChangedCallback.New(self, nil, self.OnTableViewListScrollNotify)},
		{"ScrollToTheHeadSwitch", UIBinderValueChangedCallback.New(self, nil, self.OnTableViewListScrollHead)},
		{"Color", UIBinderSetMaterialVectorParameterValue.New(self, self.FImagePhoto, "Color")},
		{"Tint", UIBinderSetMaterialScalarParameterValue.New(self, self.FImagePhoto, "Tint")},
		{"Int", UIBinderSetMaterialScalarParameterValue.New(self, self.FImagePhoto, "Int")},
		{"Opacity", UIBinderSetMaterialScalarParameterValue.New(self, self.FImagePhoto, "Opacity")},
		{"IsRealWeatherUnLock", UIBinderSetIsVisible.New(self, self.PanelWeather)},
		{"IsRealWeatherUnLock", UIBinderSetIsVisible.New(self, self.PanelUnlock02, true)},
		{"IsRealTimeUnLock", UIBinderSetIsVisible.New(self, self.PanelTime)},
		{"IsRealTimeUnLock", UIBinderSetIsVisible.New(self, self.PanelUnlock01, true)},
		{"IsEmotionIDUnLock", UIBinderSetIsVisible.New(self, self.PanelAct)},
		{"IsEmotionIDUnLock", UIBinderSetIsVisible.New(self, self.PanelUnlock03, true)},
		{"WeatherLockText", UIBinderSetText.New(self, self.TextUnlock02)},
		{"TimeLockText", UIBinderSetText.New(self, self.TextUnlock01)},
		{"EmotionIDLockText", UIBinderSetText.New(self, self.TextUnlock03)},
		{"bWeatherUnLockAnimPlay", UIBinderValueChangedCallback.New(self, nil, self.OnPlayAnimWeatherUnlock)},
		{"bTimeUnLockAnimPlay", UIBinderValueChangedCallback.New(self, nil, self.OnPlayAnimTimeUnlock)},
		{"bEmotionIDUnLockAnimPlay", UIBinderValueChangedCallback.New(self, nil, self.OnPlayAnimEmotionUnlock)},
		{"bWeatherImgFirstShow", UIBinderSetIsVisible.New(self, self.SizeBoxWeather01)},
		{"bWeatherImgSecondShow", UIBinderSetIsVisible.New(self, self.SizeBoxWeather02)},
		{"WeatherImgFirst", UIBinderSetBrushFromAssetPath.New(self, self.ImgWeather)},
		{"WeatherImgSecond", UIBinderSetBrushFromAssetPath.New(self, self.ImgWeather_1)},
		{"EmotionImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgAct)},
		{"WeatherName", UIBinderSetText.New(self, self.TextWeather)},
		{"TimeText", UIBinderSetText.New(self, self.TextTime_1)},
		{"EmotionName", UIBinderSetText.New(self, self.TextAct)},
		{"bLocationBtnShow", UIBinderSetIsVisible.New(self, self.PanelLocalicon)},
		{"SelectedNoteID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectedNoteIDChanged)},
		{"bShowPerfectCondEffect", UIBinderValueChangedCallback.New(self, nil, self.OnShowOrHidePerfectCondEffect)},
	}
	self:InitConstStringInfo()

	self.UnlockWeatherTimer = nil -- 天气解锁动画计时器
	self.UnlockTimeTimer = nil -- 时间解锁动画计时器
	self.UnlockEmotionTimer = nil -- 情感动作解锁动画计时器
end

function SightSeeingLogMainView:OnDestroy()

end

function SightSeeingLogMainView:OnShow()
	self:InitSubViewConstStringInfo()
	self:CreateRegionList()
end

function SightSeeingLogMainView:OnHide()
	DiscoverNoteMgr:ClearRegionTabUnlockRedDot()
	DiscoverNoteMgr:ClearNoteItemUnlockRedDot()
	DiscoverNoteMgr:StopUpdatePerfectCondTimer()
	DiscoverNoteVM:ClearSelectedNoteID()
	self.LastSelectedNote = nil
end

function SightSeeingLogMainView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnVerIconTabsChg)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnSingleBoxCheckStateChanged)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButton_57, self.OnToggleButtonStateChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnSkip, self.OnBtnSkipClicked)
	self.BtnBack:AddBackClick(self, function(e) e:Hide() end)
end

function SightSeeingLogMainView:OnRegisterGameEvent()

end

function SightSeeingLogMainView:OnRegisterBinder()
	self:RegisterBinders(DiscoverNoteVM, self.Binders)
end

function SightSeeingLogMainView:OnSelectedNoteIDChanged(NoteID, OldNoteID)
	if not NoteID then
		return
	end

	if NoteID == OldNoteID then
		return
	end

	DiscoverNoteMgr:SelectedChangeUpdateSingleNoteInfo(NoteID)
end


function SightSeeingLogMainView:OnVerIconTabsChg(_, ItemData, _, _)
	local RegionID = ItemData.ID
	if RegionID then
		DiscoverNoteMgr:ChangeTheRegionTab(RegionID)
		_G.ObjectMgr:CollectGarbage(false)
	end
end

function SightSeeingLogMainView:OnSelectedLocationIconChanged(_, ItemData, _, _)
	local CurItemID = ItemData.ItemID
	if CurItemID then
		self:CheckClueUnlockAnimIsPlaying()
		DiscoverNoteVM:ChangeSelectedNote(CurItemID)
        _G.ObjectMgr:CollectGarbage(false)
	end
end

function SightSeeingLogMainView:OnBtnSkipClicked()
	local NoteID = DiscoverNoteVM.SelectedNoteID
	if not NoteID then
		return
	end

	local NoteCfg = DiscoverNoteCfg:FindCfgByKey(NoteID)
	if not NoteCfg then
		return
	end

	local MapID = NoteCfg.MapID or 0
	local EobjResID = NoteCfg.EobjID or 0
	_G.WorldMapMgr:ShowWorldMapLocationEObj(MapID, EobjResID, true)
end

function SightSeeingLogMainView:OnTableViewListScrollHead(NewValue, OldValue)
	if OldValue == nil then
		return
	end

	if NewValue == OldValue then
		return
	end

	local Adapter = self.TableViewListAdapter
	if not Adapter then
		return
	end

	Adapter:ScrollToIndex(1)
end

function SightSeeingLogMainView:OnSingleBoxCheckStateChanged()
	DiscoverNoteMgr:ChangeTheCheckBoxCompleteState()
end

function SightSeeingLogMainView:OnToggleButtonStateChanged()
	DiscoverNoteVM:ChangeShowNoteRecord()
end

function SightSeeingLogMainView:OnPlayAnimWeatherUnlock(NewValue)
	if NewValue then
		local AnimWeatherUnlock = self.AnimUnlock2
		if not AnimWeatherUnlock then
			return
		end
		self:PlayAnimation(AnimWeatherUnlock, 0, 1, nil, 1, true)
		DiscoverNoteVM.bWeatherUnLockAnimPlay = false
		DiscoverNoteMgr:ClearNoteClueUnlockRecord(DiscoverNoteVM.SelectedNoteID, NoteClueType.Weather)
		local UnlockWeatherTimer = self.UnlockWeatherTimer
		if UnlockWeatherTimer then
			self:UnRegisterTimer(UnlockWeatherTimer)
		end
		local DelayTime = AnimWeatherUnlock:GetEndTime()
		self.UnlockWeatherTimer = self:RegisterTimer(function()
			DiscoverNoteVM:SetTheClueLockState(NoteClueType.Weather, true)
			UIUtil.SetRenderOpacity(self.PanelUnlock02, 1)
			self.UnlockWeatherTimer = nil
		end, DelayTime)
	else
		--self:PlayAnimationTimeRange(self.AnimUnlock2, 0.0, 0.01, 1, nil, 1.0, false)
	end
end

function SightSeeingLogMainView:OnPlayAnimTimeUnlock(NewValue)
	if NewValue then
		local AnimTimeUnlock = self.AnimUnlock1
		if not AnimTimeUnlock then
			return
		end
		self:PlayAnimation(AnimTimeUnlock, 0, 1, nil, 1, true)
		DiscoverNoteVM.bTimeUnLockAnimPlay = false
		DiscoverNoteMgr:ClearNoteClueUnlockRecord(DiscoverNoteVM.SelectedNoteID, NoteClueType.Time)
		local UnlockTimeTimer = self.UnlockTimeTimer
		if UnlockTimeTimer then
			self:UnRegisterTimer(UnlockTimeTimer)
		end
		local DelayTime = AnimTimeUnlock:GetEndTime()
		self.UnlockTimeTimer = self:RegisterTimer(function()
			DiscoverNoteVM:SetTheClueLockState(NoteClueType.Time, true)
			UIUtil.SetRenderOpacity(self.PanelUnlock01, 1)
			self.UnlockTimeTimer = nil
		end, DelayTime)
	else
		--self:PlayAnimationTimeRange(self.AnimUnlock1, 0.0, 0.01, 1, nil, 1.0, false)
	end
end

function SightSeeingLogMainView:OnPlayAnimEmotionUnlock(NewValue)
	if NewValue then
		local AnimEmotionUnlock = self.AnimUnlock3
		if not AnimEmotionUnlock then
			return
		end
		self:PlayAnimation(AnimEmotionUnlock, 0, 1, nil, 1, true)
		DiscoverNoteVM.bEmotionIDUnLockAnimPlay = false
		DiscoverNoteMgr:ClearNoteClueUnlockRecord(DiscoverNoteVM.SelectedNoteID, NoteClueType.Emotion)
		local UnlockEmotionTimer = self.UnlockEmotionTimer
		if UnlockEmotionTimer then
			self:UnRegisterTimer(UnlockEmotionTimer)
		end
		local DelayTime = AnimEmotionUnlock:GetEndTime()
		self.UnlockEmotionTimer = self:RegisterTimer(function()
			DiscoverNoteVM:SetTheClueLockState(NoteClueType.Emotion, true)
			UIUtil.SetRenderOpacity(self.PanelUnlock03, 1)
			self.UnlockEmotionTimer = nil
		end, DelayTime)
	else
		--self:PlayAnimationTimeRange(self.AnimUnlock3, 0.0, 0.01, 1, nil, 1.0, false)
	end
end

--- 检查是否有线索解锁动画需要停止（数据层变化脱离表现，直接停止就行）
function SightSeeingLogMainView:CheckClueUnlockAnimIsPlaying()
	local AnimWeatherUnlock = self.AnimUnlock2
	if AnimWeatherUnlock then
		if self:IsAnimationPlaying(AnimWeatherUnlock) then
			self:StopAnimation(AnimWeatherUnlock)
			local UnlockWeatherTimer = self.UnlockWeatherTimer
			if UnlockWeatherTimer then
				self:UnRegisterTimer(UnlockWeatherTimer)
			end
		end
	end

	local AnimTimeUnlock = self.AnimUnlock1
	if AnimTimeUnlock then
		if self:IsAnimationPlaying(AnimTimeUnlock) then
			self:StopAnimation(AnimTimeUnlock)
			local UnlockTimeTimer = self.UnlockTimeTimer
			if UnlockTimeTimer then
				self:UnRegisterTimer(UnlockTimeTimer)
			end
		end
	end

	local AnimEmotionUnlock = self.AnimUnlock3
	if AnimEmotionUnlock then
		if self:IsAnimationPlaying(AnimEmotionUnlock) then
			self:StopAnimation(AnimEmotionUnlock)
			local UnlockEmotionTimer = self.UnlockEmotionTimer
			if UnlockEmotionTimer then
				self:UnRegisterTimer(UnlockEmotionTimer)
			end
		end
	end
end

--- 创建左侧地域页签
function SightSeeingLogMainView:CreateRegionList()
	local ListData, SelectedIndex = DiscoverNoteMgr:MakeTheRegionData()
	if not ListData then
		return
	end
	local RegionList = {}
	for _, value in ipairs(ListData) do
		local RegionID = value.RegionID
		table.insert(RegionList, RegionID)
	end
	self.RegionList = RegionList
	self.VerIconTabs:UpdateItems(ListData, SelectedIndex)
end

function SightSeeingLogMainView:OnPlayAnimNotify()
	self:PlayAnimation(self.AnimRefresh)
end

function SightSeeingLogMainView:OnTableViewListScrollNotify(NoteListScrollIndex, OldValue)
	if NoteListScrollIndex == OldValue then
		return
	end

	local Adapter = self.TableViewListAdapter
	if not Adapter then
		return
	end

	local NoteItemIdPointed = DiscoverNoteVM.NoteItemIdPointed
	if not NoteItemIdPointed then
		return
	end

	if not NoteListScrollIndex or type(NoteListScrollIndex) ~= "number" then
		return
	end
	Adapter:ScrollToIndex(NoteListScrollIndex)
end

function SightSeeingLogMainView:OnShowOrHidePerfectCondEffect(bShow)
	UIUtil.SetIsVisible(self.MI_DX_Transform_SightSeeing_1a, bShow)
	UIUtil.SetIsVisible(self.MI_DX_Transform_SightSeeing_1b, bShow)
	UIUtil.SetIsVisible(self.MI_DX_Transform_SightSeeing_1c, bShow)
end

function SightSeeingLogMainView:OnAnimationFinished(Anim)
	if Anim == self.AnimUnlock1 then
		DiscoverNoteVM:SetTheClueLockState(NoteClueType.Time, true)
		UIUtil.SetRenderOpacity(self.PanelUnlock01, 1)
	elseif Anim == self.AnimUnlock2 then
		DiscoverNoteVM:SetTheClueLockState(NoteClueType.Weather, true)
		UIUtil.SetRenderOpacity(self.PanelUnlock02, 1)
	elseif Anim == self.AnimUnlock3 then
		DiscoverNoteVM:SetTheClueLockState(NoteClueType.Emotion, true)
		UIUtil.SetRenderOpacity(self.PanelUnlock03, 1)
	end
end

return SightSeeingLogMainView