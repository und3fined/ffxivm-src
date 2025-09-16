---
--- Author: lydianwang
--- DateTime: 2022-08-23 16:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local BagMgr = require("Game/Bag/BagMgr")
local CommonUtil = require("Utils/CommonUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local OPAQUE = 1
local TRANSLUCENT = 0.5
local MsgBoxTitle = nil -- 不显示Title
local MsgBoxContent = _G.LSTR(596007) --596007("所提交物品中包含优质道具，确定要提交吗？")

---@class QuestPropPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn_Cancel CommBtnMView
---@field Btn_Close CommonCloseBtnView
---@field Btn_Submit CommBtnMView
---@field FText_HQTips UFTextBlock
---@field ItemTips UFCanvasPanel
---@field ItemTipsContent ItemTipsFrameNewView
---@field PopUpBGHideItemTips CommonPopUpBGView
---@field TableView_Porp UTableView
---@field TableView_QuestList UTableView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local QuestPropPanelView = LuaClass(UIView, true)

function QuestPropPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn_Cancel = nil
	--self.Btn_Close = nil
	--self.Btn_Submit = nil
	--self.FText_HQTips = nil
	--self.ItemTips = nil
	--self.ItemTipsContent = nil
	--self.PopUpBGHideItemTips = nil
	--self.TableView_Porp = nil
	--self.TableView_QuestList = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function QuestPropPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn_Cancel)
	self:AddSubView(self.Btn_Close)
	self:AddSubView(self.Btn_Submit)
	self:AddSubView(self.ItemTipsContent)
	self:AddSubView(self.PopUpBGHideItemTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function QuestPropPanelView:OnInit()
	self.RequiredItemsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_QuestList)
	self.OwnedItemsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_Porp)

	self.RequiredItemsAdapter:SetOnClickedCallback(self.OnRequiredItemClicked)
	self.OwnedItemsAdapter:SetOnClickedCallback(self.OnOwnedItemClicked)
	self.PopUpBGHideItemTips:SetCallback(self, self.OnPopUpBGHideItemTipsClicked)

	self.RequiredItemsAdapter.OnClickedUnselect = function(_, Index, ItemData, ItemView)
		self:OnRequiredItemCanceled(Index, ItemData, ItemView)
	end
end

-- function QuestPropPanelView:OnDestroy()
-- end

function QuestPropPanelView:OnShow()
	self.Btn_Submit:SetIsEnabled(false)
	self.RequiredItemsAdapter:CancelSelected()
	self.OwnedItemsAdapter:CancelSelected()

	self:SetRequiredItemShowUnselect(nil, false)
	self:SetRequiredItemOpacity(nil, TRANSLUCENT)
	self:SetOwnedItemOpacity(nil, OPAQUE)
	self.Params.ViewModel:ResetData()
	self.Btn_Close:SetCallback(self, function()
		_G.NpcDialogMgr:EndInteraction()
		self:Hide()
	end)
    -- 自动填充任务所需道具
	self:AutoFillItem()
	UIUtil.SetIsVisible(self.ItemTips, false)
	UIUtil.SetIsVisible(self.PopUpBGHideItemTips, false)
end

function QuestPropPanelView:OnHide(Params)
	if (Params ~= nil and Params.IsBreakTargetGetItem ~= nil and Params.IsBreakTargetGetItem) then
		--中断提交
		self:OnClickedCancel()
	end
end

function QuestPropPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn_Cancel.Button, self.OnClickedCancel)
	UIUtil.AddOnClickedEvent(self, self.Btn_Submit.Button, self.OnClickedSubmit)
end

-- function QuestPropPanelView:OnRegisterGameEvent()
-- end

function QuestPropPanelView:OnRegisterBinder()
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

	local Binders = {
		{ "RequiredItemVMList", UIBinderUpdateBindableList.New(self, self.RequiredItemsAdapter) },
		{ "OwnedItemVMList", UIBinderUpdateBindableList.New(self, self.OwnedItemsAdapter) },
		{ "bHQTipsVisible", UIBinderSetIsVisible.New(self, self.FText_HQTips) },
	}
	self:RegisterBinders(VM, Binders)
end

function QuestPropPanelView:OnClickedCancel()
	_G.NpcDialogMgr:EndInteraction()
	self:Hide()
end

