---
--- Author: loiafeng
--- DateTime: 2024-05-09 10:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoadingVM = require("Game/Loading/LoadingVM")

local UIBinderSetImageBrushSync = require("Binder/UIBinderSetImageBrushSync")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class LoadingGoldEventItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img UFImage
---@field ImgCactus UFImage
---@field Title LoadingTitleItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoadingGoldEventItemView = LuaClass(UIView, true)

function LoadingGoldEventItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Img = nil
	--self.ImgCactus = nil
	--self.Title = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingGoldEventItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Title)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingGoldEventItemView:OnInit()
	self.Binders = {
		{ "MainImage", UIBinderSetImageBrushSync.New(self, self.Img) },
		{ "LandscapeImage", UIBinderSetImageBrushSync.New(self, self.ImgCactus) },
	}
end

function LoadingGoldEventItemView:OnDestroy()

end

function LoadingGoldEventItemView:OnShow()

end

function LoadingGoldEventItemView:OnHide()

end

function LoadingGoldEventItemView:OnRegisterUIEvent()

end

function LoadingGoldEventItemView:OnRegisterGameEvent()

end

function LoadingGoldEventItemView:OnRegisterBinder()
	self:RegisterBinders(LoadingVM, self.Binders)
end

return LoadingGoldEventItemView