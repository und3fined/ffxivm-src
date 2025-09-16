---
--- Author: xingcaicao
--- DateTime: 2023-10-16 16:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")

---@class PersonInfoFuncBtnItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFunction CommBtnLView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoFuncBtnItemView = LuaClass(UIView, true)

function PersonInfoFuncBtnItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFunction = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoFuncBtnItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnFunction)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoFuncBtnItemView:OnInit()
	self.Binders = {
		{ "Name", 			UIBinderSetText.New(self, self.BtnFunction.TextContent) },
	}
end

function PersonInfoFuncBtnItemView:OnDestroy()

end

function PersonInfoFuncBtnItemView:OnShow()

end

function PersonInfoFuncBtnItemView:OnHide()

end

function PersonInfoFuncBtnItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFunction, self.OnClickButtonFunction)
end

function PersonInfoFuncBtnItemView:OnRegisterGameEvent()

end

function PersonInfoFuncBtnItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel 
	self:RegisterBinders(ViewModel, self.Binders)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function PersonInfoFuncBtnItemView:OnClickButtonFunction()
	PersonInfoVM:SimpleViewOnClickButtonFunction(self.ViewModel)
end

return PersonInfoFuncBtnItemView