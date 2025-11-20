---
--- Author: Administrator
--- DateTime: 2025-08-05 11:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WardrobeSuitWinVM = require("Game/Wardrobe/VM/WardrobeSuitWinVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ItemUtil = require("Utils/ItemUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class WardrobeSuitWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackEmpty CommBackpackEmptyView
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field CommBtnL_UIBP CommBtnLView
---@field FCanvasPanel_81 UFCanvasPanel
---@field PanelBtn UFCanvasPanel
---@field PanelTaskList UFCanvasPanel
---@field PanelTitle UFCanvasPanel
---@field TableViewEquipmentList UTableView
---@field TableViewSlot UTableView
---@field TableViewTaskList UTableView
---@field TextEquipmentName UFTextBlock
---@field TextHowtogetit UFTextBlock
---@field TextTitle UFTextBlock
---@field TextUnlock UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeSuitWinView = LuaClass(UIView, true)

function WardrobeSuitWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackEmpty = nil
	--self.Comm2FrameL_UIBP = nil
	--self.CommBtnL_UIBP = nil
	--self.FCanvasPanel_81 = nil
	--self.PanelBtn = nil
	--self.PanelTaskList = nil
	--self.PanelTitle = nil
	--self.TableViewEquipmentList = nil
	--self.TableViewSlot = nil
	--self.TableViewTaskList = nil
	--self.TextEquipmentName = nil
	--self.TextHowtogetit = nil
	--self.TextTitle = nil
	--self.TextUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeSuitWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackEmpty)
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.CommBtnL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeSuitWinView:OnInit()
	self.VM = WardrobeSuitWinVM.New()

	-- 套装列表List
	self.SuitListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnTableSuitListChanged, true)
	-- 同模装备列表List
	self.EquipmentListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewEquipmentList, self.OnTableEquipmentListChanged, true)
	-- 获取途径List
	self.GetWayListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTaskList, true)

	self.Binders = {
		{ "SuitList",  UIBinderUpdateBindableList.New(self, self.SuitListAdapter)},
		-- { "SuitListSelectedIndex",  UIBinderSetSelectedIndex.New(self, self.SuitListAdapter)},
		{ "EquipmentList",  UIBinderUpdateBindableList.New(self, self.EquipmentListAdapter)},
		-- { "EquipmentListSelectedIndex",  UIBinderSetSelectedIndex.New(self, self.EquipmentListAdapter)},
		{ "IsCurAppUnlock",  UIBinderSetIsVisible.New(self, self.TextUnlock)},
		{ "AppName",  UIBinderSetText.New(self, self.TextEquipmentName)},
		{ "IsEmptyGetWay", UIBinderSetIsVisible.New(self, self.BackpackEmpty)},
		{ "IsEmptyGetWay", UIBinderSetIsVisible.New(self, self.TextHowtogetit, true)},
		{ "UnlockText", UIBinderSetText.New(self, self.CommBtnL_UIBP)},
		{ "CurEquipID", UIBinderValueChangedCallback.New(self, nil, self.OnItemChanged) },
	}
end

function WardrobeSuitWinView:OnDestroy()

end

function WardrobeSuitWinView:OnShow()
	self.CurAppID = nil
	self.SuperView = self.Params.SuperView
	self:InitText()
	self.VM:UpdateSuitList(self.Params.SuitID)
	self.SuitListAdapter:SetSelectedIndex(1)
end

function WardrobeSuitWinView:OnHide()

end

function WardrobeSuitWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnL_UIBP, self.OnClickedBtnUnlock)
end

function WardrobeSuitWinView:OnRegisterGameEvent()
	-- 衣橱解锁更新
	self:RegisterGameEvent(_G.EventID.WardrobeUnlockUpdate, self.OnWardrobeUnlockUpdate)
end

function WardrobeSuitWinView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
end

function WardrobeSuitWinView:InitText()
	self.Comm2FrameL_UIBP:SetTitleText(_G.LSTR(1080158)) -- 套装获取
	self.TextTitle:SetText(_G.LSTR(1080159))  --所有同模装备
	self.TextHowtogetit:SetText(_G.LSTR(1080160)) --获取途径
	self.TextUnlock:SetText(_G.LSTR(1080161)) --外观可解锁
	self.BackpackEmpty:SetTipsContent(_G.LSTR(1080162)) --暂无获取途径
end

function WardrobeSuitWinView:OnWardrobeUnlockUpdate()
	if self.Params ~= nil and self.Params.SuitID ~= nil and self.VM ~= nil then
		self.VM:UpdateSuitList(self.Params.SuitID)
	end
end

function WardrobeSuitWinView:OnTableSuitListChanged(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end

	local AppID = ItemData.AppID
	self.CurAppID = AppID
	self.VM.AppName = WardrobeUtil.GetEquipmentAppearanceName(AppID)
	self.VM:UpdateEquipmentList(AppID)

	self.EquipmentListAdapter:SetSelectedIndex(1)
	self.VM:UpdateUnlockText(AppID)
	local IsUnlock = _G.WardrobeMgr:GetIsUnlock(AppID) 
	if IsUnlock then
		self.VM.IsCurAppUnlock = false
		self.CommBtnL_UIBP:SetIsDoneState(true, _G.LSTR(1080057)) --已解锁
	else
		local IsUnlockEnable =  WardrobeUtil.JudgeUnlockAppearanceWithouItem(AppID)
		if IsUnlockEnable then
		self.VM.IsCurAppUnlock = true
		self.CommBtnL_UIBP:SetIsRecommendState(true)
		else
		self.VM.IsCurAppUnlock = false
		self.CommBtnL_UIBP:SetIsDisabledState(true, _G.LSTR(1080150)) -- 前往解锁
		end
	end
end

function WardrobeSuitWinView:OnTableEquipmentListChanged(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end

	self.CurEquipID = ItemData.EquipID

	self:OnItemChanged(self.CurEquipID)
end

function WardrobeSuitWinView:OnItemChanged(NewValue)
	local CommGetWayItems = ItemUtil.GetItemGetWayList(NewValue) or {}
	self.GetWayListAdapter:UpdateAll(CommGetWayItems)
	self.VM.IsEmptyGetWay = #CommGetWayItems == 0
end

function WardrobeSuitWinView:OnClickedBtnUnlock()
	if self.CurAppID == nil then
		return
	end

	local AppID = self.CurAppID
	local IsUnlock = _G.WardrobeMgr:GetIsUnlock(AppID) 
	local IsUnlockEnable =  WardrobeUtil.JudgeUnlockAppearanceWithouItem(AppID)
	if not IsUnlock and not IsUnlockEnable then
		MsgTipsUtil.ShowTips(_G.LSTR(1080151)) --暂未满足解锁条件
		return 
	end

	-- Todo 前往衣橱解锁界面
	self.SuperView.HideSuitPanelView(self.SuperView, AppID)
	_G.UIViewMgr:HideView(_G.UIViewID.WardrobeSuitGetWayWin)

end

return WardrobeSuitWinView