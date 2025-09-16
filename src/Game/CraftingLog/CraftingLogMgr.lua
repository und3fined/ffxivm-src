--
-- Author: Gh
-- Date : 2023-4-18
-- Description :
--
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ActorMgr = require("Game/Actor/ActorMgr")
local BagMgr = require("Game/Bag/BagMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local RecipeCfg = require("TableCfg/RecipeCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")
local NoteParamCfg = require("TableCfg/NoteParamCfg")
local RecipetoolAnimatiomCfg = require("TableCfg/RecipetoolAnimatiomCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local LoginMgr = require("Game/Login/LoginMgr")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local MsgTipsID = require("Define/MsgTipsID")
local EventID = require("Define/EventID")
local CraftingLogDefine = require("Game/CraftingLog/CraftingLogDefine")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")
local LevelExpCfg = require("TableCfg/LevelExpCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local UIViewID = require("Define/UIViewID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local SaveKey = require("Define/SaveKey")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local SaveMgr = _G.UE.USaveMgr
local LOOT_TYPE = ProtoCS.LOOT_TYPE
local FilterALLType = CraftingLogDefine.FilterALLType
local UnEnoughType = CraftingLogDefine.UnEnoughType
local CraftingLogState = CraftingLogDefine.CraftingLogState
local NormalRecipeLevel = CraftingLogDefine.NormalRecipeLevel
local NormalIncrementStage = CraftingLogDefine.NormalIncrementStage
local NormalMaxSearchHistoryCount = CraftingLogDefine.NormalMaxSearchHistoryCount
local CareerSortData = CraftingLogDefine.CareerSortData
local UIViewMgr = require("UI/UIViewMgr")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local ItemUtil = require("Utils/ItemUtil")
local SpecialType = GatheringLogDefine.SpecialType
local RecipeType = ProtoRes.RecipeType
local CraftingNoteType = ProtoCS.NoteType.NOTE_TYPE_PRODUCTION
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_NOTE_CMD

local LSTR = _G.LSTR

-- @class CraftingLogMgr : MgrBase
local CraftingLogMgr = LuaClass(MgrBase)

function CraftingLogMgr:OnInit()
    self:Reset()
end

function CraftingLogMgr:Reset()
    -- 每个职业最后查看的历史记录
    self.CareerLastCheckMap = {}
    -- 选择的职业
    self.LastChoiceCareer = nil
    -- 最后选择的分类
    self.LastHorTabIndex = nil
    -- 最后选择的下拉列表
    self.LastDropDownIndex = nil
    -- 当前的道具数据
    self.NowPropData = nil
    -- 当前选择到道具数据
    self.NowChoicePropData = nil
    -- 当前搜索出道具数据
    self.NowSearchPropData = nil
    -- 最大制作数量
    self.MaxMakeCount = 0
    -- 当前制作数量
    self.NowMakeCount = 0
    -- 道具按照职业
    self.ProListWithProf = {}
    -- 历史记录
    self.SearchHistory = {}
    self.WorkingID = nil
    -- 职业查看记录
    self.CareerCheckMap = {}
    -- 是否是提审版本
    self.bArraignmentVersion = true

    self.RecipeCfgWithProf = {}
    self.AllCraftToolCfg = nil

    -- 筛选接口
    self.bFilterCheats = true
    self.bFilterCommerceChamber = true
    self.bFilterRegularCustomer = true
    self.bFilterFriendTribe = true

    self.EnoughState = UnEnoughType.Material

    -- 第一次完成了普通制作
    self.FirstCraftedHQItem = false
    -- 制作记录
    self.HistoryList = nil
    -- 制作历史记录展示最大数量
    self.MaxHistoryCount = NoteParamCfg:FindCfgByKey(ProtoRes.NoteParamCfgID.NoteProductionHistoryPageMaxNum).Value[1]
    -- 最大收藏数量
    self.MaxCollectCount = NoteParamCfg:FindCfgByKey(ProtoRes.NoteParamCfgID.NoteProductionMaxCollectNum).Value[1]
    -- 收藏数据
    self.CollectListData = nil
    self.MakeState = CraftingLogDefine.MakeRecipeState.Normal
    -- 是否可以记录
    self.bCanRecord = false
    -- 制作笔记状态
    self.CraftingState = CraftingLogState.Picking
    -- GM 是否开启便捷添加道具
    self.bConvenient = false

    -- 快速搜索内容
    self.FastSearchInfo = ""
    self.CurrentToolName = ""
    self.SearchInfo = nil
    self.OnShowSearchInfo = nil

    -- 简易制作金币不足
    self.ScoreNotEnough = false

    self.VersionNametoNum = {}
    self.GameVersionNum = self:GetGameVersionNum()
    self.UseEsotericaProf = {}

    -- 普通页签下拉选项红点回包
    self.NormalDropRedDotLists = {}
    -- 特殊页签下拉选项红点回包
    self.SpecialDropRedDotLists = {}
    ---保存制作物的红点名
    self.ItemRedDotNameList = {}
    ---已读过的普通页签下拉框选项
    self.CancelNormalDropRedDotLists = {}
    ---已读过的特殊页签下拉框选项
    self.CancelSpecialDropRedDotLists = {}
    self.AddNewIndex = {}
    self.SwitchProfInNote = false

    self.ParamTabItems = nil
    self.ReverseOrder = false --正序为从小到大
end

function CraftingLogMgr:GetGameVersionNum()
    local GetGameVersionNum = SaveMgr.GetInt(SaveKey.GatherNoteVersion, 0, true)
    if GetGameVersionNum ~= 0 then
        FLOG_INFO("CraftingLogMgr:GetGameVersionName SaveKey.GatherNoteVersion is %s", tostring(GetGameVersionNum))
        return GetGameVersionNum
    end
    local GameVersionCfg = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION)
    local VersionName = GameVersionCfg.Value
    if not table.is_nil_empty(VersionName) then
        GetGameVersionNum = VersionName[1] * 100 + VersionName[2] * 10 + VersionName[3]
    else
        GetGameVersionNum = CraftingLogDefine.DefaultGameVersionNum
    end
    return GetGameVersionNum
end

function CraftingLogMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.CrafterOnMakeComplete, self.OnMakeComplete) --制作完成
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch) --切换职业
    self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate) -- 升级
    self:RegisterGameEvent(EventID.MajorProfActivate, self.MajorProfActivate) -- 激活
    self:RegisterGameEvent(EventID.ModuleOpenUpdated, self.OnModuleOpenUpdated) --系统解锁
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    -- Test
    self:RegisterGameEvent(EventID.CraftingLogConvenient, self.ConvenientGM)
end

function CraftingLogMgr:OnGameEventLoginRes()
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMakerNote) then
        return
    end
    self:SendMsgHistoryListinfo()  
    local OwnCareerList = self:GetOwnCareerData()
    if OwnCareerList ~= nil then
        for _, value in pairs(OwnCareerList) do
            self:SendMsgUpdateDropNewData(value.Prof)
        end
    end
    self:SendMsgQueryVersion()
end

function CraftingLogMgr:OnEventMajorProfSwitch()
    -- if not MajorUtil.IsCrafterProf() then
    --     return
    -- end
    --若玩家在笔记外切换职业，重置笔记的配方选择和记忆功能
    if not self.SwitchProfInNote then
        self.CareerCheckMap = {}
        self.CareerLastCheckMap = {}
        self.LastChoiceCareer = nil
        self.LastHorTabIndex = nil
        self.LastDropDownIndex = nil
        self.NowPropData = nil
    else
        --在笔记内切换职业，当切换为本职业后，刷新按钮状态
        self.SwitchProfInNote = false
        if self.NowPropData ~= nil then
            _G.CraftingLogVM:RefreshPropInfo(self.NowPropData)
        end
    end
end

function CraftingLogMgr:OnModuleOpenUpdated()
    ---新手引导这里触发第一次打开制作笔记界面（默认选中简易制作，开始引导）
    self.TutorialGuide = true
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.Type = TutorialDefine.TutorialConditionType.UnLockCraftingLog --新手引导触发类型
    _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
end

function CraftingLogMgr:SendTutorialFirstCrafted()
    if self.FirstCraftedHQItem == false then
        self.FirstCraftedHQItem = true
        ---新手引导这里触发第一次普通制作成功
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.FirstCraftedHQItem --新手引导触发类型
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end
end

-- region 职业数据及获取下标

---@type 获取已有职业信息 用于显示左侧列表
function CraftingLogMgr:GetOwnCareerData()
    self.OwnCareerList = {}
    local RoleDetail = ActorMgr:GetMajorRoleDetail()
    local Prof = RoleDetail and RoleDetail.Prof
    local ProfList = Prof and Prof.ProfList
    if not table.is_nil_empty(ProfList) then
        for _, value in pairs(ProfList) do
            local ProfInfo = RoleInitCfg:FindCfgByKey(value.ProfID)
            local VerIconTabIcons = GatheringLogDefine.VerIconTabIcons[value.ProfID]
            if ProfInfo and ProfInfo.Class == ProtoCommon.class_type.CLASS_TYPE_CARPENTER then
                local ProfData = {}
                ProfData.ID = ProfInfo.Prof
                ProfData.Prof = ProfInfo.Prof
                ProfData.SortPriority = CareerSortData[ProfData.ID] or 0
                ProfData.IconPath = VerIconTabIcons.IconPath
                ProfData.SelectIcon = VerIconTabIcons.SelectIcon
                ProfData.RedDotType = CraftingNoteType
                table.insert(self.OwnCareerList, ProfData)
            end
        end
    
        table.sort(self.OwnCareerList, function(a, b)
            return a.SortPriority < b.SortPriority
        end)
    end
    return self.OwnCareerList
end

---判断职业是否解锁
function CraftingLogMgr:GetProfIsLock(Prof)
    local AllCareerData = self.AllCareerData or self:GetAllCareerData()
    for _, value in pairs(AllCareerData) do
        if value.Prof == Prof then
            return value.IsLock
        end
    end
    return true
end

---所有职业详情（每次onshow时调用，self.AllCareerData刷新一次）
function CraftingLogMgr:GetAllCareerData()
    self.AllCareerData = {}
    for ProfID, SortPriority in pairs(CareerSortData) do
        local VerIconTabIcons = GatheringLogDefine.VerIconTabIcons[ProfID]
        local ProfListIndex = self:GetProfListIndex(ProfID)
        local ProfData = {}
        ProfData.ID = ProfID
        ProfData.IsLock = ProfListIndex == -1 
        ProfData.Prof = ProfID
        ProfData.SortPriority = SortPriority
        ProfData.IconPath = VerIconTabIcons.IconPath
        ProfData.SelectIcon = VerIconTabIcons.SelectIcon
        ProfData.RedDotType = CraftingNoteType
        --ProfData.bShowlock = false
        table.insert(self.AllCareerData, ProfData)
    end
    table.sort(self.AllCareerData, function(a, b)
        if a.IsLock ~= b.IsLock then
            return a.IsLock == false and b.IsLock == true
        end
        return a.SortPriority < b.SortPriority
    end)
    return self.AllCareerData
end

---已解锁职业详情
function CraftingLogMgr:GetProfListIndex(ProfID)
    local RoleDetail = ActorMgr:GetMajorRoleDetail()
    local Prof = RoleDetail and RoleDetail.Prof
    local ProfList = Prof and Prof.ProfList
    if not table.is_nil_empty(ProfList) then
        for Index, v in pairs(ProfList) do
            if v.ProfID == ProfID then
                return Index
            end
        end
    end
    return -1
end

---@type 获取最后选择的职业Index
function CraftingLogMgr:GetChoiceCareer()
    local MajorProfID = self.LastChoiceCareer or MajorUtil:GetMajorProfID()
    local AllAllowData = self:GetAllCareerData()
    -- 当前职业ID
    local ChoiceIndex = nil
    -- 找到 当前职业的下标
    if nil ~= MajorProfID then
        local Specialization = RoleInitCfg:FindProfSpecialization(MajorProfID)
        if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
            for key, value in ipairs(AllAllowData) do
                if value.ID == MajorProfID then
                    ChoiceIndex = key
                    self:SetLastChoiceCareer(key)
                    break
                end
            end
        end
    end
    return ChoiceIndex or 1
end

---@type 获取最后选择的职业ID
function CraftingLogMgr:GetChoiceProfID()
    local ChoiceIndex = self:GetChoiceCareer()
    local AllAllowData = self:GetAllCareerData()
    if AllAllowData and AllAllowData[ChoiceIndex] then
        return AllAllowData[ChoiceIndex].Prof
    end
end

-- endregion

-- region 记忆功能

-- 记录当前职业数据
function CraftingLogMgr:RecordCareerData()
    -- 首次不记录，避免覆盖数据
    if not self.bCanRecord then
        self.bCanRecord = true
        return
    end
    local LastChoiceCareer = self.LastChoiceCareer
    if not LastChoiceCareer or self.CraftingState == CraftingLogState.Searching then
        return
    end
    local NowPropData = self.NowPropData
    local ThisRecipeID = NowPropData and NowPropData.ID or 0
    if LastChoiceCareer then
        local RecipeID = ThisRecipeID
        if self.LastHorTabIndex then
            local LastHorTabIndex = self.LastHorTabIndex
            local LastDropDownIndex = self.LastDropDownIndex
            local bUseDefaultIndex = self.LastDropDownIndex == 1
            self.CareerCheckMap[LastChoiceCareer] = {
                RecipeID = {
                    [LastHorTabIndex] = RecipeID
                },
                HorIndex = LastHorTabIndex,
                DropDownIndexs = {
                    [LastHorTabIndex] = LastDropDownIndex
                },
                bUseDefaultIndex = bUseDefaultIndex
            }
        end
    end
end

---获取当前职业的存储数据
---@return table
function CraftingLogMgr:GetCareerCheckData(AssignProf)
    local CareerCheckMap = self.CareerCheckMap
    local Prof = AssignProf or self.LastChoiceCareer
    if CareerCheckMap[Prof] then
        return CareerCheckMap[Prof]
    end
    return {}
end

---根据职业获取最后选择的筛选下标
---@param Prof number
---@return number
function CraftingLogMgr:GetLastHorTabIndex(Prof)
    local HorIndex = 1
    local CareerCheckMap = self.CareerCheckMap
    if CareerCheckMap[Prof] then
        HorIndex = CareerCheckMap[Prof].HorIndex or 1
    end
    return HorIndex
end

