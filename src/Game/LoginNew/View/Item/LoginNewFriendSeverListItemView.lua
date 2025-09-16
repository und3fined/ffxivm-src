---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:58
--- Description:
---

local CommonUtil = require("Utils/CommonUtil")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local LoginMgr = require("Game/Login/LoginMgr")
local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID
local LSTR = _G.LSTR

local FLOG_INFO = _G.FLOG_INFO

---@class LoginNewFriendSeverListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field ImgGoBg UFImage
---@field ImgSeverBg UFImage
---@field ImgSeverSelect UFImage
---@field LoginNewFriend LoginNewFriendItem2View
---@field LoginNewSever LoginNewSeverItemView
---@field TextName1 UFTextBlock
---@field TextName2 UFTextBlock
---@field TextSever UFTextBlock
---@field TextState UFTextBlock
---@field TextState_1 UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewFriendSeverListItemView = LuaClass(UIView, true)

function LoginNewFriendSeverListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.ImgGoBg = nil
	--self.ImgSeverBg = nil
	--self.ImgSeverSelect = nil
	--self.LoginNewFriend = nil
	--self.LoginNewSever = nil
	--self.TextName1 = nil
	--self.TextName2 = nil
	--self.TextSever = nil
	--self.TextState = nil
	--self.TextState_1 = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewFriendSeverListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.LoginNewFriend)
	self:AddSubView(self.LoginNewSever)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewFriendSeverListItemView:OnInit()
	UIUtil.SetIsVisible(self.ImgSeverBg, true, true)
end

function LoginNewFriendSeverListItemView:OnDestroy()

end

function LoginNewFriendSeverListItemView:OnShow()
	local Params = self.Params
	if nil == Params then return end

	---@type FriendServerListItemVM
	local VM = Params.Data
	if nil == VM then return end

	if CommonUtil.GetStrLen(VM.FriendName) > 14 then
		self.TextName1:SetText(string.format("%s...", CommonUtil.SubStr(VM.FriendName, 1, 14)))
	else
		self.TextName1:SetText(VM.FriendName)
	end
	self.TextName2:SetText(VM.RoleName)
	self.TextSever:SetText(VM.Name)
	self.LoginNewSever:SetWorldID(VM.WorldID)
	self.LoginNewSever:SetState(VM.State)
	FLOG_INFO("[LoginNewFriendSeverListItemView:OnShow] Name:%s", VM.FriendName)

	if VM.IsOnline then
		self.TextState:SetText(LSTR(LoginStrID.Online))
		UIUtil.TextBlockSetColorAndOpacity(self.TextState, 0.250158, 0.508881, 0.246201, 1)
	else
		local LastLoginTime = tonumber(VM.LoginTime)
		if LastLoginTime then
			local offlineTime = TimeUtil.GetOfflineDesc(LastLoginTime)
			self.TextState:SetText(string.format("%s%s", LSTR(LoginStrID.Offline), offlineTime))
			FLOG_INFO("[LoginNewFriendSeverListItemView:OnShow] OfflineStr:%s", offlineTime)
			UIUtil.TextBlockSetColorAndOpacity(self.TextState, 0.223228, 0.223228, 0.223228, 1)
		end
	end
	--UIUtil.SetIsVisible(self.TextState, VM.IsOnline)

	self.TextState_1:SetText(LSTR(LoginStrID.GoTo))

	if VM.State == LoginNewDefine.ServerStateEnum.Maintenance then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgGoBg, LoginNewDefine.FriendBtnBgDisable)
	else
		UIUtil.ImageSetBrushFromAssetPath(self.ImgGoBg, LoginNewDefine.FriendBtnBgNormal)
	end

	self.LoginNewFriend:ShowIconByUrl(VM.HeadUrl)

end

function LoginNewFriendSeverListItemView:OnHide()

end

function LoginNewFriendSeverListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickBtnGo)
end

function LoginNewFriendSeverListItemView:OnRegisterGameEvent()

end

function LoginNewFriendSeverListItemView:OnRegisterBinder()

end

function LoginNewFriendSeverListItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgSeverSelect, IsSelected)
end

---@see LoginNewSeverListItemView:OnClickBtn
function LoginNewFriendSeverListItemView:OnClickBtnGo()
	if self.Params.Data.WorldState == LoginNewDefine.ServerStateEnum.Maintenance then
		MsgTipsUtil.ShowTips(LSTR(LoginStrID.SvrMaintenance))
		return
	end

	LoginNewVM.WorldID = self.Params.Data.WorldID
	LoginNewVM.WorldState = self.Params.Data.State
	LoginNewVM.NodeTag = self.Params.Data.Tag
	LoginMgr.OverseasSvrAreaId = self.Params.Data.CustomValue2

	local UIViewID = require("Define/UIViewID")
	UIViewMgr:HideView(UIViewID.LoginServerList)
	_G.EventMgr:SendEvent(_G.EventID.LoginShowMainPanel)
end

return LoginNewFriendSeverListItemView