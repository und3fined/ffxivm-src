---
--- Author: xingcaicao
--- DateTime: 2023-05-18 21:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TeamVM = require("Game/Team/VM/TeamVM")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local SceneMode = require("Protocol/ProtoCommon").SceneMode

---@class TeamRecruitContentSelectView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnConfirm CommBtnLView
---@field BtnHelp CommHelpBtnView
---@field PanelSet UFCanvasPanel
---@field TableViewContents UTableView
---@field TableViewTypes UTableView
---@field TeamRecruitDropBar TeamRecruitDropBarView
---@field TextQuestSet UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitContentSelectView = LuaClass(UIView, true)

function TeamRecruitContentSelectView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnConfirm = nil
	--self.BtnHelp = nil
	--self.PanelSet = nil
	--self.TableViewContents = nil
	--self.TableViewTypes = nil
	--self.TeamRecruitDropBar = nil
	--self.TextQuestSet = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitContentSelectView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.BtnHelp)
	self:AddSubView(self.TeamRecruitDropBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitContentSelectView:OnPostInit()
	self.TableAdapterTypes = UIAdapterTableView.CreateAdapter(self, self.TableViewTypes, self.OnSelectTypeChanged)
	self.TableAdapterContent = UIAdapterTableView.CreateAdapter(self, self.TableViewContents, self.OnSelectContentChanged)
	self.Binders = {
		{ "TeamRecruitTypeVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterTypes) },
		{ "EditRecruitType", UIBinderValueChangedCallback.New(self, nil, self.OnEditRecruitTypeChanged) },
		{ "bShowEditDifficulty", UIBinderSetIsVisible.New(self, self.PanelSet)},
	}
end

function TeamRecruitContentSelectView:OnShow()
	local TypeIdx = 1
	local TypeID = TeamRecruitVM.EditRecruitType
	if TypeID then
		TypeIdx = TeamRecruitVM.TeamRecruitTypeVMList:GetItemIndexByPredicate(function (e)
			return e.TypeID == TypeID
		end)
	end

	self.TableAdapterTypes:SetSelectedIndex(TypeIdx or 1)

	local SceneMode = require("Protocol/ProtoCommon").SceneMode
	self.TeamRecruitDropBar:OnEditSceneModeChanged(TeamRecruitVM.EditSceneMode or SceneMode.SceneModeNormal)

	self.BG:SetTitleText(_G.LSTR(1310065))
	self.BtnConfirm:SetText(_G.LSTR(1310066))
	self.TextQuestSet:SetText(_G.LSTR(1310083))
end

function TeamRecruitContentSelectView:OnHide()
	self.TableAdapterTypes:CancelSelected()
	self.TableAdapterContent:CancelSelected()
	self:SetContentID(nil)
	self.EditMode = nil
end

function TeamRecruitContentSelectView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnClickedConfirm)
end

function TeamRecruitContentSelectView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.RecruitEditDifficulty, self.OnDifficultySelect)
end

function TeamRecruitContentSelectView:OnRegisterBinder()
	self:RegisterBinders(TeamRecruitVM, self.Binders)

	self.TeamRecruitDropBar:SetBinderKV("EditDifficultyVMs", TeamRecruitVM)
end

function TeamRecruitContentSelectView:OnMouseButtonDown(InGeometry, InTouchEvent)
	self.TeamRecruitDropBar:ToggleCollapse()
	return _G.UE.UWidgetBlueprintLibrary.Unhandled()
end

function TeamRecruitContentSelectView:OnSelectTypeChanged(Index, ItemData, ItemView)
	if ItemData then
		self:OnEditRecruitTypeChanged(ItemData.TypeID)
		self:PlayAnimation(self.AnimPanelIn)
		self.TeamRecruitDropBar:ToggleCollapse()
	end
end

function TeamRecruitContentSelectView:OnSelectContentChanged(Index, ItemData, ItemView)
	if ItemData then
		self:SetContentID(ItemData.ID)
		self.TeamRecruitDropBar:ToggleCollapse()
	end
end

function TeamRecruitContentSelectView:OnEditRecruitTypeChanged(RecruitType)
	if nil == RecruitType then
		return
	end

	local ContentIdx = 1
	local ContentList = TeamRecruitVM:GetRecruitContentList(RecruitType)
	local RecruitID = TeamRecruitVM.EditContentID
	if RecruitID then
		local _, Idx = table.find_by_predicate(ContentList, function(e)
			return e.ID == RecruitID
		end)

		ContentIdx = math.max(Idx or 1, 1)
	end

	self.TableAdapterContent:UpdateAll(ContentList)

	if #ContentList >= ContentIdx then
		self.TableAdapterContent:SetSelectedIndex(ContentIdx)
	end
end

function TeamRecruitContentSelectView:CheckUpdateContentID( ContentID )
	local CurMemberNum = TeamVM.MemberNumber or 0
	local MaxMemberNum = TeamRecruitUtil.GetMemberNum(ContentID)
	if CurMemberNum >= MaxMemberNum then
		MsgTipsUtil.ShowTips(_G.LSTR(1310033))
		return false
	end

	return true
end

-------------------------------------------------------------------------------------------------------
--- Component CallBack

function TeamRecruitContentSelectView:OnClickedConfirm()
	if self:CheckUpdateContentID(self.ContentID) then
		TeamRecruitVM:SetEditContentID(self.ContentID)
		TeamRecruitVM:SetEditRecruitTypeByContentID(self.ContentID)
		TeamRecruitVM:SetEditSceneMode(self.EditMode or SceneMode.SceneModeNormal)
		self:Hide()
	end
end

function TeamRecruitContentSelectView:OnDifficultySelect(ItemData, View)
	if View == self.TeamRecruitDropBar and View then
		local Mode = SceneMode.SceneModeNormal
		if ItemData.Op == 1 then
			Mode = SceneMode.SceneModeNormal
		elseif ItemData.Op == 2 then
			Mode = SceneMode.SceneModeChallenge
		elseif ItemData.Op == 3 then
			Mode = SceneMode.SceneModeUnlimited
		end
		self.EditMode = Mode
	end
end

function TeamRecruitContentSelectView:SetContentID(ID)
	self.ContentID = ID
	TeamRecruitVM:UpdateEditDiffculty(ID)

	local bFlag
	for  _, v in ipairs(TeamRecruitVM.EditDifficultyVMs:GetItems()) do
		if self.EditMode and (self.EditMode + 1) == v.Op then
			bFlag = true
			break
		end
	end

	if not bFlag then
		self.EditMode = SceneMode.SceneModeNormal
		self.TeamRecruitDropBar:OnEditSceneModeChanged(self.EditMode)
	end
end

return TeamRecruitContentSelectView