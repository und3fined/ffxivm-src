--
-- Author: ashyuan
-- Date: 2024-4-8
-- Description:副本教学
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ProtoRes = require("Protocol/ProtoRes")
local TeachingType = require("Game/Pworld/Teaching/TeachingType")
local UIInteractiveUtil = require("Game/PWorld/UIInteractive/UIInteractiveUtil")
local TeachingDefine = require("Game/Pworld/Teaching/TeachingDefine")
local PworldCfg = require("TableCfg/PworldCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")
local PWorldStagePanelVM = require("Game/PWorld/Warning/PWorldStagePanelVM")

local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

---@class TeachingMgr : MgrBase
local TeachingMgr = LuaClass(MgrBase)

function TeachingMgr:OnInit()
    self.UIType = ProtoRes.pworld_ui_type.PWORLD_UI_TEACH                       -- ui类型
    self.MainUIViewID = UIViewID.PWorldTeachingPanel                            -- UIViewID
    self.ContentUIViewID = UIViewID.PWorldTeachingContentPanel                  -- 
	
    self.InitConfig = false
	self.IsTeachScene = false
	self.SendInteractiveID = 0
    self.CurrentInteractiveID = 0
	--self.SelectedLevel = 1
end

function TeachingMgr:OnBegin()
    local SearchConditions = string.format("IsTeachScene=%d", 1)
	local Cfg = PworldCfg:FindCfg(SearchConditions)
    self.TeachingWorldID = Cfg and Cfg.ID or 0
end

-- function TeachingMgr:SetSelectedLevel(SelectedLevel)
-- 	self.SelectedLevel = SelectedLevel
-- end

function TeachingMgr:GetShowLevel()
    local MajorProfID = MajorUtil.GetMajorAttributeComponent().ProfID
	local MajorClass = RoleInitCfg:FindProfClass(MajorProfID)
    local CfgMap = self:GetTableByProf(MajorClass)

    -- 默认显示玩家未完成的那个难度
    for DiffLevel,ItemList in ipairs(CfgMap) do
        if not self:IsItemListCompleted(ItemList) then
            return DiffLevel
        end
    end
    
    -- 都完成的话就显示高级难度
    return TeachingType.Diff_Type.Hight
end

function TeachingMgr:IsSelected(InteractiveID)
    if self.IsTeachScene then
        return self.CurrentInteractiveID == InteractiveID
    else
        return false
    end
end

--- 返回当前是否正在挑战中
function TeachingMgr:IsInTeaching()
    return self.IsTeachScene and self.CurrentInteractiveID > 0
end

function TeachingMgr:ResetTeachCfgMap()
    self.TeachCfgMap = {}
    for job_key, job_value in pairs(TeachingType.Job_Type) do
        self.TeachCfgMap[job_value] = {}
        for diff_key, diff_value in pairs(TeachingType.Diff_Type) do
            self.TeachCfgMap[job_value][diff_value] = {}
        end
    end
    self.InitConfig = false
end

function TeachingMgr:InitTeachCfgMap()

    if self.InitConfig then
        return true
    end

    self:ResetTeachCfgMap()

    local TeachUICfg = UIInteractiveUtil.GetInteractiveConfig(self.UIType)

    for i = 1, #TeachUICfg do

        local Param = TeachUICfg[i].Param
        if (Param == nil or Param[1] == nil or Param[2] == nil) then
            FLOG_ERROR("InitTeachCfgMap Error! Param Null")
            return false
        end

        local StrParam = TeachUICfg[i].StrParam
        if (StrParam == nil or StrParam[1] == nil or StrParam[2] == nil or StrParam[3] == nil) then
            FLOG_ERROR("InitTeachCfgMap Error! StrParam Null")
            return false
        end

        -- 读取参数
        local InteractiveID = TeachUICfg[i].InteractiveID
        local DiffType = Param[1]
        local JobType = Param[2]
        local LevelLimit = Param[3]
        local TeachContent = StrParam[1]
        local TeachItemList = {}
        
        -- 每个挑战的信息
        for item in string.gmatch(StrParam[2], "([^;]+)") do
            local TeachItem = {Desc = item, State = TeachingType.Item_State.UnOpened}
            table.insert(TeachItemList, TeachItem)
        end

        local TeachBackImg = StrParam[3]

        -- 挑战目标，包含多个挑战
        local TeachItemInfo = {Content = TeachContent, InteractiveID = InteractiveID, ItemList = TeachItemList, LevelLimit = LevelLimit, BackImg = TeachBackImg}

        -- 插入不同难度和职能分段
        table.insert(self.TeachCfgMap[JobType][DiffType], TeachItemInfo)
	end

    self.InitConfig = true

    return true