function QuestPropPanelView:OnClickedSubmit()
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

	local HQSubmitNQList, CollectItem = VM:GetSubmitItemInfo()

	local function DoSubmitItem()
		VM:SubmitItem(CollectItem)
		self:Hide()
	end

	if next(HQSubmitNQList) == nil then
		DoSubmitItem()
	else
		self:ShowHQConfirmMsgBox(HQSubmitNQList, DoSubmitItem)
	end
end

function QuestPropPanelView:ShowHQConfirmMsgBox(HQSubmitNQList, ConfirmCallback)
	local HQNameListStr = nil
	for _, ResID in ipairs(HQSubmitNQList) do
		local HQName = ItemCfg:FindValue(ResID, "ItemName") or "None"
		HQNameListStr = (HQNameListStr == nil)
			and HQName
			or string.format("%s, %s", HQNameListStr, HQName)
	end
	HQNameListStr = CommonUtil.GetTextFromStringWithSpecialCharacter(HQNameListStr)
	MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle,
		string.format("%s\n%s", MsgBoxContent, HQNameListStr),
		ConfirmCallback)
end

function QuestPropPanelView:ShowItemTip(ItemData)
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

	local ItemDataParams = {
		GID = -1,
		ResID = ItemData.ResID,
	}
	if VM:CheckCurrItemNotEqualToVM(ItemDataParams) then
		VM.ItemTipsVMData:UpdateVM(ItemDataParams)
		self.ItemTipsContent:HideView()
		self.ItemTipsContent:ShowView({ ItemData = ItemData })
	end
	UIUtil.SetIsVisible(self.ItemTips, true)
	UIUtil.SetIsVisible(self.PopUpBGHideItemTips, true)
end

function QuestPropPanelView:OnRequiredItemClicked(_, ItemData, _)
	if ItemData == nil then return end

	self.OwnedItemsAdapter:CancelSelected()
	self:ShowItemTip(ItemData)
end

function QuestPropPanelView:OnRequiredItemCanceled(_, ItemData, _)
	if self.Params == nil or self.Params.ViewModel == nil or ItemData == nil then return end
	local VM = self.Params.ViewModel

	VM:ResetSubmitItem(ItemData.ResID)
	self.RequiredItemsAdapter:CancelSelected()
	self.OwnedItemsAdapter:CancelSelected()
	UIUtil.SetIsVisible(self.ItemTips, false)

	self:SetRequiredItemShowUnselect(ItemData, false)
	ItemData:SetItemOpacity(TRANSLUCENT)
	self:SetOwnedItemOpacity(ItemData, OPAQUE)

	VM:ResetHQTipsVisibility()

	self.Btn_Submit:SetIsEnabled(false)
end

function QuestPropPanelView:OnOwnedItemClicked(_, ItemData, _)
	if self.Params == nil or self.Params.ViewModel == nil or ItemData == nil then return end
	local VM = self.Params.ViewModel

	self.RequiredItemsAdapter:CancelSelected()
	self:ShowItemTip(ItemData)

	local ItemSubmitInfo = VM.ItemToSubmit[ItemData.ResID]
	if (ItemSubmitInfo == nil) then
		-- 点击HQ时看能不能找到并提交给对应NQ
		local NQHQItemID = BagMgr:GetItemNQHQItemID(ItemData.ResID)
		ItemSubmitInfo = VM.ItemToSubmit[NQHQItemID]
		if (ItemSubmitInfo == nil)
		or (ItemSubmitInfo.SubmitNum == ItemSubmitInfo.RequiredNum)
		or (ItemSubmitInfo.NQToHQ <= 0) then
			return
		end
		ItemSubmitInfo.bHQSubmitNQ = true
	end

	VM:ResetHQTipsVisibility()

	if VM:CheckReadyToSubmit() then
		return
	end

	local NumLeft = ItemSubmitInfo.RequiredNum - ItemSubmitInfo.SubmitNum
	local NewSubmitNum = math.min(NumLeft, ItemData.Num)

	if (NewSubmitNum > 0) and (ItemSubmitInfo.SubmitGIDMap[ItemData.GID] == nil) then
		ItemSubmitInfo.SubmitNum = ItemSubmitInfo.SubmitNum + NewSubmitNum
		ItemSubmitInfo.SubmitGIDMap[ItemData.GID] = NewSubmitNum

		ItemData:SetItemOpacity(TRANSLUCENT)
		if ItemSubmitInfo.SubmitNum > 0 then
			self:SetRequiredItemShowUnselect(ItemData, true)
		end
		if ItemSubmitInfo.SubmitNum >= ItemSubmitInfo.RequiredNum then
			self:SetRequiredItemOpacity(ItemData, OPAQUE)
		end
	end

	if VM:CheckReadyToSubmit() then
		self.Btn_Submit:SetIsEnabled(true)
	end
