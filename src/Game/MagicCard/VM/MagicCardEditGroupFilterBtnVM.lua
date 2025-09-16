---
--- Author: frankjfwang
--- DateTime: 2022-05-15 19:01
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MagicCardLocalDef = require("Game/MagicCard/MagicCardLocalDef")
local CardRaceCfg = require("TableCfg/FantasyCardRaceCfg")
local CardStarCfg = require("TableCfg/FantasyCardStarCfg")

local FilterBtnType = MagicCardLocalDef.FilterBtnType

---@class MagicCardEditGroupFilterBtnVM : UIViewModel
local MagicCardEditGroupFilterBtnVM = LuaClass(UIViewModel)

---@param ParentVm MagicCardGroupEditItemVM
function MagicCardEditGroupFilterBtnVM:Ctor(FilterType, RaceOrStarId, ParentVm, Index)
    self.__FilterType = FilterType
    self.__ParentVm = ParentVm
    self.__RaceOrStarId = RaceOrStarId
    self.__Index = Index
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

function MagicCardEditGroupFilterBtnVM:OnClicked()
    self.IsSelected = not self.IsSelected
    self.__ParentVm:OnFilterBtnClicked(self.__FilterType, self.IsSelected, self.__RaceOrStarId, self.__Index)
end

return MagicCardEditGroupFilterBtnVM
