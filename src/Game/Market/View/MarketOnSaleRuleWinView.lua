---
--- Author: Administrator
--- DateTime: 2023-05-09 11:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local LSTR = _G.LSTR
---@class MarketOnSaleRuleWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameMView
---@field RichTextIntro URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketOnSaleRuleWinView = LuaClass(UIView, true)

function MarketOnSaleRuleWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.RichTextIntro = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketOnSaleRuleWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketOnSaleRuleWinView:OnInit()

end

function MarketOnSaleRuleWinView:OnDestroy()

end

function MarketOnSaleRuleWinView:OnShow()
end

function MarketOnSaleRuleWinView:OnHide()

end

function MarketOnSaleRuleWinView:OnRegisterUIEvent()

end

function MarketOnSaleRuleWinView:OnRegisterGameEvent()

end

function MarketOnSaleRuleWinView:OnRegisterBinder()
	self.Bg:SetTitleText(LSTR(1010066))
	self.RichTextIntro:SetText(LSTR(1010067))
end

return MarketOnSaleRuleWinView