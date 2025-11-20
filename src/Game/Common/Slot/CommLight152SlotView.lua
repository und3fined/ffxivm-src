---
--- Author: v_vvxinchen
--- DateTime: 2025-01-17 17:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")



---@class CommLight152SlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Icon UFImage
---@field ImgBg UFImage
---@field PanelSelect UFCanvasPanel
---@field RedDot CommonRedDotView
---@field RichTextNum URichTextBox
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommLight152SlotView = LuaClass(UIView, true)


function CommLight152SlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Icon = nil
	--self.ImgBg = nil
	--self.PanelSelect = nil
	--self.RedDot = nil
	--self.RichTextNum = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommLight152SlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommLight152SlotView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.Icon)},
		{ "ItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBg)},
		{ "ItemNum",UIBinderSetItemNumFormat.New(self, self.RichTextNum)},
		{ "NumVisible", UIBinderSetIsVisible.New(self, self.RichTextNum)},
		{ "IsMask",UIBinderSetIsVisible.New(self, self.ImgMask)},
		{ "IsSelect", UIBinderValueChangedCallback.New(self, nil, self.OnItemSelectChanged)},
		{ "IsWearable", UIBinderSetIsVisible.New(self, nil, self.ImgWearable)},
	}
end

function CommLight152SlotView:OnDestroy()

end

function CommLight152SlotView:OnShow()
	if nil == self.Params then return end

	self.ViewModel = self.Params.Data
    if nil == self.ViewModel then return end

	_G.FishNotesMgr:SetShowCount()

    if  not string.isnilorempty(self.ViewModel.RedDotName) then
        local RedDotName = self.ViewModel.RedDotName
        self.RedDot:SetRedDotNameByString(RedDotName)
	else
		self.RedDot:SetRedDotNameByString("")
    end
end

function CommLight152SlotView:OnHide()

end

function CommLight152SlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickButtonItem)
end

function CommLight152SlotView:OnClickButtonItem()
    if(self.ClickCallback ~= nil and self.CallbackView ~= nil) then
        self.ClickCallback(self.CallbackView, self)
    else
        local Params = self.Params
        if(Params and Params.Adapter) then
            Params.Adapter:OnItemClicked(self, Params.Index)
        end
    end
end

function CommLight152SlotView:SetClickButtonCallback(TargetView, TargetCallback)
    self.CallbackView = TargetView
    self.ClickCallback = TargetCallback
	UIUtil.SetIsVisible(self.Btn, true, true) 
end

function CommLight152SlotView:OnRegisterGameEvent()

end

function CommLight152SlotView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then return end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)
end


function CommLight152SlotView:OnItemSelectChanged(bSelect) 
	UIUtil.SetIsVisible(self.PanelSelect, bSelect)
	if bSelect then
		self:PlayAnimation(self.AnimSelect)
	end
end

return CommLight152SlotView