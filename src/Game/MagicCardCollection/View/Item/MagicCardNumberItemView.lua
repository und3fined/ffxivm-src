---
--- Author: Administrator
--- DateTime: 2023-12-18 16:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MagicCardNumberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextureDown TextureTextView
---@field TextureLeft TextureTextView
---@field TextureRight TextureTextView
---@field TextureUp TextureTextView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicCardNumberItemView = LuaClass(UIView, true)

function MagicCardNumberItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextureDown = nil
	--self.TextureLeft = nil
	--self.TextureRight = nil
	--self.TextureUp = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicCardNumberItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.TextureDown)
	self:AddSubView(self.TextureLeft)
	self:AddSubView(self.TextureRight)
	self:AddSubView(self.TextureUp)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicCardNumberItemView:OnInit()

end

function MagicCardNumberItemView:OnDestroy()

end

function MagicCardNumberItemView:OnShow()

end

function MagicCardNumberItemView:OnHide()

end

function MagicCardNumberItemView:OnRegisterUIEvent()

end

function MagicCardNumberItemView:OnRegisterGameEvent()

end

function MagicCardNumberItemView:OnRegisterBinder()

end

function MagicCardNumberItemView:UpDateNumberText(CardCfg)
	self.TextureDown:SetText(string.format("%X", CardCfg.Down))
	self.TextureUp:SetText(string.format("%X", CardCfg.Up))
	self.TextureLeft:SetText(string.format("%X", CardCfg.Left))
	self.TextureRight:SetText(string.format("%X", CardCfg.Right))
end

return MagicCardNumberItemView