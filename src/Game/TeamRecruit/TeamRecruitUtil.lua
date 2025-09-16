--[[
Author: jususchen jususchen@tencent.com
Date: 2025-03-10 16:41:54
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-03-11 20:09:39
FilePath: \Script\Game\TeamRecruit\TeamRecruitUtil.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local TeamRecruitDefine = require("Game/TeamRecruit/TeamRecruitDefine")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local MajorUtil = require("Utils/MajorUtil")
local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
local TeamRecruitFastMsgCfg = require("TableCfg/TeamRecruitFastMsgCfg")
local TeamDefine = require("Game/Team/TeamDefine")
local RecruitFunctionType = TeamRecruitDefine.RecruitFunctionType
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")

local LSTR = _G.LSTR
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS

local TeamRecruitUtil = {}

-- 是不是玩家自己的招募 
-- 招募ID等于队长的RoleID
function TeamRecruitUtil.IsMajorRecruitByID(RecruitID)
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    return RecruitID == MajorRoleID and RecruitID ~= nil
end

function TeamRecruitUtil.CanReRecruitMem()
    local TeamRecruitVM = _G.TeamRecruitVM
    if TeamRecruitVM.IsRecruiting == true then
        return false
    end

    if TeamRecruitVM.HasCompleteRecruit == false then
        return false
    end

    local IsCaptain = _G.TeamMgr:IsCaptain()
    if not IsCaptain then
        return false
    end

    if _G.PWorldMgr:CurrIsInDungeon() then
       return false 
    end

    local Data = _G.TeamRecruitMgr:GetSelfRecruitData()
    if Data == nil or not TeamRecruitUtil.IsMajorRecruitByID(Data.RoleID) then
        return false
    end

    local DesiredNum = 0
    for _, v in ipairs(Data.Prof or {}) do
        local ProfList = v.Prof
        if ProfList and #ProfList > 0 then
            DesiredNum = DesiredNum + 1
        end
    end

    return DesiredNum == _G.TeamMgr:GetMemberNum() + 1
end

function TeamRecruitUtil.TryOpenTeamRecruitView(RecruitType, PreSelectTask)
    if _G.ModuleOpenMgr:ModuleState(ProtoCommon.ModuleID.ModuleIDTeamRecruit) then
        _G.UIViewMgr:ShowView(_G.UIViewID.TeamMainPanel, { ModuleType = TeamDefine.ModuleType.Recruit, RecruitType=RecruitType, PreSelectTask=PreSelectTask })
        return true
    end
end

function TeamRecruitUtil.GetProfList( CfgList )
    CfgList = CfgList or {}

    local Ret = {}

    for _, v in ipairs(CfgList) do
        local Prof = v.Prof
        if Prof and not table.contain(Ret, Prof) then
            table.insert(Ret, Prof)
        end
    end

    return Ret
end

--获取所有开放的指定职业类职业
---@param FunctionType ProtoCommon.function_type @职业类 
---@return table
function TeamRecruitUtil.GetAllOpenProfByFunctionType( FunctionType )
    if nil == FunctionType then
        return {}
    end

    if nil == TeamRecruitUtil.OpenProfInfo then
        TeamRecruitUtil.OpenProfInfo = {}
    end

    if nil == TeamRecruitUtil.OpenProfInfo[FunctionType] then
        TeamRecruitUtil.OpenProfInfo[FunctionType] = TeamRecruitUtil.GetProfList(RoleInitCfg:GetOpenProfCfgListByFunction(FunctionType))
    end

    return TeamRecruitUtil.OpenProfInfo[FunctionType]
end

---获取所有开放的职业
---@return table
function TeamRecruitUtil.GetAllOpenProf()
    if nil == TeamRecruitUtil.AllOpenProf then
        TeamRecruitUtil.AllOpenProf = TeamRecruitUtil.GetProfList(RoleInitCfg:GetAllOpenProfCfgList())
    end

    return TeamRecruitUtil.AllOpenProf
end

local ClassProfsMap = {}

function TeamRecruitUtil.GetOpenProfsByClass(ClassType)
    if ClassType == nil then
       return {} 
    end

    local Profs = ClassProfsMap[ClassType] or {}
    if #Profs > 0 then
       return table.clone(Profs, true) 
    end

    Profs = {}
    for _, v in ipairs(RoleInitCfg:GetOpenProfCfgListByClass(ClassType) or {}) do
        table.insert(Profs, v.Prof)
    end

    if #Profs == 0 then
       return Profs 
    end

    Profs = table.makeconst(Profs)
    ClassProfsMap[ClassType] = Profs

    return table.clone(Profs, true) 
end

local OpenNonBattleProfs = nil
function TeamRecruitUtil.GetOpenNonBattleProfs()
    if OpenNonBattleProfs then
       return table.clone(OpenNonBattleProfs, true) 
    end

    local Profs = {}
    for _, Cfg in ipairs(RoleInitCfg:GetAllOpenProfCfgList()) do
        if not (Cfg.Function and Cfg.Function > 0 and Cfg.Function < 4) then
            table.insert(Profs, Cfg.Prof)
        end
    end

    if #Profs == 0 then
       return Profs 
    end

    OpenNonBattleProfs = table.makeconst(Profs)

    return table.clone(Profs, true)
end

--获取招募职能类型
function TeamRecruitUtil.GetRecruitFunctionType( ProfList )
    if #ProfList >= #(TeamRecruitUtil.GetAllOpenProf()) then
        return RecruitFunctionType.All
    end

    local FunctionList = {}

    for _, v in ipairs(ProfList) do
        local FuncType = RoleInitCfg:FindFunction(v)
        if FuncType and FuncType > 0 and FuncType < 4 then
            FunctionList[FuncType] = true
        end
    end

    local Bit = 0

    for k in pairs(FunctionList) do
        Bit = Bit + (1 << k) 
    end

    return Bit
end

--获取指定位置招募职业描述
---@param ProfVM TeamRecruitProfVM  @招募职业VM
---@return string
function TeamRecruitUtil.GetRecruitProfDesc( ProfVM )
    local RoleID = ProfVM.RoleID
    if RoleID and RoleID ~= 0 then
        local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID)
        local Name = RoleInitCfg:FindRoleInitProfName(RoleVM.Prof)
        return Name or ""
    end

    local FuncType = ProfVM.RecruitFuncType 
    if FuncType == RecruitFunctionType.None then 
        return TeamRecruitDefine.RecruitFuncTypeName.None

    elseif FuncType == RecruitFunctionType.All then 
        return TeamRecruitDefine.RecruitFuncTypeName.All
    end

    local NameList = {}

    for _, v in ipairs(ProfVM.Profs or {}) do
        local ProfName = RoleInitCfg:FindRoleInitProfName(v)
        if not string.isnilorempty(ProfName) then
            table.insert(NameList, ProfName)
        end
    end

    return table.concat(NameList, "·") 
end

--- 招募是否解锁
---@param ID number 招募表ID
---@return boolean true为已解锁
function TeamRecruitUtil.IsRecruitUnlocked(ID)
    local Cfg = TeamRecruitCfg:FindCfgByKey(ID)
    if Cfg == nil then
       return false 
    end

    local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
    if Cfg.DailyRandomID and Cfg.DailyRandomID ~= 0 then
        return PWorldEntUtil.IsDailyRandomUnlocked(Cfg.DailyRandomID) 
    end

    local SceneEnterID = Cfg.Task or 0
    if SceneEnterID <= 0 then
        return true
    end

    if PWorldEntUtil.IsPrettyHardPWorld(SceneEnterID) and not PWorldEntUtil.IsPrettyHardEntranceJoinable(SceneEnterID) then
       return false 
    end

    local QuestID = SceneEnterCfg:GetPreQuestID(SceneEnterID)
    if nil == QuestID then
        return true
    end

    local QuestStatus = _G.QuestMgr:GetQuestStatus(QuestID)
    return QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_FINISHED
end

function TeamRecruitUtil.GetRecruitTask(ContentID)
    local Cfg = TeamRecruitCfg:FindCfgByKey(ContentID)
    if Cfg then
        return Cfg.Task
    end
end

function TeamRecruitUtil.GetQuickConfigTextList()
    if nil == TeamRecruitUtil.QuickConfigTextList then
        TeamRecruitUtil.QuickConfigTextList = {}
        local AllCfg = TeamRecruitFastMsgCfg:FindAllCfg() or {}

        for _, v in ipairs(AllCfg) do
            if not string.isnilorempty(v.Text) then
                table.insert(TeamRecruitUtil.QuickConfigTextList, v.Text)
            end
        end
    end

    return TeamRecruitUtil.QuickConfigTextList
end

function TeamRecruitUtil.GetQuickConfigTextMap()
    if nil == TeamRecruitUtil.QuickConfigTextMap then
        TeamRecruitUtil.QuickConfigTextMap = {}
        local AllCfg = TeamRecruitFastMsgCfg:FindAllCfg() or {}

        for _, v in ipairs(AllCfg) do
            local Key = v.Text
            if not string.isnilorempty(Key) then
                TeamRecruitUtil.QuickConfigTextMap[Key] = v.ID
            end
        end
    end

    return TeamRecruitUtil.QuickConfigTextMap
end

---适配招募留言
---@param Text stirng @留言
---@param IsCompleteTask bool @是否勾选“已完成过任务”选项
---@return string
function TeamRecruitUtil.AdaptMessage( Text, IsCompleteTask )
    if string.isnilorempty(Text) then
        return LSTR(1310012)
    end

    local NewText = ""
    local TempText = Text

    if IsCompleteTask then
		local Word = TeamRecruitDefine.CompleteTaskWord
		if string.startsWith(TempText, Word) then
			TempText = string.gsub(TempText, string.revisePattern(Word), "", 1)

            local ReplaceWord = string.format('<span color="#89bd88ff">%s</>', Word)
			NewText = NewText .. ReplaceWord
        end
    end

    local QuickTextList = TeamRecruitUtil.GetQuickConfigTextList()

    for v in string.gmatch(TempText, "%[(.-)%]") do
        local Word = string.format("[%s]", v)
        if not string.startsWith(TempText, Word) then
            break
        end

        if not table.contain(QuickTextList, v) then
            break
        end

        TempText = string.gsub(TempText, string.revisePattern(Word), "", 1)

        local ReplaceWord = string.format('<span color="#d1ba8eff">%s</>', Word)
        NewText = NewText .. ReplaceWord
    end

	NewText = NewText .. TempText 

    return NewText 
end

---根据留言获取快捷留言文本id列表
---@param Text stirng @留言
---@param IsCompleteTask bool @是否勾选“已完成过任务”选项
---@return table
function TeamRecruitUtil.GetQuickTextIDs( Text, IsCompleteTask )
    if string.isnilorempty(Text) then
        return {}
    end

    local TempText = Text
    if IsCompleteTask then
		local Word = TeamRecruitDefine.CompleteTaskWord
		if string.startsWith(TempText, Word) then
			TempText = string.gsub(TempText, string.revisePattern(Word), "", 1)
        end
    end

    local Ret =  {}
    local QuickTextMap = TeamRecruitUtil.GetQuickConfigTextMap()

    for v in string.gmatch(TempText, "%[(.-)%]") do
        local Word = string.format("[%s]", v)
        if not string.startsWith(TempText, Word) then
            break
        end

        local ID = QuickTextMap[v]
        if ID then
            table.insert(Ret, ID)

            TempText = string.gsub(TempText, "^" .. string.revisePattern(Word), "")
        end
    end

    return Ret
end

---获取招募目标可招募人数
---@param ContentID number @招募内容ID
function TeamRecruitUtil.GetMemberNum( ContentID )
    if nil == ContentID then
        return 0
    end

    local Cfg = TeamRecruitCfg:FindCfgByKey(ContentID) or {}
    return #(Cfg.DefaultProf or {})
end

-------------------------------------------------------------------------------------------------------
---@see 招募分享

--- 招募分享那边需要把Icon转换成ID
function TeamRecruitUtil.EncodeRecruitMemIconID(HasRole, RoleID, Profs)
    local IsProf = false
    local ID = 0
    if HasRole then
        local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID)
        if RoleVM then
            IsProf = true
            ID = RoleVM.Prof
        end

    else
        if table.length(Profs) == 1 then
            IsProf = true
            ID = Profs[1]
        else
            local RecruitFuncType = TeamRecruitUtil.GetRecruitFunctionType(Profs)
            ID = RecruitFuncType
        end

    end

    local H = ID
    local L = IsProf and 1 or 0
    ID = (H << 1) | L
    
    return ID
