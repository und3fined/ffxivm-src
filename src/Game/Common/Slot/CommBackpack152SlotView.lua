---
--- Author: Administrator
--- DateTime: 2024-08-19 11:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")

---@class CommBackpack152SlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field BtnCheck UFButton
---@field Icon UFImage
---@field IconCheck UFImage
---@field IconChoose UFImage
---@field IconReceived UFImage
---@field ImgCheckBox UFImage
---@field ImgEmpty UFImage
---@field ImgMask UFImage
---@field ImgQuanlity UFImage
---@field ImgSelect UFImage
---@field PanelAvailable UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field RedDot2 CommonRedDot2View
---@field RichTextLevel URichTextBox
---@field RichTextQuantity URichTextBox
---@field AnimLoop UWidgetAnimation
---@field AnimTurn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBackpack152SlotView = LuaClass(UIView, true)

function CommBackpack152SlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.BtnCheck = nil
	--self.Icon = nil
	--self.IconCheck = nil
	--self.IconChoose = nil
	--self.IconReceived = nil
	--self.ImgCheckBox = nil
	--self.ImgEmpty = nil
	--self.ImgMask = nil
	--self.ImgQuanlity = nil
	--self.ImgSelect = nil
	--self.PanelAvailable = nil
	--self.PanelInfo = nil
	--self.RedDot2 = nil
	--self.RichTextLevel = nil
	--self.RichTextQuantity = nil
	--self.AnimLoop = nil
	--self.AnimTurn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBackpack152SlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBackpack152SlotView:OnInit()
    UIUtil.SetIsVisible(self.RichTextLevel, false)
    -- CommRewardItemView 里面需要提前设置下Binders 
    if (self.Binders == nil) then 
        self.Binders = {
            {
                "ItemQualityIcon",
                UIBinderSetBrushFromAssetPath.New(self, self.ImgQuanlity)
            },
            {
                "IsQualityVisible",
                UIBinderSetIsVisible.New(self, self.ImgQuanlity)
            },
            {
                "Icon",
                UIBinderSetBrushFromAssetPath.New(self, self.Icon)
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
                "IsValid",
                UIBinderSetIsVisible.New(self, self.PanelInfo)
            },
            {
                "IsMask",
                UIBinderSetIsVisible.New(self, self.ImgMask)
            },
            {
                "IsSelect",
                UIBinderSetIsVisible.New(self, self.ImgSelect)
            },
            {
                "ItemColorAndOpacity",
                UIBinderSetColorAndOpacity.New(self, self.ImgQuanlity)
            },
            {
                "ItemColorAndOpacity",
                UIBinderSetColorAndOpacity.New(self, self.Icon)
            },
            {
                "ItemLevel",
                UIBinderSetTextFormat.New(self, self.RichTextLevel, "%d级")
            },
            {
                "ItemLevelVisible",
                UIBinderSetIsVisible.New(self, self.RichTextLevel)
            },
            {
                "IconChooseVisible",
                UIBinderSetIsVisible.New(self, self.IconChoose)
            },

            {
                "IconReceivedVisible",
                UIBinderSetIsVisible.New(self, self.IconReceived)
            },
            {
                "IsReward",
                UIBinderSetIsVisible.New(self, self.PanelAvailable)
            },
            {
                "BtnCheckVisible",
                UIBinderSetIsVisible.New(self, self.BtnCheck, nil, true)
            },
            {
                "ImgCheckBoxVisible",
                UIBinderSetIsVisible.New(self, self.ImgCheckBox)
            },
            {
                "IconCheck",
                UIBinderSetBrushFromAssetPath.New(self, self.IconCheck)
            },
        }
    end
end


function CommBackpack152SlotView:AddRemoveBinder(BinderName, AddOrRemove)
    if BinderName == "" or AddOrRemove == nil then
       return
    end
    if AddOrRemove then
        local Owner = false
        local SlotBinders = self.Binders or {}
		for i = 1, #SlotBinders do
			local Binder = SlotBinders[i]
			if Binder ~= nil and Binder[1] == BinderName then
				Owner = true
			end
		end
        if not Owner then
            table.insert(SlotBinders, {BinderName, UIBinderSetIsVisible.New(self, self.RichTextQuantity)})
        end
    else
        local SlotBinders = self.Binders or {}
		for i = #SlotBinders, 1, -1 do
			local Binder = SlotBinders[i]
			if Binder ~= nil and Binder[1] == BinderName then
				table.remove(SlotBinders, i)
			end
		end
    end
