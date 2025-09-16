---
--- Author: sammrli
--- DateTime: 2024-09-01 23:08
--- Description: 任务道具提交界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local EventID = require("Define/EventID")
local ItemDefine = require("Game/Item/ItemDefine")

local LSTR = _G.LSTR

---@class NewQuestPropPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnSView
---@field BtnDelete UFButton
---@field BtnSubmit CommBtnSView
---@field CommBackpack126Slot CommBackpack126SlotView
---@field CommSidebarFrameS CommSidebarFrameSView
---@field PanelCheck UFCanvasPanel
---@field PanelDelete UFCanvasPanel
---@field PanelSlot UFCanvasPanel
---@field TableViewList UTableView
---@field TextTaskName URichTextBox
---@field AnimCheckHide UWidgetAnimation
---@field AnimCheckShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewQuestPropPanelView = LuaClass(UIView, true)

function NewQuestPropPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnDelete = nil
	--self.BtnSubmit = nil
	--self.CommBackpack126Slot = nil
	--self.CommSidebarFrameS = nil
	--self.PanelCheck = nil
	--self.PanelDelete = nil
	--self.PanelSlot = nil
	--self.TableViewList = nil
	--self.TextTaskName = nil
	--self.AnimCheckHide = nil
	--self.AnimCheckShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewQuestPropPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSubmit)
	self:AddSubView(self.CommBackpack126Slot)
	self:AddSubView(self.CommSidebarFrameS)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewQuestPropPanelView:OnInit()
	self.OwnedItemsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.OwnedItemsAdapter:SetOnClickedCallback(self.OnOwnedItemClicked)
end

function NewQuestPropPanelView:OnDestroy()

end

function NewQuestPropPanelView:OnShow()
	-- title
	UIUtil.SetIsVisible(self.CommSidebarFrameS.ImgState, false)
	local CommonTitle = self.CommSidebarFrameS.CommonTitle
	CommonTitle.TextTitleName:SetText(LSTR(596001)) --596001("提交道具")
	CommonTitle:SetSubTitleIsVisible(false)
	CommonTitle:SetCommInforBtnIsVisible(false)

	self.BtnCancel:SetText(LSTR(10003))
	self.BtnSubmit:SetText(LSTR(596008)) --596008("提 交")

	if not self.Params or not self.Params.ViewModel then
		return
	end

	local VM = self.Params.ViewModel

	self.OwnedItemsAdapter:CancelSelected()
	self.Params.ViewModel:ResetData()

	self.IsCanSelected = VM.IsMagicsparNeed -- 需求:需要魔晶石装备的提交,开启选择
	if self.IsCanSelected then
		UIUtil.SetIsVisible(self.PanelCheck, true)
		self:PlayAnimation(self.AnimCheckShow)
		self.BtnSubmit:SetIsEnabled(false)
		UIUtil.SetIsVisible(self.PanelDelete, false)
		UIUtil.SetIsVisible(self.CommBackpack126Slot.Icon, false)
		UIUtil.SetIsVisible(self.CommBackpack126Slot.IconChoose, false)
		UIUtil.SetIsVisible(self.CommBackpack126Slot.RichTextLevel, false)
		UIUtil.SetIsVisible(self.CommBackpack126Slot.RichTextQuantity, false)
		--UIUtil.ImageSetBrushFromAssetPath(self.CommBackpack126Slot.ImgQuanlity, ItemDefine.ItemIconColorType[1])
		UIUtil.SetIsVisible(self.CommBackpack126Slot.PanelInfo, false)
	else
		self:AutoFillItem()
		UIUtil.SetIsVisible(self.PanelCheck, false)
		if VM:CheckReadyToSubmit() then
			self.BtnSubmit:SetIsEnabled(true)
		else
			self.BtnSubmit:SetIsEnabled(false)
		end
	end

	self:UpdateSelectedCont()
end

function NewQuestPropPanelView:OnHide(Params)
	if (Params ~= nil and Params.IsBreakTargetGetItem ~= nil and Params.IsBreakTargetGetItem) then
		--中断提交
		self:OnClickedCancel()
	end
end

function NewQuestPropPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClickedCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnSubmit.Button, self.OnClickedSubmit)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickedDelete)
	self.CommSidebarFrameS.BtnClose:SetCallback(self, self.OnClickedCancel)
end

function NewQuestPropPanelView:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.ErrorCode, self.OnGameEventErrorCode)
end

function NewQuestPropPanelView:OnRegisterBinder()
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

	local Binders = {
		{ "OwnedItemVMList", UIBinderUpdateBindableList.New(self, self.OwnedItemsAdapter) },
	}
	self:RegisterBinders(VM, Binders)
end