-- 获取下标
function CraftingLogMgr:GetRecipeIndex()
    local NowChoiceIndex = 0
    local CareerCheckMap = self.CareerCheckMap
    local ChoiceCareer = self.LastChoiceCareer
    if ChoiceCareer then
        local CareerCheckData = CareerCheckMap[ChoiceCareer]
        local ProListWithProf = self.ProListWithProf
        local NowChoiceID = (CareerCheckData and CareerCheckData.RecipeID and CareerCheckData.RecipeID[self.LastHorTabIndex])
            or (not table.is_nil_empty(ProListWithProf) and ProListWithProf[1].ID)
        --系统解锁首次打开制作笔记，选中等级最低的简易制作配方
        if self.TutorialGuide == true then
            self.TutorialGuide = false
            table.sort(ProListWithProf,function(a, b) return a.RecipeLevel < b.RecipeLevel end)
            for _, value in pairs(ProListWithProf) do
                if value.CanHQ == 0 then
                    NowChoiceID = value.ID
                    break
                end
            end
        end

        if NowChoiceID and not table.is_nil_empty(ProListWithProf) then
            for key, ItemData in pairs(ProListWithProf) do
                if (NowChoiceID == ItemData.ID) then
                    NowChoiceIndex = key
                    break
                end
            end
        end
    end
    return NowChoiceIndex == 0 and 1 or NowChoiceIndex
end

-- endregion

---设置最后选择的职业
---@param Index number
function CraftingLogMgr:SetLastChoiceCareer(Index)
    local AllCareerData = self:GetAllCareerData()
    if self.LastChoiceCareer == nil or self.LastChoiceCareer ~= AllCareerData[Index].ID then
        self.LastChoiceCareer = AllCareerData[Index].Prof
        self:SetLastHorTabIndex(self:GetCareerCheckData().HorIndex or 1)
    end
end

---获取下拉列表下标
---@param RecipeID number
function CraftingLogMgr:GetLastDropDownIndex()
    local LastChoiceCareer = self.LastChoiceCareer
    if not LastChoiceCareer then
        return 1
    end
    local DropDownIndex
    local ThisCareerData = self.CareerCheckMap[LastChoiceCareer]
    if ThisCareerData and ThisCareerData.DropDownIndexs then
        DropDownIndex = ThisCareerData.DropDownIndexs[self.LastHorTabIndex]
    end
    if not DropDownIndex then
        --普通页签选中等级段
        if self.LastHorTabIndex == 1 and MajorUtil.IsCrafterProfByProfID(LastChoiceCareer) then
            local Level = MajorUtil.GetMajorLevelByProf(LastChoiceCareer) or 1
            DropDownIndex = Level and ((Level - 1)//5 + 1)
            if self.ReverseOrder then
                local Len = CraftingLogDefine.MaxLevel//5
                DropDownIndex = Len + 1 - DropDownIndex
            end
        else
            DropDownIndex = 1
        end
    end
    return DropDownIndex or 1
end

-- region DropDownData

---获取下拉列表下标
function CraftingLogMgr:GetDropDownIndex()
    local HorIndex = self.LastHorTabIndex
    local DropDownIndex = 1
    if HorIndex == FilterALLType.Level then
        DropDownIndex = self:GetDrowIndexByLevel()
    elseif HorIndex == FilterALLType.Career then
        DropDownIndex = self:GetDrowIndexByCareer()
    elseif HorIndex == FilterALLType.Collect then
        DropDownIndex = self:GetDrowIndexByCollect()
    elseif HorIndex == FilterALLType.Time then
        local DropDownIndexs = self:GetCareerCheckData().DropDownIndexs
        DropDownIndex = DropDownIndexs and DropDownIndexs[HorIndex] or 1
    end
    return DropDownIndex
end

---根据配方ID获取下拉列表下标
---@param RecipeID number
---@return number
function CraftingLogMgr:GetDrowIndexByLevel()
    local RecipedData = self:GetRecipeDataById(self:GetCareerCheckData().RecipeID)
    if not RecipedData then
        return 1
    end
    local ThisRecipeLevel = RecipedData.RecipeLevel
    local FilterLevelList = self.FilterLevelList
    for key, value in pairs(FilterLevelList) do
        if value.FloorLimitLevel <= ThisRecipeLevel then
            return key
        end
    end
    return 1
end

function CraftingLogMgr:GetDrowIndexByCareer()
    local RecipedData = self:GetRecipeDataById(self:GetCareerCheckData().RecipeID)
    local ThisRecipeLable = RecipedData.RecipeType
    local FilterLevelList = self.FilterLevelList
    for key, value in pairs(FilterLevelList) do
        if value.RecipeType == ThisRecipeLable then
            return key
        end
    end
    return 1
end

function CraftingLogMgr:GetDrowIndexByCollect()
    local RecipedData = self:GetRecipeDataById(self:GetCareerCheckData().RecipeID)
    if not RecipedData then
        return 1
    end
    local ThisRecipeLevel = RecipedData.RecipeLevel
    local FilterLevelList = self.FilterLevelList
    local FilterLen = #FilterLevelList
    for index = 2, FilterLen do
        if FilterLevelList[index].FloorLimitLevel <= ThisRecipeLevel then
            return index
        end
    end
    return 1

    -- local RecipeID = self:GetCareerCheckData().RecipeID
    -- local ThisHistoryData = self.HistoryList[self.LastChoiceCareer] or {}
    -- local Time = 0
    -- if ThisHistoryData[RecipeID] then
    --     Time = os.time() - self.HistoryList[self.LastChoiceCareer][RecipeID]
    -- else
    --     return 1
    -- end
    -- local NormalDaySecond = CraftingLogDefine.NormalDaySecond
    -- local SpaceFilterData = CraftingLogDefine.SpaceFilterData
    -- local FilterLen = #SpaceFilterData
    -- for index = 2, FilterLen do
    --     if(Time - SpaceFilterData[index].SectionDay*NormalDaySecond <= 0)then
    --         return index
    --     end
    -- end
    -- return 1
end

---设置最后选择的筛选数据
---@param HorTabIndex number
function CraftingLogMgr:SetLastHorTabIndex(HorTabIndex)
    -- if self.LastHorTabIndex ~= HorTabIndex then
    self.LastHorTabIndex = HorTabIndex
    CraftingLogMgr:GetDropDownData(HorTabIndex)
    self.LastDropDownIndex = self:GetLastDropDownIndex()
    self.NowChoicePropData = nil
    self.NowPropData = nil
    -- end
end

-- endregion

---设置选择的下拉列表
---@param DropDownIndex number
function CraftingLogMgr:SetLastDropDownIndex(DropDownIndex)
    if not self.LastChoiceCareer or not self.LastHorTabIndex then
        _G.FLOG_INFO("Invalid Career/HorTabIndex:")
        return
    end
    --if self.LastDropDownIndex ~= DropDownIndex then
        self.LastDropDownIndex = DropDownIndex
        self.NowChoicePropData = nil
        self.NowPropData = nil
        self.CareerCheckMap = self.CareerCheckMap or {}
        if not self.CareerCheckMap[self.LastChoiceCareer] then
            self.CareerCheckMap[self.LastChoiceCareer] = {} 
        end
        if not self.CareerCheckMap[self.LastChoiceCareer].DropDownIndexs then
            self.CareerCheckMap[self.LastChoiceCareer].DropDownIndexs = {}
        end
        self.CareerCheckMap[self.LastChoiceCareer].DropDownIndexs[self.LastHorTabIndex] = DropDownIndex
    --end
end

---NowProfData变化
function CraftingLogMgr:ChangeNowProfData()
    if self.NowSearchPropData ~= nil then
        self.NowPropData = self.NowSearchPropData
    else
        self.NowPropData = self.NowChoicePropData
    end
end

---设置当前的道具数据
---@param NowPropData RecipeCfg
function CraftingLogMgr:SetNowChoicePropData(NowPropData)
    NowPropData.Name = ItemUtil.GetItemName(NowPropData.ProductID)
    if self.CraftingState == CraftingLogState.Picking then
        self:SetNowChoicePropDataPicking(NowPropData)
    else
        self.NowSearchPropData = NowPropData
    end
end
function CraftingLogMgr:SetNowChoicePropDataPicking(NowPropData)
    local ThisProf = NowPropData.Craftjob
    local ThisProfData = self.CareerCheckMap[ThisProf] or {}
    ThisProfData.RecipeID = ThisProfData.RecipeID or {}
    self.LastHorTabIndex = self.LastHorTabIndex or 1
    ThisProfData.RecipeID[self.LastHorTabIndex] = NowPropData.ID
    self.CareerCheckMap[ThisProf] = ThisProfData
    self.NowChoicePropData = NowPropData
end

function CraftingLogMgr:GetNowPropData()
    return self.NowPropData
end

function CraftingLogMgr:GetNowRecipeID()
    if self.NowPropData then
        return self.NowPropData.ID
    end

    return 0
end

---获取当前最大制作数量
function CraftingLogMgr:GetMaxMakeCount()
    return self.MaxMakeCount
end

---设置当前最大制作数量
---@param MaxMakeCount number
function CraftingLogMgr:SetMaxMakeCount(MaxMakeCount)
    self.MaxMakeCount = MaxMakeCount
end

function CraftingLogMgr:OnBegin()
    self.bArraignmentVersion = LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_VERIFY)
end

function CraftingLogMgr:OnEnd()
    local View = UIViewMgr:FindVisibleView(UIViewID.CraftingLog)
    if View then
        UIViewMgr:HideView(UIViewID.CraftingLog)
    end
end

---清理数据
function CraftingLogMgr:OnShutdown()
    self:Reset()
end

-- region Sever
---注册网络消息
function CraftingLogMgr:OnRegisterNetMsg()
    -- 获取解锁了的版本号及背包中的秘籍是否使用过
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_QUERY_VERSION, self.OnNetMsgQueryVersion)
    -- 拉取收藏列表
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_MARK_LIST, self.OnNetMsgCollectItemsInfo)
    -- 收藏道具消息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_MARK, self.OnNetMsgCollectOrNotinfo)
    -- 取消收藏道具消息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_CANCEL_MARK, self.OnNetMsgCancelCollect)
    -- 获取历史记录
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_HISTORY_LIST, self.OnNetMsgHistoryInfo)
    -- 更新历史记录
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_NOTIFY_HISTORY_UPDATE, self.OnNetMsgHistoryUpdate)

    -- 获取/更新制作笔记获得下拉列表的新字
    --self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_COLLECTION_APPEAR, self.OnNetMsgAddRedDot)
    -- 移除采集笔记获得下拉列表的新字
    --self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_COLLECTION_REMOVE_APPEAR, self.OnNetMsgRemoveRedDot)
end

---数据初始化
function CraftingLogMgr:SeverDatainit()
    -- 查询背包里的卷是否使用了，版本号读本地了
    self:SendMsgQueryVersion()

    if self.HistoryList == nil then
        self.HistoryList = {}
        -- 拉取历史记录
        self:SendMsgHistoryListinfo()
    end

    if self.CollectListData == nil then
        self.CollectListData = {}
        -- 拉取收藏记录
        self:SendMsgMarkListinfo()
    end
end

-- 查询版本号
function CraftingLogMgr:SendMsgQueryVersion()
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_QUERY_VERSION

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.queryVersion = {}
    MsgBody.queryVersion.NoteType = CraftingNoteType
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    self.IsSendMsgQueryVersion = true
end

function CraftingLogMgr:OnNetMsgQueryVersion(MsgBody)
    if MsgBody == nil or MsgBody.queryVersion == nil then
        return
    end
    local queryVersion = MsgBody.queryVersion
    if queryVersion.NoteType == nil or queryVersion.NoteType ~= CraftingNoteType then
        return
    end
    self:SaveUseEsotericaProf(queryVersion.Unlocks)

    if self.IsSendMsgQueryVersion == false then
        if not table.is_nil_empty(queryVersion.Unlocks) then
            local Unlock = queryVersion.Unlocks[1]
            local ReadData = CraftingLogMgr:GetSpecialReadData(Unlock.Prof, SpecialType.SpecialTypeSecret)
            local ReadVersion = ReadData and ReadData.ReadVersion or 0
            local IsRead = ReadData and ReadData.IsRead
            self:SendMsgUpdateDropNewData(Unlock.Prof, 0, SpecialType.SpecialTypeSecret, ReadVersion, IsRead, Unlock.Volume)
        end
        return
    end

    self.IsSendMsgQueryVersion = false
    -- 版本更新，检查传承录的更新
    self:UpdateEsotericaRedDot()
    -- 版本更新或使用完之后，更新特殊页签
    local CraftingLog = UIViewMgr:FindVisibleView(UIViewID.CraftingLog)
    if CraftingLog and self.LastHorTabIndex == FilterALLType.Career and self.CraftingState == CraftingLogState.Picking then
        _G.EventMgr:SendEvent(EventID.CraftingLogUpdateHorTabs, 2)
    end
end

function CraftingLogMgr:SaveUseEsotericaProf(Unlocks)
    self.UseEsotericaProf = self.UseEsotericaProf or {}
    if table.is_nil_empty(Unlocks) then
        return
    end
    for _, value in pairs(Unlocks) do
        local Prof = value.Prof
        if self.UseEsotericaProf[Prof] == nil then
            self.UseEsotericaProf[Prof] = {}
        end
        local Volume = value.Volume
        self.UseEsotericaProf[Prof][Volume] = true
    end
end

---收藏或取消 C2S
---@param NoteType number
---@param MarkID number
function CraftingLogMgr:SendMsgMarkOrNotinfo(MarkID, IsCollect)
    ---是否超出收藏最大数量
    if IsCollect and table.length(self.CollectListData[self.LastChoiceCareer] or {}) >= self.MaxCollectCount then
        _G.MsgTipsUtil.ShowTips(LSTR(80014)) --该职业收藏数量已上限
        return false
    end
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_MARK
    local MsgBody = {}
    if IsCollect then
        MsgBody.Cmd = SubMsgID
        MsgBody.mark = {}
        MsgBody.mark.NoteType = ProtoCS.NoteType.NOTE_TYPE_PRODUCTION
        MsgBody.mark.MarkID = MarkID
    else
        SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_CANCEL_MARK
        MsgBody.Cmd = SubMsgID
        MsgBody.cancelMark = {}
        MsgBody.cancelMark.NoteType = ProtoCS.NoteType.NOTE_TYPE_PRODUCTION
        MsgBody.cancelMark.MarkID = MarkID
    end
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---收藏 S2C
---@param MsgBody any
function CraftingLogMgr:OnNetMsgCollectOrNotinfo(MsgBody)
    if nil == MsgBody or MsgBody.mark == nil then
        return
    end
    local CraftingLogNoteType = 2
    if MsgBody.mark.NoteType ~= CraftingLogNoteType then
        return
    end
    if MsgBody.mark.IsMarked == false then
        self:DelCraftingRsqList(MsgBody.mark.MarkID)
    else
        local MarkID = MsgBody.mark.MarkID
        local ThisCollectProf = self:GetRecipeDataById(MarkID).Craftjob
        local ListData = self.CollectListData
        if not ListData[ThisCollectProf] then
            ListData[ThisCollectProf] = {}
        end
        ListData[ThisCollectProf][MarkID] = true
    end
    _G.EventMgr:SendEvent(_G.EventID.CraftingLogCollectInit)
