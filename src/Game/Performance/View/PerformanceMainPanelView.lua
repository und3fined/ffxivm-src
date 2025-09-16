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
local UIViewID = require("Define/UIViewID")

local SaveKey = require("Define/SaveKey")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIDefine = require("Define/UIDefine")
local ObjectGCType = require("Define/ObjectGCType")
local DataReportUtil = require("Utils/DataReportUtil")
local CommBtnColorType = UIDefine.CommBtnColorType

local EnsembleStatus = ProtoCS.EnsembleStatus

---@class PerformanceMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChat UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnEnsemble UFButton
---@field BtnInfor CommInforBtnView
---@field BtnMetroSetting UFButton
---@field BtnMetronome UFButton
---@field BtnPerformAssist CommBtnSView
---@field BtnQuitTeam UFButton
---@field BtnSettings UFButton
---@field BtnSideBar UFButton
---@field BtnSwitchInstrument UFButton
---@field CountDownItem PerformanceCountDownItemView
---@field ImgBg UImage
---@field ImgBlueBg UFImage
---@field ImgEnsemble UFImage
---@field ImgInstruIcon UFImage
---@field ImgInstruIconBg UFImage
---@field ImgMetronomeOff UFImage
---@field ImgMetronomeOn UFImage
---@field ImgNew UFImage
---@field ImgRedBg UFImage
---@field ImgSelect1 UFImage
---@field ImgSelect2 UFImage
---@field ImgTinyIcon UFImage
---@field ImgTypeIcon UImage
---@field Metronome PerformanceMetronomeItemView
---@field PanelEnsemble UFCanvasPanel
---@field PanelMetronome UFCanvasPanel
---@field PanelModes UFCanvasPanel
---@field PanelSideBar UCanvasPanel
---@field PanelSwitch UFCanvasPanel
---@field PerformAssistPanel UFCanvasPanel
---@field RaidalCD URadialImage
---@field RedDot2 CommonRedDot2View
---@field Spacer4LongKey USpacer
---@field Spacer4LongKey1 USpacer
---@field TableViewTeam UTableView
---@field TextBPM UFTextBlock
---@field TextBeat UFTextBlock
---@field TextEnsemble UFTextBlock
---@field TextInstrumentName UFTextBlock
---@field TextMetronome UFTextBlock
---@field TextSideBarState UFTextBlock
---@field TextTempo UFTextBlock
---@field TextTitle UFTextBlock
---@field TinyMetronome PerformanceTinyMetronomeItemView
---@field ToggleBtnMode1 UToggleButton
---@field ToggleBtnMode2 UToggleButton
---@field ToggleBtnMode3 UToggleButton
---@field ToggleBtnMode4 UToggleButton
---@field ToggleBtnMode5 UToggleButton
---@field ToggleBtnNoBlack UToggleButton
---@field ToggleBtnVisibility UToggleButton
---@field ToggleBtnWithBlack UToggleButton
---@field ToggleGroupSwitch UToggleGroup
---@field VerticalBottom UFVerticalBox
---@field AnimBtnEnsembleLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceMainPanelView = LuaClass(UIView, true)

function PerformanceMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChat = nil
	--self.BtnClose = nil
	--self.BtnEnsemble = nil
	--self.BtnInfor = nil
	--self.BtnMetroSetting = nil
	--self.BtnMetronome = nil
	--self.BtnPerformAssist = nil
	--self.BtnQuitTeam = nil
	--self.BtnSettings = nil
	--self.BtnSideBar = nil
	--self.BtnSwitchInstrument = nil
	--self.CountDownItem = nil
	--self.ImgBg = nil
	--self.ImgBlueBg = nil
	--self.ImgEnsemble = nil
	--self.ImgInstruIcon = nil
	--self.ImgInstruIconBg = nil
	--self.ImgMetronomeOff = nil
	--self.ImgMetronomeOn = nil
	--self.ImgNew = nil
	--self.ImgRedBg = nil
	--self.ImgSelect1 = nil
	--self.ImgSelect2 = nil
	--self.ImgTinyIcon = nil
	--self.ImgTypeIcon = nil
	--self.Metronome = nil
	--self.PanelEnsemble = nil
	--self.PanelMetronome = nil
	--self.PanelModes = nil
	--self.PanelSideBar = nil
	--self.PanelSwitch = nil
	--self.PerformAssistPanel = nil
	--self.RaidalCD = nil
	--self.RedDot2 = nil
	--self.Spacer4LongKey = nil
	--self.Spacer4LongKey1 = nil
	--self.TableViewTeam = nil
	--self.TextBPM = nil
	--self.TextBeat = nil
	--self.TextEnsemble = nil
	--self.TextInstrumentName = nil
	--self.TextMetronome = nil
	--self.TextSideBarState = nil
	--self.TextTempo = nil
	--self.TextTitle = nil
	--self.TinyMetronome = nil
	--self.ToggleBtnMode1 = nil
	--self.ToggleBtnMode2 = nil
	--self.ToggleBtnMode3 = nil
	--self.ToggleBtnMode4 = nil
	--self.ToggleBtnMode5 = nil
	--self.ToggleBtnNoBlack = nil
	--self.ToggleBtnVisibility = nil
	--self.ToggleBtnWithBlack = nil
	--self.ToggleGroupSwitch = nil
	--self.VerticalBottom = nil
	--self.AnimBtnEnsembleLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnInfor)
	self:AddSubView(self.BtnPerformAssist)
	self:AddSubView(self.CountDownItem)
	self:AddSubView(self.Metronome)
	self:AddSubView(self.RedDot2)
	self:AddSubView(self.TinyMetronome)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceMainPanelView:OnInit()
	self:InitStaticText()
	self.BtnClose:SetCallback(self, self.OnBtnCloseClicked)
	self.VM = MusicPerformanceMainVM.New()
	self.Metronome:SetParentVM(self.VM)
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewTeam, nil, false)
	self.BtnInfor.HelpInfoID = 10012
end

function PerformanceMainPanelView:InitStaticText()
	self.TextTitle:SetText(_G.LSTR(830092))
	self.BtnPerformAssist:SetBtnName(_G.LSTR(830093))
	self.TextMetronome:SetText(_G.LSTR(830063))
	self.TextEnsemble:SetText(_G.LSTR(830104))

	--CountDownItem是合奏的动画--合奏即将开始
	self.CountDownItem:SetText(_G.LSTR(830105))
	self.CountDownItem:SetEndText(_G.LSTR(830076))
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
Padding.Top = 31
function PerformanceMainPanelView:CreateKeyboard(BPName)
	if self.KeyboardView and self.KeyboardView.BPName == BPName then
		return
	end

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
	CommonUtil.DisableShowJoyStick(true)
	CommonUtil.HideJoyStick()
	self:UpdateKeyboardVisibility()
	self.BtnInfor.HelpInfoID = 1000002

	self:UpdateEnsembleBtnAnimation()
	UIUtil.SetIsVisible(self.CountDownItem, false)
	UIUtil.SetIsVisible(self.BtnChat, false) --首测屏蔽聊天入口

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

	--演奏埋点(进入演奏界面)
	DataReportUtil.ReportSystemFlowData("EnsembleAssistant", tostring(1))
end

function PerformanceMainPanelView:OnActive()
	self:UpdatePerformData()
	self:UpdateToggles()
	self:UpdateKeyboardVisibility()
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
	UIUtil.AddOnClickedEvent(self, self.BtnSwitchInstrument, self.OnBtnSwitchInstrumentClicked)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMode1, self.SelectToggle, 0)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMode2, self.SelectToggle, 1)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMode3, self.SelectToggle, 2)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMode4, self.SelectToggle, 3)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMode5, self.SelectToggle, 4)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnVisibility, self.OnToggleBtnVisibilityClicked)

	UIUtil.AddOnClickedEvent(self, self.BtnSideBar, self.OnBtnSideBarClicked)
	
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupSwitch, self.OnToggleGroupCheckChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnMetronome, self.OnBtnMetronomeClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnMetroSetting, self.OnBtnMetroSettingClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnEnsemble, self.OnBtnEnsembleClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnQuitTeam, self.OnBtnQuitTeamClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnSettings, self.OnBtnSettingsClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnChat, self.OnBtnChatClicked)

	UIUtil.AddOnClickedEvent(self, self.BtnPerformAssist, self.OnBtnPerformAssistClicked)

	--UIUtil.AddOnClickedEvent(self, self.BtnInfor.InforBtn, self.OnBtnInforClicked)
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

