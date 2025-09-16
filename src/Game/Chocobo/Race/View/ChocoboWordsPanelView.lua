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

---@class ChocoboWordsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSkip UFButton
---@field ImgArmy01 UFImage
---@field ImgArmy02 UFImage
---@field ImgArmy03 UFImage
---@field ImgIcon UFImage
---@field Panel01 UFCanvasPanel
---@field Panel02 UFCanvasPanel
---@field Panel03 UFCanvasPanel
---@field PanelPlaceName UFCanvasPanel
---@field PanelRace UFCanvasPanel
---@field PanelSkip UFCanvasPanel
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
	--self.BtnSkip = nil
	--self.ImgArmy01 = nil
	--self.ImgArmy02 = nil
	--self.ImgArmy03 = nil
	--self.ImgIcon = nil
	--self.Panel01 = nil
	--self.Panel02 = nil
	--self.Panel03 = nil
	--self.PanelPlaceName = nil
	--self.PanelRace = nil
	--self.PanelSkip = nil
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
end

function ChocoboWordsPanelView:OnDestroy()

end

function ChocoboWordsPanelView:OnShow()
    ChocoboRaceMainVM:UpdateWordsPanelVM()
    self:PlayAnimation(self.AnimRace)
    UIUtil.SetIsVisible(self.PanelSkip, false)
end

function ChocoboWordsPanelView:OnHide()
end

function ChocoboWordsPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSkip, self.OnClickBtnSkip)
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

function ChocoboWordsPanelView:OnTouchStarted(MyGeometry, MouseEvent)
    UIUtil.SetIsVisible(self.PanelSkip, true)

    return _G.UE.UWidgetBlueprintLibrary.CaptureMouse(_G.UE.UWidgetBlueprintLibrary.Handled(), self)
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