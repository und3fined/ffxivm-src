---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:59
--- Description:
---

local CommonUtil = require("Utils/CommonUtil")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local PreLoginMgr = require("Game/LoginNew/Mgr/PreLoginMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIUtil = require("Utils/UIUtil")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID
local LSTR = _G.LSTR

---@class LoginNewPermissionsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAgree CommBtnLView
---@field BtnRefuse CommBtnLView
---@field BtnVolume UFButton
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field TableViewDrop UTableView
---@field TextCalendar UFTextBlock
---@field TextHealthy UFTextBlock
---@field TextLoction UFTextBlock
---@field TextMic UFTextBlock
---@field TextPhone UFTextBlock
---@field TextSave UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewPermissionsWinView = LuaClass(UIView, true)

function LoginNewPermissionsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAgree = nil
	--self.BtnRefuse = nil
	--self.BtnVolume = nil
	--self.Comm2FrameM_UIBP = nil
	--self.TableViewDrop = nil
	--self.TextCalendar = nil
	--self.TextHealthy = nil
	--self.TextLoction = nil
	--self.TextMic = nil
	--self.TextPhone = nil
	--self.TextSave = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewPermissionsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAgree)
	self:AddSubView(self.BtnRefuse)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewPermissionsWinView:OnInit()
	self.TableViewDropAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewDrop)
end

function LoginNewPermissionsWinView:OnDestroy()

end

function LoginNewPermissionsWinView:OnShow()
	UIUtil.SetIsVisible(self.Comm2FrameM_UIBP.ButtonClose, false);

	local IndicatorConfig = {
		{ IsSelected = false },
		{ IsSelected = true }
	}
	self.TableViewDropAdapter:UpdateAll(IndicatorConfig)
	self.TableViewDropAdapter:SetSelectedIndex(2)
end

function LoginNewPermissionsWinView:OnHide()

end

function LoginNewPermissionsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAgree, self.OnClickBtnAgree)
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse, self.OnClickBtnRefuse)
	UIUtil.AddOnClickedEvent(self, self.BtnVolume, self.OnClickBtnVolume)
	UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.ButtonClose, self.OnClickBtnRefuse)
end

function LoginNewPermissionsWinView:OnRegisterGameEvent()

end

function LoginNewPermissionsWinView:OnRegisterBinder()

end

function LoginNewPermissionsWinView:OnClickBtnAgree()
	PreLoginMgr:AcquirePermissions()

	-- 保存权限标志
	local SaveKey = require("Define/SaveKey")
	local SaveMgr = _G.UE.USaveMgr
	SaveMgr.LoadFile("PreLoginData", false, false)
	SaveMgr.SetInt(SaveKey.RequirePermission, 1, false)
	SaveMgr.SaveFile("PreLoginData", false)

	_G.UIViewMgr:ShowView(_G.UIViewID.LoginSplash)
end

function LoginNewPermissionsWinView:OnClickBtnRefuse()
	local MsgBoxUtil = require("Utils/MsgBoxUtil")
	local Callback = function()
		CommonUtil.QuitGame()
	end
	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(LoginStrID.TipsTitle), LSTR(LoginStrID.ConfirmRefusePermission), Callback, nil, LSTR(LoginStrID.CancelBtnStr), LSTR(LoginStrID.ConfirmBtnStr))
end

function LoginNewPermissionsWinView:OnClickBtnVolume()
	-- TODO 静音

end

return LoginNewPermissionsWinView