function PerformanceMainPanelView:OnToggleBtnVisibilityClicked()
	self.VM.OtherCharacterVisiblity = not self.VM.OtherCharacterVisiblity
	
	if self.VM.OtherCharacterVisiblity then
		_G.MsgTipsUtil.ShowTips(LSTR(830035))
	else
		_G.MsgTipsUtil.ShowTips(LSTR(830025))
		--演奏埋点(点击屏蔽玩家)
		DataReportUtil.ReportSystemFlowData("EnsembleAssistant", tostring(4))
	end
end

function PerformanceMainPanelView:OnBtnSettingsClicked()
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceSettingView)
end

--退出合奏按钮
function PerformanceMainPanelView:OnBtnQuitTeamClicked()
	local MsgContent = _G.TeamMgr:IsCaptain() and LSTR(830032) or LSTR(830033)
	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(830018), MsgContent,
		function(_, Params)
		end,
		function(_, Params)
			_G.MusicPerformanceMgr:ReqAbortEnsemble()
		end,
		LSTR(830044), LSTR(830043),
		{
			LeftBtnStyle = CommBtnColorType.Recommend,
			RightBtnStyle = CommBtnColorType.Normal,
		})
end

function PerformanceMainPanelView:OnMusicPerformanceAbortEnsemble()
	MsgBoxUtil.CloseMsgBox()
end

function PerformanceMainPanelView:OnBtnSideBarClicked()
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceEnsembleConfirmView, { 
		BPM = _G.MusicPerformanceVM.EnsembleMetronome.BPM or self.Metronome.VM.BPM,
		Beat = _G.MusicPerformanceVM.EnsembleMetronome.Beat or self.Metronome.VM.BeatPerBar,
		OpenAssistant = _G.MusicPerformanceVM.EnsembleMetronome.Assistant or true,
	 })
end

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

function PerformanceMainPanelView:OnBtnMetroSettingClicked()
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceMetronomeSettingView)
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
		-- 进行提示
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(830045), LSTR(830034),
		function(_, Params)
			local IsNeverAgain = Params.IsNeverAgain
			if IsNeverAgain then
				-- 默认转换职业
				_G.UE.USaveMgr.SetInt(SaveKey.PerformanceExitTipSelect, 1, true)
			end
			self:AbortPerform()
		end,
		function(_, Params)
		end,
		LSTR(830014), LSTR(830044),
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
	self:RegisterGameEvent(_G.EventID.MusicPerformanceEnsembleWorkStart, self.UpdateEnsembleBtnAnimation)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceEnsembleWorkClear, self.UpdateEnsembleBtnAnimation)
	self:RegisterGameEvent(_G.EventID.StateChange, self.OnNetStateUpdate)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceToneOffset, self.OnMusicPerformanceToneOffsetUpdate)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceEnsembleConfirm, self.OnMusicPerformanceEnsembleConfirm)

	self:RegisterGameEvent(_G.EventID.MusicPerformanceAbortEnsemble, self.OnMusicPerformanceAbortEnsemble)
	--self:RegisterGameEvent(_G.EventID.StateChange, self.OnStateChange)
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

function PerformanceMainPanelView:OnMusicPerformanceToneOffsetUpdate(Offset)
	self.VM.ImgRedBgVisible = Offset > 0
	self.VM.ImgBlueBgVisible = Offset < 0
end

--重置键盘背景状态
function PerformanceMainPanelView:OnResetKeyboardBg(Offset)
	self.VM.ImgRedBgVisible = false
	self.VM.ImgBlueBgVisible = false
end

