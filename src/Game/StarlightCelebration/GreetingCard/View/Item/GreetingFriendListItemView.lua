---
--- Author: Administrator
--- DateTime: 2025-06-30 16:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIViewID = require("Define/UIViewID")

---@class GreetingFriendListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGift CommBtnSView
---@field CommPlayerItem CommPlayerItemView
---@field ContentNode UFCanvasPanel
---@field ImgBG UFImage
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field TextLevel UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GreetingFriendListItemView = LuaClass(UIView, true)

local LSTR = _G.LSTR

function GreetingFriendListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGift = nil
	--self.CommPlayerItem = nil
	--self.ContentNode = nil
	--self.ImgBG = nil
	--self.ProfSlot = nil
	--self.TextLevel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GreetingFriendListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGift)
	self:AddSubView(self.CommPlayerItem)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GreetingFriendListItemView:OnInit()

end

function GreetingFriendListItemView:OnDestroy()

end

function GreetingFriendListItemView:OnShow()
	self.BtnGift:SetBtnName(LSTR(1670016))    -- "赠送"
end

function GreetingFriendListItemView:OnHide()

end

function GreetingFriendListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGift, self.OnClickBtnGift)
end

function GreetingFriendListItemView:OnRegisterGameEvent()

end

function GreetingFriendListItemView:OnClickBtnGift()
	if self.RoleID == nil then
		MsgTipsUtil.ShowTips(LSTR(1670019))    -- "未找到玩家信息"
		return
	end
	local GreetingCardWinView = _G.UIViewMgr:FindVisibleView(UIViewID.GreetingCardWinView) or {}
	if (GreetingCardWinView.CanGiftNum or 0) <= 0 then
		MsgTipsUtil.ShowTips(LSTR(1670013))    -- "可赠送次数为0，无法赠送"
		return
	end

	_G.GreetingCardWinVM:OpenEditingCardPanel(self.RoleID)
end

function GreetingFriendListItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self.RoleID = ViewModel.RoleID
	self.RoleName = ViewModel.Name

	local Binders = {
		{ "Level",	UIBinderSetText.New(self, self.TextLevel) },
	}
	self:RegisterBinders(ViewModel, Binders)
end

return GreetingFriendListItemView