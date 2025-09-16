---
--- Author: yutingzhan
--- DateTime: 2024-10-31 11:28
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

---@class OpsActivityList1ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot CommBtnSView
---@field ImgLine UFImage
---@field PanelList UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TableViewSlot UTableView
---@field TextList UFTextBlock
---@field TextQuantity UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityList1ItemView = LuaClass(UIView, true)

function OpsActivityList1ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.ImgLine = nil
	--self.PanelList = nil
	--self.RedDot = nil
	--self.TableViewSlot = nil
	--self.TextList = nil
	--self.TextQuantity = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityList1ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnSlot)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityList1ItemView:OnInit()
	self.TableViewRewardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot,self.OnClickedSelectMemberItem, true)
	self.Binders = {
		{"TaskContent", UIBinderSetText.New(self, self.TextList)},
		{"TaskProgress", UIBinderSetText.New(self, self.TextQuantity)},
		{"RewardList", UIBinderUpdateBindableList.New(self, self.TableViewRewardAdapter)},
		{"NodeDescColor", UIBinderSetColorAndOpacityHex.New(self, self.TextList)},
		{"ProgressColor", UIBinderSetColorAndOpacityHex.New(self, self.TextQuantity)},
		{"bShowBtnGo", UIBinderSetIsVisible.New(self, self.BtnSlot)},
		{"TextBtnGo", UIBinderSetText.New(self, self.BtnSlot.TextContent)},

		{"LineImgColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgLine)},
		{"LineImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgLine)},
		{"LineVisible", UIBinderSetIsVisible.New(self, self.ImgLine)},
	}
end

function OpsActivityList1ItemView:OnDestroy()

end

function OpsActivityList1ItemView:OnShow()
	if not self.ViewModel then return end
	self:SetBtnState()
	self:SetBtnRed()
end

function OpsActivityList1ItemView:OnHide()

end

function OpsActivityList1ItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.OnClickedGoHandle)
end

function OpsActivityList1ItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.UpdateItemState)
	self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.UpdateItemState)
	self:RegisterGameEvent(EventID.OpsActivityUpdate, self.UpdateItemState)
end

function OpsActivityList1ItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

function OpsActivityList1ItemView:OnClickedGoHandle()
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

function OpsActivityList1ItemView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ItemID == nil then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView, nil, nil, 30)
end

function OpsActivityList1ItemView:SetBtnState()
	if self.ViewModel == nil then return end
	self.ViewModel:SetBtnState(self.BtnSlot)
end

function OpsActivityList1ItemView:SetBtnRed()
	if self.ViewModel.RedDotName then
		self.RedDot:SetRedDotNameByString(self.ViewModel.RedDotName)
	end
end

function OpsActivityList1ItemView:UpdateItemState()
	if not self.ViewModel then return end
	self:SetBtnState()
end

return OpsActivityList1ItemView