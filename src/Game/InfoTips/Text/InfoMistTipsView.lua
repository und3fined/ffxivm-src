---
--- Author: sammrli
--- DateTime: 2024-09-09 19:07
--- Description:探索迷雾解锁提示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

local MsgTipsID = require("Define/MsgTipsID")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")

local LSTR = _G.LSTR

---@class InfoMistTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MI_DX_InfoTextTips_3 UFImage
---@field PanelBigTips UFCanvasPanel
---@field PanelSamll UFCanvasPanel
---@field TextBigSubTitle UFTextBlock
---@field TextBigTitle UFTextBlock
---@field TextSamllTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoMistTipsView = LuaClass(InfoTipsBaseView, true)

function InfoMistTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MI_DX_InfoTextTips_3 = nil
	--self.PanelBigTips = nil
	--self.PanelSamll = nil
	--self.TextBigSubTitle = nil
	--self.TextBigTitle = nil
	--self.TextSamllTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoMistTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoMistTipsView:OnInit()

end

function InfoMistTipsView:OnDestroy()

end

function InfoMistTipsView:OnShow()
	self.Super:OnShow()

	local Params = self.Params

	if Params and Params.IsAllUnlock then
		self:ShowAllMistUnlock()
	else
		self:ShowMistUnlock()
	end
end

function InfoMistTipsView:OnHide()
end

function InfoMistTipsView:OnRegisterUIEvent()

end

function InfoMistTipsView:OnRegisterGameEvent()
	self.Super:OnRegisterTimer()
end

function InfoMistTipsView:OnRegisterBinder()

end

function InfoMistTipsView:ShowMistUnlock()
	UIUtil.SetIsVisible(self.PanelBigTips, false)
	UIUtil.SetIsVisible(self.MI_DX_InfoTextTips_3, false)
	UIUtil.SetIsVisible(self.PanelSamll, true)
	local SysnoticeCfgItem = SysnoticeCfg:FindCfgByKey(MsgTipsID.MapFogUnlock)
	if SysnoticeCfgItem then
		self.TextSamllTitle:SetText(SysnoticeCfgItem.Content[1])
	else
		self.TextSamllTitle:SetText("")
		FLOG_ERROR("[InfoMistTipsView] cant find sysnoticeCfg id="..tostring(MsgTipsID.MapFogUnlock))
	end
end

function InfoMistTipsView:ShowAllMistUnlock()
	UIUtil.SetIsVisible(self.PanelBigTips, true)
	UIUtil.SetIsVisible(self.MI_DX_InfoTextTips_3, true)
	UIUtil.SetIsVisible(self.PanelSamll, false)
	self.TextBigTitle:SetText(LSTR(550001)) --550001("迷雾探索完成")
	local MapTableCfg = _G.PWorldMgr:GetCurrMapTableCfg()
	if MapTableCfg then
		self.TextBigSubTitle:SetText(MapTableCfg.DisplayName)
	else
		self.TextBigSubTitle:SetText("")
	end
end

return InfoMistTipsView