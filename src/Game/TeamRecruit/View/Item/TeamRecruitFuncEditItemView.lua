---
--- Author: xingcaicao
--- DateTime: 2023-05-27 17:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")

---@class TeamRecruitFuncEditItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EditProfSlot1 TeamRecruitEditProfSlotView
---@field EditProfSlot2 TeamRecruitEditProfSlotView
---@field EditProfSlot3 TeamRecruitEditProfSlotView
---@field EditProfSlot4 TeamRecruitEditProfSlotView
---@field EditProfSlot5 TeamRecruitEditProfSlotView
---@field EditProfSlot6 TeamRecruitEditProfSlotView
---@field EditProfSlot7 TeamRecruitEditProfSlotView
---@field ImgColor UFImage
---@field ImgLine UFImage
---@field ImgProfType UFImage
---@field SingleBoxAllSelect CommCheckBoxView
---@field TextProfType UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitFuncEditItemView = LuaClass(UIView, true)

function TeamRecruitFuncEditItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EditProfSlot1 = nil
	--self.EditProfSlot2 = nil
	--self.EditProfSlot3 = nil
	--self.EditProfSlot4 = nil
	--self.EditProfSlot5 = nil
	--self.EditProfSlot6 = nil
	--self.EditProfSlot7 = nil
	--self.ImgColor = nil
	--self.ImgLine = nil
	--self.ImgProfType = nil
	--self.SingleBoxAllSelect = nil
	--self.TextProfType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitFuncEditItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EditProfSlot1)
	self:AddSubView(self.EditProfSlot2)
	self:AddSubView(self.EditProfSlot3)
	self:AddSubView(self.EditProfSlot4)
	self:AddSubView(self.EditProfSlot5)
	self:AddSubView(self.EditProfSlot6)
	self:AddSubView(self.EditProfSlot7)
	self:AddSubView(self.SingleBoxAllSelect)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitFuncEditItemView:OnPostInit()
	self.SingleBoxAllSelect.TextContent:SetText(_G.LSTR(1310106))
end

function TeamRecruitFuncEditItemView:OnShow()
	if nil == self.ViewModel then
		return
	end

	--图标
	UIUtil.ImageSetBrushFromAssetPath(self.ImgProfType, self.ViewModel.Icon or "")

	--名称
	self.TextProfType:SetText(self.ViewModel.Name or "")

	--职业信息
	self:SetFuncProfInfo()

	--线条
	UIUtil.SetIsVisible(self.ImgLine, not self.ViewModel.IsLastItem)

	local ProtoCommon = require("Protocol/ProtoCommon")
	local CLASS_TYPE = ProtoCommon.class_type
	local ImgBg
	if self.ViewModel.ClassType == CLASS_TYPE.CLASS_TYPE_TANK then
		ImgBg = "Texture2D'/Game/UI/Texture/Team/UI_Team_Img_Win_EditJob_Blue.UI_Team_Img_Win_EditJob_Blue'"
	elseif self.ViewModel.ClassType == CLASS_TYPE.CLASS_TYPE_HEALTH then
		ImgBg = "Texture2D'/Game/UI/Texture/Team/UI_Team_Img_Win_EditJob_Green.UI_Team_Img_Win_EditJob_Green'"
	else
		ImgBg = "Texture2D'/Game/UI/Texture/Team/UI_Team_Img_Win_EditJob_Red.UI_Team_Img_Win_EditJob_Red'"
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgColor, ImgBg)
end

function TeamRecruitFuncEditItemView:OnHide()

end

function TeamRecruitFuncEditItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxAllSelect, self.OnToggleStateChanged)
end

function TeamRecruitFuncEditItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TeamRecruitFuncEditUpdate, self.OnGameEventUpdateFunc)
end

function TeamRecruitFuncEditItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.ViewModel = Params.Data
	self.ProfInfoList = self.ViewModel.ProfInfoList

	local Binders = {
		{ "EditSelectProfVMListIdx", UIBinderValueChangedCallback.New(self, nil, self.OnEditSelectFuncIdxChanged) },
	}

	self:RegisterBinders(TeamRecruitVM, Binders)
end

function TeamRecruitFuncEditItemView:SetFuncProfInfo()
	if nil == self.ProfInfoList then
		return
	end

	for i = 1, 7 do
		local Slot = self["EditProfSlot" .. i]
		if Slot then
			local ProfInfo = self.ProfInfoList[i]
			if ProfInfo then
				UIUtil.SetIsVisible(Slot, true)
				Slot:SetProf(ProfInfo.Prof, ProfInfo.Icon)
				Slot:SetParentView(self)

			else
				UIUtil.SetIsVisible(Slot, false)
			end
		end
	end
end

function TeamRecruitFuncEditItemView:OnEditSelectFuncIdxChanged()
	if nil == self.ProfInfoList then
		return
	end

	local ProfVM = TeamRecruitVM:GetCurSelectTempEditProfVM()
	if nil == ProfVM then
		return
	end

	local IsFull = true 
	local CurProfs = ProfVM.Profs

	for i = 1, 7 do
		local Slot = self["EditProfSlot" .. i]
		if Slot then
			local ProfInfo = self.ProfInfoList[i]
			if ProfInfo then
				local IsContain = table.contain(CurProfs, ProfInfo.Prof)
				Slot:SetIsChecked(IsContain, false)

				IsFull = IsFull and IsContain 
			end
		end
	end

	--全选开关
	self.SingleBoxAllSelect:SetChecked(IsFull)
end

function TeamRecruitFuncEditItemView:OnToggleStateChanged(ToggleButton, State)
	if nil == self.ProfInfoList then
		return
	end

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	for i = 1, 7 do
		local Slot = self["EditProfSlot" .. i]
		if Slot then
			local ProfInfo = self.ProfInfoList[i]
			if ProfInfo then
				Slot:SetIsChecked(IsChecked)
			end
		end
	end

	local ProfVM = TeamRecruitVM:GetCurSelectTempEditProfVM()
	if nil == ProfVM then
		return
	end

	if IsChecked then
		local Profs = {}
		for _, v in pairs(self.ProfInfoList) do
			table.insert(Profs, v.Prof)
		end
		ProfVM:BatchAddProfs(Profs, true)
	end

	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	
	local Profs = {}
	if not IsChecked then
		Profs = TeamRecruitUtil.GetOpenProfsByClass(self.ViewModel.ClassType)
	end
	for _, v in ipairs(TeamRecruitUtil.GetOpenNonBattleProfs()) do
		table.insert(Profs, v)
	end
	ProfVM:BatchRemove(Profs)
end

function TeamRecruitFuncEditItemView:CheckSingleBoxAllSelectState()
	if nil == self.ProfInfoList then
		return
	end

	local ProfVM = TeamRecruitVM:GetCurSelectTempEditProfVM()
	if nil == ProfVM then
		return	
	end

	local IsFull = true 
	local CurProfs = ProfVM.Profs

	for _, v in pairs(self.ProfInfoList) do
		if not table.contain(CurProfs, v.Prof) then
			IsFull = false
			break
		end
	end

	--全选开关
	self.SingleBoxAllSelect:SetChecked(IsFull)
end

function TeamRecruitFuncEditItemView:OnGameEventUpdateFunc()
	self:OnEditSelectFuncIdxChanged()
end

return TeamRecruitFuncEditItemView