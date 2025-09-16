---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-09-27 14:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SidebarCardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CardsReward CardsRewardItemView
---@field CommonRedDot2 CommonRedDot2View
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SidebarCardItemView = LuaClass(UIView, true)

function SidebarCardItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.CardsReward = nil
    --self.CommonRedDot2 = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidebarCardItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CardsReward)
    self:AddSubView(self.CommonRedDot2)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidebarCardItemView:OnInit()
end

function SidebarCardItemView:OnDestroy()
end

function SidebarCardItemView:OnShow()
end

function SidebarCardItemView:OnHide()
end

function SidebarCardItemView:OnRegisterUIEvent()
end

function SidebarCardItemView:OnRegisterGameEvent()
end

function SidebarCardItemView:OnRegisterBinder()
end

function SidebarCardItemView:RefreshCardInfo(InCardID)
    self.CardsReward:OnCardIDChanged(InCardID, 0)
    UIUtil.SetIsVisible(self.CardsReward.TextCardName, false)
    UIUtil.SetIsVisible(self.CommonRedDot2.PanelRedDot, true, false)
end

return SidebarCardItemView