end

function TeachingMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventExitWorld)

	self:RegisterGameEvent(EventID.PWorldUIChange, self.OnPWorldUIChange)
	self:RegisterGameEvent(EventID.PWorldSkillTip, self.OnPWorldSkillTip)
end

function TeachingMgr:OnPWorldUIChange(UIType, ResultType)
    if UIType == ProtoRes.action_change_ui_type.ACTION_CHANGE_UI_TYPE_SPECIAL_TRAINING_SIGN then
        if ResultType == ProtoRes.action_challenge_result_type.ACTION_CHALLENGE_RESULT_TYPE_START then  --显示Content窗口
            self:OnShowContentWindow(self.CurrentInteractiveID)
        end
    elseif UIType == ProtoRes.action_change_ui_type.ACTION_CHANGE_UI_TYPE_SPECIAL_TRAINING_TIPS then
        self:OnShowPWorldGuideTip(ResultType)   --显示Tips窗口
    end
    FLOG_INFO("TeachingMgr:OnPWorldUIChange (Type:%d, Result:%d)", UIType, ResultType)
end

function TeachingMgr:OnPWorldSkillTip(Index)
    local Params = { Index = Index }
    UIViewMgr:ShowView(UIViewID.PWorldSkillGuidancePanel, Params)
end

function TeachingMgr:OnGameEventEnterWorld()
    local PWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
	local Value = PworldCfg:FindValue(PWorldResID, "IsTeachScene")
    self.IsTeachScene = nil ~= Value and Value > 0
    if self.IsTeachScene then
        -- 发送交互事件
        if self.SendInteractiveID > 0 then
            UIInteractiveUtil.SendInteractiveReq(self.SendInteractiveID)
            --self:OnShowContentWindow(self.SendInteractiveID)
        else
            FLOG_ERROR("TeachingMgr:OnGameEventEnterWorld No SendInteractiveID")
        end

        self:OnEnterWorldSetUI()
    end
    _G.EventMgr:SendEvent(EventID.PWorldTeachingStateChange)
end

function TeachingMgr:OnGameEventExitWorld()
    if self.IsTeachScene then
        self:OnLevelWorldSetUI()
    end
end

function TeachingMgr:OnEnterWorldSetUI()
    MainPanelVM:SetTeachingLevelVisible(true)
    PWorldStagePanelVM:SetSettingVisible(false)

    self.TopLeftUIVisible = MainPanelVM:GetTopLeftMainTeamPanelVisible()
    if self.TopLeftUIVisible then
		self.TopLeftUIVisible = false
        MainPanelVM:SetTopLeftMainTeamPanelVisible(false)
    end
end

function TeachingMgr:OnLevelWorldSetUI()
    MainPanelVM:SetTeachingLevelVisible(false)
    PWorldStagePanelVM:SetSettingVisible(true)

    if not self.TopLeftUIVisible then
        MainPanelVM:SetTopLeftMainTeamPanelVisible(true)
    end
end

function TeachingMgr:OnShowMainWindow()
    local HaveCfg = self:InitTeachCfgMap()
    if HaveCfg then
        UIViewMgr:ShowView(self.MainUIViewID)
    else
        FLOG_ERROR("InitTeachCfgMap Fail!!!")
    end
end

function TeachingMgr:OnShowContentWindow(InteractiveID)
    local HaveCfg = self:InitTeachCfgMap()
    if HaveCfg then
        if UIViewMgr:IsViewVisible(self.ContentUIViewID) then
            _G.EventMgr:SendEvent(_G.EventID.PWorldItemChange, InteractiveID)
        else
            local Params = { InteractiveID = InteractiveID }
            UIViewMgr:ShowView(self.ContentUIViewID, Params)
        end
    else
        FLOG_ERROR("InitTeachCfgMap Fail!!!")
    end
end

