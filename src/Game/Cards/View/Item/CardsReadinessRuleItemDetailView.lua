---
--- Author: Administrator
--- DateTime: 2023-11-10 16:45
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class CardsReadinessRuleItemDetailView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextContent UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsReadinessRuleItemDetailView = LuaClass(UIView, true)

function CardsReadinessRuleItemDetailView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.TextRuleContent = nil
    -- self.TextRuleTitle = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsReadinessRuleItemDetailView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsReadinessRuleItemDetailView:OnInit()
end

function CardsReadinessRuleItemDetailView:OnDestroy()

end

function CardsReadinessRuleItemDetailView:OnShow()
    --- ViewModel 是一个 CardsRuleDetaiItemVM ,包含的是
    ---            Title = TitleValue,
    ---            Content = ContentValue
    self.ViewModel = self.Params.Data
    if (self.ViewModel.Title == _G.LSTR(LocalDef.UKeyConfig.None)) then
        -- 这里设置一下颜色，无的颜色
        if(self.ViewModel.NoRuleTitleColor ~= nil) then
            local _color = self.ViewModel.NoRuleTitleColor
            UIUtil.SetColorAndOpacity(self.TextTitle, _color.R, _color.G, _color.B, _color.A)
        else
            UIUtil.SetColorAndOpacity(self.TextTitle, 0.783, 0.783, 0.783, 1)
        end
    else
        -- 这里设置一下颜色，有的颜色
        if(self.ViewModel.NormalRuleTitleColor ~= nil) then
            local _color = self.ViewModel.NormalRuleTitleColor
            UIUtil.SetColorAndOpacity(self.TextTitle, _color.R, _color.G, _color.B, _color.A)
        else
            UIUtil.SetColorAndOpacity(self.TextTitle, 0.738, 0.289, 0.11 ,1)
        end
    end
    self.TextTitle:SetText(self.ViewModel.Title)
    if (self.ViewModel.Content == nil or self.ViewModel.Content == "") then
        UIUtil.SetIsVisible(self.TextContent, false)
    else
        UIUtil.SetIsVisible(self.TextContent, true)
        self.TextContent:SetText(self.ViewModel.Content)
    end
end

function CardsReadinessRuleItemDetailView:OnHide()

end

function CardsReadinessRuleItemDetailView:OnRegisterUIEvent()

end

function CardsReadinessRuleItemDetailView:OnRegisterGameEvent()

end

function CardsReadinessRuleItemDetailView:OnRegisterBinder()
end

return CardsReadinessRuleItemDetailView
