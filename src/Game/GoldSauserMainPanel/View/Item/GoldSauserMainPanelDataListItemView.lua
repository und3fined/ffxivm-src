---
--- Author: Administrator
--- DateTime: 2023-12-29 20:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath") 
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class GoldSauserMainPanelDataListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgListBg UFImage
---@field TextPercentage UFTextBlock
---@field TextType URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelDataListItemView = LuaClass(UIView, true)

function GoldSauserMainPanelDataListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgListBg = nil
	--self.TextPercentage = nil
	--self.TextType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelDataListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelDataListItemView:OnInit()

end

function GoldSauserMainPanelDataListItemView:OnDestroy()

end

function GoldSauserMainPanelDataListItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self:OnPercentageChanged(VM.Percentage)
end

function GoldSauserMainPanelDataListItemView:OnHide()

end

function GoldSauserMainPanelDataListItemView:OnRegisterUIEvent()

end

function GoldSauserMainPanelDataListItemView:OnRegisterGameEvent()

end

function GoldSauserMainPanelDataListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.Binders = {
		{"PercentageStr", UIBinderSetText.New(self, self.TextPercentage)},
		{"DescriptionStr", UIBinderSetText.New(self, self.TextType)},
		{"Percentage", UIBinderValueChangedCallback.New(self, nil, self.OnPercentageChanged)},
		{"BgPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgListBg)},
	}
	self:RegisterBinders(VM, self.Binders)
end

function GoldSauserMainPanelDataListItemView:OnPercentageChanged(Percentage)
	
end
return GoldSauserMainPanelDataListItemView