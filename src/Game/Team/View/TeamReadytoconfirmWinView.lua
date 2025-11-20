--[[
Author: jususchen jususchen@tencent.com
Date: 2025-07-14 14:26:56
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-07-14 15:01:13
FilePath: \Script\Game\Team\View\TeamReadytoconfirmWinView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local TeamHelperMgr = require("Game/Team/Abs/TeamHelperMgr")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local UIBinderLambdaComputeChange = require("Binder/UIBinderLambdaComputeChange")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class TeamReadytoconfirmWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnNormal CommBtnMView
---@field BtnRecom CommBtnMView
---@field CommHorTabs CommHorTabsView
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field FProgressBar_46 UFProgressBar
---@field PanelBtn UFCanvasPanel
---@field TableView_31 UTableView
---@field TextHint UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamReadytoconfirmWinView = LuaClass(UIView, true)

function TeamReadytoconfirmWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnNormal = nil
	--self.BtnRecom = nil
	--self.CommHorTabs = nil
	--self.CommSidebarFrameS_UIBP = nil
	--self.FProgressBar_46 = nil
	--self.PanelBtn = nil
	--self.TableView_31 = nil
	--self.TextHint = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamReadytoconfirmWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnNormal)
	self:AddSubView(self.BtnRecom)
	self:AddSubView(self.CommHorTabs)
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamReadytoconfirmWinView:OnPostInit()
	UIUtil.SetIsVisible(self.CommHorTabs, false)

	self.ATVPlayers = UIAdapterTableView.CreateAdapter(self, self.TableView_31,nil, false, nil, true)

	self.BinderSubTitle = UIBinderLambdaComputeChange.CustomNew(self, function(_, v)
		self.CommSidebarFrameS_UIBP:SetSubTitleText(v)
	end, function()
		if self.Params and self.Params.TeamVM then
			return string.sformat("%d/%d", self.Params.TeamVM.CurConfirmCount, self.Params.TeamVM.TotalConfirmCount)
		end
	end)
	self.TeamBinders = {
		{ "BindableListMember", 			UIBinderUpdateBindableList.New(self, self.ATVPlayers) },
		{ "bMajorConfirmTeamReady", 		UIBinderSetIsVisible.New(self, self.PanelBtn, true)},
		{ "CurConfirmCount", self.BinderSubTitle},
		{ "TotalConfirmCount", self.BinderSubTitle},
		{ "TimeTeamReadyToConfirm", 		UIBinderValueChangedCallback.New(self, nil, self.OnTimeTeamReadyToConfirmChanged)},
	}
end

function TeamReadytoconfirmWinView:OnShow()
	if not self.Params then
		return
	end

	self.CommSidebarFrameS_UIBP:SetTitleText(_G.LSTR("1300081"))
	self.TextHint:SetText(_G.LSTR("1300094"))
	self.BtnRecom:SetButtonText(_G.LSTR("1300092"))
	self.BtnNormal:SetButtonText(_G.LSTR("1300093"))

	if TeamHelperMgr:IsTeamReadyVoteFinished() then
		if self.TimerIDLoop then
			self:UnRegisterTimer(self.TimerIDLoop)
			self.TimerIDLoop = nil
		end
		self.FProgressBar_46:SetPercent(0)
	end

	if self.Params and self.Params.TeamVM then
		self.CommSidebarFrameS_UIBP:SetSubTitleText(string.sformat("%d/%d", self.Params.TeamVM.CurConfirmCount, self.Params.TeamVM.TotalConfirmCount))
	end
end

function TeamReadytoconfirmWinView:OnHide()
	local TeamVM = self.Params and self.Params.TeamVM or nil
	if TeamVM == nil or not TeamVM.IsTeam then
		return
	end

	local TimeoutSecs = TeamHelperMgr:GetTeamReadyConfirmTimeoutSeconds()
	if TimeoutSecs > 0 and TeamHelperMgr:IsTeamReadyConfirming() then
		_G.SidebarMgr:AddOrUpdateSidebarItem({
			Type = SidebarDefine.SidebarType.TeamReadyConfirm,
			StartTime = TeamHelperMgr:GetTeamReadyConfirmStartTime(),
			CountDown = TeamHelperMgr:GetTeamReadyConfirmTimeoutInterval(),
			Tips = _G.LSTR(TeamHelperMgr:IsMajorTeamReadyConfirmed() and 1300100 or 1300099),
			bNotNotifyTimeout = true,
			IsTryOpenWin = true,
			TransData = {TeamVM=TeamVM},
		})
	else
		if not _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.TeamReadyConfirm) then
			 _G.SidebarMgr:TryOpenSidebarMainWin()
		end
	end
end

function TeamReadytoconfirmWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnNormal, self.OnClickCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnRecom, self.OnClickConfirm)
end

function TeamReadytoconfirmWinView:OnRegisterTimer()
	self:InitLoopTimer()
end

function TeamReadytoconfirmWinView:OnRegisterBinder()
	if not self.Params then
		return
	end

	self:RegisterBinders(self.Params.TeamVM, self.TeamBinders)
end

function TeamReadytoconfirmWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TeamReadyConfirmFinish, self.OnTeamReadyConfirmFinished)
end

function TeamReadytoconfirmWinView:OnClickConfirm()
	self:Confirm(true)
end

function TeamReadytoconfirmWinView:OnClickCancel()
	self:Confirm(false)
end

function TeamReadytoconfirmWinView:Confirm(bOK)
	if self.Params and self.Params.TeamVM then
		local TeamVM = self.Params.TeamVM
		if TeamVM then
			local TeamMgr = TeamVM:GetOwnerMgr()
			if TeamMgr then
				if bOK then
					TeamHelperMgr:ConfirmReadyOK(TeamMgr)	
				else
					TeamHelperMgr:ConfirmReadyCancel(TeamMgr)
				end
			end
		end
	end
end

function TeamReadytoconfirmWinView:OnTimer()
	local TeamVM = self.Params and self.Params.TeamVM or nil

	if TeamVM then
		local t = _G.TimeUtil.GetServerTime() - (TeamVM:GetTeamConfirmReadyTime() or 0)
		local Percent = t / TeamHelperMgr:GetTeamReadyConfirmTimeoutInterval()
		Percent = math.clamp(1 - Percent, 0, 1)
		self.FProgressBar_46:SetPercent(Percent)
	end
end

function TeamReadytoconfirmWinView:InitLoopTimer()
	if self.TimerIDLoop then
		self:UnRegisterTimer(self.TimerIDLoop)
	end
	self.TimerIDLoop = self:RegisterTimer( function()
		self:OnTimer()
	end, 0.1, 1, 0)
end

function TeamReadytoconfirmWinView:OnTeamReadyConfirmFinished(TeamID)
	if not self.Params or not self.Params.TeamVM then
		return
	end

	local Mgr = self.Params.TeamVM:GetOwnerMgr()
	if Mgr and Mgr:GetTeamID() == TeamID then
		if self.TimerIDLoop then
			self:UnRegisterTimer(self.TimerIDLoop)
			self.TimerIDLoop = nil
		end
		self.FProgressBar_46:SetPercent(0)
	end
end

function TeamReadytoconfirmWinView:OnTimeTeamReadyToConfirmChanged()
	if not self.Params or not self.Params.TeamVM then
		return
	end

	if TeamHelperMgr:IsTeamReadyConfirming() then
		self:InitLoopTimer()
	end
end

return TeamReadytoconfirmWinView