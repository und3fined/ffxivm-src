--[[
Author: jususchen jususchen@tencent.com
Date: 2025-03-07 16:50:17
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-03-07 18:55:19
FilePath: \Script\Game\TeamRecruit\View\TeamRecruitObjectFilteringView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local PWorldQuestUtil = require("Game/PWorld/Quest/PWorldQuestUtil")

---@class TeamRecruitObjectFilteringView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnHelp CommHelpBtnView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommBtnLOK CommBtnLView
---@field CommBtnLReset CommBtnLView
---@field TableViewList UTableView
---@field TeamRecruitDropBar TeamRecruitDropBarView
---@field TextQuestSet UFTextBlock
---@field TextSelect UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitObjectFilteringView = LuaClass(UIView, true)

function TeamRecruitObjectFilteringView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnHelp = nil
	--self.Comm2FrameM_UIBP = nil
	--self.CommBtnLOK = nil
	--self.CommBtnLReset = nil
	--self.TableViewList = nil
	--self.TeamRecruitDropBar = nil
	--self.TextQuestSet = nil
	--self.TextSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitObjectFilteringView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnHelp)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommBtnLOK)
	self:AddSubView(self.CommBtnLReset)
	self:AddSubView(self.TeamRecruitDropBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitObjectFilteringView:OnPostInit()
	local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
	self.TableAdapterContent = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectContentChanged)
end

function TeamRecruitObjectFilteringView:OnShow()
	if self.Params then
		local ContentList = TeamRecruitVM:GetRecruitContentList(self.Params.RecruitType)
		self.TableAdapterContent:UpdateAll(ContentList)

		local CID = TeamRecruitVM:GetFilterContentID(self.Params.RecruitType)
		if CID ~= nil then
			self.TableAdapterContent:SetSelectedByPredicate(function(V)
				return CID == V.ID
			end)
		else
			self.TableAdapterContent:CancelSelected()
		end
	end

	self.Comm2FrameM_UIBP:SetTitleText(_G.LSTR(1310100))
	self.CommBtnLOK:SetBtnName(_G.LSTR(1310102))
	self.CommBtnLReset:SetBtnName(_G.LSTR(1310101))
	self.TextSelect:SetText(_G.LSTR(1310103))
	self.TextQuestSet:SetText(_G.LSTR(1310104))
end

function TeamRecruitObjectFilteringView:PostShowView()
	local Op = TeamRecruitVM:GetFilterOp(self.Params.RecruitType) or 999
	TeamRecruitVM.FilterDifficultVMs:UpdateByValues({{Op=999},{Op=1},{Op=2},{Op=3},})
	self.TeamRecruitDropBar:SelectIndexByPredicate(function(V)
		return V.Op == Op
	end)

	do
		local Text
		if Op == 999 then
			Text = _G.LSTR(1310105)
		else
			local TaskType = _G.PWorldEntDetailVM:ToTaskType(Op)
			Text = PWorldQuestUtil.GetSceneModeName(TaskType) or ""
		end

		self.TeamRecruitDropBar:SetSelectedDifficultyText(Text)
		self.TeamRecruitDropBar:SetSelectedDifficultyIcon(TeamRecruitUtil.GetSceneModeIconByOp(Op))
	end

	local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
	local Cfg = TeamRecruitCfg:FindCfg(string.sformat("TypeID = %s and bFilterDifficulty = 1", self.Params.RecruitType))
	self:ShowTaskDifficulty(Cfg ~= nil)
end

function TeamRecruitObjectFilteringView:OnHide()
	self:Clear()
end

function TeamRecruitObjectFilteringView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnLReset.Button, self.OnBtnResetClick)
	UIUtil.AddOnClickedEvent(self, self.CommBtnLOK.Button, self.OnBtnConfirmClick)
end

function TeamRecruitObjectFilteringView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.RecruitEditDifficulty, self.OnDifficultySelect)
end

function TeamRecruitObjectFilteringView:OnRegisterBinder()
	self.TeamRecruitDropBar:SetBinderKV("FilterDifficultVMs", TeamRecruitVM)
end

function TeamRecruitObjectFilteringView:OnDifficultySelect(ItemData, View)
	if self.TeamRecruitDropBar == View then
		self:SetOp(ItemData.Op)
		self:MarkReset(nil)
	end
end

function TeamRecruitObjectFilteringView:OnSelectContentChanged(Index, ItemData, ItemView)
	if ItemData then
		self.TeamRecruitDropBar:ToggleCollapse()
		self:SetContentID(ItemData.ID)
		self:MarkReset(nil)
	end
end

function TeamRecruitObjectFilteringView:ShowTaskDifficulty(bShowDifficulty)
	UIUtil.SetIsVisible(self.TeamRecruitDropBar, bShowDifficulty, true)
	UIUtil.SetIsVisible(self.TextQuestSet, bShowDifficulty)
	UIUtil.SetIsVisible(self.BtnHelp, bShowDifficulty, true)
end

function TeamRecruitObjectFilteringView:OnMouseButtonDown(InGeometry, InTouchEvent)
	self.TeamRecruitDropBar:ToggleCollapse()
	return _G.UE.UWidgetBlueprintLibrary.Unhandled()
end

function TeamRecruitObjectFilteringView:SetContentID(ID)
	self.ContentID = ID

	local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
	local Cfg = TeamRecruitCfg:FindCfgByKey(ID)
	if Cfg == nil then
		return
	end

	local bShowDifficulty = Cfg and Cfg.bFilterDifficulty == 1
	self:ShowTaskDifficulty( bShowDifficulty)

	if not bShowDifficulty then
		return
	end

	local Values = {}
	if Cfg and #(Cfg.RecruitModel or {}) > 0 then
		table.insert(Values, {Op = 1,})
		for _, v in ipairs(Cfg.RecruitModel) do
			table.insert(Values, {Op = v + 1,})
		end
	end
	if #Values > 1 then
		table.insert(Values, 1, {Op=999})
	end
	TeamRecruitVM.FilterDifficultVMs:UpdateByValues(Values)
end

function TeamRecruitObjectFilteringView:SetOp(Op)
	self.Op = Op
end

function TeamRecruitObjectFilteringView:OnBtnResetClick()
	self:Clear()
	self.TableAdapterContent:CancelSelected()
	self:MarkReset(true)
end

function TeamRecruitObjectFilteringView:OnBtnConfirmClick()
	if self.bResetFlag then
		TeamRecruitVM:ClearFilterData(self.Params.RecruitType)
		self.TableAdapterContent:CancelSelected()
	else
		
		TeamRecruitVM:SetFilterOp(self.Params.RecruitType, self.Op)
		TeamRecruitVM:SetFilterContentID(self.Params.RecruitType, self.ContentID)
	end
	
	self:Hide()
end

function TeamRecruitObjectFilteringView:Clear()
	self:SetContentID(nil)
	self:SetOp(nil)
	self:MarkReset(nil)
end

function TeamRecruitObjectFilteringView:MarkReset(Value)
	self.bResetFlag = Value
end

return TeamRecruitObjectFilteringView