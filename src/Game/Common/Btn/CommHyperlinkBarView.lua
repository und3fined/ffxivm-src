---
--- Author: xingcaicao
--- DateTime: 2023-03-24 15:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local AccountUtil = require("Utils/AccountUtil")
local LSTR = _G.LSTR

---@class CommHyperlinkBarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnHyperlink UFButton
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommHyperlinkBarView = LuaClass(UIView, true)

function CommHyperlinkBarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnHyperlink = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommHyperlinkBarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommHyperlinkBarView:OnInit()

end

function CommHyperlinkBarView:OnDestroy()

end

function CommHyperlinkBarView:OnShow()

end

function CommHyperlinkBarView:OnHide()
	self.Url = nil
	self.ClickCallback = nil
end

function CommHyperlinkBarView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnHyperlink, self.OnClickButtonHyperlink)
end

function CommHyperlinkBarView:OnRegisterGameEvent()

end

function CommHyperlinkBarView:OnRegisterBinder()

end

function CommHyperlinkBarView:OnClickButtonHyperlink()
	if not string.isnilorempty(self.Url) then
		AccountUtil.OpenUrl(self.Url, 1, false, true, "", false)
	end

	if self.ClickCallback ~= nil then 
		self.ClickCallback()
	end
end

function CommHyperlinkBarView:SetUrl(Url)
	self.Url = Url
end

function CommHyperlinkBarView:SetContentText( Text )
	self.TextContent:SetText(Text or "")
end

function CommHyperlinkBarView:SetClickCallback( ClickCallback )
	self.ClickCallback = ClickCallback
end

return CommHyperlinkBarView