---
--- Author: moodliu
--- DateTime: 2023-11-20 19:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MusicPerformanceMainVM = require("Game/Performance/VM/MusicPerformanceMainVM")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local ProtoCS = require("Protocol/ProtoCS")
local CommonUtil = require("Utils/CommonUtil")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local SaveKey = require("Define/SaveKey")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIDefine = require("Define/UIDefine")
local ObjectGCType = require("Define/ObjectGCType")
local DataReportUtil = require("Utils/DataReportUtil")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local TeamVoiceMgr = require("Game/Team/TeamVoiceMgr")

local CommBtnColorType = UIDefine.CommBtnColorType
local EnsembleStatus = ProtoCS.EnsembleStatus
local AvatarType_Hair = _G.UE.EAvatarPartType.NAKED_BODY_HAIR

---@class PerformanceMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BlueAreaEffectBtn UFButton
---@field BtnChat UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnEnsemble UFButton
---@field BtnHelp UFButton
---@field BtnMetroSetting UFButton
---@field BtnMetronome UFButton
---@field BtnMic UFButton
---@field BtnPerformAssistNew PerformanceAideBtnView
---@field BtnQuitTeam UFButton
---@field BtnSettings UFButton
---@field BtnSwitchInstrument UFButton
---@field BtnVoice UFButton
---@field IconMicOff UFImage
---@field IconMicOn UFImage
---@field IconVoiceOff UFImage
---@field IconVoiceOn UFImage
---@field ImgBgBlue UFImage
---@field ImgBgRed UFImage
---@field ImgBlueBg UFImage
---@field ImgEnsemble UFImage
---@field ImgHighBlue UFImage
---@field ImgHighBlueBg UFImage
---@field ImgHighRed UFImage
---@field ImgHighRedBg UFImage
---@field ImgInstruIcon UFImage
---@field ImgInstruIconBg UFImage
---@field ImgMetronomeOff UFImage
---@field ImgMetronomeOn UFImage
---@field ImgNew UFImage
---@field ImgRedBg UFImage
---@field ImgSelect1 UFImage
---@field ImgSelect2 UFImage
---@field ImgTeamVoiceBg UFImage
---@field ImgTinyIcon UFImage
---@field Metronome PerformanceMetronomeItemView
---@field PanelBtns UFHorizontalBox
---@field PanelEnsemble UFCanvasPanel
---@field PanelEnsembleTips UFCanvasPanel
---@field PanelExpand UFCanvasPanel
---@field PanelExpandMic UFCanvasPanel
---@field PanelHighBlue UFCanvasPanel
---@field PanelHighRed UFCanvasPanel
---@field PanelMetronome UFCanvasPanel
---@field PanelModes UFCanvasPanel
---@field PanelSwitch UFCanvasPanel
---@field PanelTeamVoice UFCanvasPanel
---@field PanelTitle UFCanvasPanel
---@field PanelTutorial UFCanvasPanel
---@field PanelTutorial1 UFCanvasPanel
---@field PanelTutorial2 UFCanvasPanel
---@field PanelTutorial3 UFCanvasPanel
---@field PerformAssistPanel UFCanvasPanel
---@field RedAreaEffectBtn UFButton
---@field RedDot2 CommonRedDot2View
---@field Spacer4LongKey USpacer
---@field Spacer4LongKey1 USpacer
---@field TableViewTeam UTableView
---@field TextBPM UFTextBlock
---@field TextBeat UFTextBlock
---@field TextBlue UFTextBlock
---@field TextEnsemble UFTextBlock
---@field TextExpand UFTextBlock
---@field TextExpandMic UFTextBlock
---@field TextInstrumentName UFTextBlock
---@field TextMetronome UFTextBlock
---@field TextRed UFTextBlock
---@field TextTempo UFTextBlock
---@field TinyMetronome PerformanceTinyMetronomeItemView
---@field ToggleBtnMode1 UToggleButton
---@field ToggleBtnMode2 UToggleButton
---@field ToggleBtnMode3 UToggleButton
---@field ToggleBtnMode4 UToggleButton
---@field ToggleBtnMode5 UToggleButton
---@field ToggleBtnMusic UToggleButton
---@field ToggleBtnNoBlack UToggleButton
---@field ToggleBtnOtherCharacter UToggleButton
---@field ToggleBtnPackUp UToggleButton
---@field ToggleBtnWithBlack UToggleButton
---@field ToggleGroupSwitch UToggleGroup
---@field VerticalBottom UFVerticalBox
---@field AnimBlueBgShow UWidgetAnimation
---@field AnimBtnEnsembleLoop UWidgetAnimation
---@field AnimMetroBgShine UWidgetAnimation
---@field AnimRedBgShow UWidgetAnimation
---@field AnimTempoBgShine UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceMainPanelView = LuaClass(UIView, true)

function PerformanceMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BlueAreaEffectBtn = nil
	--self.BtnChat = nil
	--self.BtnClose = nil
	--self.BtnEnsemble = nil
	--self.BtnHelp = nil
	--self.BtnMetroSetting = nil
	--self.BtnMetronome = nil
	--self.BtnMic = nil
	--self.BtnPerformAssistNew = nil
	--self.BtnQuitTeam = nil
	--self.BtnSettings = nil
	--self.BtnSwitchInstrument = nil
	--self.BtnVoice = nil
	--self.IconMicOff = nil
	--self.IconMicOn = nil
	--self.IconVoiceOff = nil
	--self.IconVoiceOn = nil
	--self.ImgBgBlue = nil
	--self.ImgBgRed = nil
	--self.ImgBlueBg = nil
	--self.ImgEnsemble = nil
	--self.ImgHighBlue = nil
	--self.ImgHighBlueBg = nil
	--self.ImgHighRed = nil
	--self.ImgHighRedBg = nil
	--self.ImgInstruIcon = nil
	--self.ImgInstruIconBg = nil
	--self.ImgMetronomeOff = nil
	--self.ImgMetronomeOn = nil
	--self.ImgNew = nil
	--self.ImgRedBg = nil
	--self.ImgSelect1 = nil
	--self.ImgSelect2 = nil
	--self.ImgTeamVoiceBg = nil
	--self.ImgTinyIcon = nil
	--self.Metronome = nil
	--self.PanelBtns = nil
	--self.PanelEnsemble = nil
	--self.PanelEnsembleTips = nil
	--self.PanelExpand = nil
	--self.PanelExpandMic = nil
	--self.PanelHighBlue = nil
	--self.PanelHighRed = nil
	--self.PanelMetronome = nil
	--self.PanelModes = nil
	--self.PanelSwitch = nil
	--self.PanelTeamVoice = nil
	--self.PanelTitle = nil
	--self.PanelTutorial = nil
	--self.PanelTutorial1 = nil
	--self.PanelTutorial2 = nil
	--self.PanelTutorial3 = nil
	--self.PerformAssistPanel = nil
	--self.RedAreaEffectBtn = nil
	--self.RedDot2 = nil
	--self.Spacer4LongKey = nil
	--self.Spacer4LongKey1 = nil
	--self.TableViewTeam = nil
	--self.TextBPM = nil
	--self.TextBeat = nil
	--self.TextBlue = nil
	--self.TextEnsemble = nil
	--self.TextExpand = nil
	--self.TextExpandMic = nil
	--self.TextInstrumentName = nil
	--self.TextMetronome = nil
	--self.TextRed = nil
	--self.TextTempo = nil
	--self.TinyMetronome = nil
	--self.ToggleBtnMode1 = nil
	--self.ToggleBtnMode2 = nil
	--self.ToggleBtnMode3 = nil
	--self.ToggleBtnMode4 = nil
	--self.ToggleBtnMode5 = nil
	--self.ToggleBtnMusic = nil
	--self.ToggleBtnNoBlack = nil
	--self.ToggleBtnOtherCharacter = nil
	--self.ToggleBtnPackUp = nil
	--self.ToggleBtnWithBlack = nil
	--self.ToggleGroupSwitch = nil
	--self.VerticalBottom = nil
	--self.AnimBlueBgShow = nil
	--self.AnimBtnEnsembleLoop = nil
	--self.AnimMetroBgShine = nil
	--self.AnimRedBgShow = nil
	--self.AnimTempoBgShine = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnPerformAssistNew)
	self:AddSubView(self.Metronome)
	self:AddSubView(self.RedDot2)
	self:AddSubView(self.TinyMetronome)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceMainPanelView:OnInit()
	self:InitStaticText()
	self.VM = MusicPerformanceMainVM.New()
	self.Metronome:SetParentVM(self.VM)
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewTeam, nil, false)

	self:OnSetRedBlueAreaSize()
end

function PerformanceMainPanelView:InitStaticText()
	-- self.TextTitle:SetText(_G.LSTR(830092))
	self.BtnPerformAssistNew:SetBtnName(_G.LSTR(830093))
	self.TextMetronome:SetText(_G.LSTR(830063))
	self.TextEnsemble:SetText(_G.LSTR(830104))

	self.TextBlue:SetText(_G.LSTR(830138))
	self.TextRed:SetText(_G.LSTR(830137))
end

function PerformanceMainPanelView:OnActive()
	self:UpdateKeyboardVisibility()
end

function PerformanceMainPanelView:OnDestroy()

end

function PerformanceMainPanelView:UpdateKeyboardVisibility()
	if not self.IsShowView then
		return
	end
	local IsSmallSize = MusicPerformanceUtil.GetKeySize() == 1		-- 是否是小按键
	local IsSingleMode = MusicPerformanceUtil.GetKeybordMode() == 1	-- 是否是单音阶
	local UseBlackKey = self:UseBlackKey()
	
	if IsSmallSize and IsSingleMode and UseBlackKey then
		self:CreateKeyboard("Performance/PerformanceMonoKey_UIBP")
	elseif not IsSmallSize and IsSingleMode and UseBlackKey then
		self:CreateKeyboard("Performance/PerformanceMonoLargeKey_UIBP")
	elseif IsSmallSize and IsSingleMode and not UseBlackKey then
		self:CreateKeyboard("Performance/PerformanceNoBlackKey_UIBP")
	elseif not IsSmallSize and IsSingleMode and not UseBlackKey then
		self:CreateKeyboard("Performance/PerformanceNoBlackLargeKey_UIBP")
	elseif IsSmallSize and not IsSingleMode and UseBlackKey then
		self:CreateKeyboard("Performance/PerformanceFullKey_UIBP")
	elseif not IsSmallSize and not IsSingleMode and UseBlackKey then
		self:CreateKeyboard("Performance/PerformanceFullLargeKey_UIBP")
	elseif IsSmallSize and not IsSingleMode and not UseBlackKey then
		self:CreateKeyboard("Performance/PerformanceFullNoBlackKey_UIBP")
	elseif not IsSmallSize and not IsSingleMode and not UseBlackKey then
		self:CreateKeyboard("Performance/PerformanceFullNoBlackLargeKey_UIBP")
	end

	self.VM.Spacer4LongKey1Visible = not IsSmallSize
	self.VM.Spacer4LongKeyVisible = not IsSmallSize

end

local Padding = _G.UE.FMargin()
Padding.Top = 31 --影响演奏主界面[演奏助手]按钮那行UI距离下面键盘顶部的距离
function PerformanceMainPanelView:CreateKeyboard(BPName)
	-- if self.KeyboardView and self.KeyboardView.BPName == BPName then
	-- 	return
	-- end

	if self.KeyboardView then
		_G.UIViewMgr:HideSubView(self.KeyboardView)
		self.VerticalBottom:RemoveChild(self.KeyboardView)
		self.KeyboardView:RemoveFromParentView()
		_G.UIViewMgr:RecycleView(self.KeyboardView)
	end
	self.KeyboardView = _G.UIViewMgr:CreateViewByName(BPName, ObjectGCType.NoCache, self, true, true, nil)
	
	self.VerticalBottom:AddChildToVerticalBox(self.KeyboardView)
	self.KeyboardView.Slot:SetPadding(Padding)
	self.KeyboardView.Slot:SetHorizontalAlignment(_G.UE.EHorizontalAlignment.HAlign_Center)
	
	_G.UIViewMgr:ShowSubView(self.KeyboardView)
	-- UIUtil.CanvasSlotSetAutoSize(ItemView, true)

	--更换键盘后，需要重置键盘背景状态
	self:OnResetKeyboardBg()
end

function PerformanceMainPanelView:UpdatePerformData()
	local PerformName = _G.MusicPerformanceMgr:GetSelectedPerformData().Name or ""
	self.VM.BaseIconPath = _G.MusicPerformanceMgr:GetSelectedPerformData().BaseIcon or ""
	self.VM.SmallIconPath = _G.MusicPerformanceMgr:GetSelectedPerformData().SmallIcon or ""
	self.VM.BigIconPath = _G.MusicPerformanceMgr:GetSelectedPerformData().BigIcon or ""

	local PatternName = "电吉他"
	if string.find(PerformName, PatternName) then
		self.VM.PerformName = PatternName
	else
		self.VM.PerformName = PerformName
	end
