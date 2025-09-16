---
--- Author: Administrator
--- DateTime: 2025-03-11 14:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class GoldSauserMainPanelAwardTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconTabNormal UFImage
---@field IconTabSelect UFImage
---@field ToggleButton_71 UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelAwardTabItemView = LuaClass(UIView, true)

function GoldSauserMainPanelAwardTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconTabNormal = nil
	--self.IconTabSelect = nil
	--self.ToggleButton_71 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelAwardTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelAwardTabItemView:OnInit()
	
end

function GoldSauserMainPanelAwardTabItemView:OnDestroy()

end

function GoldSauserMainPanelAwardTabItemView:OnShow()

end

function GoldSauserMainPanelAwardTabItemView:OnHide()

end

function GoldSauserMainPanelAwardTabItemView:OnRegisterUIEvent()

end

function GoldSauserMainPanelAwardTabItemView:OnRegisterGameEvent()

end

function GoldSauserMainPanelAwardTabItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	local Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.IconTabNormal) },
		{ "IconSelected", UIBinderSetBrushFromAssetPath.New(self, self.IconTabSelect) },
		{ "bChecked", UIBinderSetIsChecked.New(self, self.ToggleButton_71) },
	}

	self:RegisterBinders(VM, Binders)
end

function GoldSauserMainPanelAwardTabItemView:OnSelectChanged(bSelect)
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	VM.bChecked = bSelect
end

return GoldSauserMainPanelAwardTabItemView