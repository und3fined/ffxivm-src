---
--- Author: MichaelYang_Lightpaw
--- DateTime: 2025-07-17 11:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local FateHighRiskCfg = require("TableCfg/FateHighRiskCfg")
local FateTextCfgTable = require("TableCfg/FateTextCfg")

local LSTR = _G.LSTR
---@class FateStageInfoTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgHighriskBuff UFImage
---@field PanelHighrisk UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field RichTextHighrisk URichTextBox
---@field RichTextHighrisk02 URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateStageInfoTipsView = LuaClass(UIView, true)

function FateStageInfoTipsView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgHighriskBuff = nil
    --self.PanelHighrisk = nil
    --self.PopUpBG = nil
    --self.RichTextHighrisk = nil
    --self.RichTextHighrisk02 = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateStageInfoTipsView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.PopUpBG)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateStageInfoTipsView:OnInit()
end

function FateStageInfoTipsView:OnDestroy()
end

function FateStageInfoTipsView:OnShow()
    if (self.Params == nil) then
        return
    end

    local ItemView = self.Params.ItemView
    if (ItemView) then
        local TargetOffset = self.Params.Offset or {X = -100, Y = 100}
        local CustomBottomMargin = self.Params.CustomBottomMargin or 0
        local bAlwaysRight = true
        ItemTipsUtil.AdjustTipsPosition(self.PanelHighrisk, ItemView, TargetOffset, CustomBottomMargin, bAlwaysRight)
    end

    if (_G.FateMgr.CurrentFate ~= nil) then
        local FateTextCfg = FateTextCfgTable:FindCfgByKey(_G.FateMgr.CurrentFate.ID)
        local HighRiskState = _G.FateMgr.CurrentFate.HighRiskState
        local TableData = FateHighRiskCfg:FindCfgByKey(HighRiskState)
        if (TableData ~= nil) then
            local HighRiskFateTtitle = string.format(LSTR(190139), TableData.ShortTitle)
            self.RichTextHighrisk:SetText(HighRiskFateTtitle)
            self.RichTextHighrisk02:SetText(TableData.Desc)
            UIUtil.ImageSetBrushFromAssetPath(self.ImgHighriskBuff, TableData.TipsIcon)
        else
            self.TargetName = FateTextCfg.NameCh or ""
            _G.FLOG_ERROR("无法找到高危词条表格数据，ID是：%s", HighRiskState)
        end
    end
end

function FateStageInfoTipsView:OnHide()
end

function FateStageInfoTipsView:OnRegisterUIEvent()
end

function FateStageInfoTipsView:OnRegisterGameEvent()
end

function FateStageInfoTipsView:OnRegisterBinder()
end

return FateStageInfoTipsView
