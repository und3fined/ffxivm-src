---
--- Author: anypkvcai
--- DateTime: 2024-01-30 11:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local RichTextUtil = require("Utils/RichTextUtil")

---@class TextureTextView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextBoxText URichTextBox
---@field TextContent string
---@field TexturePath string
---@field TextMapping string
---@field TextTemp string
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TextureTextView = LuaClass(UIView, true)

function TextureTextView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextBoxText = nil
	--self.TextContent = nil
	--self.TexturePath = nil
	--self.TextMapping = nil
	--self.TextTemp = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TextureTextView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TextureTextView:OnInit()

end

function TextureTextView:OnDestroy()

end

function TextureTextView:OnShow()

end

function TextureTextView:OnHide()

end

function TextureTextView:OnRegisterUIEvent()

end

function TextureTextView:OnRegisterGameEvent()

end

function TextureTextView:OnRegisterBinder()

end

function TextureTextView:GetTexture(Char)
	Char = self.TextMapping:Find(Char) or Char

	local Path = string.format(self.TexturePath, Char, Char)

	return RichTextUtil.GetTexture(Path)
end

function TextureTextView:GetRichText(Text)
	local ListText = {}
	for i = 1, #Text do
		table.insert(ListText, self:GetTexture(string.sub(Text, i, i)))
	end

	return table.concat(ListText, "")
end

function TextureTextView:SetText(Text)
	self.RichTextBoxText:SetText(self:GetRichText(Text))
end

return TextureTextView