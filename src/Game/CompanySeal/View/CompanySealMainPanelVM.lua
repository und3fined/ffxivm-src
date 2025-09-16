--
-- Author: ds_yangyumian
-- Date: 2024-06-3 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local CompanySealList1ItemVM = require("Game/CompanySeal/View/Item/CompanySealList1ItemVM")
local CompanySealList2ItemVM = require("Game/CompanySeal/View/Item/CompanySealList2ItemVM")
local CompanySealSlot126pxItemVM = require("Game/CompanySeal/View/Item/CompanySealSlot126pxItemVM")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIDefine = require("Define/UIDefine")
local LSTR = _G.LSTR
local EToggleButtonState = _G.UE.EToggleButtonState
local CommBtnColorType = UIDefine.CommBtnColorType
local LocalizationUtil = require("Utils/LocalizationUtil")


---@class CompanySealMainPanelVM : UIViewModel
local CompanySealMainPanelVM = LuaClass(UIViewModel)

---Ctor
function CompanySealMainPanelVM:Ctor()
	self.CurTaskList = UIBindableList.New(CompanySealList1ItemVM)
	self.CurItemSelectList = UIBindableList.New(CompanySealSlot126pxItemVM)
	self.CurRewardList = UIBindableList.New(CompanySealSlot126pxItemVM)
	self.CurRareList = UIBindableList.New(CompanySealList2ItemVM)
	self.CurChoseID = nil
	self.TextTime = nil
	self.ToggleButtonState = EToggleButtonState.Unchecked
	self.ConfimBtnVisible = nil
	self.ConfimBtnText = nil
	self.TextSub = nil
	self.RareChoesdList = nil
	self.WarningVisible = nil
	self.BtnColor = CommBtnColorType.Recommend
	self.BtnTextColor = "FFFFFFFF"
	self.IsNeverTips = nil
	self.ArmyLogo = nil
	self.ArmyBG = nil
	self.TagSilverVisible = false
	self.TagSilverText = ""
	self.TagGoldVisible = false
	self.TagGoldText = ""
end

function CompanySealMainPanelVM:OnInit()

end

---UpdateVM
---@param List table
function CompanySealMainPanelVM:UpdateVM()

end

function CompanySealMainPanelVM:OnBegin()

end

function CompanySealMainPanelVM:OnEnd()

end

function CompanySealMainPanelVM:UpdateTaskListInfo(List)
	if List == nil then
		return
	end

	self.CurTaskList:UpdateByValues(List)
end

function CompanySealMainPanelVM:UpdateTaskHasNum()
	local Items = self.CurTaskList:GetItems()
	if Items then
		for i = 1, #Items do
			if Items[i].CurID == CompanySealMgr.CurChoseTaskID then
				for j = 1, #Items[i].ItemList do
					Items[i].ItemList[j].HasItem = _G.BagMgr:GetItemNum(Items[i].ItemList[j].ItemID)
					return
				end
			end
		end
	end
end

function CompanySealMainPanelVM:UpdateSelectListInfo(List)
	if List == nil then
		return
	end

	self.CurItemSelectList:UpdateByValues(List)
end

function CompanySealMainPanelVM:UpdateRareList(List)
	if List == nil then
		return
	end

	self.CurRareList:UpdateByValues(List)
end

function CompanySealMainPanelVM:SetCurItemSelectIndex(Index)
	if self.CurItemSelectList == nil then
		return
	end
	local Items = self.CurItemSelectList:GetItems()
	if Items then
		if #Items > 1 then
			for i = 1, #Items do
				Items[i].IsSelect = Index == i
			end
		else
			Items[1].IsSelect = false
		end
	end
end

function CompanySealMainPanelVM:SetRareListSelectIndex(Index)
	if self.CurRareList == nil then
		return
	end
	local Items = self.CurRareList:GetItems()
	if Items and #Items ~= 0 then
		Items[Index].ToggleButtonState = 0
	end
end