end

function QuestPropPanelView:OnPopUpBGHideItemTipsClicked()
	self.RequiredItemsAdapter:CancelSelected()
	self.OwnedItemsAdapter:CancelSelected()

	UIUtil.SetIsVisible(self.ItemTips, false)
	UIUtil.SetIsVisible(self.PopUpBGHideItemTips, false)
end

---@param ItemData QuestSubmitItemVM | nil
---@param bShowUnselect boolean
function QuestPropPanelView:SetRequiredItemShowUnselect(ItemData, bShowUnselect)
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

    for _, RequiredVM in ipairs(VM.RequiredItemVMList:GetItems()) do
        if (ItemData == nil)
		or (RequiredVM.ResID == ItemData.ResID)
		or (RequiredVM.ResID == BagMgr:GetItemNQHQItemID(ItemData.ResID)) then
            RequiredVM.bShowUnselect = bShowUnselect
        end
    end
end

---@param ItemData QuestSubmitItemVM | nil
---@param Opacity number
function QuestPropPanelView:SetRequiredItemOpacity(ItemData, Opacity)
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

    for _, RequiredVM in ipairs(VM.RequiredItemVMList:GetItems()) do
        if (ItemData == nil)
		or (RequiredVM.ResID == ItemData.ResID)
		or (RequiredVM.ResID == BagMgr:GetItemNQHQItemID(ItemData.ResID)) then
            RequiredVM:SetItemOpacity(Opacity)
        end
    end
end

---@param ItemData QuestSubmitItemVM | nil
---@param Opacity number
function QuestPropPanelView:SetOwnedItemOpacity(ItemData, Opacity)
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

    for _, OwnedVM in ipairs(VM.OwnedItemVMList:GetItems()) do
        if (ItemData == nil)
		or (OwnedVM.ResID == ItemData.ResID)
		or (OwnedVM.ResID == BagMgr:GetItemNQHQItemID(ItemData.ResID)) then
            OwnedVM:SetItemOpacity(Opacity)
        end
    end
end

function QuestPropPanelView:AutoFillItem()
	local VM = self.Params.ViewModel
	
	if VM:CheckReadyToSubmit() then return end

	for _, RequireItemVM in ipairs(VM.RequiredItemVMList:GetItems()) do
		local RequiredItemResID = RequireItemVM.ResID
		local ItemSubmitInfo = VM.ItemToSubmit[RequiredItemResID]

		-- 如果要求NQ道具则寻找NQ，要求HQ则找HQ
		self:SimulateClickItem(RequiredItemResID)
		
		-- 如果要求NQ但不够数量，则寻找HQ
		-- 如果要求HQ，则上方已遍历完，这里跳过
		if ItemSubmitInfo.SubmitNum < ItemSubmitInfo.RequiredNum
		and ItemSubmitInfo.NQToHQ ~= 0
		and ItemSubmitInfo.NQToHQ ~= RequiredItemResID then
			self:SimulateClickItem(ItemSubmitInfo.NQToHQ)
		end

		if VM:CheckReadyToSubmit() then break end
	end

	self.RequiredItemsAdapter:CancelSelected()
	self.OwnedItemsAdapter:CancelSelected()
	-- UIUtil.SetIsVisible(self.ItemTips, false)
	-- UIUtil.SetIsVisible(self.PopUpBGHideItemTips, false)
end

function QuestPropPanelView:SimulateClickItem(ItemResID)
	local VMList = self.Params.ViewModel.OwnedItemVMList:GetItems()
	for Index, ItemVM in ipairs(VMList) do
		local OwnItemResID = ItemVM.ResID
		if ItemResID == OwnItemResID then
			-- 此界面OnShow时，Table里的东西还没Show，手动调用函数模拟点击
			self.OwnedItemsAdapter:SetSelectedIndex(Index)
			self:OnOwnedItemClicked(nil, ItemVM, nil)
		end
	end
end

return QuestPropPanelView