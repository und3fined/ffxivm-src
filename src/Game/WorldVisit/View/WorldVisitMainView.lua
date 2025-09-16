---
--- Author: Administrator
--- DateTime: 2025-02-10 11:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local WorldVisitMainVM = require("Game/WorldVisit/VM/WorldVisitMainVM")
local WorldVisitDefine =  require("Game/WorldVisit/WorldVisitDefine")
local DataReportUtil = require("Utils/DataReportUtil")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")

---@class WorldVisitMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSidebarFrameS CommSidebarFrameSView
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldVisitMainView = LuaClass(UIView, true)

function WorldVisitMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSidebarFrameS = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldVisitMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSidebarFrameS)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldVisitMainView:OnInit()
	self.ViewModel = WorldVisitMainVM.New()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.TableViewAdapter:SetOnClickedCallback(self.OnTableItemClick)

	self.Binders = {
		{"ServerList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)}
	}
end

function WorldVisitMainView:OnTableItemClick(Index, ItemData, ItemView)
	if not self.Params or not self.Params.CrystalID then 
		FLOG_ERROR("WorldVisitMainView:OnTableItemClick CrystalID Is Nil")
		return 
	end

	if self.Params.State and self.Params.State == LoginNewDefine.ServerStateEnum.Maintenance then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1530008))
		return
	end

	local EnterWidgetType = ItemData.EnterWidgetType and ItemData.EnterWidgetType or WorldVisitDefine.WorldVisitEntryWidgetType.SeverItemTitle
	if self.Params.CrystalID and EnterWidgetType == WorldVisitDefine.WorldVisitEntryWidgetType.AllServerListItem then
		local Params = {WorldID = ItemData.WorldID, State = ItemData.State, ServerTitle = ItemData.ServerTitle, CrystalID = self.Params.CrystalID}
		_G.UIViewMgr:ShowView(_G.UIViewID.WorldVisitWinPanel, Params)
	end
end

function WorldVisitMainView:OnDestroy()

end

function WorldVisitMainView:OnShow()
	self.CommSidebarFrameS:SetTitleText(_G.LSTR(1530001))
	self.ViewModel:InitServerList()
	local CrystalID = self.Params and self.Params.CrystalID or 0
	if CrystalID ~= 0 then
		DataReportUtil.ReportCrossServerFlowData(CrystalID)
	end
end

function WorldVisitMainView:OnHide()

end

function WorldVisitMainView:OnRegisterUIEvent()

end

function WorldVisitMainView:OnRegisterGameEvent()

end

function WorldVisitMainView:OnRegisterBinder()
	if self.ViewModel then
		self:RegisterBinders(self.ViewModel, self.Binders)
	end
end

return WorldVisitMainView