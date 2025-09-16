---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-08-29 09:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapMap2areaCfg = require("TableCfg/MapMap2areaCfg")
local LSTR = _G.LSTR
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")

---@class FateArchiveMapNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgMap UFImage
---@field TextCompleteRate UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveMapNewItemView = LuaClass(UIView, true)

function FateArchiveMapNewItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Btn = nil
    --self.ImgMap = nil
    --self.TextCompleteRate = nil
    --self.TextName = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveMapNewItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveMapNewItemView:OnInit()
end

function FateArchiveMapNewItemView:OnDestroy()
end

function FateArchiveMapNewItemView:OnShow()
    local Params = self.Params
    if nil == Params then
        return
    end
    local MapItemInfo = Params.Data
    self.MapID = MapItemInfo.ResID
    self.TextCompleteRate:SetText(string.format("%.1f%%", MapItemInfo.Percent))
    local MapCfg = MapMap2areaCfg:FindCfgByKey(MapItemInfo.ResID)
    self.TextName:SetText(MapCfg.MapName)
    --读取图标
    UIUtil.ImageSetBrushFromAssetPath(self.ImgMap, MapCfg.ScreenImage)
end

function FateArchiveMapNewItemView:OnHide()
end

function FateArchiveMapNewItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
end

function FateArchiveMapNewItemView:OnRegisterGameEvent()
end

function FateArchiveMapNewItemView:OnRegisterBinder()
end

function FateArchiveMapNewItemView:OnBtnClicked()
    _G.EventMgr:SendEvent(EventID.FateCloseStatisticsPanel)
    _G.EventMgr:SendEvent(EventID.FateOnMapSelected, self.MapID)
end

return FateArchiveMapNewItemView
