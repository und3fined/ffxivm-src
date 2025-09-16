---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 11:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class CommGuideSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Icon UFImage
---@field ImgBg UFImage
---@field ImgNormal UFImage
---@field ImgQuery UFImage
---@field ImgSelect UFImage
---@field PanelInfo UFCanvasPanel
---@field RedDot2 CommonRedDot2View
---@field RichTextNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommGuideSlotView = LuaClass(UIView, true)

function CommGuideSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Icon = nil
	--self.ImgBg = nil
	--self.ImgNormal = nil
	--self.ImgQuery = nil
	--self.ImgSelect = nil
	--self.PanelInfo = nil
	--self.RedDot2 = nil
	--self.RichTextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommGuideSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommGuideSlotView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.Icon)},
		{ "ImgQueryIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuery)},
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "NumVisible", UIBinderSetIsVisible.New(self, self.RichTextNum)},
	}
end

function CommGuideSlotView:OnDestroy()

end

function CommGuideSlotView:OnShow()
	if nil == self.Params then return end

	self.ViewModel = self.Params.Data
    if nil == self.ViewModel then return end

    if  not string.isnilorempty(self.ViewModel.RedDotName) then
        local RedDotName = self.ViewModel.RedDotName
        self.RedDot2:SetRedDotNameByString(RedDotName)
    end
end

function CommGuideSlotView:OnHide()

end

function CommGuideSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickButtonItem)
end

function CommGuideSlotView:OnClickButtonItem()
    if(self.ClickCallback ~= nil and self.CallbackView ~= nil) then
        self.ClickCallback(self.CallbackView, self)
    else
        local Params = self.Params
        if(Params and Params.Adapter) then
            Params.Adapter:OnItemClicked(self, Params.Index)
        end
    end
end

function CommGuideSlotView:SetClickButtonCallback(TargetView, TargetCallback)
    self.CallbackView = TargetView
    self.ClickCallback = TargetCallback
end

function CommGuideSlotView:OnRegisterGameEvent()

end

function CommGuideSlotView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then return end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

return CommGuideSlotView