end

function TeamRecruitUtil.GetRecruitMemIcon(IconID)
    local H = IconID >> 1
    local L = IconID & 1

    local IsProf = L == 1
    local ID = H

    local Icon = ""

    if IsProf then
        Icon = RoleInitCfg:FindRoleInitProfIcon(ID)

    else
        Icon = TeamRecruitDefine.FuncTypeIconConfig[ID]
    end

    return Icon
end

function TeamRecruitUtil.GetTaskLimitIcon(TaskLimit)
    if TaskLimit then 
        return TeamRecruitDefine.TaskLimitIcon[TaskLimit]
    end
end

function TeamRecruitUtil.IsUnOpenTask(ContentID)
    return not TeamRecruitUtil.IsRecruitUnlocked(ContentID)
end

local function IsFitProf(v, ProfVMList, Prof)
    for _, v in ipairs(ProfVMList:GetItems() or {}) do
		if not v.HasRole and table.contain(v.Profs, Prof) then
			return true
		end
	end
end

function TeamRecruitUtil.CanJoinRecruit(VM)
    --装备平均品级
	local NeedLv = VM.EquipLv or 0
	if NeedLv > 0 then
		local CurLv = _G.EquipmentMgr:CalculateEquipScore()
		if CurLv < NeedLv then
			return false
		end
	end

	--剩余职位是否匹配
	local bFitProf
    do
        local ProfVMList = VM.MemberSimpleProfVMList or VM.MemberProfVMList
        if ProfVMList then
           bFitProf = IsFitProf(VM, ProfVMList, MajorUtil.GetMajorProfID()) 
        end
    end

	if not bFitProf then
		return bFitProf
	end

	return not TeamRecruitUtil.IsUnOpenTask(VM.ContentID)
