---
--- Author: daniel
--- DateTime: 2023-03-09 16:15
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local GroupLevelCfg = require("TableCfg/GroupLevelCfg")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local LSTR = _G.LSTR

local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local ArmyInfoTrendsVM = require("Game/Army/VM/ArmyInfoTrendsVM")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyTextColor = ArmyDefine.ArmyTextColor
local MainLogsCount = ArmyDefine.MainLogsCount
local DefineCategorys = ArmyDefine.DefineCategorys
local GlobalCfgType = ArmyDefine.GlobalCfgType
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local GroupPermissionType = ProtoRes.GroupPermissionType
local GroupRecruitStatus = ProtoCS.GroupRecruitStatus
local GroupLogType = ProtoCS.GroupLogType
local ArmyMgr = require("Game/Army/ArmyMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local GroupStoreIconCfg = require("TableCfg/GroupStoreIconCfg")
local ArmyShowInfoVM = require("Game/Army/VM/ArmyShowInfoVM")
local UIBindableList = require("UI/UIBindableList")
--local ArmyPrivilegeListItemVM = require("Game/Army/ItemVM/ArmyPrivilegeListItemVM")
local ArmySpecialEffectsItemVM = require("Game/Army/ItemVM/ArmySpecialEffectsItemVM") 
local ArmyInfoTrendsItemVM = require("Game/Army/ItemVM/ArmyInfoTrendsItemVM") 
local GroupUplevelpermissionCfg = require("TableCfg/GroupUplevelpermissionCfg")
local GroupStoreUitextCfg = require("TableCfg/GroupStoreUitextCfg")
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")
local GroupLogCfg = require("TableCfg/GroupLogCfg")
local GroupBonusStateDataCfg = require("TableCfg/GroupBonusStateDataCfg")
local GroupBonusStateCfg = require("TableCfg/GroupBonusStateCfg")
local TimeUtil = require("Utils/TimeUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")

---@class ArmyInfoPageVM : UIViewModel
---@field Notice string @公告
---@field NewsTime3 string @动态3发布时间
---@field USmailIcon string @联盟IconPath
---@field bPanel1 boolean @动态1显示
---@field bPanel2 boolean @动态2显示
---@field bPanel3 boolean @动态3显示
---@field RecruitTips string @招募提示
---@field RecruitSloganTip string @招募标语
---@field ArmyLevel number @部队等级
---@field ArmyName string @部队名称
---@field ArmyShortName string @部队简称
---@field CaptainName string @部队长名称
---@field ArmyID number @部队ID
---@field MemberNum string @成员数量(现有/该级容量)
---@field GainNum string @部队战绩
---@field bNoticeEnable boolean @是否激活公告编辑
---@field bRecruitEnable boolean @是否激活招募编辑
---@field bEditNameEnable boolean @是否激活名称编辑
---@field UnionBgIcon string @联盟背景图
---@field BadgeData GroupEmblem @队徽数据
local ArmyInfoPageVM = LuaClass(UIViewModel)

---Ctor
function ArmyInfoPageVM:Ctor()
    self.Notice = nil
    self.NewsTime1 = nil
    self.NewsTime2 = nil
    self.USmailIcon = nil
    self.NewsTime3 = nil
    self.bPanel1 = nil
    self.bPanel2 = nil
    self.bPanel3 = nil
    self.RecruitTips = nil
    self.RecruitSloganTip = nil
    self.ArmyLevel = nil
    self.ArmyName = nil
    self.ArmyShortName = nil
    self.CaptainName = nil
    self.ArmyID = nil
    self.MemberNum = nil
    self.GainNum = nil
    self.bNoticeEnable = nil
    self.bRecruitEnable = nil
    self.bEditNameEnable = nil
    self.UnionBgIcon = nil
    self.BadgeData = nil
    self.bTopLogShow = nil
    self.NewsTime = nil
    self.NewsContent = nil
    self.ArmyShowInfoVM = nil
    self.LeaderRoleID = nil
    --self.PrivilegeList = nil
    self.GainExpWay = nil
    self.ExpText = nil
    self.MaxExpText = nil
    self.ExpProgressValue = nil
    self.LogIcon = nil
    self.TrendList = nil
    self.GrandCompanyType = nil
end

function ArmyInfoPageVM:OnInit()
    self.ArmyInfoTrendsVM = ArmyInfoTrendsVM.New()
    self.ArmyInfoTrendsVM:OnInit()
    self.ArmyShowInfoVM = ArmyShowInfoVM.New()
    self.ArmyShowInfoVM:OnInit()
    self.ArmyShowInfoVM:SetIsShowArmyLeader(false)
    --self.PrivilegeList = UIBindableList.New(ArmyPrivilegeListItemVM)
    self.SEList = UIBindableList.New(ArmySpecialEffectsItemVM)
    self.TrendList = UIBindableList.New(ArmyInfoTrendsItemVM)
    self.GainExpWay = GroupStoreUitextCfg:FindCfgByKey(ArmyDefine.ArmyUITextID.GainExpWay).TextStr or ""
end

function ArmyInfoPageVM:OnBegin()
    self.ArmyInfoTrendsVM:OnBegin()
    self.ArmyShowInfoVM:OnBegin()
end

function ArmyInfoPageVM:OnEnd()
    self.ArmyInfoTrendsVM:OnEnd()
    self.ArmyShowInfoVM:OnEnd()
end

function ArmyInfoPageVM:OnShutdown()
    self.ArmyShowInfoVM:OnShutdown()
    self.ArmyInfoTrendsVM:OnShutdown()
end

function ArmyInfoPageVM:GetArmyInfoTrendsVM()
    return self.ArmyInfoTrendsVM
end

function ArmyInfoPageVM:UpdateArmyInfo(ArmyInfo, CategoryData, LeaderRoleID, bLeader)
    local ArmySimple = ArmyInfo.Simple
    local RecruitStatus = ArmySimple.RecruitStatus
    local RecruitSlogan = ArmySimple.RecruitSlogan
    local Level = ArmySimple.Level
    local MaxGainCurExp = GroupLevelCfg:GetGroundMaxScoreByLevel(Level)
    local CurLevelExp = GroupLevelCfg:GetGroundScoreByLevel(Level + 1)
    local Exp = ArmySimple.Exp
    local Score = ArmyInfo.Score or {Count = 0, CycleCount = 0, CycleTime = 0}
    self.ArmyLevel = Level
    self.ArmyID = ArmySimple.ID
    self.LeaderRoleID = LeaderRoleID
    self.GrandCompanyType = ArmySimple.GrandCompanyType
    local Cfg = GrandCompanyCfg:FindCfgByKey(self.GrandCompanyType)
    self.UnionBgIcon = Cfg.BgIcon
    -- local MaxMemberCountStr = string.format("/%s", MaxMemberCount)
    -- MaxMemberCountStr = RichTextUtil.GetText(MaxMemberCountStr, "828282")
    -- self.MemberNum = string.format("%d%s", ArmySimple.MemberCount, MaxMemberCountStr)
    self:UpdateMemberNumByData(ArmySimple.MemberCount, Level)
    self.GainNum = self:FormatNumber(Score.Count)
    self.bRecruitEnable = bLeader
    self:UpdateEidtPermssion(CategoryData)
    self:SetName(ArmySimple.Name, ArmyInfo.NameEditedTime)
    self:SetShortName(ArmySimple.Alias, ArmyInfo.AliasEditedTime)
    self:SetNotice(ArmyInfo.Notice)
    self:SetRecruitInfo(RecruitSlogan, RecruitStatus)
    self:SetLeaderID(self.LeaderRoleID)
    self:SetBadgeData(ArmySimple.Emblem, ArmyInfo.EmblemEditedTime)
    self:UpdateDynamicLogs(ArmyInfo.TopLogs)
    self.ArmyShowInfoVM:SetData(
        self.LeaderRoleID,
        self.GrandCompanyType,
        self.ArmyID,
        ArmyInfo.Notice,
        ArmySimple.Emblem,
        ArmySimple.Name,
        ArmySimple.Alias
    )
    self:SetLevelExpShow(Exp, CurLevelExp)
    local CycleExp = ArmyInfo.CycleExp or {Num = 0, Time = 0}
    if MaxGainCurExp then
        self:DailyUpadte(CycleExp)
        self:SetCurMaxLevelText(CycleExp.Num, MaxGainCurExp)
    end
    --self:UpdatePrivilegeList(Level)
    ---特效处理
    self:UpdateSEList(ArmyInfo.BonusStateUps)
end

function ArmyInfoPageVM:FormatNumber(Number)
    
    local resultNum = Number
    if type(Number) == "number" then
        local inter, point = math.modf(Number)

        local StrNum = tostring(inter)
        local NewStr = ""
        local NumLen = string.len( StrNum )
        local Count = 0
        for i = NumLen, 1, -1 do
            if Count % 3 == 0 and Count ~= 0  then
                NewStr = string.format("%s,%s",string.sub( StrNum,i,i),NewStr) 
            else
                NewStr = string.format("%s%s",string.sub( StrNum,i,i),NewStr) 
            end
            Count = Count + 1
        end

        if point > 0 then
            --@desc 存在小数点，
            local strPoint = string.format( "%.2f", point )
            resultNum = string.format("%s%s",NewStr,string.sub( strPoint,2, string.len( strPoint ))) 
        else
            resultNum = NewStr
        end
    end
    
    return resultNum
end

function ArmyInfoPageVM:UpdateMemberNum()
    local MemberNum = ArmyMgr:GetArmyMembersCount()
    local Level = ArmyMgr:GetArmyLevel()
    self:UpdateMemberNumByData(MemberNum, Level)
end

function ArmyInfoPageVM:UpdateMemberNumByData(MemberNum, Level)
    local MaxMemberCount = ArmyMgr:GetArmyMemberMaxCount(Level)
    local MaxMemberCountStr = string.format("/%s", MaxMemberCount)
    MaxMemberCountStr = RichTextUtil.GetText(MaxMemberCountStr, "828282")
    self.MemberNum = string.format("%d%s", MemberNum, MaxMemberCountStr)
end

--- 设置经验显示
---@param CurExp number @当前经验
---@param LevelExp number @下一次升级所需经验
function ArmyInfoPageVM:SetLevelExpShow(CurExp, LevelExp)
    self:SetLevelExpText(CurExp, LevelExp)
    if LevelExp then
        self.ExpProgressValue  = CurExp/LevelExp
    else
        self.ExpProgressValue  = 1
    end
end

--- 设置经验文本显示
---@param CurExp number @当前经验
---@param LevelExp number @下一次升级所需经验
function ArmyInfoPageVM:SetLevelExpText(CurExp, LevelExp)
    if LevelExp then
        --self.ExpText = string.format("%d/%d", CurExp, LevelExp)
        local LevelExpStr = string.format("/%s", LevelExp)
        LevelExpStr = RichTextUtil.GetText(LevelExpStr, "828282")
        self.ExpText = string.format("%d%s", CurExp, LevelExpStr)
    else
        -- LSTR string:已满级
        self.ExpText = LSTR(910111)
    end
end

--- 设置每日经验文本显示
---@param CurExp number @当前获取每日经验
---@param LevelExp number @每日最大经验
function ArmyInfoPageVM:SetCurMaxLevelText(CurExp, LevelExp)
    -- LSTR string:本日获取上限
    local TextStr = LSTR(910164)
    self.MaxExpText = string.format("%s:%d/%d", TextStr, CurExp, LevelExp)
end

--- 设置名称
---@param Name string @名称
---@param NextEditTime number @下一次可编辑时间
function ArmyInfoPageVM:SetName(Name, NextEditTime)
    self.ArmyName = Name
    self.NameEditedTime = NextEditTime
    self.ArmyShowInfoVM.ArmyName = Name
end

--- 设置名称
---@param Name string @名称
---@param NextEditTime number @下一次可编辑时间
function ArmyInfoPageVM:GetName()
    return self.ArmyName
end

--- 设置简称
function ArmyInfoPageVM:SetShortName(ShortName, NextEditTime)
    self.ArmyShortName = ShortName
    self.AliasEditedTime = NextEditTime
    self.ArmyShowInfoVM.ArmyShortName = string.format("<%s>",ShortName)
    ---自身编辑简称单独走一个事件，给部队信息编辑界面更新，区分于部队简称实时更新
    EventMgr:SendEvent(EventID.ArmySelfArmyAliasUpdateBySelf, ShortName, NextEditTime)
end

--- 获取简称
function ArmyInfoPageVM:GetShortName()
    return self.ArmyShortName
end

--- 设置部队长ID
---@param LeaderRoleID number @部队长ID
function ArmyInfoPageVM:SetLeaderID(LeaderRoleID)
    if LeaderRoleID == nil then
        return
    end
    RoleInfoMgr:QueryRoleSimple(LeaderRoleID, function(_, RoleVM)
        if nil == RoleVM then
            return
        end
        if RoleVM.Name then
            self.CaptainName = RoleVM.Name
        else
            self.CaptainName = ""
        end
    end)
    _G.ArmyMgr:GetMemberDataByRoleID(LeaderRoleID, function(Member)
        local LoaderMember = Member
        local CategoryID = LoaderMember.Simple.CategoryID
        local CategoryData = _G.ArmyMgr:GetCategoryDataByID(CategoryID)
        if CategoryData then
            local CategoryName = CategoryData.Name
            if string.isnilorempty(CategoryName) then
                local CfgCategoryName
                local DefaultCategoryNameData = ArmyMgr:GetDefaultCategoryName()
                CfgCategoryName = table.find_all_by_predicate(DefaultCategoryNameData, function(A)
                    return A.ID == CategoryID
                end
                )
                CategoryName = CfgCategoryName or DefineCategorys.LeaderName
            end
            self:SetCaptainCategoryName(CategoryName)
        end
    end)
    
end

--- 设置部队长ID
---@param LeaderRoleID number @部队长ID
function ArmyInfoPageVM:GetLeaderID()
    return self.LeaderRoleID
end

function ArmyInfoPageVM:SetCaptainCategoryName(Name)
    self.CaptainCgName = Name
end

function ArmyInfoPageVM:UpdateEidtPermssion(MyCategoryData)
    if nil == MyCategoryData then
        return
    end
    --- 更新权限状态/自身权限在登录和全量下发时会更新
    self.bEditNameEnable = ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.GROUP_PERMISSION_TYPE_EditIntro)
    self.bNoticeEnable = ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.GROUP_PERMISSION_TYPE_EditNotice)
