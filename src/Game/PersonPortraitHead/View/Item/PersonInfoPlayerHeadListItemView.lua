---
--- Author: Administrator
--- DateTime: 2024-09-27 15:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PersonPortraitHeadHelper = require("Game/PersonPortraitHead/PersonPortraitHeadHelper")

---@class PersonInfoPlayerHeadListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PersonInfoPlayerHead PersonInfoPlayerHeadItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoPlayerHeadListItemView = LuaClass(UIView, true)

function PersonInfoPlayerHeadListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PersonInfoPlayerHead = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoPlayerHeadListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PersonInfoPlayerHead)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoPlayerHeadListItemView:OnInit()
	self.Binders = {
		{ "HeadIconUrl", 	UIBinderValueChangedCallback.New(self, nil, self.OnValChgUrl) },
	}
end

function PersonInfoPlayerHeadListItemView:OnDestroy()

end

function PersonInfoPlayerHeadListItemView:OnShow()

end

function PersonInfoPlayerHeadListItemView:OnHide()

end

function PersonInfoPlayerHeadListItemView:OnRegisterUIEvent()

end

function PersonInfoPlayerHeadListItemView:OnRegisterGameEvent()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.VM = Params.Data
	self:RegisterBinders(self.VM, self.Binders)
end

function PersonInfoPlayerHeadListItemView:OnRegisterBinder()

end

function PersonInfoPlayerHeadListItemView:OnValChgUrl(Val)
	if string.isnilorempty(Val) then
		return
	end

	PersonPortraitHeadHelper.SetHeadByUrl(self.PersonInfoPlayerHead.ImgPlayer, Val, 'PersonInfoPlayerHeadListItemView::OnValChgUrl')
end

return PersonInfoPlayerHeadListItemView