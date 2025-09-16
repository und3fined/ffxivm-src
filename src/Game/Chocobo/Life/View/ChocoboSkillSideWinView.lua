---
--- Author: Administrator
--- DateTime: 2023-12-14 10:54
--- Description:
---

local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ColorDefine = require("Define/ColorDefine")

local ChocoboMgr = nil
local ChocoboMainVM = nil
local LSTR = nil

local POS_TYPE =
{
	ACTIVE = 1,
	PASSIVE = 2,
}

---@class ChocoboSkillSideWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAuto CommBtnMView
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field HorizontalSkillName UFHorizontalBox
---@field ImgArrow UFImage
---@field ImgSelect UFImage
---@field ImgSelect_1 UFImage
---@field TableViewCarrySkill UTableView
---@field TableViewCarrySkill02 UTableView
---@field TableViewSkillActive UTableView
---@field TableViewSkillPassive UTableView
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field TextSkill01 UFTextBlock
---@field TextSkill02 UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboSkillSideWinView = LuaClass(UIView, true)

function ChocoboSkillSideWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAuto = nil
	--self.CommSidebarFrameS_UIBP = nil
	--self.HorizontalSkillName = nil
	--self.ImgArrow = nil
	--self.ImgSelect = nil
	--self.ImgSelect_1 = nil
	--self.TableViewCarrySkill = nil
	--self.TableViewCarrySkill02 = nil
	--self.TableViewSkillActive = nil
	--self.TableViewSkillPassive = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.TextSkill01 = nil
	--self.TextSkill02 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboSkillSideWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAuto)
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboSkillSideWinView:OnInit()
	LSTR = _G.LSTR
	ChocoboMgr = _G.ChocoboMgr
	ChocoboMainVM = _G.ChocoboMainVM
	self.CurSelectPos = 1
	self.CurSelectPosType = POS_TYPE.ACTIVE
	self.SkillPosVM = nil
	self.ActiveSkillSelectVM = nil
	self.PassiveSkillSelectVM = nil
	self.ActiveSkillVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCarrySkill, nil, nil)
	self.PassiveSkillVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCarrySkill02, nil, nil)
	self.HasActiveSkillVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSkillActive, nil, nil)
	self.HasPassiveSkillVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSkillPassive, nil, nil)
	
	self.HasActiveSkillVMAdapter:SetOnSelectChangedCallback(self.OnActiveSkillItemSelectChange)
	self.HasPassiveSkillVMAdapter:SetOnSelectChangedCallback(self.OnPassiveSkillItemSelectChange)
	self.ActiveSkillVMAdapter:SetOnSelectChangedCallback(self.OnActiveSkillVMAdapterChange)
	self.PassiveSkillVMAdapter:SetOnSelectChangedCallback(self.OnPassiveSkillVMAdapterChange)
end

function ChocoboSkillSideWinView:OnDestroy()

end

function ChocoboSkillSideWinView:OnShow()
	self:InitConstInfo()
	if self.ViewModel == nil then return end
	self.ViewModel:ResetSkillVMList()
	ChocoboMainVM:GetSkillPanelVM():InitHasSkillList(self.ViewModel.ChocoboID)
	self.HasPassiveSkillVMAdapter:SetSelectedIndex(1)
	self.HasActiveSkillVMAdapter:SetSelectedIndex(1)
	self.ActiveSkillVMAdapter:SetSelectedIndex(1)
end

function ChocoboSkillSideWinView:InitConstInfo()
	-- LSTR string: 配置技能
	self.CommSidebarFrameS_UIBP.CommonTitle:SetTextTitleName(_G.LSTR(420028))
	
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	-- LSTR string: 主动
	self.Text01:SetText(_G.LSTR(420026))
	-- LSTR string: 被动
	self.Text02:SetText(_G.LSTR(420027))
	-- LSTR string: 卸载技能
	self.BtnAuto:SetText(_G.LSTR(420029))
end

function ChocoboSkillSideWinView:OnHide()

end

function ChocoboSkillSideWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAuto, self.OnClickAutoBtn)
end

function ChocoboSkillSideWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ChocoboSkillOp, self.OnGameEventChocoboSkillOp)
end

function ChocoboSkillSideWinView:OnRegisterBinder()
	local ChocoboID = self.Params.ChocoboID
	self.ViewModel = ChocoboMainVM:FindChocoboVM(ChocoboID)
	
	if self.ViewModel == nil then return end
	
	local ChocoboBinders = {
		{ "ActiveSkillVMList", UIBinderUpdateBindableList.New(self, self.ActiveSkillVMAdapter) },
		{ "PassiveSkillVMList", UIBinderUpdateBindableList.New(self, self.PassiveSkillVMAdapter) },
	}
	self:RegisterBinders(self.ViewModel, ChocoboBinders)
	
	local Binders =
	{
		{ "HasActiveSkillVMList", UIBinderUpdateBindableList.New(self, self.HasActiveSkillVMAdapter) },
		{ "HasPassiveSkillVMList", UIBinderUpdateBindableList.New(self, self.HasPassiveSkillVMAdapter) },
	}
	self:RegisterBinders(ChocoboMainVM:GetSkillPanelVM(), Binders)
