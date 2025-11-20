---
--- Author: Administrator
--- DateTime: 2025-08-01 14:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local DataReportUtil = require("Utils/DataReportUtil")
local ProtoCS = require("Protocol/ProtoCS")

---@class OpsFF7ListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot CommBtnSView
---@field ImgBG UFImage
---@field PanelList UFCanvasPanel
---@field TableViewSlot UTableView
---@field TextList UFTextBlock
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsFF7ListItemView = LuaClass(UIView, true)

function OpsFF7ListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.ImgBG = nil
	--self.PanelList = nil
	--self.TableViewSlot = nil
	--self.TextList = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsFF7ListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsFF7ListItemView:OnInit()
	self.TableViewRewardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot,self.OnClickedSelectMemberItem, true)
	self.Binders = {
		{"TaskContent", UIBinderSetText.New(self, self.TextList)},
		{"TaskProgress", UIBinderSetText.New(self, self.TextQuantity)},
		{"RewardList", UIBinderUpdateBindableList.New(self, self.TableViewRewardAdapter)},
		{"NodeDescColor", UIBinderSetColorAndOpacityHex.New(self, self.TextList)},
		{"ProgressColor", UIBinderSetColorAndOpacityHex.New(self, self.TextQuantity)},
		{"bShowBtnGo", UIBinderSetIsVisible.New(self, self.BtnSlot)},
		{"TextBtnGo", UIBinderSetText.New(self, self.BtnSlot.TextContent)},
	}
	UIUtil.SetIsVisible(self.BtnSlot.RedDot, true)
end


function OpsFF7ListItemView:OnDestroy()

end

function OpsFF7ListItemView:OnShow()
	if not self.ViewModel then return end
	self:UpdateItemState()
end

function OpsFF7ListItemView:OnHide()

end

function OpsFF7ListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.OnClickedGoHandle)
end

function OpsFF7ListItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.UpdateItemState)
	self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.UpdateItemState)
	self:RegisterGameEvent(EventID.OpsActivityUpdate, self.UpdateItemState)
end

function OpsFF7ListItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

function OpsFF7ListItemView:OnClickedGoHandle()
	if self.ViewModel == nil then return end
	DataReportUtil.ReportActivityFlowData("ActivityTaskClickFlow", self.ViewModel.ActivityID, 1, tostring(self.ViewModel.NodeID))
	local NowTime = TimeUtil.GetServerTime()
	if not self.ClickTime then
		self.ClickTime = NowTime
		self.ViewModel:OnClickedGoHandle()
	else
		if NowTime - self.ClickTime > 2 then
			self.ViewModel:OnClickedGoHandle()
			self.ClickTime = NowTime
		end
	end
end

function OpsFF7ListItemView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ItemID == nil then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView, nil, nil, 30)
end

function OpsFF7ListItemView:SetBtnState()
	if self.ViewModel == nil then return end
	self.ViewModel:SetBtnState(self.BtnSlot)
end

function OpsFF7ListItemView:UpdateItemState()
	if not self.ViewModel then return end
	self.ViewModel:SetBtnState(self.BtnSlot)
	if self.ViewModel.RedDotName then
		local RedDotItem = (self.BtnSlot or {}).RedDot
		if RedDotItem ~= nil then
			RedDotItem:SetRedDotNameByString(self.ViewModel.RedDotName)
		end
	end
end

return OpsFF7ListItemView