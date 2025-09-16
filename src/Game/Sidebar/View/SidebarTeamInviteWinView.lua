---
--- Author: xingcaicao
--- DateTime: 2023-06-26 10:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBindableList = require("UI/UIBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local SimpleProfInfoVM = require("Game/Profession/VM/SimpleProfInfoVM")
local TimeUtil = require("Utils/TimeUtil")


---@class SidebarTeamInviteWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAccept CommBtnSView
---@field BtnClose UFButton
---@field BtnRefuse CommBtnSView
---@field EFF_ProBarLight UFImage
---@field ProBarCD UProgressBar
---@field RichTextMsg URichTextBox
---@field TableViewMemberProf UTableView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBarLight UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SidebarTeamInviteWinView = LuaClass(UIView, true)

function SidebarTeamInviteWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAccept = nil
	--self.BtnClose = nil
	--self.BtnRefuse = nil
	--self.EFF_ProBarLight = nil
	--self.ProBarCD = nil
	--self.RichTextMsg = nil
	--self.TableViewMemberProf = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProBarLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidebarTeamInviteWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAccept)
	self:AddSubView(self.BtnRefuse)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidebarTeamInviteWinView:OnInit()
	self.TableAdapterMemberProf = UIAdapterTableView.CreateAdapter(self, self.TableViewMemberProf)
	self.BtnRefuse:SetText(_G.LSTR(1300054))
	self.BtnAccept:SetText(_G.LSTR(1300055))
end

function SidebarTeamInviteWinView:OnShow()
	self.RichTextMsg:SetText("")

	local Params = self.Params
	if nil == Params then
		return
	end

	--成员职业列表
	local Data = {}
	local MemberProfIDList = Params.MemberProfIDList or {}
	local ProfVMList = UIBindableList.New(SimpleProfInfoVM)

	for i = 1, 8 do
		table.insert(Data, { ProfID = MemberProfIDList[i] })
	end

	local ProfUtil = require("Game/Profession/ProfUtil")
	ProfVMList:UpdateByValues(Data, ProfUtil.SortByProfID)
	self.TableAdapterMemberProf:UpdateAll(ProfVMList)

	--邀请信息
	local CaptainRoleVM = _G.RoleInfoMgr:FindRoleVM(self.Params.CaptainRoleID)
	if CaptainRoleVM then
		local MajorUtil = require("Utils/MajorUtil")
		local Text = string.sformat( _G.LSTR((CaptainRoleVM.CurWorldID == MajorUtil.GetMajorRoleVM(true).CurWorldID) and 1300074 or 1300073), CaptainRoleVM.Name)
		self.RichTextMsg:SetText(Text)
	else
		self.RichTextMsg:SetText("")
	end

	UIUtil.SetIsVisible(self.EFF_ProBarLight, false)
	self:PlayAnimationTimeRange(self.AnimProBarLight, 0, self.ProBarCD.Percent, 1, nil, 1.0, false)
end

function SidebarTeamInviteWinView:OnRegisterTimer()
	--应答倒计时
	self:RegisterTimer(self.OnTimer, 0.1, 0.3, 0)
end

function SidebarTeamInviteWinView:OnHide()
	if self.Params and not (self.Params.bResume == false) then
		if TimeUtil.GetServerTime() - self.Params.StartTime < self.Params.CountDown then
			local SidebarMgr = require("Game/Sidebar/SidebarMgr")
			SidebarMgr:TryOpenSidebarMainWin()
		end
	end
end

function SidebarTeamInviteWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse.Button, 	self.OnClickButtonRefuse)
	UIUtil.AddOnClickedEvent(self, self.BtnAccept.Button, 	self.OnClickButtonAccept)
	UIUtil.AddOnClickedEvent(self, self.BtnClose,			self.OnClickButtonClose)
end

function SidebarTeamInviteWinView:SetProBarCD( ElapsedTime )
	if not self.Params then
		return
	end

	self.ProBarCD:SetPercent(math.clamp(1 - ElapsedTime / self.Params.CountDown, 0, 1))
end

function SidebarTeamInviteWinView:OnTimer()
	if not self.Params then
		return
	end

	self:SetProBarCD(self:GetTimeElapsed())
	if self:GetTimeElapsed() >= self.Params.CountDown then
		self:Hide()
		return
	end
end

function SidebarTeamInviteWinView:GetTimeElapsed()
	return self.Params and math.max(0, TimeUtil.GetServerTime() - self.Params.StartTime) or 0
end

function SidebarTeamInviteWinView:OnAnimationFinished(Animation)
	if Animation == self.AnimProBarLight then
		UIUtil.SetIsVisible(self.EFF_ProBarLight, false)
	end
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function SidebarTeamInviteWinView:OnClickButtonRefuse()
	if self.Params then
		self:ReqActionWithLimit("LastReqTime", function()
			_G.TeamMgr:SendAnswerInviteReq(self.Params.TeamID, false, self.Params.CaptainRoleID)
		end, 2)
	end

	self.Params.bResume = false
	-- _G.TeamMgr:ClearInvitePopUpInfo()
	self:Hide()
end

function SidebarTeamInviteWinView:OnClickButtonAccept()
	if self.Params then
		self:ReqActionWithLimit("LastReqTime", function()
			_G.TeamMgr:SendAnswerInviteReq(self.Params.TeamID, true, self.Params.CaptainRoleID)
		end, 2)
	end

	self.Params.bResume = false
	self:Hide()
end

function SidebarTeamInviteWinView:OnClickButtonClose()
	self:Hide()
end

function SidebarTeamInviteWinView:ReqActionWithLimit(Key, Callbakck, Threshould)
	if self[Key] == nil or os.time() - self[Key] >= Threshould then
		Callbakck()
	end
	self[Key] = os.time()
end

return SidebarTeamInviteWinView