end

function ChocoboSkillSideWinView:OnClickClose1Btn()
	self:Hide()
end

function ChocoboSkillSideWinView:OnClickAutoBtn()
	if self.ViewModel == nil then
		return
	end
	
	local SourceSkillID = 0
	local TargetSkillID = 0
	
	local ID = self.ViewModel.ChocoboID
	local ActiveList = self.ViewModel.Skill.Active
	
	if self.SkillPosVM ~= nil then
		SourceSkillID = self.SkillPosVM.SkillID
	end
	
	if self.CurSelectPosType == POS_TYPE.ACTIVE then
		TargetSkillID = self.ActiveSkillSelectVM.SkillID
	elseif self.CurSelectPosType == POS_TYPE.PASSIVE then
		TargetSkillID = self.PassiveSkillSelectVM.SkillID
	end

	if TargetSkillID == 0 then
		return
	end

	local SkillOp = ProtoCS.SkillOp.OpEquip
	if SourceSkillID == 0 then
		SkillOp = ProtoCS.SkillOp.OpEquip
		for Key, Value in pairs(ActiveList) do
			if Value == TargetSkillID then
				ChocoboMgr:ReqSkillOp(ID, ProtoCS.SkillOp.OpRemove, Key, TargetSkillID)
			end
		end
	elseif SourceSkillID == TargetSkillID then
		SkillOp = ProtoCS.SkillOp.OpRemove
	else
		SkillOp = ProtoCS.SkillOp.OpReplace
		for Key, Value in pairs(ActiveList) do
			if Value == TargetSkillID then
				ChocoboMgr:ReqSkillOp(ID, SkillOp, Key, SourceSkillID)
			end
		end
	end
	ChocoboMgr:ReqSkillOp(ID, SkillOp, self.CurSelectPos, TargetSkillID)
end

function ChocoboSkillSideWinView:OnActiveSkillItemSelectChange(Index, ItemData, ItemView, IsByClick)
	if ItemData == nil then return end

	self.ActiveSkillSelectVM = ItemData
	if self.SkillPosVM ~= nil and self.SkillPosVM.SkillID > 0 then
		if self.ActiveSkillSelectVM.SkillID == self.SkillPosVM.SkillID then
			-- LSTR string: 卸载技能
			self.BtnAuto:SetButtonText(LSTR(420077))
			UIUtil.SetIsVisible(self.ImgArrow, false)
			UIUtil.SetIsVisible(self.TextSkill02, false)
		else
			-- LSTR string: 替换技能
			self.BtnAuto:SetButtonText(LSTR(420078))
			UIUtil.SetIsVisible(self.ImgArrow, true)
			UIUtil.SetIsVisible(self.TextSkill02, true)
			self.TextSkill02:SetText(self.ActiveSkillSelectVM.Name)
		end
	else
		self.TextSkill01:SetText(self.ActiveSkillSelectVM.Name)
	end
end

function ChocoboSkillSideWinView:OnPassiveSkillItemSelectChange(Index, ItemData, ItemView, IsByClick)
	if ItemData == nil then return end

	self.PassiveSkillSelectVM = ItemData
	if self.SkillPosVM ~= nil and self.SkillPosVM.SkillID > 0 then
		if self.PassiveSkillSelectVM.SkillID == self.SkillPosVM.SkillID then
			-- LSTR string: 卸载技能
			self.BtnAuto:SetButtonText(LSTR(420077))
			UIUtil.SetIsVisible(self.ImgArrow, false)
			UIUtil.SetIsVisible(self.TextSkill02, false)
		else
			-- LSTR string: 替换技能
			self.BtnAuto:SetButtonText(LSTR(420078))
			UIUtil.SetIsVisible(self.ImgArrow, true)
			UIUtil.SetIsVisible(self.TextSkill02, true)
			self.TextSkill02:SetText(self.PassiveSkillSelectVM.Name)
		end
	else
		self.TextSkill01:SetText(self.PassiveSkillSelectVM.Name)
	end
end

