---
--- Author: xingcaicao
--- DateTime: 2025-04-07 14:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local ColorDefine = require("Define/ColorDefine")

local ListSelectedColor = ColorDefine.ListSelectedColor

---@class LinkShellMgRecruitWayItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextDesc UFTextBlock
---@field FTextName UFTextBlock
---@field FTextPrivateChatTips UFTextBlock
---@field ImgSelect UFImage
---@field PanelAllowPrivateChat UFCanvasPanel
---@field SingleBoxAllowPrivateChat CommSingleBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellMgRecruitWayItemView = LuaClass(UIView, true)

function LinkShellMgRecruitWayItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextDesc = nil
	--self.FTextName = nil
	--self.FTextPrivateChatTips = nil
	--self.ImgSelect = nil
	--self.PanelAllowPrivateChat = nil
	--self.SingleBoxAllowPrivateChat = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellMgRecruitWayItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBoxAllowPrivateChat)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellMgRecruitWayItemView:OnInit()
	self.Binders = {
		{ "MgIsAllowPrivateChat", UIBinderSetIsChecked.New(self, self.SingleBoxAllowPrivateChat, false) },
	}
end

function LinkShellMgRecruitWayItemView:OnDestroy()

end

function LinkShellMgRecruitWayItemView:OnShow()
	local Data = (self.Params or {}).Data or {}

	-- 招募类型名
	self.FTextName:SetText(Data.Name)

	-- 招募类型描述
	self.FTextDesc:SetText(Data.Desc)

	-- 私聊会话
	if Data.AllowSetPrivateChat then
		self.FTextPrivateChatTips:SetText(_G.LSTR(40052)) -- "允许在加入前发起私聊对话"
		UIUtil.SetIsVisible(self.PanelAllowPrivateChat, true)
		self.SingleBoxAllowPrivateChat:SetIsEnabled(true)

	else
		UIUtil.SetIsVisible(self.PanelAllowPrivateChat, false)
	end
end

function LinkShellMgRecruitWayItemView:OnHide()

end

function LinkShellMgRecruitWayItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxAllowPrivateChat, self.OnStateChangedAllowPrivateChat)
end

function LinkShellMgRecruitWayItemView:OnRegisterGameEvent()

end

function LinkShellMgRecruitWayItemView:OnRegisterBinder()
	self:RegisterBinders(LinkShellVM, self.Binders)
end

function LinkShellMgRecruitWayItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)

	if UIUtil.IsVisible(self.PanelAllowPrivateChat) then
		self.SingleBoxAllowPrivateChat:SetIsEnabled(IsSelected)
		UIUtil.SetColorAndOpacityHex(self.FTextPrivateChatTips, IsSelected and ListSelectedColor.Selected or ListSelectedColor.Normal)	
	end
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellMgRecruitWayItemView:OnStateChangedAllowPrivateChat(_, State)
	if nil == self.Params then
		return
	end

	local Data = self.Params.Data
	if nil == Data or Data.AllowSetPrivateChat ~= true then
		return
	end

	LinkShellVM.MgIsAllowPrivateChat = UIUtil.IsToggleButtonChecked(State)
end

return LinkShellMgRecruitWayItemView