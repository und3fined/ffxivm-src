---
--- Author: mingyyzhang
--- DateTime: 2025-06-13 16:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local HouseInfoInvitePanelVM = require("Game/House/VM/HouseInfoInvitePanelVM")
---@class HouseInfoInvitePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommEmpty CommBackpackEmptyView
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoInvitePanelView = LuaClass(UIView, true)

function HouseInfoInvitePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommEmpty = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoInvitePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommEmpty)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoInvitePanelView:OnInit()
	self.ViewModel = HouseInfoInvitePanelVM.New()

	self.Binders = {
		{"InvitedListVisibility", UIBinderSetIsVisible.New(self, self.TableViewList)},}
		--{"InvitedListVisibility", UIBinderSetIsVisible.New(self, self.CommEmpty, true)},   --该控件无法通过binder绑定控制显隐 原因未知
	self.InvitedListTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
end

function HouseInfoInvitePanelView:OnDestroy()

end

function HouseInfoInvitePanelView:OnShow()
	self.ViewModel.InvitedList = {}
	_G.HouseInfoMgr:SendGetInviteInformation()
	self.CommEmpty:SetTipsContent(HouseLocalDef.BeInvitedEmptyStr)
	self.InvitedListTableViewAdapter:UpdateAll(self.ViewModel.InvitedList)

end

function HouseInfoInvitePanelView:OnHide()

end

function HouseInfoInvitePanelView:OnRegisterUIEvent()
	
end

function HouseInfoInvitePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.HouseGetInvitedRsp, self.OnGetHouseInvitedRsp)
	self:RegisterGameEvent(_G.EventID.HouseInviteReplyRsp, self.OnHouseInviteReplyRsp)
end

function HouseInfoInvitePanelView:OnRegisterBinder()

end

function HouseInfoInvitePanelView:OnGetHouseInvitedRsp(MsgBody)
	if MsgBody and MsgBody.Invites  then
		if #MsgBody.Invites > 0 then
			self.ViewModel:GetInvitedList(MsgBody.Invites)
			UIUtil.SetIsVisible(self.CommEmpty, false)
		else
			UIUtil.SetIsVisible(self.CommEmpty, true)
		end
		self.InvitedListTableViewAdapter:UpdateAll(self.ViewModel.InvitedList)
	end
end

function HouseInfoInvitePanelView:OnHouseInviteReplyRsp(MsgBody)
	if MsgBody and MsgBody.HouseID > 0 then
		if not MsgBody.Reply  then
			self:OnShow()
		end
		
	end
end

return HouseInfoInvitePanelView