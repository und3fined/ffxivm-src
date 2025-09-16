---
--- Author: daniel
--- DateTime: 2023-03-10 14:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")

---@class ArmySlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot UFButton
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySlotItemView = LuaClass(UIView, true)

function ArmySlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySlotItemView:OnInit()
	UIUtil.SetIsVisible(self.ImgIcon, true)
end

function ArmySlotItemView:OnDestroy()

end

function ArmySlotItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	if nil == Params.Data then
		return
	end
	if Params.Data.Icon then
		UIUtil.ImageSetBrushTintColorHex(self.ImgIcon, "#FFFFFFFF")
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, Params.Data.Icon, true)
		UIUtil.CanvasSlotSetSize(self.ImgIcon, _G.UE.FVector2D(152, 152))
	elseif Params.Data.ColorHex then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, ArmyDefine.DefaluBadgeBgIcon)
		UIUtil.CanvasSlotSetSize(self.ImgIcon, _G.UE.FVector2D(178, 178))
		UIUtil.ImageSetBrushTintColorHex(self.ImgIcon, Params.Data.ColorHex or "#FFFFFFFF")
	end
end

function ArmySlotItemView:OnHide()

end

function ArmySlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.OnClickedItem)
end

function ArmySlotItemView:OnRegisterGameEvent()

end

function ArmySlotItemView:OnRegisterBinder()
end

function ArmySlotItemView:OnClickedItem()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
end

---@field IsSelected boolean
function ArmySlotItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
end

return ArmySlotItemView