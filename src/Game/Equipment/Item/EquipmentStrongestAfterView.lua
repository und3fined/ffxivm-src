--[[
Author: luojiewen_ds luojiewen@dasheng.tv
Date: 2024-07-03 10:04:22
LastEditors: luojiewen_ds luojiewen@dasheng.tv
LastEditTime: 2024-07-16 19:57:57
FilePath: \Script\Game\Equipment\Item\EquipmentStrongestAfterView.lua
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

---@class EquipmentStrongestAfterView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img_Line UFImage
---@field Img_PartIcon UFImage
---@field SlotItem EquipmentSlotItemView
---@field Text_EquipName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentStrongestAfterView = LuaClass(UIView, true)

function EquipmentStrongestAfterView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Img_Line = nil
	--self.Img_PartIcon = nil
	--self.SlotItem = nil
	--self.Text_EquipName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentStrongestAfterView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SlotItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentStrongestAfterView:OnInit()
	self.ViewModel = EquipmentStrongestItemVM.New()
end

function EquipmentStrongestAfterView:OnDestroy()
	
end

function EquipmentStrongestAfterView:OnShow()
	self:UpdateUI(self.Params.Data)
	local HasPlayStrongestAnimNum = _G.EquipmentMgr:GetHasPlayStrongestAnimNumR()
	local CanPlayStrongestAnimNum = _G.EquipmentMgr:GetCanPlayStrongestAnimNum()
	if HasPlayStrongestAnimNum < CanPlayStrongestAnimNum then
		_G.EquipmentMgr:SetStrongestAnimPlayNum(false, HasPlayStrongestAnimNum + 1)
		self:RegisterTimer(function()
			self:PlayAnimation(self.AnimationLeftIn)
		end, self.Params.Data.DelayTime or 0)
	else
		self:SetRenderOpacity(1)
	end
end

function EquipmentStrongestAfterView:OnHide()
	
end

function EquipmentStrongestAfterView:OnRegisterUIEvent()
	
end

function EquipmentStrongestAfterView:OnRegisterGameEvent()
	
end

function EquipmentStrongestAfterView:OnRegisterBinder()
	-- local Param = self.Params

	-- if Param then
	-- 	self.SlotItem.ViewModel.bBtnVisibel = false
	-- 	self.SlotItem.ViewModel:SetPart(Param.Part, Param.ResID)
	-- 	self.ViewModel:SetPart(Param.Part, Param.ResID)
	-- end

	local Binders = {
		{ "EquipmentName", UIBinderSetText.New(self, self.Text_EquipName) },
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.Img_PartIcon) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function EquipmentStrongestAfterView:UpdateUI(Param)
	if Param == nil then
		return
	end
	self.SlotItem.ViewModel.bBtnVisibel = false
	self.SlotItem.ViewModel.bShowProgress = false
	self.SlotItem.ViewModel:SetPart(Param.Part, Param.ResID)
	self.ViewModel:SetPart(Param.Part, Param.ResID)
end

return EquipmentStrongestAfterView