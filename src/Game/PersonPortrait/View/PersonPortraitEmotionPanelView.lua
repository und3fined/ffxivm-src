---
--- Author: xingcaicao
--- DateTime: 2023-11-29 12:36
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

---@class PersonPortraitEmotionPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropDownListFilter CommDropDownListView
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonPortraitEmotionPanelView = LuaClass(UIView, true)

function PersonPortraitEmotionPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropDownListFilter = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonPortraitEmotionPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DropDownListFilter)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonPortraitEmotionPanelView:OnInit()
	self.TableAdapterList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectChangedItem, true)

	self.Binders = {
		{ "ShowingResItemVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterList) },
		{ "CurTab", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurTab) },
	}
end

function PersonPortraitEmotionPanelView:OnDestroy()

end

function PersonPortraitEmotionPanelView:OnShow()
	self.DropDownListFilter:UpdateItems(PersonPortraitDefine.EmotionFilterList)
end

function PersonPortraitEmotionPanelView:OnHide()
	self.CurIndex = nil
end

function PersonPortraitEmotionPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownListFilter, self.OnSelectionChangedDropDownList)
end

function PersonPortraitEmotionPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PersonPortraitResStatusUpdate, self.OnEventResStatusUpdate)
end

function PersonPortraitEmotionPanelView:OnRegisterBinder()
	self:RegisterBinders(PersonPortraitVM, self.Binders)
end

function PersonPortraitEmotionPanelView:OnValueChangedCurTab(Tab)
    if (Tab == TabTypes.Action) or (Tab == TabTypes.Emotion) then
		self.DropDownListFilter:ResetDropDown()
	end
end

function PersonPortraitEmotionPanelView:OnSelectionChangedDropDownList( Index )
	PersonPortraitVM:UdpateShowingResItemVMList(PersonPortraitVM.CurTab, Index)
	self.CurIndex = Index
end

function PersonPortraitEmotionPanelView:OnSelectChangedItem(Index, ItemData, ItemView)
	if Index then
		self.TableAdapterList:ScrollIndexIntoView(Index)
	end

	if ItemData then
		PersonPortraitVM:UpdateCurSelectID(ItemData.ID, ItemData.Type)
	end
end

function PersonPortraitEmotionPanelView:CancelSelectedEmotion()
	self.TableAdapterList:CancelSelected()
end

function PersonPortraitEmotionPanelView:OnEventResStatusUpdate()
	local Index = self.CurIndex
	if Index then
		PersonPortraitVM:UdpateShowingResItemVMList(PersonPortraitVM.CurTab, Index)
	end
end


return PersonPortraitEmotionPanelView