---
---@author Carl
---DateTime: 2023-09-15 19:17:13
---Description:幻卡筛选按钮VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local MagicCardLocalDef = require("Game/MagicCard/MagicCardLocalDef")
local CardRaceCfg = require("TableCfg/FantasyCardRaceCfg")
local CardStarCfg = require("TableCfg/FantasyCardStarCfg")



---@class MagicCardFilterItemVM : UIViewModel
---@field IsSelected boolean @是否选中

local FilterBtnType = MagicCardLocalDef.FilterBtnType

local MagicCardFilterItemVM = LuaClass(UIViewModel)

---@param ParentVm
function MagicCardFilterItemVM:Ctor(FilterType, RaceOrStarId, ParentVm)
    self.FilterType = FilterType
    self.ParentVm = ParentVm
    self.RaceOrStarId = RaceOrStarId

    self.ImgAssetPath = ""
    if FilterType == FilterBtnType.Race then
        local RaceCfg = CardRaceCfg:FindCfgByKey(RaceOrStarId)
        if RaceCfg ~= nil then
            self.ImgAssetPath = RaceCfg.RaceImageFilterBtn
        end
    elseif FilterType == FilterBtnType.Star then
		local StarCfg = CardStarCfg:FindCfgByKey(RaceOrStarId)
        if StarCfg ~= nil then
            self.ImgAssetPath = StarCfg.StarImageFilterBtn
        end
    end

    self.IsSelected = false
end

function MagicCardFilterItemVM:OnClicked()
    self.IsSelected = not self.IsSelected
    self.ParentVm:OnFilterBtnClicked(self.FilterType, self.IsSelected, self.RaceOrStarId)
end
return MagicCardFilterItemVM
