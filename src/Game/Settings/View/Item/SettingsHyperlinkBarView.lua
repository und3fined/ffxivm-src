---
--- Author: chriswang
--- DateTime: 2025-04-17 19:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local AccountUtil = require("Utils/AccountUtil")
local LSTR = _G.LSTR

---@class SettingsHyperlinkBarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnHyperlink UFButton
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsHyperlinkBarView = LuaClass(UIView, true)

function SettingsHyperlinkBarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnHyperlink = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsHyperlinkBarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsHyperlinkBarView:OnInit()

end

function SettingsHyperlinkBarView:OnDestroy()

end

function SettingsHyperlinkBarView:OnShow()

end

function SettingsHyperlinkBarView:OnHide()
	self.Url = nil
	self.ClickCallback = nil
end

function SettingsHyperlinkBarView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnHyperlink, self.OnClickButtonHyperlink)
end

function SettingsHyperlinkBarView:OnRegisterGameEvent()

end

function SettingsHyperlinkBarView:OnRegisterBinder()

end

function SettingsHyperlinkBarView:OnClickButtonHyperlink()
	if not string.isnilorempty(self.Url) then
		AccountUtil.OpenUrl(self.Url, 1, false, true, "", false)
	end

	if self.ClickCallback ~= nil then 
		self.ClickCallback()
	end
end

function SettingsHyperlinkBarView:SetUrl(Url)
	self.Url = Url
end

function SettingsHyperlinkBarView:SetContentText( Text )
	self.TextContent:SetText(Text or "")
end

function SettingsHyperlinkBarView:SetClickCallback( ClickCallback )
	self.ClickCallback = ClickCallback
end

return SettingsHyperlinkBarView