end

--- 设置公告信息
---@param Notice string 公告
function ArmyInfoPageVM:SetNotice(Notice)
    self.Notice = Notice
    self.ArmyShowInfoVM.Slogan = Notice
end

--- 获取公告信息
function ArmyInfoPageVM:GetNotice()
    return self.Notice
end

--- 设置招募信息
---@param RecruitSlogan 招募标语
---@param RecruitStatus 招募状态 0 关闭 1公开
function ArmyInfoPageVM:SetRecruitInfo(RecruitSlogan, RecruitStatus)
    local bOpen = RecruitStatus == GroupRecruitStatus.GROUP_RECRUIT_STATUS_Open
    -- LSTR string:公开招募
    self.RecruitTips = string.format("<%s>", bOpen and LSTR(910057) or LSTR(910049))
    if bOpen then
        self.RecruitSloganTip = RecruitSlogan
    else
        self.RecruitSloganTip = ""
    end
end

--- 设置队徽
---@param BadgeData GroupEmblem @队徽
---@param NextEditEmblemTime number @下次可以修改时间
function ArmyInfoPageVM:SetBadgeData(BadgeData, EmblemEditedTime)
    self.BadgeData = BadgeData
    self.ArmyShowInfoVM:SetBadgeData(BadgeData)
    self.EmblemEditedTime = EmblemEditedTime
