---
--- Author: moodliu
--- DateTime: 2023-11-20 16:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local MusicPerformanceSelectVM = require("Game/Performance/VM/MusicPerformanceSelectVM")
local InstrumentCfg = require("TableCfg/InstrumentCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local SaveKey = require("Define/SaveKey")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ProtoCS = require("Protocol/ProtoCS")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local ProfDefine = require("Game/Profession/ProfDefine")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local DataReportUtil = require("Utils/DataReportUtil")

---@class PerformanceSelectPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field BtnConfirm CommBtnLView
---@field BtnSound UFButton
---@field TableViewSpecific UTableView
---@field TableViewSpecificCruves UTableView
---@field TextPercussion UFTextBlock
---@field TextString UFTextBlock
---@field TextWind UFTextBlock
---@field ToggleBtnFavor UToggleButton
---@field ToggleBtnInstrument1 UToggleButton
---@field ToggleBtnInstrument2 UToggleButton
---@field ToggleBtnInstrument3 UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceSelectPanelView = LuaClass(UIView, true)

function PerformanceSelectPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.BtnConfirm = nil
	--self.BtnSound = nil
	--self.TableViewSpecific = nil
	--self.TableViewSpecificCruves = nil
	--self.TextPercussion = nil
	--self.TextString = nil
	--self.TextWind = nil
	--self.ToggleBtnFavor = nil
	--self.ToggleBtnInstrument1 = nil
	--self.ToggleBtnInstrument2 = nil
	--self.ToggleBtnInstrument3 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceSelectPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnConfirm)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceSelectPanelView:OnInit()
	self:InitStaticText()
	self.VM = MusicPerformanceSelectVM.New()
	
	self.VM.InstrumentMap[0] = InstrumentCfg:FindAllCfg("Type = 0")
	self.VM.InstrumentMap[1] = InstrumentCfg:FindAllCfg("Type = 1")
	self.VM.InstrumentMap[2] = InstrumentCfg:FindAllCfg("Type = 2")
	self.InstrumentItemCount = 7

	self.TableViewInstrumentAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSpecific, nil, true, nil, true)
	self.PrevSelectedView = nil
	self.CurrentCameraMoveParam = nil
end

function PerformanceSelectPanelView:InitStaticText()
	self.TextTitle:SetText(_G.LSTR(830091))
	self.TextString:SetText(_G.LSTR(830050))
	self.TextWind:SetText(_G.LSTR(830051))
	self.TextPercussion:SetText(_G.LSTR(830052))
	self.BtnConfirm:SetBtnName(_G.LSTR(830053))
end

function PerformanceSelectPanelView:OnDestroy()
	self.VM = nil
end

function PerformanceSelectPanelView:OnShow()
	self.VM.SelectedID = 1
	if _G.MusicPerformanceMgr:GetSelectedPerformData() then
		self.VM.SelectedID = _G.MusicPerformanceMgr:GetSelectedPerformData().ID
	end

	if self.VM.CurInstrumentList == nil then
		self:SelectToggle(((InstrumentCfg:FindCfgByKey(self.VM.SelectedID) or {}).Type or 0) + 1)
	end

	local _, SelectedIndex = table.find_by_predicate(self.VM.CurInstrumentList, function(e)
		return e.ID == self.VM.SelectedID
	end)
	SelectedIndex = SelectedIndex or 1
	self.TableViewInstrumentAdapter:SetSelectedIndex(SelectedIndex)
	self.TableViewInstrumentAdapter:ScrollToIndex(SelectedIndex)

	if self.Params and (self.Params.IsFromMainPanel or self.Params.IsMusicAssistant) then
		self.VM.IsShowBackBtn = true
	end

	--保存当前摄像机参数
	self.CurrentCameraMoveParam = _G.LuaCameraMgr:GetDefaultCameraParam()

	-- 摄像机转到正前方
	local Major = MajorUtil.GetMajor()
	local CameraMoveParam = _G.LuaCameraMgr:GetDefaultCameraParam()
	CameraMoveParam.Rotator = (-Major:GetActorForwardVector()):ToRotator()
	local CameraResetType = _G.UE.ECameraResetLocation.RecordLocation
	CameraMoveParam.LagValue = MPDefines.CameraSettings.LagValue
	CameraMoveParam.Distance = MPDefines.CameraSettings.SelectPanelDistance
	_G.LuaCameraMgr:ResetMajorCameraSpringArmByParam(CameraResetType, CameraMoveParam)
	
	--记录操作是否为退出演奏系统
	self.IsExitPerormancePanel = true
	--取消场景中选中的对象
	_G.SelectTargetMgr:CancelSelectTargetActor()
	--隐藏场景中的HUD相关
	_G.HUDMgr:SetIsDrawHUD(false)
	--隐藏追踪任务地面路点指引特效
	_G.NaviDecalMgr:SetNavPathHiddenInGame(true)
	_G.NaviDecalMgr:DisableTick(true)
	--静音
	_G.TouringBandMgr:EnterTouringBandSilentMode()
end

