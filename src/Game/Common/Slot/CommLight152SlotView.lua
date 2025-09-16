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
local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE

---@class CommLight152SlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Icon UFImage
---@field ImgBg UFImage
---@field ImgSelect UFImage
---@field PanelShowSelect UFCanvasPanel
---@field RedDot CommonRedDotView
---@field RichTextNum URichTextBox
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommLight152SlotView = LuaClass(UIView, true)

CommLight152SlotView.ItemColorType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/Ui_Img_LightSlot_NQ_Grey_152px_png.Ui_Img_LightSlot_NQ_Grey_152px_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/Ui_Img_LightSlot_NQ_Green_152px_png.Ui_Img_LightSlot_NQ_Green_152px_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/Ui_Img_LightSlot_NQ_Blue_152px_png.Ui_Img_LightSlot_NQ_Blue_152px_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/Ui_Img_LightSlot_NQ_Purple_152px_png.Ui_Img_LightSlot_NQ_Purple_152px_png'",
}

CommLight152SlotView.ItemHQColorType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/Ui_Img_LightSlot_HQ_Grey_152px_png.Ui_Img_LightSlot_HQ_Grey_152px_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/Ui_Img_LightSlot_HQ_Green_152px_png.Ui_Img_LightSlot_HQ_Green_152px_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/Ui_Img_LightSlot_HQ_Blue_152px_png.Ui_Img_LightSlot_HQ_Blue_152px_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/Ui_Img_LightSlot_HQ_Purple_152px_png.Ui_Img_LightSlot_HQ_Purple_152px_png'",
}

function CommLight152SlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Icon = nil
	--self.ImgBg = nil
	--self.ImgSelect = nil
	--self.PanelShowSelect = nil
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
		{ "NumVisible", UIBinderSetIsVisible.New(self, self.RichTextNum)},
		{ "ItemData", UIBinderValueChangedCallback.New(self, nil, self.OnItemDataChanged) },
		{ "IsSelect", UIBinderValueChangedCallback.New(self, nil, self.OnItemSelectChanged)},
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

function CommLight152SlotView:OnItemDataChanged(ItemData)
	if ItemData ~= nil then
		local IsHQ = (1 == ItemData.IsHQ)
		local ColorType = IsHQ and self.ItemHQColorType or self.ItemColorType
		UIUtil.ImageSetBrushFromAssetPath(self.ImgBg, ColorType[ItemData.ItemColor])
	end
end

function CommLight152SlotView:OnItemSelectChanged(bSelect)
	if bSelect then
		self:PlayAnimToEnd(self.AnimSelect)
		self.IsPlayed = true
	else
		-- UnSelect动画反复执行导致创建大量Anim对象：UnSelect动画只对播过动画（处于选中态）的进行处理
		if self.IsPlayed then
			self:PlayAnimationTimeRange(self.AnimSelect, 0, 0.01, 1, nil, 1.0, false)
		end
	end
end

return CommLight152SlotView