end

--- 更新部队动态信息
function ArmyInfoPageVM:UpdateDynamicLogs(LogData)
    local Len = table.length(LogData or {})
    if Len > 0 then
        self.bTopLogShow = true
    else
        self.bTopLogShow = false
        return
    end
    table.sort(LogData, function(A, B)
        if A.Time == nil or B.Time == nil then
            return A.Time
        end
        if A.Time == B.Time then
            ---todo 没有复现服务器下发的数据是nil，先判空，等服务器同学请假回来一起排查
            if A.LogType and B.LogType then
                return A.LogType > B.LogType
            else
                return A.LogType
            end
        end
        return A.Time > B.Time
    end)
    --界面改版，日志只显示首条
    --for i = 1, Len do
    -- local Type = LogData[1].LogType
    -- self.LogIcon = ArmyMgr:GetArmyLogIconByLogType(Type)
    -- ArmyMgr:GetArmyLogTextByLogData(LogData[1],function(Text)
    --     self.NewsContent = Text
    --     ---长度不超过24, 中英文占位数量不一样
    --     self.NewsContent =  self:SetStrByTextNum(self.NewsContent, 24)
    -- end )
    ---改回显示3条
    local Logs = {}
    if Len > MainLogsCount then
        Len = MainLogsCount
    end
    for i = 1, Len do
        local Log = table.clone(LogData[i])
        Log.IsCloseBG = true
        table.insert(Logs, Log)
    end
    self.TrendList:UpdateByValues(Logs)