end

function PerformanceMainPanelView:OnShow()
	self:UpdatePerformData()
	self:UpdatePanelMetronome()
	self:UpdateToggles()

	--断线重新进来需要调整主角摄像头
	if self.Params and not self.Params.IsFromSelectPanel then
		self:UpdateMajorCamera()
	end

	self.VM.TableViewTeamVisible = true
	UIUtil.SetIsVisible(self.TableViewTeam, true, false, false) --初始化为不可点击自身，否则点空白处会点中TableViewTeam

	CommonUtil.DisableShowJoyStick(true)
	CommonUtil.HideJoyStick()
	self:UpdateKeyboardVisibility()

	self:UpdateTeamMicVoice()
	self:UpdateEnsembleBtnAnimation()
	UIUtil.SetIsVisible(self.BtnChat, false) --首测屏蔽聊天入口

	--红点
	self.RedDot2:SetRedDotIDByID(3001)

	self.IsExitPerormancePanel = true
	--取消场景中选中的对象
	_G.SelectTargetMgr:CancelSelectTargetActor()
	--隐藏场景中的HUD相关
	_G.HUDMgr:SetIsDrawHUD(false)
	--隐藏追踪任务地面路点指引特效
	_G.NaviDecalMgr:SetNavPathHiddenInGame(true)
	_G.NaviDecalMgr:DisableTick(true)
	--禁止移动-因为此界面没有UI锁屏
	local StateComponent = MajorUtil.GetMajorStateComponent()
   	if StateComponent ~= nil then
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, false, "Performance")
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanAllowMove, false, "Performance")
	end
	--静音
	_G.TouringBandMgr:EnterTouringBandSilentMode()
	--修改头发渲染顺序，让特效完全覆盖
	local AvatarComp = ActorUtil.GetActorAvatarComponent(MajorUtil.GetMajorEntityID())
    if AvatarComp then
        AvatarComp:SetPartTranslucencySortPriority(AvatarType_Hair, -1)
    end

	--演奏埋点(进入演奏界面)
	DataReportUtil.ReportSystemFlowData("EnsembleAssistant", tostring(1))
end

function PerformanceMainPanelView:OnActive()
	self:UpdatePerformData()
	self:UpdateToggles()
	self:UpdateKeyboardVisibility()
end

--玩家 加入/离开 队伍的事件
function PerformanceMainPanelView:OnGameEventTeamInTeamChanged(InTeam)
	self:UpdateTeamMicVoice()
end

function PerformanceMainPanelView:UpdateEnsembleBtnAnimation()
	-- 提示队长可以进行合奏
	self.VM.IsAnimBtnEnsembleLoopPlaying = _G.TeamMgr:IsCaptain()
		and not _G.MusicPerformanceMgr.EnsembleBuffer:IsUse() and self:HasNearbyMusicPlayer()
end

function PerformanceMainPanelView:OnHide()
	if self.IsExitPerormancePanel then
		_G.UE.UActorManager:Get():HideAllActors(false, _G.UE.TArray(_G.UE.uint64), _G.UE.TArray(_G.UE.uint8))
		_G.HUDMgr:SetIsDrawHUD(true)
		_G.NaviDecalMgr:SetNavPathHiddenInGame(false)
		_G.NaviDecalMgr:DisableTick(false)
		--停止静音
		_G.TouringBandMgr:ExitTouringBandSilentMode()
		--恢复背景音乐
		_G.UE.UBGMMgr.Get():Resume()
	end

	--解除禁止移动-因为此界面没有UI锁屏
	local StateComponent = MajorUtil.GetMajorStateComponent()
   	if StateComponent ~= nil then
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, true, "Performance")
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanAllowMove, true, "Performance")
	end
	
	CommonUtil.DisableShowJoyStick(false)
	CommonUtil.ShowJoyStick()
	self.VM.IsAnimBtnEnsembleLoopPlaying = false

	--恢复头发渲染顺序
	local AvatarComp = ActorUtil.GetActorAvatarComponent(MajorUtil.GetMajorEntityID())
    if AvatarComp then
        AvatarComp:SetPartTranslucencySortPriority(AvatarType_Hair, 0)
    end

	_G.MusicPerformanceMgr.IsShowMainPanelExitMsgBox = false
end

function PerformanceMainPanelView:UpdateToggles()
	local GroupID = _G.MusicPerformanceMgr:GetSelectedPerformData().InstrumentGroup or 0
	local GroupData = {}

	if GroupID ~= 0 then
		-- 获取GroupData
		GroupData = MusicPerformanceUtil.GetPerformGroupData(GroupID)
	end


	local CurID = _G.MusicPerformanceMgr:GetSelectedPerformData().ID
	for Index = 0, MPDefines.GroupMax - 1 do
		local GroupItemID = GroupData["ID" .. tostring(Index)]
		if GroupItemID == nil or GroupItemID == 0 then
			self.VM[string.format("Toggle%dVisible", Index + 1)] = false
		else
			self.VM[string.format("Toggle%dVisible", Index + 1)] = true
			self["ToggleBtnMode" .. tostring(Index+1)]:SetCheckedState((GroupItemID == CurID)
				and _G.UE.EToggleButtonState.Checked or _G.UE.EToggleButtonState.Unchecked , false)
		end
	end
end

function PerformanceMainPanelView:UpdateMajorCamera()
	-- 摄像机转到正前方
	local Major = MajorUtil.GetMajor()
	local CameraMoveParam = _G.LuaCameraMgr:GetDefaultCameraParam()
	CameraMoveParam.Rotator = (-Major:GetActorForwardVector()):ToRotator()
	local CameraResetType = _G.UE.ECameraResetLocation.RecordLocation
	CameraMoveParam.LagValue = MPDefines.CameraSettings.LagValue
	CameraMoveParam.Distance = MPDefines.CameraSettings.SelectPanelDistance
	_G.LuaCameraMgr:ResetMajorCameraSpringArmByParam(CameraResetType, CameraMoveParam)
end

