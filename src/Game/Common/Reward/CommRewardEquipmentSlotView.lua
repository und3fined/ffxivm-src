---
--- Author: Administrator
--- DateTime: 2025-09-16 16:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")

---@class CommRewardEquipmentSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF UFCanvasPanel
---@field ImgCheck UFImage
---@field ImgEquipment UFImage
---@field ImgFavorite UFImage
---@field ImgNo UFImage
---@field ImgSelect UFImage
---@field ImgTrait UFImage
---@field ImgUnlock UFImage
---@field PanelSlot UFCanvasPanel
---@field SizeBoxNo USizeBox
---@field SizeBoxTrait USizeBox
---@field StainTag WardrobeStainTagItemView
---@field TextName UFTextBlock
---@field TextUnlock UFTextBlock
---@field AnimIn_1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommRewardEquipmentSlotView = LuaClass(UIView, true)

function CommRewardEquipmentSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF = nil
	--self.ImgCheck = nil
	--self.ImgEquipment = nil
	--self.ImgFavorite = nil
	--self.ImgNo = nil
	--self.ImgSelect = nil
	--self.ImgTrait = nil
	--self.ImgUnlock = nil
	--self.PanelSlot = nil
	--self.SizeBoxNo = nil
	--self.SizeBoxTrait = nil
	--self.StainTag = nil
	--self.TextName = nil
	--self.TextUnlock = nil
	--self.AnimIn_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommRewardEquipmentSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.StainTag)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommRewardEquipmentSlotView:OnInit()
	self.Binders = {
		{ "UnlockVisible", UIBinderSetIsVisible.New(self, self.ImgUnlock) },
		{ "CanUnlockVisible", UIBinderSetIsVisible.New(self, self.TextUnlock) },
		{ "StainTagVisible", UIBinderSetIsVisible.New(self, self.StainTag) },
		{ "FavoriteVisible", UIBinderSetIsVisible.New(self, self.ImgFavorite) },
		{ "CheckVisible", UIBinderSetIsVisible.New(self, self.ImgCheck) },
		{ "CanEquip", UIBinderSetIsVisible.New(self, self.SizeBoxNo, true) },
		{ "TraitVisible", UIBinderSetIsVisible.New(self, self.SizeBoxTrait)} ,
		{ "TraitIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgTrait) },
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "ItemName", UIBinderSetText.New(self, self.TextName) },
		{ "EquipmentIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgEquipment) },
		{ "StainColorVisible", UIBinderSetIsVisible.New(self, self.StainTag.ImgDye)} ,
		{ "RewardItemPlayAnimIn", UIBinderValueChangedCallback.New(self, nil, self.OnRewardItemPlayAnimInChanged) }, 
	}
end

function CommRewardEquipmentSlotView:OnDestroy()

end

function CommRewardEquipmentSlotView:OnShow()
	self.TextUnlock:SetText(_G.LSTR(1080085))
	UIUtil.SetIsVisible(self.StainTag.ImgStainColor, false)
	-- Todo 查询一下是否要更新数据
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	local RewardPanel = _G.UIViewMgr:FindView(_G.UIViewID.CommonRewardAppearancePanel)
	if RewardPanel ~= nil then
		if ViewModel.IsReward ~= nil then
			if RewardPanel.PlayedAnimFirstIn then
				UIUtil.SetRenderOpacity(self.PanelSlot, 0)
				UIUtil.SetRenderOpacity(self.EFF, 100)
			end
		end
	else
		WardrobeMgr:SendClosetQueryPartUnlockReq(ViewModel.ID)
	end
end

function CommRewardEquipmentSlotView:OnHide()

end

function CommRewardEquipmentSlotView:OnRegisterUIEvent()

end

function CommRewardEquipmentSlotView:OnRegisterGameEvent()

end

function CommRewardEquipmentSlotView:OnRegisterBinder()
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


function CommRewardEquipmentSlotView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	if ViewModel.IsReward then
		return
	end

	ViewModel.IsSelected = bSelected
end

function CommRewardEquipmentSlotView:OnRewardItemPlayAnimInChanged(NewValue)
	if NewValue then 
		self:PlayAnimation(self.AnimIn_1)
			self:RegisterTimer(function ()
				UIUtil.SetRenderOpacity(self.EFF, 0)
			end, self.AnimIn_1:GetEndTime())
		UIUtil.SetRenderOpacity(self.PanelSlot, 100)
	end
end

return CommRewardEquipmentSlotView