---
--- Author: peterxie
--- DateTime: 2024-08-26 10:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")
local ProtoRes = require("Protocol/ProtoRes")
local UIShowType = require("UI/UIShowType")
local ObjectGCType = require("Define/ObjectGCType")
local UILayer = require("UI/UILayer")
local TipsShowType = ProtoRes.sysnotice_show_type


---@class InfoAreaTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelArea UFCanvasPanel
---@field PanelMap UFCanvasPanel
---@field PanelPworid UFCanvasPanel
---@field TextAreaTitle UFTextBlock
---@field TextMapSubTitle UFTextBlock
---@field TextMapTitle UFTextBlock
---@field TextPworidSubTitle UFTextBlock
---@field TextPworidTitle UFTextBlock
---@field AnimAreaIn UWidgetAnimation
---@field AnimMapIn UWidgetAnimation
---@field AnimPworid UWidgetAnimation
---@field AnimPworidOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoAreaTipsView = LuaClass(InfoTipsBaseView, true)

function InfoAreaTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelArea = nil
	--self.PanelMap = nil
	--self.PanelPworid = nil
	--self.TextAreaTitle = nil
	--self.TextMapSubTitle = nil
	--self.TextMapTitle = nil
	--self.TextPworidSubTitle = nil
	--self.TextPworidTitle = nil
	--self.AnimAreaIn = nil
	--self.AnimMapIn = nil
	--self.AnimPworid = nil
	--self.AnimPworidOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoAreaTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoAreaTipsView:InitView(ViewID, Config)
	self.Super:InitView()
	-- 有两个view共用蓝图,间隔太短调用底层initview会过滤掉参数赋值,这里手动加一下
	self.ViewID = ViewID
	self.Config = Config
	self.ShowType = Config and Config.ShowType or UIShowType.Normal
	self.GCType = Config and Config.GCType or ObjectGCType.LRU
	self.Layer = Config and Config.Layer or UILayer.Normal
end

function InfoAreaTipsView:OnInit()

end

function InfoAreaTipsView:OnDestroy()

end

function InfoAreaTipsView:OnShow()
	self.Super:OnShow()

	local Params = self.Params
	if nil == Params then
		return
	end

	UIUtil.SetIsVisible(self.PanelArea, false)
	UIUtil.SetIsVisible(self.PanelMap, false)
	UIUtil.SetIsVisible(self.PanelPworid, false)
	if Params.ShowType == TipsShowType.SYSNOTICE_SHOWTYPE_AREA then
		MsgTipsUtil.MarkAreaTips(true)
		UIUtil.SetIsVisible(self.PanelArea, true)
		self:ShowEnterArea()
		self:PlayAnimation(self.AnimAreaIn)
	elseif Params.ShowType == TipsShowType.SYSNOTICE_SHOWTYPE_MAP then
		MsgTipsUtil.MarkEnterMapTips(true)
		UIUtil.SetIsVisible(self.PanelMap, true)
		self:ShowEnterMap()
		self:PlayAnimation(self.AnimMapIn)
	elseif Params.ShowType == TipsShowType.SYSNOTICE_SHOWTYPE_PWORLD_ENTER then
		UIUtil.SetIsVisible(self.PanelPworid, true)
		self:ShowEnterPWorld()
		self:PlayAnimation(self.AnimPworid)
	end
end

function InfoAreaTipsView:ShowEnterArea()
	local Params = self.Params

	self.TextAreaTitle:SetText(Params.Content)
end

function InfoAreaTipsView:ShowEnterMap()
	local Params = self.Params

	local MapCfgData = nil
	if (Params ~= nil and Params.MapResID ~= nil) then
		MapCfgData = _G.PWorldMgr:GetMapTableCfg(Params.MapResID)
	else
		MapCfgData = _G.PWorldMgr:GetCurrMapTableCfg()
	end
	if (MapCfgData ~= nil) then
		self.TextMapTitle:SetText(MapCfgData.DisplayName)
		self.TextMapSubTitle:SetText(MapCfgData.RegionName)
	end
end

function InfoAreaTipsView:ShowEnterPWorld()
	local Params = self.Params
	local MapCfgData = nil
	if (Params ~= nil and Params.MapResID ~= nil) then
		MapCfgData = _G.PWorldMgr:GetMapTableCfg(Params.MapResID)
	else
		MapCfgData = _G.PWorldMgr:GetCurrMapTableCfg()
	end
	self.TextPworidTitle:SetText(MapCfgData.DisplayName)
	self.TextPworidSubTitle:SetText(MapCfgData.RegionName)
end

function InfoAreaTipsView:PlayPWorldOutAnimation()
	self:PlayAnimation(self.AnimPworidOut)
end

function InfoAreaTipsView:OnHide()
	local Params = self.Params

	if Params.ShowType == TipsShowType.SYSNOTICE_SHOWTYPE_AREA then
		MsgTipsUtil.MarkAreaTips(false)
	elseif Params.ShowType == TipsShowType.SYSNOTICE_SHOWTYPE_MAP then
		MsgTipsUtil.MarkEnterMapTips(false)
	end
end

function InfoAreaTipsView:OnRegisterUIEvent()

end

function InfoAreaTipsView:OnRegisterGameEvent()

end

function InfoAreaTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function InfoAreaTipsView:OnRegisterBinder()

end

function InfoAreaTipsView:OnAnimationFinished(Animation)
	if Animation == self.AnimAreaIn or Animation == self.AnimMapIn or Animation == self.AnimPworidOut then
		self:Hide()
	end
end

return InfoAreaTipsView