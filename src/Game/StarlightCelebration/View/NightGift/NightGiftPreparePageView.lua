---
--- Author: Administrator
--- DateTime: 2025-07-28 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local NightGiftPreparePageVM = require("Game/StarlightCelebration/VM/NightGift/NightGiftPreparePageVM")
local ProtoCS = require("Protocol/ProtoCS")
local OpsStarlightDefine = require("Game/StarlightCelebration/OpsStarlightDefine")

local LSTR = _G.LSTR

---@class NightGiftPreparePageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BGPanel NightGiftBGPanelView
---@field BtnFinish CommBtnLView
---@field BtnRefresh UFButton
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field SideWin NightGiftSideWinView
---@field TableViewSlot UTableView
---@field Text1 UFTextBlock
---@field Text2 UFTextBlock
---@field Text3 UFTextBlock
---@field TextDescribe UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NightGiftPreparePageView = LuaClass(UIView, true)

function NightGiftPreparePageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BGPanel = nil
	--self.BtnFinish = nil
	--self.BtnRefresh = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.SideWin = nil
	--self.TableViewSlot = nil
	--self.Text1 = nil
	--self.Text2 = nil
	--self.Text3 = nil
	--self.TextDescribe = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NightGiftPreparePageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BGPanel)
	self:AddSubView(self.BtnFinish)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.SideWin)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NightGiftPreparePageView:OnInit()
	self.ViewModel = NightGiftPreparePageVM:New()
	self.AdapterTableViewGift = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.AdapterTableViewGift:SetOnClickedCallback(self.OnItemClicked)
	self.Binders = {	
		{"DescribeText", UIBinderSetText.New(self, self.TextDescribe)},
		{"BlessingText", UIBinderSetText.New(self, self.Text2) },
		{"BtnFinishEnabled", UIBinderSetIsEnabled.New(self, self.BtnFinish, false, true) },
		{"NightGiftItemVMList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewGift) },
		
	}

	self.SideWin.BtnClose:SetCallback(self, self.OnClickButtonClose)
end

function NightGiftPreparePageView:OnDestroy()

end

function NightGiftPreparePageView:OnShow()
	self.ViewModel:UpdatePreparePageInfo()
end

function NightGiftPreparePageView:OnHide()
	self.ViewModel:ClearData()
end

function NightGiftPreparePageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFinish.Button, self.OnClickFinishButton)
	UIUtil.AddOnClickedEvent(self, self.BtnRefresh, self.OnClickRefreshButton)
end

function NightGiftPreparePageView:OnRegisterGameEvent()

end

function NightGiftPreparePageView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.SideWin:SetParams(self.ViewModel)

	self.TextTitle:SetText(LSTR(1700007))
	self.Text1:SetText(LSTR(1700025))
	self.Text3:SetText(LSTR(1700026))
	self.BtnFinish:SetBtnName(LSTR(1700028))

	self.BlessingTextIndex = 1
	self.Text2:SetText(OpsStarlightDefine.GiftBlessingText[self.BlessingTextIndex])
end

function NightGiftPreparePageView:OnItemClicked(Index, ItemData, ItemView)
	self.ViewModel:RemoveItemFromGiftList(ItemData.ItemSlotVM.GID)

	local CurGiftItem = self.ViewModel.CurGiftItem
	if CurGiftItem then
		self.SideWin.EditQuantityItem:SetCurValue(CurGiftItem.Num)
	else
		self.SideWin.EditQuantityItem:SetCurValue(1)
	end
end

function NightGiftPreparePageView:OnClickFinishButton()
	if self.ViewModel.BtnFinishEnabled == false then
		_G.MsgTipsUtil.ShowTips(LSTR(1700031))
		return
	end

	local function OkCallback()
		local ItemList = {}
		for _, Value in ipairs(self.ViewModel.GiftList) do
			table.insert(ItemList, {GID = Value.GID, Num = Value.Num, ResID = Value.ResID})
		end
		local Data = {
			Message = self.BlessingTextIndex,
			Items = ItemList
		}

		_G.OpsActivityMgr:SendActivityNodeOperate(OpsStarlightDefine.PutGiftNodeID, ProtoCS.Game.Activity.NodeOpType.NodeOpTypeStarDayPutGift, {StarDayPutGift = Data})
		self:Hide()
	end

	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self ,LSTR(10004), LSTR(1700032), OkCallback, nil, LSTR(10003), LSTR(10002))

end

function NightGiftPreparePageView:OnClickRefreshButton()
	self.BlessingTextIndex = self.BlessingTextIndex + 1
	if self.BlessingTextIndex > #OpsStarlightDefine.GiftBlessingText then
		self.BlessingTextIndex = 1
	end
	self.Text2:SetText(OpsStarlightDefine.GiftBlessingText[self.BlessingTextIndex])
end

function NightGiftPreparePageView:OnClickButtonClose()
	local function OkCallback()
		self:Hide()
	end

	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self ,LSTR(10004), LSTR(1700033), OkCallback, nil, LSTR(10003), LSTR(10002))
end


return NightGiftPreparePageView