end

function CommBackpack152SlotView:OnDestroy()

end

function CommBackpack152SlotView:OnShow()
	if nil == self.Params then return end

	self.ViewModel = self.Params.Data
    if nil == self.ViewModel then return end

    if  not string.isnilorempty(self.ViewModel.RedDotName) then
        local RedDotName = self.ViewModel.RedDotName
        self.RedDot2:SetRedDotNameByString(RedDotName)
    end
end

function CommBackpack152SlotView:OnHide()
	self:StopAllAnimations()
    UIUtil.SetIsVisible(self.PanelAvailable, false)
    UIUtil.SetIsVisible(self.RichTextQuantity, false)
end

function CommBackpack152SlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickButtonItem)
    UIUtil.AddOnDoubleClickedEvent(self, self.Btn, self.OnDoubleClickButtonItem)
end

function CommBackpack152SlotView:OnRegisterGameEvent()

end

function CommBackpack152SlotView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then return end

    local ViewModel = Params.Data
    if nil == ViewModel or nil == ViewModel.RegisterBinder then
        return
    end
    self:RegisterBinders(ViewModel, self.Binders)
end

function CommBackpack152SlotView:OnClickButtonItem()
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
function CommBackpack152SlotView:SetClickButtonCallback(TargetView, TargetCallback)
    self.CallbackView = TargetView
    self.ClickCallback = TargetCallback
end

function CommBackpack152SlotView:SetCoubleClickButtonCallback(DoubleTargetView, DoubleCallback)
    self.DoubleCallbackView = DoubleTargetView
    self.DoubleClickCallback = DoubleCallback
end

function CommBackpack152SlotView:OnDoubleClickButtonItem()
    -- local Params = self.Params
    -- if nil == Params then return end

    -- local Adapter = Params.Adapter
    -- if nil == Adapter then
    --     return
    -- end

	if(self.DoubleClickCallback ~= nil and self.DoubleCallbackView ~= nil) then
        self.DoubleClickCallback(self.CallbackView, self)
	else
		local Params = self.Params
        if(Params and Params.Adapter) then
			Params.Adapter:OnItemDoubleClicked(self, Params.Index)
        end
    end
end

function CommBackpack152SlotView:OnSelectChanged(IsSelected)
    if nil == self.Params then return end

    local ViewModel = self.Params.Data
    if ViewModel and ViewModel.OnSelectedChange then
        ViewModel:OnSelectedChange(IsSelected)
    end
end

function CommBackpack152SlotView:GetViewportPosition()
    local LocalPos = UIUtil.CanvasSlotGetPosition(self.Icon)
    local Pos = UIUtil.LocalToViewport(self.PanelInfo, LocalPos)
    return Pos
end

function CommBackpack152SlotView:SetIconImg(ImgName)
    UIUtil.ImageSetBrushFromAssetPath(self.Icon, ImgName)
end

function CommBackpack152SlotView:SetQualityImg(ImgName)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgQuanlity, ImgName)
end

function CommBackpack152SlotView:SetNum(TargetNum)
    UIUtil.SetIsVisible(self.RichTextQuantity, true)
    self.RichTextQuantity:SetText(tostring(TargetNum))
end

function CommBackpack152SlotView:SetLevelVisible(IsVisible)
    UIUtil.SetIsVisible(self.RichTextLevel, IsVisible)
end

function CommBackpack152SlotView:SetIconChooseVisible(IsVisible)
    UIUtil.SetIsVisible(self.IconChoose, IsVisible)
end


function CommBackpack152SlotView:SetNumVisible(IsVisible)
    UIUtil.SetIsVisible(self.RichTextQuantity, IsVisible)
end
return CommBackpack152SlotView