function PerformanceMainPanelView:OnRegisterUIEvent()
	self.BtnClose:SetCallback(self, self.OnBtnCloseClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnPerformAssistNew.Button, self.OnBtnPerformAssistClicked)

	UIUtil.AddOnClickedEvent(self, self.BtnSwitchInstrument, self.OnBtnSwitchInstrumentClicked)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMode1, self.SelectToggle, 0)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMode2, self.SelectToggle, 1)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMode3, self.SelectToggle, 2)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMode4, self.SelectToggle, 3)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMode5, self.SelectToggle, 4)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnOtherCharacter, self.OnToggleBtnOtherCharacterChanged)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnMusic, self.OnToggleBtnMusicChanged)

	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupSwitch, self.OnToggleGroupCheckChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnQuitTeam, self.OnBtnQuitTeamClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnMetronome, self.OnBtnMetronomeClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnMetroSetting, self.OnBtnMetroSettingClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnEnsemble, self.OnBtnEnsembleClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnSettings, self.OnBtnSettingsClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnChat, self.OnBtnChatClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnHelp, self.OnBtnHelpClicked)

	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnPackUp, self.OnToggleBtnPackUpClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnVoice, self.OnClickedButtonVoice)
	UIUtil.AddOnClickedEvent(self, self.BtnMic, self.OnClickedButtonMic)

	--高低八度20%侧边按键
	UIUtil.AddOnLongClickedEvent(self, self.RedAreaEffectBtn, self.OnPressedRedAreaEffectBtn)
    UIUtil.AddOnLongClickReleasedEvent(self, self.RedAreaEffectBtn, self.OnReleasedRedAreaEffectBtn)
	UIUtil.AddOnLongClickedEvent(self, self.BlueAreaEffectBtn, self.OnPressedBlueAreaEffectBtn)
    UIUtil.AddOnLongClickReleasedEvent(self, self.BlueAreaEffectBtn, self.OnReleasedBlueAreaEffectBtn)
end

function PerformanceMainPanelView:OnBtnHelpClicked()
	HelpInfoUtil.ShowHelpInfo({HelpInfoID = 1000002})
end

function PerformanceMainPanelView:OnBtnChatClicked()
	_G.ChatMgr:ShowChatView(nil, nil, nil, self:GetViewID())

	--演奏埋点(点击聊天)
	DataReportUtil.ReportSystemFlowData("EnsembleAssistant", tostring(5))
end

function PerformanceMainPanelView:OnBtnPerformAssistClicked()
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPefromanceSongPanelView)

	--演奏埋点(点击演奏助手)
	DataReportUtil.ReportSystemFlowData("EnsembleAssistant", tostring(3))
end

--显示和屏蔽周围玩家
function PerformanceMainPanelView:OnToggleBtnOtherCharacterChanged(ToggleGroup, ToggleButton, Index, State)
	self.VM.IsShowOtherCharacter = ToggleButton == _G.UE.EToggleButtonState.Checked
	if self.VM.IsShowOtherCharacter then
		_G.MsgTipsUtil.ShowTips(LSTR(830035))
	else
		_G.MsgTipsUtil.ShowTips(LSTR(830025))
		--演奏埋点(点击屏蔽玩家)
		DataReportUtil.ReportSystemFlowData("EnsembleAssistant", tostring(4))
	end
end
function PerformanceMainPanelView:OnIsShowOtherCharacterChanged(Value)
	local ExcludeActorTypes = _G.UE.TArray(_G.UE.uint8)
	local ExcludeActorID = _G.UE.TArray(_G.UE.uint64)

	for _, RoleID in pairs(_G.TeamMgr:GetMemberRoleIDList() or {}) do
		local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
		ExcludeActorID:Add(EntityID)
	end
	ExcludeActorTypes:Add(_G.UE.EActorType.Major)
	_G.UE.UActorManager:Get():HideAllActors(not self.VM.IsShowOtherCharacter, _G.UE.TArray(_G.UE.uint64), ExcludeActorTypes)
end

--屏蔽场景背景音乐
function PerformanceMainPanelView:OnToggleBtnMusicChanged(ToggleGroup, ToggleButton, Index, State)
	self.VM.IsCloseSceneBGM = ToggleButton == _G.UE.EToggleButtonState.Checked
	if self.VM.IsCloseSceneBGM then
		_G.MsgTipsUtil.ShowTipsByID(168017)
	else
		_G.MsgTipsUtil.ShowTipsByID(168016)
	end
end
function PerformanceMainPanelView:OnIsCloseSceneBGMChanged(Value)
	if self.VM.IsCloseSceneBGM then
		_G.UE.UBGMMgr.Get():Pause()
	else
		_G.UE.UBGMMgr.Get():Resume()
	end
end

function PerformanceMainPanelView:OnBtnSettingsClicked()
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceSettingView)
end

--退出合奏按钮
function PerformanceMainPanelView:OnBtnQuitTeamClicked()
	local TitleText = _G.TeamMgr:IsCaptain() and LSTR(830130) or LSTR(830131)
	local MessageText = _G.TeamMgr:IsCaptain() and LSTR(830032) or LSTR(830033)
	local LeftText = LSTR(10003)
	local RightBtnText = _G.TeamMgr:IsCaptain() and LSTR(10071) or LSTR(10010)
	MsgBoxUtil.ShowMsgBoxTwoOp(self, TitleText, MessageText,
		function(_, Params)
			_G.MusicPerformanceMgr:ReqAbortEnsemble()
			--本地主动退出合奏
			_G.MusicPerformanceMgr:AbortEnsemble()
		end,
		function(_, Params)
		end,
		LeftText, RightBtnText,
		{
			LeftBtnStyle = CommBtnColorType.Normal,
			RightBtnStyle = CommBtnColorType.Recommend,
		})
end

function PerformanceMainPanelView:OnMusicPerformanceAbortEnsemble()
	MsgBoxUtil.CloseMsgBox()
end

--点击主界面打开节拍器按钮
function PerformanceMainPanelView:OnBtnMetronomeClicked()
	if _G.MusicPerformanceVM.Status == EnsembleStatus.EnsembleStatusEnsemble then
		-- 合奏模式下，只使用mini节拍器
		return
	end
	self.VM.PanelMetronomeVisible = not self.VM.PanelMetronomeVisible
	if self.VM.PanelMetronomeVisible then
		--演奏埋点(点击打开节拍器)
		DataReportUtil.ReportSystemFlowData("EnsembleAssistant", tostring(7))
	end
end

function PerformanceMainPanelView:OnBtnEnsembleClicked()
	--演奏埋点(点击开始合奏)
	DataReportUtil.ReportSystemFlowData("EnsembleAssistant", tostring(1))

	if not _G.TeamMgr:IsInTeam() then
		_G.MsgTipsUtil.ShowTips(LSTR(830029))
		return
	end

	if not _G.TeamMgr:IsCaptain() then
		_G.MsgTipsUtil.ShowTips(LSTR(830016))
		return
	end

	if _G.MusicPerformanceMgr.EnsembleBuffer:IsUse() then
		_G.MsgTipsUtil.ShowTips(LSTR(830012))
		return
	end

	if not self:HasNearbyMusicPlayer() then
		_G.MsgTipsUtil.ShowTips(LSTR(830047))
		return
	end

	if _G.MusicPerformanceMgr:IsTeamMembersInPerformanceAssist() then
		return
	end

	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceEnsembleMetronmeView)
