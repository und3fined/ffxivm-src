---
--- Author: Administrator
--- DateTime: 2024-01-30 10:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class PhotoPageTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgSelect UFImage
---@field TextTabName UFTextBlock
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoPageTabItemView = LuaClass(UIView, true)

function PhotoPageTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgSelect = nil
	--self.TextTabName = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoPageTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoPageTabItemView:OnInit()
	self.Binders = 
	{
		{ "IsSelected", 			UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "Name", 					UIBinderSetText.New(self, self.TextTabName) },
	}
end

function PhotoPageTabItemView:OnDestroy()

end

function PhotoPageTabItemView:OnShow()
	UIUtil.SetIsVisible(self.RedDot, false)
end

function PhotoPageTabItemView:OnHide()

end

function PhotoPageTabItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,              self.Btn,             self.OnBtn)
end

function PhotoPageTabItemView:OnRegisterGameEvent()

end

function PhotoPageTabItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function PhotoPageTabItemView:OnBtn()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Adapter = Params.Adapter
    if nil == Adapter then
        return
    end

	Adapter:OnItemClicked(self, Params.Index)
end

function PhotoPageTabItemView:OnSelectChanged(IsSelected)
	self.ViewModel.IsSelected = IsSelected

	-- local TextCol = IsSelected and "fff4d0ff" or "fefefe99"
	-- UIUtil.SetColorAndOpacityHex(self.TextTabName, TextCol)

	if IsSelected then
		self:PlayAnimation(self.AnimCheck)
	else
		self:PlayAnimation(self.AnimUnCheck)
	end
end


return PhotoPageTabItemView