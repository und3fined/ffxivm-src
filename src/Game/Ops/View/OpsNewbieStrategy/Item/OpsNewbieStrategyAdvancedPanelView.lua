---
--- Author: Administrator
--- DateTime: 2024-11-18 14:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local OpsNewbieStrategyPanelVM = require("Game/Ops/VM/OpsNewbieStrategy/OpsNewbieStrategyPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local OpsNewbieStrategyDefine
local DataReportUtil = require("Utils/DataReportUtil")
local ActivityOperationMap
local AdvancedPanelVM

---@class OpsNewbieStrategyAdvancedPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyAdvancedPanelView = LuaClass(UIView, true)

function OpsNewbieStrategyAdvancedPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyAdvancedPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyAdvancedPanelView:OnInit()
	AdvancedPanelVM = OpsNewbieStrategyPanelVM:GetAdvancedPanelVM()
	OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
	ActivityOperationMap = {
		[OpsNewbieStrategyDefine.ActivityID.AdvancedEthericActivityID] = OpsNewbieStrategyDefine.OperationPageActionType.AdvancedEtheric,
		[OpsNewbieStrategyDefine.ActivityID.AdvancedExploreActivityID] = OpsNewbieStrategyDefine.OperationPageActionType.AdvancedExplore,
		[OpsNewbieStrategyDefine.ActivityID.AdvancedGoldSauserActivityID] = OpsNewbieStrategyDefine.OperationPageActionType.AdvancedGoldSauser,
		[OpsNewbieStrategyDefine.ActivityID.AdvancedCombatActivityID] = OpsNewbieStrategyDefine.OperationPageActionType.AdvancedCombat,
		[OpsNewbieStrategyDefine.ActivityID.AdvancedProductionActivityID] = OpsNewbieStrategyDefine.OperationPageActionType.AdvancedProduction,
	}
	self.TableViewSubActiveAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnItemClicked, true, true)
	self.Binders = 
	{
		{ "CompletedNumText", UIBinderSetText.New(self, self.TextQuantity1)},
		{ "SubActivityList", UIBinderUpdateBindableList.New(self, self.TableViewSubActiveAdapter) },
	}
end

function OpsNewbieStrategyAdvancedPanelView:OnDestroy()

end

function OpsNewbieStrategyAdvancedPanelView:OnShow()
	---红点名设置
	--_G.OpsNewbieStrategyMgr:DelFirstOpenRedDot(OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID)
end

function OpsNewbieStrategyAdvancedPanelView:OnHide()
	---清除选中展开/防止再次进入的时候
	if AdvancedPanelVM then
		AdvancedPanelVM:ClearCurSelected()
	end
end

function OpsNewbieStrategyAdvancedPanelView:OnRegisterUIEvent()
	
end

function OpsNewbieStrategyAdvancedPanelView:OnRegisterGameEvent()

end

function OpsNewbieStrategyAdvancedPanelView:OnRegisterBinder()
	if AdvancedPanelVM then
		self:RegisterBinders(AdvancedPanelVM, self.Binders)
	end
end

function OpsNewbieStrategyAdvancedPanelView:OnItemClicked(Index, ItemData, ItemView)
	if ItemData:GetIsUnLock() then
		if not AdvancedPanelVM  then
			return
		end
		local OldIndex
		OldIndex = AdvancedPanelVM:GetCurSelectedIndex()
		if OldIndex ~= Index then
			--- 未解锁/收起时不触发点击上报 
			local ActionType = ActivityOperationMap[ItemData.ID]
			if ActionType then
				DataReportUtil.ReportActivityClickFlowData(ItemData.ID ,ActionType)
			end

		end
		AdvancedPanelVM:SetSelectedItem(Index, ItemData, ItemView)
		---等VM处理完数据变化再处理动效
		if self.ScrollTimer then
			self:UnRegisterAllTimer(self.ScrollTimer)
			self.ScrollTimer = nil
		end
		local CurIsExpand = AdvancedPanelVM:GetCurSelectedIndex() ~= nil
		local AnimEndTime
		if CurIsExpand then
			AnimEndTime = ItemView:GetAnimUnfoldEndTime()
		else
			AnimEndTime = ItemView:GetAnimfoldEndTime()
		end
		local LoopNum = AnimEndTime/0.1
		LoopNum = math.ceil(LoopNum)
		self.ScrollTimer = self:RegisterTimer( self.ScrollCallback,0, 0.1,LoopNum)
	else
		local QuestName = ItemData.QuestName or AdvancedPanelVM:GetQuestName()
		-- LSTR string:完成任务%s后解锁
		_G.MsgTipsUtil.ShowTips(string.format(LSTR(920044), QuestName))
	end
end

---配合动效效果做滑动
function OpsNewbieStrategyAdvancedPanelView:ScrollCallback()
	if not AdvancedPanelVM  then
		return
	end
	local Index = AdvancedPanelVM:GetCurSelectedIndex()
	local CurIsExpand = Index ~= nil

	if CurIsExpand then
		self.TableViewSubActiveAdapter:ScrollToIndex(Index)
	else
		self.TableViewSubActiveAdapter:ScrollToTop()
	end
end

return OpsNewbieStrategyAdvancedPanelView