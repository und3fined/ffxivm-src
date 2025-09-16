---
--- Author: moodliu
--- DateTime: 2023-11-24 16:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MajorUtil = require("Utils/MajorUtil")
local MusicPerformanceEnsembleWinVM = require("Game/Performance/VM/MusicPerformanceEnsembleWinVM")
local MusicPerformanceMemberItemVM = require("Game/Performance/VM/MusicPerformanceMemberItemVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local ActorUtil = require("Utils/ActorUtil")

local ProtoCS = require ("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType

local EnsembleStatus = ProtoCS.EnsembleStatus

local CS_CMD = ProtoCS.CS_CMD
local PERFORM_CMD = ProtoCS.PerformCmd
local LSTR = _G.LSTR

---@class PerformanceEnsembleWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnClose CommonCloseBtnView
---@field BtnEnsembleListenHelp CommInforBtnView
---@field BtnKeep CommBtnLView
---@field BtnStart CommBtnLView
---@field DropDownAssistant CommDropDownListView
---@field PanelEnsembleListen UFCanvasPanel
---@field PanelProBar UFCanvasPanel
---@field ProBarWait UProgressBar
---@field TableViewMember UTableView
---@field TextAssistant UFTextBlock
---@field TextBPM UFTextBlock
---@field TextBeat UFTextBlock
---@field TextEL UFTextBlock
---@field TextEnsembleListen UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceEnsembleWinView = LuaClass(UIView, true)

function PerformanceEnsembleWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnClose = nil
	--self.BtnEnsembleListenHelp = nil
	--self.BtnKeep = nil
	--self.BtnStart = nil
	--self.DropDownAssistant = nil
	--self.PanelEnsembleListen = nil
	--self.PanelProBar = nil
	--self.ProBarWait = nil
	--self.TableViewMember = nil
	--self.TextAssistant = nil
	--self.TextBPM = nil
	--self.TextBeat = nil
	--self.TextEL = nil
	--self.TextEnsembleListen = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceEnsembleWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnEnsembleListenHelp)
	self:AddSubView(self.BtnKeep)
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.DropDownAssistant)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceEnsembleWinView:OnInit()
	self:InitStaticText()
    self.TableViewMemberAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMember)
	self.VM = MusicPerformanceEnsembleWinVM.New()
	self.VM.PlayerList = UIBindableList.New()
end

function PerformanceEnsembleWinView:InitStaticText()
	self.TextTitle:SetText(LSTR(830089))
	self.TextEnsembleListen:SetText(LSTR(830019))
	
	self.BtnCancel:SetBtnName(LSTR(830060))
	self.BtnStart:SetBtnName(LSTR(830028))
	self.BtnKeep:SetBtnName(LSTR(830103))
	UIUtil.SetIsVisible(self.BtnClose, false)
end

function PerformanceEnsembleWinView:OnDestroy()

end

function PerformanceEnsembleWinView:OnShow()
	self.VM.TextBPM = string.format(LSTR(830049), _G.MusicPerformanceVM.EnsembleMetronome.BPM or 0)
	self.VM.TextBEAT = string.format(LSTR(830048), _G.MusicPerformanceVM.EnsembleMetronome.Beat or 0)
	self.VM.TextAssistant = string.format(LSTR(830017), (_G.MusicPerformanceVM.EnsembleMetronome.Assistant or false) and LSTR(830021) or LSTR(830011))

	self.VM.PanelProBarVisible = true
	self.VM.TextTipsVisible = true

	self.VM.PlayerList:Clear()
	for _, RoleID in _G.TeamMgr:IterTeamMembers() do
		local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
		-- local Actor = ActorUtil.GetActorByEntityID(EntityID)
		local AttrCom = ActorUtil.GetActorAttributeComponent(EntityID)
		
		local ProfID = ActorUtil.GetActorProfID(EntityID)
		if ProfID == ProtoCommon.prof_type.PROF_TYPE_BARD then
			--是不是演奏状态
			local StateComp = ActorUtil.GetActorStateComponent(EntityID)
			if StateComp then
				if StateComp:IsInNetState(ProtoCommon.CommStatID.CommStatPerform) then
					local MusicPerformanceMemberItemVM = MusicPerformanceMemberItemVM.New()
					MusicPerformanceMemberItemVM.RoleID = RoleID
					MusicPerformanceMemberItemVM.EntityID = EntityID
					MusicPerformanceMemberItemVM.Name = AttrCom.ActorName
					MusicPerformanceMemberItemVM.Level = AttrCom.Level
					MusicPerformanceMemberItemVM.IsMajor = ActorUtil.IsMajor(EntityID)
					self.VM.PlayerList:Add(MusicPerformanceMemberItemVM)
				end
			end
		end
	end
	_G.MusicPerformanceMgr:SetTeamPlayerList(self.VM.PlayerList)
	
	local DropDownList = { {Name = LSTR(830046)}, {Name = LSTR(830015)} }
	self.DropDownAssistant:UpdateItems(DropDownList, MusicPerformanceUtil.IsPerformanceSyncedWithParty() and 1 or 2)
	self.VM.TextBtnStart = _G.TeamMgr:IsCaptain() and LSTR(830028) or LSTR(830038)
	self.VM.TextBtnCancel = _G.TeamMgr:IsCaptain() and LSTR(830014) or LSTR(830030)
	self:UpdateTextEL()
	self:SetConfirmStatus(_G.MusicPerformanceVM.EnsembleConfirmStatus[MajorUtil.GetMajorRoleID()])
	--隐藏面板后，再打开时需要检查队伍所有人确认完之后的表现
	self:CheckAllTeamPlayerConfirmState(false)