end

-- 判断附近是否有处于演奏状态的队友
function PerformanceMainPanelView:HasNearbyMusicPlayer()
	local RoleIDList = _G.TeamMgr:GetMemberRoleIDList()
	for _, RoleID in pairs(RoleIDList) do
		if not MajorUtil.IsMajorByRoleID(RoleID) then
			local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
			local StateComp = ActorUtil.GetActorStateComponent(EntityID)
			if StateComp
				and StateComp:IsInNetState(ProtoCommon.CommStatID.CommStatPerform)	-- 现在状态有问题，先注释掉
				and MusicPerformanceUtil.IsInPerformRange(MajorUtil.GetMajorEntityID(), EntityID)
			then
				return true
			end
		end
	end

	return false
end

--点击打开节拍器设置面板
function PerformanceMainPanelView:OnBtnMetroSettingClicked()
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceMetronomeSettingView)
	self.Metronome:ResetMetronome()
end

function PerformanceMainPanelView:UpdatePanelMetronome()
	self.VM.BPMTip = "BPM:" .. tostring(self.Metronome.VM.BPM)
	self.VM.BeatTip = "BEAT:" .. tostring(self.Metronome.VM.BeatPerBar)
end

function PerformanceMainPanelView:UseBlackKey()
	return self.ToggleGroupSwitch:GetCheckedIndex() == 0
end

function PerformanceMainPanelView:OnToggleGroupCheckChanged(ToggleGroup, ToggleButton, Index, State)
	-- local UseBlack = Index == 0
	self:UpdateKeyboardVisibility()

	--演奏埋点(切换按键)
	DataReportUtil.ReportSystemFlowData("EnsembleAssistant", tostring(6))
end

function PerformanceMainPanelView:ChangeTimbre(Index)
	local GroupID = _G.MusicPerformanceMgr:GetSelectedPerformData().InstrumentGroup or 0

	if GroupID ~= 0 then
		-- 获取GroupData
		local GroupData = {}
		GroupData = MusicPerformanceUtil.GetPerformGroupData(GroupID)
		local PerformID = GroupData["ID" .. tostring(Index)]
		if PerformID == nil or PerformID == 0 then
			return
		end

		_G.MusicPerformanceMgr:SetSelectedPerformData(MusicPerformanceUtil.GetPerformData(PerformID))
	end
end

function PerformanceMainPanelView:SelectToggle(Index)
	_G.MusicPerformanceMgr:SetTimbre(Index)
	self:ChangeTimbre(Index)
	self:UpdatePerformData()
	self:UpdateToggles()
end

function PerformanceMainPanelView:OnBtnCloseClicked()
	local Select = _G.UE.USaveMgr.GetInt(SaveKey.PerformanceExitTipSelect, 0, true)
	if Select == 0 then
		_G.MusicPerformanceMgr.IsShowMainPanelExitMsgBox = true
		-- 进行提示
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(830045), LSTR(830034),
		function(_, Params)
			local IsNeverAgain = Params.IsNeverAgain
			if IsNeverAgain then
				-- 默认转换职业
				_G.UE.USaveMgr.SetInt(SaveKey.PerformanceExitTipSelect, 1, true)
			end
			self:AbortPerform()
			_G.MusicPerformanceMgr.IsShowMainPanelExitMsgBox = false
		end,
		function(_, Params)
			_G.MusicPerformanceMgr.IsShowMainPanelExitMsgBox = false
		end,
		LSTR(10003), LSTR(10010),
		{
			bUseNever = true,	-- 不再提醒
			NeverMindText = LSTR(830007)
		})
	elseif Select == 1 then
		self:AbortPerform()
	end
end

function PerformanceMainPanelView:AbortPerform()
	_G.MusicPerformanceMgr:ReqAbortPerform()
	_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceMainPanelView)
end

function PerformanceMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MusicPerformanceMetronomeSettingUpdate, self.OnMusicPerformanceMetronomeSettingUpdate)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceCommonSettingUpdate, self.OnMusicPerformanceCommonSettingUpdate)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceStartEnsemble, self.OnMusicPerformanceStartEnsemble)

	self:RegisterGameEvent(_G.EventID.TeamCaptainChanged, self.UpdateEnsembleBtnAnimation)
	self:RegisterGameEvent(_G.EventID.TeamLeave, self.UpdateEnsembleBtnAnimation)
	self:RegisterGameEvent(_G.EventID.TeamInTeamChanged, self.OnGameEventTeamInTeamChanged)

	self:RegisterGameEvent(_G.EventID.MusicPerformanceEnsembleWorkStart, self.UpdateEnsembleBtnAnimation)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceEnsembleWorkClear, self.UpdateEnsembleBtnAnimation)
	self:RegisterGameEvent(_G.EventID.StateChange, self.OnNetStateUpdate)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceToneOffset, self.OnMusicPerformanceToneOffsetUpdate)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceEnsembleConfirm, self.OnMusicPerformanceEnsembleConfirm)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceAbortEnsemble, self.OnMusicPerformanceAbortEnsemble)
end

function PerformanceMainPanelView:OnNetStateUpdate(Params)
	local Stat = Params.IntParam1
	if Stat == ProtoCommon.CommStatID.CommStatPerform then
		local EntityID = Params.ULongParam1
		if _G.TeamMgr:IsTeamMemberByEntityID(EntityID) then
			self:UpdateEnsembleBtnAnimation()
		end
	end
end

--重置键盘背景状态
function PerformanceMainPanelView:OnResetKeyboardBg()
	self:OnHideRedEffect()
	self:OnHideBlueEffect()
end

--演奏高低音调偏移按键通知
function PerformanceMainPanelView:OnMusicPerformanceToneOffsetUpdate(Offset)
	local IsSingleMode = MusicPerformanceUtil.GetKeybordMode() == 1	-- 是否是单音阶
	if not IsSingleMode then
		return
	end

	if Offset > 0 then
		self:OnShowRedEffect()
		self:OnHideBlueEffect()
		self.RedAreaEffectBtn:SetIsEnabled(false)
		self.BlueAreaEffectBtn:SetIsEnabled(false)
	elseif Offset < 0 then
		self:OnShowBlueEffect()
		self:OnHideRedEffect()
		self.RedAreaEffectBtn:SetIsEnabled(false)
		self.BlueAreaEffectBtn:SetIsEnabled(false)
	else
		self:OnHideBlueEffect()
		self:OnHideRedEffect()
		self.RedAreaEffectBtn:SetIsEnabled(true)
		self.BlueAreaEffectBtn:SetIsEnabled(true)
	end
