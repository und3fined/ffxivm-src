---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:12
--- Description:
---


local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderSetCheckedState =  require("Binder/UIBinderSetCheckedState")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local AchievementDefine = require("Game/Achievement/AchievementDefine")


---@class Achievement2ndTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot_UIBP_49 CommonRedDotView
---@field Img2ndBg UFImage
---@field Img2ndBottomBg UFImage
---@field ImgLine UFImage
---@field TextContent UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Achievement2ndTabItemView = LuaClass(UIView, true)

function Achievement2ndTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot_UIBP_49 = nil
	--self.Img2ndBg = nil
	--self.Img2ndBottomBg = nil
	--self.ImgLine = nil
	--self.TextContent = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Achievement2ndTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot_UIBP_49)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Achievement2ndTabItemView:OnInit()
	self.TypeID = 0
	self.CategoryID = 0

	self.Binders = {
		{ "CategoryID", UIBinderValueChangedCallback.New(self, nil, self.OnCategoryIDChanged) },
		{ "TextContent", UIBinderSetText.New(self, self.TextContent) },
		{ "ToggleBtnState", UIBinderSetCheckedState.New(self, self.ToggleBtn) },
		--{ "SelectCategoryID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectCategoryIDChanged)  }
	}
end

function Achievement2ndTabItemView:OnDestroy()

end

function Achievement2ndTabItemView:OnShow()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
end

function Achievement2ndTabItemView:OnHide()

end

function Achievement2ndTabItemView:OnRegisterUIEvent()

end

function Achievement2ndTabItemView:OnRegisterGameEvent()

end

function Achievement2ndTabItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function Achievement2ndTabItemView:OnCategoryIDChanged()
	local ViewModel = self.ViewModel
	if ViewModel ~= nil then 
		self.CommonRedDot_UIBP_49:SetRedDotNameByString(AchievementDefine.RedDotName .. '/' .. tostring(ViewModel.TypeID) .. '/' .. tostring(ViewModel.CategoryID))
	else
		self.CommonRedDot_UIBP_49:SetRedDotNameByString("")
	end
end

return Achievement2ndTabItemView