end

function PerformanceEnsembleWinView:OnHide()
end

function PerformanceEnsembleWinView:SetConfirmStatus(Status)
	local IsConfirmed = Status == MPDefines.ConfirmStatus.ConfirmStatusConfirm
	self.VM.PanelEnsembleListenVisible = not IsConfirmed
	self.VM.TextELVisible = IsConfirmed

	if _G.TeamMgr:IsCaptain() then
		local IsTeamAllAgree = _G.MusicPerformanceMgr:GetTeamConfirmResult() == MPDefines.TeamConfirmResult.AllAgree
		self.VM.BtnStartIsEnable = IsTeamAllAgree
		self.VM.BtnKeepIsEnable = not self.VM.BtnStartIsEnable
		self.VM.BtnCancelIsEnable = true
	else
		self.VM.BtnStartIsEnable = not IsConfirmed
		self.VM.BtnKeepIsEnable = true
		self.VM.BtnCancelIsEnable = not IsConfirmed
	end
end

function PerformanceEnsembleWinView:UpdateTextEL()
	self.VM.TextEL = LSTR(830019) .. (MusicPerformanceUtil.IsPerformanceSyncedWithParty() and LSTR(830046) or LSTR(830015))
end

function PerformanceEnsembleWinView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.BtnEnsembleListenHelp.InforBtn, self.OnBtnEnsembleListenHelpClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnBtnCancelClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnStart.Button, self.OnBtnStartClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnKeep.Button, self.OnBtnKeepClicked)

	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownAssistant, function(_, Value)
		MusicPerformanceUtil.SavePerformanceSyncedWithParty(Value)
		self:UpdateTextEL()
	end)
end

--开始演奏/确认按钮
function PerformanceEnsembleWinView:OnBtnStartClicked()
	-- 同意合奏
	local MsgID = CS_CMD.CS_CMD_PERFORM
	local SubID = PERFORM_CMD.EnsembleCmdConfirm
	local MsgBody = {
		Cmd = SubID,
		Confirm = {
			IsAgree = true
		}
	}
	
	MusicPerformanceUtil.Log(table.tostring(MsgBody))
		
	GameNetworkMgr:SendMsg(MsgID, SubID, MsgBody)

	-- 本地视作已经确认，预表现
	_G.MusicPerformanceVM.EnsembleConfirmStatus[MajorUtil.GetMajorRoleID()] = MPDefines.ConfirmStatus.ConfirmStatusConfirm
	self:SetConfirmStatus(MPDefines.ConfirmStatus.ConfirmStatusConfirm)
end

--取消/拒绝按钮
function PerformanceEnsembleWinView:OnBtnCancelClicked()
	_G.MusicPerformanceMgr:CancelEnsembleCmdConfirm() 
end

--暂时收起按钮
function PerformanceEnsembleWinView:OnBtnKeepClicked()
	_G.UIViewMgr:HideView(self.ViewID)
end

function PerformanceEnsembleWinView:OnBtnEnsembleListenHelpClicked()
	self.VM.PanelAssistantIntroVisible = not self.VM.PanelAssistantIntroVisible