end

function PerformanceMainPanelView:OnPressedRedAreaEffectBtn()
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceToneOffset, MPDefines.KeyDefines.KEY_MAX)
end
function PerformanceMainPanelView:OnReleasedRedAreaEffectBtn()
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceToneOffset, 0)
end

function PerformanceMainPanelView:OnPressedBlueAreaEffectBtn()
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceToneOffset, -MPDefines.KeyDefines.KEY_MAX)
end
function PerformanceMainPanelView:OnReleasedBlueAreaEffectBtn()
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceToneOffset, 0)
end

--设置二侧20%高底八底按键区域
function PerformanceMainPanelView:OnSetRedBlueAreaSize()
	local ViewportSize = UIUtil.GetViewportSize()

	local BlueSize = UIUtil.CanvasSlotGetSize(self.BlueAreaEffectBtn)
	local BlueViewportX = ViewportSize.X * 0.2
	UIUtil.CanvasSlotSetSize(self.BlueAreaBtnEffect, _G.UE.FVector2D(BlueViewportX, BlueSize.Y))

	local RedSize = UIUtil.CanvasSlotGetSize(self.RedAreaEffectBtn)
	local RedViewportX = ViewportSize.X * 0.2
	UIUtil.CanvasSlotSetSize(self.BlueAreaBtnEffect, _G.UE.FVector2D(RedViewportX, RedSize.Y))
end

--显示高八度效果
function PerformanceMainPanelView:OnShowRedEffect()
	self:PlayAnimation(self.AnimRedBgShow)
	self.VM.ImgRedBgVisible = true
end
--隐藏高八度效果
function PerformanceMainPanelView:OnHideRedEffect()
	self:StopAnimLoop(self.AnimRedBgShow)
	self.VM.ImgRedBgVisible = false
end

--显示低八度效果
function PerformanceMainPanelView:OnShowBlueEffect()
	self:PlayAnimation(self.AnimBlueBgShow)
	self.VM.ImgBlueBgVisible = true
end
--隐藏低八度效果
function PerformanceMainPanelView:OnHideBlueEffect()
	self:StopAnimLoop(self.AnimBlueBgShow)
	self.VM.ImgBlueBgVisible = false
end

function PerformanceMainPanelView:OnMusicPerformanceEnsembleConfirm(Params)
	_G.MusicPerformanceMgr:UpdateEnsembleConfirmSidebarData()
end

function PerformanceMainPanelView:OnStatusChanged(Params)
	local EntityID = Params.ULongParam1
	
	if _G.TeamMgr:IsTeamMemberByEntityID(EntityID) then
		local StateComp = ActorUtil.GetActorStateComponent(EntityID)
		if StateComp and StateComp:IsInNetState(ProtoCommon.CommStatID.CommStatPerform) then
			self:UpdateEnsembleBtnAnimation()
		end
	end
end

function PerformanceMainPanelView:OnMusicPerformanceStartEnsemble()
	-- 本地合奏开始 结束倒计时
	self.VM.BtnQuitTeamVisible = true
end

function PerformanceMainPanelView:OnMusicPerformanceMetronomeSettingUpdate()
	self.Metronome:SetVMSettingsSaved()
	self:UpdatePanelMetronome()
end

function PerformanceMainPanelView:OnMusicPerformanceCommonSettingUpdate()
	self:UpdateKeyboardVisibility()
end

function PerformanceMainPanelView:OnPanelMetronomeVisibleChanged(NewValue)
	self.VM.ImgMetronomeOnVisible = NewValue
	self.VM.ImgMetronomeOffVisible = not NewValue
end