--TaskIndex 页签下标
function CompanySealMainPanelVM:UpdateRewardNum(TaskIndex, IsHQ)
	if self.CurRewardList == nil then
		return
	end
	
	local TaskInfo 
	if CompanySealMgr.AllTaskList[TaskIndex] ~= nil then
		TaskInfo = CompanySealMgr.AllTaskList[TaskIndex].TaskList[CompanySealMgr.CurChoseTaskIndex]
	end

	if TaskInfo == nil then
		FLOG_ERROR("TaskIndex = %d， CurChoseTaskIndex = %d", TaskIndex, CompanySealMgr.CurChoseTaskIndex)
		return
	end
	
	local Items = self.CurRewardList:GetItems()

	local Exp = 0
	local CompanySeal = 0
	if Items then
		for i = 1, #Items do
			if IsHQ and TaskInfo.Times > 1 then
				Exp = TaskInfo.Exp * 2 * TaskInfo.Times
				CompanySeal = TaskInfo.CompanySeal * 2 * TaskInfo.Times
			elseif IsHQ and TaskInfo.Times <= 1 then
				Exp = TaskInfo.Exp * 2
				CompanySeal = TaskInfo.CompanySeal * 2
			elseif not IsHQ and TaskInfo.Times > 1 then
				Exp = TaskInfo.Exp * TaskInfo.Times
				CompanySeal = TaskInfo.CompanySeal * TaskInfo.Times
			elseif not IsHQ and TaskInfo.Times <= 1 then
				Exp = TaskInfo.Exp
				CompanySeal = TaskInfo.CompanySeal
			end

			if i == 1 then
				Items[i].Num = _G.ScoreMgr.FormatScore(Exp)
				CompanySealMgr.GetRewardList[1] = {}
				CompanySealMgr.GetRewardList[1].Num = Exp
			else
				Items[i].Num = _G.ScoreMgr.FormatScore(CompanySeal)
				CompanySealMgr.GetRewardList[2] = {}
				CompanySealMgr.GetRewardList[2].Num = CompanySeal
			end
			Items[i].NumVisible = true
		end
	end

	local CompanysealInfo = CompanySealMgr.CompanyRankList[CompanySealMgr.GrandCompanyID]
	local MilitaryLv = CompanySealMgr:GetMilitaryLvByGrandCompanyID(CompanySealMgr.GrandCompanyID)
	local CurHas = _G.ScoreMgr:GetScoreValueByID(CompanySealMgr.CompanySealID)
	local Max = CompanysealInfo[MilitaryLv].CompanySealMax or 0
	self.WarningVisible = CurHas + CompanySeal >= Max
end

function CompanySealMainPanelVM:UpdateRewardList(List)
	if List == nil then
		return
	end

	local CurAllNum = List[1].Num or 0
	local CompanysealInfo = CompanySealMgr.CompanyRankList[CompanySealMgr.GrandCompanyID]
	local MilitaryLv = CompanySealMgr:GetMilitaryLvByGrandCompanyID(CompanySealMgr.GrandCompanyID)
	local CurHas = _G.ScoreMgr:GetScoreValueByID(CompanySealMgr.CompanySealID)
	local Max = CompanysealInfo[MilitaryLv].CompanySealMax or 0
	self.WarningVisible = CurHas + CurAllNum >= Max
	self.CurRewardList:UpdateByValues(List)
end

function CompanySealMainPanelVM:UpdateTimeText(Time)
	local TimeString = LocalizationUtil.GetCountdownTimeForLongTime(Time)
	self.TextTime = string.format("%s:%s", LSTR(1160014), TimeString)
	--local Hour = math.floor(Time / 3600)
	--local Min = math.floor(Time % 3600 / 60)
	--self.TextTime = string.format("%s:%s%s%s%s", LSTR(1160014), math.ceil(Hour), LSTR(1160036), math.ceil(Min), LSTR(1160013))
end