end

function TeamRecruitUtil.HasDifficultyConfig(ContentID)
    local Cfg = TeamRecruitCfg:FindCfgByKey(ContentID)
    if Cfg and Cfg.RecruitModel then
        return #Cfg.RecruitModel > 0
    end

    return false
end

function TeamRecruitUtil.ShareSelfRecruitToChat(ChatType)
    return TeamRecruitUtil.ShareRecruitToChat(ChatType, _G.TeamRecruitVM.RecruitingDetailVM)
end

function TeamRecruitUtil.ShareRecruitToChat(ChatType, VM, Callback)
    local RoleID, ResID, IconIDs, LocList, SceneMode = TeamRecruitUtil.GatherShareData(VM)
	local Succ, Time = _G.ChatMgr:ShareTeamRecruit(ChatType, RoleID, ResID, IconIDs, LocList, SceneMode)
	if (not Succ) and Time then
		_G.MsgTipsUtil.ShowTips(string.sformat(LSTR(1310018), Time))
	end

    if Succ then
       _G.TeamRecruitMgr:AddChatShareCallback(ChatType, RoleID, Callback) 
    end

    return Succ
end

function TeamRecruitUtil.GatherShareData(VM)
    local TeamRecruitDetailVM = VM or _G.TeamRecruitVM.CurRecruitDetailVM

	local ResID = TeamRecruitDetailVM.ContentID
	local RoleID = TeamRecruitDetailVM.RoleID
	local IconIDs = {}
	local LocList = {}

	local Mems = TeamRecruitDetailVM.MemberProfVMList:GetItems()

	for _, Mem in pairs(Mems) do
		if not table.empty(Mem.Profs) then
			table.insert(IconIDs, Mem.MemIconID)
			local Flag = Mem.HasRole and 1 or 0
			table.insert(LocList, Flag)
		end
	end

	return RoleID, ResID, IconIDs, LocList, TeamRecruitDetailVM.SceneMode 
