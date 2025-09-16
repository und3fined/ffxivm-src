local LuaClass = require("Core/LuaClass")
local AdventureBaseVM = require("Game/Adventure/AdventureBaseVM")
local AdventureCareerMgr = require("Game/Adventure/AdventureCareerMgr")
local AdventureDefine = require("Game/Adventure/AdventureDefine")
local AdventureProfCareerItemVM = require("Game/Adventure/ItemVM/AdventureProfCareerItemVM")
local ProtoCS = require("Protocol/ProtoCS")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS
local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIBindableList = require("UI/UIBindableList")

local AdventureProfCareerVM = LuaClass(AdventureBaseVM)

function  AdventureProfCareerVM:Ctor()
    self.ItemList = UIBindableList.New(AdventureProfCareerItemVM)
    self.RedChapterID = 0
end

local StatusSort = {
    [QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED] = 5,
    [QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS] = 5,
    [QUEST_STATUS.CS_QUEST_STATUS_FINISHED] = 4
}

local function TaskListSort(a, b)
    if StatusSort[a.Status] ~= StatusSort[b.Status] then
        return StatusSort[a.Status] > StatusSort[b.Status]
    else
        return a.SortID < b.SortID
    end
end

function AdventureProfCareerVM:GetShowTaskData(ProfData)
    local CareerTaskData = AdventureCareerMgr:GetAdventureCareerTaskDataByProf(ProfData)
    local FinalTaskData = {}
    for i, v in ipairs(CareerTaskData) do
        local Cfg = AdventureCareerMgr:GetChapterCfgData(v.ChapterID)
        if Cfg then
            local CurTaskDetail = AdventureCareerMgr:GetTaskDetailData(v.ChapterID)
            local Status = CurTaskDetail.Status
            local Params = {
                SortID = v.ID,
                ChapterID = v.ChapterID,
                ImgTaskIcon = CurTaskDetail.Icon,
                TextTitle = CurTaskDetail.Title,
                Status = Status,
                BtnGoVisible = true,
                PanelSelectVisible = false,
                IsNew = CurTaskDetail.ChangeProfTaskRed or AdventureCareerMgr:IsCurTaskNeedRemindRed(v.ChapterID, CurTaskDetail.Prof),
                Prof = CurTaskDetail.Prof,
                Activate = CurTaskDetail.Activate,
            }

            if Params.IsNew then
                self.RedChapterID = v.ChapterID
            end
  
            if CurTaskDetail.RewardType and CurTaskDetail.RewardType ~= ProtoRes.ProfCareerRewardType.ProfCareerNone then
                Params.TextTypeTagVisible = true
                Params.TextTypeTag = ProtoEnumAlias.GetAlias(ProtoRes.ProfCareerRewardType, CurTaskDetail.RewardType)
                if CurTaskDetail.RewardType == ProtoRes.ProfCareerRewardType.ChangeProf then
                    Params.PanelSelectVisible = true
                    local ProfUtil = require("Game/Profession/ProfUtil")
                    local CurAdvancedProf = ProfUtil.GetAdvancedProf(ProfData.Prof or 1)
                    local ProfInfo = RoleInitCfg:FindCfgByKey(CurAdvancedProf or 1)
                    Params.ImgTask = string.format("Texture2D'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_%s.UI_InfoTips_Icon_JobUnlock_%s'", ProfInfo.ProfAssetAbbr, ProfInfo.ProfAssetAbbr)
                    Params.TextTypeTag = string.format(LSTR(520065), RoleInitCfg:FindRoleInitProfName(CurAdvancedProf or 1))
                end
            end

            Params.FinishLootID = CurTaskDetail.FinishLootID
            table.insert(FinalTaskData, Params)
        end
    end

    table.sort(FinalTaskData, TaskListSort)
    return FinalTaskData
end

function AdventureProfCareerVM:ClearNewRed(CurProf)
    if not CurProf then return end
        
    if self.RedChapterID ~= 0  then
        AdventureCareerMgr:SaveTaskNotStartSeen(CurProf, self.RedChapterID)
        self.RedChapterID = 0
    end

    AdventureCareerMgr:DelAllRedRecordDataByProf(CurProf)
    AdventureCareerMgr:UpdateAdventureCareerRed()
end

return AdventureProfCareerVM