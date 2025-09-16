---
--- Author: Administrator
--- DateTime: 2023-09-12 15:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BagMedicineSetWinVM = require("Game/NewBag/VM/BagMedicineSetWinVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MajorUtil = require("Utils/MajorUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ClientSetupKey = ProtoCS.ClientSetupKey
local BagMgr = _G.BagMgr
local ActorMgr = _G.ActorMgr
local EventID = _G.EventID
local ClientSetupMgr = _G.ClientSetupMgr
local LSTR = _G.LSTR
---@class NewBagMedicineSetWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackEmpty CommBackpackEmptyView
---@field BagDrugTips NewBagMedicineTipsView
---@field BtnCancel CommBtnLView
---@field BtnDrugs UFCanvasPanel
---@field BtnReplace CommBtnLView
---@field BtnSet CommBtnLView
---@field Comm2FrameL Comm2FrameLView
---@field TableViewItem UTableView
---@field TableView_54 UTableView
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagMedicineSetWinView = LuaClass(UIView, true)

function NewBagMedicineSetWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackEmpty = nil
	--self.BagDrugTips = nil
	--self.BtnCancel = nil
	--self.BtnDrugs = nil
	--self.BtnReplace = nil
	--self.BtnSet = nil
	--self.Comm2FrameL = nil
	--self.TableViewItem = nil
	--self.TableView_54 = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagMedicineSetWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackEmpty)
	self:AddSubView(self.BagDrugTips)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnReplace)
	self:AddSubView(self.BtnSet)
	self:AddSubView(self.Comm2FrameL)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagMedicineSetWinView:OnInit()
	self.ProfTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_54)
	self.ProfTableViewAdapter:SetOnClickedCallback(self.OnProfItemClicked)
	
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItem)
	self.TableViewAdapter:SetOnClickedCallback(self.OnItemClicked)

	self.Binders = {
		{ "NoneTipsVisible", UIBinderSetIsVisible.New(self, self.BackpackEmpty) },
		{ "ProfBindableList", UIBinderUpdateBindableList.New(self, self.ProfTableViewAdapter) },
		{ "MedicineBindableList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{ "DrugTipsVisible", UIBinderSetIsVisible.New(self, self.BagDrugTips) },
		{ "DrugTipsVisible", UIBinderSetIsVisible.New(self, self.BtnDrugs) },

		{ "SetBtnVisible", UIBinderSetIsVisible.New(self, self.BtnSet) },
		{ "ReplaceBtnVisible", UIBinderSetIsVisible.New(self, self.BtnReplace) },
		{ "CancelBtnVisible", UIBinderSetIsVisible.New(self, self.BtnCancel) },
	}
end

function NewBagMedicineSetWinView:OnDestroy()

end

function NewBagMedicineSetWinView:OnShow()
	BagMedicineSetWinVM:SetProList()

	local MajorIndex = BagMedicineSetWinVM:GetMajorIndex()
	if MajorIndex > 0 then
		self.ProfTableViewAdapter:SetSelectedIndex(MajorIndex)
		self.ProfTableViewAdapter:ScrollToIndex(MajorIndex)
	else
		self.ProfTableViewAdapter:ScrollToTop()
	end

	local MajorProfID = MajorUtil.GetMajorProfID()
	self.ProfID = MajorProfID
	BagMedicineSetWinVM:SetSelectedProf(MajorProfID)

	BagMedicineSetWinVM:UpdateMedicineBindableList(MajorProfID)
	BagMedicineSetWinVM:SetCurItemIndex(1)

	self:SetCurItemInfo(BagMedicineSetWinVM:GetCurItem())
end

function NewBagMedicineSetWinView:OnHide()

end

function NewBagMedicineSetWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSet.Button, self.OnClickedSetBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnReplace.Button, self.OnClickedSetBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClickedCancelBtn)
end

function NewBagMedicineSetWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BagUpdate, self.OnUpdateMedicineSetWin)
end

