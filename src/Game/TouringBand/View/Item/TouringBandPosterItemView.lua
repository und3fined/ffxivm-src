---
--- Author: Administrator
--- DateTime: 2024-07-08 15:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local AudioUtil = require("Utils/AudioUtil")
local UIBinderSetMaterialTextureFromAssetPath = require("Binder/UIBinderSetMaterialTextureFromAssetPath")

---@class TouringBandPosterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconFansLogo UFImage
---@field ImgLine UFImage
---@field ImgMain UFImage
---@field ImgMask UFImage
---@field MI_DX_Common_InfoTips_TouringBand_1 UFImage
---@field M_DX_TouringBand_1 UFImage
---@field PanelFansLogo UFCanvasPanel
---@field PanelTag UFCanvasPanel
---@field PanelText UFCanvasPanel
---@field TextContent UFTextBlock
---@field TextTag UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimBandFanWin UWidgetAnimation
---@field AnimIn_1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandPosterItemView = LuaClass(UIView, true)

function TouringBandPosterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconFansLogo = nil
	--self.ImgLine = nil
	--self.ImgMain = nil
	--self.ImgMask = nil
	--self.MI_DX_Common_InfoTips_TouringBand_1 = nil
	--self.M_DX_TouringBand_1 = nil
	--self.PanelFansLogo = nil
	--self.PanelTag = nil
	--self.PanelText = nil
	--self.TextContent = nil
	--self.TextTag = nil
	--self.TextTitle = nil
	--self.AnimBandFanWin = nil
	--self.AnimIn_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandPosterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandPosterItemView:OnInit()
    
end

function TouringBandPosterItemView:OnDestroy()

end

function TouringBandPosterItemView:OnShow()

end

function TouringBandPosterItemView:OnHide()

end

function TouringBandPosterItemView:OnRegisterUIEvent()

end

function TouringBandPosterItemView:OnRegisterGameEvent()

end

function TouringBandPosterItemView:OnRegisterBinder()
    self.VM = _G.TouringBandMgr:GetPosterVM()
    local Binders = {
        { "IsFans", UIBinderSetIsVisible.New(self, self.PanelFansLogo) },
        { "IsShowLine", UIBinderSetIsVisible.New(self, self.ImgLine) },
        { "IsShowTag", UIBinderSetIsVisible.New(self, self.PanelTag) },
        { "IsShowMask", UIBinderSetIsVisible.New(self, self.ImgMask) },
        { "TextTag", UIBinderSetText.New(self, self.TextTag)},
        { "TextTitle", UIBinderSetText.New(self, self.TextTitle)},
        { "TextContent", UIBinderSetText.New(self, self.TextContent)},
        { "TexturePath", 	UIBinderSetMaterialTextureFromAssetPath.New(self, self.ImgMain, "Texture") },
    }
    self:RegisterBinders(self.VM, Binders)
end

function TouringBandPosterItemView:PlayPosterAnim()
    self:PlayAnimation(self.AnimBandFanWin)
    self:RegisterTimer(self.AnimBandFanWinSound, 0.57)
end

function TouringBandPosterItemView:PlayPosterIn()
    self:PlayAnimation(self.AnimIn_1)
end

function TouringBandPosterItemView:AnimBandFanWinSound()
    AudioUtil.LoadAndPlayUISound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_UI_Band_Badge_Generator.Play_UI_Band_Badge_Generator'")
end

return TouringBandPosterItemView