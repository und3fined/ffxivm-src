--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-06-18 10:28:16
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-06-20 10:16:48
FilePath: \Script\Game\Team\View\TeamTeleportWinView.lua
Description: 跨服确认弹窗
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoginMgr = require("Game/Login/LoginMgr")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
---@class TeamTeleportWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field RichMainContent URichTextBox
---@field RichSubContent URichTextBox
---@field Server LoginNewSeverItem2View
---@field TextServer UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamTeleportWinView = LuaClass(UIView, true)

function TeamTeleportWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameM_UIBP = nil
	--self.RichMainContent = nil
	--self.RichSubContent = nil
	--self.Server = nil
	--self.TextServer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamTeleportWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.Server)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamTeleportWinView:OnRegisterUIEvent()
	local Widget = self.Comm2FrameM_UIBP
	UIUtil.AddOnClickedEvent(self, Widget.Ben2Left, self.OnClickCancel)
	UIUtil.AddOnClickedEvent(self, Widget.Btn2Right, self.OnClickOk)
end
function TeamTeleportWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldCrossWorld, self.OnCrossSuccess)
	self:RegisterGameEvent(EventID.QueryRoleInfo, 	 self.OnQueryCaptainRoleInfoDataUpdate)
	if self.Params.CrossAfterEvent then
		self:RegisterGameEvent(self.Params.CrossAfterEvent, 	 self.OnEventCrossWorld)
	end
end

function TeamTeleportWinView:OnShow()
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(1530001))
	self.Comm2FrameM_UIBP.Btn2Right:SetBtnName(LSTR(10027))
	self.Comm2FrameM_UIBP.Ben2Left:SetBtnName(LSTR(10028))
	
	self:SetTeleportContent()
	self.CheckRoleID = self.Params and self.Params.CheckRoleID
	self.ConfirmCallBack = self.Params and self.Params.ConfirmCallBack
end

function TeamTeleportWinView:OnHide()
	self.CheckRoleID = nil
	self.ConfirmCallBack = nil
end

function TeamTeleportWinView:SetTeleportContent()
	if self.Params and self.Params.WorldID then
		local Name = LoginMgr:GetMapleNodeName(self.Params.WorldID)
		self.TextServer:SetText(Name)

		local NodeInfo = LoginMgr:GetMapleNodeInfo(self.Params.WorldID)
		local Icon = LoginNewDefine.ServerStateConfigMap[NodeInfo.State].Icon
		local StateName = LoginNewDefine.ServerStateConfigMap[NodeInfo.State].Name
		self.Server:SetSeverContent(StateName, Icon)
	else
		FLOG_ERROR("TeamTeleportWinView:SetTeleportContent() Get Empty WorldID")
	end

	self.RichMainContent:SetText(self.Params and self.Params.MainContent or "")
	self.RichSubContent:SetText(self.Params and self.Params.SubContent or "")
end

function TeamTeleportWinView:DelayCrossWorld()
	if self.Params and self.Params.WorldID then
		local MajorActor = MajorUtil.GetMajor()
		local MajorPos = MajorActor and MajorActor:FGetActorLocation() or _G.UE.FVector(0, 0, 0)
		local Pos = {
			X = math.floor(MajorPos.X),
			Y = math.floor(MajorPos.Y),
			Z = math.floor(MajorPos.Z)
		}
		local ActorRotation = MajorActor:FGetActorRotation()
		local CrystalPortalMgr = require("Game/PWorld/CrystalPortal/CrystalPortalMgr")
		self:RegisterTimer(function()
			CrystalPortalMgr:SendTravelCrossWorldTransReq(self.Params.WorldID, Pos, math.floor(ActorRotation.Yaw) or 0)
		end, 1, 0, 1)
	end
end

function TeamTeleportWinView:OnClickOk()
	--- 组队跨服需传入 组队队长可能随时变动worldid 需二次查询
	if self.CheckRoleID then
		_G.RoleInfoMgr:SendQueryInfoByRoleID(self.CheckRoleID)
	else
		if self.ConfirmCallBack then
			self.ConfirmCallBack()
		end

		if not self.Params.CrossAfterEvent then
			self:DelayCrossWorld()
		end
	end
end

function TeamTeleportWinView:OnClickCancel()
	self:Hide()
end

function TeamTeleportWinView:OnQueryCaptainRoleInfoDataUpdate(RoleID)
	if self.CheckRoleID and self.CheckRoleID == RoleID then
		local CheckRoleWorldID = (_G.RoleInfoMgr:FindRoleVM(RoleID) or {}).CurWorldID or 0 
		local MajorRoleWorldID = (MajorUtil.GetMajorRoleVM() or {}).CurWorldID or 0 

		if CheckRoleWorldID ~= MajorRoleWorldID then
			self.Params.WorldID = CheckRoleWorldID
			if self.ConfirmCallBack then
				self.ConfirmCallBack()
			end

			if not self.Params.CrossAfterEvent then
				self:DelayCrossWorld()
			end
		else
			self:DelayCheckCaptainRoleInfo()
			self:Hide()
		end
	end
end

function TeamTeleportWinView:OnCrossSuccess()
	if self.Params and self.Params.CrossSuccesssCallback then
		self.Params.CrossSuccesssCallback()
	end

	self:DelayCheckCaptainRoleInfo()
	self:Hide()
end

---- 招募 需要加入招募队伍才会跨服 
function TeamTeleportWinView:OnEventCrossWorld()
	self:DelayCrossWorld()
end

function TeamTeleportWinView:DelayCheckCaptainRoleInfo()
	if self.CheckRoleID then
		_G.TeamMgr:DelayUpdatRoleInfo(self.CheckRoleID)
	end
end

return TeamTeleportWinView