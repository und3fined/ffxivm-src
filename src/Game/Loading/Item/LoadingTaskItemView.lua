---
--- Author: loiafeng
--- DateTime: 2024-05-09 10:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoadingVM = require("Game/Loading/LoadingVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrushSync = require("Binder/UIBinderSetImageBrushSync")

---@class LoadingTaskItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img UFImage
---@field Text UFTextBlock
---@field TextTask UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoadingTaskItemView = LuaClass(UIView, true)

function LoadingTaskItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Img = nil
	--self.Text = nil
	--self.TextTask = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingTaskItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingTaskItemView:OnInit()
	self.Binders = {
		{ "MainImage", UIBinderSetImageBrushSync.New(self, self.Img) },
		{ "TextLabel", UIBinderSetText.New(self, self.TextTask) },
		{ "TextTitle", UIBinderSetText.New(self, self.TextTitle) },
		{ "TextBody", UIBinderSetText.New(self, self.Text) },
	}
end

function LoadingTaskItemView:OnDestroy()

end

function LoadingTaskItemView:OnShow()

end

function LoadingTaskItemView:OnHide()

end

function LoadingTaskItemView:OnRegisterUIEvent()

end

function LoadingTaskItemView:OnRegisterGameEvent()

end

function LoadingTaskItemView:OnRegisterBinder()
	self:RegisterBinders(LoadingVM, self.Binders)
end

return LoadingTaskItemView