---
--- Author: raymondxiao
--- DateTime: 2021-04-09 09:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")

---@class ReviveTipsBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG CommMsgTipsView
---@field CommonPlaySound_UIBP CommonPlaySoundView
---@field KeepBtn CommBtnSView
---@field RejectBtn CommBtnSView
---@field ReviveBtn CommBtnSView
---@field RichText_Line01 URichTextBox
---@field RichText_Line02 URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ReviveTipsBoxView = LuaClass(UIView, true)

function ReviveTipsBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.CommonPlaySound_UIBP = nil
	--self.KeepBtn = nil
	--self.RejectBtn = nil
	--self.ReviveBtn = nil
	--self.RichText_Line01 = nil
	--self.RichText_Line02 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ReviveTipsBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CommonPlaySound_UIBP)
	self:AddSubView(self.KeepBtn)
	self:AddSubView(self.RejectBtn)
	self:AddSubView(self.ReviveBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ReviveTipsBoxView:UpdateLeftTime()
	if (_G.ReviveMgr == nil or _G.ReviveMgr.ReviveInfo == nil or self.RichText_Line02 == nil) then
		return
	end

	local LeftTime = _G.ReviveMgr.ReviveInfo.RescueDeadline - _G.TimeUtil.GetServerTime()
	if (LeftTime < 0) then
		self:OnClickReject()
		return
	end

	self.RichText_Line02:SetText(string.format("(%d)", LeftTime))
end

function ReviveTipsBoxView:OnInit()
	--self.PopUpBG:SetCallback(self, self.OnClickKeep)
	-- 长按压开启
	-- self.RejectBtn.ParamLongPress = true
	-- self.RejectBtn.ParamPressTime = 3 -- time 3s
end

function ReviveTipsBoxView:OnDestroy()

end

function ReviveTipsBoxView:OnShow()
	self:InitConstInfo()
	self:UpdateReviveInfo()
	if self.AnimScale ~= nil then
		self:PlayAnimation(self.AnimScale)
	end
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.BeDeathView) then
		_G.UIViewMgr:FindView(_G.UIViewID.BeDeathView):ShowDeatFloatButton()
	end
end

function ReviveTipsBoxView:InitConstInfo()
	self.BG:SetTitleText(_G.LSTR(460010))	--"救助提示"
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true
	self.RejectBtn:SetText(_G.LSTR(460011)) -- "拒 绝"
	self.KeepBtn:SetText(_G.LSTR(460012)) -- "保 留"
	self.ReviveBtn:SetText(_G.LSTR(460013)) -- "接 受"
	self.RichText_Line01:SetText(_G.LSTR(460015)) --是否接受复活？
end

function ReviveTipsBoxView:ShowReviveButton()
	if _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.Revive) ~= nil then
        _G.SidebarMgr:TryOpenSidebarMainWin()
	else
	    _G.SidebarMgr:AddSidebarItem(SidebarDefine.SidebarType.Revive, _G.TimeUtil.GetServerTime(), _G.ReviveMgr.ReviveInfo.RescueDeadline - _G.TimeUtil.GetServerTime())
	end
	_G.UIViewMgr:HideView(_G.UIViewID.BeReviveView)
end

function ReviveTipsBoxView:OnHide()
	_G.SidebarMgr:TryOpenSidebarMainWin()
end

function ReviveTipsBoxView:UpdateReviveInfo()
	if (_G.ReviveMgr == nil or _G.ReviveMgr.ReviveInfo == nil or self.RichText_Line01 == nil) then
		return
	end

	self.RichText_Line01:SetText(string.format(_G.LSTR(460009), _G.ReviveMgr.ReviveRescueRoleName)) --要接受 %s 的救助吗？
end

function ReviveTipsBoxView:OnRegisterUIEvent()
	if self.ReviveBtn.ParamLongPress then
		_G.UIUtil.AddOnLongPressedEvent(self, self.ReviveBtn, self.OnClickRevive)
	else
		_G.UIUtil.AddOnClickedEvent(self, self.ReviveBtn, self.OnClickRevive)
	end
	if self.KeepBtn.ParamLongPress then
		_G.UIUtil.AddOnLongPressedEvent(self, self.KeepBtn, self.OnClickKeep)
	else
		_G.UIUtil.AddOnClickedEvent(self, self.KeepBtn, self.OnClickKeep)
	end
	if self.RejectBtn.ParamLongPress then
		_G.UIUtil.AddOnLongPressedEvent(self, self.RejectBtn, self.OnClickReject)
	else
		_G.UIUtil.AddOnClickedEvent(self, self.RejectBtn, self.OnClickReject)
	end
end

function ReviveTipsBoxView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ReviveInfoUpdate, self.UpdateReviveInfo)
end

function ReviveTipsBoxView:OnRegisterTimer()
	if (_G.ReviveMgr == nil or _G.ReviveMgr.ReviveInfo == nil) then
		return
	end

	self:RegisterTimer(self.UpdateLeftTime, 0, 1, 0);
end

function ReviveTipsBoxView:OnRegisterBinder()

end

function ReviveTipsBoxView:OnClickReject()
	if _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.Revive) ~= nil then
        _G.SidebarMgr:RemoveSidebarItem(SidebarDefine.SidebarType.Revive)
    end
	self:SendRevive(false)
end

function ReviveTipsBoxView:OnClickKeep()
	if self.AnimScale ~= nil then
		local Delay = self.AnimScale:GetEndTime()
		_G.TimerMgr:AddTimer(nil, self.ShowReviveButton, Delay)
	else
		self:ShowReviveButton()
	end
end

function ReviveTipsBoxView:OnClickRevive()
	if _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.Revive) ~= nil then
        _G.SidebarMgr:RemoveSidebarItem(SidebarDefine.SidebarType.Revive)
    end
	self:SendRevive(true)
end

function ReviveTipsBoxView:SendRevive(bIsAccepted)
	_G.ReviveMgr:SendRevive(bIsAccepted)
	self:Hide()
end

return ReviveTipsBoxView