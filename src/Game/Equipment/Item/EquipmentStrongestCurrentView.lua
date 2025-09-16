--[[
Author: luojiewen_ds luojiewen@dasheng.tv
Date: 2024-07-03 10:04:11
LastEditors: luojiewen_ds luojiewen@dasheng.tv
LastEditTime: 2024-07-16 20:13:26
FilePath: \Script\Game\Equipment\Item\EquipmentStrongestCurrentView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: enqingchen
--- DateTime: 2021-12-27 15:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EquipmentStrongestItemVM = require("Game/Equipment/VM/EquipmentStrongestItemVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class EquipmentStrongestCurrentView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img_PartIcon UFImage
---@field SizeBoxItem USizeBox
---@field SlotItem EquipmentSlotItemView
---@field Text_EquipName1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentStrongestCurrentView = LuaClass(UIView, true)

function EquipmentStrongestCurrentView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Img_PartIcon = nil
	--self.SizeBoxItem = nil
	--self.SlotItem = nil
	--self.Text_EquipName1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentStrongestCurrentView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SlotItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentStrongestCurrentView:OnInit()
	self.ViewModel = EquipmentStrongestItemVM.New()
end

function EquipmentStrongestCurrentView:OnDestroy()
	
end

function EquipmentStrongestCurrentView:OnShow()
	self:UpdateUI(self.Params.Data)
	local HasPlayStrongestAnimNum = _G.EquipmentMgr:GetHasPlayStrongestAnimNumL()
	local CanPlayStrongestAnimNum = _G.EquipmentMgr:GetCanPlayStrongestAnimNum()
	if HasPlayStrongestAnimNum < CanPlayStrongestAnimNum then
		_G.EquipmentMgr:SetStrongestAnimPlayNum(true, HasPlayStrongestAnimNum + 1)
		self:RegisterTimer(function()
			self:PlayAnimation(self.AnimationLeftIn)
		end, self.Params.Data.DelayTime or 0)
	else
		self:SetRenderOpacity(1)
	end
end

function EquipmentStrongestCurrentView:OnHide()
	
end

function EquipmentStrongestCurrentView:OnRegisterUIEvent()
	
end

function EquipmentStrongestCurrentView:OnRegisterGameEvent()
	
end

function EquipmentStrongestCurrentView:OnRegisterBinder()
	-- local Param = self.Params

	-- if Param then
	-- 	self.SlotItem.ViewModel.bBtnVisibel = false
	-- 	self.SlotItem.ViewModel:SetPart(Param.Part, Param.ResID)
	-- 	self.ViewModel:SetPart(Param.Part, Param.ResID)
	-- end

	local Binders = {
		{ "EquipmentName", UIBinderSetText.New(self, self.Text_EquipName1) },
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.Img_PartIcon) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function EquipmentStrongestCurrentView:UpdateUI(Param)
	if Param == nil then
		return
	end
	if nil ~= Param.ResID then
		UIUtil.SetIsVisible(self.SizeBoxItem, true)
		self.SlotItem.ViewModel.bBtnVisibel = false
		self.SlotItem.ViewModel.bShowProgress = false
		self.SlotItem.ViewModel:SetPart(Param.Part, Param.ResID)
	else
		UIUtil.SetIsVisible(self.SizeBoxItem, false)
	end
	self.ViewModel:SetPart(Param.Part, Param.ResID)
end

return EquipmentStrongestCurrentView