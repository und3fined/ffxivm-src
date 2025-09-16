---
--- Author: Administrator
--- DateTime: 2024-04-01 10:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local FootPrintMgr = require("Game/FootPrint/FootPrintMgr")
local FootPrintVM = require("Game/FootPrint/FootPrintVM")
local UIViewID = require("Define/UIViewID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR

---@class FootPrintMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field TableViewArea UTableView
---@field AnimIn UWidgetAnimation
---@field AnimInBackup UWidgetAnimation
---@field AnimMove UWidgetAnimation
---@field CurveMove CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FootPrintMainPanelView = LuaClass(UIView, true)

function FootPrintMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.CommonTitle = nil
	--self.TableViewArea = nil
	--self.AnimIn = nil
	--self.AnimInBackup = nil
	--self.AnimMove = nil
	--self.CurveMove = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FootPrintMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FootPrintMainPanelView:InitConstStringInfo()
	self.CommonTitle:SetTextTitleName(LSTR(320004))
end

function FootPrintMainPanelView:OnInit()
	self.TableViewAreaAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewArea, self.OnRegionItemSelectChanged, true)
	self.Binders = {
		{"RegionItemVMs", UIBinderUpdateBindableList.New(self, self.TableViewAreaAdapter)},
		{"ScheduleText", UIBinderSetText.New(self, self.TexxtSchedule)},
	}
	self:InitConstStringInfo()
end

function FootPrintMainPanelView:OnDestroy()

end

function FootPrintMainPanelView:OnShow()
	local ListData = FootPrintMgr:MakeTheRegionData()
	if not ListData then
		return
	end
	FootPrintVM:UpdateRegionList(ListData)
end

function FootPrintMainPanelView:OnHide()

end

function FootPrintMainPanelView:OnRegisterUIEvent()
	
end

function FootPrintMainPanelView:OnRegisterGameEvent()

end

function FootPrintMainPanelView:OnRegisterBinder()
	self:RegisterBinders(FootPrintVM, self.Binders)
end

function FootPrintMainPanelView:OnRegionItemSelectChanged(_, ItemVM)
	if not ItemVM then
		return
	end

	local RegionID = ItemVM.RegionID
	if not RegionID then
		return
	end

	if not FootPrintMgr:IsRegionUnlock(RegionID) then
		MsgTipsUtil.ShowTips(LSTR(320008))
		return
	end

	FootPrintMgr:UpdateTheRegionDetail(RegionID, true)
	self:Hide()
	_G.ObjectMgr:CollectGarbage(false)
end

--- 重写AnimIn方法，控制播放时机
function FootPrintMainPanelView:PlayAnimIn()
	local AnimIn = self.AnimIn
	if not AnimIn then
		return
	end
	local bNeed = FootPrintMgr.bNeedPlayAnimIn
	FootPrintVM:SetAllRegionItemPlayAnimInState(bNeed)
	if bNeed then
		self.Super:PlayAnimIn()
	end
end

return FootPrintMainPanelView