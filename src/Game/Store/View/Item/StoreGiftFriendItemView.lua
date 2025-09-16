
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local StoreDefine = require("Game/Store/StoreDefine")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")
local StoreUtil = require("Game/Store/StoreUtil")

---@class StoreGiftFriendItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGift CommBtnSView
---@field CommPlayerItem CommPlayerItemView
---@field ContentNode UFCanvasPanel
---@field ImgBG UFImage
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field TextLevel UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreGiftFriendItemView = LuaClass(UIView, true)

function StoreGiftFriendItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGift = nil
	--self.CommPlayerItem = nil
	--self.ContentNode = nil
	--self.ImgBG = nil
	--self.ProfSlot = nil
	--self.TextLevel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreGiftFriendItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGift)
	self:AddSubView(self.CommPlayerItem)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreGiftFriendItemView:OnInit()

end

function StoreGiftFriendItemView:OnDestroy()

end

function StoreGiftFriendItemView:OnShow()
	self.BtnGift:SetBtnName(LSTR(950006))
end

function StoreGiftFriendItemView:OnHide()

end

function StoreGiftFriendItemView:OnRegisterUIEvent()

end

function StoreGiftFriendItemView:OnRegisterGameEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGift, self.OnClickBtnGift)
end

function StoreGiftFriendItemView:OnClickBtnGift()
	if self.RoleID == nil then
		return
	end
	_G.StoreMainVM:OnShowGiftMailPanel(false, {GoodID = StoreMainVM:GetCurrentGoodsID(),
		TargetRoleID = self.RoleID, ToName = self.RoleName})
	if nil ~= StoreMainVM.CurrentSelectedItem then
		local GoodsID = StoreMainVM.CurrentSelectedItem.GoodID or StoreMainVM.CurrentSelectedItem.GoodsId -- 非道具：GoodID 道具：GoodId
		StoreUtil.ReportGiftClickFlow(GoodsID, StoreDefine.GiftOperationType.ClickFriendGiftButton)
	end
end

function StoreGiftFriendItemView:OnRegisterBinder()
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

return StoreGiftFriendItemView