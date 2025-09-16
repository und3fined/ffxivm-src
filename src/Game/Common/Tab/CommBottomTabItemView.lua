---
--- Author: Administrator
--- DateTime: 2024-08-19 19:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class CommBottomTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgSelect UFImage
---@field ImgSelectLight UFImage
---@field PanelSelect UFCanvasPanel
---@field TextTitle UFTextBlock
---@field AnimSelect UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBottomTabItemView = LuaClass(UIView, true)

function CommBottomTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgSelect = nil
	--self.ImgSelectLight = nil
	--self.PanelSelect = nil
	--self.TextTitle = nil
	--self.AnimSelect = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBottomTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBottomTabItemView:OnInit()
	self.Binders = {
        {"TabName", UIBinderSetText.New(self, self.TextTitle)},
        {"IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{"IsSelectedLight", UIBinderSetIsVisible.New(self, self.ImgSelectLight)},
    }
end

function CommBottomTabItemView:OnDestroy()

end

function CommBottomTabItemView:OnShow()

end

function CommBottomTabItemView:OnHide()

end

function CommBottomTabItemView:OnRegisterUIEvent()

end

function CommBottomTabItemView:OnRegisterGameEvent()

end

function CommBottomTabItemView:OnRegisterBinder()
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

function CommBottomTabItemView:OnSelectChanged(NewValue)
	local Color = ""
	if NewValue then
		Color = "#fff4d0"
		self:PlayAnimation(self.AnimSelect)
	else
		Color = "#d5d5d5"
		self:PlayAnimation(self.AnimUncheck)
	end
	UIUtil.SetColorAndOpacityHex(self.TextTitle, Color)
	UIUtil.SetIsVisible(self.ImgSelect, NewValue)
	UIUtil.SetIsVisible(self.ImgSelectLight, NewValue)
end

return CommBottomTabItemView