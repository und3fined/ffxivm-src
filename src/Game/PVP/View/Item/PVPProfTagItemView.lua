---
--- Author: Administrator
--- DateTime: 2024-11-12 16:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class PVPProfTagItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextLabel UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPProfTagItemView = LuaClass(UIView, true)

function PVPProfTagItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextLabel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPProfTagItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPProfTagItemView:OnInit()

end

function PVPProfTagItemView:OnDestroy()

end

function PVPProfTagItemView:OnShow()

end

function PVPProfTagItemView:OnHide()

end

function PVPProfTagItemView:OnRegisterUIEvent()

end

function PVPProfTagItemView:OnRegisterGameEvent()

end

function PVPProfTagItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	local Binders = {
		{ "TagText", UIBinderSetText.New(self, self.TextLabel) },
		--{ "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgSkillIcon) },
	}
	
	self:RegisterBinders(ViewModel, Binders)
end

return PVPProfTagItemView