---
--- Author: v_vvxinchen
--- DateTime: 2023-12-08 15:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetFormatTextValueWithCurve = require("Binder/UIBinderSetFormatTextValueWithCurve")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local VM = _G.GatheringJobSkillPanelVM

---@class GatheringCollectionPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field GatherItemIcon UFImage
---@field GatherItemQuality UFImage
---@field ImgBlue UFImage
---@field ImgGreen UFImage
---@field ImgItemIcon UFImage
---@field ImgQualityBlueLight UFImage
---@field ImgQualityGreenLight UFImage
---@field ImgQualityYellowLight UFImage
---@field ImgYellow UFImage
---@field PanelBlue UFCanvasPanel
---@field PanelGreen UFCanvasPanel
---@field PanelProBarIcon UFCanvasPanel
---@field PanelQualityBlue UFCanvasPanel
---@field PanelQualityGreen UFCanvasPanel
---@field PanelQualityYellow UFCanvasPanel
---@field PanelYellow UFCanvasPanel
---@field ProBarGreen URadialImage
---@field ProBarOrange URadialImage
---@field ProBarYellow URadialImage
---@field RichTextValueNumber URichTextBox
---@field RichTextValueNumber_2 URichTextBox
---@field TextBigTitle UFTextBlock
---@field TextBlue UFTextBlock
---@field TextGreen UFTextBlock
---@field TextItemName URichTextBox
---@field TextMaxNumber UFTextBlock
---@field TextSmallTitle UFTextBlock
---@field TextValueNumber UFTextBlock
---@field TextYellow UFTextBlock
---@field contant URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimQualityBlue UWidgetAnimation
---@field AnimQualityGreen UWidgetAnimation
---@field AnimQualityYellow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringCollectionPanelView = LuaClass(UIView, true)

function GatheringCollectionPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.CloseBtn = nil
    --self.GatherItemIcon = nil
    --self.GatherItemQuality = nil
    --self.ImgBlue = nil
    --self.ImgGreen = nil
    --self.ImgItemIcon = nil
    --self.ImgQualityBlueLight = nil
    --self.ImgQualityGreenLight = nil
    --self.ImgQualityYellowLight = nil
    --self.ImgYellow = nil
    --self.PanelBlue = nil
    --self.PanelGreen = nil
    --self.PanelProBarIcon = nil
    --self.PanelQualityBlue = nil
    --self.PanelQualityGreen = nil
    --self.PanelQualityYellow = nil
    --self.PanelYellow = nil
    --self.ProBarGreen = nil
    --self.ProBarOrange = nil
    --self.ProBarYellow = nil
    --self.RichTextValueNumber = nil
    --self.RichTextValueNumber_2 = nil
    --self.TextBigTitle = nil
    --self.TextBlue = nil
    --self.TextGreen = nil
    --self.TextItemName = nil
    --self.TextMaxNumber = nil
    --self.TextSmallTitle = nil
    --self.TextValueNumber = nil
    --self.TextYellow = nil
    --self.contant = nil
    --self.AnimIn = nil
    --self.AnimOut = nil
    --self.AnimQualityBlue = nil
    --self.AnimQualityGreen = nil
    --self.AnimQualityYellow = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringCollectionPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CloseBtn)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringCollectionPanelView:OnInit()
    self.Anims = {
        [3] = self.AnimQualityGreen,
        [2] = self.AnimQualityYellow,
        [1] = self.AnimQualityBlue
    }
    self.Binders = {
        --标题
        {"TextBigTitle", UIBinderSetText.New(self, self.TextBigTitle)},
        --head相关  只品质框品质色
        {"GatherIcon", UIBinderSetBrushFromAssetPath.New(self, self.GatherItemIcon)},
        {"QualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.GatherItemQuality)},
        {"GatherName", UIBinderSetText.New(self, self.TextItemName)},
        {"CurrentVal", UIBinderSetText.New(self, self.TextValueNumber)},
        --圆形进度条 回调中view去处理，暂时没绑定
        {"RadialPercentYellow", UIBinderSetPercent.New(self, self.ProBarYellow)},
        --预测环
        {"RadialPercentRed", UIBinderSetPercent.New(self, self.ProBarOrange)},
        --最大环
        {"RadialPercentGreen", UIBinderSetPercent.New(self, self.ProBarGreen)}, --当前环
        --环中间最大值，读db
        {"CollectionValueMax", UIBinderSetText.New(self, self.TextMaxNumber)},
        --环中间显示的收藏价值（长按显示预测值，否则显示当前值）**
        {
            "CollectionVal",
            UIBinderSetFormatTextValueWithCurve.New(self, self.RichTextValueNumber, nil, 0.1, nil, "%d", 0, true)
        },
        {"CollectionValColor", UIBinderSetColorAndOpacity.New(self, self.RichTextValueNumber)},
        {
            "CollectionRedVal",
            UIBinderSetFormatTextValueWithCurve.New(self, self.RichTextValueNumber_2, nil, 0.1, nil, "%d", 0, true)
        },
        {"CollectionRedValColor", UIBinderSetColorAndOpacity.New(self, self.RichTextValueNumber_2)},
        {"CollectionRedValVisible", UIBinderSetIsVisible.New(self, self.RichTextValueNumber_2)},
        {"CollectionRedValVisible", UIBinderSetIsVisible.New(self, self.contant)},
        --档位信息**
        {"TextBlue", UIBinderSetText.New(self, self.TextBlue)},
        {"TextYellow", UIBinderSetText.New(self, self.TextYellow)},
        {"TextGreen", UIBinderSetText.New(self, self.TextGreen)},
        --挡位图标
        {"TextBlue", UIBinderValueChangedCallback.New(self, nil, self.SetImgBlue)},
        --预测环
        {"TextYellow", UIBinderValueChangedCallback.New(self, nil, self.SetImgYellow)},
        --最大环
        {"TextGreen", UIBinderValueChangedCallback.New(self, nil, self.SetImgGreen)}, --当前环
        --挡位动效亮
        {"CurrentVal", UIBinderValueChangedCallback.New(self, nil, self.SetColorAnim)}
    }
end

local State = 1
local To = 0
function GatheringCollectionPanelView:SetColorAnim()
    --当一直是最大值时，也不会变化，不会调用这个方法
    if not VM.CurrentVal or type(VM.CurrentVal) ~= "number" then
        FLOG_ERROR("GatheringCollectionPanelView: VM.CurrentVal is nil or is not number")
        return
    end
    if VM.CurrentVal <= 0 then
        State = 1
        UIUtil.SetRenderOpacity(self.ImgQualityGreenLight, 0)
        UIUtil.SetRenderOpacity(self.ImgQualityYellowLight, 0)
        UIUtil.SetRenderOpacity(self.ImgQualityBlueLight, 0)
        return
    end
    
    if not string.isnilorempty(VM.TextGreen) and VM.CurrentVal >= tonumber(VM.TextGreen) then
        To = 3
    elseif VM.CurrentVal >= VM.ValYellow then
        To = 2
    elseif VM.CurrentVal >= VM.ValBlue then
        To = 1
    end
    for index = State, To do
        self:RegisterTimer(
            function()
                self:PlayAnimation(self.Anims[index])
            end,
            0.2 * (To - State)
        )
    end
    State = To + 1
end

function GatheringCollectionPanelView:SetImgBlue()
    if VM.ValBlue and not string.isnilorempty(VM.TextGreen) then
        local percent = VM.ValBlue / tonumber(VM.TextGreen)
        self:SetIconAngleandPosition(percent, self.PanelQualityBlue)
    else
        FLOG_ERROR("GatheringCollectionPanelView: VM.ValBlue or VM.TextGreen is nil")
    end
end

function GatheringCollectionPanelView:SetImgYellow()
    if VM.ValYellow and not string.isnilorempty(VM.TextGreen) then
        local percent = VM.ValYellow / tonumber(VM.TextGreen)
        self:SetIconAngleandPosition(percent, self.PanelQualityYellow)
    else
        FLOG_ERROR("GatheringCollectionPanelView: VM.ValYellow or VM.TextGreen is nil")
    end
end

function GatheringCollectionPanelView:SetImgGreen()
    self:SetIconAngleandPosition(1, self.PanelQualityGreen)
end

function GatheringCollectionPanelView:SetIconAngleandPosition(percent, Slot, SlotView)
    local Angle = percent * 360
    if percent >= 0.5 then
        Slot:SetRenderTransformAngle(Angle - 360)
    else
        Slot:SetRenderTransformAngle(Angle)
    end
    -- local X, Y = self:CalculateOvalXY(Angle)
    -- local SlotViewSize = UIUtil.CanvasSlotGetSize(SlotView)
    -- X = X - SlotViewSize.X / 2
    -- if Y > 0 then
    --     Y = Y - SlotViewSize.Y
    -- end
    -- local pos = _G.UE.FVector2D(X, Y)
    -- UIUtil.CanvasSlotSetPosition(SlotView, pos)
end

--根据椭圆的参数方程计算XY坐标
--x=rsinθ
--y=rcosθ
--θ = [0,360] 从y轴正向开始
function GatheringCollectionPanelView:CalculateOvalXY(InAngle)
    local SlotViewSize = UIUtil.CanvasSlotGetSize(self.PanelProBarIcon)
    local R = SlotViewSize.X / 2
    local Value = _G.math.rad(InAngle)
    local X = R * _G.math.sin(Value)
    local Y = R * _G.math.cos(Value)
    return X, -Y
end

function GatheringCollectionPanelView:OnDestroy()
end

function GatheringCollectionPanelView:OnShow()
 
end

function GatheringCollectionPanelView:OnHide()
end

function GatheringCollectionPanelView:OnRegisterUIEvent()
end

function GatheringCollectionPanelView:OnRegisterGameEvent()
end

function GatheringCollectionPanelView:OnRegisterBinder()
    self:RegisterBinders(VM, self.Binders)
end

return GatheringCollectionPanelView
