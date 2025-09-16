---
--- Author: Administrator
--- DateTime: 2024-12-27 16:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local RichTextUtil = require("Utils/RichTextUtil")
local TimeUtil = require("Utils/TimeUtil")

---@class PVPReviveTimeTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextTips URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPReviveTimeTipsView = LuaClass(UIView, true)

function PVPReviveTimeTipsView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.RichTextTips = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPReviveTimeTipsView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPReviveTimeTipsView:OnInit()
    self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(
        self,
        self.RichTextTips,
        nil,
        nil,
        self.TimeOutCallback,
        self.TimeUpdateCallback
    )
end

function PVPReviveTimeTipsView:TimeOutCallback()
    self:Hide()
end

function PVPReviveTimeTipsView:TimeUpdateCallback(InLeftTime)
    local FinalTime = math.ceil(InLeftTime)
    local TimeStr = string.format(self.ReviveSecondStr, FinalTime)
    local TextStr = string.format(self.ReviveStr, TimeStr)
    return TextStr
end

function PVPReviveTimeTipsView:OnDestroy()
end

-- OnShow 在 OnRegisterTimer 后面
function PVPReviveTimeTipsView:OnShow()
    self.ReviveStr = LSTR(460016) --%s后复活并返回队伍
    self.ReviveSecondStr =  RichTextUtil.GetText(LSTR(460018), "#FFF4D0FF", "#B567287A", 2) -- %s秒
    local RespawnEndTimeStamp = self.Params
    self.AdapterCountDownTime:Start(RespawnEndTimeStamp, 1, true, true)
end

function PVPReviveTimeTipsView:OnHide()
end

function PVPReviveTimeTipsView:OnRegisterUIEvent()
end

function PVPReviveTimeTipsView:OnRegisterTimer()
end

function PVPReviveTimeTipsView:OnRegisterGameEvent()
end

function PVPReviveTimeTipsView:OnRegisterBinder()
end

return PVPReviveTimeTipsView
