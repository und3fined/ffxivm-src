---
--- Author: Administrator
--- DateTime: 2023-12-12 14:45
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local FantasyCardMoreCardHintCfg = require("TableCfg/FantasyCardMoreCardHintCfg")

---@class CardsShowGetWayView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field PanelGetWayTips UFCanvasPanel
---@field TextGetWay UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsShowGetWayView = LuaClass(UIView, true)

function CardsShowGetWayView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.CommonPopUpBG = nil
    -- self.PanelGetWayTips = nil
    -- self.TextGetWay = nil
    -- self.AnimIn = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsShowGetWayView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommonPopUpBG)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsShowGetWayView:OnInit()

end

function CardsShowGetWayView:OnDestroy()

end

function CardsShowGetWayView:OnShow()
    self.CommonPopUpBG.Hide = function()
        UIUtil.SetIsVisible(self.Object, false)
        _G.UIViewMgr:HideView(_G.UIViewID.MagicCardShowGetWayView)
    end
    self.TextGetWay:SetText(_G.LSTR(1130091)) --"幻卡主要获取途径"
    local Params = self.Params
    if nil == Params then
        return
    end
    local InTagetView = Params.InTagetView
    ItemTipsUtil.AdjustTipsPosition(self.PanelGetWayTips, InTagetView, Params.Offset)
    local _data = FantasyCardMoreCardHintCfg:FindCfgByKey(1)
    local _text = string.format("%d、%s", 1, _data.Hints[1])
    for i = 2, #_data.Hints do
        _text = _text .. "\n"
        _text = _text .. string.format("%d、%s", i, _data.Hints[i])
    end

    self.TextSuggest:SetText(_text)
end

function CardsShowGetWayView:OnHide()

end

function CardsShowGetWayView:OnRegisterUIEvent()

end

function CardsShowGetWayView:OnRegisterGameEvent()

end

function CardsShowGetWayView:OnRegisterBinder()

end

return CardsShowGetWayView
