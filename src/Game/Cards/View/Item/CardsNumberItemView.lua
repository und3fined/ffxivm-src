---
--- Author: Administrator
--- DateTime: 2023-10-23 17:12
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CardsNumberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextDown UFTextBlock
---@field TextLeft UFTextBlock
---@field TextRight UFTextBlock
---@field TextUp UFTextBlock
---@field TextureDown TextureTextView
---@field TextureLeft TextureTextView
---@field TextureRight TextureTextView
---@field TextureUp TextureTextView
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

end

---@param DownValue integer
---@param LeftValue integer
---@param RightValue integer
---@param UpValue integer
function CardsNumberItemView:SetNumbes(UpValue, DownValue, LeftValue, RightValue)
    self.TextureUp:SetText(string.format("%X", UpValue))
    self.TextureDown:SetText(string.format("%X", DownValue))
    self.TextureLeft:SetText(string.format("%X", LeftValue))
    self.TextureRight:SetText(string.format("%X", RightValue))
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

return CardsNumberItemView