end

---todo 后续考虑用</>做特征查询处理，防止“1<2,2>1”这种特殊情况
function ArmyInfoPageVM:SetStrByTextNum(Str, TextNum)
    local Count = 0
    local Index = 1
    local EndCount = 1
    local IsEndTag = true
    ---处理第一个富文本标签前面的文本，如果有的话
    local FirstContent = Str:match("([^<]*)(<.->)")
    if FirstContent then
        if FirstContent ~= "" then
            while Index < #FirstContent and Count < TextNum do
                local Char = string.sub(FirstContent, Index, Index)
                if Char:match("[\x80-\xff]") then
                    Count = Count + 1
                    Index = Index + 3
                    EndCount = 3
                else
                    Count = Count + 0.5
                    Index = Index + 1
                    EndCount = 1
                end
            end
        end
        if Count >= TextNum then
            return string.sub(Str, 1, Index - 1 - EndCount).."..."
        end
        --- 提取富文本标签，不计入长度
        for Tag, Content in Str:gmatch("(<.->)([^<]*)") do
            IsEndTag = Tag == "</>"
            Index = Index + #Tag
            local CurLength = Index
            --Index = Index + 1
            while Index - CurLength < #Content and Count < TextNum do
                local Char = string.sub(Str, Index, Index)
                if Char:match("[\x80-\xff]") then
                    Count = Count + 1
                    Index = Index + 3
                    EndCount = 3
                else
                    Count = Count + 0.5
                    Index = Index + 1
                    EndCount = 1
                end
            end
            if Count >= TextNum then
                if IsEndTag then
                    return string.sub(Str, 1, Index - 1 - EndCount).."..."
                else
                    return string.format("%s%s%s", string.sub(Str, 1, Index - 1 - EndCount), "</>", "...")
                end
            end
        end
    else
        ---无富文本标签
        while Index <= #Str and Count < TextNum do
            local Char = string.sub(Str, Index, Index)
            if Char:match("[\x80-\xff]") then
                Count = Count + 1
                Index = Index + 3
                EndCount = 3
            else
                Count = Count + 0.5
                Index = Index + 1
                EndCount = 1
            end
        end
        if Count >= TextNum then
            return string.sub(Str, 1, Index - 1 - EndCount).."..."
        end
    end
    return Str
