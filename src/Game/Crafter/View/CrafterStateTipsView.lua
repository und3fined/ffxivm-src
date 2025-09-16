---
--- Author: chriswang
--- DateTime: 2023-09-06 10:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
-- local CrafterConfig = require("Define/CrafterConfig")
local RandomEventCfg = require("TableCfg/RandomEventCfg")
local RnadomEventColorCfg = require("TableCfg/RandomEventColorCfg")

local TipsLineNum = 4
local TipsDelayHideTime = 2

---@class CrafterStateTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLightColor UFImage
---@field ImgTipsColorBg UFImage
---@field ImgTipsLine1 UFImage
---@field ImgTipsLine2 UFImage
---@field ImgTipsLine3 UFImage
---@field ImgTipsLine4 UFImage
---@field PanelFail UFCanvasPanel
---@field PanelSuccess UFCanvasPanel
---@field PanelTipsLine UFCanvasPanel
---@field RichTextTitle URichTextBox
---@field TextContent UFTextBlock
---@field TextFail UFTextBlock
---@field TextSuccess UFTextBlock
---@field TextTitle UScaleBox
---@field AnimChaos UWidgetAnimation
---@field AnimFailed UWidgetAnimation
---@field AnimInactivation UWidgetAnimation
---@field AnimInnerQuiet UWidgetAnimation
---@field AnimOverheat UWidgetAnimation
---@field AnimSlack UWidgetAnimation
---@field AnimSuc UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterStateTipsView = LuaClass(UIView, true)
-- local StateConfig = CrafterConfig.StateConfig

function CrafterStateTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLightColor = nil
	--self.ImgTipsColorBg = nil
	--self.ImgTipsLine1 = nil
	--self.ImgTipsLine2 = nil
	--self.ImgTipsLine3 = nil
	--self.ImgTipsLine4 = nil
	--self.PanelFail = nil
	--self.PanelSuccess = nil
	--self.PanelTipsLine = nil
	--self.RichTextTitle = nil
	--self.TextContent = nil
	--self.TextFail = nil
	--self.TextSuccess = nil
	--self.TextTitle = nil
	--self.AnimChaos = nil
	--self.AnimFailed = nil
	--self.AnimInactivation = nil
	--self.AnimInnerQuiet = nil
	--self.AnimOverheat = nil
	--self.AnimSlack = nil
	--self.AnimSuc = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterStateTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterStateTipsView:OnInit()
	local LSTR = _G.LSTR
	self.TextSuccess:SetText(LSTR(150063))  -- 制作成功
	self.TextFail:SetText(LSTR(150064))     -- 制作失败
end

function CrafterStateTipsView:OnDestroy()

end

function CrafterStateTipsView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	if Params.EventType then
		local Cfgs=  RandomEventCfg:FindAllCfg()
		local Cfg = RandomEventCfg:FindCfgByKey(Params.EventType)
		if Cfg then
			self.TextContent:SetText(Cfg.Desc)
			self.RichTextTitle:SetText(Params.Title or Cfg.Name)

			if Cfg.ColorID then
				local ColorCfg = RnadomEventColorCfg:FindCfgByKey(Cfg.ColorID)
				-- UIUtil.ImageSetBrushFromAssetPath(self.ImgLightColor, ColorCfg.LightColorTexture)
				local FColor = _G.UE.FColor

				if ColorCfg.OutlineColor then
					_G.UE.UUIUtil.SetFontTextureAndOutlineColor(self.RichTextTitle, nil, ColorCfg.OutlineColor)
				end

				if ColorCfg.FontColor then
					self.RichTextTitle:SetColorAndOpacity(FColor.FromHex(ColorCfg.FontColor):ToLinearColor())
				end
				
				local TipsLineType = ColorCfg.TipsLineType
				if TipsLineType then
					for i = 1, TipsLineNum do
						local TipsLineName = "ImgTipsLine" .. tostring(i)
						local TipsLinePanel = self[TipsLineName]
						if TipsLinePanel then
							UIUtil.SetIsVisible(TipsLinePanel, i == TipsLineType)
						end
					end
				end
			end

			
			local TipsAnim = self[Cfg.TipsAnim]
			if TipsAnim then
				self:PlayAnimation(TipsAnim)
			end
		end

		if Cfg and Cfg.SkillID > 0 then
			_G.EventMgr:SendEvent(_G.EventID.CrafterRandomEventSkill, Params.EventType, Cfg.SkillID)
		end
		-- local EventConfig = StateConfig[Params.EventType]
		-- if EventConfig then
		-- 	self.TextContent:SetText(EventConfig.Text)
		-- 	UIUtil.ImageSetBrushFromAssetPath(self.ImgTitle, EventConfig.ImagePath)
		-- end
	end

	if self.HideTimerID then
        _G.TimerMgr:CancelTimer(self.HideTimerID)
	end

	self.HideTimerID = _G.TimerMgr:AddTimer(self, self.Hide, TipsDelayHideTime, 1, 1)
end

function CrafterStateTipsView:OnHide()
	self:CloseTimer()
end

function CrafterStateTipsView:CloseTimer()
	if self.HideTimerID then
        _G.TimerMgr:CancelTimer(self.HideTimerID)
	end

	self.HideTimerID = nil
end

function CrafterStateTipsView:OnRegisterUIEvent()

end

function CrafterStateTipsView:OnRegisterGameEvent()

end

function CrafterStateTipsView:OnRegisterBinder()

end

return CrafterStateTipsView