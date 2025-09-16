---
--- Author: jususchen
--- DateTime: 2024-06-03 18:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class PWorldTaskSetUpListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TextSetUp UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldTaskSetUpListItemView = LuaClass(UIView, true)

function PWorldTaskSetUpListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.TextSetUp = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldTaskSetUpListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldTaskSetUpListItemView:OnInit()
	self.Binders = {
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon, true)},
		{"Text", UIBinderSetText.New(self, self.TextSetUp)},
	}
end

function PWorldTaskSetUpListItemView:OnDestroy()

end

function PWorldTaskSetUpListItemView:OnShow()

end

function PWorldTaskSetUpListItemView:OnHide()

end

function PWorldTaskSetUpListItemView:OnRegisterUIEvent()

end

function PWorldTaskSetUpListItemView:OnRegisterGameEvent()

end

function PWorldTaskSetUpListItemView:OnRegisterBinder()
	local VM = self.Params.Data
	if VM == nil then
		return
	end

	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return PWorldTaskSetUpListItemView