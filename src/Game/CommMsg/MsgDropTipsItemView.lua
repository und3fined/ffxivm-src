---
--- Author: anypkvcai
--- DateTime: 2021-09-13 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
-- local ProtoCS = require("Protocol/ProtoCS")
-- local LOOT_TYPE = ProtoCS.LOOT_TYPE
-- local ItemCfg = require("TableCfg/ItemCfg")
local ItemDropVM = require("Game/Item/ItemDropVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetItemColor = require("Binder/UIBinderSetItemColor")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class MsgDropTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Icon UFImage
---@field FImg_Quality UFImage
---@field RichText_Name URichTextBox
---@field SizeBoxHQ USizeBox
---@field Anim_Fly UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MsgDropTipsItemView = LuaClass(UIView, true)

function MsgDropTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Icon = nil
	--self.FImg_Quality = nil
	--self.RichText_Name = nil
	--self.SizeBoxHQ = nil
	--self.Anim_Fly = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MsgDropTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MsgDropTipsItemView:OnInit()
	UIUtil.SetIsVisible(self.SizeBoxHQ, false)
end

function MsgDropTipsItemView:OnDestroy()

end

function MsgDropTipsItemView:OnShow()
	self:PLayAnimation(self.Anim_Fly)
end

function MsgDropTipsItemView:OnRegisterUIEvent()

end

function MsgDropTipsItemView:OnRegisterGameEvent()

end

function MsgDropTipsItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local LootItem = Params.LootItem
	if nil == LootItem then
		return
	end

	local ViewModel = ItemDropVM.CreateVM(LootItem)

	local Binders = {
		{ "Color", UIBinderSetItemColor.New(self, self.FImg_Quality) },
		{ "QualityVisible", UIBinderSetIsVisible.New(self, self.FImg_Quality) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.FImg_Icon) },
		{ "Name", UIBinderSetText.New(self, self.RichText_Name) },
		{ "Color", UIBinderSetItemColor.New(self, self.RichText_Name) },

	}

	self:RegisterBinders(ViewModel, Binders)
end

function MsgDropTipsItemView:OnAnimationFinished(Animation)
	local Params = self.Params
	if nil == Params then
		return
	end

	Params.OnItemAnimationFinished(Params.View, self)
end

return MsgDropTipsItemView