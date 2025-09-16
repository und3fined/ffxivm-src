---
--- Author: xingcaicao
--- DateTime: 2023-05-29 10:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local LSTR = _G.LSTR

---@class TeamRecruitEditFuncView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnCancel CommBtnLView
---@field BtnForbid CommBtnSView
---@field BtnFreedom CommBtnSView
---@field BtnSure CommBtnLView
---@field PanelProfEditTips UFCanvasPanel
---@field TableViewFuncEdit UTableView
---@field TableViewLocProf UTableView
---@field TextBubbleTips UFTextBlock
---@field AnimPanelProfEditTips UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitEditFuncView = LuaClass(UIView, true)

function TeamRecruitEditFuncView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnForbid = nil
	--self.BtnFreedom = nil
	--self.BtnSure = nil
	--self.PanelProfEditTips = nil
	--self.TableViewFuncEdit = nil
	--self.TableViewLocProf = nil
	--self.TextBubbleTips = nil
	--self.AnimPanelProfEditTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitEditFuncView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnForbid)
	self:AddSubView(self.BtnFreedom)
	self:AddSubView(self.BtnSure)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitEditFuncView:OnPostInit()
	self.TableAdapterLocProf = UIAdapterTableView.CreateAdapter(self, self.TableViewLocProf, self.OnSelectProfChanged)
	self.TableAdapterFuncEdit = UIAdapterTableView.CreateAdapter(self, self.TableViewFuncEdit)

	self.BG:SetTitleText(_G.LSTR(1310070))
	self.BtnFreedom:SetBtnName(_G.LSTR(1310072))
	self.BtnForbid:SetBtnName(_G.LSTR(1310073))
	self.BtnCancel:SetBtnName(_G.LSTR(1310074))
	self.BtnSure:SetBtnName(_G.LSTR(1310075))
end

function TeamRecruitEditFuncView:OnShow()
	local Data = self:GetData(TeamRecruitVM.EditProfVMList)
    TeamRecruitVM.TempEditProfVMList:UpdateByValues(Data)

	--选择职能
	local Idx = TeamRecruitVM.TempEditProfVMList:GetItemIndexByPredicate(function(Item) return Item.HasRole == false end)
	if Idx then
		Idx = math.max(Idx, 1)
		if #Data >= Idx then
			self.TableAdapterLocProf:SetSelectedIndex(Idx)
		end
	end

	--职能编辑提示
	if TeamRecruitVM.ShowProfEditTips then
		UIUtil.SetIsVisible(self.PanelProfEditTips, true)
		self:PlayAnimation(self.AnimPanelProfEditTips)
		TeamRecruitVM.ShowProfEditTips = false

	else
		UIUtil.SetIsVisible(self.PanelProfEditTips, false)
	end
end

function TeamRecruitEditFuncView:OnHide()
	TeamRecruitVM.ShowProfEditTips = false
	TeamRecruitVM.EditSelectProfVMListIdx = nil
	self.TableAdapterLocProf:CancelSelected()
	TeamRecruitVM.TempEditProfVMList:Clear()
end

function TeamRecruitEditFuncView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFreedom, self.OnClickedFreedom)
	UIUtil.AddOnClickedEvent(self, self.BtnForbid, self.OnClickedForbid)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnSure, self.OnClickedSure)
end

function TeamRecruitEditFuncView:OnRegisterGameEvent()

end

function TeamRecruitEditFuncView:OnRegisterBinder()
	local Binders = {
		{ "TempEditProfVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterLocProf) },
		{ "FuncEditVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterFuncEdit) },
	}

	self:RegisterBinders(TeamRecruitVM, Binders)
end

function TeamRecruitEditFuncView:GetData( ProfVMList )
	if nil == ProfVMList then
		return {} 
	end

	local Ret = {}
	local Items = ProfVMList:GetItems() or {}

	for _, v in ipairs(Items) do
		table.insert(Ret, { Loc = v.Loc or 0, RoleID = v.RoleID, Prof = v.Profs or {} })
	end

	return Ret
end

function TeamRecruitEditFuncView:OnSelectProfChanged(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	if ItemData.HasRole then
		self.TableAdapterLocProf:CancelSelected()
		self.TableAdapterLocProf:SetSelectedIndex(TeamRecruitVM.EditSelectProfVMListIdx)
		return
	end

	TeamRecruitVM.EditSelectProfVMListIdx = Index 
end

-------------------------------------------------------------------------------------------------------
--- Component CallBack

function TeamRecruitEditFuncView:OnClickedFreedom()
	local ProfVM = TeamRecruitVM:GetCurSelectTempEditProfVM()
	if nil == ProfVM then
		return
	end

	ProfVM:FullProfs()
	_G.EventMgr:SendEvent(_G.EventID.TeamRecruitFuncEditUpdate)
end

function TeamRecruitEditFuncView:OnClickedForbid()
	local ProfVM = TeamRecruitVM:GetCurSelectTempEditProfVM()
	if nil == ProfVM then
		return
	end

	ProfVM:ClearProfs()
	_G.EventMgr:SendEvent(_G.EventID.TeamRecruitFuncEditUpdate)
end

function TeamRecruitEditFuncView:OnClickedCancel()
	self:Hide()
end

function TeamRecruitEditFuncView:OnClickedSure()
	local Idx = TeamRecruitVM.TempEditProfVMList:GetItemIndexByPredicate(function(Item) return Item:IsCanJoinRole() end)
	if nil == Idx then
		MsgTipsUtil.ShowTips(LSTR(1310034))
		return
	end

	local Data = self:GetData(TeamRecruitVM.TempEditProfVMList)
    TeamRecruitVM.EditProfVMList:UpdateByValues(Data)
	TeamRecruitVM:CalcMembersProf(Data)

	self:Hide()
end

return TeamRecruitEditFuncView