function PerformanceMainPanelView:OnRegisterBinder()
	local Binders = {
		{ "PerformName", UIBinderSetText.New(self, self.TextInstrumentName) },
		{ "BPMTip", UIBinderSetText.New(self, self.TextBPM) },
		{ "BeatTip", UIBinderSetText.New(self, self.TextBeat) },
		{ "TempoTip", UIBinderSetText.New(self, self.TextTempo) },
		{ "TempoTipColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTempo) },

		{ "Toggle1Visible", UIBinderSetIsVisible.New(self, self.ToggleBtnMode1, false, true) },
		{ "Toggle2Visible", UIBinderSetIsVisible.New(self, self.ToggleBtnMode2, false, true) },
		{ "Toggle3Visible", UIBinderSetIsVisible.New(self, self.ToggleBtnMode3, false, true) },
		{ "Toggle4Visible", UIBinderSetIsVisible.New(self, self.ToggleBtnMode4, false, true) },
		{ "Toggle5Visible", UIBinderSetIsVisible.New(self, self.ToggleBtnMode5, false, true) },

		{ "Spacer4LongKeyVisible", UIBinderSetIsVisible.New(self, self.Spacer4LongKey) },
		{ "Spacer4LongKey1Visible", UIBinderSetIsVisible.New(self, self.Spacer4LongKey1) },

		{ "PanelMetronomeVisible", UIBinderSetIsVisible.New(self, self.PanelMetronome, false, true) },
		{ "PanelMetronomeVisible", UIBinderValueChangedCallback.New(self, nil, self.OnPanelMetronomeVisibleChanged) },
		{ "TableViewTeamVisible", UIBinderSetIsVisible.New(self, self.TableViewTeam, false, true) },
		{ "BtnQuitTeamVisible", UIBinderSetIsVisible.New(self, self.BtnQuitTeam, false, true) },
		{ "PanelEnsembleTipsVisible", UIBinderSetIsVisible.New(self, self.PanelEnsembleTips, false, true) },
		{ "TinyMetronomeVisible", UIBinderSetIsVisible.New(self, self.TinyMetronome, false, true) },
		{ "BtnMetronomeVisible", UIBinderSetIsVisible.New(self, self.BtnMetronome, false, true) },
		{ "PanelBtnsVisible", UIBinderSetIsVisible.New(self, self.PanelBtns, false, true) },
		{ "ImgMetronomeOnVisible", UIBinderSetIsVisible.New(self, self.ImgMetronomeOn, false, true) },
		{ "ImgMetronomeOffVisible", UIBinderSetIsVisible.New(self, self.ImgMetronomeOff, false, true) },
		{ "BtnCloseVisible", UIBinderSetIsVisible.New(self, self.BtnClose, false, true) },
		{ "PanelSwitchVisible", UIBinderSetIsVisible.New(self, self.PanelSwitch, false, true) },
		{ "PanelModesVisible", UIBinderSetIsVisible.New(self, self.PanelModes, false, true) },
		{ "PerformAssistPanelVisible", UIBinderSetIsVisible.New(self, self.PerformAssistPanel, false, true) },
		{ "BtnEnsembleVisible", UIBinderSetIsVisible.New(self, self.BtnEnsemble, false, true) },

		{ "BigIconPath", UIBinderSetImageBrush.New(self, self.ImgInstruIcon, false, true) },
		{ "BaseIconPath", UIBinderSetImageBrush.New(self, self.ImgInstruIconBg, false, true) },
		{ "SmallIconPath", UIBinderSetImageBrush.New(self, self.ImgTinyIcon, false, true) },

		{ "IsShowOtherCharacter", UIBinderSetIsChecked.New(self, self.ToggleBtnOtherCharacter)},
		{ "IsShowOtherCharacter", UIBinderValueChangedCallback.New(self, nil, self.OnIsShowOtherCharacterChanged) },
		{ "IsCloseSceneBGM", UIBinderSetIsChecked.New(self, self.ToggleBtnMusic)},
		{ "IsCloseSceneBGM", UIBinderValueChangedCallback.New(self, nil, self.OnIsCloseSceneBGMChanged) },
		{ "IsAnimBtnEnsembleLoopPlaying", UIBinderIsLoopAnimPlay.New(self, nil, self.AnimBtnEnsembleLoop) },
		
		{ "ImgRedBgVisible", UIBinderSetIsVisible.New(self, self.ImgRedBg) },
		{ "ImgBlueBgVisible", UIBinderSetIsVisible.New(self, self.ImgBlueBg) },
		{ "ImgRedBgVisible", UIBinderSetIsVisible.New(self, self.ImgBgRed) },
		{ "ImgBlueBgVisible", UIBinderSetIsVisible.New(self, self.ImgBgBlue) },
		{ "ImgRedBgVisible", UIBinderSetIsVisible.New(self, self.PanelHighRed) },
		{ "ImgBlueBgVisible", UIBinderSetIsVisible.New(self, self.PanelHighBlue) },

		{ "PanelMicVoiceVisible", UIBinderSetIsVisible.New(self, self.PanelTeamVoice) },
		{ "bToggleBtnPackUpChecked", UIBinderSetIsChecked.New(self, self.ToggleBtnPackUp) },
		{ "bToggleBtnPackUpChecked", UIBinderValueChangedCallback.New(self, nil, self.OnbToggleBtnPackUpCheckedChanged) },

		{ "IsPlayTempoTipBgEffect", UIBinderValueChangedCallback.New(self, nil, self.OnIsPlayTempoTipBgEffectChanged) },
		{ "IsPlayMetronomeItemBgEffect", UIBinderValueChangedCallback.New(self, nil, self.OnIsPlayMetronomeItemBgEffectChanged) },
	}
	self:RegisterBinders(self.VM, Binders)

	--队伍信息、麦克风喇叭需与组队同步，二边相互影响
	local TeamDataBinders = {
		{ "IsOnVoice", 			UIBinderSetIsVisible.New(self, self.IconVoiceOff, true) },
		{ "IsOnVoice", 			UIBinderSetIsVisible.New(self, self.IconVoiceOn) },
		{ "IsOnMic", 			UIBinderSetIsVisible.New(self, self.IconMicOff, true) },
		{ "IsOnMic", 			UIBinderSetIsVisible.New(self, self.IconMicOn) },
		{ "BindableListMember", UIBinderUpdateBindableList.New(self, self.AdapterTableView) }
	}
	self:RegisterBinders(_G.TeamVM, TeamDataBinders)

	-- 合奏信息
	local EnsembleBinders = {
		{ "Status", UIBinderValueChangedCallback.New(self, nil, self.OnStatusValueChanged) },
	}
	self:RegisterBinders(_G.MusicPerformanceVM, EnsembleBinders)
end

function PerformanceMainPanelView:OnStatusValueChanged(Value)
	--MusicPerformanceUtil.Log("OnStatusValueChanged" .. tostring(Value))
	-- 仅在倒计时阶段进行显示
	local IsEnsembleState = Value == EnsembleStatus.EnsembleStatusEnsemble
	self.VM.BtnQuitTeamVisible = IsEnsembleState and _G.MusicPerformanceMgr.EnsembleFlag
	self.VM.PanelEnsembleTipsVisible = IsEnsembleState
	self.VM.TinyMetronomeVisible = IsEnsembleState
	self.VM.PanelMetronomeVisible = IsEnsembleState
	local IsEnsembleStateOrConfirm = Value == EnsembleStatus.EnsembleStatusConfirm or Value == EnsembleStatus.EnsembleStatusEnsemble
	self.VM.BtnCloseVisible = not IsEnsembleStateOrConfirm
	self.VM.PerformAssistPanelVisible = not IsEnsembleStateOrConfirm
	self.VM.PanelSwitchVisible = not IsEnsembleStateOrConfirm
	self.VM.PanelModesVisible = not IsEnsembleStateOrConfirm
	self.VM.BtnEnsembleVisible = not IsEnsembleStateOrConfirm --story=119667344 【演奏】【首测】屏蔽合奏助手功能及入口
	-- self.VM.BtnEnsembleVisible = _G.MusicPerformanceMgr.bOpenEnsembleGM --增加一个GM命令开启合奏

	self.VM.PanelBtnsVisible = not IsEnsembleState
	self.VM.BtnMetronomeVisible = not IsEnsembleState
	
	if IsEnsembleState then
		self.VM.PanelMetronomeVisible = false
	end

	if Value ~= EnsembleStatus.EnsembleStatusConfirm then
		_G.MusicPerformanceMgr:SetEnsembleConfirmSidebarVisible(false)
	end

	if Value == EnsembleStatus.EnsembleStatusEnsemble then
		-- 更新节拍器参数并进行重置
		-- self.Metronome.VM.BPM = _G.MusicPerformanceVM.EnsembleMetronome.BPM
		-- self.Metronome.VM.BeatPerBar = _G.MusicPerformanceVM.EnsembleMetronome.Beat
		-- self.Metronome.VM.Prepare = true
		-- self.Metronome.VM.BtnMetroPlayVisible = false
		-- self.Metronome.VM.ImgPlayVisible = false
		self.Metronome:ResetMetronome()
		self:OnEnterEnsembleState()
	elseif Value == EnsembleStatus.EnsembleStatusConfirm then
		_G.MusicPerformanceMgr:UpdateEnsembleConfirmSidebarData()
	elseif Value == EnsembleStatus.EnsembleStatusPerform then
		_G.MusicPerformanceVM:CancelTimer()
	else
		-- 更新节拍器参数并进行重置
		self.Metronome:SetVMSettingsSaved()
		self.Metronome.VM.BtnMetroPlayVisible = true
		self.Metronome.VM.ImgPlayVisible = true
		self.Metronome:ResetMetronome()
	end
end

--节拍tip(如1:1)背景特效(右下角)
function PerformanceMainPanelView:OnIsPlayTempoTipBgEffectChanged(InIsPlayTempoTipBgEffect)
	if InIsPlayTempoTipBgEffect == true then
		self:PlayAnimation(self.AnimTempoBgShine)
		self.VM.IsPlayTempoTipBgEffect = false
	end
end

--节拍器item背景特效(右下角)
function PerformanceMainPanelView:OnIsPlayMetronomeItemBgEffectChanged(InIsPlayMetronomeItemBgEffect)
	if InIsPlayMetronomeItemBgEffect == true then
		self:PlayAnimation(self.AnimMetroBgShine)
		self.VM.IsPlayMetronomeItemBgEffect = false
	end
end

--进入合奏状态时
function PerformanceMainPanelView:OnEnterEnsembleState()
	--合奏的321倒计时动画
	_G.MusicPerformanceMgr:OnShowCountDownTips(_G.LSTR(830105))

	--关闭演奏助手歌曲界面
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPefromanceSongPanelView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPefromanceSongPanelView)
	end

	--节拍器设置界面
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceMetronomeSettingView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceMetronomeSettingView)
	end