end

function ArmyInfoPageVM:UpdateArmyLogs(ArmyLogs)
    --需要把头3条消息更新到InfoPage
    for Index, LogData in ipairs(ArmyLogs) do
        local CfgData = GroupLogCfg:FindCfgByKey(LogData.LogType)
        if CfgData then
            LogData.FilterType = CfgData.Type
        else
            -- LSTR string:全部
            LogData.FilterType = LSTR(910054)
        end
    end
    self:UpdateDynamicLogs(ArmyLogs)
    self.ArmyInfoTrendsVM:SetData(ArmyLogs)
end

function ArmyInfoPageVM:AddArmyLogs(ArmyLogs)
    self.ArmyInfoTrendsVM:AddLogsToList(ArmyLogs)
end

function ArmyInfoPageVM:UpdateArmyGainNum(GainNum)
    self.GainNum = self:FormatNumber(GainNum)
end

----部队信息界面不显示权限了，先屏蔽
-- function ArmyInfoPageVM:UpdatePrivilegeList(InLevel)
--     local Cfg = GroupUplevelpermissionCfg:FindAllCfg()
--     local ArmyLevel = InLevel
--     local PrivilegeList = {}
--     for _, Data in ipairs(Cfg) do
--         if Data.Level <= ArmyLevel then
--             local ReplaceIndex
--             local IsExist = false
--             for Index, Privilege in ipairs(PrivilegeList) do
--                 if Data.Type == Privilege.Type then
--                     IsExist = true
--                     if Data.Level > Privilege.Level then
--                         ReplaceIndex = Index
--                     end
--                 end
--             end
--             local ItemData = table.clone(Data)
--             if ReplaceIndex then
--                 PrivilegeList[ReplaceIndex] = ItemData
--             elseif IsExist == false then
--                 if Data.Type ~= 0 then
--                     table.insert(PrivilegeList, ItemData)
--                 end
--             end
--         end
--     end
--     ---显示一个的时候，为了Item保持一致，额外加一个空Item
--     if #PrivilegeList == 1 then
--         local Data ={}
--         Data.ID = 0
--         Data.Permission = ""
--         Data.Icon = ""
--         table.insert(PrivilegeList, Data)
--     end
--     self.PrivilegeList:UpdateByValues(PrivilegeList)
-- end

