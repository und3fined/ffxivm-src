---
--- Author: Administrator
--- DateTime: 2023-10-23 17:12
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")

---@class CardsNumberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextureDown TextureTextView
---@field TextureDown_Light TextureTextView
---@field TextureLeft TextureTextView
---@field TextureLeft_Light TextureTextView
---@field TextureRight TextureTextView
---@field TextureRight_Light TextureTextView
---@field TextureUp TextureTextView
---@field TextureUp_Light TextureTextView
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsNumberItemView = LuaClass(UIView, true)

function CardsNumberItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.TextDown = nil
    -- self.TextLeft = nil
    -- self.TextRight = nil
    -- self.TextUp = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsNumberItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsNumberItemView:OnInit()
    self.NumTextLightList = {
        [LocalDef.EnumCardNumberDir.Up] = self.TextureUp_Light,
        [LocalDef.EnumCardNumberDir.Down] = self.TextureDown_Light,
        [LocalDef.EnumCardNumberDir.Left] = self.TextureLeft_Light,
        [LocalDef.EnumCardNumberDir.Right] = self.TextureRight_Light,
    }
end

---@param DownValue integer
---@param LeftValue integer
---@param RightValue integer
---@param UpValue integer
function CardsNumberItemView:SetNumbes(UpValue, DownValue, LeftValue, RightValue)
    self.TextureUp:SetText(string.format("%X", UpValue))
    self.TextureUp_Light:SetText(string.format("%X", UpValue))

    self.TextureDown:SetText(string.format("%X", DownValue))
    self.TextureDown_Light:SetText(string.format("%X", DownValue))

    self.TextureLeft:SetText(string.format("%X", LeftValue))
    self.TextureLeft_Light:SetText(string.format("%X", LeftValue))

    self.TextureRight:SetText(string.format("%X", RightValue))
    self.TextureRight_Light:SetText(string.format("%X", RightValue))
end

function CardsNumberItemView:OnDestroy()

end

function CardsNumberItemView:OnShow()

end

function CardsNumberItemView:OnHide()

end

function CardsNumberItemView:OnRegisterUIEvent()

end

function CardsNumberItemView:OnRegisterGameEvent()

end

function CardsNumberItemView:OnRegisterBinder()

end

function CardsNumberItemView:ShowHightlightNumberText(Dir)
    local TextWidget = self.NumTextLightList[Dir]
    if TextWidget == nil then
        return
    end
    UIUtil.SetIsVisible(TextWidget, true)
end

function CardsNumberItemView:HideHightlightNumberText()
    if self.NumTextLightList == nil then
        return
    end
    for _, LightTextWidget in ipairs(self.NumTextLightList) do
        UIUtil.SetIsVisible(LightTextWidget, false)
    end
end

return CardsNumberItemView