end

function TeamRecruitUtil.GenChatRecruitShareHref(ClipBoardData)
    local Info = ClipBoardData --_G.TeamRecruitMgr:GetClipboard()
	if nil == Info then 
		return
	end
 	
	local ID = Info.ID
	local ResID = Info.ResID
	local IconIDs = Info.IconIDs
	local LocList = Info.LocList
	local TaskLimit = Info.TaskLimit

	if nil == ID or nil == ResID or nil == IconIDs or table.empty(IconIDs) or nil == LocList or table.empty(LocList) or nil == TaskLimit then
		-- _G.FLOG_ERROR("ChatBarPanelView:AddTeamRecruitHref, params error")
        _G.FLOG_ERROR("TeamRecruitUtil.GenChatRecruitShareHref params error")
		return
	end

	local Href = {
		Type = ProtoCS.PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TEAM_RECRUIT,
		TeamRecruit = { ID = ID, ResID = ResID, IconIDs = IconIDs, LocList = LocList, TaskLimit = TaskLimit }
	}

    return Href
end

local function IsCrossServerByRoleVM(WorldID)
    local VM = MajorUtil.GetMajorRoleVM(true)
    return VM and VM.CurWorldID ~= WorldID
end 

---@param Func function | nil
---@param View UIView
---@param Widget any
---@return UIBinderSetIsVisiblePred
function TeamRecruitUtil.NewCrossServerShowBinder(Func, View, Widget, ...)
    local UIBinderSetIsVisiblePred = require("Binder/UIBinderSetIsVisiblePred")
    return UIBinderSetIsVisiblePred.NewByPred(Func or IsCrossServerByRoleVM, View, Widget, ...)
