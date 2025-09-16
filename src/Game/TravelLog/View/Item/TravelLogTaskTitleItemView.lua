---
--- Author: sammrli
--- DateTime: 2024-02-26 11:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetText = require("Binder/UIBinderSetText")

---@class TravelLogTaskTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextBlock_43 UFTextBlock
---@field IconMark UFImage
---@field ImgLine UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TravelLogTaskTitleItemView = LuaClass(UIView, true)

function TravelLogTaskTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextBlock_43 = nil
	--self.IconMark = nil
	--self.ImgLine = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TravelLogTaskTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TravelLogTaskTitleItemView:OnInit()

end

function TravelLogTaskTitleItemView:OnDestroy()

end

function TravelLogTaskTitleItemView:OnShow()

end

function TravelLogTaskTitleItemView:OnHide()

end

function TravelLogTaskTitleItemView:OnRegisterUIEvent()

end

function TravelLogTaskTitleItemView:OnRegisterGameEvent()

end

function TravelLogTaskTitleItemView:OnRegisterBinder()
	if nil == self.Params then return end

	---@type TravelLogTaskTitleItneVM
	self.ViewModel = self.Params.Data

	local Binders = {
		{ "Title", UIBinderSetText.New(self, self.FTextBlock_43) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

return TravelLogTaskTitleItemView