function NewBagMedicineSetWinView:OnRegisterBinder()
	self:RegisterBinders(BagMedicineSetWinVM, self.Binders)

	self.Comm2FrameL:SetTitleText(LSTR(990087))
	self.BackpackEmpty:SetTipsContent(LSTR(990088))
	self.BtnSet:SetButtonText(LSTR(990089))
	self.BtnReplace:SetButtonText(LSTR(990090))
	self.BtnCancel:SetButtonText(LSTR(990091))
end

function NewBagMedicineSetWinView:OnProfItemClicked(Index, ItemData, ItemView)
	local Active = ItemData.bActive
	if Active == true then
		local ProfID = ItemData.ProfID
		if ProfID and self.ProfID ~= ProfID then
			self.ProfID = ProfID
			BagMedicineSetWinVM:SetSelectedProf(ProfID)
			BagMedicineSetWinVM:UpdateMedicineBindableList(ProfID)
			BagMedicineSetWinVM:SetCurItemIndex(1)
			self:SetCurItemInfo(BagMedicineSetWinVM:GetCurItem())
			self:PlayAnimation(self.AnimUpdate)
		end

	end
	
end

function NewBagMedicineSetWinView:OnUpdateMedicineSetWin()
	BagMedicineSetWinVM:SetProList()

	local ProfID = self.ProfID
	if ProfID then
		BagMedicineSetWinVM:SetSelectedProf(ProfID)
		BagMedicineSetWinVM:UpdateMedicineBindableList(ProfID)
	end

	local CurItem = BagMedicineSetWinVM:GetCurItem()
	--当前物品为空则默认选中第一个物品
	if CurItem == nil then
		BagMedicineSetWinVM:SetCurItemIndex(1)
		self:SetCurItemInfo(BagMedicineSetWinVM:GetCurItem())
	else
		BagMedicineSetWinVM:SetCurItemIndex(BagMedicineSetWinVM.ItemIndex)
		self:SetCurItemInfo(CurItem)
	end
end

function NewBagMedicineSetWinView:OnItemClicked(Index, ItemData, ItemView)
	BagMedicineSetWinVM:SetCurItemIndex(Index)
	local CurItem = BagMedicineSetWinVM:GetCurItem()
	self:SetCurItemInfo(CurItem)
end

function NewBagMedicineSetWinView:SetCurItemInfo(CurItem)
	if CurItem == nil then
		return
	end

	self.BagDrugTips:UpdateByItem(CurItem)

	local ItemResID = CurItem.ResID
	local ProfID = self.ProfID
	if ProfID then
		local MedicineID = BagMgr.ProfMedicineTable[ProfID]
		if BagMgr:IsMedicineItem(MedicineID) == true then
			if ItemResID == MedicineID then
				BagMedicineSetWinVM:CancelMedicine()
			else
				BagMedicineSetWinVM:ReplaceMedicine()
			end
		else
			BagMedicineSetWinVM:SetMedicine()
		end
	end

end

function NewBagMedicineSetWinView:OnClickedSetBtn()
	local ProfID = self.ProfID
	local CurItem = BagMedicineSetWinVM:GetCurItem()
	if CurItem and ProfID then
		BagMgr:ManualSetMedicine(ProfID, CurItem.ResID)
	end
	self:SaveProfMedicineTable()

	self:OnUpdateMedicineSetWin()
end


function NewBagMedicineSetWinView:OnClickedCancelBtn()
	local ProfID = self.ProfID
	if ProfID then
		BagMgr:ManualSetMedicine(ProfID, nil)
	end
	self:SaveProfMedicineTable()

	self:OnUpdateMedicineSetWin()
end

function NewBagMedicineSetWinView:SaveProfMedicineTable()
	local SetupValue = ""
	for key, value in pairs(BagMgr.ProfMedicineTable) do
		if SetupValue ~= nil then
			SetupValue = string.format("%s%s%s%s%s", SetupValue, ",", tostring(key), "=", tostring(value))
		else
			SetupValue = string.format("%s%s%s", tostring(key), "=", tostring(value))
		end
	end

	ClientSetupMgr:SendSetReq(ClientSetupKey.CSCombatDrug, SetupValue)
end

return NewBagMedicineSetWinView