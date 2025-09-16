---
--- Author: Administrator
--- DateTime: 2025-03-13 17:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class GoldSauserMainPanelAwardGetWayItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FButton_265 UFButton
---@field IconReceive UFImage
---@field ImgArrow UFImage
---@field ImgItemIcon UFImage
---@field TextQuestName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelAwardGetWayItemView = LuaClass(UIView, true)

function GoldSauserMainPanelAwardGetWayItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FButton_265 = nil
	--self.IconReceive = nil
	--self.ImgArrow = nil
	--self.ImgItemIcon = nil
	--self.TextQuestName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelAwardGetWayItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelAwardGetWayItemView:OnInit()

end

function GoldSauserMainPanelAwardGetWayItemView:OnDestroy()

end

function GoldSauserMainPanelAwardGetWayItemView:OnShow()

end

function GoldSauserMainPanelAwardGetWayItemView:OnHide()

end

function GoldSauserMainPanelAwardGetWayItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButton_265, self.OnClickBtnClick)
end

function GoldSauserMainPanelAwardGetWayItemView:OnRegisterGameEvent()

end

function GoldSauserMainPanelAwardGetWayItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	local Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgItemIcon) },
		{ "bGot", UIBinderSetIsVisible.New(self, self.ImgArrow, true) },
		{ "bGot", UIBinderSetIsVisible.New(self, self.IconReceive) },
		{ "AchievementName", UIBinderSetText.New(self, self.TextQuestName) },
		--TODO
	}

	self:RegisterBinders(VM, Binders)
end

function GoldSauserMainPanelAwardGetWayItemView:OnClickBtnClick()
	local Params = self.Params
	if Params == nil then return end

	local Adapter = Params.Adapter
	if Adapter == nil then return end

	Adapter:OnItemClicked(self, Params.Index)
end

return GoldSauserMainPanelAwardGetWayItemView