function PerformanceMainPanelView:OnMusicPerformanceEnsembleConfirm(Params)
	self:UpdateSideBarState()
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
	self.VM.CountDownItemVisible = false
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
		{ "SideBarState", UIBinderSetText.New(self, self.TextSideBarState) },

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
		{ "PanelSideBarVisible", UIBinderSetIsVisible.New(self, self.PanelSideBar, false, true) },
		{ "BtnQuitTeamVisible", UIBinderSetIsVisible.New(self, self.BtnQuitTeam, false, true) },
		{ "TextEnsembleVisible", UIBinderSetIsVisible.New(self, self.TextEnsemble, false, true) },
		{ "TinyMetronomeVisible", UIBinderSetIsVisible.New(self, self.TinyMetronome, false, true) },
		{ "BtnMetronomeVisible", UIBinderSetIsVisible.New(self, self.BtnMetronome, false, true) },
		{ "PanelBtnsVisible", UIBinderSetIsVisible.New(self, self.PanelBtns, false, true) },
		{ "ImgMetronomeOnVisible", UIBinderSetIsVisible.New(self, self.ImgMetronomeOn, false, true) },
		{ "ImgMetronomeOffVisible", UIBinderSetIsVisible.New(self, self.ImgMetronomeOff, false, true) },
		{ "BtnCloseVisible", UIBinderSetIsVisible.New(self, self.BtnClose, false, true) },
		{ "PanelSwitchVisible", UIBinderSetIsVisible.New(self, self.PanelSwitch, false, true) },
		{ "PerformAssistPanelVisible", UIBinderSetIsVisible.New(self, self.PerformAssistPanel, false, true) },
		{ "BtnEnsembleVisible", UIBinderSetIsVisible.New(self, self.BtnEnsemble, false, true) },

		-- 倒计时
		{ "CountDownItemVisible", UIBinderSetIsVisible.New(self, self.CountDownItem, false, true) },

		{ "BigIconPath", UIBinderSetImageBrush.New(self, self.ImgInstruIcon, false, true) },
		{ "BaseIconPath", UIBinderSetImageBrush.New(self, self.ImgInstruIconBg, false, true) },
		{ "SmallIconPath", UIBinderSetImageBrush.New(self, self.ImgTinyIcon, false, true) },

		{ "RaidalCDValue", UIBinderSetPercent.New(self, self.RaidalCD) },
		{ "OtherCharacterVisiblity", UIBinderSetIsChecked.New(self, self.ToggleBtnVisibility)},
		{ "OtherCharacterVisiblity", UIBinderValueChangedCallback.New(self, nil, self.OnOtherCharacterVisiblityChanged) },
		{ "IsAnimBtnEnsembleLoopPlaying", UIBinderIsLoopAnimPlay.New(self, nil, self.AnimBtnEnsembleLoop) },
		
		{ "ImgRedBgVisible", UIBinderSetIsVisible.New(self, self.ImgRedBg) },
		{ "ImgBlueBgVisible", UIBinderSetIsVisible.New(self, self.ImgBlueBg) },
	}

	self:RegisterBinders(self.VM, Binders)

	-- 队伍信息
	local ListBinders = {{ "BindableListMember", UIBinderUpdateBindableList.New(self, self.AdapterTableView) }}
	self:RegisterBinders(_G.TeamVM, ListBinders)

	-- 合奏信息
	local EnsembleBinders = {
		{ "ReadyTime", UIBinderValueChangedCallback.New(self, nil, self.OnReadyTimeChanged) },
		{ "Status", UIBinderValueChangedCallback.New(self, nil, self.OnStatusValueChanged) },
		--{ "BeginTimeMs", UIBinderValueChangedCallback.New(self, nil, self.OnBeginTimeMsChanged) },
	}
	self:RegisterBinders(_G.MusicPerformanceVM, EnsembleBinders)
end

function PerformanceMainPanelView:OnOtherCharacterVisiblityChanged(Value)
	local ExcludeActorTypes = _G.UE.TArray(_G.UE.uint8)
	local ExcludeActorID = _G.UE.TArray(_G.UE.uint64)

	for _, TeamMember in pairs(_G.TeamMgr:GetMemberList() or {}) do
		local RoleID = TeamMember and TeamMember.RoleID or 0
		local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)

		ExcludeActorID:Add(EntityID)
	end

	ExcludeActorTypes:Add(_G.UE.EActorType.Major)
	_G.UE.UActorManager:Get():HideAllActors(not self.VM.OtherCharacterVisiblity, _G.UE.TArray(_G.UE.uint64), ExcludeActorTypes)

end

function PerformanceMainPanelView:OnReadyTimeChanged(Value)
	if _G.MusicPerformanceVM.Status == EnsembleStatus.EnsembleStatusConfirm then
		-- 更新等待进度条
		self.VM.RaidalCDValue = 1 - Value / MPDefines.Ensemble.DefaultSettings.ReadyTime
	end
end

