---
--- Author: v_vvxinchen
--- DateTime: 2024-07-24 10:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class GatheringLogHistorySearchListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnHistory UFButton
---@field TextHistoryContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringLogHistorySearchListItemView = LuaClass(UIView, true)

function GatheringLogHistorySearchListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnHistory = nil
	--self.TextHistoryContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringLogHistorySearchListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringLogHistorySearchListItemView:OnInit()
	self.Binders = {
		{ "SearchText", UIBinderSetText.New(self, self.TextHistoryContent) },
	}
end

function GatheringLogHistorySearchListItemView:OnDestroy()

end

function GatheringLogHistorySearchListItemView:OnShow()

end

function GatheringLogHistorySearchListItemView:OnHide()

end

function GatheringLogHistorySearchListItemView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnBtnDeleteClick)
    UIUtil.AddOnClickedEvent(self, self.BtnHistory, self.OnBtnHistoryClick)
end

function GatheringLogHistorySearchListItemView:OnRegisterGameEvent()

end

function GatheringLogHistorySearchListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

---@type 点击历史记录Item
function GatheringLogHistorySearchListItemView:OnBtnHistoryClick()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

---@type 删除单个历史记录Item
function GatheringLogHistorySearchListItemView:OnBtnDeleteClick()
	--采集笔记的删除
	-- local ViewModel = self.Params.Data
	-- if nil == ViewModel then
	-- 	return
	-- end
	-- local HistoryList = GatheringLogVM.SearchRecordVMList
    -- local TargetIndex = 0
    -- if nil ~= HistoryList and HistoryList:Length() > 0 then
    --     for i = 1, HistoryList:Length() do
    --         local SearchItemVM = HistoryList:Get(i)
    --         if SearchItemVM.SearchText == ViewModel.SearchText then
    --             TargetIndex = i
    --             break
    --         end
    --     end
    -- end
	-- _G.GatheringLogVM.SearchRecordVMList:RemoveAt(TargetIndex)
	-- table.remove(_G.GatheringLogMgr.SearchRecordList, TargetIndex)

	--制作笔记的删除
	--_G.CraftingLogMgr:SetSearchHistory(ViewModel.SearchInfoText, true)
end

return GatheringLogHistorySearchListItemView