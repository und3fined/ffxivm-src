---
--- Author: Administrator
--- DateTime: 2024-09-12 11:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")

---@class FateArchiveMergerPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FateArchiveMain FateArchiveNewMainView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveMergerPanelView = LuaClass(UIView, true)

function FateArchiveMergerPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.FateArchiveMain = nil
    --self.AnimIn = nil
    --self.AnimOut = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveMergerPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY

    self:AddSubView(self.FateArchiveMain)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveMergerPanelView:OnInit()
end

function FateArchiveMergerPanelView:OnDestroy()
end

function FateArchiveMergerPanelView:OnShow()
    UIUtil.SetIsVisible(self.FateArchiveMain, true)
    self.FateArchiveMain:PlayAnimation(self.FateArchiveMain.AnimIn)
end

function FateArchiveMergerPanelView:OnHide()
    local b = 0
end

function FateArchiveMergerPanelView:OnRegisterUIEvent()
end

function FateArchiveMergerPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.FateOpenStatisticsPanel, self.OnFateOpenStatisticsPanel)
    self:RegisterGameEvent(EventID.FateCloseStatisticsPanel, self.OnFateCloseStatisticsPanel)
end

function FateArchiveMergerPanelView:OnFateOpenStatisticsPanel()
    -- 打开了统计界面
    UIViewMgr:ShowView(UIViewID.FateEventStatisticsPanel)
end

function FateArchiveMergerPanelView:OnFateCloseStatisticsPanel()
    -- 关闭了统计界面，播放动画
    UIViewMgr:HideView(UIViewID.FateEventStatisticsPanel)
end

function FateArchiveMergerPanelView:OnRegisterBinder()
end

return FateArchiveMergerPanelView
