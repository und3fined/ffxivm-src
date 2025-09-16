---
--- Author: chriswang
--- DateTime: 2024-09-24 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local SettingsUtils = require("Game/Settings/SettingsUtils")
local SettingsDefine = require("Game/Settings/SettingsDefine")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local LSTR = _G.LSTR
local ItemDisplayStyle = SettingsDefine.ItemDisplayStyle

---@class SettingsItemHyperLinkView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field HyperlinkBar SettingsHyperlinkBarView
---@field PanelHyperlink UFCanvasPanel
---@field TextItemContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsItemHyperLinkView = LuaClass(UIView, true)

function SettingsItemHyperLinkView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.HyperlinkBar = nil
	--self.PanelHyperlink = nil
	--self.TextItemContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsItemHyperLinkView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.HyperlinkBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsItemHyperLinkView:OnInit()

end

function SettingsItemHyperLinkView:OnDestroy()

end

function SettingsItemHyperLinkView:OnShow()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	self.ItemVM = self.Params.Data

	local Style = self.ItemVM.DisplayStyle
	if Style == ItemDisplayStyle.Hyperlink then
		self:SetHyperlink()
	elseif Style == ItemDisplayStyle.Button then
		self:SetClieckCallback()
	elseif Style == ItemDisplayStyle.TextByCustomUI then
		self:SetCustomUIItem()
	end
end

function SettingsItemHyperLinkView:OnHide()

end

function SettingsItemHyperLinkView:OnRegisterUIEvent()

end

function SettingsItemHyperLinkView:OnRegisterGameEvent()

end

function SettingsItemHyperLinkView:OnRegisterBinder()

end

---超链接（唤起网页）
function SettingsItemHyperLinkView:SetHyperlink()
	-- CommHyperlinkBarView文本
	self.HyperlinkBar:SetContentText(self.ItemVM.Value[1])

	-- 设置url
	self.HyperlinkBar:SetUrl(self.ItemVM.NoTranslateStr)

	-- 设置点击回调
	local ClickCallback = self.ItemVM.SetValueFunc
	if not string.isnilorempty(ClickCallback) then
		self.HyperlinkBar:SetClickCallback(function()
			SettingsUtils.SetValue(ClickCallback, self.ItemVM.SettingCfg)
		end)
	end

	-- 设置描述
	local Desc = self.ItemVM.Desc
	if string.isnilorempty(Desc) then
		Desc = SettingsUtils.GetValue(self.ItemVM.GetValueFunc, self.ItemVM.SettingCfg)
	end

	self.TextItemContent:SetText(Desc or "")
end

---点击回调(按钮)
function SettingsItemHyperLinkView:SetClieckCallback()
	self.TextItemContent:SetText(self.ItemVM.Desc or "")
	self.HyperlinkBar:SetContentText(self.ItemVM.Value[1])
	self.HyperlinkBar:SetUrl(nil)

	-- 设置点击回调
	local ClickCallback = self.ItemVM.SetValueFunc
	if not string.isnilorempty(ClickCallback) then
		self.HyperlinkBar:SetClickCallback(function()
			SettingsUtils.SetValue(ClickCallback, self.ItemVM.SettingCfg)
		end)
	end
end

--- 自定义UI ，相当于按钮
function SettingsItemHyperLinkView:SetCustomUIItem()
	UIUtil.SetIsVisible(self.PanelHyperlink, true)

	self.TextItemContent:SetText(self.ItemVM.Desc or "")
	
	self.HyperlinkBar:SetUrl(nil)

	local Value = SettingsUtils.GetValue(self.ItemVM.GetValueFunc, self.ItemVM.SettingCfg) or 1
	local RightBtnContent, UIViewID = _G.SettingsMgr:GetContentBySaveKey(self.ItemVM.SettingCfg.SaveKey, Value)
	if RightBtnContent == nil then
		RightBtnContent, UIViewID = _G.SettingsMgr:GetContentByClientSetupKey(self.ItemVM.SettingCfg.ClientSetupKey, Value)
	end

	self.HyperlinkBar:SetContentText(RightBtnContent or "")

	-- UIUtil.AddOnClickedEvent(self, self.HyperlinkBar.BtnHyperlink
	-- 	, self.OnCustomUIClose)

	self.HyperlinkBar:SetClickCallback(function()
		_G.UIViewMgr:ShowView(UIViewID, {ViewObj = self, CallBack = self.OnCustomUIClose, Value = Value})
	end)
end

function SettingsItemHyperLinkView:OnCustomUIClose(SelectValue)
	FLOG_INFO("setting OnCustomUIClose SelectValue: %d", SelectValue)
	local Value = SelectValue
	local RightBtnContent = _G.SettingsMgr:GetContentBySaveKey(self.ItemVM.SettingCfg.SaveKey, Value)
	if RightBtnContent == nil then
		RightBtnContent = _G.SettingsMgr:GetContentByClientSetupKey(self.ItemVM.SettingCfg.ClientSetupKey, Value)
	end

	self.HyperlinkBar:SetContentText(RightBtnContent or "")

	-- 设置值
	SettingsUtils.SetValue(self.ItemVM.SetValueFunc, self.ItemVM.SettingCfg, SelectValue, true)
end

return SettingsItemHyperLinkView