end

---取消收藏 S2C
---@param MsgBody any
function CraftingLogMgr:OnNetMsgCancelCollect(MsgBody)
    if nil == MsgBody or MsgBody.cancelMark == nil then
        return
    end
    local CraftingLogNoteType = 2
    if MsgBody.cancelMark.NoteType ~= CraftingLogNoteType then
        return
    end
    self:DelCraftingRsqList(MsgBody.cancelMark.MarkID)
    _G.EventMgr:SendEvent(_G.EventID.CraftingLogCollectInit)
end

---请求收藏列表 C2S
---@param NoteType number
function CraftingLogMgr:SendMsgMarkListinfo()
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_MARK_LIST

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.markList = {}
    MsgBody.markList.NoteType = CraftingNoteType
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---请求收藏列表 S2C
---@param MsgBody any
function CraftingLogMgr:OnNetMsgCollectItemsInfo(MsgBody)
    if nil == MsgBody or MsgBody.markList.NoteType ~= CraftingNoteType then
        return
    end
    local CollectItemList = MsgBody.markList.MarkList -- 回包信息
    if #CollectItemList == 0 then
        return
    end

    self:UpdateCraftingRsqList(CollectItemList)
end

---初始化收藏列表
---@param Data any
function CraftingLogMgr:UpdateCraftingRsqList(Data)
    self.CollectListData = {}
    local ListData = self.CollectListData
    for _, value in pairs(Data) do
        local RecipeData = self:GetRecipeDataById(value)
        if RecipeData ~= nil then
            local ThisCollectProf = RecipeData.Craftjob
            if not ListData[ThisCollectProf] then
                ListData[ThisCollectProf] = {}
            end
            ListData[ThisCollectProf][value] = true
        end
    end
    _G.EventMgr:SendEvent(_G.EventID.CraftingLogCollectInit)
end

---删除收藏
---@param Id number
function CraftingLogMgr:DelCraftingRsqList(ID)
    if not ID then
        return
    end
    local ListData = self.CollectListData
    local ThisCollectProf = self:GetRecipeDataById(ID).Craftjob
    if not ListData[ThisCollectProf] then
        ListData[ThisCollectProf] = {}
    end
    if ListData[ThisCollectProf][ID] then
        ListData[ThisCollectProf][ID] = nil
        _G.EventMgr:SendEvent(_G.EventID.CraftingLogCancelMake, ID)
    end

    if self:GetNowRecipeID() == ID then
        _G.CraftingLogVM.bSetFavor = false
    end
end

-- 获取历史记录 C2S
---@param NoteType any
function CraftingLogMgr:SendMsgHistoryListinfo()
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_HISTORY_LIST

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.historyList = {}
    MsgBody.historyList.NoteType = CraftingNoteType
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--给制作记录更新加一层保障（主要是靠CraftingLogMgr:OnMakeComplete更新）
function CraftingLogMgr:OnNetMsgHistoryUpdate(MsgBody)
    local historyUpdate = MsgBody.historyUpdate
    if historyUpdate.NoteType == CraftingNoteType then
        local UpdateList = historyUpdate.UpdateList
        if not table.is_nil_empty(UpdateList) then
            local DoneID = UpdateList[1].DoneID
            local RecipeData = DoneID and self:GetRecipeDataById(DoneID)
            if RecipeData == nil or self:GetIsDone(RecipeData) then
                return
            end
            self.HistoryUpdateMsg = UpdateList[1]
        end
    end
end

function CraftingLogMgr:HistoryUpdate()
    local HistoryUpdateMsg = self.HistoryUpdateMsg
    local DoneID = HistoryUpdateMsg and HistoryUpdateMsg.DoneID
    local RecipeData = DoneID and self:GetRecipeDataById(DoneID)
    if RecipeData == nil then
        FLOG_ERROR(string.format("CraftingLogMgr:InitHistoryList RecipeData is nil, DoneID = %d", DoneID))
        return
    end
    self.HistoryList = self.HistoryList or {}
    local ListData = self.HistoryList
    local ThisCollectProf = RecipeData.Craftjob
    if not ListData[ThisCollectProf] then
        ListData[ThisCollectProf] = {}
    end
    ListData[ThisCollectProf][DoneID] = TimeUtil.GetServerTime()
end

-- 获取历史记录 S2C
---@param MsgBody any
function CraftingLogMgr:OnNetMsgHistoryInfo(MsgBody)
    if MsgBody.historyList.NoteType == CraftingNoteType then
        self:InitHistoryList(MsgBody.historyList.ItemList)
    end
end

function CraftingLogMgr:InitHistoryList(HistoryList)
    if table.is_nil_empty(HistoryList) then
        self.FirstCraftedHQItem = false
    end
    self.HistoryList = {}
    local ListData = self.HistoryList
    for _, value in pairs(HistoryList) do
        local RecipeData = self:GetRecipeDataById(value.DoneID)
        if RecipeData == nil then
            FLOG_ERROR(string.format("CraftingLogMgr:InitHistoryList RecipeData is nil, DoneID = %d", value.DoneID))
            break
        end
        local ThisCollectProf = RecipeData.Craftjob
        if not ListData[ThisCollectProf] then
            ListData[ThisCollectProf] = {}
        end
        ListData[ThisCollectProf][value.DoneID] = value.LastTime
        --FirstCraftedHQItem初始化，新手引导处理后更新值
        if self.FirstCraftedHQItem == false and RecipeData.CanHQ == 1 then
            self.FirstCraftedHQItem = true
        end
    end
    _G.EventMgr:SendEvent(_G.EventID.CraftingLogHistoryInit)
end

function CraftingLogMgr:GetIsDone(RecipeData)
    if RecipeData == nil or self.HistoryList == nil then
        return false
    end
    local RecipeDatas = self.HistoryList[RecipeData.Craftjob]
    if RecipeDatas == nil then
        return false
    end
    local LastTime = RecipeDatas[RecipeData.ID]
    return LastTime ~= nil
end

-- 开始制作   普通制作
function CraftingLogMgr:SendStartMakeReq(bIsTrain)
    if self:CheckMakeState(bIsTrain) and self:CheckBagCapacity(bIsTrain) and
        self:CheckSlaveHand() then
        self.WorkingID = self.NowPropData.ID
        _G.CrafterMgr:StartMake(self.NowPropData.ID, bIsTrain, self.NowMakeCount)
    end
end

function CraftingLogMgr:SendStartSimpleMakeReq()
    self.WorkingID = self.NowPropData.ID
    local bFastCraft = self.NowPropData.FastCraft == 1
    _G.CrafterMgr:StartSimpleMake(self.NowPropData.ID, _G.CrafterMgr:GetNowSimpleMakeCount(), bFastCraft)
end

function CraftingLogMgr:ShowProfUnmatchTips()
    _G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(80015), --切换职业
        string.format(
            "%s<span color=\"#D1BA8E\">“%s”</>%s？", LSTR(80016), --是否切换为
            RoleInitCfg:FindCfgByKey(self.NowPropData.Craftjob).ProfName, LSTR(80061)), --并开始制作
            function()
                -- _G.ProfMgr:SwitchProfByID(self.NowPropData.Craftjob)
                if not _G.ProfMgr:CanChangeProf(self.NowPropData.Craftjob) then
                return
            end
            self.SwitchProfInNote = true
            self:RegisterTimer(function()
                _G.EquipmentMgr:SwitchProfByID(self.NowPropData.Craftjob)
            end, 0.2, 1, 1)
        end, nil, nil, LSTR(10002), {
            HideCloseBtn = true
        })
end

---@type 检查制作状态
function CraftingLogMgr:CheckMakeState(bIsTrain)
    local Major = MajorUtil.GetMajor()
    if Major and Major:IsSwimming() then
        _G.MsgTipsUtil.ShowTips(LSTR(80017)) --当前状态无法使用
        return false
    end

    -- 训练制作只判断职业是否匹配
    if bIsTrain then
        -- EnoughState同时材料不足职业不匹配时, 优先处于材料不足的状态, 这里直接用ProfID判断更准确
        if self.NowPropData.Craftjob ~= MajorUtil:GetMajorProfID() then
            if self:GetProfIsLock(self.NowPropData.Craftjob) then
                _G.MsgTipsUtil.ShowTips(LSTR(80018)) --该职业暂未解锁
            else
                self:ShowProfUnmatchTips()
            end
            return false
        end

        local Level = MajorUtil.GetMajorLevelByProf(self.NowPropData.Craftjob) or 0
        if self.NowPropData.RecipeLevel - Level >= 10  then
            _G.MsgTipsUtil.ShowTips(LSTR(80019)) --配方等级大于职业等级10级，无法开始制作或制作练习
            return
        end
        --练习制作是只有普通制作才显示的，所以用普通制作/加工精度
        local AttrWorkPrecision = _G.UE.UActorUtil.GetActorAttrValue(MajorUtil.GetMajorEntityID(), ProtoCommon.attr_type.attr_work_precision)
        local LimitAttrWorkPrecision = self.NowPropData.CraftmanshipNeed
        if AttrWorkPrecision < LimitAttrWorkPrecision then
            _G.MsgTipsUtil.ShowTips(LSTR(80020)) --作业精度不足，无法开始制作或制作练习
            return false
        end

        local AttrProducePrecision = _G.UE.UActorUtil.GetActorAttrValue(MajorUtil.GetMajorEntityID(), ProtoCommon.attr_type.attr_produce_precision)
        local LimitAttrProdecePresicion = self.NowPropData.ControlNeed
        if LimitAttrProdecePresicion and AttrProducePrecision < LimitAttrProdecePresicion then
            _G.MsgTipsUtil.ShowTips(LSTR(80021)) --加工精度不足，无法开始制作或制作练习
            return false
        end
        return true
    end

    --  是否满足制作条件
    if self.EnoughState == UnEnoughType.Default then
        return true
    elseif self.EnoughState == UnEnoughType.Prof then -- 职业
        if self:GetProfIsLock(self.NowPropData.Craftjob) then
            _G.MsgTipsUtil.ShowTips(LSTR(80018)) --该职业暂未解锁
        else
            self:ShowProfUnmatchTips()
        end
        return false
    elseif self.EnoughState == UnEnoughType.ProfLevel then -- 职业等级
        _G.MsgTipsUtil.ShowTips(LSTR(80023)) --配方等级大于职业等级10级，无法进行制作
        return false
    elseif self.EnoughState == UnEnoughType.Material then -- 材料
        _G.MsgTipsUtil.ShowTips(LSTR(80024)) --制作所需素材不足，无法进行制作
        return false
    elseif self.EnoughState == UnEnoughType.CrystalType then -- 触媒
        _G.MsgTipsUtil.ShowTips(LSTR(80025)) --水晶不足，无法进行制作
        return false
    elseif self.EnoughState == UnEnoughType.Craftmanship then -- 作业精度
        _G.MsgTipsUtil.ShowTips(LSTR(80026)) --作业精度不足，无法进行制作
        return false
    elseif self.EnoughState == UnEnoughType.CraftControl then -- 加工精度
        _G.MsgTipsUtil.ShowTips(LSTR(80027)) --加工精度不足，无法进行制作
        return false
    end
    return true
end

---@type 检查精度
function CraftingLogMgr:CheckPresicion()
    local MakeBtnState = _G.CraftingLogVM.MakeBtnState

    local AttrWorkPrecision = _G.UE.UActorUtil.GetActorAttrValue(MajorUtil.GetMajorEntityID(),
        ProtoCommon.attr_type.attr_work_precision)
    local AttrProducePrecision = _G.UE.UActorUtil.GetActorAttrValue(MajorUtil.GetMajorEntityID(),
        ProtoCommon.attr_type.attr_produce_precision)

    --普通制作时，用普通制作/加工精度
    local LimitAttrWorkPrecision = self.NowPropData.CraftmanshipNeed
    local LimitAttrProdecePresicion = self.NowPropData.ControlNeed
    if MakeBtnState == CraftingLogDefine.MakeBtnState.Easy then -- 简易制作
        LimitAttrWorkPrecision = self.NowPropData.SimpleCraftmanShipNeed
        LimitAttrProdecePresicion = self.NowPropData.SimpleCraftControlNeed
    elseif MakeBtnState == CraftingLogDefine.MakeBtnState.Fast then -- 快速制作
        LimitAttrWorkPrecision = self.NowPropData.HQFastCraftmanShipNeed
        LimitAttrProdecePresicion = self.NowPropData.HQFastCraftControlNeed
    end

    -- 消耗物都满足才判断 精度是否足够
    if AttrWorkPrecision < LimitAttrWorkPrecision then
        self.EnoughState = UnEnoughType.Craftmanship
        return false
    end
    if LimitAttrProdecePresicion and AttrProducePrecision < LimitAttrProdecePresicion then
        self.EnoughState = UnEnoughType.CraftControl
        return false
    end
    return true
end

---检查背包容量
function CraftingLogMgr:CheckBagCapacity(bIsTrain)
    -- local RecipeID = self.NowPropData.ID
    local RecipeConfig = self.NowPropData -- RecipeCfg:FindCfgByKey(RecipeID)
    if not RecipeConfig then
        return false
    end

    if bIsTrain then
        return true
    end

    local BagLeftNum = BagMgr:GetBagLeftNum()
    if BagLeftNum < 1 then
        _G.MsgTipsUtil.ShowTips(LSTR(80028)) --背包空间不足，无法进行制作作业。
        return false
    end

    local MakeNum = self.MakeState == CraftingLogDefine.MakeRecipeState.Normal and self.NowMakeCount or _G.CrafterMgr:GetNowSimpleMakeCount()
    if MakeNum > 1 then
        local PropMaxPile = self:GetPropMaxPile(RecipeConfig)
        if BagLeftNum < math.ceil(MakeNum / PropMaxPile) then
            _G.MsgTipsUtil.ShowTips(LSTR(80028)) --背包空间不足，无法进行制作作业。
            return false
        end
    end
    return true
end

