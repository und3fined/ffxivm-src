---
--- Author: xingcaicao
--- DateTime: 2023-11-29 12:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local TabTypes = PersonPortraitDefine.TabTypes

---@class PersonPortraitDecoratePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropDownListFilter CommDropDownListView
---@field ListPanel UFCanvasPanel
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonPortraitDecoratePanelView = LuaClass(UIView, true)

function PersonPortraitDecoratePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropDownListFilter = nil
	--self.ListPanel = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonPortraitDecoratePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DropDownListFilter)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonPortraitDecoratePanelView:OnInit()
	self.TempMargin = _G.UE.FMargin()
	self.ListSrcOffsets = UIUtil.CanvasSlotGetOffsets(self.TableViewList)

	self.TableAdapterList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectChangedItem, true)

	self.Binders = {
		{ "ShowingResItemVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterList) },
		{ "CurTab", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurTab) },
	}
end

function PersonPortraitDecoratePanelView:OnDestroy()

end

function PersonPortraitDecoratePanelView:OnShow()
	self.DropDownListFilter:UpdateItems(PersonPortraitDefine.DesignFilterList)
end

function PersonPortraitDecoratePanelView:OnHide()
	self.CurIndex = nil
end

function PersonPortraitDecoratePanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownListFilter, self.OnSelectionChangedDropDownList)
end

function PersonPortraitDecoratePanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PersonPortraitResStatusUpdate, self.OnEventResStatusUpdate)
end

function PersonPortraitDecoratePanelView:OnRegisterBinder()
	self:RegisterBinders(PersonPortraitVM, self.Binders)
end

function PersonPortraitDecoratePanelView:OnValueChangedCurTab(Tab)
    if nil == Tab or (1 << Tab) & TabTypes.Design == 0 then
		return
	end

	-- 过滤下拉框
	local FilterVisible = Tab ~= TabTypes.PreDesign
	UIUtil.SetIsVisible(self.DropDownListFilter.Object, FilterVisible)

	local Offsets = self.ListSrcOffsets
	if Offsets then
		local Margin = self.TempMargin
		Margin.Left = Offsets.Left
		Margin.Top = Offsets.Top
		Margin.Right = Offsets.Right

		local Bottom = Offsets.Bottom
		Margin.Bottom = FilterVisible and Bottom or (Bottom - 82)

		UIUtil.CanvasSlotSetOffsets(self.TableViewList, Margin)
	end

	self.DropDownListFilter:ResetDropDown()
end

function PersonPortraitDecoratePanelView:OnSelectionChangedDropDownList( Index )
	PersonPortraitVM:UdpateShowingResItemVMList(PersonPortraitVM.CurTab, Index)
	self.CurIndex = Index
end

function PersonPortraitDecoratePanelView:OnSelectChangedItem(Index, ItemData, ItemView)
	if Index then
		self.TableAdapterList:ScrollIndexIntoView(Index)
	end

	if ItemData then
		PersonPortraitVM:UpdateCurSelectID(ItemData.ID, ItemData.Type)
		PersonPortraitVM:AddReadRedDotID(ItemData.RedDotID)
	end
end

function PersonPortraitDecoratePanelView:CancelSelectedItem()
	self.TableAdapterList:CancelSelected()
end

function PersonPortraitDecoratePanelView:OnEventResStatusUpdate()
	local Index = self.CurIndex
	if Index then
		PersonPortraitVM:UdpateShowingResItemVMList(PersonPortraitVM.CurTab, Index)
	end
end

return PersonPortraitDecoratePanelView