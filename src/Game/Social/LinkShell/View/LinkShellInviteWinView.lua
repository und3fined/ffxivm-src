---
--- Author: xingcaicao
--- DateTime: 2024-07-11 11:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local MajorUtil = require("Utils/MajorUtil")

local LSTR = _G.LSTR

---@class LinkShellInviteWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnSure CommBtnLView
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellInviteWinView = LuaClass(UIView, true)

function LinkShellInviteWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnSure = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellInviteWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSure)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellInviteWinView:OnInit()
	self.TableAdapterList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectChanged)
end

function LinkShellInviteWinView:OnDestroy()

end

function LinkShellInviteWinView:OnShow()
	self:InitConstText()

	if nil == self.Params then
		return
	end

	self.LinkShellList = self.Params.LinkShellList or {}
	self.InviteRoleID = self.Params.InviteRoleID

	self.TableAdapterList:UpdateAll(self.LinkShellList)
	self.TableAdapterList:SetSelectedIndex(1)
end

function LinkShellInviteWinView:OnHide()

end

function LinkShellInviteWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel,	self.OnClickButtonCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnSure, 	self.OnClickButtonSure)
end

function LinkShellInviteWinView:OnRegisterGameEvent()

end

function LinkShellInviteWinView:OnRegisterBinder()

end

function LinkShellInviteWinView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.BG:SetTitleText(LSTR(40041)) -- "通讯贝邀请"
	self.BtnCancel:SetButtonText(LSTR(10003)) -- "取 消"
	self.BtnSure:SetButtonText(LSTR(10002)) -- "确 认"
end

function LinkShellInviteWinView:OnSelectChanged(Index, ItemData, ItemView)
	self.CurSelectID = ItemData.ID
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function LinkShellInviteWinView:OnClickButtonCancel()
	self:Hide()
end

function LinkShellInviteWinView:OnClickButtonSure()
	if self.CurSelectID and self.InviteRoleID then
		LinkShellMgr:SendMsgLSInviteJoinReq(self.CurSelectID, MajorUtil.GetMajorRoleID(), self.InviteRoleID)
	end

	self:Hide()
end

return LinkShellInviteWinView