end

function TeamRecruitUtil.GetSceneModeIconByOp(Op)
    if Op == 999 then
        return "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Icon_All_png.UI_Team_Icon_All_png'"
    else
        local TaskType = _G.PWorldEntDetailVM:ToTaskType(Op)
        local PWorldQuestUtil = require("Game/PWorld/Quest/PWorldQuestUtil")
        return PWorldQuestUtil.GetSceneModeIcon(TaskType) or ""
    end
end

function TeamRecruitUtil.AddRoleLocationShowBinders(Binders, FindRoleID, View, Widget, Func)
    local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
    local LocBinder <const> = UIBinderValueChangedCallback.New(View, Widget, Func or function()
        local RVM = _G.RoleInfoMgr:FindRoleVM(FindRoleID(), true)
        if RVM then
            local Text = RVM.MapResName
            if RVM.CurWorldID ~= (MajorUtil.GetMajorRoleVM(true) or {}).CurWorldID then
                Text = _G.LoginMgr:GetMapleNodeName(RVM.CurWorldID)
            end

            Widget:SetText(Text)
        end
    end)

    table.insert(Binders,  { "MapResName", LocBinder })
    table.insert(Binders,  { "CurWorldID", LocBinder})
end

function TeamRecruitUtil.HasWeeklyRewardConfig(ContentID)
    local Cfg = TeamRecruitCfg:FindCfgByKey(ContentID)
    if Cfg then
       return Cfg.IsWeeklyRewards == 1 
    end
end

