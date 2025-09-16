---
--- Author: Administrator
--- DateTime: 2024-03-05 10:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class GuideItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGuide UFButton
---@field IconGuide UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GuideItemView = LuaClass(UIView, true)

function GuideItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGuide = nil
	--self.IconGuide = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GuideItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GuideItemView:OnInit()

end

function GuideItemView:OnDestroy()

end

function GuideItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Item = Params.Data
	if nil == Item then
		return
	end
end

function GuideItemView:OnHide()
	self.AtlasID = nil
end

function GuideItemView:OnRegisterUIEvent()

end


function GuideItemView:OnRegisterGameEvent()

end

function GuideItemView:OnRegisterBinder()

end

function GuideItemView:ItemClick()


end

return GuideItemView