function ArmyInfoPageVM:UpdateSEList(Ups)
    local UsedBonusStateDataList = {}
    local CurTime = TimeUtil.GetServerTime()
    local MaxNum = ArmyMgr:GetArmyMaxUsedBonusStatesNum() or 0
    for Index = 1, MaxNum do
        local EmptyItem = {
            Index = Index,
            ID = -Index,
            IsEmpty = true,
            IsSelected = false,
        }
        table.insert(UsedBonusStateDataList, EmptyItem)
    end
    if Ups then
        for _, UsedData in ipairs(Ups) do
            local StateShowCfg = GroupBonusStateDataCfg:FindCfgByKey(UsedData.ID)
            local ArmyStateCfg = GroupBonusStateCfg:FindCfgByKey(UsedData.ID)
            if StateShowCfg and ArmyStateCfg then
                local UsedItem = {}
                UsedItem.ID = UsedData.ID
                UsedItem.IsEmpty = false
                UsedItem.Index = UsedData.Index
                UsedItem.Name = StateShowCfg.EffectName
                UsedItem.Desc = StateShowCfg.Desc
                UsedItem.Icon = ArmyStateCfg.Icon
                UsedItem.EndTime = UsedData.EndTime
                UsedItem.SimpleDesc = ArmyStateCfg.SimpleDesc
                if UsedItem.EndTime - CurTime > 0 then
                    UsedBonusStateDataList[UsedItem.Index] = UsedItem
                    --table.insert(UsedBonusStateDataList, UsedItem)
                end
            end
        end
    end
    --local Len = #UsedBonusStateDataList
    -- if MaxNum > Len then
    --     local Num = MaxNum - Len
    --     for _ = 1, Num do
    --         local UsedItem = {}
    --         UsedItem.IsEmpty = true
    --         table.insert(UsedBonusStateDataList, UsedItem)
    --     end
    -- end
    self.SEList:UpdateByValues(UsedBonusStateDataList)
