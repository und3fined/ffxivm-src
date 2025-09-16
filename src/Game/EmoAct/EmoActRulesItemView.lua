---
--- Author: Administrator
--- DateTime: 2023-10-09 20:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class EmoActRulesItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TextExplan URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActRulesItemView = LuaClass(UIView, true)

function EmoActRulesItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.TextExplan = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActRulesItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActRulesItemView:OnInit()
	UIUtil.SetIsVisible(self, true)
end

function EmoActRulesItemView:OnDestroy()

end

function EmoActRulesItemView:OnShow()
	if self.Params.Data then
		if self.TextExplan and self.Params.Data.CanUseName then
			self.TextExplan:SetText(self.Params.Data.CanUseName)
		end
		if self.ImgIcon and self.Params.Data.IconPath then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, self.Params.Data.IconPath)
		end
	else
		self:Hide()
	end
end

function EmoActRulesItemView:OnHide()

end

function EmoActRulesItemView:OnRegisterUIEvent()

end

function EmoActRulesItemView:OnRegisterGameEvent()

end

function EmoActRulesItemView:OnRegisterBinder()

end

return EmoActRulesItemView