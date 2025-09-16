---
--- Author: Administrator
--- DateTime: 2023-06-25 14:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CommScreenerVM = require("Game/Common/Screener/CommScreenerVM")
local ScreenerClassificationCfg = require("TableCfg/ScreenerClassificationCfg")
local DBUtil = require("Utils/DBUtil")

local EventID = _G.EventID
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local EventMgr = _G.EventMgr
local LSTR = _G.LSTR

---@class CommScreenerView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameLView
---@field BtnConfirm CommBtnLView
---@field BtnReset CommBtnLView
---@field TableViewScreener UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommScreenerView = LuaClass(UIView, true)

function CommScreenerView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnConfirm = nil
	--self.BtnReset = nil
	--self.TableViewScreener = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommScreenerView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.BtnReset)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommScreenerView:OnInit()
	self.ScreenerTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewScreener)
	self.ScreenerTableViewAdapter:SetOnClickedCallback(self.OnScreenerItemClicked)
end

function CommScreenerView:OnDestroy()

end

function CommScreenerView:OnShow()
	if nil == self.Params then
		return
	end

	local CfgSearchCond = string.format("RelatedSystem == %d AND SystemRelatedValue == %d", self.Params.RelatedSystem, self.Params.SystemRelatedValue)
	local ScreenerList = ScreenerClassificationCfg:FindAllCfg(CfgSearchCond)

	if ScreenerList ~= nil and #ScreenerList > 0 then
		self.ScreenerTable = ScreenerList[1].InquiryTable
	end

	local DropDownScreenList= {}
	local OtherScreenerList = {}
	if ScreenerList then
		for i = 1, #ScreenerList do
			local ScreenerInfo = ScreenerList[i]
			if ScreenerInfo.ScreenerType == 0 then --下拉框
				table.insert(DropDownScreenList, ScreenerInfo)
			else
				table.insert(OtherScreenerList, ScreenerInfo)
			end
		end
	end

	CommScreenerVM:UpdateScreenerList(DropDownScreenList, OtherScreenerList, self.Params.ScreenerSelectedInfo)
end

function CommScreenerView:OnHide()
end

function CommScreenerView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnReset.Button, self.OnClickedResetBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm.Button, self.OnClickedConfirmBtn)
	UIUtil.AddOnClickedEvent(self, self.Bg.ButtonClose, self.OnClickCloseBtn)
end

function CommScreenerView:OnRegisterGameEvent()

end

function CommScreenerView:OnRegisterBinder()
	local Binders = {
		{ "ScreenerItemVMList", UIBinderUpdateBindableList.New(self, self.ScreenerTableViewAdapter) },
	}

	self:RegisterBinders(CommScreenerVM, Binders)

	
	self.Bg:SetTitleText(LSTR(1480001))
	self.BtnReset:SetBtnName(LSTR(1480002))
	self.BtnConfirm:SetBtnName(LSTR(10002))
end

function CommScreenerView:OnClickedResetBtn()
	CommScreenerVM:ResetScreener()
end

function CommScreenerView:OnClickedConfirmBtn()
	local CfgSearchCond,  ScreenerList= CommScreenerVM:SearchCondAndScreenerList()
	if #ScreenerList > 0 then --AllCfg记录最终筛选的结果列表。ScreenerList记录筛选的条件列表
		if not string.isnilorempty(self.ScreenerTable) then --通过策划配表获取最终结果列表，返回筛选结果列表和选中的条件列表
			local AllCfg = DBUtil.FindAllCfg(self.ScreenerTable, CfgSearchCond)
			EventMgr:SendEvent(EventID.ScreenerResult, {Result = AllCfg, ScreenerList = ScreenerList})
		else --需要程序自己处理筛选结果，返回选中的条件列表
			EventMgr:SendEvent(EventID.ScreenerResult, {ScreenerList = ScreenerList})
		end
	else
		-- 搜索条件为空。表示默认没有任何过滤条件
		EventMgr:SendEvent(EventID.ScreenerResult, nil)
	end

	UIViewMgr:HideView(UIViewID.ScreenerWin)
end

function CommScreenerView:OnScreenerItemClicked(Index, ItemData, ItemView)
	if ItemView == nil then
		return
	end

	local ItemViewParams = ItemView.Params
	if nil == ItemViewParams then return end

	local ViewModel = ItemViewParams.Data
	if nil == ViewModel then return end

	CommScreenerVM:ResetLastSingleSelectIndex(ViewModel.Index, ViewModel.ScreenerID)

end

function CommScreenerView:OnClickCloseBtn()
	local CfgSearchCond,  ScreenerList= CommScreenerVM:SearchCondAndScreenerList()
	if not next(ScreenerList) then
		EventMgr:SendEvent(EventID.ScreenerResult, nil)
	end

	UIViewMgr:HideView(UIViewID.ScreenerWin)
end

return CommScreenerView