end

function PerformanceEnsembleWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MusicPerformanceEnsembleConfirm, self.OnMusicPerformanceEnsembleConfirm)
end

function PerformanceEnsembleWinView:OnMusicPerformanceEnsembleConfirm(Params)
	if MajorUtil.IsMajorByRoleID(Params.RoleID) then
		self:SetConfirmStatus(Params.ConfirmStatus)
	else
		-- 队长检查当前是否可以开始合奏
		if _G.TeamMgr:IsCaptain() then
			self.VM.BtnStartIsEnable = _G.MusicPerformanceMgr:GetTeamConfirmResult() == MPDefines.TeamConfirmResult.AllAgree
			self.VM.BtnKeepIsEnable = not self.VM.BtnStartIsEnable
		end
	end
	self:CheckAllTeamPlayerConfirmState(true)
end

--检查队伍所有人确认完之后的表现
function PerformanceEnsembleWinView:CheckAllTeamPlayerConfirmState(IsEnsembleConfirm)
	if _G.MusicPerformanceMgr:GetTeamConfirmResult() == MPDefines.TeamConfirmResult.AllAgree then
		_G.MusicPerformanceVM:CancelTimer()
		self.VM.PanelProBarVisible = false
		local TextTipsStr = LSTR(830020)
		self.VM.TextTips = string.format(TextTipsStr)
		--仅合奏确认结果出来时提示
		if IsEnsembleConfirm then
			_G.MsgTipsUtil.ShowTips(TextTipsStr)
		end
	end
end

--进度倒计时改变
function PerformanceEnsembleWinView:OnReadyTimeChanged(Value)
	self.VM.ProBarValue = Value / MPDefines.Ensemble.DefaultSettings.ReadyTime
	self.VM.TextTips = string.format(LSTR(830040), MPDefines.Ensemble.DefaultSettings.ReadyTime - Value)
end


function PerformanceEnsembleWinView:OnStatusChanged(Value)
	if Value == EnsembleStatus.EnsembleStatusEnsemble then
		self:Hide()
	end
end

function PerformanceEnsembleWinView:OnRegisterBinder()
	local Binders = {
		{ "PanelAssistantIntroVisible", UIBinderSetIsVisible.New(self, self.PanelAssistantIntro) },
		{ "PanelProBarVisible", UIBinderSetIsVisible.New(self, self.PanelProBar) },
		{ "PanelEnsembleListenVisible", UIBinderSetIsVisible.New(self, self.PanelEnsembleListen) },
		{ "TextTipsVisible", UIBinderSetIsVisible.New(self, self.TextTips) },
		{ "BtnStartIsEnable", UIBinderSetIsEnabled.New(self,self.BtnStart)},
		{ "BtnKeepIsEnable", UIBinderSetIsEnabled.New(self,self.BtnKeep)},
		{ "BtnCancelIsEnable", UIBinderSetIsEnabled.New(self,self.BtnCancel)},
		{ "TextELVisible", UIBinderSetIsVisible.New(self, self.TextEL) },
		{ "PlayerList", UIBinderUpdateBindableList.New(self, self.TableViewMemberAdapter) },
		{ "ProBarValue", UIBinderSetPercent.New(self, self.ProBarWait) },
		{ "TextBPM", UIBinderSetText.New(self, self.TextBPM) },
		{ "TextBEAT", UIBinderSetText.New(self, self.TextBEAT) },
		{ "TextAssistant", UIBinderSetText.New(self, self.TextAssistant) },
		{ "TextTips", UIBinderSetText.New(self, self.TextTips) },
		{ "TextBtnStart", UIBinderSetText.New(self, self.BtnStart) },
		{ "TextBtnCancel", UIBinderSetText.New(self, self.BtnCancel) },
		{ "TextEL", UIBinderSetText.New(self, self.TextEL) },
	}

	self:RegisterBinders(self.VM, Binders)

	local MainVM = _G.MusicPerformanceVM
	local MainBinders = {
		{ "ReadyTime", UIBinderValueChangedCallback.New(self, nil, self.OnReadyTimeChanged) },
		{ "Status", UIBinderValueChangedCallback.New(self, nil, self.OnStatusChanged) },
	}

	self:RegisterBinders(MainVM, MainBinders)
end

return PerformanceEnsembleWinView