function CompanySealMainPanelVM:SetAllSlecteBtnState(Value)
	local State =  UIUtil.IsToggleButtonChecked(self.ToggleButtonState)
	if not Value and State then
		self.ToggleButtonState = EToggleButtonState.Unchecked
	end
end

function CompanySealMainPanelVM:UpdateBtnColor(Value)
	if Value then
		self.BtnColor = CommBtnColorType.Recommend
		self.BtnTextColor = "FFFFFFFF"
	else
		self.BtnColor = CommBtnColorType.Disable
		self.BtnTextColor = "828282FF"
	end
end

function CompanySealMainPanelVM:ChosedAllRare()
	local State =  UIUtil.IsToggleButtonChecked(self.ToggleButtonState)
	if State then
		self.ToggleButtonState = EToggleButtonState.Unchecked
		for i = 1, #CompanySealMgr.RareChoesdList do
			CompanySealMgr.RareChoesdList[i].ItemID = nil
		end
		CompanySealMgr.RecordRareChoesd = {}
	else
		if #CompanySealMgr.RecordRareChoesd >= CompanySealMgr.RareChoseLimit then
			self.ToggleButtonState = EToggleButtonState.Unchecked
			return
		end

		self.ToggleButtonState = EToggleButtonState.Checked
		for i = 1, #CompanySealMgr.RareTaskList do
			if #CompanySealMgr.RecordRareChoesd >= CompanySealMgr.RareChoseLimit then
				break
			end
			CompanySealMgr.RareChoesdList[#CompanySealMgr.RecordRareChoesd + 1].ItemID = CompanySealMgr.RareTaskList[i].ResID
			table.insert(CompanySealMgr.RecordRareChoesd, CompanySealMgr.RareTaskList[i].ResID)
			-- if not CompanySealMgr.RecordRareChoesd[CompanySealMgr.RareTaskList[i].ResID] then

			-- end
		end
	end
	EventMgr:SendEvent(EventID.CompanySealUpdateRareChoseList)
end

--State CompanySealMgr SortRuler任务状态
function CompanySealMainPanelVM:UpdateConfimBtnState(State, IsHQ, Times, IsMatch)
	self.ConfimBtnVisible = true
	self.BtnTextColor = "FFFFFFFF"
	if not IsMatch and State ~= 5 then
		self.ConfimBtnText = LSTR(1160015)
		self.BtnColor = CommBtnColorType.Recommend
		return
	end
	
	if State == 1 or State == 2 or State == 3 then
		self.ConfimBtnText = LSTR(1160033)  --提交
		self.BtnColor = CommBtnColorType.Recommend
	elseif State == 4 then
		self.ConfimBtnText = LSTR(1160015)  --前往
		self.BtnColor = CommBtnColorType.Recommend
	elseif State == 5 then
		self.ConfimBtnText = LSTR(1160077)  --前往转职
		self.BtnColor = CommBtnColorType.Recommend
	elseif State == 6 then
		self.BtnColor = CommBtnColorType.Done
		self.BtnTextColor = "B2B2B2FF"
		self.ConfimBtnText =  LSTR(1160028)  --已提交
		self:SetTagState(IsHQ, Times)
	end

end

function CompanySealMainPanelVM:UpdateLogoIcon()
	self.ArmyLogo = CompanySealMgr:GetLogoPath(CompanySealMgr.GrandCompanyID)
end

function CompanySealMainPanelVM:UpdateBGIcon()
	self.ArmyBG = CompanySealMgr:GetBgPath(CompanySealMgr.GrandCompanyID)
	self:UpdateLogoIcon()
end

function CompanySealMainPanelVM:SetTagState(IsHQ, Times)
	if Times > 1 and IsHQ then
		self.TagGoldVisible = true
		self.TagSilverVisible = false
		self.TagGoldText = "400%"
	elseif Times > 1 or IsHQ then
		self.TagGoldVisible = false
		self.TagSilverVisible = true
		self.TagSilverText = "200%"
	else
		self.TagGoldVisible = false
		self.TagSilverVisible = false
	end
end



return CompanySealMainPanelVM