function ChocoboSkillSideWinView:OnActiveSkillVMAdapterChange(Index, ItemData, ItemView, IsByClick)
	self.PassiveSkillVMAdapter:CancelSelected()
	UIUtil.SetIsVisible(self.ImgSelect, true)
	UIUtil.SetIsVisible(self.ImgSelect_1, false)
	UIUtil.SetIsVisible(self.TableViewSkillActive, true)
	UIUtil.SetIsVisible(self.TableViewSkillPassive, false)
	self.Text01:SetColorAndOpacity(_G.UE.FLinearColor.FromHex("D2BA8EFF"))
	self.Text02:SetColorAndOpacity(_G.UE.FLinearColor.FromHex("D5D5D5FF"))

	self.SkillPosVM = ItemData
	self.CurSelectPos = Index
	self.CurSelectPosType = POS_TYPE.ACTIVE
	if self.ActiveSkillSelectVM ~= nil then
		if self.SkillPosVM.SkillID > 0 then
			if self.ActiveSkillSelectVM.SkillID == self.SkillPosVM.SkillID then
				-- LSTR string: 卸载技能
				self.BtnAuto:SetButtonText(LSTR(420077))
				self.TextSkill01:SetText(self.SkillPosVM.Name)
				self.TextSkill02:SetText(self.ActiveSkillSelectVM.Name)
				UIUtil.SetIsVisible(self.TextSkill02, false)
				UIUtil.SetIsVisible(self.ImgArrow, false)
			else
				-- LSTR string: 替换技能
				self.BtnAuto:SetButtonText(LSTR(420078))
				self.TextSkill01:SetText(self.SkillPosVM.Name)
				self.TextSkill02:SetText(self.ActiveSkillSelectVM.Name)
				UIUtil.SetIsVisible(self.TextSkill02, true)
				UIUtil.SetIsVisible(self.ImgArrow, true)
			end
		else
			-- LSTR string: 装备技能
			self.BtnAuto:SetButtonText(LSTR(420079))
			self.TextSkill01:SetText(self.ActiveSkillSelectVM.Name)
			UIUtil.SetIsVisible(self.ImgArrow, false)
			UIUtil.SetIsVisible(self.TextSkill02, false)
		end
	else
		_G.FLOG_ERROR("ChocoboSkillSideWinView.OnActiveSkillVMAdapterChange.ActiveSkillSelectVM == nil")
	end
end

function ChocoboSkillSideWinView:OnPassiveSkillVMAdapterChange(Index, ItemData, ItemView, IsByClick)
	self.ActiveSkillVMAdapter:CancelSelected()
	UIUtil.SetIsVisible(self.ImgSelect, false)
	UIUtil.SetIsVisible(self.ImgSelect_1, true)
	UIUtil.SetIsVisible(self.TableViewSkillActive, false)
	UIUtil.SetIsVisible(self.TableViewSkillPassive, true)
	self.Text01:SetColorAndOpacity(_G.UE.FLinearColor.FromHex("D5D5D5FF"))
	self.Text02:SetColorAndOpacity(_G.UE.FLinearColor.FromHex("D2BA8EFF"))

	self.SkillPosVM = ItemData
	self.CurSelectPos = Index
	self.CurSelectPosType = POS_TYPE.PASSIVE
	if self.PassiveSkillSelectVM ~= nil then
		if self.SkillPosVM.SkillID > 0 then
			if self.PassiveSkillSelectVM.SkillID == self.SkillPosVM.SkillID then
				-- LSTR string: 卸载技能
				self.BtnAuto:SetButtonText(LSTR(420077))
				self.TextSkill01:SetText(self.SkillPosVM.Name)
				self.TextSkill02:SetText(self.PassiveSkillSelectVM.Name)
				UIUtil.SetIsVisible(self.TextSkill02, false)
				UIUtil.SetIsVisible(self.ImgArrow, false)
			else
				-- LSTR string: 替换技能
				self.BtnAuto:SetButtonText(LSTR(420078))
				self.TextSkill01:SetText(self.SkillPosVM.Name)
				self.TextSkill02:SetText(self.PassiveSkillSelectVM.Name)
				UIUtil.SetIsVisible(self.TextSkill02, true)
				UIUtil.SetIsVisible(self.ImgArrow, true)
			end
		else
			-- LSTR string: 装备技能
			self.BtnAuto:SetButtonText(LSTR(420079))
			self.TextSkill01:SetText(self.PassiveSkillSelectVM.Name)
			UIUtil.SetIsVisible(self.ImgArrow, false)
			UIUtil.SetIsVisible(self.TextSkill02, false)
		end
	else
		_G.FLOG_ERROR("ChocoboSkillSideWinView.OnPassiveSkillVMAdapterChange.PassiveSkillSelectVM == nil")
	end
end

function ChocoboSkillSideWinView:OnGameEventChocoboSkillOp(Params)
	if Params == nil then return end

	local SkillID = Params.SkillID
	local Type = Params.Type
	if SkillID <= 0 then return end

	if Type == ProtoRes.CHOCOBO_RACE_SKILL_CASTING_TYPE.CHOCOBO_RACE_SKILL_CASTING_ACTIVE then
		local SkillVM = self.ActiveSkillVMAdapter:GetItemDataByIndex(self.CurSelectPos)
		if SkillVM ~= nil then
			self:OnActiveSkillVMAdapterChange(self.CurSelectPos, SkillVM)
		end
	elseif Type == ProtoRes.CHOCOBO_RACE_SKILL_CASTING_TYPE.CHOCOBO_RACE_SKILL_CASTING_PASSIVE then
		local SkillVM = self.PassiveSkillVMAdapter:GetItemDataByIndex(self.CurSelectPos)
		if SkillVM ~= nil then
			self:OnPassiveSkillVMAdapterChange(self.CurSelectPos, SkillVM)
		end
	end
end

return ChocoboSkillSideWinView