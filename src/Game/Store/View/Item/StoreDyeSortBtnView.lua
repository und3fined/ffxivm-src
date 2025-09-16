
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class StoreDyeSortBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field PanelItem UFCanvasPanel
---@field TextSort UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreDyeSortBtnView = LuaClass(UIView, true)

function StoreDyeSortBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.PanelItem = nil
	--self.TextSort = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreDyeSortBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreDyeSortBtnView:OnInit()
	self.Binders = {
		{ "bSelected", UIBinderSetIsVisible.New(self, self.ImgSelect, false, false, false) },
		{ "SubName", UIBinderSetText.New(self, self.TextSort) },
		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextSort) },
	}
end

function StoreDyeSortBtnView:OnDestroy()

end

function StoreDyeSortBtnView:OnShow()
end

function StoreDyeSortBtnView:OnHide()

end

function StoreDyeSortBtnView:OnRegisterUIEvent()

end

function StoreDyeSortBtnView:OnRegisterGameEvent()

end

function StoreDyeSortBtnView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return StoreDyeSortBtnView