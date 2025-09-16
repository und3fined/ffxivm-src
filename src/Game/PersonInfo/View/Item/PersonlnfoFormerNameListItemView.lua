--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2024-11-01 11:22:12
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2024-11-01 11:23:07
FilePath: \Script\Game\PersonInfoNew\View\Item\PersonlnfoFormerNameListItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: Administrator
--- DateTime: 2024-11-01 11:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PersonlnfoFormerNameListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot_UIBP CommonRedDotView
---@field ImgLine UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonlnfoFormerNameListItemView = LuaClass(UIView, true)

function PersonlnfoFormerNameListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot_UIBP = nil
	--self.ImgLine = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonlnfoFormerNameListItemView:OnInit()
	self.Binders = {
		{ "ReddotID", UIBinderValueChangedCallback.New(self, nil, self.OnBinderRedDot) },
		{ "Name", 	UIBinderSetText.New(self, self.TextName) },
	}
end

function PersonlnfoFormerNameListItemView:OnBinderRedDot(V)
	if V then
		self.CommonRedDot_UIBP:SetRedDotIDByID(V)
	else
		self.CommonRedDot_UIBP:SetRedDotIDByID(0)
	end
end

function PersonlnfoFormerNameListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonlnfoFormerNameListItemView:OnShow()
	local Params = self.Params or {}

	if Params.Data and type(Params.Data) ~= "table" then
		self.TextName:SetText(Params.Data or "")
	end
end

function PersonlnfoFormerNameListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel or type(Params.Data) ~= "table" then
		return
	end

	self.ViewModel = ViewModel
	

	self:RegisterBinders(ViewModel, self.Binders)
end

return PersonlnfoFormerNameListItemView