function TeachingMgr:OnShowPWorldGuideTip(GuideID)
    local Params = {}
	Params.ID = GuideID
	Params.PWorldTeaching = true
	UIViewMgr:ShowView(UIViewID.TutorialGuideShowPanel, Params)
end

function TeachingMgr:GetJobTypeInfoFromProfClass(ProfClass)
    if ProfClass == ProtoCommon.class_type.CLASS_TYPE_TANK then
        return TeachingDefine.JobTypeInfos[1]
    elseif ProfClass == ProtoCommon.class_type.CLASS_TYPE_HEALTH then
        return TeachingDefine.JobTypeInfos[2]
    elseif ProfClass >= ProtoCommon.class_type.CLASS_TYPE_NEAR and ProfClass <= ProtoCommon.class_type.CLASS_TYPE_MAGIC then
        return TeachingDefine.JobTypeInfos[3]
    else
        FLOG_ERROR("TeachingMgr GetJobTypeInfoFromProfClass Error! ProfClass %d", ProfClass)
        return nil
    end
end

function TeachingMgr.GetJobTypeFromProfClass(ProfClass)
    if ProfClass == ProtoCommon.class_type.CLASS_TYPE_TANK then
        return TeachingType.Job_Type.Tank
    elseif ProfClass == ProtoCommon.class_type.CLASS_TYPE_HEALTH then
        return TeachingType.Job_Type.Heal
    elseif ProfClass >= ProtoCommon.class_type.CLASS_TYPE_NEAR and ProfClass <= ProtoCommon.class_type.CLASS_TYPE_MAGIC then
        return TeachingType.Job_Type.Dps
    else
        FLOG_ERROR("TeachingMgr GetJobTypeFromProfClass Error! ProfClass %d", ProfClass)
        return nil
    end
end

function TeachingMgr:GetTableByProf(ProfClass)
    local JobType = self.GetJobTypeFromProfClass(ProfClass)
    if JobType and self.TeachCfgMap then
        return self.TeachCfgMap[JobType]
    else
        FLOG_ERROR("TeachingMgr GetTableByProf Error! ProfClass %d", ProfClass)
        return nil
    end
end

function TeachingMgr:GetTableByProfAndDiff(ProfClass, DiffType)
    local TeachTable = self:GetTableByProf(ProfClass)
    if TeachTable then
        return TeachTable[DiffType]
    else
        FLOG_ERROR("TeachingMgr GetTableByProfAndDiff Error! DiffType %d", DiffType)
        return nil
    end
end

function TeachingMgr:GetItemInfo(ProfClass, DiffType, Index)
    local TeachSubTable = self:GetTableByProfAndDiff(ProfClass, DiffType)
    if TeachSubTable then
        return TeachSubTable[Index]
    else
        FLOG_ERROR("TeachingMgr GetItemInfo Error! Index %d", Index)
        return nil
    end
end

function TeachingMgr:GetMaxLevelCombat()
    local MaxLevel = 0
    local ProfDetailList = _G.ActorMgr:GetMajorRoleDetail().Prof.ProfList
	for _, ProfDetail in pairs(ProfDetailList) do
		if RoleInitCfg:FindProfSpecialization(ProfDetail.ProfID) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
            if ProfDetail.Level > MaxLevel then
                MaxLevel = ProfDetail.Level
            end
		end
	end
    return MaxLevel
end

function TeachingMgr:IsCrafterProf()
    local MajorProfID = MajorUtil.GetMajorAttributeComponent().ProfID
	local Specialization = RoleInitCfg:FindProfSpecialization(MajorProfID)
	local IsCrafterProf = Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
    return IsCrafterProf
end

function TeachingMgr:IsEnableTeaching(ShowMessage)
	local IsCrafterProf = self:IsCrafterProf()

    if IsCrafterProf then
        if ShowMessage then
		    MsgTipsUtil.ShowTips(LSTR(890022))
        end
        return false
	end

    return true
end

