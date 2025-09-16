---
--- Author: Administrator
--- DateTime: 2025-01-03 18:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
--local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")

---@class ChocoboCodexArmorSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Icon UFImage
---@field ImgMask UFImage
---@field ImgNoOpen UFImage
---@field RedDot CommonRedDot2View
---@field RichTextLevel URichTextBox
---@field RichTextQuantity URichTextBox
---@field SizeIcon UScaleBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboCodexArmorSlotView = LuaClass(UIView, true)

function ChocoboCodexArmorSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Icon = nil
	--self.ImgMask = nil
	--self.ImgNoOpen = nil
	--self.RedDot = nil
	--self.RichTextLevel = nil
	--self.RichTextQuantity = nil
	--self.SizeIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboCodexArmorSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboCodexArmorSlotView:OnInit()
	UIUtil.SetIsVisible(self.RichTextLevel, false) 
end

function ChocoboCodexArmorSlotView:OnDestroy()

end

function ChocoboCodexArmorSlotView:OnShow()
	if nil == self.Params then return end

	self.ViewModel = self.Params.Data
    if nil == self.ViewModel then return end

    if  not string.isnilorempty(self.ViewModel.RedDotName) then
        local RedDotName = self.ViewModel.RedDotName
        self.RedDot:SetRedDotNameByString(RedDotName)
    end
end

function ChocoboCodexArmorSlotView:OnHide()
	self:StopAllAnimations()
end

function ChocoboCodexArmorSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickButtonItem)
    UIUtil.AddOnDoubleClickedEvent(self, self.Btn, self.OnDoubleClickButtonItem)
end

function ChocoboCodexArmorSlotView:OnRegisterGameEvent()

end

function ChocoboCodexArmorSlotView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then return end

    local ViewModel = Params.Data
    if nil == ViewModel or nil == ViewModel.RegisterBinder then
        return
    end

	if (self.Binders == nil) then
        self.Binders = {
			{
                "Icon",
                UIBinderSetBrushFromAssetPath.New(self, self.Icon)
            },
            --[[{
                "ItemColorAndOpacity",
                UIBinderSetColorAndOpacity.New(self, self.Icon)
            },]]
            {
                "ItemColor",
                 UIBinderSetBrushTintColorHex.New(self, self.Icon)
            },
			{
                "Num",
                UIBinderSetText.New(self, self.RichTextQuantity)
            },
			{
                "NumVisible",
                UIBinderSetIsVisible.New(self, self.RichTextQuantity)
            },
            {
                "IsIcon",
                UIBinderSetIsVisible.New(self, self.SizeIcon)
            },
            {
                "IsNoOpen",
                UIBinderSetIsVisible.New(self, self.ImgNoOpen)
            },
			{
                "IsMask",
                UIBinderSetIsVisible.New(self, self.ImgMask)
            },
			{
                "ItemLevelVisible",
                UIBinderSetIsVisible.New(self, self.RichTextLevel)
            },
		}
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function ChocoboCodexArmorSlotView:OnClickButtonItem()
    if(self.ClickCallback ~= nil and self.CallbackView ~= nil) then
        self.ClickCallback(self.CallbackView, self)
    else
        local Params = self.Params
        if(Params and Params.Adapter) then
            Params.Adapter:OnItemClicked(self, Params.Index)
        end
    end
end

-- 有些时候用不到Adapter，就在这里设置吧
function ChocoboCodexArmorSlotView:SetClickButtonCallback(TargetView, TargetCallback)
    self.CallbackView = TargetView
    self.ClickCallback = TargetCallback
end

function ChocoboCodexArmorSlotView:SetCoubleClickButtonCallback(DoubleTargetView, DoubleCallback)
    self.DoubleCallbackView = DoubleTargetView
    self.DoubleClickCallback = DoubleCallback
end

function ChocoboCodexArmorSlotView:OnDoubleClickButtonItem()
	if(self.DoubleClickCallback ~= nil and self.DoubleCallbackView ~= nil) then
        self.DoubleClickCallback(self.CallbackView, self)
	else
		local Params = self.Params
        if(Params and Params.Adapter) then
			Params.Adapter:OnItemDoubleClicked(self, Params.Index)
        end
    end
end

return ChocoboCodexArmorSlotView