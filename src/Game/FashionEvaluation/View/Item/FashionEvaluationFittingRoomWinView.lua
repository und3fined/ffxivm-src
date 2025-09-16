---
--- Author: Administrator
--- DateTime: 2024-02-20 16:40
--- Description:追踪外观界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local FashionEvaluationVM = require("Game/FashionEvaluation/VM/FashionEvaluationVM")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")
local SystemEntranceMgr = require("Game/Common/Tips/SystemEntranceMgr")

---@class FashionEvaluationFittingRoomWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackEmpty CommBackpackEmptyView
---@field BtnGotoUnlock CommBtnMView
---@field BtnRemove1 CommBtnLView
---@field BtnRemove2 CommBtnMView
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field FCanvasPanel_81 UFCanvasPanel
---@field PanelBtn UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PanelTitle UFCanvasPanel
---@field TableViewEquipmentList UTableView
---@field TableViewSlot UTableView
---@field TableViewTaskList UTableView
---@field TextEquipmentName UFTextBlock
---@field TextHowtogetit UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationFittingRoomWinView = LuaClass(UIView, true)

function FashionEvaluationFittingRoomWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackEmpty = nil
	--self.BtnGotoUnlock = nil
	--self.BtnRemove1 = nil
	--self.BtnRemove2 = nil
	--self.Comm2FrameL_UIBP = nil
	--self.FCanvasPanel_81 = nil
	--self.PanelBtn = nil
	--self.PanelTips = nil
	--self.PanelTitle = nil
	--self.TableViewEquipmentList = nil
	--self.TableViewSlot = nil
	--self.TableViewTaskList = nil
	--self.TextEquipmentName = nil
	--self.TextHowtogetit = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationFittingRoomWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackEmpty)
	self:AddSubView(self.BtnGotoUnlock)
	self:AddSubView(self.BtnRemove1)
	self:AddSubView(self.BtnRemove2)
	self:AddSubView(self.Comm2FrameL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationFittingRoomWinView:OnInit()
	self.TrackAppAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnAppearanceSelected, true, false)
	self.TrackEquipModleAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewEquipmentList, self.OnEquipSelected, true, false)
	self.EquipGetWayAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewTaskList, self.OnEquipModelGetWaySelected, true, false)
	self.Binders = {
		{"AppearanceName", UIBinderSetText.New(self, self.TextEquipmentName)},
		{"TrackAppearanceVMList", UIBinderUpdateBindableList.New(self, self.TrackAppAdapterTableView)},
		{"TrackEquipVMList", UIBinderUpdateBindableList.New(self, self.TrackEquipModleAdapterTableView)},
		--{"EquipGetWayVMList", UIBinderUpdateBindableList.New(self, self.EquipGetWayAdapterTableView)},
		{"TrackEquipModelList", UIBinderValueChangedCallback.New(self, nil, self.OnTrackEquipModelVMListChanged)},
		{"IsTrackListEmpty", UIBinderSetIsVisible.New(self, self.BackpackEmpty)},
		{"IsTrackListEmpty", UIBinderSetIsVisible.New(self, self.FCanvasPanel_81, true)},
		{"CanUnLockCurAppearance", UIBinderSetIsVisible.New(self, self.PanelTips)},
	}
end

function FashionEvaluationFittingRoomWinView:OnDestroy()

end

function FashionEvaluationFittingRoomWinView:SetLSTR()
	self.Comm2FrameL_UIBP:SetTitleText(_G.LSTR(1120057)) --"时尚目标"
	self.TextTitle:SetText(_G.LSTR(1120058)) --"所有同模装备"
	self.TextHowtogetit:SetText(_G.LSTR(1120059)) --"获取途径"
	self.BtnRemove1:SetButtonText(_G.LSTR(1120060)) --"移除"
	self.BtnRemove2:SetButtonText(_G.LSTR(1120060)) --"移除"
	self.BtnGotoUnlock:SetButtonText(_G.LSTR(1120061)) --"前往解锁"
	self.BackpackEmpty:SetTipsContent(_G.LSTR(1120062)) --"暂无标记的外观"
	self.TextTips:SetText(_G.LSTR(1120049)) --"当前外观可解锁，快去衣橱解锁吧"
end

function FashionEvaluationFittingRoomWinView:OnShow()
	self:SetLSTR()
	UIUtil.SetIsVisible(self.BackpackEmpty.PanelBtn, false)
	UIUtil.SetIsVisible(self.PanelBtn, false)
	UIUtil.SetIsVisible(self.PanelTips, false)
	self.TrackAppAdapterTableView:SetSelectedIndex(1) -- 默认第一个外观
end

function FashionEvaluationFittingRoomWinView:OnHide()
	
end

function FashionEvaluationFittingRoomWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRemove1, self.OnBtnRemoveTrackClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnRemove2, self.OnBtnRemoveTrackClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnGotoUnlock, self.OnBtnUnlockClicked)
end

function FashionEvaluationFittingRoomWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OnFashionEvaluationTrackUpdate, self.UpdateUnlockBtn)
end

function FashionEvaluationFittingRoomWinView:OnRegisterBinder()
	self.TrackVM = FashionEvaluationVM:GetTrackVM()
	if self.TrackVM then
		self:RegisterBinders(self.TrackVM, self.Binders)
	end
end


function FashionEvaluationFittingRoomWinView:OnBtnRemoveTrackClicked()
	if self.TrackVM then
		self.TrackVM:RemoveEquipFromTrackList(self.AppearanceID)
	end
	self.TrackAppAdapterTableView:SetSelectedIndex(1)
end

---@type 进入衣橱界面解锁
function FashionEvaluationFittingRoomWinView:OnBtnUnlockClicked()
	self:Hide()
	FashionEvaluationMgr:OnGoToUnlockAppearanceView(self.AppearanceID)
end

---@type 外观被点击
function FashionEvaluationFittingRoomWinView:OnAppearanceSelected(Index, ItemData, ItemView)
	self.TrackEquipModleAdapterTableView:CancelSelected()
	self.AppearanceID = ItemData.AppearanceID
	self:UpdateUnlockBtn()
	self.TrackEquipModleAdapterTableView:SetSelectedIndex(1)
end

function FashionEvaluationFittingRoomWinView:UpdateUnlockBtn()
	if self.TrackVM then
		self.TrackVM:OnAppearanceSelected(self.AppearanceID)
		local CanUnLock = self.TrackVM:CanUnLock(self.AppearanceID)
		UIUtil.SetIsVisible(self.BtnRemove1, not CanUnLock)
		UIUtil.SetIsVisible(self.PanelBtn, CanUnLock)
	end
end

---@type 同模装备被点击
function FashionEvaluationFittingRoomWinView:OnEquipSelected(Index, ItemData, ItemView)
	local EquipID = ItemData.EquipID
	local CommGetWayItems = ItemUtil.GetItemGetWayList(EquipID)
	self.EquipGetWayAdapterTableView:UpdateAll(CommGetWayItems)
end

function FashionEvaluationFittingRoomWinView:OnTrackEquipModelVMListChanged(EquipList)
	if EquipList == nil or next(EquipList) == nil then
		self.EquipGetWayAdapterTableView:UpdateAll()
	end
end

---@type 装备获取途径被点击
function FashionEvaluationFittingRoomWinView:OnEquipModelGetWaySelected(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	if not ItemData.IsUnLock then
		return
	end

	if ItemData.IsRedirect == 0 then --跳转状态为0不跳转
		return
	end

	local ItemUtil = require("Utils/ItemUtil")
	ItemUtil.JumpGetWayByItemData(ItemData)

end

return FashionEvaluationFittingRoomWinView