---
--- Author: Administrator
--- DateTime: 2024-02-22 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local WardrobeUnlockPanelVM = require("Game/Wardrobe/VM/WardrobeUnlockPanelVM")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local ClosetCfg = require("TableCfg/ClosetCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemUtil = require("Utils/ItemUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ClosetGlobalCfg = require("TableCfg/ClosetGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

---@class WardrobeUnlockListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnList UFButton
---@field ImgEquipmentv UFImage
---@field ImgFavorite UFImage
---@field ImgSelect UFImage
---@field PanelList UFCanvasPanel
---@field SingleBox CommSingleBoxView
---@field TextCondition UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeUnlockListItemView = LuaClass(UIView, true)

function WardrobeUnlockListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnList = nil
	--self.ImgEquipmentv = nil
	--self.ImgFavorite = nil
	--self.ImgSelect = nil
	--self.PanelList = nil
	--self.SingleBox = nil
	--self.TextCondition = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeUnlockListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeUnlockListItemView:OnInit()
	self.Binders = {
		{ "ItemName", UIBinderSetText.New(self, self.TextName) },
		{ "ReduceCond", UIBinderSetIsVisible.New(self, self.TextCondition) },
		{ "FavoriteVisible", UIBinderSetIsVisible.New(self, self.ImgFavorite) },
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "EquipmentIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgEquipmentv)},
		{ "CheckedState", UIBinderSetIsChecked.New(self, self.SingleBox.ToggleButton) },
	}
end

function WardrobeUnlockListItemView:OnDestroy()

end

function WardrobeUnlockListItemView:OnShow()
	self.TextCondition:SetText(_G.LSTR(1080098))
end

function WardrobeUnlockListItemView:OnHide()

end

function WardrobeUnlockListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnList, self.OnClickItemBtn)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox.ToggleButton, self.OnCheckedChanged)
end

function WardrobeUnlockListItemView:OnRegisterGameEvent()

end

function WardrobeUnlockListItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end


function WardrobeUnlockListItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.IsSelected = bSelected
end

function WardrobeUnlockListItemView:OnCheckedChanged(ToggleButton, State)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	local TotalUseItemNum = WardrobeUnlockPanelVM:CheckedUseItemNum()
	local CheckedNum = WardrobeUnlockPanelVM:CheckedStateNum()
	if CheckedNum >= _G.WardrobeMgr:GetMaxUnlockNum() then
		IsChecked = false
		self.SingleBox.ToggleButton:SetChecked(IsChecked, false)
		MsgTipsUtil.ShowTips(_G.LSTR(1080127))
	end

	if not IsChecked then
		ViewModel.CheckedState = IsChecked
	else
		if table.is_nil_empty(WardrobeUtil.GetAchievementIDList(ViewModel.ID)) then
			if not WardrobeUtil.GetIsSpecial(ViewModel.ID) then
				TotalUseItemNum = TotalUseItemNum + WardrobeUtil.GetUnlockCostItemNum(ViewModel.ID)
				ViewModel.CheckedState = IsChecked
			else
				ViewModel.CheckedState = IsChecked
			end
		else
			ViewModel.CheckedState = IsChecked
		end
	end

	WardrobeUnlockPanelVM:UpdateAppearanceListCheckStateData()
end

function WardrobeUnlockListItemView:OnClickItemBtn()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then return end

	Adapter:OnItemClicked(self, Params.Index)
end



return WardrobeUnlockListItemView