function PerformanceMainPanelView:OnStatusValueChanged(Value)
	--MusicPerformanceUtil.Log("OnStatusValueChanged" .. tostring(Value))
	self.VM.PanelSideBarVisible = Value == EnsembleStatus.EnsembleStatusConfirm
	-- 仅在倒计时阶段进行显示
	self.VM.CountDownItemVisible = (Value == EnsembleStatus.EnsembleStatusEnsemble and not _G.MusicPerformanceMgr.EnsembleFlag)
	local IsEnsembleState = Value == EnsembleStatus.EnsembleStatusEnsemble
	self.VM.BtnQuitTeamVisible = IsEnsembleState and _G.MusicPerformanceMgr.EnsembleFlag
	self.VM.TextEnsembleVisible = IsEnsembleState
	self.VM.TinyMetronomeVisible = IsEnsembleState
	self.VM.PanelMetronomeVisible = IsEnsembleState
	local IsEnsembleStateOrConfirm = Value == EnsembleStatus.EnsembleStatusConfirm or Value == EnsembleStatus.EnsembleStatusEnsemble
	self.VM.BtnCloseVisible = not IsEnsembleStateOrConfirm
	self.VM.PerformAssistPanelVisible = not IsEnsembleStateOrConfirm
	self.VM.PanelSwitchVisible = not IsEnsembleStateOrConfirm
	-- self.VM.BtnEnsembleVisible = not IsEnsembleStateOrConfirm --story=119667344 【演奏】【首测】屏蔽合奏助手功能及入口
	-- self.VM.BtnEnsembleVisible = _G.MusicPerformanceMgr.bOpenEnsembleGM --增加一个GM命令开启合奏

	self.VM.PanelBtnsVisible = not IsEnsembleState
	self.VM.BtnMetronomeVisible = not IsEnsembleState
	
	if IsEnsembleState then
		self.VM.PanelMetronomeVisible = false
	end

	if Value == EnsembleStatus.EnsembleStatusEnsemble then
		-- 更新节拍器参数并进行重置
		-- self.Metronome.VM.BPM = _G.MusicPerformanceVM.EnsembleMetronome.BPM
		-- self.Metronome.VM.BeatPerBar = _G.MusicPerformanceVM.EnsembleMetronome.Beat
		-- self.Metronome.VM.Prepare = true
		-- self.Metronome.VM.BtnMetroPlayVisible = false
		-- self.Metronome.VM.ImgPlayVisible = false
		self.Metronome:ResetMetronome()
		local ServerTimeMS = TimeUtil.GetServerTimeMS()
		local StartCountDownAt = MPDefines.Ensemble.DefaultSettings.CountDownTime - ((_G.MusicPerformanceVM.BeginTimeMS or ServerTimeMS) - ServerTimeMS)
		self.CountDownItem:StartCountDownFrom(StartCountDownAt)
	elseif Value == EnsembleStatus.EnsembleStatusConfirm then
		self:UpdateSideBarState()
	else
		-- 更新节拍器参数并进行重置
		self.Metronome:SetVMSettingsSaved()
		self.Metronome.VM.BtnMetroPlayVisible = true
		self.Metronome.VM.ImgPlayVisible = true
		self.Metronome:ResetMetronome()
	end
end

--更新合奏确认过程中“暂时收起”后，主界面左侧的tip状态
function PerformanceMainPanelView:UpdateSideBarState()
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	local IsSelfConfirm = _G.MusicPerformanceVM.EnsembleConfirmStatus[MajorRoleID] == MPDefines.ConfirmStatus.ConfirmStatusConfirm
	--队长默认为确认状态
	if _G.TeamMgr:IsCaptainByRoleID(MajorRoleID) then
		IsSelfConfirm = true
	end
	self.VM.SideBarState = IsSelfConfirm and LSTR(830042) or LSTR(830039)

	--当所有人确认后，隐藏进度条
	if _G.MusicPerformanceMgr:GetTeamConfirmResult() == MPDefines.TeamConfirmResult.AllAgree then
		self.VM.RaidalCDValue = 0
	end
end

function PerformanceMainPanelView:OnBtnSwitchInstrumentClicked()
	self.IsExitPerormancePanel = false
	_G.MusicPerformanceMgr:ReqAbortPerform(true)
	_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceMainPanelView)
	local Params = { IsFromMainPanel = true } 
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceSelectPanelView, Params)
end

return PerformanceMainPanelView