function CraftingLogMgr:GetPropMaxPile(RecipeConfig)
    local function GetMaxPileByProductID(ProductID)
        local ItemData = ItemCfg:FindCfgByKey(ProductID)
        local MaxPile = 1
        if ItemData and ItemData.MaxPile > 1 then
            MaxPile = ItemData.MaxPile
        end
        return MaxPile
    end
    local PropMaxPile
    if RecipeConfig.CanHQ == 0 then
        PropMaxPile = GetMaxPileByProductID(RecipeConfig.ProductID)
    else
        --如果制作后NQ和HQ道具的堆叠上限不同，按照堆叠上限最小，即背包格子需求最大的数量来算
        local NQMaxPile = GetMaxPileByProductID(RecipeConfig.ProductID)
        local HQMaxPile = GetMaxPileByProductID(RecipeConfig.HQProductID)
        PropMaxPile =  NQMaxPile <= HQMaxPile and NQMaxPile or HQMaxPile
    end
    return PropMaxPile
end

-- 判斷是否佩戴了副手裝備
function CraftingLogMgr:CheckSlaveHand()
    local EquipPart = ProtoCommon.equip_part
    local InPart = EquipPart.EQUIP_PART_SLAVE_HAND
    local EquipItem = EquipmentMgr:GetEquipedItemByPart(InPart)
    local CurrentToolName = self.CurrentToolName
    if CurrentToolName == "" then
        -- 為空時只需要主手武器
        return true
    end
    if EquipItem ~= nil then
        return true
    end
    _G.MsgTipsUtil.ShowTips(LSTR(80029)) --没有穿戴副手，无法制作此配方。
    return false
end

---ButtonState
function CraftingLogMgr:ButtonState()
    local bButtonState = false
    if self.EnoughState == UnEnoughType.Default then
        bButtonState = true
    end
    _G.EventMgr:SendEvent(_G.EventID.CraftingLogButtonState, bButtonState)
end

---开始制作
---@param MsgBody any
function CraftingLogMgr:OnMakeComplete(Result, IsNormal)
    if not self.WorkingID then
        return
    end
    local RecipeData = self:GetRecipeDataById(self.WorkingID)
    if RecipeData == nil then
        FLOG_ERROR(string.format("CraftingLogMgr:OnMakeComplete RecipeData is nil, WorkingID = %d", self.WorkingID))
        return
    end
    local ProfHistoryList = CraftingLogMgr.HistoryList[RecipeData.Craftjob]

    local bImgDoneShow = ProfHistoryList and ProfHistoryList[RecipeData.ID] and true or false
    if not bImgDoneShow then
        if IsNormal then
            if Result.Success then
                if RecipeData.BatchNum ~= nil and RecipeData.BatchNum > 0 then
                    local function ShowTips()
                        _G.MsgTipsUtil.ShowTips(LSTR(80030)) --可以对该配方使用批量制作了！
                    end
                    self:RegisterTimer(ShowTips, 3, 0, 1, nil)
                end
            else
                return
            end
        else
            if Result.SimpleRsp and Result.SimpleRsp.SuccessNum < 1 then
                return
            end
        end
    end

    local ThisCollectProf = self:GetRecipeDataById(self.WorkingID).Craftjob
    if not self.HistoryList[ThisCollectProf] then
        self.HistoryList[ThisCollectProf] = {}
    end
    self.HistoryList[ThisCollectProf][self.WorkingID] = TimeUtil.GetServerTime()

    _G.EventMgr:SendEvent(_G.EventID.CraftingLogMakeSucceedBack, RecipeData)

    local DoneID = self.HistoryUpdateMsg and self.HistoryUpdateMsg.DoneID
    if DoneID == nil or DoneID == self.WorkingID then
        self.HistoryUpdateMsg = nil
    end
    self.WorkingID = nil
end

---@type 首次制作经验的提示
function CraftingLogMgr:FirstCraftEXPBonus(Name, Score)
    local EXPValue = Score.Value
    local GetRitchText = RichTextUtil.GetText(string.format("%s", LSTR(70029)), "d1ba8e", 0, nil) --获得了
    local ScoreInfo = ScoreCfg:FindCfgByKey(19000099)
    local IconRichText = RichTextUtil.GetTexture(ScoreInfo.IconName, 40, 40, -10)
    local ScoreRichText = RichTextUtil.GetText(string.format("[%s]", ScoreInfo.NameText), "DAB53AFF", 0, nil)
    local SoceNumRichText = RichTextUtil.GetText(string.format("x%s", _G.LootMgr.FormatCurrency(EXPValue)),"d1ba8e", 0, nil)
    local Content = string.format(LSTR(80031), Name, GetRitchText, IconRichText, ScoreRichText,SoceNumRichText) --80031 首次制作了[%s]%s%s%s%s
    if Score.Percent ~= 0 then
        Content = string.format("%s  ( + %d%s)", Content, Score.Percent, "%")
    end
    self:RegisterTimer(function ()
        _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.FirstCraft, Content)
        _G.ChatMgr:AddSysChatMsg(Content)
    end, 1.5, 0, 1, nil)
end

function CraftingLogMgr:ConvenientGM(bConvenient)
    self.bConvenient = bConvenient == 1
    _G.FLOG_INFO("Craft Add Material is Begin %s", self.bConvenient)
end

-- endregion

---5取整
local function RoundFive(Num)
    if Num == nil then
        --FLOG_ERROR("RoundFive Num is nil")
        Num = 0
    end
    local TargerNumber
    local Segment = math.floor(Num / NormalRecipeLevel) * NormalRecipeLevel
    if Segment == 0 then
        TargerNumber = NormalRecipeLevel
    else
        TargerNumber = Segment + NormalRecipeLevel
    end
    if Num % NormalRecipeLevel > NormalIncrementStage then
        TargerNumber = TargerNumber + NormalRecipeLevel
    end
    return TargerNumber or NormalRecipeLevel
end

function CraftingLogMgr:RoundFive(Num)
    return RoundFive(Num)
end

