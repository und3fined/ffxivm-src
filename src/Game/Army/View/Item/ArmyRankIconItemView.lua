---
--- Author: daniel
--- DateTime: 2023-03-24 18:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmyRankIconItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgRankIcon UFImage
---@field ImgSelect UFImage
---@field ToggleBtnRankIcon UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyRankIconItemView = LuaClass(UIView, true)

function ArmyRankIconItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgRankIcon = nil
	--self.ImgSelect = nil
	--self.ToggleBtnRankIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyRankIconItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyRankIconItemView:OnInit()

end

function ArmyRankIconItemView:OnDestroy()

end

function ArmyRankIconItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	if nil == Params.Data then
		return
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgRankIcon, Params.Data.Icon)
	if not Params.Data.IsSelected then
		self.ToggleBtnRankIcon:SetIsEnabled(Params.Data.IsEnabled)
	else
		self.ToggleBtnRankIcon:SetIsEnabled(true)
	end
end

function ArmyRankIconItemView:OnHide()

end

function ArmyRankIconItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnRankIcon, self.OnClickedItem)
end

function ArmyRankIconItemView:OnRegisterGameEvent()

end

function ArmyRankIconItemView:OnRegisterBinder()

end

function ArmyRankIconItemView:OnClickedItem()
	local Params = self.Params
	if nil == Params then
		return
	end
	if Params.Data.IsSelected then
		self.ToggleBtnRankIcon:SetChecked(true, false)
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
end

---@field IsSelected boolean
function ArmyRankIconItemView:OnSelectChanged(IsSelected)
	self.ToggleBtnRankIcon:SetChecked(IsSelected, false)
end

return ArmyRankIconItemView