---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-10-23 11:27
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EmotionCfg = require("TableCfg/EmotionCfg")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")

---@class CardsEmoActSettingItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSetting UFButton
---@field ImgCheck UFImage
---@field ImgEmo UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsEmoActSettingItemView = LuaClass(UIView, true)

function CardsEmoActSettingItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnSetting = nil
    -- self.ImgCheck = nil
    -- self.ImgEmo = nil
    -- self.TextName = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsEmoActSettingItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsEmoActSettingItemView:OnInit()
    self:SetEmoID(0)
    self:SetIsSelect(false)
end

function CardsEmoActSettingItemView:OnDestroy()

end

function CardsEmoActSettingItemView:SetName(targetName)
    self.TextName:SetText(targetName)
end

function CardsEmoActSettingItemView:SetIndex(TargetValue)
    self.Index = TargetValue
end

function CardsEmoActSettingItemView:GetEmoID()
    return self.EmoID
end

function CardsEmoActSettingItemView:SetEmoID(TargetID)
    self.EmoID = TargetID
    -- 显示一下图片
    if (self.EmoID > 0) then
        UIUtil.SetIsVisible(self.ImgEmo, true)
        -- 更新一下图片
        local EmotionData = EmotionCfg:FindCfgByKey(self.EmoID)
        if (EmotionData == nil) then
            UIUtil.SetIsVisible(self.ImgEmo, false)
            _G.FLOG_ERROR("错误，无法找到情感动作数据，ID是:" .. self.EmoID)
            return
        end
        UIUtil.SetIsVisible(self.ImgAdd, false)
        UIUtil.ImageSetBrushFromAssetPath(self.ImgEmo, self:GetEmoActIconPath(EmotionData))
    else
        UIUtil.SetIsVisible(self.ImgAdd, true)
        UIUtil.SetIsVisible(self.ImgEmo, false)
    end
end

function CardsEmoActSettingItemView:GetEmoActIconPath(EmotionData)
    return EmotionUtils.GetEmoActIconPath(EmotionData.IconPath)
end

function CardsEmoActSettingItemView:SetIsSelect(TargetIsSelect)
    self.IsSelect = TargetIsSelect
    UIUtil.SetIsVisible(self.ImgCheck, self.IsSelect)
end

function CardsEmoActSettingItemView:SetName(targetName)
    self.TextName:SetText(targetName)
end

function CardsEmoActSettingItemView:OnShow()

end

function CardsEmoActSettingItemView:OnHide()

end

function CardsEmoActSettingItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSetting, self.OnClickBtnSetting)
end

function CardsEmoActSettingItemView:SetClickCallback(CallbackView, ClickCallback)
    self.CallbackView = CallbackView
    self.ClickCallback = ClickCallback
end

function CardsEmoActSettingItemView:OnClickBtnSetting()
    -- 这里回调一下
    if (self.ClickCallback ~= nil) then
        self.ClickCallback(self.CallbackView, self.Index)
    end
end

function CardsEmoActSettingItemView:OnRegisterGameEvent()

end

function CardsEmoActSettingItemView:OnRegisterBinder()

end

return CardsEmoActSettingItemView
