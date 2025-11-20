---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-05-29
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class OpsHalloweenScratchCardTabVM : UIViewModel
local OpsHalloweenScratchCardTabVM = LuaClass(UIViewModel)

function OpsHalloweenScratchCardTabVM:Ctor()
    self.PhaseTitleText = ""
    self.ContentText = ""
    self.ProgressText = "0/1"
    self.ItemID = 0
    self.bSelected = false
    self.bShowPhaseDate = true
    self.Icon = ""
    self.Index = 0
    self.IconReceivedVisible = false
    self.bGetBigPrize = false -- 抽中大奖
end

function OpsHalloweenScratchCardTabVM:UpdateVM(InData, InParams)
    if (InData == nil) then
        _G.FLOG_ERROR("OpsHalloweenScratchCardTabVM:UpdateVM 错误，传入的 InData 为空, 请检查")
        return
    end

    self.ItemID = InData.BigPrizeItemID
    self.Icon = UIUtil.GetItemIconPath(self.ItemID)
    self.PhaseTitleText = InData.TitleText
    self.bSelected = InData.bSelected or false
    self.Index = InData.Index
    self.IconReceivedVisible = InData.bGetBigPrize or false
    self.PhaseDataText = InData.ActivityCfg.StartTime
    self.bShowPhaseDate = not InData.bActivityOpen
    self.ItemQualityIcon = ItemUtil.GetItemColorIcon(self.ItemID)
end

function OpsHalloweenScratchCardTabVM:IsEqualVM(InData)
    return false
end

return OpsHalloweenScratchCardTabVM
