---
--- Author: Administrator
--- DateTime: 2023-12-28 19:16
--- Description:
---

local UIUtil = require("Utils/UIUtil")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

local ChocoboMainVM = nil

---@class ChocoboGenealogyPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Avatar01 ChocoboGenealogyItemView
---@field Avatar02 ChocoboGenealogyItemView
---@field Avatar03 ChocoboGenealogyItemView
---@field Avatar04 ChocoboGenealogyItemView
---@field Avatar05 ChocoboGenealogyItemView
---@field Avatar06 ChocoboGenealogyItemView
---@field Avatar07 ChocoboGenealogyItemView
---@field Avatar08 ChocoboGenealogyItemView
---@field Avatar09 ChocoboGenealogyItemView
---@field Avatar10 ChocoboGenealogyItemView
---@field Avatar11 ChocoboGenealogyItemView
---@field Avatar12 ChocoboGenealogyItemView
---@field Avatar13 ChocoboGenealogyItemView
---@field Avatar14 ChocoboGenealogyItemView
---@field Avatar15 ChocoboGenealogyItemView
---@field Avatar16 ChocoboGenealogyItemView
---@field Avatar17 ChocoboGenealogyItemView
---@field Avatar18 ChocoboGenealogyItemView
---@field Avatar19 ChocoboGenealogyItemView
---@field Avatar20 ChocoboGenealogyItemView
---@field TableViewGeneration UTableView
---@field AnimBGLoop UWidgetAnimation
---@field AnimChangeTab UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboGenealogyPanelView = LuaClass(UIView, true)

function ChocoboGenealogyPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Avatar01 = nil
	--self.Avatar02 = nil
	--self.Avatar03 = nil
	--self.Avatar04 = nil
	--self.Avatar05 = nil
	--self.Avatar06 = nil
	--self.Avatar07 = nil
	--self.Avatar08 = nil
	--self.Avatar09 = nil
	--self.Avatar10 = nil
	--self.Avatar11 = nil
	--self.Avatar12 = nil
	--self.Avatar13 = nil
	--self.Avatar14 = nil
	--self.Avatar15 = nil
	--self.Avatar16 = nil
	--self.Avatar17 = nil
	--self.Avatar18 = nil
	--self.Avatar19 = nil
	--self.Avatar20 = nil
	--self.TableViewGeneration = nil
	--self.AnimBGLoop = nil
	--self.AnimChangeTab = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboGenealogyPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Avatar01)
	self:AddSubView(self.Avatar02)
	self:AddSubView(self.Avatar03)
	self:AddSubView(self.Avatar04)
	self:AddSubView(self.Avatar05)
	self:AddSubView(self.Avatar06)
	self:AddSubView(self.Avatar07)
	self:AddSubView(self.Avatar08)
	self:AddSubView(self.Avatar09)
	self:AddSubView(self.Avatar10)
	self:AddSubView(self.Avatar11)
	self:AddSubView(self.Avatar12)
	self:AddSubView(self.Avatar13)
	self:AddSubView(self.Avatar14)
	self:AddSubView(self.Avatar15)
	self:AddSubView(self.Avatar16)
	self:AddSubView(self.Avatar17)
	self:AddSubView(self.Avatar18)
	self:AddSubView(self.Avatar19)
	self:AddSubView(self.Avatar20)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboGenealogyPanelView:OnInit()
	ChocoboMainVM = _G.ChocoboMainVM
	self.GenerationAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewGeneration, nil, nil)
	self.GenerationAdapter:SetOnSelectChangedCallback(self.OnGeneSelectChange)
end

function ChocoboGenealogyPanelView:OnDestroy()

end

function ChocoboGenealogyPanelView:OnShow()
	self.GenerationAdapter:SetSelectedIndex(1)
end

function ChocoboGenealogyPanelView:OnHide()
end

function ChocoboGenealogyPanelView:OnRegisterUIEvent()
end

function ChocoboGenealogyPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ChocoboGenealogyItemSelect, self.OnChocoboGenealogyItemSelect)
end

function ChocoboGenealogyPanelView:OnRegisterBinder()
	self.ViewModel = ChocoboMainVM:GetGenePanelVM()
	local Binders = {
		{ "GenerationTabList", UIBinderUpdateBindableList.New(self, self.GenerationAdapter) },
		{ "SelectGeneID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectGeneIDValueChanged) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function ChocoboGenealogyPanelView:OnGeneSelectChange(Index, ItemData, ItemView, IsByClick)
	self.ViewModel:OnGeneSelectChange(ItemData.ID)

	if IsByClick then
		self:PlayAnimation(self.AnimChangeTab)
	end
end

function ChocoboGenealogyPanelView:OnSelectGeneIDValueChanged(Value)
	local CurGeneDataList = self.ViewModel:GetCurGeneDataList()
	for i = 1, #self.SubViews do
		local SubVM = self.SubViews[i].ViewModel
		if SubVM ~= nil then
			SubVM:UpdateVM(CurGeneDataList[i])
		end
	end
	EventMgr:SendEvent(EventID.ChocoboGenealogyItemSelect)
end

function ChocoboGenealogyPanelView:OnChocoboGenealogyItemSelect(Params)
	if Params ~= nil and Params.IsByClick then
		UIViewMgr:ShowView(UIViewID.ChocoboRelationPageView, Params)
	end
end

return ChocoboGenealogyPanelView