function NewQuestPropPanelView:AutoFillItem()
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

	local VMList = VM.OwnedItemVMList:GetItems()
	for _, ItemVM in ipairs(VMList) do
		local ItemSubmitInfo = VM.ItemToSubmit[ItemVM.ResID]
		if ItemSubmitInfo then
			local NumLeft = ItemSubmitInfo.RequiredNum - ItemSubmitInfo.SubmitNum
			local NewSubmitNum = math.min(NumLeft, ItemVM.Num)

			if NewSubmitNum > 0 and not ItemSubmitInfo.SubmitGIDMap[ItemVM.GID] then
				ItemSubmitInfo.SubmitNum = ItemSubmitInfo.SubmitNum + NewSubmitNum
				ItemSubmitInfo.SubmitGIDMap[ItemVM.GID] = NewSubmitNum
			end
		end
	end
end

function NewQuestPropPanelView:UpdateSelectedCont()
	if not self.Params or not self.Params.ViewModel then
		return
	end
	local SubmitNum = 0
	local VM = self.Params.ViewModel
	for _, ItemVM in pairs(VM.ItemToSubmit) do
		if ItemVM.SubmitNum and ItemVM.SubmitNum > 0 then
			SubmitNum = SubmitNum + 1
		end
	end
	local SubmitTip = LSTR(596002)..string.format(" %d/%d", SubmitNum, VM.RequiredItemVMList:Length()) --596002("请选择提交道具")
	self.TextTaskName:SetText(SubmitTip)
end

function NewQuestPropPanelView:OnClickedCancel()
	_G.EventMgr:SendEvent(EventID.QuestClosePropPanel)
	_G.NpcDialogMgr:EndInteraction()
	self:Hide()
end

function NewQuestPropPanelView:OnClickedSubmit()
	if self.Params == nil or self.Params.ViewModel == nil then return end
	local VM = self.Params.ViewModel

	local HQSubmitNQList, CollectItem = VM:GetSubmitItemInfo()

	VM:SubmitItem(CollectItem)
	if self.Params and self.Params.DialogOrSequenceID then
		local NeedWait = _G.QuestMgr:IsBlackScreenOnStopDialogOrSeq(self.Params.DialogOrSequenceID)
		if NeedWait then
			local FadeViewID = _G.UIViewID.CommonFadePanel
			local Params = {}
			Params.FadeColorType = 3
			Params.Duration = 1
			Params.bAutoHide = false
			_G.UIViewMgr:ShowView(FadeViewID, Params)
		end
	end
	--_G.NpcDialogMgr:EndInteraction()
	self:Hide()
end

function NewQuestPropPanelView:OnClickedDelete()
	if not self.Params or not self.Params.ViewModel then
		return
	end
	local VM = self.Params.ViewModel
	local VMList = VM.OwnedItemVMList:GetItems()
	for _, ItemVM in ipairs(VMList) do
		ItemVM:OnSelectedChange(false)
	end
	VM:ResetData()
	self.OwnedItemsAdapter:CancelSelected()

	UIUtil.SetIsVisible(self.CommBackpack126Slot.Icon, false)
	UIUtil.SetIsVisible(self.PanelDelete, false)
	--UIUtil.ImageSetBrushFromAssetPath(self.CommBackpack126Slot.ImgQuanlity, ItemDefine.ItemIconColorType[1])
	UIUtil.SetIsVisible(self.CommBackpack126Slot.PanelInfo, false)
	self.BtnSubmit:SetIsEnabled(false)
	self:UpdateSelectedCont()
end

function NewQuestPropPanelView:OnOwnedItemClicked(Index, ItemData, ItemView)
	if not self.IsCanSelected then
		return
	end

	if self.Params == nil or self.Params.ViewModel == nil or ItemData == nil then return end
	local VM = self.Params.ViewModel

	VM:ResetData()

	local VMList = VM.OwnedItemVMList:GetItems()
	for Idx, ItemVM in ipairs(VMList) do
		if Idx == Index then
			ItemVM:OnSelectedChange(true)
			UIUtil.SetIsVisible(self.CommBackpack126Slot.Icon, true)
			UIUtil.ImageSetBrushFromAssetPath(self.CommBackpack126Slot.Icon, ItemVM.Icon)
			UIUtil.ImageSetBrushFromAssetPath(self.CommBackpack126Slot.ImgQuanlity, ItemVM.ItemQualityIcon)
			UIUtil.SetIsVisible(self.PanelDelete, true)
			UIUtil.SetIsVisible(self.CommBackpack126Slot.PanelInfo, true)
		else
			ItemVM:OnSelectedChange(false)
		end
	end

	local ItemSubmitInfo = VM.ItemToSubmit[ItemData.ResID]
	if ItemSubmitInfo then
		local NumLeft = ItemSubmitInfo.RequiredNum - ItemSubmitInfo.SubmitNum
		local NewSubmitNum = math.min(NumLeft, ItemData.Num)

		if NewSubmitNum > 0 and not ItemSubmitInfo.SubmitGIDMap[ItemData.GID] then
			ItemSubmitInfo.SubmitNum = ItemSubmitInfo.SubmitNum + NewSubmitNum
			ItemSubmitInfo.SubmitGIDMap[ItemData.GID] = NewSubmitNum
		end
	end

	self:UpdateSelectedCont()

	if VM:CheckReadyToSubmit() then
		self.BtnSubmit:SetIsEnabled(true)
	end
end


return NewQuestPropPanelView