function TeachingMgr:StartTeaching(InteractiveID)
    -- 先结束掉当前挑战
    if self.CurrentInteractiveID > 0 then
        self:FinishCurrentChallenge()
    end

    if self.IsTeachScene then
        -- 如果在教学场景中，直接发交互事件
        UIInteractiveUtil.SendInteractiveReq(InteractiveID)
        --self:OnShowContentWindow(InteractiveID)
    else
        -- 否则，先进入副本，再发交互事件
        UIInteractiveUtil.SendInteractiveReq(TeachingDefine.EnterInteractiveID)
        --_G.PWorldMgr:SendEnterPWorld(self.TeachingWorldID)
        self.SendInteractiveID = InteractiveID
    end
    self.CurrentInteractiveID = InteractiveID
    _G.UIViewMgr:HideView(self.MainUIViewID)
    _G.EventMgr:SendEvent(EventID.PWorldTeachingStateChange)
end

function TeachingMgr:LeaveTeaching()
    if self.IsTeachScene then
        _G.PWorldMgr:SendLeavePWorld(self.TeachingWorldID)
    end
end

function TeachingMgr:FindSubTable(InteractiveID)
    for _,SubTable in ipairs(self.TeachCfgMap) do
        for _,ItemList in ipairs(SubTable) do
            for _,Item in ipairs(ItemList) do
                if Item.InteractiveID == InteractiveID then
                    return ItemList
                end
            end
        end
    end
    FLOG_ERROR("TeachingMgr FindSubTable Null")
    return nil
end

function TeachingMgr:FindItemInfo(InteractiveID)
    local ItemList = self:FindSubTable(InteractiveID)
    if ItemList == nil then
        return nil
    end

    for _,Item in ipairs(ItemList) do
        if Item.InteractiveID == InteractiveID then
            return Item
        end
    end

    return nil
end

function TeachingMgr:IsLastTeachingProject(InteractiveID)
    local ItemList = self:FindSubTable(InteractiveID)
    if ItemList == nil then
        return false
    end

    local LastItem = ItemList[#ItemList]
    if LastItem then
        return LastItem.InteractiveID == InteractiveID and true or false
    else
        return false
    end
end

function TeachingMgr:PreInteractiveCompleted(InteractiveID)
    local ItemList = self:FindSubTable(InteractiveID)
    if ItemList == nil then
        return false
    end

    local AllCompleted = true

    for _,Item in ipairs(ItemList) do
        if Item.InteractiveID == InteractiveID then
            break
        end

        local bCompleted = UIInteractiveUtil.InteractiveIsCompleted(Item.InteractiveID)
        if bCompleted == false then
            AllCompleted = false
            break
        end
    end

    return AllCompleted
end

function TeachingMgr:GetLevelLimit(InteractiveID)
    local ItemList = self:FindSubTable(InteractiveID)
    if ItemList == nil then
        return 0
    end

    for _,Item in ipairs(ItemList) do
        if Item.InteractiveID == InteractiveID then
            return Item.LevelLimit
        end
    end
    return 0
end

function TeachingMgr:IsItemListCompleted(ItemList)
    local AllCompleted = true
    for _,Item in ipairs(ItemList) do
        local bCompleted = UIInteractiveUtil.InteractiveIsCompleted(Item.InteractiveID)
        if bCompleted == false then
            AllCompleted = false
            break
        end
    end
    return AllCompleted
end

function TeachingMgr:FinishCurrentChallenge()
    self.CurrentInteractiveID = 0
    UIViewMgr:HideView(UIViewID.PWorldTeachingContentPanel)
    _G.EventMgr:SendEvent(EventID.PWorldTeachingStateChange)
end

function TeachingMgr:GetGuideSkillID(Index)
	if Index > TeachingDefine.GuideSkillExBaseID then
		Index = Index - TeachingDefine.GuideSkillExBaseID
		-- 查表
		local SkillInfoTable = TeachingDefine.GuideSkillDetailInfo[Index]
		if SkillInfoTable then
			local MajorProfID = MajorUtil.GetMajorAttributeComponent().ProfID
			local MajorClass = RoleInitCfg:FindProfClass(MajorProfID)
			for _, SkillInfo in pairs(SkillInfoTable) do
				if SkillInfo.ClassType == MajorClass then
					if SkillInfo.ProfType == 0 then
						return SkillInfo.SkillID
					elseif SkillInfo.ProfType == MajorProfID then
						return SkillInfo.SkillID
					end
				end
			end
		end
	end
	return 0
end

function TeachingMgr.SendInteractiveByGuideID(GuideID)
    UIInteractiveUtil.SendInteractiveByGuideID(GuideID)
end

return TeachingMgr