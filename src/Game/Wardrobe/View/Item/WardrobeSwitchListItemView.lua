---
--- Author: Administrator
--- DateTime: 2024-02-22 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class WardrobeSwitchListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot BagSlotView
---@field BtnList UFButton
---@field ImgSelect UFImage
---@field PanelList UFCanvasPanel
---@field TextName UFTextBlock
---@field TextRecommend UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeSwitchListItemView = LuaClass(UIView, true)

function WardrobeSwitchListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot = nil
	--self.BtnList = nil
	--self.ImgSelect = nil
	--self.PanelList = nil
	--self.TextName = nil
	--self.TextRecommend = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeSwitchListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeSwitchListItemView:OnInit()
	self.Binders = {
		{"Name", UIBinderSetText.New(self, self.TextName)},
		{"IsRecommend", UIBinderSetIsVisible.New(self, self.TextRecommend)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
	}
end

function WardrobeSwitchListItemView:OnDestroy()

end

function WardrobeSwitchListItemView:OnShow()
	self.TextRecommend:SetText(_G.LSTR(1080079))
end

function WardrobeSwitchListItemView:OnHide()

end

function WardrobeSwitchListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BagSlot.BtnSlot, self.OnClickBagItem)

end

function WardrobeSwitchListItemView:OnRegisterGameEvent()

end

function WardrobeSwitchListItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.BagSlot:SetParams({Data = ViewModel.BagSlotVM})
end

function WardrobeSwitchListItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.IsSelected = bSelected
	if bSelected then
		self:OnClickBagItem()
	end
end

function WardrobeSwitchListItemView:OnClickBagItem()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	local ResID = ViewModel.GID
	if ResID ~= nil and ResID ~= 0 then
		self:RegisterTimer(function()
			if _G.BagMgr:FindItem(ResID) ~= nil then
				ItemTipsUtil.ShowTipsByGID(ResID, self.PanelList)
			else
				local Item, Part = _G.EquipmentMgr:GetEquipedItemByGID(ResID)
				ItemTipsUtil.ShowTipsByItem(Item, self.PanelList)
			end
		end, 0.3)
	end

end

return WardrobeSwitchListItemView