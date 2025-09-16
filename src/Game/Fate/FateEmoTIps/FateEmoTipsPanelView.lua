---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-04-07 10:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ObjectGCType = require("Define/ObjectGCType")

local BPName = "Fate/FateEmoTips/FateEmoTipsItem_UIBP"

---@class FateEmoTipsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CanvasPanel_Main UCanvasPanel
---@field FateEmoTipsItem_UIBP FateEmoTipsItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateEmoTipsPanelView = LuaClass(UIView, true)

function FateEmoTipsPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.CanvasPanel_Main = nil
    --self.FateEmoTipsItem_UIBP = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateEmoTipsPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.FateEmoTipsItem_UIBP)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateEmoTipsPanelView:OnInit()
end

function FateEmoTipsPanelView:OnDestroy()
end

function FateEmoTipsPanelView:OnShow()
    self.PlayingCount = 0
    self.TipsList = {}
end

function FateEmoTipsPanelView:OnHide()
    self.PlayingCount = 0
    self.TipsList = {}
end

function FateEmoTipsPanelView:OnEmoTipsHide(InEntityID, InView)
    self.PlayingCount = self.PlayingCount - 1
    UIUtil.SetIsVisible(InView, false, false)
end

function FateEmoTipsPanelView:OnRegisterUIEvent()
end

function FateEmoTipsPanelView:OnRegisterGameEvent()
end

function FateEmoTipsPanelView:OnRegisterBinder()
end

function FateEmoTipsPanelView:AppendNewEmoTips(InParams)
    if (InParams == nil) then
        _G.FLOG_ERROR("传入的参数为空，请检查")
        return
    end

    if (InParams.EntityID == nil or InParams.EntityID <= 0) then
        _G.FLOG_ERROR("FateEmoTipsPanelView:AppendNewEmo 出错，传入的 EntityID 无效，请检查")
        return
    end

    if (InParams.EmotionID == nil or InParams.EmotionID <= 0) then
        _G.FLOG_ERROR("FateEmoTipsPanelView:AppendNewEmo 出错，传入的 EmotionID 无效，请检查")
        return
    end

    local Index = self.PlayingCount + 1
    local TargetView = self.TipsList[Index]
    
    if (TargetView == nil) then
        TargetView = _G.UIViewMgr:CreateViewByName(BPName, ObjectGCType.LRU, self, true, true)
        self.CanvasPanel_Main:AddChildToCanvas(TargetView)
    end

    if (TargetView == nil) then
        _G.FLOG_ERROR("FateEmoTipsPanelView:AppendNewEmo 出错，无法获取 EmoTips")
        return
    end
    self.TipsList[Index] = TargetView
    UIUtil.SetIsVisible(TargetView, true, false)
    TargetView:UpdateInfo(InParams, self, self.OnEmoTipsHide)
    self.PlayingCount = self.PlayingCount + 1
end

return FateEmoTipsPanelView