end

--点击乐器选择切换按钮
function PerformanceMainPanelView:OnBtnSwitchInstrumentClicked()
	self.IsExitPerormancePanel = false
	_G.MusicPerformanceMgr:ReqAbortPerform(true)
	_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceMainPanelView)
	local Params = { IsFromMainPanel = true } 
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceSelectPanelView, Params)
end

-----------------------------麦克风喇叭-------------------------------
--更新组队麦克风喇叭功能
function PerformanceMainPanelView:UpdateTeamMicVoice()
	self.VM.PanelMicVoiceVisible = _G.TeamMgr:IsInTeam()
	if self.VM.PanelMicVoiceVisible then
		self.VM.bToggleBtnPackUpChecked = true
		UIUtil.SetIsVisible(self.ToggleBtnPackUp, true, true, true)
	else
		UIUtil.SetIsVisible(self.ToggleBtnPackUp, false, false, false)
	end
end

function PerformanceMainPanelView:OnToggleBtnPackUpClicked(ToggleGroup, ToggleButton, Index, State)
	self.VM.bToggleBtnPackUpChecked = ToggleButton == _G.UE.EToggleButtonState.Checked
end

function PerformanceMainPanelView:OnbToggleBtnPackUpCheckedChanged()
	UIUtil.SetIsVisible(self.TableViewTeam, self.VM.bToggleBtnPackUpChecked, false, not self.VM.bToggleBtnPackUpChecked)
	UIUtil.SetIsVisible(self.PanelTeamVoice, self.VM.bToggleBtnPackUpChecked, false, not self.VM.bToggleBtnPackUpChecked)
end

function PerformanceMainPanelView:OnClickedButtonMic()
	PerformanceMainPanelView.OnClickMic(self, self.BtnMic)
end

function PerformanceMainPanelView:OnClickedButtonVoice()
	PerformanceMainPanelView.OnClickVoice(self, self.BtnVoice)
end

function PerformanceMainPanelView.OnClickMic(View, Widget)
	local ShouldOn = not TeamVoiceMgr:IsCurMicOn()
	if ShouldOn and not TeamVoiceMgr:IsCurVoiceOn() then
		View:ShowChatTips(_G.LSTR(1300021), Widget)
		CommonUtil.ReportTeamVoiceStatus(false)
		return
	end

	local bOpenMic = false
	if ShouldOn then
		bOpenMic = TeamVoiceMgr:UIOpenMic()
	else
		TeamVoiceMgr:UICloseMic()
	end
	CommonUtil.ReportTeamVoiceStatus(ShouldOn)
	View:ShowChatTips(bOpenMic and _G.LSTR(1300022) or _G.LSTR(1300023), Widget)
end

function PerformanceMainPanelView.OnClickVoice(View, Widget)
	local ShouldOn = not TeamVoiceMgr:IsCurVoiceOn()
	local Tip
	if ShouldOn then
		if TeamVoiceMgr:UIOpenSpeaker() then
			Tip = _G.LSTR(1300024)
		end
	else
		TeamVoiceMgr:UICloseSpeaker()
		Tip = _G.LSTR(1300025)
	end

	if Tip then
		View:ShowChatTips(Tip , Widget)
	end
end

function PerformanceMainPanelView:StopVoiceTipsTimerID()
	local TimerID = self.VoiceTipsTimerID 
	if TimerID then
		self:UnRegisterTimer(TimerID)
		self.VoiceTipsTimerID = nil
	end
end

function PerformanceMainPanelView:ShowChatTips( TextTips, AnchorWidget )
	local TextWidget
	if self.BtnVoice == AnchorWidget then
		UIUtil.SetIsVisible(self.PanelExpand, true)
		UIUtil.SetIsVisible(self.PanelExpandMic, false)
		TextWidget = self.TextExpand
	elseif self.BtnMic == AnchorWidget then
		UIUtil.SetIsVisible(self.PanelExpand, false)
		UIUtil.SetIsVisible(self.PanelExpandMic, true)
		TextWidget = self.TextExpandMic
	else
		UIUtil.SetIsVisible(self.PanelExpand, false)
		UIUtil.SetIsVisible(self.PanelExpandMic, false)
	end

	if TextWidget == nil then
		return
	end
	
	TextWidget:SetText(TextTips)
	self:StopVoiceTipsTimerID()
	self.VoiceTipsTimerID  = self:RegisterTimer(self.OnVoiceTipsTimer, 2)
end

function PerformanceMainPanelView:OnVoiceTipsTimer()
	UIUtil.SetIsVisible(self.PanelExpand, false)
	UIUtil.SetIsVisible(self.PanelExpandMic, false)
	self:StopVoiceTipsTimerID()
end
-----------------------------麦克风喇叭-------------------------------

return PerformanceMainPanelView