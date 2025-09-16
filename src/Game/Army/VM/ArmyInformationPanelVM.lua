---
--- Author: star
--- DateTime: 2025-01-21 10:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MajorUtil = require("Utils/MajorUtil")
local ArmyEditArmyInformationWinVM = require("Game/Army/VM/ArmyEditArmyInformationWinVM")
local ArmyDefine = require("Game/Army/ArmyDefine")
local GlobalCfgType = ArmyDefine.GlobalCfgType
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local GroupActivityDataCfg = require("TableCfg/GroupActivityDataCfg")
local GroupRecruitProfCfg = require("TableCfg/GroupRecruitProfCfg")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")

local GroupReputationLevelCfg = require("TableCfg/GroupReputationLevelCfg")
local ArmyJoinInfoActivityItemVM = require("Game/Army/ItemVM/ArmyJoinInfoActivityItemVM")
local ArmyJoinInfoViewJobItemVM = require("Game/Army/ItemVM/ArmyJoinInfoViewJobItemVM")
local ProtoCS = require("Protocol/ProtoCS")
local GroupRecruitStatus = ProtoCS.GroupRecruitStatus
local BitUtil = require("Utils/BitUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ProtoRes = require("Protocol/ProtoRes")



---@class ArmyInformationPanelVM : UIViewModel
local ArmyInformationPanelVM = LuaClass(UIViewModel)

---Ctor
function ArmyInformationPanelVM:Ctor()
    self.ActivityList = nil
    self.JobList = nil
	self.IsRecurit = nil
	self.RecruitSlogan = nil
	self.ActivityTimeType = nil
	self.Reputation = nil
	self.CreateTime = nil
	self.ReputationProgressValue = nil
	self.OtherGrandCompanyName1 = nil
	self.OtherGrandCompanyIcon1 = nil
	self.OtherGrandCompanyName2 = nil
	self.OtherGrandCompanyIcon2 = nil
	self.CurGrandCompanyName= nil
	self.CurGrandCompanyIcon = nil
	self.ReputationStr = nil
	self.ReputationColor = nil
	self.EditWinVM = ArmyEditArmyInformationWinVM.New()
	self.IsShowEditBtn = nil
	self.CreateTimeText = nil
end

function ArmyInformationPanelVM:OnInit()
    self.ActivityList = UIBindableList.New( ArmyJoinInfoActivityItemVM )
    self.JobList = UIBindableList.New( ArmyJoinInfoViewJobItemVM )
	self.CreateTime = 0
	self.ReputationProgressValue = 0
	self.EditWinVM:OnInit()
end

function ArmyInformationPanelVM:OnBegin()
	self.EditWinVM:OnBegin()
end

function ArmyInformationPanelVM:OnEnd()
	self.EditWinVM:OnEnd()
end

function ArmyInformationPanelVM:OnShutdown()
	self.EditWinVM:OnShutdown()
end

--- 更新情报数据
function ArmyInformationPanelVM:UpdateInformationData(InformationData)
	self.IsShowEditBtn = _G.ArmyMgr:GetSelfIsHavePermisstion(ProtoRes.GroupPermissionType.GROUP_PERMISSION_TYPE_EditNotice)
    if InformationData then
		self.InformationData = table.clone(InformationData) ---保存数据用于预览处理
		self:UpdateEditData(InformationData)
		self:SetGrandCompanyData(InformationData.GrandCompanyType or 1, InformationData.Reputation or {Level = 1, Exp = 0}) ---设置国防联军UI
		self.CreateTime = InformationData.CreateTime or 0 ---创建时间
		local GainTimeStr = TimeUtil.GetTimeFormat("%Y/%m/%d", self.CreateTime )
		self.CreateTimeText =  LocalizationUtil.GetTimeForFixedFormat(GainTimeStr)---创建时间文本
		self:UpdateEditWinVMCurData()
	end
end

function ArmyInformationPanelVM:UpdateEditWinVMCurData()
	if self.InformationData then
		self.EditWinVM:UpdateCurData(self.InformationData)
	end
end

function ArmyInformationPanelVM:SetGrandCompanyData(GrandCompanyType, Reputation)
	self.Reputation =  Reputation ---友好关系
	if self.Reputation and self.Reputation.Level then
		local NextLevel = self.Reputation.Level + 1
		if NextLevel < 2 then
			---最低1级
			NextLevel = 2
		end
		local ReputationLevelCfg = GroupReputationLevelCfg:FindCfgByKey(NextLevel)
		if ReputationLevelCfg then
			local CurLevelExp = ReputationLevelCfg.Exp
			if self.Reputation.Exp and CurLevelExp then
				self.ReputationProgressValue = self.Reputation.Exp / CurLevelExp
			else
				self.ReputationProgressValue = 0
			end
		else
			---拿不到默认满级
			self.ReputationProgressValue = 1
		end
		
	else
		self.ReputationProgressValue = 0
	end
	self.GrandCompanyType = GrandCompanyType --- 国防联军类型
	local Cfg =  GrandCompanyCfg:FindAllCfg()
	local CurName = ""
	local CurIcon = ""
	local OtherCompanyDatas = {}
	---表格数据，注意只读
	for _, Data in ipairs(Cfg) do
		if Data.ID == self.GrandCompanyType then
			CurName = Data.Name or ""
			CurIcon = Data.EditIcon or ""
		else
			local OtherCompanyData = {
				ID = Data.ID,
				Name = Data.Name,
				Icon = Data.EditIcon,
			}
			table.insert(OtherCompanyDatas, OtherCompanyData)
		end
	end
	self.CurGrandCompanyName= CurName
	self.CurGrandCompanyIcon = CurIcon
	table.sort(OtherCompanyDatas,function(a, b) 
		return a.ID > b.ID
	end)
	for i, OtherData in ipairs(OtherCompanyDatas) do
		--self["OtherGrandCompanyName"..i] = OtherData.Name
		local ReputationText = self:GetReputationText(1)
		local ReputationColor = self:GetReputationColor(1)
		ReputationText = RichTextUtil.GetText(ReputationText, ReputationColor)
		self["OtherGrandCompanyName"..i] = string.format("%s	%s", OtherData.Name, ReputationText)
		self["OtherGrandCompanyIcon"..i] = OtherData.Icon
	end
	---设置关系等级文本
	if Reputation then
		local Level = Reputation.Level
		if Level < 1 then
			---最低1级
			Level = 1
		end
		self.ReputationStr = self:GetReputationText(Level)
		local Color = self:GetReputationColor(Level)
		self.ReputationColor = _G.UE.FLinearColor.FromHex(Color)
	end
end

function ArmyInformationPanelVM:GetReputationText(Level)
	local Cfg = GroupReputationLevelCfg:FindCfgByKey(Level)
	local Str = ""
	if Cfg then
		Str = string.format("%s.%s", Level, Cfg.Text)
	end
	return Str
end

function ArmyInformationPanelVM:GetReputationColor(Level)
	local Cfg = GroupReputationLevelCfg:FindCfgByKey(Level)
	local Color = "FFFFFFFF"
	if Cfg then
		Color = Cfg.Color
	end
	return Color
end

function ArmyInformationPanelVM:GetInformationData()
	return self.InformationData
end
	
function ArmyInformationPanelVM:GetArmyEditArmyInformationWinVM()
	return self.EditWinVM
end

function ArmyInformationPanelVM:UpdateDataByEdit(GroupProfileEdite)
	---用到的字段名是一样的，直接复用
	self:UpdateEditData(GroupProfileEdite)
	self:UpdateInformationDataByEditData(GroupProfileEdite)
	self.EditWinVM:UpdateDataByEdit(GroupProfileEdite)
end

---设置可编辑的数据
function ArmyInformationPanelVM:UpdateEditData(InformationData)
	local ActivityDatas = {}
	if InformationData.ActivityIcons then
		for Index = 0, 64 do
			local ActivityIsOn = BitUtil.IsBitSetByInt64(InformationData.ActivityIcons, Index, false)
			if ActivityIsOn then
				local Cfg = GroupActivityDataCfg:FindCfgByKey(Index + 1)
				if Cfg then
					local Item = {ID = Index + 1, Icon = Cfg.Icon}
					table.insert(ActivityDatas, Item)
				end
			end
		end
	end
	self.ActivityList:UpdateByValues(ActivityDatas)
	local RecruitProfDatas = {}
	if InformationData.RecruitProfs then
		for Index = 0, 64 do
			local RecruitProfsIsOn = BitUtil.IsBitSetByInt64(InformationData.RecruitProfs, Index, false)
			if RecruitProfsIsOn then
				local Cfg = GroupRecruitProfCfg:FindCfgByKey(Index + 1)
				if Cfg then
					local Item = {ID = Index + 1, Icon = Cfg.Icon}
					table.insert(RecruitProfDatas, Item)
				end
			end
		end
	end
	self.JobList:UpdateByValues(RecruitProfDatas)

	self.ActivityTimeType = InformationData.ActivityTimeType or InformationData.ActivityTime--- 活动时间
	self.IsRecurit =  InformationData.RecruitStatus  == GroupRecruitStatus.GROUP_RECRUIT_STATUS_Open ---招募状态
	self.RecruitSlogan = InformationData.RecruitSlogan ---招募标语
end

---编辑数据返回时更新
function ArmyInformationPanelVM:UpdateInformationDataByEditData(GroupProfileEdite)
	self.InformationData.RecruitStatus = GroupProfileEdite.RecruitStatus
	self.InformationData.RecruitSlogan = GroupProfileEdite.RecruitSlogan
	self.InformationData.RecruitProfs = GroupProfileEdite.RecruitProfs
	self.InformationData.ActivityTimeType = GroupProfileEdite.ActivityTime or GroupProfileEdite.ActivityTimeType
	self.InformationData.ActivityIcons = GroupProfileEdite.ActivityIcons
end

function ArmyInformationPanelVM:GetRecruitSlogan()
	return self.RecruitSlogan
end

return ArmyInformationPanelVM