end

-- function ArmyInfoPageVM:UpdataUsedBonusStates(Ups)
--     local UsedBonusStatesList = ArmyMgr:GetArmyUsedBonusStates()
--     self:UpdateSEList(UsedBonusStatesList)
-- end

--- 切页签时更新显示数据
function ArmyInfoPageVM:UpdateArmyInfoPanelData(Info)
    local Level = Info.GroupLevel
    --- 特效数据更新
    self:UpdateSEList(Info.BonusStateUps)
    if Info.Logs ~= nil then
        --- 日志更新
        self:UpdateArmyLogs(Info.Logs)
    end
    ---右侧旗帜数据更新
    self:SetName(Info.GroupName, self.NameEditedTime)
    self:SetShortName(Info.GroupAlias, self.AliasEditedTime)
    self:SetNotice(Info.GroupNotice)
    self.ArmyLevel = Level
    self.LeaderRoleID = Info.LeaderID
    self:SetLeaderID(Info.LeaderID)
    self.ArmyShowInfoVM:SetData(
        Info.LeaderID,
        self.GrandCompanyType,
        self.ArmyID,
        Info.GroupNotice,
        Info.Emblem,
        Info.GroupName,
        Info.GroupAlias
    )
    ---经验设置
    local MaxGainCurExp = GroupLevelCfg:GetGroundMaxScoreByLevel(Level)
    local CurLevelExp = GroupLevelCfg:GetGroundScoreByLevel(Level + 1)
    local Exp = Info.GroupExp
    self:UpdateMemberNumByData(Info.MemberCount, Level)
    self:SetLevelExpShow(Exp, CurLevelExp)
    ---todo 注意跨天处理
    local CycleExp = Info.CycleExp or {Num = 0, Time = 0}
    if MaxGainCurExp then
        self:DailyUpadte(CycleExp)
        self:SetCurMaxLevelText(CycleExp.Num, MaxGainCurExp)
    end
    ----部队信息界面不显示权限了，先屏蔽
    --self:UpdatePrivilegeList(Level)
    --- 权限更新
    self:UpdateEidtPermssion(ArmyMgr:GetSelfCategoryData())
end

function ArmyInfoPageVM:DailyUpadte(CycleExp)
    if CycleExp then
        if nil == CycleExp.Time or CycleExp.Time == 0 then
            CycleExp.Num = 0
        else
            local IsCurDailyCycleTime = TimeUtil.GetIsCurDailyCycleTime(CycleExp.Time)
            if not IsCurDailyCycleTime then
                CycleExp.Num = 0
            end
        end
    end
end

--- 设置是否自动打开编辑信息界面,显示后会自动置为false
function ArmyInfoPageVM:SetIsOpenEditWin(IsOpen)
    self.IsOpenEditWin = IsOpen
end

function ArmyInfoPageVM:GetIsOpenEditWin()
    return self.IsOpenEditWin
end

function ArmyInfoPageVM:GetArmyID()
    return self.ArmyID
end


return ArmyInfoPageVM
