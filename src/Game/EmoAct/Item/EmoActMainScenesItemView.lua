---
--- Author: Administrator
--- DateTime: 2023-10-07 15:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class EmoActMainScenesItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgOff UFImage
---@field ImgOn UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActMainScenesItemView = LuaClass(UIView, true)

function EmoActMainScenesItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgOff = nil
	--self.ImgOn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActMainScenesItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActMainScenesItemView:OnInit()

end

function EmoActMainScenesItemView:OnDestroy()

end

function EmoActMainScenesItemView:OnShow()

	if self.Params.Data then
		self:SetActive(self.Params.Data.CanUse == 1)
		self:SetIconPath(self.Params.Data.IconPath)
	end
end

function EmoActMainScenesItemView:OnHide()

end

function EmoActMainScenesItemView:OnRegisterUIEvent()

end

function EmoActMainScenesItemView:OnRegisterGameEvent()

end

function EmoActMainScenesItemView:OnRegisterBinder()

end

---设置高亮可视性
function EmoActMainScenesItemView:SetActive(IsActive)
	UIUtil.SetIsVisible(self.ImgOff, not IsActive)
	UIUtil.SetIsVisible(self.ImgOn, IsActive)
end

---设置图标样式
function EmoActMainScenesItemView:SetIconPath(IconPath)

	if IconPath == nil then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgOff, IconPath)

	local NewIconPath = string.gsub(IconPath, "Off","On")

	UIUtil.ImageSetBrushFromAssetPath(self.ImgOn, NewIconPath)

end

return EmoActMainScenesItemView