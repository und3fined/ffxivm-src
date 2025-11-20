---
--- Author: Administrator
--- DateTime: 2023-11-01 09:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ChocoboRaceMainVM = nil
local ProtoRes = require("Protocol/ProtoRes")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local LocalizationUtil = require("Utils/LocalizationUtil")

---@class ChocoboWordsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgArmy01 UFImage
---@field ImgArmy02 UFImage
---@field ImgArmy03 UFImage
---@field ImgIcon UFImage
---@field ImgMapPlaceName01 UFImage
---@field ImgMapPlaceName02 UFImage
---@field ImgMapPlaceName03 UFImage
---@field ImgWords01 UFImage
---@field ImgWords02 UFImage
---@field Panel01 UFCanvasPanel
---@field Panel02 UFCanvasPanel
---@field Panel03 UFCanvasPanel
---@field PanelPlaceName UFCanvasPanel
---@field PanelRace UFCanvasPanel
---@field TextMapName UFTextBlock
---@field TextPlace UFTextBlock
---@field AnimPlaceName1 UWidgetAnimation
---@field AnimPlaceName2 UWidgetAnimation
---@field AnimPlaceName3 UWidgetAnimation
---@field AnimRace UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboWordsPanelView = LuaClass(UIView, true)

function ChocoboWordsPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgArmy01 = nil
	--self.ImgArmy02 = nil
	--self.ImgArmy03 = nil
	--self.ImgIcon = nil
	--self.ImgMapPlaceName01 = nil
	--self.ImgMapPlaceName02 = nil
	--self.ImgMapPlaceName03 = nil
	--self.ImgWords01 = nil
	--self.ImgWords02 = nil
	--self.Panel01 = nil
	--self.Panel02 = nil
	--self.Panel03 = nil
	--self.PanelPlaceName = nil
	--self.PanelRace = nil
	--self.TextMapName = nil
	--self.TextPlace = nil
	--self.AnimPlaceName1 = nil
	--self.AnimPlaceName2 = nil
	--self.AnimPlaceName3 = nil
	--self.AnimRace = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboWordsPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboWordsPanelView:OnInit()
    ChocoboRaceMainVM = _G.ChocoboRaceMainVM
    local DefaultPath = "Texture2D'/Game/UI/Texture/Localized/CHS/UI_Chocobo_Img_BigWords01.UI_Chocobo_Img_BigWords01'"
    local LocalIconPath = LocalizationUtil.GetLocalizedAssetPath(DefaultPath)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgWords01, LocalIconPath)

    DefaultPath = "Texture2D'/Game/UI/Texture/Localized/CHS/UI_Chocobo_Img_BigWords02.UI_Chocobo_Img_BigWords02'"
    LocalIconPath = LocalizationUtil.GetLocalizedAssetPath(DefaultPath)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgWords02, LocalIconPath)
    
    DefaultPath = "Texture2D'/Game/UI/Texture/Localized/CHS/UI_Chocobo_Img_Words_MapStyle03_Name.UI_Chocobo_Img_Words_MapStyle03_Name'"
    LocalIconPath = LocalizationUtil.GetLocalizedAssetPath(DefaultPath)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgMapPlaceName03, LocalIconPath)
    
    DefaultPath = "Texture2D'/Game/UI/Texture/Localized/CHS/UI_Chocobo_Img_Words_MapStyle01_Name.UI_Chocobo_Img_Words_MapStyle01_Name'"
    LocalIconPath = LocalizationUtil.GetLocalizedAssetPath(DefaultPath)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgMapPlaceName01, LocalIconPath)
    
    DefaultPath = "Texture2D'/Game/UI/Texture/Localized/CHS/UI_Chocobo_Img_Words_MapStyle02_Name.UI_Chocobo_Img_Words_MapStyle02_Name'"
    LocalIconPath = LocalizationUtil.GetLocalizedAssetPath(DefaultPath)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgMapPlaceName02, LocalIconPath)
end

function ChocoboWordsPanelView:OnDestroy()

end

function ChocoboWordsPanelView:OnShow()
    ChocoboRaceMainVM:UpdateWordsPanelVM()
    self:PlayAnimation(self.AnimRace)
end

function ChocoboWordsPanelView:OnHide()
end

function ChocoboWordsPanelView:OnRegisterUIEvent()
end

function ChocoboWordsPanelView:OnRegisterGameEvent()

end

function ChocoboWordsPanelView:OnRegisterBinder()
    local Binders = {
        { "MapName", UIBinderSetText.New(self, self.TextPlace) },
        { "MapLevelName", UIBinderSetText.New(self, self.TextMapName) },
        { "IsShowPanelRace", UIBinderSetIsVisible.New(self, self.PanelRace) },
        { "IsShowPanelPlaceName", UIBinderSetIsVisible.New(self, self.PanelPlaceName) },
    }
    self:RegisterBinders(ChocoboRaceMainVM, Binders)
end

function ChocoboWordsPanelView:OnClickBtnSkip()
    _G.StoryMgr:StopSequence()
end

function ChocoboWordsPanelView:OnAnimationFinished(Anim)
    if Anim == self.AnimRace then
        ChocoboRaceMainVM.IsShowPanelPlaceName = true
        local GlobalCfgValue = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_CHOCOBO_RACE_MAP_ID_RANGE, "Value") --1055
        local ChocoboRaceMapResIDMin = GlobalCfgValue and GlobalCfgValue[1] or 0
        local SubNum = 0
        local BaseInfo = _G.PWorldMgr.BaseInfo
        if BaseInfo ~= nil then
            SubNum =  BaseInfo.CurrPWorldResID - ChocoboRaceMapResIDMin
        end

        if SubNum == 0 then
            self:PlayAnimation(self.AnimPlaceName3)
        elseif SubNum == 1 then
            self:PlayAnimation(self.AnimPlaceName1)
        elseif SubNum == 2 then
            self:PlayAnimation(self.AnimPlaceName2)
        end
    end
end

return ChocoboWordsPanelView