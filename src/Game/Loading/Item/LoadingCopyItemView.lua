---
--- Author: loiafeng
--- DateTime: 2024-05-09 10:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoadingVM = require("Game/Loading/LoadingVM")

local UIBinderSetImageBrushSync = require("Binder/UIBinderSetImageBrushSync")

---@class LoadingCopyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img UFImage
---@field Title LoadingTitleItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoadingCopyItemView = LuaClass(UIView, true)

function LoadingCopyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Img = nil
	--self.Title = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingCopyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Title)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingCopyItemView:OnInit()
	self.Binders = {
		{ "MainImage", UIBinderSetImageBrushSync.New(self, self.Img) },
	}
end

function LoadingCopyItemView:OnDestroy()

end

function LoadingCopyItemView:OnShow()

end

function LoadingCopyItemView:OnHide()

end

function LoadingCopyItemView:OnRegisterUIEvent()

end

function LoadingCopyItemView:OnRegisterGameEvent()

end

function LoadingCopyItemView:OnRegisterBinder()
	self:RegisterBinders(LoadingVM, self.Binders)
end

return LoadingCopyItemView