---获取搜索数据
---@param SearchInfo string
function CraftingLogMgr:GetSearchData(SearchInfo)
    self.SearchInfo = SearchInfo
    local ProfList = ActorMgr:GetMajorRoleDetail().Prof.ProfList
    local ScreeningListData = {}
    local Pattern = "^[%p%s]+$"	--清理特殊符号
	if string.match(SearchInfo, Pattern) or tonumber(SearchInfo) then
		return ScreeningListData,1
	end
    local PropData = RecipeCfg:FindAllCfg()
    local ProfData = {}
    local PrecisionID = 0
    -- local bArraignmentVersion = self.bArraignmentVersion
    for _, value in pairs(PropData) do
        if self:BeIncludedInGameVersion(value.Version)  then
            local ThisProfData = ProfList[value.Craftjob]
            local ThisProfLevel = ThisProfData and ThisProfData.Level or 0
            local RecipeName = ItemUtil.GetItemName(value.ProductID)
            local UnlockVolume = self.UseEsotericaProf[value.Craftjob]
            if string.find(tostring(RecipeName), SearchInfo) then 
                if value.RecipeType == RecipeType.RecipeTypeRoutine or
                    (value.RecipeType == RecipeType.RecipeTypeSecret and UnlockVolume and value.CategoryNum and UnlockVolume[value.CategoryNum]) or
                    (value.RecipeType == RecipeType.RecipeTypeCollection and _G.GatheringLogMgr:GetQuestStatus() and (ThisProfLevel//10 + 1) * 10 >= value.RecipeLevel) then
                        if PrecisionID == 0 and RecipeName == SearchInfo then
                            PrecisionID = value.ID
                        end
                        local Craftjob = value.Craftjob
                        local ProfInfo = ProfData[Craftjob]
                        if ProfInfo == nil then
                            ProfInfo = RoleInitCfg:FindCfgByKey(Craftjob)
                            ProfData[Craftjob] = ProfInfo -- 缓存避免重复查找
                        end
                        -- value.ChildTypeFilter = ProfInfo.ProfName
                        table.insert(ScreeningListData, value)
                end
            end
        end
    end
    table.sort(ScreeningListData, self.SortByLevelStar)

    local PrecisionIndex = nil
    if PrecisionID ~= 0 then
        for index, value in pairs(ScreeningListData) do
            value.bLockGray = nil
            if value.ID == PrecisionID then
                PrecisionIndex = index
                break
            end
        end
    end
    return ScreeningListData, PrecisionIndex or 1
end

-- Test 点击tip 自动添加不足道具25个
function CraftingLogMgr:TestEnoughToDo()
    -- GM界面控制是否可以启用便捷添加
    if self.bConvenient == false then
        return
    end
    if self.NowPropData == nil then
        return
    end
    local MaterialData = self.NowPropData.Material
    local NormalToGetMakeCount = CraftingLogDefine.NormalToGetMakeCount
    for _, value in pairs(MaterialData) do
        local ItemID = value.ItemID
        if ItemID ~= 0 then
            local PropHaveNumber = value.IsHQ and BagMgr:GetItemHQNum(value.ItemID) or
                                       BagMgr:GetItemNumWithHQ(value.ItemID)
            local CanMakeCount = math.floor(PropHaveNumber / value.ItemNum)
            if CanMakeCount == 0 then
                _G.GMMgr:ReqGM(string.format("zone bag add %d %d", ItemID, NormalToGetMakeCount))
            end
        end
    end
    local CrystalTypeData = self.NowPropData.CrystalType
    for _, value in pairs(CrystalTypeData) do
        local ItemID = value.ItemID
        if ItemID ~= 0 then
            local PropHaveNumber = BagMgr:GetItemNum(ItemID)
            local CanMakeCount = math.floor(PropHaveNumber / value.ItemNum)
            if CanMakeCount == 0 then
                _G.GMMgr:ReqGM(string.format("zone bag add %d %d", ItemID, NormalToGetMakeCount))
            end
        end
    end
end

function CraftingLogMgr:GetShoppingList()
    if self.NowPropData == nil then
        return {}
    end
    local TempShoppingList = {}
    local ShoppingList = {}
    local MaterialData = self.NowPropData.Material
    for _, value in pairs(MaterialData) do
        if value.ItemID ~= 0 then
            TempShoppingList[value.ItemID] = value
        end
    end
    local CrystalTypeData = self.NowPropData.CrystalType
    for _, value in pairs(CrystalTypeData) do
        if value.ItemID ~= 0 then
            TempShoppingList[value.ItemID] = value
        end
    end
    local ShopID = 1010 --素材商店
    local GoodsInfos = _G.ShopMgr.AllGoodsInfo[ShopID]
    for _, value in pairs(GoodsInfos) do
        local GoodsInfo = value.GoodsInfo
        local ItemID = GoodsInfo.Items[1].ID
        local PropMaterialData = TempShoppingList[ItemID]
        if PropMaterialData then
            table.insert(ShoppingList, {
                ItemID = ItemID,
                NeedNum = PropMaterialData.ItemNum,
                GoodsID = GoodsInfo.ID,
                OnceLimitation = GoodsInfo.OnceLimitation,
            })
            TempShoppingList[ItemID] = nil
        end
    end
    return ShoppingList
end

--- 最大可制作数量
---@param MaterialData any
---@param CrystalTypeData any
function CraftingLogMgr:ToGetMakeUpperLimit(MaterialData, CrystalTypeData)
    local NowPropData = self.NowPropData
    if NowPropData == nil then
        FLOG_ERROR("CraftingLogMgr:ToGetMakeUpperLimit self.NowPropData is nil")
        return false
    end
    if NowPropData.Craftjob ~= MajorUtil.GetMajorProfID() then
        self.EnoughState = UnEnoughType.Prof
        return
    end
    local Level = MajorUtil.GetMajorLevelByProf(NowPropData.Craftjob) or 0
    if NowPropData.RecipeLevel - Level >= 10  then
        self.EnoughState = UnEnoughType.ProfLevel
        return
    end
    self.EnoughState = UnEnoughType.Default
    local UpperLimitCount = CraftingLogDefine.NormalUpperLimitCount
    for i, value in pairs(MaterialData) do
        if value.ItemID ~= 0 then
            local PropHaveNumber = value.IsHQ and BagMgr:GetItemHQNum(value.ItemID) or
                                       BagMgr:GetItemNumWithHQ(value.ItemID)
            if PropHaveNumber >= value.ItemNum then
                local CanMakeCount = math.floor(PropHaveNumber / value.ItemNum)
                if i == 1 then
                    UpperLimitCount = CanMakeCount
                end
                if UpperLimitCount > CanMakeCount then
                    UpperLimitCount = CanMakeCount
                end
            else
                self.EnoughState = UnEnoughType.Material
                self:SetMaxMakeNumber(0)
                return
            end
        end
    end

    for _, value in pairs(CrystalTypeData) do
        if value.ItemID ~= 0 then
            local PropHaveNumber = BagMgr:GetItemNum(value.ItemID)
            if PropHaveNumber >= value.ItemNum then
                local CanMakeCount = math.floor(PropHaveNumber / value.ItemNum)
                if UpperLimitCount > CanMakeCount then
                    UpperLimitCount = CanMakeCount
                end
            else
                self.EnoughState = UnEnoughType.CrystalType
                self:SetMaxMakeNumber(0)
                return
            end
        end
    end

    self:CheckPresicion()

    if NowPropData.BatchNum > 0 and UpperLimitCount > NowPropData.BatchNum then
        UpperLimitCount = NowPropData.BatchNum
    end
    self:SetMaxMakeNumber(UpperLimitCount)
end

function CraftingLogMgr:SetMaxMakeNumber(UpperLimitCount)
    self:SetMaxMakeCount(UpperLimitCount)
    self.NowMakeCount = 1
end

--------------------------------获取临时配置/数据--------------------------------
---获取所有配方工具数据
function CraftingLogMgr:GetAllCraftToolData()
    if self.AllCraftToolCfg == nil then
        self.AllCraftToolCfg = RecipetoolAnimatiomCfg:FindAllCfg()
    end
    return self.AllCraftToolCfg
end

---获取制作工具数据
---@param Prof number 职业
---@param MainSubTool number 主副手
function CraftingLogMgr:GetCraftToolData(Prof, MainSubTool)
    local AllCraftToolCfg = self:GetAllCraftToolData()
    for _, value in pairs(AllCraftToolCfg) do
        if value.Job == Prof and value.MainSubTool == MainSubTool then
            return value
        end
    end
end

--region 排序
function CraftingLogMgr:OnBtnSorting(DropDown)
    self.ReverseOrder = not self.ReverseOrder
    if self.CraftingState == CraftingLogState.Picking then
        local ProfIDList = CraftingLogDefine.CareerSortData
        local NormalIndex = FilterALLType.Level
        local HorTabsIndex = self.LastHorTabIndex or 1
        for ProfID, _ in pairs(ProfIDList) do
            local SavedData = self.CareerCheckMap[ProfID] and self.CareerCheckMap[ProfID].DropDownIndexs
            local DropDownIndex = SavedData and SavedData[NormalIndex]
            if DropDownIndex then
                local Total = CraftingLogDefine.MaxLevel//5
                local NewDropDownIndex = Total + 1 - DropDownIndex
                if ProfID == self.LastChoiceCareer and HorTabsIndex == NormalIndex then
                    self:GetDropDownData(NormalIndex)
                    local DropDownListData = CraftingLogMgr.FilterLevelList
                    self.LastDropDownIndex = NewDropDownIndex
                    DropDown:UpdateItems(DropDownListData, NewDropDownIndex)
                else
                    SavedData[NormalIndex] = NewDropDownIndex
                end
            end
        end
    end
        _G.CraftingLogVM.PropItemTabAdapter:Sort(self.SortByLevelStar)
    MsgTipsUtil.ShowTips(LSTR(80067))--"已切换排序"
end

local function SortWithFloorlimitlevel(a, b)
    if CraftingLogMgr.ReverseOrder then
        return a.FloorLimitLevel > b.FloorLimitLevel
    else
        return a.FloorLimitLevel < b.FloorLimitLevel
    end
end

---@type 通过等级排序
function CraftingLogMgr.SortByLevelStar(Left, Right)
    --搜索
    if CraftingLogMgr.CraftingState == CraftingLogState.Searching and CraftingLogMgr.SearchInfo ~= nil then
        local searchKey = LSTR(CraftingLogMgr.SearchInfo)
        local leftMatch = Left.Name == searchKey
        local rightMatch = Right.Name == searchKey
        if leftMatch or rightMatch then
            return leftMatch and not rightMatch 
        end
    end
    if Left.Craftjob ~= Right.Craftjob then
        return Left.Craftjob < Right.Craftjob
    end
    if CraftingLogMgr.ReverseOrder then
        if Left.CategoryNum ~= Right.CategoryNum then
            return Left.CategoryNum > Right.CategoryNum
        elseif Left.RecipeStar ~= Right.RecipeStar then
            return Left.RecipeStar > Right.RecipeStar
        elseif Left.RecipeLevel ~= Right.RecipeLevel then
            return Left.RecipeLevel > Right.RecipeLevel
        else
            return Left.ID < Right.ID
        end
    else
        if Left.CategoryNum ~= Right.CategoryNum then
            return Left.CategoryNum < Right.CategoryNum
        elseif Left.RecipeStar ~= Right.RecipeStar then
            return Left.RecipeStar < Right.RecipeStar
        elseif Left.RecipeLevel ~= Right.RecipeLevel then
            return Left.RecipeLevel < Right.RecipeLevel
        else
            return Left.ID < Right.ID
        end
    end
end
--endregion

---获取所有配方数据根据职业
function CraftingLogMgr:GetPropDataByProf(Prof)
    if Prof == nil then
        if self.LastChoiceCareer == nil then
            return {}
        end
        Prof = self.LastChoiceCareer
    end

    if self.RecipeCfgWithProf[Prof] == nil then
        local SearchConditions = string.format("Craftjob = %d",Prof)
        local Datas = RecipeCfg:FindAllCfg(SearchConditions)
        self.RecipeCfgWithProf[Prof] = Datas
    end
    return self.RecipeCfgWithProf[Prof] or {}
end

---获取配方数据根据ID
function CraftingLogMgr:GetRecipeDataById(ID)
    local Cfg = RecipeCfg:FindCfgByKey(ID)
    if Cfg ~= nil then
        Cfg.Name = ItemUtil.GetItemName(Cfg.ProductID)
    end
    return Cfg
end

function CraftingLogMgr:GetRecipeDataByProductID(ProductID)
    if nil == ProductID then return end
    local Cfg = RecipeCfg:FindCfg(string.format("ProductID = %d", ProductID))
        or RecipeCfg:FindCfg(string.format("HQProductID = %d", ProductID))
    if Cfg ~= nil then
        Cfg.Name = ItemUtil.GetItemName(Cfg.ProductID)
    end
    return Cfg
end

---等级筛选
---@param NowProfLevel number 当前职业等级
function CraftingLogMgr:IsChoiceWithLevel(NowProfLevel)
    self.LastDropDownIndex = self.LastDropDownIndex or 1
    local FloorLimitLevel, UpperLimitLevel = self.FilterLevelList[self.LastDropDownIndex].FloorLimitLevel,
        self.FilterLevelList[self.LastDropDownIndex].UpperLimitLevel
    local ProfbLock = self:GetProfIsLock(self.LastChoiceCareer)
    local PropDataList = self:GetPropDataByProf()
    for _, v in pairs(PropDataList) do
        if self:BeIncludedInGameVersion(v.Version) and v.RecipeType == RecipeType.RecipeTypeRoutine and
            (FloorLimitLevel <= v.RecipeLevel and v.RecipeLevel <= UpperLimitLevel) then
            v.bLockGray = ProfbLock or (NowProfLevel + 10) <= v.RecipeLevel
            table.insert(self.ProListWithProf, v)
        end
    end
    table.sort(self.ProListWithProf, self.SortByLevelStar)
end

---特殊筛选
---@param NowProfLevel number 当前职业等级
function CraftingLogMgr:IsChoiceWithCareer(MajorLevel)
    local Prof = self.LastChoiceCareer
    local UnlockVolume = self.UseEsotericaProf[Prof] -- 背包中的秘籍是否使用过
    --80062"[工票商店]"
    local ShopName = RichTextUtil.GetHyperlink(LSTR(80062), 1, "#d1ba8e", nil, nil, nil, nil, nil, false)
    local ItemText = string.format(LSTR(CraftingLogDefine.UnUsedEsotericaText), ShopName)
    local LockItemTable = {}
    if table.is_nil_empty(self.FilterLevelList) then
        return
    end
    if self.LastDropDownIndex == nil then
        self.LastDropDownIndex = 1
    end
    local FilterType = self.FilterLevelList[self.LastDropDownIndex].RecipeType
    local PropDataList = self:GetPropDataByProf()
    for _, v in pairs(PropDataList) do
        if v.RecipeType == FilterType then
            local Category = v.CategoryNum
            -- 如果是筛选的是秘籍且背包中的秘籍未使用过
            if FilterType == RecipeType.RecipeTypeSecret and
                (UnlockVolume == nil or UnlockVolume[Category] == nil) then
                if not LockItemTable[Category] and self:BeIncludedInGameVersion(v.Version) then
                    table.insert(self.ProListWithProf, {
                        ---ID = 1,
                        TextTips = ItemText,
                        Category = v.RecipeLable[3],
                        CategoryItemID = CraftingLogDefine.CategoryItemIDMap[Prof][Category],
                        CategoryNum = v.CategoryNum,
                        Craftjob = Prof
                    })
                    LockItemTable[Category] = true
                end
            else
                if self:BeIncludedInGameVersion(v.Version) then
                    if FilterType == RecipeType.RecipeTypeCollection then
                        if MajorLevel and _G.GatheringLogMgr:GetQuestStatus() and ( MajorLevel//10 + 1) * 10 >= v.RecipeLevel then
                            table.insert(self.ProListWithProf, v)
                        end
                    elseif FilterType == RecipeType.RecipeTypeSecret then
                        if UnlockVolume and UnlockVolume[Category] then
                            table.insert(self.ProListWithProf, v)
                        end
                    end
                end
            end
        end
    end
    table.sort(self.ProListWithProf, self.SortByLevelStar)
end

---收藏筛选
function CraftingLogMgr:IsChoiceWithCollect()
    local FloorLimitLevel, UpperLimitLevel = CraftingLogDefine.NormalFloorLimitLevel,
        CraftingLogDefine.NormalMaxCollectLevel
    local LastDropDownIndex = self.LastDropDownIndex
    if LastDropDownIndex ~= 1 then
        FloorLimitLevel = self.FilterLevelList[LastDropDownIndex].FloorLimitLevel
        UpperLimitLevel = self.FilterLevelList[LastDropDownIndex].UpperLimitLevel
    end
    local CollectListData = self.CollectListData[self.LastChoiceCareer] or {}
    for key, _ in pairs(CollectListData) do
        local RecipeCfgData = self:GetRecipeDataById(key)
        if RecipeCfgData.RecipeLevel <= UpperLimitLevel and RecipeCfgData.RecipeLevel >= FloorLimitLevel then
            table.insert(self.ProListWithProf, RecipeCfgData)
        end
    end
    table.sort(self.ProListWithProf, self.SortByLevelStar)
end

---时间筛选
function CraftingLogMgr:IsChoiceWithTime()
    local LastDropDownIndex = self.LastDropDownIndex
    local FilterData = self.FilterLevelList[LastDropDownIndex]
    if FilterData == nil then
        return
    end
    local NormalDaySecond = CraftingLogDefine.NormalDaySecond
    local FloorAllowTime = NormalDaySecond * FilterData.SectionDay
    local UpAllowTime = NormalDaySecond * FilterData.Days

    local NowTime = TimeUtil.GetServerTime()
    local HistoryList = self.HistoryList[self.LastChoiceCareer] or {}
    local HistorySortList = self:GetNowCareerHistoryList(HistoryList)
    for _, value in pairs(HistorySortList) do
        local TimeLag = NowTime - HistoryList[value]
        if TimeLag <= UpAllowTime and TimeLag >= FloorAllowTime then
            local RecipeCfgData = self:GetRecipeDataById(value)
            table.insert(self.ProListWithProf, RecipeCfgData)
        end
    end
end

function CraftingLogMgr:GetNowCareerHistoryList(HistoryList)
    local DataList = {}
    for key, _ in pairs(HistoryList) do
        table.insert(DataList, key)
    end
    local function cmp(x, y)
        return HistoryList[x] > HistoryList[y]
    end
    table.sort(DataList, cmp)
    if #DataList > self.MaxHistoryCount then
        for i = #DataList, self.MaxHistoryCount + 1 do
            table.remove(DataList, i)
        end
    end
    return DataList
end

---获取配方数据根据职业
function CraftingLogMgr:GetTablePropData()
    self.ProListWithProf = {}
    local NowProfLevel = MajorUtil.GetMajorLevelByProf(self.LastChoiceCareer)
    if self.LastHorTabIndex == FilterALLType.Level then
        self:IsChoiceWithLevel(NowProfLevel)
    elseif self.LastHorTabIndex == FilterALLType.Career then
        self:IsChoiceWithCareer(NowProfLevel)
    elseif self.LastHorTabIndex == FilterALLType.Collect then
        self:IsChoiceWithCollect()
    elseif self.LastHorTabIndex == FilterALLType.Time then
        self:IsChoiceWithTime()
    end
    return self.ProListWithProf
end

---获取配方材料数据
function CraftingLogMgr:GetPropMaterialData(MaterialData, IsRequireHQ)
    if MaterialData == "0" or MaterialData == nil then
        return
    end
    local CompelIndex = CraftingLogDefine.CompelHQ.Compel
    local MaterialNumber = #MaterialData
    for i = 1, MaterialNumber do
        local MaterialItemID = MaterialData[i].ItemID
        MaterialData[i].IsHQ = IsRequireHQ[i] == CompelIndex
        MaterialData[i].ItemID = MaterialItemID
    end
    return MaterialData
end

---获取搜索历史
function CraftingLogMgr:GetSearchHistory()
    return self.SearchHistory
end

---设置搜索历史
---@param Param string 搜索参数
---@param bDelete boolean 是否删除
function CraftingLogMgr:SetSearchHistory(Param, bDelete)
    local SearchHistoryData = self.SearchHistory
    for key, value in pairs(SearchHistoryData) do
        if value.SearchText == Param then
            table.remove(self.SearchHistory, key)
            if bDelete == false then
                table.insert(self.SearchHistory, 1, value)
            end
            return
        end
    end
    table.insert(self.SearchHistory, 1, {
        SearchText = Param
    })
    local SearchHistoryLen = #self.SearchHistory
    if SearchHistoryLen > NormalMaxSearchHistoryCount then
        for index = NormalMaxSearchHistoryCount + 1, SearchHistoryLen do
            table.remove(self.SearchHistory, index)
        end
    end
end

---获取筛选等级数据
function CraftingLogMgr:IsHorIndexChoiceWithLevel()
    local ProfData = self:GetPropDataByProf()
    local MajorLevel = MajorUtil.GetMajorLevelByProf(self.LastChoiceCareer)
    local ProfbLock = self:GetProfIsLock(self.LastChoiceCareer)
    local TabList = {}
    for _, value in pairs(ProfData) do
        local FloorLimitLevel
        -- 5 级别一个档次
        if value.RecipeLevel <= NormalRecipeLevel then
            FloorLimitLevel = CraftingLogDefine.NormalLowestLevel
        else
            FloorLimitLevel = math.floor((value.RecipeLevel / NormalRecipeLevel - 1)) * NormalRecipeLevel + 1
        end
        local UpperLimitLevel = FloorLimitLevel + CraftingLogDefine.NormalLevelIncrement
        local LabelInfo = string.format("%d~%d级", FloorLimitLevel, UpperLimitLevel)
        local Name = string.format("%d~%d%s", FloorLimitLevel, UpperLimitLevel, LSTR(70022)) --70022级
        if TabList[LabelInfo] == nil then
            local bTextGray = ProfbLock or (MajorLevel + 10) <= FloorLimitLevel
            table.insert(self.FilterLevelList, {
                ID = #self.FilterLevelList + 1,
                FloorLimitLevel = FloorLimitLevel,
                UpperLimitLevel = UpperLimitLevel,
                Name = Name,
                RedDotType = CraftingNoteType,
                Prof = self.LastChoiceCareer,
                HorIndex = FilterALLType.Level,
                DropdownIndex = math.ceil(UpperLimitLevel / 5),
                IconPath = bTextGray and GatheringLogDefine.LockIcon or nil,
                ImgIconColorbSameasText = true
            })
            TabList[LabelInfo] = true
        end
    end
    local PropDataList = self:GetPropDataByProf()
    for _, value in pairs(self.FilterLevelList) do
        local FinishNum, TotalNum = self:GetFinishNumTotalNumWithLevel(value, PropDataList)
        local TextStr = string.format("%d/%d", FinishNum, TotalNum)
        value.TextQuantityStr = TextStr
        value.bTextQuantityShow = true
    end
    table.sort(self.FilterLevelList, SortWithFloorlimitlevel)
end

---@type 获取此下拉选项玩家已制作过的配方数量
function CraftingLogMgr:GetFinishNumTotalNumWithLevel(Condition, PropDataList)
    local ProList = {}
    local FloorLimitLevel = Condition.FloorLimitLevel
    local UpperLimitLevel = Condition.UpperLimitLevel
    for _, v in pairs(PropDataList) do
        if self:BeIncludedInGameVersion(v.Version) and v.RecipeType == RecipeType.RecipeTypeRoutine and
            (FloorLimitLevel <= v.RecipeLevel and v.RecipeLevel <= UpperLimitLevel) then
            table.insert(ProList, v)
        end
    end
    local FinishNum = 0
    for _, v in pairs(ProList) do
        if self:GetIsDone(v) == true then
            FinishNum = FinishNum + 1
        end
    end
    return FinishNum, #ProList
end

---@type 获取此下拉选项玩家已制作过的配方数量
function CraftingLogMgr:GetFinishNumTotalNumWithCareer(Condition, PropDataList, MajorLevel, UnlockVolume)
    local ProList = {}
    if Condition.Name == ProtoEnumAlias.GetAlias(RecipeType, RecipeType.RecipeTypeSecret) and UnlockVolume == 0 then
        return 0, 0
    end
    for _, v in pairs(PropDataList) do
        if (v.RecipeType == Condition.RecipeType) and self:BeIncludedInGameVersion(v.Version) then
            if Condition.RecipeType == RecipeType.RecipeTypeCollection then
                if (MajorLevel//10 + 1) * 10 >= v.RecipeLevel then
                    table.insert(ProList, v)
                end
            elseif Condition.RecipeType == RecipeType.RecipeTypeSecret then
                if UnlockVolume and UnlockVolume[v.CategoryNum] then
                    table.insert(ProList, v)
                end
            end
        end
    end
    local FinishNum = 0
    local LockVolume = 0
    for _, v in pairs(ProList) do
        if self:GetIsDone(v) == true then
            FinishNum = FinishNum + 1
        end
        if v.TextTips ~= nil then
            LockVolume = LockVolume + 1
        end
    end
    return FinishNum, #ProList - LockVolume
end

---获取筛选职业数据
function CraftingLogMgr:IsHorIndexChoiceWithCareer()
    local MajorLevel = MajorUtil.GetMajorLevelByProf(self.LastChoiceCareer)
    local ProfData = self:GetPropDataByProf()
    local TabList = {}
    for _, value in pairs(ProfData) do
        local RecipeLable = value.RecipeType
        -- 当玩家处于秘籍可解锁版本之前，不解锁秘籍
        if self:BeIncludedInGameVersion(value.Version) then
            if RecipeLable and TabList[RecipeLable] == nil then
                -- 不是秘籍的根据等级解锁
                if RecipeLable == RecipeType.RecipeTypeSecret or
                    (RecipeLable == RecipeType.RecipeTypeCollection and MajorLevel and
                        _G.GatheringLogMgr:GetQuestStatus() and (MajorLevel//10 + 1) * 10 >= value.RecipeLevel) then
                    local DropdownIndex = nil
                    if RecipeLable == RecipeType.RecipeTypeSecret then
                        DropdownIndex = SpecialType.SpecialTypeSecret
                    elseif RecipeLable == RecipeType.RecipeTypeCollection then
                        DropdownIndex = SpecialType.SpecialTypeCollection
                    end
                    table.insert(self.FilterLevelList, {
                        ID = #self.FilterLevelList + 1,
                        Name = ProtoEnumAlias.GetAlias(RecipeType, RecipeLable),
                        RecipeType = RecipeLable,
                        RedDotType = CraftingNoteType,
                        Prof = self.LastChoiceCareer,
                        HorIndex = FilterALLType.Career,
                        DropdownIndex = DropdownIndex
                    })
                    TabList[RecipeLable] = true
                end
            end
        end
    end
    local PropDataList = self:GetPropDataByProf()
    local MajorLevel = MajorUtil.GetMajorLevelByProf(self.LastChoiceCareer)
    local UnlockVolume = self.UseEsotericaProf[self.LastChoiceCareer]
    for _, value in pairs(self.FilterLevelList) do
        local FinishNum, TotalNum = self:GetFinishNumTotalNumWithCareer(value, PropDataList, MajorLevel, UnlockVolume)
        local TextStr = string.format("%d/%d", FinishNum, TotalNum)
        value.TextQuantityStr = TextStr
        value.bTextQuantityShow = true
    end
end

---@type 指定版本是否被包含于当前游戏版本
---@param VersionName string @指定版本
function CraftingLogMgr:BeIncludedInGameVersion(VersionName)
    if not string.isnilorempty(VersionName) then
        local VersionNum = self.VersionNametoNum[VersionName] or self:VersionNameToNum(VersionName)
        if VersionNum ~= nil and VersionNum <= self.GameVersionNum then
            return true
        end
    end
    return false
end

function CraftingLogMgr:VersionNameToNum(Name)
    local Version = string.split(Name,".")
    local VersionNum = Version[1] * 100 + Version[2] * 10 + Version[3]
    self.VersionNametoNum[Name] = VersionNum
    return VersionNum
end

---获取筛选收藏数据
function CraftingLogMgr:IsHorIndexChoiceWithCollect()
    local FilterData = {}
    local NormalRecipeCollectLevel = CraftingLogDefine.NormalRecipeCollectLevel
    local NormalCollectLevelIncrement = CraftingLogDefine.NormalCollectLevelIncrement
    local CollectListData = self.CollectListData[self.LastChoiceCareer] or {}
    for CollectID, _ in pairs(CollectListData) do
        local bRepeatFlag = false
        local RecipeCfgData = self:GetRecipeDataById(CollectID)
        local FloorLimitLevel, UpperLimitLevel
        if RecipeCfgData.RecipeLevel % NormalRecipeCollectLevel == 0 and RecipeCfgData.RecipeLevel > 0 then
            FloorLimitLevel = RecipeCfgData.RecipeLevel - NormalCollectLevelIncrement
        else
            FloorLimitLevel = math.floor((RecipeCfgData.RecipeLevel / NormalRecipeCollectLevel)) *
                                  NormalRecipeCollectLevel + 1
        end
        for _, value in pairs(FilterData) do
            if value.FloorLimitLevel == FloorLimitLevel then
                bRepeatFlag = true
                break
            end
        end
        if not bRepeatFlag then
            UpperLimitLevel = FloorLimitLevel + NormalCollectLevelIncrement
            table.insert(FilterData, {
                ID = #self.FilterLevelList + 1,
                FloorLimitLevel = FloorLimitLevel,
                UpperLimitLevel = UpperLimitLevel,
                Name = string.format("%d~%d%s", FloorLimitLevel, UpperLimitLevel, LSTR(70022))
            })
        end
    end
    table.sort(FilterData, SortWithFloorlimitlevel)
    self.FilterLevelList = FilterData

    table.insert(FilterData, 1, {
        ID = 1,
        Name = string.format(LSTR(70011)) --全部
    })
    for index, value in pairs(self.FilterLevelList) do
        local TotalNum = self:GetTotalNumWithCollect(value)
        if index == 1 then
            value.TextQuantityStr = string.format("%d/%d", TotalNum, self.MaxCollectCount)
        else
            value.TextQuantityStr = string.format("%d", TotalNum)
        end
        value.bTextQuantityShow = true
    end
    return self.FilterLevelList
end

function CraftingLogMgr:GetTotalNumWithCollect(Condition)
    local ProList = {}
    local FloorLimitLevel = Condition.FloorLimitLevel
    local UpperLimitLevel = Condition.UpperLimitLevel
    local CollectListData = self.CollectListData[self.LastChoiceCareer] or {}
    for key, _ in pairs(CollectListData) do
        local RecipeCfgData = self:GetRecipeDataById(key)
        if (UpperLimitLevel == nil and FloorLimitLevel == nil) or
            (RecipeCfgData.RecipeLevel <= UpperLimitLevel and RecipeCfgData.RecipeLevel >= FloorLimitLevel) then
            table.insert(ProList, RecipeCfgData)
        end
    end
    return #ProList
end

---获取筛选时间数据
function CraftingLogMgr:IsHorIndexChoiceWithTime()
    local FilterLevelList = CraftingLogDefine.SpaceFilterData
    for index, value in pairs(FilterLevelList) do
        local TotalNum = self:GetTotalNumWithTime(value)
        if TotalNum ~= 0 then
            if index == 1 then
                value.TextQuantityStr = string.format("%d/%d", TotalNum, self.MaxHistoryCount)
            else
                value.TextQuantityStr = string.format("%d", TotalNum)
            end
            value.bTextQuantityShow = true
            table.insert(self.FilterLevelList, value)
        end
    end
    return self.FilterLevelList
end

function CraftingLogMgr:GetTotalNumWithTime(FilterData)
    local NormalDaySecond = CraftingLogDefine.NormalDaySecond
    local FloorAllowTime = NormalDaySecond * FilterData.SectionDay
    local UpAllowTime = NormalDaySecond * FilterData.Days

    local NowTime = TimeUtil.GetServerTime()
    local HistoryList = self.HistoryList[self.LastChoiceCareer] or {}
    local HistorySortList = self:GetNowCareerHistoryList(HistoryList)
    local Num = 0
    for _, value in pairs(HistorySortList) do
        local TimeLag = NowTime - HistoryList[value]
        if TimeLag <= UpAllowTime and TimeLag >= FloorAllowTime then
            Num = Num + 1
        end
    end
    return Num
end

---获取筛选下拉数据
---@param HorTabIndex number 横向索引
function CraftingLogMgr:GetDropDownData(HorTabIndex)
    self.FilterLevelList = {}
    if HorTabIndex == FilterALLType.Level then
        self:IsHorIndexChoiceWithLevel()
    elseif HorTabIndex == FilterALLType.Career then
        self:IsHorIndexChoiceWithCareer()
    elseif HorTabIndex == FilterALLType.Collect then
        self:IsHorIndexChoiceWithCollect()
    elseif HorTabIndex == FilterALLType.Time then
        self:IsHorIndexChoiceWithTime()
    end
    return self.FilterLevelList
end
-- endregion

-- region  制作说明
---获取制作说明
---@param ItemData any
function CraftingLogMgr:GetItmeExplainData(ItemData)
    local ExplainList = {}
    local AttrWorkPrecision = _G.UE.UActorUtil.GetActorAttrValue(MajorUtil.GetMajorEntityID(),
        ProtoCommon.attr_type.attr_work_precision)
    local AttrProducePrecision = _G.UE.UActorUtil.GetActorAttrValue(MajorUtil.GetMajorEntityID(),
        ProtoCommon.attr_type.attr_produce_precision)

    local NowPropData = self.NowPropData
    local CraftmanshipNeed
    local ControlNeed
    if NowPropData.CanHQ == 0 then
        CraftmanshipNeed = ItemData.SimpleCraftmanShipNeed
        ControlNeed = ItemData.SimpleCraftControlNeed
    elseif ItemData.FastCraft == 1 then
        --普通制作时也显示快速制作的解锁条件(除收藏品不能快速制作)
        CraftmanshipNeed = ItemData.HQFastCraftmanShipNeed
        ControlNeed = ItemData.HQFastCraftControlNeed
    else
        CraftmanshipNeed = ItemData.CraftmanshipNeed
        ControlNeed = ItemData.ControlNeed
    end
    if CraftmanshipNeed ~= nil and CraftmanshipNeed > 0 then
        local Forbidden = AttrWorkPrecision < CraftmanshipNeed
        table.insert(ExplainList, {
            bForbidden = Forbidden,
            bChecked = not Forbidden,
            TextCondition = string.format(LSTR(80032), math.floor(CraftmanshipNeed)) --作业精度≥%s
        })
    end
    if ControlNeed ~= nil and ControlNeed > 0 then
        local Forbidden = AttrProducePrecision < ControlNeed
        table.insert(ExplainList, {
            bForbidden = Forbidden,
            bChecked = not Forbidden,
            TextCondition = string.format(LSTR(80033), math.floor(ControlNeed)) --加工精度≥%s
        })
    end
    if NowPropData.CanHQ == 1 and NowPropData.FastCraft == 1 then
        local IsDone = self:GetIsDone(NowPropData)
        table.insert(ExplainList, {
            bForbidden = not IsDone,
            bChecked = IsDone,
            TextCondition = LSTR(80066) --完成首次制作
        })
    end
    return self:GetItmeCommonExplainData(ExplainList)
end
-- endregion  制作说明
function CraftingLogMgr:ConvertTo1Percent(Number)
    return math.floor((Number * 100) + 0.5) * 0.01
end

---获取制作说明
function CraftingLogMgr:GetItmeCommonExplainData(ExplainList)
    if self.NowPropData == nil then
        return
    end
    if self.NowPropData.BatchNum == 0 then
        table.insert(ExplainList, {
            bForbidden = false,
            bChecked = false,
            TextCondition = LSTR(80035) --无法批量制作
        })
    end
    if self.NowPropData.RecipeDifficulty == CraftingLogDefine.ExplainType.Grandmini then -- 特殊
        -- 高难度配方
        table.insert(ExplainList, {
            bForbidden = false,
            bChecked = false,
            ExplainType = CraftingLogDefine.SpecialExplainType.Difficulty,
            TextCondition = LSTR(80037) --高难度配方
        })
    end
    if self.NowPropData.RecipeType == RecipeType.RecipeTypeCollection then
        table.insert(ExplainList, {
            bForbidden = false,
            bChecked = false,
            ExplainType = CraftingLogDefine.SpecialExplainType.Collection,
            TextCondition = LSTR(80038) --收藏品配方
        })
    end
    return ExplainList
end

-- endregion

---职业变更
function CraftingLogMgr:VerTabsChanged(CareerIndex)
    self:RecordCareerData()
    self:SetLastChoiceCareer(CareerIndex)
end

---面板关闭，数据处理
function CraftingLogMgr:ViewHide()
    self:RecordCareerData()
    self.bCanRecord = false
    self.CraftingState = CraftingLogState.Picking
    self.NowSearchPropData = nil
end

function CraftingLogMgr:SaveFastSearchInfo()
    if self.CraftingState == CraftingLogState.Searching then
        self.OnShowSearchInfo = self.SearchInfo
    end
end

---快捷入口
---@param ItemID number
function CraftingLogMgr:OpenCraftingLogWithItemID(ItemID)
    if ItemID == nil then
        _G.FLOG_INFO("CraftingLogMgr:OpenCraftingLogWithItemID ItemID is nil")
        return
    end
    _G.FLOG_INFO("CraftingLogMgr:OpenCraftingLogWithItemID ItemID = %d", ItemID)
    self.FastSearchInfo = ""
    local RecipeCfgData = CraftingLogMgr:GetRecipeDataByProductID(ItemID)
    if RecipeCfgData ~= nil then
        self.FastSearchInfo = RecipeCfgData.Name
    else
        local ItemCfgData = ItemCfg:FindCfgByKey(ItemID)
        if ItemCfgData ~= nil then
            self.FastSearchInfo = ItemCfg:GetItemName(ItemID)
        else
            _G.FLOG_INFO("CraftingLogMgr:OpenCraftingLogWithItemID ItemCfgData is nil")
        end
    end

    if self.FastSearchInfo ~= "" then
        if not _G.UIViewMgr:IsViewVisible(_G.UIViewID.CraftingLog) then
            UIViewMgr:ShowView(_G.UIViewID.CraftingLog)
        end
        
        -- 快捷跳转前 关闭Tips界面 避免界面错乱
        _G.UIViewMgr:HideView(_G.UIViewID.ItemTips)
        _G.UIViewMgr:HideView(_G.UIViewID.CraftingLogShopWin)
        
        self.CraftingState = CraftingLogState.MaterialsSeaarch
            _G.EventMgr:SendEvent(_G.EventID.CraftingLogFastSearch, self.FastSearchInfo)
    end
end

--region ==================================红点 Begin===========================================
---@type 请求下拉或新增列表DropFilterList中新字的数据
---@param Index number @0表示查询，其余表示新增
function CraftingLogMgr:SendMsgUpdateDropNewData(Prof, Index, SpecialType, ReadVersion, IsRead, Volume)
    local appear = {}
    appear.Index = Index or 0
    appear.NoteType = CraftingNoteType
    appear.ProfID = Prof or self.LastChoiceCareer
    if SpecialType ~= 0 and SpecialType ~= nil then
        local SpecialData = {}
        SpecialData.SpecialType = SpecialType
        SpecialData.IsRead = IsRead
        SpecialData.ReadVersion = ReadVersion or 0
        SpecialData.Volume = Volume
        appear.SpecialData = SpecialData
    end

    -- local MsgID = CS_CMD.CS_CMD_NOTE
    -- local SubMsgID = SUB_MSG_ID.CS_CMD_COLLECTION_APPEAR
    -- local MsgBody = {}
    -- MsgBody.Cmd = SubMsgID
    -- MsgBody.appear = appear
    -- GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 移除下拉列表DropFilterList中新字
function CraftingLogMgr:SendMsgRemoveDropNewData(Prof, Index, SpecialType, ReadVersion, IsRead, Volume)
    local appear = {}
    appear.Index = Index or 0
    appear.NoteType = CraftingNoteType
    appear.ProfID = Prof or self.LastChoiceCareer
    if SpecialType ~= 0 and SpecialType ~= nil then
        local SpecialData = {}
        SpecialData.SpecialType = SpecialType
        SpecialData.IsRead = IsRead
        SpecialData.ReadVersion = ReadVersion or 0
        SpecialData.Volume = Volume or 0
        appear.SpecialData = SpecialData
    end

    -- local MsgID = CS_CMD.CS_CMD_NOTE
    -- local SubMsgID = SUB_MSG_ID.CS_CMD_COLLECTION_REMOVE_APPEAR
    -- local MsgBody = {}
    -- MsgBody.Cmd = SubMsgID
    -- MsgBody.removeAppear = appear
    -- GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 获取或更新制作笔记获得下拉列表的红点
function CraftingLogMgr:OnNetMsgAddRedDot(MsgBody)
    if nil == MsgBody or nil == MsgBody.appear or nil == MsgBody.appear.NoteAppear then
        return
    end
    local AllNoteAppear = MsgBody.appear.NoteAppear
    if #AllNoteAppear == 0 then
        return
    end

    for _, NoteAppear in pairs(AllNoteAppear) do
        if NoteAppear.NoteType ~= CraftingNoteType then
            break
        end
        local ProfID = NoteAppear.ProfID

        -- 普通页签
        if self.NormalDropRedDotLists == nil then
            self.NormalDropRedDotLists = {}
        end
        self.NormalDropRedDotLists[ProfID] = NoteAppear.IndexList
        self:NormalRedDotDataUpdate(ProfID)
        for _, value in pairs(NoteAppear.IndexList) do
            if value == 100 then
                if self.SpecialDropRedDotLists == nil then
                    self.SpecialDropRedDotLists = {}
                end
                if self.SpecialDropRedDotLists[ProfID] == nil then
                    self.SpecialDropRedDotLists[ProfID] = {}
                end
                self.SpecialDropRedDotLists[ProfID][3] = { ReadVersion=0, Volume=0, IsRead=false, SpecialType=3 }
                self:SpecialRedDotDataUpdate(ProfID)
                break
            end
        end

        -- 特殊页签
        local SpecialData = NoteAppear.SpecialData
        if not table.is_nil_empty(SpecialData) then
            if self.SpecialDropRedDotLists == nil then
                self.SpecialDropRedDotLists = {}
            end
            if self.SpecialDropRedDotLists[ProfID] == nil then
                self.SpecialDropRedDotLists[ProfID] = {}
            end
            for _, value in pairs(SpecialData) do
                local Type = value.SpecialType
                if Type ~= 0 then
                    self.SpecialDropRedDotLists[ProfID][Type] = value
                end
            end
            self:SpecialRedDotDataUpdate(ProfID)
        end
    end

    -- （界面先打开，红点树才加上）更新界面红点
    local function SendUpdateTabRedDot()
        _G.EventMgr:SendEvent(EventID.UpdateTabRedDot)
         if self.LastHorTabIndex == FilterALLType.Career and self.CraftingState == CraftingLogState.Picking then
            _G.EventMgr:SendEvent(EventID.CraftingLogUpdateHorTabs, FilterALLType.Career)
         end
        self.UpdateTabRedDotTimer = nil
    end
    if self.UpdateTabRedDotTimer == nil then
        self.UpdateTabRedDotTimer = self:RegisterTimer(SendUpdateTabRedDot, 0.2, 1, 1)
    end
end

function CraftingLogMgr:GetSpecialReadData(Prof, SpecialType)
    local DropRedDotLists = self.SpecialDropRedDotLists[Prof]
    if DropRedDotLists then
        for _, value in pairs(DropRedDotLists) do
            if value.SpecialType == SpecialType then
                return value
            end
        end
    end
end

---@type 红点系统增删调用普通页签
function CraftingLogMgr:NormalRedDotDataUpdate(Prof, IsRemove)
    local HorIndex = FilterALLType.Level
    local DropRedDotLists = self.NormalDropRedDotLists[Prof]
    local bShowHorIndexRedDot = #DropRedDotLists > 0

    -- 弱红点提醒
    local ProfRedDotName = self:GetRedDotName(Prof, nil, nil, CraftingLogDefine.RedDotID.CraftingLogProf)
    local HorIndexRedDotName = self:GetRedDotName(Prof, HorIndex, nil, CraftingLogDefine.RedDotID.CraftingLogProf)
    if bShowHorIndexRedDot and not IsRemove then --- 新增
        if not HorIndexRedDotName then
            -- 左侧职业列表的红点
            if not ProfRedDotName then
                ProfRedDotName = RedDotMgr:AddRedDotByParentRedDotID(CraftingLogDefine.RedDotID.CraftingLogProf)
                local ProfRedNode = RedDotMgr:FindRedDotNodeByName(ProfRedDotName)
                if ProfRedNode then
                    ProfRedNode.ProfID = Prof
                    ProfRedNode.SubRedDotList = {}
                end
            end

            -- 上方普通页签的红点
            HorIndexRedDotName = RedDotMgr:AddRedDotByParentRedDotName(ProfRedDotName)
            local HorIndexRedNode = RedDotMgr:FindRedDotNodeByName(HorIndexRedDotName)
            if HorIndexRedNode then
                HorIndexRedNode.HorIndex = HorIndex
                HorIndexRedNode.SubRedDotList = {}
            end
        end

        -- 下拉框列表的红点
        for _, DropDownIndex in pairs(DropRedDotLists) do
            local RedDotName = self:GetRedDotName(Prof, HorIndex, DropDownIndex,
                CraftingLogDefine.RedDotID.CraftingLogProf)
            if not RedDotName then
                RedDotName = string.format("%s/%s级", HorIndexRedDotName, DropDownIndex)
                RedDotMgr:AddRedDotByName(RedDotName)
                local RedNode = RedDotMgr:FindRedDotNodeByName(RedDotName)
                if RedNode then
                    RedNode.DropDownIndex = DropDownIndex
                end
            end
        end
    end

    ---删除
    if not bShowHorIndexRedDot and HorIndexRedDotName then
        local IsDel = RedDotMgr:DelRedDotByName(HorIndexRedDotName)
        if IsDel then
            local TheOtherRedDotName = self:GetRedDotName(Prof, FilterALLType.Career, nil,
                CraftingLogDefine.RedDotID.CraftingLogProf)
            if not TheOtherRedDotName then
                RedDotMgr:DelRedDotByName(ProfRedDotName)
            end
        end
    end
end

---@type 红点系统增删调用特殊页签
function CraftingLogMgr:SpecialRedDotDataUpdate(Prof)
    local HorIndex = FilterALLType.Career
    local DropRedDotLists = self.SpecialDropRedDotLists[Prof]
    local SpecialAddRedDots = {}

    -- 强红点提醒（下拉框为叶子节点）
    if DropRedDotLists then
        local IsAllRead = true
        local RedDotID = CraftingLogDefine.RedDotID.CraftingLog
        local ProfRedDotNameStrong = self:GetRedDotName(Prof, nil, nil, RedDotID)
        for _, value in pairs(DropRedDotLists) do
            if value.SpecialType ~= 0 then
                if value.IsRead == false then
                    IsAllRead = false
                    -- 左侧职业列表的红点
                    if not ProfRedDotNameStrong then
                        ProfRedDotNameStrong = RedDotMgr:AddRedDotByParentRedDotID(RedDotID)
                        local ProfRedNodeStrong = RedDotMgr:FindRedDotNodeByName(ProfRedDotNameStrong)
                        ProfRedNodeStrong.ProfID = Prof
                        ProfRedNodeStrong.IsStrongReminder = true
                        ProfRedNodeStrong.SubRedDotList = {}
                    end

                    -- 上方普通页签的红点
                    local HorIndexRedDotName = self:GetRedDotName(Prof, HorIndex, nil, RedDotID)
                    if HorIndexRedDotName == nil then
                        HorIndexRedDotName = RedDotMgr:AddRedDotByParentRedDotName(ProfRedDotNameStrong)
                        local HorIndexRedNode = RedDotMgr:FindRedDotNodeByName(HorIndexRedDotName)
                        HorIndexRedNode.HorIndex = HorIndex
                        HorIndexRedNode.IsStrongReminder = true
                        HorIndexRedNode.SubRedDotList = {}
                    end

                    -- 下拉框列表的红点
                    local RedDotName = RedDotMgr:AddRedDotByParentRedDotName(HorIndexRedDotName)
                    local RedNode = RedDotMgr:FindRedDotNodeByName(RedDotName)
                    RedNode.DropDownIndex = value.SpecialType
                    RedNode.IsStrongReminder = true
                end

                -- 检测弱红点是否提醒
                if value.SpecialType == SpecialType.SpecialTypeSecret and self.UseEsotericaProf[Prof] ~= nil then
                    if value.ReadVersion == 0 or value.ReadVersion < self.GameVersionNum or
                        (value.ReadVersion == self.GameVersionNum and
                            self:IsHaveUnReadEsotericaVolume(Prof, value.Volume)) then
                        SpecialAddRedDots[SpecialType.SpecialTypeSecret] = true
                    end
                elseif value.SpecialType == SpecialType.SpecialTypeCollection and value.IsRead == true then
                    --and value.ReadVersion <RoundFive(MajorUtil.GetMajorLevelByProf(Prof))
                    SpecialAddRedDots[SpecialType.SpecialTypeCollection] = true
                end
            end
        end

        ---强红点删除
        if IsAllRead then
            local HorIndexRedDotName = self:GetRedDotName(Prof, HorIndex, nil, RedDotID)
            if HorIndexRedDotName then
                local IsDel = RedDotMgr:DelRedDotByName(HorIndexRedDotName)
                if IsDel and ProfRedDotNameStrong then
                    RedDotMgr:DelRedDotByName(ProfRedDotNameStrong)
                    local RedNodeStrong = RedDotMgr:FindRedDotNodeByID(RedDotID)
                    if RedNodeStrong and table.is_nil_empty(RedNodeStrong.SubRedDotList) then
                        RedDotMgr:DelRedDotByID(RedDotID)
                    end
                end
            end
        end
    end

    -- 弱红点提醒
    local ProfRedDotName = self:GetRedDotName(Prof, nil, nil, CraftingLogDefine.RedDotID.CraftingLogProf)
    local HorIndexRedDotName = self:GetRedDotName(Prof, HorIndex, nil, CraftingLogDefine.RedDotID.CraftingLogProf)
    if not table.is_nil_empty(SpecialAddRedDots) then --- 新增
        if not HorIndexRedDotName then
            -- 左侧职业列表的红点
            if not ProfRedDotName then
                ProfRedDotName = RedDotMgr:AddRedDotByParentRedDotID(CraftingLogDefine.RedDotID.CraftingLogProf)
                local ProfRedNode = RedDotMgr:FindRedDotNodeByName(ProfRedDotName)
                if ProfRedNode then
                    ProfRedNode.ProfID = Prof
                    ProfRedNode.SubRedDotList = {}
                end
            end

            -- 上方普通页签的红点
            HorIndexRedDotName = RedDotMgr:AddRedDotByParentRedDotName(ProfRedDotName)
            local HorIndexRedNode = RedDotMgr:FindRedDotNodeByName(HorIndexRedDotName)
            if HorIndexRedNode then
                HorIndexRedNode.HorIndex = HorIndex
                HorIndexRedNode.SubRedDotList = {}
            end
        end

        -- 下拉框列表的红点
        for _, DropDownIndex in pairs(DropRedDotLists) do
            if SpecialAddRedDots[DropDownIndex.SpecialType] then
                local RedDotName = self:GetRedDotName(Prof, HorIndex, DropDownIndex.SpecialType,
                    CraftingLogDefine.RedDotID.CraftingLogProf)
                if not RedDotName then
                    RedDotName = RedDotMgr:AddRedDotByParentRedDotName(HorIndexRedDotName)
                    local RedNode = RedDotMgr:FindRedDotNodeByName(RedDotName)
                    if RedNode then
                        RedNode.DropDownIndex = DropDownIndex.SpecialType
                    end
                end
            end
        end
    end

    ---弱红点删除
    if HorIndexRedDotName and table.is_nil_empty(SpecialAddRedDots) then
        local IsDel = RedDotMgr:DelRedDotByName(HorIndexRedDotName)
        if IsDel then
            local TheOtherRedDotName = self:GetRedDotName(Prof, FilterALLType.Level, nil,
                CraftingLogDefine.RedDotID.CraftingLogProf)
            if not TheOtherRedDotName then
                RedDotMgr:DelRedDotByName(ProfRedDotName)
            end
        end
    end
end

-- 是否有未读的秘籍卷
function CraftingLogMgr:IsHaveUnReadEsotericaVolume(Prof, Volume)
    local UseEsoterica = self.UseEsotericaProf and self.UseEsotericaProf[Prof]
    if table.is_nil_empty(UseEsoterica) then
        return false
    end
    for index, _ in pairs(UseEsoterica) do
        if (Volume >> (index)) & 1 == 1 then
            return true
        end
    end
    return false
end

---@type 红点名获取（没有就是无红点）
---@param Prof 左侧职业列表
---@param HorIndex 上方四种页签_0表示总数
function CraftingLogMgr:GetRedDotName(Prof, HorIndex, DropDownIndex, RedDotID)
    if Prof == nil then
        Prof = self.LastChoiceCareer or self:GetChoiceProfID()
        if Prof == nil then
            return
        end
    end

    local RedNode = nil
    local RedNodeList = nil
    local ProfRedDotName = nil

    -- 获取所有职业总红点
    if RedDotID == nil then
        RedDotID = CraftingLogDefine.RedDotID.CraftingLogProf
        if HorIndex == nil or HorIndex == FilterALLType.Career then
            RedNode = RedDotMgr:FindRedDotNodeByID(CraftingLogDefine.RedDotID.CraftingLog)
            if RedNode then
                RedNodeList = RedNode.SubRedDotList
                if RedNodeList ~= nil then
                    for _, value in pairs(RedNodeList) do
                        if value.ProfID == Prof then
                            ProfRedDotName = value.RedDotName
                            RedDotID = CraftingLogDefine.RedDotID.CraftingLog
                            break
                        end
                    end
                end
            end
        end
    end

    if not ProfRedDotName then
        RedNode = RedDotMgr:FindRedDotNodeByID(RedDotID)
        if not RedNode then
            return nil
        end
        -- 获取该职业的红点名 及红点
        RedNodeList = RedNode.SubRedDotList
        if RedNodeList == nil then
            return
        end
        for _, value in pairs(RedNodeList) do
            if value.ProfID == Prof then
                ProfRedDotName = value.RedDotName
                break
            end
        end
        if not ProfRedDotName then
            return nil
        end
    end

    if HorIndex == nil then
        return ProfRedDotName
    end
    local ProfRedNode = RedDotMgr:FindRedDotNodeByName(ProfRedDotName)
    if not ProfRedNode then
        return nil
    end

    if HorIndex == 0 then
        HorIndex = self.LastFilterState.HorTabsIndex or 1
    end
    -- 获取该页签的红点名 及红点
    local HorRedDotList = ProfRedNode.SubRedDotList
    if HorRedDotList == nil then
        return nil
    end
    local HorRedDotNode = nil
    for _, value in pairs(HorRedDotList) do
        if value.HorIndex == HorIndex then
            HorRedDotNode = value
        end
    end
    if HorRedDotNode == nil then
        return nil
    end
    if DropDownIndex == nil then
        return HorRedDotNode.RedDotName
    elseif DropDownIndex == 0 then
        return nil
    end

    ----获取该下拉选项的红点名
    local DropDownRedDotList = HorRedDotNode.SubRedDotList
    if DropDownRedDotList == nil then
        return nil
    end
    for _, value in pairs(DropDownRedDotList) do
        if HorIndex == FilterALLType.Level and value.DropDownIndex == DropDownIndex then
            return value.RedDotName
        end
        if HorIndex == FilterALLType.Career and value.DropDownIndex == DropDownIndex then
            return value.RedDotName
        end
    end

    if HorIndex == FilterALLType.Career and RedDotID == CraftingLogDefine.RedDotID.CraftingLog then
        return self:GetRedDotName(Prof, HorIndex, DropDownIndex, CraftingLogDefine.RedDotID.CraftingLogProf)
    end
end

---@type 红点强弱类型获取（没有就是无红点）
function CraftingLogMgr:GetRedDotIsStrongReminder(RedDotName)
    local RedNode = RedDotMgr:FindRedDotNodeByName(RedDotName)
    if RedNode and RedNode.IsStrongReminder == true then
        return true
    end
    return false
end

---@type 当激活时
function CraftingLogMgr:MajorProfActivate(Params)
    local ProfID = Params.ActiveProf.ProfID
    if not ProfUtil.IsCrafterProf(ProfID) then
        return
    end
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMakerNote) then
        local OwnCareerList = self:GetOwnCareerData()
        if #OwnCareerList == 0 or (#OwnCareerList == 1 and OwnCareerList[1].Prof == ProfID) then
            -- 就代表是刚解锁笔记
            return
        end
        local ProfName = ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, ProfID)
        local function ShowNoteTip()
            FLOG_INFO(string.format("制作笔记中追加了%s的书页", ProfName))
            MsgTipsUtil.ShowTips(string.format(LSTR(80039), ProfName)) --制作笔记中追加了%s的书页
        end
        self:RegisterTimer(ShowNoteTip, 1.5, 1, 1)
    end
end

---@type 当升级时新增普通页签下拉选项红点
function CraftingLogMgr:OnMajorLevelUpdate(Params)
    local prof = Params.RoleDetail.Simple.Prof
    if not MajorUtil.IsCrafterProf() then
        return
    end
    local Level = Params.RoleDetail.Simple.Level
    local OldLevel = Params.OldLevel
    if OldLevel == nil then
        if Level == 1 then
            OldLevel = 0
        else
            return
        end
    end
    Level = RoundFive(Level)
    --制作笔记可预览功能单，暂时屏蔽等级段红点
    -- local ProfData = self:GetPropDataByProf(prof)
    -- for _, value in pairs(ProfData) do
    --     if value.RecipeLevel <= Level then
    --         local FloorLimitLevel
    --         if value.RecipeLevel <= NormalRecipeLevel then
    --             FloorLimitLevel = CraftingLogDefine.NormalLowestLevel
    --         else
    --             FloorLimitLevel = math.floor((value.RecipeLevel / NormalRecipeLevel - 1)) * NormalRecipeLevel + 1
    --         end
    --         local UpperLimitLevel = FloorLimitLevel + CraftingLogDefine.NormalLevelIncrement
    --         local Index = math.ceil(UpperLimitLevel / 5)
    --         if not self.AddNewIndex or not self.AddNewIndex[prof] or not self.AddNewIndex[prof][Index] then
    --             if OldLevel <= FloorLimitLevel and Level >= FloorLimitLevel then
    --                 self:SendMsgUpdateDropNewData(prof, Index)
    --                 if not self.AddNewIndex[prof] then
    --                     self.AddNewIndex[prof] = {}
    --                 end
    --                 self.AddNewIndex[prof][Index] = true -- 表示已经发过新增了
    --             end
    --         end
    --     end
    -- end

    -- 当收藏品解锁时新增特殊页签下拉选项红点（收藏品的解锁暂时用等级解锁）
    if _G.GatheringLogMgr:GetQuestStatus() and Level >= CraftingLogDefine.CollectionUnLockLevel and
        OldLevel < CraftingLogDefine.CollectionUnLockLevel then
        --self:SendMsgUpdateDropNewData(prof, nil, SpecialType.SpecialTypeCollection, nil, false, 1)
        self:SendMsgUpdateDropNewData(prof, 100)
    end
end

--- 在完成一流工匠的新工作后解锁收藏品交易列表
function CraftingLogMgr:OnUpdateQuest()
    local ProfList = self:GetOwnCareerData()
    if not table.is_nil_empty(ProfList) then
        for _, ProfData in pairs(ProfList) do
            if MajorUtil.GetMajorLevelByProf(ProfData.Prof) >= CraftingLogDefine.CollectionUnLockLevel then
                --self:SendMsgUpdateDropNewData(ProfData.Prof, nil, SpecialType.SpecialTypeCollection, nil, false)
                self:SendMsgUpdateDropNewData(ProfData.Prof, 100)
            end
        end
    end
end

---@type 当版本更新_传承录解锁时新增特殊页签下拉选项红点 --2.ToDo：如果后来才解锁的职业，也要添加红点(调用此方法)
function CraftingLogMgr:UpdateEsotericaRedDot()
    local OwnCareerList = self:GetOwnCareerData()
    if table.is_nil_empty(OwnCareerList) then
        return
    end
    for _, Value in pairs(OwnCareerList) do
        local IsUnLock = self:IsUnLockEsotericaByVersion(Value.Prof) -- Check更新后的版本是否可解锁传承录
        if not IsUnLock then
            break
        end
        local SpecialDropRedDotList = self.SpecialDropRedDotLists[Value.Prof]
        local IsRead = nil -- 从服务器拉取的传承录是否已读
        local EsotericaReadVer = 0 -- 从服务器拉取的传承录已读版本
        local ReadVolume = 0
        if not table.is_nil_empty(SpecialDropRedDotList) then
            for _, value in pairs(SpecialDropRedDotList) do
                if value.SpecialType == SpecialType.SpecialTypeSecret then
                    IsRead = value.IsRead
                    EsotericaReadVer = value.ReadVersion
                    ReadVolume = value.Volume
                end
            end
        end

        -- 如果未读过,按职业添加强红点,,,向服务器新增，回包加到红点树，并且在服务器记录已读版本
        if IsRead == nil then
            self:SendMsgUpdateDropNewData(Value.Prof, nil, SpecialType.SpecialTypeSecret, nil, false)
        end

        -- 游戏过程中使用过了之后更新一下，（在红点协议拉取后就更新了）
        if self.UseEsotericaProf[Value.Prof] ~= nil then
            -- 且已读版本小于本地版本，按职业添加弱红点红点,,,在本地显示就行了，与服务器的交互就是EsotericaReadVer的值           
            if EsotericaReadVer == 0 or EsotericaReadVer < self.GameVersionNum then
                self:SpecialRedDotDataUpdate(Value.Prof)
            end
        end
    end
end

---@type 检查当前游戏版本是否可解锁传承录
function CraftingLogMgr:IsUnLockEsotericaByVersion(ProfID)
    if self.IsUnLockEsotericaByVersion then
        return true
    end
    local ItemData = self:GetPropDataByProf(ProfID)
    for _, value in pairs(ItemData) do
        -- 看看版本之内有没有GatheringLabel为秘籍的
        if self:BeIncludedInGameVersion(value.Version) and value.RecipeType == RecipeType.RecipeTypeSecret then
            self.IsUnLockEsotericaByVersion = true
            return true
        end
    end
    return false
end

---@type 当关闭界面时点过的下拉框选项的红点移除
function CraftingLogMgr:DelRedDotsOnHide()
    if self.CancelNormalDropRedDotLists ~= nil then
        for Prof, CancelNormalDropRedDotList in pairs(self.CancelNormalDropRedDotLists) do
            local NormalDropRedDotLists = self.NormalDropRedDotLists[Prof]
            if NormalDropRedDotLists then
                for _, DropdownIndex in pairs(NormalDropRedDotLists) do
                    if CancelNormalDropRedDotList[DropdownIndex] then
                        local RedDotName = self:GetRedDotName(Prof, FilterALLType.Level, DropdownIndex)
                        if RedDotName then
                            _G.RedDotMgr:DelRedDotByName(RedDotName)
                            self:SendMsgRemoveDropNewData(Prof, DropdownIndex)
                        end
                    end
                end
            end
        end
    end
    self.CancelNormalDropRedDotLists = {}
    if self.CancelSpecialDropRedDotLists ~= nil then
        for Prof, CancelSpecialDropRedDotList in pairs(self.CancelSpecialDropRedDotLists) do
            local SpecialDropRedDotLists = self.SpecialDropRedDotLists[Prof]
            if SpecialDropRedDotLists then
                for _, DropdownIndex in pairs(SpecialDropRedDotLists) do
                    if DropdownIndex.SpecialType ~= 0 and CancelSpecialDropRedDotList[DropdownIndex.SpecialType] then
                        local RedDotName = self:GetRedDotName(Prof, FilterALLType.Career, DropdownIndex.SpecialType)
                        if RedDotName then
                            local isDel = _G.RedDotMgr:DelRedDotByName(RedDotName)
                            if isDel then
                                local ReadVersion = nil
                                local Volume = 0
                                if DropdownIndex.SpecialType == SpecialType.SpecialTypeCollection then
                                    ReadVersion = RoundFive(MajorUtil.GetMajorLevelByProf(Prof))
                                    --self:SendMsgRemoveDropNewData(Prof, nil, DropdownIndex.SpecialType, ReadVersion, true)
                                    self:SendMsgRemoveDropNewData(Prof, 100)
                                    self.SpecialDropRedDotLists[Prof][3] = nil
                                    self:SpecialRedDotDataUpdate(Prof)

                                else
                                    ReadVersion = CraftingLogMgr.GameVersionNum
                                    if CraftingLogMgr.UseEsotericaProf[Prof][1] then
                                        -- Volume = Volume|(1<<1)
                                        self:SendMsgRemoveDropNewData(Prof, nil, DropdownIndex.SpecialType, ReadVersion,
                                            true, 1)
                                    end
                                    if CraftingLogMgr.UseEsotericaProf[Prof][2] then
                                        -- Volume = Volume|(1<<2)
                                        self:SendMsgRemoveDropNewData(Prof, nil, DropdownIndex.SpecialType, ReadVersion,
                                            true, 2)
                                    end
                                end
                                -- self:SendMsgRemoveDropNewData(Prof, nil, DropdownIndex.SpecialType, ReadVersion, true, Volume)
                            end
                        end
                    end
                end
            end
        end
    end
    self.CancelSpecialDropRedDotLists = {}
end

---@type 移除采集笔记获得下拉列表的红点
function CraftingLogMgr:OnNetMsgRemoveRedDot(MsgBody)
    if nil == MsgBody or nil == MsgBody.removeAppear or nil == MsgBody.removeAppear.NoteAppear then
        return
    end
    local AllNoteAppear = MsgBody.removeAppear.NoteAppear
    if #AllNoteAppear == 0 then
        return
    end

    for _, NoteAppear in pairs(AllNoteAppear) do
        if NoteAppear.NoteType ~= CraftingNoteType then
            break
        end
        local ProfID = NoteAppear.ProfID

        --普通页签
        self.NormalDropRedDotLists[ProfID] = NoteAppear.IndexList
        self:NormalRedDotDataUpdate(ProfID, true)

        --特殊页签
        local SpecialData = NoteAppear.SpecialData
        if not table.is_nil_empty(SpecialData) and self.SpecialDropRedDotLists[ProfID] ~= nil then
            for _, value in pairs(SpecialData) do
                local Type = value.SpecialType
                if Type ~= 0 then
                    self.SpecialDropRedDotLists[ProfID][Type] = value
                end
            end
            self:SpecialRedDotDataUpdate(ProfID)
            _G.EventMgr:SendEvent(EventID.UpdateTabRedDot)
        end
    end
end
--endregion==================================红点 End===========================================

return CraftingLogMgr
