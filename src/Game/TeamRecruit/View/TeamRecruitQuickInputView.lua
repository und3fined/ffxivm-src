---
--- Author: xingcaicao
--- DateTime: 2023-05-25 16:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
local TeamRecruitFastMsgCfg = require("TableCfg/TeamRecruitFastMsgCfg")

---@class TeamRecruitQuickInputView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnSure CommBtnLView
---@field FCanvasPanel_15 UFCanvasPanel
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitQuickInputView = LuaClass(UIView, true)

function TeamRecruitQuickInputView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnSure = nil
	--self.FCanvasPanel_15 = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitQuickInputView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSure)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitQuickInputView:OnInit()
	self.TableAdapterText = UIAdapterTableView.CreateAdapter(self, self.TableViewList)

	self.BG:SetTitleText(_G.LSTR(1310067))
	self.BtnCancel:SetText(_G.LSTR(1310068))
	self.BtnSure:SetText(_G.LSTR(1310069))
end

function TeamRecruitQuickInputView:OnShow()
    TeamRecruitVM.EditReduceQuickTextIDs = {}
	TeamRecruitVM.TempEditQuickTextIDs = table.clone(TeamRecruitVM.EditQuickTextIDs)
end

function TeamRecruitQuickInputView:OnHide()
	TeamRecruitVM.TempEditQuickTextIDs = {}
end

function TeamRecruitQuickInputView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnSure, self.OnClickedSure)
end

function TeamRecruitQuickInputView:OnRegisterBinder()
	self.QuickInfoList = TeamRecruitFastMsgCfg:FindAllCfg() or {}
	self.TableAdapterText:UpdateAll(self.QuickInfoList)
end

-------------------------------------------------------------------------------------------------------
--- Component CallBack

function TeamRecruitQuickInputView:OnClickedCancel()
	self:Hide()
end

function TeamRecruitQuickInputView:OnClickedSure()
	local ReduceIDs = {}
	local SrcIDs = TeamRecruitVM.EditQuickTextIDs
	local CurIDs = table.clone(TeamRecruitVM.TempEditQuickTextIDs)

	local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
	local Cfg = TeamRecruitCfg:FindCfgByKey(TeamRecruitVM.EditContentID)
	
	if table.find_item(CurIDs, 8) and TeamRecruitVM.bShowEditWeeklyReward then
		TeamRecruitVM:SetEditWeeklyReward(true)
	end
	if table.find_item(CurIDs, 4) and Cfg and Cfg.CompleteTask == 1 then
		TeamRecruitVM:SetEditCompleteTask(true)
	end

	if TeamRecruitVM.EditWeeklyAward then
		table.array_add_unique(CurIDs, 8)
	end
	if TeamRecruitVM.EditCompleteTask then
		table.array_add_unique(CurIDs, 4)
	end
	table.sort(CurIDs, function (a, b)
		return a < b
	end)

	for _, v in ipairs(SrcIDs) do
		if not table.contain(CurIDs) then
			table.insert(ReduceIDs, v)
		end
	end

	TeamRecruitVM:SetEditQuickTextIDs(CurIDs, ReduceIDs)
	self:Hide()
end

return TeamRecruitQuickInputView