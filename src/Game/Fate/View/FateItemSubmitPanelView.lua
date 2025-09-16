---
--- Author: Rock
--- DateTime: 2023-12-18 14:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local OPAQUE = 1
local TRANSLUCENT = 0.5

---@class FateItemSubmitPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn_Cancel CommBtnMView
---@field Btn_Close CommonCloseBtnView
---@field Btn_Submit CommBtnMView
---@field FText_HQTips UFTextBlock
---@field ItemTips UFCanvasPanel
---@field ItemTipsContent ItemTipsFrameNewView
---@field TableView_Porp UTableView
---@field TableView_QuestList UTableView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateItemSubmitPanelView = LuaClass(UIView, true)

function FateItemSubmitPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn_Cancel = nil
	--self.Btn_Close = nil
	--self.Btn_Submit = nil
	--self.FText_HQTips = nil
	--self.ItemTips = nil
	--self.ItemTipsContent = nil
	--self.TableView_Porp = nil
	--self.TableView_QuestList = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateItemSubmitPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn_Cancel)
	self:AddSubView(self.Btn_Close)
	self:AddSubView(self.Btn_Submit)
	self:AddSubView(self.ItemTipsContent)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateItemSubmitPanelView:OnInit()
	self.RequiredItemsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_QuestList)
	self.OwnedItemsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_Porp)

	self.RequiredItemsAdapter:SetOnClickedCallback(self.OnRequiredItemClicked)
	self.OwnedItemsAdapter:SetOnClickedCallback(self.OnOwnedItemClicked)
end

function FateItemSubmitPanelView:OnShow()
	self.Btn_Submit:SetIsEnabled(true)
	UIUtil.SetIsVisible(self.ItemTips, false)

	self.RequiredItemsAdapter:CancelSelected()
	self.OwnedItemsAdapter:CancelSelected()

	self:UpdateRequiredItemList(nil, OPAQUE, false)
	self:UpdateOwnedItemList(nil, OPAQUE,false)
end

function FateItemSubmitPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn_Cancel.Button, self.OnClickedCancel)
	UIUtil.AddOnClickedEvent(self, self.Btn_Submit.Button, self.OnClickedSubmit)
end

function FateItemSubmitPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function FateItemSubmitPanelView:OnRegisterBinder()
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

	local Binders = {
		{ "RequiredItemVMList", UIBinderUpdateBindableList.New(self, self.RequiredItemsAdapter) },
		{ "OwnedItemVMList", UIBinderUpdateBindableList.New(self, self.OwnedItemsAdapter) },
	}
	self:RegisterBinders(VM, Binders)
end

function FateItemSubmitPanelView:OnClickedCancel()
	self:Hide()
end

function FateItemSubmitPanelView:OnClickedSubmit()
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel
	VM:SubmitItem()
	self:Hide()
end

function FateItemSubmitPanelView:ShowItemTip(ItemData)
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

	local ItemDataParams = {
		GID = -1,
		ResID = ItemData.ResID,
	}
	VM.ItemTipsVMData:UpdateVM(ItemDataParams)
	self.ItemTipsContent:HideView()
	self.ItemTipsContent:ShowView({ ItemData = ItemData })
	UIUtil.SetIsVisible(self.ItemTips, true)
end

function FateItemSubmitPanelView:OnPreprocessedMouseButtonDown(MouseEvent)
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local MousePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.ItemTips, MousePosition) == false then
		UIUtil.SetIsVisible(self.ItemTips, false)
	end
end

function FateItemSubmitPanelView:OnRequiredItemClicked(_, ItemData, _)
	if ItemData == nil then return end
	self.OwnedItemsAdapter:CancelSelected()
	self:UpdateRequiredItemList(ItemData, OPAQUE, true)
	self:ShowItemTip(ItemData)
end

function FateItemSubmitPanelView:OnOwnedItemClicked(_, ItemData, _)
	if ItemData == nil then return end
	self.RequiredItemsAdapter:CancelSelected()
	self:UpdateOwnedItemList(ItemData, OPAQUE, true)
	self:ShowItemTip(ItemData)
end

---@param ItemData FateItemSubmitInfoVM | nil
---@param Opacity number
function FateItemSubmitPanelView:UpdateRequiredItemList(ItemData, Opacity, bShowUnselect)
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

    for _, RequiredVM in ipairs(VM.RequiredItemVMList:GetItems()) do
        if (ItemData ~= nil and ItemData.ResID == RequiredVM.ResID) then
            RequiredVM:SetItemOpacity(Opacity)
		-- RequiredVM.IsSelect = bShowUnselect  需求不用选中效果了
		-- RequiredVM.NumVisible = false
        end
    end
end

---@param ItemData FateItemSubmitInfoVM | nil
---@param Opacity number
function FateItemSubmitPanelView:UpdateOwnedItemList(ItemData, Opacity, bShowUnselect)
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

    for _, OwnedVM in ipairs(VM.OwnedItemVMList:GetItems()) do
	if (ItemData ~= nil and ItemData.ResID == OwnedVM.ResID) then
		OwnedVM:SetItemOpacity(Opacity)
		-- OwnedVM.IsSelect = bShowUnselect  需求不用选中效果了
		-- OwnedVM.NumVisible = false
	end
    end
end

return FateItemSubmitPanelView