local ProtoCommon = require("Protocol/ProtoCommon")
local FunctionType = ProtoCommon.function_type
local PF_PRIORITY <const> = {
    [FunctionType.FUNCTION_TYPE_NULL] = 9,
    [FunctionType.FUNCTION_TYPE_GUARD] = 1,
    [FunctionType.FUNCTION_TYPE_RECOVER] = 2,
    [FunctionType.FUNCTION_TYPE_ATTACK] = 3,
    [FunctionType.FUNCTION_TYPE_PRODUCTION] = 4,
    [FunctionType.FUNCTION_TYPE_GATHER] = 5,
}

local function GetSortFuncPriority(F)
    return PF_PRIORITY[F] or 9
end

local function GetProfsHash(Profs)
    local ProfUtil = require("Game/Profession/ProfUtil")
    local V = 0
    for _, P in ipairs(Profs) do
        local Priority = GetSortFuncPriority(ProfUtil.Prof2Func(P) or 0)
        if Priority > 0 then
           V = V | (1 << Priority) 
        end
    end

    return V
end

local function IsPureProf(Hash)
    return Hash == 2 or Hash == 4 or Hash == 8
end

function TeamRecruitUtil.SortEditProf(a, b)
    if a.RoleID == b.RoleID and (a.RoleID == 0 or a.RoleID == nil) then
        local HA = GetProfsHash(a.Prof or a.Profs)
        local HB = GetProfsHash(b.Prof or b.Profs)
        if HA ~= HB and IsPureProf(HA) and IsPureProf(HB) then
           return HA < HB 
        end
        return (a.Loc or 0) < (b.Loc or 0)
    end

    if b.RoleID == 0 or b.RoleID == nil then
       return true 
    end

    if a.RoleID == 0 or a.RoleID == nil then
        return false
    end

    local ProfUtil = require("Game/Profession/ProfUtil")
    local FA = ProfUtil.Prof2Func(_G.TeamMgr:GetTeamMemberProf(a.RoleID)) or 0
    local FB = ProfUtil.Prof2Func(_G.TeamMgr:GetTeamMemberProf(b.RoleID))  or 0
    if FA ~= FB then
        return GetSortFuncPriority(FA) < GetSortFuncPriority(FB)
    end

    return false
end

function TeamRecruitUtil.GetViewingOpenProfs(ClassType)
    local ProfInfoList = {}
    local CfgList = RoleInitCfg:GetOpenProfCfgListByClass(ClassType) or {}
    -- a temp solution
    local ProfUtil = require("Game/Profession/ProfUtil")
    local BaseProfs = {}
    local AdvanceProfs = {}
    local LeftAdvanceProfs = {}
    local ProtoRes = require("Protocol/ProtoRes")
    for _, v in ipairs(CfgList) do
        local Prof = v.Prof
        local bAddAd
        if Prof and v.ProfLevel == ProtoRes.prof_level.PROF_LEVEL_BASE then
            table.insert(BaseProfs, { Prof = Prof, Icon = v.ProfIcon})
            if v.AdvancedProf and v.AdvancedProf ~= 0 and ProfUtil.GetAdvancedProf(v.AdvancedProf) == v.AdvancedProf then
                table.insert(AdvanceProfs, { Prof = v.AdvancedProf, Icon = ProfUtil.Prof2Icon(v.AdvancedProf)})
                bAddAd = true
            end
        end
        if Prof and v.ProfLevel == ProtoRes.prof_level.PROF_LEVEL_ADVANCED and not bAddAd then
            table.insert(LeftAdvanceProfs, { Prof = Prof, Icon = v.ProfIcon})
        end
    end

    for _, v in ipairs(LeftAdvanceProfs) do
        if not table.find_item(AdvanceProfs, v.Prof, "Prof") then
            table.insert(AdvanceProfs, v)
        end
    end

    for i = 1, 4 do
        ProfInfoList[i] = AdvanceProfs[i] 
    end
    for i = 5, 7 do
        ProfInfoList[i] = BaseProfs[i - 4]
    end

    return ProfInfoList
end

return TeamRecruitUtil