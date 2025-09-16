---
--- Author: Administrator
--- DateTime: 2024-04-01 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR

---@class FootPrintListTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconOn UFImage
---@field IconUnder UFImage
---@field PanelAllAchieved UFCanvasPanel
---@field TextAllAchieved UFTextBlock
---@field TextDistance UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FootPrintListTitleItemView = LuaClass(UIView, true)

function FootPrintListTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconOn = nil
	--self.IconUnder = nil
	--self.PanelAllAchieved = nil
	--self.TextAllAchieved = nil
	--self.TextDistance = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FootPrintListTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FootPrintListTitleItemView:InitConstStringInfo()
	self.TextAllAchieved:SetText(LSTR(320010))
end


function FootPrintListTitleItemView:OnInit()
	self.Binders = {
		{"TypeName", UIBinderSetText.New(self, self.TextTitle)},
		{"NumComplete", UIBinderSetText.New(self, self.TextDistance)},
		{"TextDistanceVisible", UIBinderSetIsVisible.New(self, self.TextDistance)},
		{"UpArrowVisible", UIBinderSetIsVisible.New(self, self.IconOn)},
		{"DownArrowVisible", UIBinderSetIsVisible.New(self, self.IconUnder)},
		{"bAllItemComplete", UIBinderSetIsVisible.New(self, self.PanelAllAchieved)},
	}
	self:InitConstStringInfo()
end

function FootPrintListTitleItemView:OnDestroy()

end

function FootPrintListTitleItemView:OnShow()

end

function FootPrintListTitleItemView:OnHide()

end

function FootPrintListTitleItemView:OnRegisterUIEvent()

end

function FootPrintListTitleItemView:OnRegisterGameEvent()

end

function FootPrintListTitleItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return FootPrintListTitleItemView