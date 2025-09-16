---
--- Author: anypkvcai
--- DateTime: 2021-08-17 10:58
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderCanvasSlotSetPosition = require("Binder/UIBinderCanvasSlotSetPosition")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
---@class CommBackpackSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FBtn_Item UFButton
---@field FImg_Icon UFImage
---@field FImg_Mask UFImage
---@field FImg_Quality UFImage
---@field FImg_Select UFImage
---@field PanelInfo UFCanvasPanel
---@field RedDot2 CommonRedDot2View
---@field RichTextNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBackpackSlotView = LuaClass(UIView, true)

function CommBackpackSlotView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.FBtn_Item = nil
    -- self.FImg_Icon = nil
    -- self.FImg_Mask = nil
    -- self.FImg_Quality = nil
    -- self.FImg_Select = nil
    -- self.PanelInfo = nil
    -- self.RichTextNum = nil
    -- self.AnimRollFails = nil
    -- self.AnimRollUpLoop = nil
    -- self.AnimRollWait = nil
    -- self.AnimRollWin = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBackpackSlotView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.RedDot2)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBackpackSlotView:OnInit()
end

function CommBackpackSlotView:SetIconImg(ImgName)
    UIUtil.ImageSetBrushFromAssetPath(self.FImg_Icon, ImgName)
end

function CommBackpackSlotView:SetQualityImg(ImgName)
    UIUtil.ImageSetBrushFromAssetPath(self.FImg_Quality, ImgName)
end

function CommBackpackSlotView:SetNum(TargetNum)
    UIUtil.SetIsVisible(self.RichTextNum, true)
    self.RichTextNum:SetText(tostring(TargetNum))
end

function CommBackpackSlotView:SetNumVisible(IsVisible)
    UIUtil.SetIsVisible(self.RichTextNum, IsVisible)
end

function CommBackpackSlotView:OnDestroy()

end

function CommBackpackSlotView:OnShow()
    if nil == self.Params then return end

	self.ViewModel = self.Params.Data
    if nil == self.ViewModel then return end

    if  not string.isnilorempty(self.ViewModel.RedDotName) then
        local RedDotName = self.ViewModel.RedDotName
        self.RedDot2:SetRedDotNameByString(RedDotName)
    end
end

function CommBackpackSlotView:OnSetParams()
end

function CommBackpackSlotView:OnHide()
    -- 清理动画
    self:StopAllAnimations()
end

function CommBackpackSlotView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.FBtn_Item, self.OnClickButtonItem)
    UIUtil.AddOnDoubleClickedEvent(self, self.FBtn_Item, self.OnDoubleClickButtonItem)
end

function CommBackpackSlotView:OnRegisterGameEvent()

end

function CommBackpackSlotView:OnRegisterTimer()

end

function CommBackpackSlotView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then return end

    local ViewModel = Params.Data
    if nil == ViewModel or nil == ViewModel.RegisterBinder then
        return
    end

    -- binder的 new 挺耗时的，有些地方根本用不到这么多东西，因此，在有ViewModel的时候，再去初始化Binders好了
    if (self.Binders == nil) then
        self.Binders = {
            {
                "ItemQualityIcon",
                UIBinderSetBrushFromAssetPath.New(self, self.FImg_Quality)
            },
            {
                "IsQualityVisible",
                UIBinderSetIsVisible.New(self, self.FImg_Quality)
            },
            {
                "Icon",
                UIBinderSetBrushFromAssetPath.New(self, self.FImg_Icon)
            },
            {
                "Num",
                UIBinderSetText.New(self, self.RichTextNum)
            },
            {
                "NumVisible",
                UIBinderSetIsVisible.New(self, self.RichTextNum)
            },
            {
                "IsValid",
                UIBinderSetIsVisible.New(self, self.PanelInfo)
            },
            {
                "IsMask",
                UIBinderSetIsVisible.New(self, self.FImg_Mask)
            },
            {
                "IsSelect",
                UIBinderSetIsVisible.New(self, self.FImg_Select)
            },
            {
                "ItemColorAndOpacity",
                UIBinderSetColorAndOpacity.New(self, self.FImg_Quality)
            },
            {
                "ItemColorAndOpacity",
                UIBinderSetColorAndOpacity.New(self, self.FImg_Icon)
            }
        }
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

function CommBackpackSlotView:OnClickButtonItem()
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
function CommBackpackSlotView:SetClickButtonCallback(TargetView, TargetCallback)
    self.CallbackView = TargetView
    self.ClickCallback = TargetCallback
end

function CommBackpackSlotView:OnDoubleClickButtonItem()
    local Params = self.Params
    if nil == Params then return end

    local Adapter = Params.Adapter
    if nil == Adapter then
        return
    end

    Adapter:OnItemDoubleClicked(self, Params.Index)
end

function CommBackpackSlotView:OnSelectChanged(IsSelected)
    if nil == self.Params then return end

    local ViewModel = self.Params.Data
    if ViewModel and ViewModel.OnSelectedChange then
        ViewModel:OnSelectedChange(IsSelected)
    end
end

function CommBackpackSlotView:GetViewportPosition()
    local LocalPos = UIUtil.CanvasSlotGetPosition(self.FImg_Icon)
    local Pos = UIUtil.LocalToViewport(self.PanelInfo, LocalPos)
    return Pos
end

return CommBackpackSlotView
