---
--- Author: daniel
--- DateTime: 2023-03-07 17:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ArmyDefine = require("Game/Army/ArmyDefine")
local UnitedArmyTabs = ArmyDefine.UnitedArmyTabs

local ArmyCreatePanelVM = nil
local ArmyMgr
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmySelectMainArmyPageVM = require("Game/Army/VM/ArmySelectMainArmyPageVM")
---@class ArmyCreatePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EditInfo ArmyEditInfoPageView
---@field SelectMainArmy ArmySelectMainArmyPageView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyCreatePanelView = LuaClass(UIView, true)

local function Callback()
	ArmyCreatePanelVM:SetIsOpenEdit(false)
end
local function CommitedCallback(Name, ShortName, BadgeData)
	---领取组建书逻辑,未领取组件书的先领取组建书
	local IsGivePeition = ArmyCreatePanelVM:GetIsGivePeition()
	if not IsGivePeition then
		local GroupPetition = {
			GrandCompanyType = ArmyCreatePanelVM.GrandID,
			Name = Name,
			Alias = ShortName,
			Emblem = BadgeData,
		}	
		ArmyMgr:SendGroupPeitionGain(GroupPetition)
	else
		ArmyMgr:SendArmyCreateMsg(ArmyCreatePanelVM.GrandID, Name, ShortName, BadgeData)
	end
end

function ArmyCreatePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EditInfo = nil
	--self.SelectMainArmy = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyCreatePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EditInfo)
	self:AddSubView(self.SelectMainArmy)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyCreatePanelView:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	ArmyCreatePanelVM = ArmyMainVM:GetCreatePanelVM()
	self.ArmySelectMainArmyPageVM = ArmySelectMainArmyPageVM.New()
	self.ArmySelectMainArmyPageVM:OnInit()
	self.ArmySelectMainArmyPageVM:SetSetBGCallbak(self.SetBGCallbak)
	self.SelectMainArmy:SetVM(self.ArmySelectMainArmyPageVM)
	self.SelectMainArmy:SetSelectCallBack(self, self.OnClickedSelectUnion)
	self.Binders = {
		{ "bSelectMain", UIBinderSetIsVisible.New(self, self.SelectMainArmy)},
		{ "bEditInfo", UIBinderSetIsVisible.New(self, self.EditInfo)},
		--- 条件判断修修改放到View中判断
		{ "bResetEidtInfo", UIBinderValueChangedCallback.New(self, nil, self.OnResetEidtInfoChange)},
		{ "RecruitSlogan", UIBinderValueChangedCallback.New(self, nil, self.OnRecruitSloganChange)},
		{ "CreateSucceed", UIBinderValueChangedCallback.New(self, nil, self.OnCreateSucceed)},
		{ "PetitionData", UIBinderValueChangedCallback.New(self, nil, self.OnPetitionDataChanged)},
	}
end

function ArmyCreatePanelView:OnDestroy()

end

function ArmyCreatePanelView:OnPetitionDataChanged(PetitionData)
	local IsGivePeition = ArmyCreatePanelVM:GetIsGivePeition()
	self.EditInfo:SetIsGivePeition(IsGivePeition, PetitionData)
	if IsGivePeition then
		ArmyMainVM:SetBGIcon(ArmyCreatePanelVM.GrandID)
		self.EditInfo:SetCallback(ArmyCreatePanelVM.GrandID, function() 
			self.ArmySelectMainArmyPageVM:SetIsPlayAnimReturn(true)
			ArmyCreatePanelVM:SetIsOpenEdit(false)
		end, CommitedCallback)
		self.EditInfo:SetCreateData(ArmyCreatePanelVM.bCreate)
	end
end

function ArmyCreatePanelView.SetBGCallbak(GrandCompanyID)
	ArmyMainVM:SetBGIcon(GrandCompanyID)
end