function PerformanceSelectPanelView:OnHide()
	if self.IsExitPerormancePanel then
		_G.UE.UActorManager:Get():HideAllActors(false, _G.UE.TArray(_G.UE.uint64), _G.UE.TArray(_G.UE.uint8))
		_G.HUDMgr:SetIsDrawHUD(true)
		_G.NaviDecalMgr:SetNavPathHiddenInGame(false)
		_G.NaviDecalMgr:DisableTick(false)

		if self.CurrentCameraMoveParam ~= nil then
			local CameraResetType = _G.UE.ECameraResetLocation.RecordLocation
			_G.LuaCameraMgr:ResetMajorCameraSpringArmByParam(CameraResetType, self.CurrentCameraMoveParam)
		end

		--停止静音
		_G.TouringBandMgr:ExitTouringBandSilentMode()
	end
end

function PerformanceSelectPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnInstrument1, self.SelectToggle, 1)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnInstrument2, self.SelectToggle, 2)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnInstrument3, self.SelectToggle, 3)
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.Confirm)
	self.BtnBack:AddBackClick(self, self.OnClickBtnBack)
end

function PerformanceSelectPanelView:Confirm()
	_G.MusicPerformanceMgr:InitRedDotData()
	if self.VM.SelectedID then
		self:OnSkipNextPanel(self.VM.SelectedID)

		--演奏埋点(乐器选择)
		local InstrumentData = InstrumentCfg:FindCfgByKey(self.VM.SelectedID)
		if InstrumentData ~= nil then
			DataReportUtil.ReportSystemFlowData("PerformanceFlow", tostring(2), tostring(InstrumentData.Name))
		end
	end
end

function PerformanceSelectPanelView:OnClickBtnBack()
	if _G.MusicPerformanceMgr:GetSelectedPerformData() then
		local SelectedID = _G.MusicPerformanceMgr:GetSelectedPerformData().ID
		self:OnSkipNextPanel(SelectedID)
	end
end

function PerformanceSelectPanelView:OnSkipNextPanel(SelectedID)
	-- IsMusicAssistant 表示是不是从歌曲界面UI跳转过来，需要先退出演奏状态，否则服务器不会发OnNetMsgPerformCmdEnterNotify，乐器相关就切不成功
	-- if self.Params ~= nil and self.Params.IsMusicAssistant then
	-- 	_G.MusicPerformanceMgr:ReqAbortPerform()
	-- end

	--通知服务器切换乐器
	_G.MusicPerformanceMgr:SetModeLocal(SelectedID)
	
	_G.MusicPerformanceMgr:SetSelectedPerformData(InstrumentCfg:FindCfgByKey(SelectedID))
	self.IsExitPerormancePanel = false
	if self.Params == nil or not self.Params.IsMusicAssistant then
		_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceMainPanelView)
	end
	_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceSelectPanelView)
end

function PerformanceSelectPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MusicPerformanceUISelect, self.OnGameEventMusicPerformanceUISelect)
end

function PerformanceSelectPanelView:SelectToggle(ToggleID)
	local ToggleNames = {"ToggleBtn1State", "ToggleBtn2State", "ToggleBtn3State"}
	local TextNames = {"NameColorTextString", "NameColorTextWind", "NameColorTextPercussion"}

	for Index = 1, #ToggleNames do
		local ToggleName = ToggleNames[Index]
		local TextName = TextNames[Index]

		self.VM[ToggleName] = Index == ToggleID
		self.VM[TextName] = Index == ToggleID and "FFEEBBFF" or "D5D5D5FF"
	end
	self.VM.CurInstrumentList = self.VM.InstrumentMap[ToggleID - 1]
	self.PrevSelectedView = nil
end

function PerformanceSelectPanelView:OnGameEventMusicPerformanceUISelect(SelectedView)
	self.VM.SelectedID = SelectedView.Params.Data.ID
	if self.PrevSelectedView then
		self.PrevSelectedView.VM.AnimChencked = false
	end

	self.PrevSelectedView = SelectedView
	if self.PrevSelectedView then
		self.PrevSelectedView.VM.AnimChencked = true
	end
end

function PerformanceSelectPanelView:OnRegisterBinder()
	local Binders = {
		{ "CurInstrumentList", UIBinderUpdateBindableList.New(self, self.TableViewInstrumentAdapter) },
		{ "ToggleBtn1State", UIBinderSetIsChecked.New(self, self.ToggleBtnInstrument1, true) },
		{ "ToggleBtn2State", UIBinderSetIsChecked.New(self, self.ToggleBtnInstrument2, true) },
		{ "ToggleBtn3State", UIBinderSetIsChecked.New(self, self.ToggleBtnInstrument3, true) },
		{ "NameColorTextString", UIBinderSetColorAndOpacityHex.New(self, self.TextString, true) },
		{ "NameColorTextWind", UIBinderSetColorAndOpacityHex.New(self, self.TextWind, true) },
		{ "NameColorTextPercussion", UIBinderSetColorAndOpacityHex.New(self, self.TextPercussion, true) },
		{ "IsShowBackBtn", UIBinderSetIsVisible.New(self, self.BtnBack, false, true) },
		{ "IsShowBackBtn", UIBinderSetIsVisible.New(self, self.BtnClose, true, true) },
	}

	self:RegisterBinders(self.VM, Binders)
end

return PerformanceSelectPanelView