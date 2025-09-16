---
--- Author: zimuyi
--- DateTime: 2023-06-26 15:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")

---@class ProfessionRangeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconRange UFImage
---@field ImgBg UFImage
---@field TableViewProf UTableView
---@field TextRange UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ProfessionRangeItemView = LuaClass(UIView, true)

function ProfessionRangeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconRange = nil
	--self.ImgBg = nil
	--self.TableViewProf = nil
	--self.TextRange = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ProfessionRangeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ProfessionRangeItemView:OnInit()
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewProf)
	self.Binders =
	{
		{ "Title", UIBinderSetTextFormat.New(self, self.TextRange, _G.LSTR(1050173)) },
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.IconRange) },
		{ "BgPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgBg) },
		{ "LevelItemVMList", UIBinderUpdateBindableList.New(self, self.AdapterTableView) },
	}
end

function ProfessionRangeItemView:OnDestroy()

end

function ProfessionRangeItemView:OnShow()

end

function ProfessionRangeItemView:OnHide()

end

function ProfessionRangeItemView:OnRegisterUIEvent()

end

function ProfessionRangeItemView:OnRegisterGameEvent()

end

function ProfessionRangeItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end
	self.ViewModel = self.Params.Data
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return ProfessionRangeItemView