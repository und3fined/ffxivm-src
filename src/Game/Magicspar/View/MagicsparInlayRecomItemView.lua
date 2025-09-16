---
--- Author: jamiyang
--- DateTime: 2023-04-03 16:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")

---@class MagicsparInlayRecomItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Icon UFImage
---@field FImg_ItemSelect UFImage
---@field FImg_TagRecom UFImage
---@field FImg_Use UFImage
---@field RichTextNum URichTextBox
---@field Text_Attri UFTextBlock
---@field Text_HoldValue UFTextBlock
---@field Text_MagicsparName_1 UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparInlayRecomItemView = LuaClass(UIView, true)

function MagicsparInlayRecomItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Icon = nil
	--self.FImg_ItemSelect = nil
	--self.FImg_TagRecom = nil
	--self.FImg_Use = nil
	--self.RichTextNum = nil
	--self.Text_Attri = nil
	--self.Text_HoldValue = nil
	--self.Text_MagicsparName_1 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparInlayRecomItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparInlayRecomItemView:OnInit()

end

function MagicsparInlayRecomItemView:OnDestroy()

end

function MagicsparInlayRecomItemView:OnShow()
	UIUtil.SetIsVisible(self.RichTextNum, true)
end

function MagicsparInlayRecomItemView:OnHide()

end

function MagicsparInlayRecomItemView:OnRegisterUIEvent()

end

function MagicsparInlayRecomItemView:OnRegisterGameEvent()

end

function MagicsparInlayRecomItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		--{ "bInlayed", UIBinderSetText.New(self, self.Text_MagicsparName) },
		--{ "bRecommend", UIBinderSetIsVisible.New(self, self.FImg_TagRecom) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.FImg_ItemSelect) },
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.FImg_Icon) },
		{ "Name", UIBinderSetText.New(self, self.Text_MagicsparName_1) },
		{ "Desc", UIBinderSetText.New(self, self.Text_Attri) },
		--{ "iCount", UIBinderSetTextFormat.New(self, self.Text_HoldValue, _G.LSTR(1060003)) },--"持有 %d"
		{ "bUse", UIBinderSetIsVisible.New(self, self.FImg_Use) },
		{ "iCount", UIBinderSetTextFormat.New(self, self.RichTextNum, "%d") },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function MagicsparInlayRecomItemView:OnSelectChanged(bSelect)
	self.ViewModel.bSelect = bSelect
end

return MagicsparInlayRecomItemView