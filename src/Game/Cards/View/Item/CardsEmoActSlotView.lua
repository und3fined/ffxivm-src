---
--- Author: Administrator
--- DateTime: 2023-10-25 23:49
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")
local EmotionCfg = require("TableCfg/EmotionCfg")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class CardsEmoActSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF UFCanvasPanel
---@field ImgBar UFImage
---@field ImgDisable UFImage
---@field ImgIcon UFImage
---@field ImgName UFTextBlock
---@field ImgSelect UFImage
---@field ImgUse UFImage
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsEmoActSlotView = LuaClass(UIView, true)

function CardsEmoActSlotView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.EFF = nil
    -- self.ImgBar = nil
    -- self.ImgDisable = nil
    -- self.ImgIcon = nil
    -- self.ImgName = nil
    -- self.ImgSelect = nil
    -- self.ImgUse = nil
    -- self.AnimIn = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsEmoActSlotView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsEmoActSlotView:OnInit()
    local _binders = {
        {"IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
        {"IsUsed", UIBinderSetIsVisible.New(self, self.ImgUse)},
        {"IsDisabled", UIBinderSetIsVisible.New(self, self.ImgDisable)},
        {"EmotionTableID", UIBinderValueChangedCallback.New(self, nil, self.OnTableIDChanged)}
    }
    self.Binders = _binders
end

function CardsEmoActSlotView:OnTableIDChanged()
    local EmoTableID = self.ViewModel:GetEmoID()
    local EmotionData = EmotionCfg:FindCfgByKey(EmoTableID)
    if (EmotionData == nil) then
        _G.FLOG_ERROR("错误，无法找到情感动作数据，ID是:" .. tostring(EmoTableID))
        return
    end
    UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, self:GetEmoActIconPath(EmotionData))
    self.ImgName:SetText(EmotionData.EmotionName)
end

function CardsEmoActSlotView:OnIsDisabledChanged(IsDisabled)
    --UIUtil.SetIsVisible(self.ImgDisable, IsDisabled)
    if IsDisabled then
        self.ImgIcon:SetRenderOpacity(0.3)
        UIUtil.SetColorAndOpacityHex(self.ImgName, "#828282")
    else
        self.ImgIcon:SetRenderOpacity(1)
        UIUtil.SetColorAndOpacityHex(self.ImgName, "#D5D5D5FF")
    end
end

function CardsEmoActSlotView:OnShow()

end

function CardsEmoActSlotView:GetEmoActIconPath(EmotionData)
    return EmotionUtils.GetEmoActIconPath(EmotionData.IconPath)
end

function CardsEmoActSlotView:OnHide()
end

function CardsEmoActSlotView:OnRegisterUIEvent()
end

function CardsEmoActSlotView:OnRegisterGameEvent()
end

function CardsEmoActSlotView:OnRegisterBinder()
    self.ViewModel = self.Params.Data
    if (self.ViewModel == nil) then
        _G.FLOG_ERROR("ViewModel 为空，请检查")
        return
    end
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return CardsEmoActSlotView
