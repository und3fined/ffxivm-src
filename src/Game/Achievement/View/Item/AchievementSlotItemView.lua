---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---


local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemVM = require("Game/Item/ItemVM")

local AchievementMgr = _G.AchievementMgr

---@class AchievementSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpackSlot CommBackpackSlotView
---@field CommIcon UFImage
---@field ImgBg UFImage
---@field ImgFrame UFImage
---@field PanelIcon UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AchievementSlotItemView = LuaClass(UIView, true)

function AchievementSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpackSlot = nil
	--self.CommIcon = nil
	--self.ImgBg = nil
	--self.ImgFrame = nil
	--self.PanelIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AchievementSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpackSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AchievementSlotItemView:OnInit()
	self.AchievementID = 0
	local ItemVM = self.ItemVM or ItemVM.New()
	ItemVM.IsQualityVisible = true 
	ItemVM.ItemQualityIcon = ""
	ItemVM.Icon = ""
	ItemVM.IsValid = true 
	self.ItemVM = ItemVM
	self.CommBackpackSlot:SetParams({ Data = self.ItemVM })

	self.IconPanelList = {
		[1] = self.CommBackpackSlot,
		[2] = self.CommIcon,
	}

	for i = 1, #self.IconPanelList do
		UIUtil.SetIsVisible(self.IconPanelList[i], false)
	end
end

function AchievementSlotItemView:OnDestroy()

end

function AchievementSlotItemView:OnShow()

end

function AchievementSlotItemView:OnHide()

end

function AchievementSlotItemView:OnRegisterUIEvent()

end

function AchievementSlotItemView:OnRegisterGameEvent()

end

function AchievementSlotItemView:OnRegisterBinder()

end

function AchievementSlotItemView:SetAchievementID(AchievementID)
	for i = 1, #self.IconPanelList do
		UIUtil.SetIsVisible(self.IconPanelList[i], false)
	end
	self.AchievementID = AchievementID
	local AchievemwntInfo = AchievementMgr:GetAchievementInfo(AchievementID)
	if AchievemwntInfo ~= nil then
		local IconType = AchievemwntInfo.IsItemIcon == 1 and 1 or 2
		self:SetIconAssetPath(IconType, AchievemwntInfo.IconPath)
		UIUtil.SetIsVisible(self.IconPanelList[IconType],  true )
	end
end

function AchievementSlotItemView:SetIconAssetPath(IconPanelIndex, AchieveIconPath)
	if IconPanelIndex == 1 then
		local Cfg = ItemCfg:FindCfgByKey( tonumber(AchieveIconPath) )
		if Cfg ~= nil then
			if 1 == Cfg.IsHQ then
				self.ItemVM.ItemQualityIcon = ItemDefine.HQItemIconColorType[Cfg.ItemColor]
			else
				self.ItemVM.ItemQualityIcon = ItemDefine.ItemIconColorType[Cfg.ItemColor]
			end
			if (Cfg.IconID or 0) ~= 0 then
				self.ItemVM.Icon = ItemCfg.GetIconPath(Cfg.IconID)
			else
				self.ItemVM.Icon = ""
				self.ItemVM.IsValid = false 
			end
		else
			self.ItemVM.ItemQualityIcon = ""
			self.ItemVM.Icon = ""
			self.ItemVM.IsValid = false 
		end
	else
		UIUtil.ImageSetBrushFromAssetPath(self.IconPanelList[IconPanelIndex], AchieveIconPath )
	end
end

return AchievementSlotItemView