function ArmyCreatePanelView:OnShow()
	---已在registerbinder时随机
	--self.SelectMainArmy:FlagSortRandomly()
	if ArmyCreatePanelVM:GetbSelectMain() then
		self.SelectMainArmy:PlayAnimInFlag()
		--self.SelectMainArmy:SetIsPlayAnimInFlag(true)
	elseif ArmyCreatePanelVM:GetbEditInfo() then
		if ArmyMainVM:GetbCreatePanel() then
			self.EditInfo:PlayAnimShow()
			self.EditInfo:SetCreateData(ArmyCreatePanelVM.bCreate)
		end
		local IsGivePeition = ArmyCreatePanelVM:GetIsGivePeition()
		if not IsGivePeition  then
			local GrandCompanyID =  ArmyCreatePanelVM:GetSelectedUnionID()
			if GrandCompanyID then
				ArmyMainVM:SetBGIcon(GrandCompanyID)
				self.EditInfo:PlayAnimCheck()
				self.EditInfo:SetCallback(GrandCompanyID, function() 
					self.ArmySelectMainArmyPageVM:SetIsPlayAnimReturn(true)
					ArmyCreatePanelVM:SetIsOpenEdit(false)
				end, CommitedCallback)
			end
		end
	end
	--self.ArmySelectMainArmyPageVM:SetIsMenuSwitchShow(true)
	--local GrandCompanyID = self.ArmySelectMainArmyPageVM:GetSelectedGrandCompanyID()
	--ArmyMainVM:SetBGIcon(GrandCompanyID)
	--ArmyMainVM:SetIsMask(false)
end

function ArmyCreatePanelView:OnHide()
	--self.EditInfo:ClearCurGrandID()
	--ArmyMainVM:SetIsMask(true)
end

function ArmyCreatePanelView:OnRegisterUIEvent()
	--- todo 确认按钮改为在子蓝图自己处理
	--UIUtil.AddOnClickedEvent(self, self.SelectMainArmy.BtnHeiWo, self.OnClickedSelectUnion, UnitedArmyTabs[1].ID)
	--UIUtil.AddOnClickedEvent(self, self.SelectMainArmy.BtnShuangShe, self.OnClickedSelectUnion, UnitedArmyTabs[2].ID)
	--UIUtil.AddOnClickedEvent(self, self.SelectMainArmy.BtnHengHui, self.OnClickedSelectUnion, UnitedArmyTabs[3].ID)
end

function ArmyCreatePanelView:OnRegisterGameEvent()

end

function ArmyCreatePanelView:OnRegisterBinder()
	---子UIonshow触发在父UI之前，在这里进行一次随机
	self.ArmySelectMainArmyPageVM:FlagSortRandomly()
	self:RegisterBinders(ArmyCreatePanelVM, self.Binders)
	--self.SelectMainArmy:RefreshVM(ArmyCreatePanelVM)
end

function ArmyCreatePanelView:OnResetEidtInfoChange()
	if ArmyCreatePanelVM.bResetEidtInfo then
		ArmyCreatePanelVM.bResetEidtInfo = false
		self.EditInfo:ResetInfo()
	end
end

--- 选择部队大国防联军
function ArmyCreatePanelView:OnClickedSelectUnion(ID)
	local OldUnionID = ArmyCreatePanelVM:GetSelectedUnionID()
	ArmyCreatePanelVM:SelectedUnionID(ID)
	self.EditInfo:PlayAnimCheck()
	self.EditInfo:SetCallback(ID, function()
		self.ArmySelectMainArmyPageVM:SetIsPlayAnimReturn(true)
		ArmyCreatePanelVM:SetIsOpenEdit(false)
	end, CommitedCallback)
	self.EditInfo:SetCreateData(ArmyCreatePanelVM.bCreate)
	---考虑到有可能会有专属寓意物，等寓意物判定完成才发送变更
	local IsGivePeition = ArmyCreatePanelVM:GetIsGivePeition()
	if IsGivePeition and OldUnionID ~= ID then
		ArmyCreatePanelVM:SendGroupPeitionEdit()
	end
end

function ArmyCreatePanelView:OnRecruitSloganChange(RecruitSlogan)
	if RecruitSlogan then
		self.EditInfo:SetRecruitSlogan(RecruitSlogan)
		ArmyCreatePanelVM:ClaerRecruitSlogan()
	end
end

function ArmyCreatePanelView:OnCreateSucceed(CreateSucceed)
	if CreateSucceed then
		self.EditInfo.CreateCallback = ArmyCreatePanelVM:GetCreateCallBack()
		self.EditInfo:PlayAnimCreate()
		ArmyCreatePanelVM:ArmySetCreateSucceed(false)
	end
end


function ArmyCreatePanelView:IsForceGC()
	return true
end

return ArmyCreatePanelView