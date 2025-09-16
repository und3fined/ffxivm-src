---
--- Author: zhangyuhao
--- DateTime: 2025-03-07 20:40
--- Description: 推荐任务View
---

local BaseView = require("Game/Adventure/View/AdventureChildPageBaseView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local AdventureRecommendTaskNewVM = require("Game/Adventure/AdventureRecommendTaskNewVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local AdventureRecommendTaskMgr = require("Game/Adventure/AdventureRecommendTaskMgr")

---@class AdventureRecommendTaskView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelEmptyStateNew UFCanvasPanel
---@field PanelRecommendTaskNew UFCanvasPanel
---@field TableViewRecommendTaskNew UTableView
---@field TextEmpty03 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureRecommendTaskView = LuaClass(BaseView, true)

function AdventureRecommendTaskView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelEmptyStateNew = nil
	--self.PanelRecommendTaskNew = nil
	--self.TableViewRecommendTaskNew = nil
	--self.TextEmpty03 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureRecommendTaskView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureRecommendTaskView:OnInit()
	self.VM = AdventureRecommendTaskNewVM.New()
	self.AdapterRecommendList = UIAdapterTableView.CreateAdapter(self, self.TableViewRecommendTaskNew)
end

function AdventureRecommendTaskView:OnDestroy()

end

function AdventureRecommendTaskView:OnShow()
	self.TextEmpty03:SetText(AdventureRecommendTaskMgr:GetAllAdventureRecommendFinished() and _G.LSTR(520020) or _G.LSTR(520033))
	UIUtil.SetIsVisible(self.PanelEmptyStateNew, false)
	UIUtil.SetIsVisible(self.TableViewRecommendTaskNew, false)
	if self.Params and next(self.Params) then
		if self.Params.MainKey and self.Params.SubKey then
			UIUtil.SetIsVisible(self.TableViewRecommendTaskNew, true, true)
			self.CurSubIndex = self.Params.SubKey - 10 * self.Params.MainKey
			self.VM:SetCurType(self.CurSubIndex)
			AdventureRecommendTaskMgr:SetTabRedDot(self.CurSubIndex, false)
			self.VM:SetTypeAllNewState(self.CurSubIndex)
			local ItemListData = self.VM:GetCurTypeListData()
			self:CreatItemList(ItemListData)
			return
		end
	end

	UIUtil.SetIsVisible(self.PanelEmptyStateNew, true)
end

function AdventureRecommendTaskView:OnHide()
	self.Super.OnHide(self)
	if self.CurSubIndex then
		self.VM:SetTypeAllNewState(self.CurSubIndex)
	end
end

function AdventureRecommendTaskView:OnRegisterUIEvent()

end

function AdventureRecommendTaskView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RecommendTaskUpdate, self.OnUpdateRecommendTask)
end

function AdventureRecommendTaskView:OnUpdateRecommendTask()
	local ItemListData = self.VM:GetCurTypeListData()
	self:CreatItemList(ItemListData)
end

function AdventureRecommendTaskView:OnRegisterBinder()
	local RecommendTaskBinders = {
		{"ItemList", UIBinderUpdateBindableList.New(self, self.AdapterRecommendList)},
		{"PanelEmptyStateVisible", UIBinderSetIsVisible.New(self, self.PanelEmptyStateNew)},
		{"EmptyText",UIBinderSetText.New(self, self.TextEmpty03)},
	}

	self:RegisterBinders(self.VM, RecommendTaskBinders)
end

return AdventureRecommendTaskView