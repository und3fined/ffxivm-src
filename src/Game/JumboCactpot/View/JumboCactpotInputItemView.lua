---
--- Author: user
--- DateTime: 2023-02-24 16:20
--- Description:仙人仙彩主界面选择号码item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
-- local UIUtil = require("Utils/UIUtil")

---@class JumboCactpotInputItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon_Number UFImage
---@field AnimRollEnd UWidgetAnimation
---@field AnimRollStart UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotInputItemView = LuaClass(UIView, true)

function JumboCactpotInputItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Icon_Number = nil
    --self.AnimRollEnd = nil
    --self.AnimRollStart = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotInputItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotInputItemView:OnInit()
end

function JumboCactpotInputItemView:OnDestroy()
end

function JumboCactpotInputItemView:OnShow()
    self.Number = 0
end

function JumboCactpotInputItemView:OnHide()
end

function JumboCactpotInputItemView:OnRegisterUIEvent()
end

function JumboCactpotInputItemView:OnRegisterGameEvent()
end

function JumboCactpotInputItemView:OnRegisterBinder()
end


function JumboCactpotInputItemView:ResetToDefault()
    self:PlayAnimation(self.AnimRollEnd, 0.05)
end


return JumboCactpotInputItemView
