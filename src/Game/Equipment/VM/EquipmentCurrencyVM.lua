local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local QuestMgr = require("Game/Quest/QuestMgr")
local UIBindableList = require("UI/UIBindableList")
local EquipmentCurrencyItemVM = require("Game/Equipment/VM/EquipmentCurrencyItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreSummaryCfg = require("TableCfg/ScoreSummaryCfg")
local ProtoCS = require("Protocol/ProtoCS")

local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local grand_company_type = ProtoRes.grand_company_type
---@class EquipmentCurrencyVM : UIViewModel
local EquipmentCurrencyVM = LuaClass(UIViewModel)

function EquipmentCurrencyVM:Ctor()
    self.CurrencyItemBindableVMList = UIBindableList.New(EquipmentCurrencyItemVM)
    self.CurrentCurrencyItemBindableParentVMList = UIBindableList.New()
    self.AllScorePossesNum = {}
end

function EquipmentCurrencyVM:UpdateScorePossesNum(Values)
    local ScoreVMMap = self.ScoreVMMap
    for ScoreID, ScoreNum in pairs(Values) do
        local SummCfg = ScoreSummaryCfg:FindCfgByKey(ScoreID)
        if SummCfg ~= nil then
            if ScoreVMMap ~= nil then
                local ScoreVMMapItem = ScoreVMMap[ScoreID]
                if ScoreVMMapItem ~= nil then
					ScoreVMMapItem:UpdateItemNum(ScoreNum)
                end
            end
        end
    end
end

function EquipmentCurrencyVM:UpdateScoreWeekUpper(Values)
    if Values == nil then
        return
    end
    local ScoreVMMap = self.ScoreVMMap
    for _, ScoreInfo in pairs(Values) do
        local SummCfg = ScoreSummaryCfg:FindCfgByKey(ScoreInfo.ID)
        if SummCfg ~= nil then
            if ScoreVMMap ~= nil then
                local ScoreVMMapItem = ScoreVMMap[SummCfg.ID]
				if ScoreVMMapItem ~= nil then
					ScoreVMMapItem:UpdateWeekUpperInfo(ScoreInfo.WeekValue)
				end
			end
		end
	end

end

function EquipmentCurrencyVM:SelectTabType(ScoreSummary)
    local ParentVMList = self.CurrencyItemBindableVMList:GetItems()
    local CurrentVMs = {}
    for i = 1, self.CurrencyItemBindableVMList:Length() do
        local ParentVM = ParentVMList[i]
        if ParentVM.ScoreSummary == ScoreSummary then
            table.insert(CurrentVMs, ParentVM)
        end
    end
    table.sort(CurrentVMs, self.CompTab)
    self.CurrentCurrencyItemBindableParentVMList:Update(CurrentVMs)
end

function EquipmentCurrencyVM:LoadAllScore()
	local AllSummCfg = ScoreSummaryCfg:FindAllCfg("true")
	local SealInfoList = _G.CompanySealMgr:GetCompanySealInfo()
	local AllScoreData = {}

	for _, value in pairs(ProtoRes.SubHeadType) do
		if value > 0 then
			local SubHead
			local SubHeadOrder
			for _, SummCfg in ipairs(AllSummCfg) do
				if SummCfg ~= nil then
					local ScoreID = SummCfg.ID
					local TempScoreNum = _G.ScoreMgr:GetScoreValueByID(ScoreID)
					if value == SummCfg.SubHead then
						--- 军票特殊处理
						if value == ProtoRes.SubHeadType.Score_Seal then
							--- 当前所属军队ID信息
							if SealInfoList.GrandCompanyID ~= 0 then
								SubHead = value
								SubHeadOrder = SummCfg.SubHeadOrder
							end
						else
							if #SummCfg.PreTask > 0 then
								for Key = 1, #SummCfg.PreTask do
									if SummCfg.PreTask[Key] ~= 0 then
										local PreTaskState = QuestMgr:GetQuestStatus(SummCfg.PreTask[Key])
										if PreTaskState == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
											SubHead = value
											SubHeadOrder = SummCfg.SubHeadOrder
											break
										end
									end
								end
							else
								SubHead = value
								SubHeadOrder = SummCfg.SubHeadOrder
							end
						end
						if value == ProtoRes.SubHeadType.Score_Seal then
							--- 当前加入的军队ID
							local TempGrandCompanyID = self:CheckSealIDByScoreID(ScoreID)
							--- 检查是否之前加入过对应军队
							local IsJoined = self:CheckJoinedSealID(TempGrandCompanyID, SealInfoList.MilitaryLevelList)
							local SealLevel = self:CheckJoinedSealLevel(TempGrandCompanyID, SealInfoList.MilitaryLevelList)
							if SealInfoList.GrandCompanyID == TempGrandCompanyID then
								table.insert(AllScoreData, {SubHead = SubHead, SubHeadOrder = SubHeadOrder, ScoreID = SummCfg.ID, ScoreNum = TempScoreNum, CurrencyShowOrder = SummCfg.CurrencyShowOrder, JumpIconPath = SummCfg.JumpIconPath, IsLock = false, SealID = TempGrandCompanyID, SealLevel = SealLevel})
							elseif IsJoined then
								table.insert(AllScoreData, {SubHead = SubHead, SubHeadOrder = SubHeadOrder, ScoreID = SummCfg.ID, ScoreNum = TempScoreNum, CurrencyShowOrder = SummCfg.CurrencyShowOrder, JumpIconPath = SummCfg.JumpIconPath, IsLock = true, SealID = TempGrandCompanyID, SealLevel = SealLevel})
							end
						elseif #SummCfg.PreTask > 0 then
							for Key = 1, #SummCfg.PreTask do
								if SummCfg.PreTask[Key] ~= 0 then
									local PreTaskState = QuestMgr:GetQuestStatus(SummCfg.PreTask[Key])
									if PreTaskState == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
										table.insert(AllScoreData, {SubHead = SubHead, SubHeadOrder = SubHeadOrder, ScoreID = SummCfg.ID, ScoreNum = TempScoreNum, CurrencyShowOrder = SummCfg.CurrencyShowOrder, JumpIconPath = SummCfg.JumpIconPath, IsLock = false})
										break
									end
								end
							end
						else
							table.insert(AllScoreData, {SubHead = SubHead, SubHeadOrder = SubHeadOrder, ScoreID = SummCfg.ID, ScoreNum = TempScoreNum, CurrencyShowOrder = SummCfg.CurrencyShowOrder, JumpIconPath = SummCfg.JumpIconPath})
						end
					end
				end
			end
		end
	end
	table.sort(AllScoreData, self.Comp)
	self.CurrencyItemBindableVMList:UpdateByValues(AllScoreData, nil)

	local ItemVMList = self.CurrencyItemBindableVMList:GetItems()
	self.ScoreVMMap = {}
	for i1 = 1, self.CurrencyItemBindableVMList:Length() do
		local ItemVM = ItemVMList[i1]
		if self.ScoreVMMap[ItemVM.ScoreID] == nil then
			self.ScoreVMMap[ItemVM.ScoreID] = ItemVM
		end
	end
	-- EquipmentCurrencyVM:SelectTabType(ProtoRes.ScoreSummaryType.Mutual)
end

function EquipmentCurrencyVM.CompTab(V1, V2)
	if V1.SubHeadOrder < V2.SubHeadOrder then
		return true
    else
        return false
    end
end

function EquipmentCurrencyVM.Comp(V1, V2)
    if V1.SubHeadOrder == V2.SubHeadOrder then
		if V1.CurrencyShowOrder ~= nil and V2.CurrencyShowOrder ~= nil then
        	return V1.CurrencyShowOrder < V2.CurrencyShowOrder
		else
			return true
		end
    else
        return V1.SubHeadOrder < V2.SubHeadOrder
    end
end

function EquipmentCurrencyVM:CheckSealIDByScoreID(ScoreID)
	if ScoreID == SCORE_TYPE.SCORE_TYPE_MAELSTROM then						--- 黑涡团军票
		return grand_company_type.GRAND_COMPANY_TYPE_Maelstrom
	elseif ScoreID == SCORE_TYPE.SCORE_TYPE_TWINADDER then					--- 双蛇党军票
		return grand_company_type.GRAND_COMPANY_TYPE_OrderOfTheTwinAdder
	elseif ScoreID == SCORE_TYPE.SCORE_TYPE_IMMORTALFLAMES then					--- 恒辉队军票
		return grand_company_type.GRAND_COMPANY_TYPE_ImmortalFlames
	end
end

--- 检查是否加入过对应军队
---@param number SealID number 1黑涡团 2双蛇党 3恒辉队
---@param table MilitaryLevelList table  1黑涡团 2双蛇党 3恒辉队
---@return boolean IsJoined
function EquipmentCurrencyVM:CheckJoinedSealID(SealID, MilitaryLevelList)
	return MilitaryLevelList[SealID] and MilitaryLevelList[SealID] > 0 
end

--- 对应军队等级
---@param number SealID number 1黑涡团 2双蛇党 3恒辉队
---@param table MilitaryLevelList table  1黑涡团 2双蛇党 3恒辉队
---@return number Level
function EquipmentCurrencyVM:CheckJoinedSealLevel(SealID, MilitaryLevelList)
	return MilitaryLevelList[SealID] or 0
end


function EquipmentCurrencyVM:Update(Values)
    self.CurrentCurrencyItemBindableParentVMList:Update(Values)
end

function EquipmentCurrencyVM:FreeAllItems()
    self.CurrencyItemBindableVMList:UpdateByValues(nil, nil)
end

function EquipmentCurrencyVM:UpdateScorePossesNumVM(Value)
    local ScorePossesNum = Value.ScorePossesNum
    local CurrencyItemVM = self:FindCurrencyItemVM(Value.ScoreID)
    if CurrencyItemVM == nil then
        return
    end
    CurrencyItemVM.ScorePossesNum = ScorePossesNum
    CurrencyItemVM.View:UpdateScorePossessNum(ScorePossesNum)
end

function EquipmentCurrencyVM:FindCurrencyItemVM(ScoreID)
    for _, value in pairs(self.CurrencyItemBindableVM) do
        if value.ScoreID == ScoreID then
            return value
        end
    end
    local ErrorInfo = string.format("%s%s", "EquipmentCurrencyVM:FindCurrencyItemVM ScoreID Is Not Existence,ScoreID=", tostring(ScoreID))
    _G.FLOG_ERROR(ErrorInfo)
    return nil
end

---@param   ScoreSummary number  货币总览显示页签类型
---@return  boolean   类型对应Item数据是否存在
function EquipmentCurrencyVM:CheckCurrencyTypeIsExist(ScoreSummary)
    local ParentVMList = self.CurrencyItemBindableVMList:GetItems()
    for i = 1, self.CurrencyItemBindableVMList:Length() do
        local ParentVM = ParentVMList[i]
        if ParentVM.ScoreSummary == ScoreSummary then
            return true
        end
    end
    return false
end

return EquipmentCurrencyVM