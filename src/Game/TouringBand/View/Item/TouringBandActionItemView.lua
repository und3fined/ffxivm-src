---
--- Author: Administrator
--- DateTime: 2025-02-12 10:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local TouringBandCfg = require("TableCfg/TouringBandCfg")
local TouringBandUtil = require("Game/TouringBand/TouringBandUtil")
local EmotionCfg = require("TableCfg/EmotionCfg")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")
local EventID = _G.EventID

---@class TouringBandActionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSkill UFButton
---@field ImgBG UFImage
---@field ImgEmoAct UFImage
---@field PanelCD UFCanvasPanel
---@field RadialImageCD URadialImage
---@field TextCD UFTextBlock
---@field AnimClick UWidgetAnimation
---@field ButtonIndex int64
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandActionItemView = LuaClass(UIView, true)

function TouringBandActionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSkill = nil
	--self.ImgBG = nil
	--self.ImgEmoAct = nil
	--self.PanelCD = nil
	--self.RadialImageCD = nil
	--self.TextCD = nil
	--self.AnimClick = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandActionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandActionItemView:OnInit()

end

function TouringBandActionItemView:OnDestroy()

end

function TouringBandActionItemView:OnShow()

end

function TouringBandActionItemView:OnHide()

end

function TouringBandActionItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSkill, self.OnClickBtnSkill)
end

function TouringBandActionItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.EmotionRefreshItemUI, self.OnGameEventEmotionRefreshItemUI)--刷新情感动作UI
end

function TouringBandActionItemView:OnRegisterBinder()
    self.SkillVM = _G.TouringBandMgr:GetTouringBandActionBtnVM()

    local Binders = {
        { "NormalCDPercent", UIBinderSetPercent.New(self, self.RadialImageCD) },
        { "bNormalCD", UIBinderSetIsVisible.New(self, self.PanelCD) },
        { "SkillCDText", UIBinderSetText.New(self, self.TextCD) },
        { "BandID", UIBinderValueChangedCallback.New(self, nil, self.OnBandIDChang) },
    }

    self:RegisterBinders(self.SkillVM, Binders)
end

function TouringBandActionItemView:OnBandIDChang(NewValue, OldValue)
    local BandCfg = TouringBandCfg:FindCfgByKey(NewValue)
    self.EmotionID = nil
    self.bCanUse = true
    if not BandCfg then
        TouringBandUtil.Err("Error TouringBandActionItemView.OnBandIDChang: BandCfg is nil for ID: " .. tostring(NewValue))
        UIUtil.SetIsVisible(self, false)
        return
    end

    local BtnEmotionIDs = BandCfg.BtnEmotionIDs or {}
    local EmotionID = BtnEmotionIDs[self.ButtonIndex + 1]
    self.EmotionID = EmotionID
    if EmotionID == nil then
        TouringBandUtil.Err("Error TouringBandMgr.PlayAtl: EmotionID is nil for Index: " .. tostring(self.ButtonIndex))
        UIUtil.SetIsVisible(self, false)
        return
    end
    self:OnGameEventEmotionRefreshItemUI()
    UIUtil.SetIsVisible(self, true)

    local EmotionData = EmotionCfg:FindCfgByKey(EmotionID)
    if nil == EmotionData then
        TouringBandUtil.Err("Error TouringBandActionItemView.OnBandIDChang: EmotionData is nil for ID: " .. tostring(EmotionData))
        return
    end

    local IconPath = EmotionData.IconPath
    if nil == IconPath then
        return
    end
    UIUtil.ImageSetBrushFromAssetPath(self.ImgEmoAct, EmotionUtils.GetEmoActIconPath(EmotionData.IconPath))
end

function TouringBandActionItemView:OnClickBtnSkill()
    local BandID = self.SkillVM.BandID
    if BandID <= 0 then
        return
    end
    local EmotionID = self.EmotionID
    if EmotionID == nil then
        return
    end
    if self.SkillVM.IsCD then
        return
    end
    if not self.bCanUse or _G.TouringBandMgr:IsEmotionValidState() ~= true then
        _G.EmotionMgr:ShowCannotUseTips(EmotionID)
        return
    end
    
    if _G.TouringBandMgr:OnPlayAction(EmotionID) then
        self:PlayAnimation(self.AnimClick)
    end
end

function TouringBandActionItemView:OnGameEventEmotionRefreshItemUI()
    local EmotionID = self.EmotionID
    if EmotionID == nil then
        return
    end
    local bEnable = _G.EmotionMgr:IsEnableAtIgnoreActivatedID(EmotionID, true)
    local Color = not bEnable and "#696969FF" or "#FFFFFFFF"
    UIUtil.SetColorAndOpacityHex(self.ImgBG, Color)
    UIUtil.SetColorAndOpacityHex(self.ImgEmoAct, Color)
    self.bCanUse = bEnable
end

return TouringBandActionItemView