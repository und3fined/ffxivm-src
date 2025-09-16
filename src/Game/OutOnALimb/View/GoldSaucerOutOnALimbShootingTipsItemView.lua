---
--- Author: bowxiong
--- DateTime: 2025-03-15 14:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameProgressType = GoldSaucerMiniGameDefine.MiniGameProgressType

local FLOG_ERROR = _G.FLOG_ERROR

---@class GoldSaucerOutOnALimbShootingTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine3 UFImage
---@field ImgLine5 UFImage
---@field MI_DX_Common_GoldSaucer_3 UFImage
---@field PanelTipsBlue UFCanvasPanel
---@field PanelTipsFail UFCanvasPanel
---@field PanelTipsGreen UFCanvasPanel
---@field PanelTipsYellow UFCanvasPanel
---@field TextFail UFTextBlock
---@field TextGood UFTextBlock
---@field TextPretty UFTextBlock
---@field TextPretty_1 UFTextBlock
---@field TextSmall2 UFTextBlock
---@field TextSmall3 UFTextBlock
---@field TextSmall4 UFTextBlock
---@field TextSmall5 UFTextBlock
---@field AnimTipsBlue UWidgetAnimation
---@field AnimTipsFail UWidgetAnimation
---@field AnimTipsGreen UWidgetAnimation
---@field AnimTipsYellow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerOutOnALimbShootingTipsItemView = LuaClass(UIView, true)

function GoldSaucerOutOnALimbShootingTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine3 = nil
	--self.ImgLine5 = nil
	--self.MI_DX_Common_GoldSaucer_3 = nil
	--self.PanelTipsBlue = nil
	--self.PanelTipsFail = nil
	--self.PanelTipsGreen = nil
	--self.PanelTipsYellow = nil
	--self.TextFail = nil
	--self.TextGood = nil
	--self.TextPretty = nil
	--self.TextPretty_1 = nil
	--self.TextSmall2 = nil
	--self.TextSmall3 = nil
	--self.TextSmall4 = nil
	--self.TextSmall5 = nil
	--self.AnimTipsBlue = nil
	--self.AnimTipsFail = nil
	--self.AnimTipsGreen = nil
	--self.AnimTipsYellow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerOutOnALimbShootingTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerOutOnALimbShootingTipsItemView:OnInit()

end

function GoldSaucerOutOnALimbShootingTipsItemView:OnDestroy()

end

function GoldSaucerOutOnALimbShootingTipsItemView:OnShow()

end

function GoldSaucerOutOnALimbShootingTipsItemView:OnHide()

end

function GoldSaucerOutOnALimbShootingTipsItemView:OnRegisterUIEvent()

end

function GoldSaucerOutOnALimbShootingTipsItemView:OnRegisterGameEvent()

end

function GoldSaucerOutOnALimbShootingTipsItemView:OnRegisterBinder()

end

function GoldSaucerOutOnALimbShootingTipsItemView:UpdateMainPanelData(ViewModel)
	if ViewModel == nil then
		return
	end
	local MiniGameInst = ViewModel.MiniGame
	if MiniGameInst == nil then
		return
	end

	local ClientDef = MiniGameInst.DefineCfg
	if not ClientDef then
		return
	end

	local ProgressLevelDef = ClientDef.ProgressLevel
	if not ProgressLevelDef then
		return
	end

	local LatestProgressLv = MiniGameInst:GetLatestProgressLv()
    if LatestProgressLv ~= nil then
		local StateDef = ProgressLevelDef[LatestProgressLv]
		local MainText = StateDef.Text or ""
		local SubText = StateDef.SubText or ""
        if LatestProgressLv == MiniGameProgressType.Perfect then
			self.TextPretty_1:SetText(MainText)
			self.TextSmall5:SetText(SubText)
			self:PlayAnimation(self.AnimTipsYellow)
        elseif LatestProgressLv == MiniGameProgressType.Nice then
			self.TextGood:SetText(MainText)
			self.TextSmall3:SetText(SubText)
			self:PlayAnimation(self.AnimTipsBlue)
        elseif LatestProgressLv == MiniGameProgressType.Good then
			self.TextPretty:SetText(MainText)
			self.TextSmall2:SetText(SubText)
			self:PlayAnimation(self.AnimTipsGreen)
        elseif LatestProgressLv == MiniGameProgressType.Bad then
			self.TextFail:SetText(MainText)
			self.TextSmall4:SetText(SubText)
			self:PlayAnimation(self.AnimTipsFail)
        else
            FLOG_ERROR("OutOnALimbView:OnMiniGameProgressChanged do not have the MiniGameProgressType")
        end
    end
end

function GoldSaucerOutOnALimbShootingTipsItemView:IsForceGC()
	return true
end

return GoldSaucerOutOnALimbShootingTipsItemView