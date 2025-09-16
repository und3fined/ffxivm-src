--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description: 试衣界面VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local FashionEquipItemVM = require("Game/FashionEvaluation/VM/ItemVM/FashionEquipItemVM")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")
local FashionThemePartItemVM = require("Game/FashionEvaluation/VM/ItemVM/FashionThemePartItemVM")
local HistoryIndexItem = require("Game/FashionEvaluation/VM/ItemVM/FashionHistoryIndexItevVM")
local FashionChallengeEquipItemVM = require("Game/FashionEvaluation/VM/ItemVM/FashionChallengeEquipItemVM")

local LSTR = _G.LSTR
local RecommendTag = FashionEvaluationDefine.RecommendTag

---@class FashionEvaluationFittingVM : UIViewModel
---@field ThemeNameText boolean @主题名
---@field PartThemeList table @主题部分表
---@field LastWearAppearanceList table @最后穿戴的外观列表
---@field ServerRecommendEquipList table @后台推荐外观ID列表
---@field AppearanceInfoList table @外观详情列表
---@field CurWearAppearanceList table @当前外观ID列表
---
local FashionEvaluationFittingVM = LuaClass(UIViewModel)

function FashionEvaluationFittingVM:Ctor(EvaluationVM)
    self.EvaluationVM = EvaluationVM
    --试衣界面
    self.IsFirstTimesEnter = false
    self.IsHistoryEmpty = true
    self.ServerRecommendEquipList = {}
    self.ThemeNameText = ""
    self.CurSelectPart = 0
    self.CurSelectAppID = 0
    self.CurSelectEquipName = ""
    self.CurSelectEquipIsOwn = false
    self.LastWearAppearanceList = {}
    self.CurWearAppearanceList = {}
    self.CurSelectEquipIsTracked = false
    self.PartThemeList = {}
    self.PartThemeVMList = UIBindableList.New(FashionThemePartItemVM)
    self.AppearanceInfoList = {}
    self.AppearanceInfoVMlist = UIBindableList.New(FashionEquipItemVM)
    ---历史记录界面
    self.CurHistoryIndex = 0
    self.CurSelectedHistoryScore = 0
    self.EvaluationHistoryList = {}
    self.EvaluationHistoryVMList = UIBindableList.New(FashionChallengeEquipItemVM)
    self.CurSelectedHistoryList = {}
    self.EvaluationHistoryIndexList = {}
    self.EvaluationHistoryIndexVMList = UIBindableList.New(HistoryIndexItem)
end

---@type 更新时尚品鉴信息
function FashionEvaluationFittingVM:UpdateThemeInfo(Info)
    if Info == nil then
        return
    end

    self.ThemeID = Info.ThemeID
    self.ThemeName = FashionEvaluationVMUtils.GetThemeName(self.ThemeID)
    self.ThemeNameText = string.format(FashionEvaluationDefine.ThemeNameText, self.ThemeName)
    if Info.RecommendEquips then
        self.ServerRecommendEquipList = Info.RecommendEquips
    end

    self:UpdateThemePartList()
    self:UpdateHistoryList(Info.EvaluationHistorys)
end

---@type 更新部位主题列表 
function FashionEvaluationFittingVM:UpdateThemePartList(NewAppearanceList)
    if self.PartThemeList == nil then
        return
    end

    -- 更新当前主题部位最新外观
    if NewAppearanceList then
        for i = 1, #self.PartThemeList do
            local CurPartData = self.PartThemeList[i]
            for _, NewAppearance in ipairs(NewAppearanceList) do
                local NewEquipPart = NewAppearance.Part
                local NewAppearanceID = NewAppearance.AppearanceID
                if NewEquipPart and CurPartData and NewEquipPart == CurPartData.Part then
                    CurPartData.AppearanceID = NewAppearanceID
                    self.CurWearAppearanceList[NewEquipPart] = (NewAppearanceID ~= 0 and NewAppearanceID) or nil
                end
            end
        end
    else
        self.PartThemeList = FashionEvaluationVMUtils.GetPartThemeList(self.ThemeID, FashionEvaluationDefine.EFashionView.Fitting)
        self.CurWearAppearanceList = {}
    end

    self.CurSelectThemePart = self.PartThemeList and self.PartThemeList[1]
    self.PartThemeVMList:UpdateByValues(self.PartThemeList, nil)
end

function FashionEvaluationFittingVM:GetPartThemeList()
    return self.PartThemeList
end

---@type 获取用于挑战的外观列表
function FashionEvaluationFittingVM:GetPartEquipList()
    if self.PartThemeList == nil then
        return
    end

    local AppearanceList = {}
    for _, PartTheme in ipairs(self.PartThemeList) do
        local Part = PartTheme.Part
        local AppearanceID = PartTheme.AppearanceID
        if Part and AppearanceID then
            AppearanceList[Part] = {AppearanceID = AppearanceID}
        end
    end
    return AppearanceList
end

---@type 试衣界面主题部位选中
function FashionEvaluationFittingVM:OnThemePartItemSelected(Index, ItemData)
    if ItemData == nil then
        return
    end

    self.CurSelectPart = ItemData.Part
    self.CurSelectThemePart = self.PartThemeList and self.PartThemeList[Index]
    -- 默认选中推荐标签
    self:UpdateAppearanceInfoListByTag(self.CurSelectPart, RecommendTag.Recommend)
    
end

---@type 通过点击标签更新外观列表
function FashionEvaluationFittingVM:UpdateAppearanceInfoListByTag(PartID, Tag)
    if PartID == nil then
        return
    end

    self.CurSelectEquipTag = Tag
    self.AppearanceInfoList = {}
    local RightAppearanceList = self:GetThemePartRightAppearanceList(PartID, self.CurSelectEquipTag)
    self:UpdateAppInfoListInternal(PartID, RightAppearanceList)
end

local function RecommendEquipSortFunc(EquipA, EquipB)
    if EquipA.IsTracked ~= EquipB.IsTracked then
        return EquipA.IsTracked
    end
    
    return EquipA.AppearanceID < EquipB.AppearanceID
end

local function AllEquipSortFunc(EquipA, EquipB)
    if EquipA.IsTracked ~= EquipB.IsTracked then
        return EquipA.IsTracked
    elseif EquipA.IsOwn ~= EquipB.IsOwn then
        return EquipA.IsOwn
    end
   
    return EquipA.AppearanceID < EquipB.AppearanceID
end

---@type 更新外观信息列表
function FashionEvaluationFittingVM:UpdateAppInfoListInternal(PartID, AppIDList)
    if PartID == nil then
        return
    end

    self.AppearanceInfoVMlist:Clear()
    self.AppearanceInfoList = {}
    self.CurSelectEquipIndex = nil
    local IsEquiped = false
    local EquipedAppID = 0
    if AppIDList ~= nil then
        for _, AppearanceID in ipairs(AppIDList) do
            local EquipInfo = {}
            EquipInfo.Part = PartID
            EquipInfo.PartThemeID = self:GetPartThemeID(PartID)
            EquipInfo.AppearanceID = AppearanceID
            EquipInfo.IsEquiped = self:IsEquiped(AppearanceID)
            EquipInfo.IsOwn = self:IsOwned(AppearanceID)
            EquipInfo.IsTracked = self:IsTracked(AppearanceID)
            table.insert(self.AppearanceInfoList, EquipInfo)
            if EquipInfo.IsEquiped then
                IsEquiped = true
                EquipedAppID = AppearanceID
            end
        end
    
        local SortFunc = self.CurSelectEquipTag == RecommendTag.Recommend and RecommendEquipSortFunc or AllEquipSortFunc
        table.sort(self.AppearanceInfoList, SortFunc)
        
        local _, NewIndex = TableTools.FindTableElementByPredicate(self.AppearanceInfoList, function(A)
            return A.AppearanceID == EquipedAppID
        end)
        if NewIndex then
            self.CurSelectEquipIndex = NewIndex
        end
    end

    self.CurSelectAppID = EquipedAppID
    self:UpdateSelectedEquipInfo(self.CurSelectAppID)
    self.AppearanceInfoVMlist:UpdateByValues(self.AppearanceInfoList, nil)
end

function FashionEvaluationFittingVM:GetCurAppearanceInfoList()
    return self.AppearanceInfoList
end

---@type 更新当前选中外观信息
function FashionEvaluationFittingVM:UpdateSelectedEquipInfo(AppearanceID)
    local AppInfo = FashionEvaluationVMUtils.GetAppearanceInfo(AppearanceID)
    if AppInfo then
        self.CurSelectEquipName = AppInfo.AppearanceName
        self.CurSelectEquipIsOwn = self:IsOwned(AppearanceID)
        self.CurSelectEquipIsTracked = self:IsTracked(AppearanceID)
    else
        self.CurSelectEquipName = ""
        self.CurSelectEquipIsOwn = false
        self.CurSelectEquipIsTracked = false
    end
end

---@type 试衣界面外观选中 重复选中视为取消
function FashionEvaluationFittingVM:OnEquipItemSelected(Index, ItemData)
    if ItemData == nil then
        return
    end

    self.CurSelectAppID = ItemData.AppearanceID
    local Part = ItemData.Part
    -- 左侧主题部位外观更新
    if self.CurSelectThemePart then
        local CurPartAppID = self.CurSelectThemePart.AppearanceID
        if CurPartAppID == self.CurSelectAppID then
            self:SetThemePartAppearance(Part, 0)
            self.CurSelectAppID = 0
        else
            self:SetThemePartAppearance(Part, self.CurSelectAppID)
        end
        self.PartThemeVMList:UpdateByValues(self.PartThemeList, nil)
    end

    -- 穿戴状态更新
    if self.CurSelectEquipIndex and Index ~= self.CurSelectEquipIndex then
        local PrevSelectedEquipInfo = self.AppearanceInfoList[self.CurSelectEquipIndex]
        if PrevSelectedEquipInfo then
            PrevSelectedEquipInfo.IsEquiped = false
        end
        self:UpdateAppearanceInfoItem(self.CurSelectEquipIndex, PrevSelectedEquipInfo)
    end
    
    local CurSelectedAppearanceInfo = self.AppearanceInfoList[Index]
    if CurSelectedAppearanceInfo then
        CurSelectedAppearanceInfo.IsEquiped = not CurSelectedAppearanceInfo.IsEquiped
        self:UpdateAppearanceInfoItem(Index, CurSelectedAppearanceInfo)
        self:UpdateSelectedEquipInfo(self.CurSelectAppID)
    end

    self.CurSelectEquipIndex = Index
end

---@type 更新外观列表指定Item
function FashionEvaluationFittingVM:UpdateAppearanceInfoItem(Index, NewAppInfo)
    local EquipItems = self.AppearanceInfoVMlist:GetItems()
    if EquipItems then
        local SelectedItem = EquipItems[Index]
        if SelectedItem then
            SelectedItem:UpdateVM(NewAppInfo)
        end
    end
end

---@type 更新挑战记录列表指定ItemVM
function FashionEvaluationFittingVM:UpdateRecordEquipItemVM(AppearanceID, IsTrack)
    local HistoryVMItems = self.EvaluationHistoryVMList:GetItems()
    if HistoryVMItems then
        for _, ItemData in ipairs(HistoryVMItems) do
            if ItemData.AppearanceID == AppearanceID then
                ItemData.IsTracked = IsTrack
            end
        end
    end
end

---@type 设置当前选中主题部位外观
---@param Part 部位ID
---@param AppearanceID 外观ID
function FashionEvaluationFittingVM:SetThemePartAppearance(Part, AppearanceID)
    if self.CurSelectThemePart == nil then
        return
    end
    self.IsEquipedHistory = false
    local CurWearAppearanceID = self.CurSelectThemePart.AppearanceID
    if CurWearAppearanceID and CurWearAppearanceID ~= 0 then
        self.CurWearAppearanceList[Part] = nil
    end

    self.CurWearAppearanceList[Part] = (AppearanceID ~= 0 and AppearanceID) or nil
    
    self.CurSelectThemePart.AppearanceID = AppearanceID
    
    self.PartThemeVMList:UpdateByValues(self.PartThemeList, nil)
end

---@type 获取主题部位外观列表
---@param PartThemeID 部位主题ID
function FashionEvaluationFittingVM:GetThemePartRightAppearanceList(PartID, Tag)
    local AppIDList = nil
    if Tag == RecommendTag.Recommend or Tag == nil then
        AppIDList = self:GetThemePartRecommendAppIDList(PartID)
    elseif Tag == RecommendTag.All then
        AppIDList = self:GetThemePartAllEquipsList(PartID)
    end
    return AppIDList
end

---@type 获取部位所有外观列表
---@param Part 部位ID
function FashionEvaluationFittingVM:GetThemePartAllEquipsList(PartID)
    return FashionEvaluationVMUtils.GetAppearanceListByPartID(PartID)
end

---@type 获取部位推荐外观列表
---@param PartID 部位主题ID @为空返回全部
function FashionEvaluationFittingVM:GetThemePartRecommendAppIDList(PartID)
    if self.ServerRecommendEquipList == nil then
        return nil
    end

    if PartID == nil then
        return nil
    end

    for _, EquipInfo in ipairs(self.ServerRecommendEquipList) do
        local Part = EquipInfo.Part
        local AppIDList = EquipInfo.AppIDList
        if PartID == Part and AppIDList then
            return AppIDList
        end
    end
    return nil
end

---@type 获取部位主题ID
---@param PartID 部位ID
function FashionEvaluationFittingVM:GetPartThemeID(PartID)
    if self.PartThemeList == nil then
        return nil
    end

    if PartID == nil then
        return nil
    end

    for _, PartInfo in ipairs(self.PartThemeList) do
        if PartInfo.Part == PartID then
            return PartInfo.PartThemeID
        end
    end
end

---@type 获取部位默认外观ID
---@param PartID 部位ID
function FashionEvaluationFittingVM:GetPartDefaultAppearanceID(PartID)
    if self.PartThemeList == nil then
        return nil
    end

    if PartID == nil then
        return nil
    end

    for _, PartInfo in ipairs(self.PartThemeList) do
        if PartInfo.Part == PartID then
            return PartInfo.DefaultAppearanceID
        end
    end
end

---@type 外观是否装备
---@param InAppearanceID 外观ID
function FashionEvaluationFittingVM:IsEquiped(InAppearanceID)
    for _, AppearanceID in pairs(self.CurWearAppearanceList) do
        if AppearanceID == InAppearanceID then
            return true
        end
    end
    return false
end

---@type 外观是否拥有
---@param ApperanceID 外观ID
function FashionEvaluationFittingVM:IsOwned(ApperanceID)
    return WardrobeMgr:GetIsUnlock(ApperanceID) -- 通过衣橱判断
end

---@type 外观是否追踪
---@param AppearanceID 外观ID
function FashionEvaluationFittingVM:IsTracked(AppearanceID)
    return self.EvaluationVM:IsTracked(AppearanceID)
end

---@type 本次穿搭是否与上次挑战一样
function FashionEvaluationFittingVM:IsSameWithLastEquipList()
    if self.LastWearAppearanceList == nil or next(self.LastWearAppearanceList) == nil then
        return false
    end

    if self.CurWearAppearanceList == nil or next(self.CurWearAppearanceList) == nil then
        return false
    end

    for _, LastWearEquip in ipairs(self.LastWearAppearanceList) do
        local LastWearAppID = LastWearEquip.AppearanceID
        local LastPart = LastWearEquip.Part
        local CurWearEquipID = self.CurWearAppearanceList[LastPart]
        if (CurWearEquipID ~= nil and CurWearEquipID ~= LastWearAppID) or self:IsOwned(CurWearEquipID) ~= LastWearEquip.IsOwn then
            return false
        end
    end

    return true
end

---@type 本次穿搭是否完整
function FashionEvaluationFittingVM:IsEquipedComplete()
    local CurWearLength = table.length(self.CurWearAppearanceList)
    local PartThemeLength = self.PartThemeList and #self.PartThemeList or 0
    return CurWearLength >= PartThemeLength
end

---@type 获取当前选中主题部位
function FashionEvaluationFittingVM:GetCurSelectThemePart()
    return self.CurSelectThemePart
end

---------------------------外观搜索--------------------------------

---@type 搜索外观
---@param Content 搜索内容
function FashionEvaluationFittingVM:OnSearchEquip(Content)
    if string.isnilorempty(Content) then
        return
    end

    local RightAppIDList = self:GetThemePartRightAppearanceList(self.CurSelectPart, RecommendTag.All) -- 搜索内容不受“推荐”导航影响，搜索部位所有内容
    if RightAppIDList == nil then
        return
    end

    local SearchResultAppIDList = {}
    for _, AppearanceID in ipairs(RightAppIDList) do
        local AppInfo = FashionEvaluationVMUtils.GetAppearanceInfo(AppearanceID)
        if AppInfo then
            local AppearanceName = AppInfo.AppearanceName
            if not string.isnilorempty(AppearanceName) and not string.isnilorempty(Content) then
                if string.find(AppearanceName, Content) ~= nil then
                    table.insert(SearchResultAppIDList, AppearanceID)
                end
            end
        end
    end

    self:UpdateAppInfoListInternal(self.CurSelectPart, SearchResultAppIDList)
end

---@type 取消搜索
---@param Content 搜索内容
function FashionEvaluationFittingVM:OnCancelSearchEquip(EquipTag)
    self:UpdateAppearanceInfoListByTag(self.CurSelectPart, EquipTag or self.CurSelectEquipTag)
end

function FashionEvaluationFittingVM:GetCurSelectEquipResID()
    return self.CurSelectAppID
end

---@type 外观追踪状态改变
function FashionEvaluationFittingVM:OnAppearanceTrackChanged(AppearanceID, IsTrack)
    if self.CurSelectAppID == AppearanceID then
        self.CurSelectEquipIsTracked = IsTrack
    end

    --不改变排序，单独改变指定的外观追踪状态
    if self.AppearanceInfoList then
        for Index, EquipInfo in ipairs(self.AppearanceInfoList) do
            if EquipInfo.AppearanceID == AppearanceID then
                EquipInfo.IsTracked = IsTrack
                self:UpdateAppearanceInfoItem(Index, EquipInfo)
            end
        end
    end

    self:UpdateRecordEquipItemVM(AppearanceID, IsTrack)
end

---------------------------历史穿戴记录--------------------------------
---
---@type 更新历史记录
function FashionEvaluationFittingVM:UpdateHistoryList(EvaluationHistoryList)
    if EvaluationHistoryList == nil or #EvaluationHistoryList <= 0 then
        self.IsHistoryEmpty = true
        return
    end

    self.IsHistoryEmpty = false
    self.EvaluationHistoryIndexList = {}
    self.EvaluationHistoryList = {}
    for Index, HistoryItem in ipairs(EvaluationHistoryList) do
        local HistoryEquipInfo = {
            TotalScore = HistoryItem.TotalScore,
            --OwnScore = HistoryItem.OwnScore, -- 后台数据有问题TODO
            AppearanceList = {}
        }

        local OwnNum = 0
        local OwnScore = 0
        local MatchNum = 0
        local SuperMatchNum = 0
        local BaseScore = 0
        local MatchScore = 0
        local SuperMatchScore = 0
        local CheckResultMap = HistoryItem.EquipCheckResultMap
        ---后台返回的数据，如果部位没有穿戴，则不返回该部位数据，所以需要再这里拼凑
        local PartThemeList = FashionEvaluationVMUtils.GetPartThemeList(self.ThemeID, FashionEvaluationDefine.EFashionView.Fitting)
        if CheckResultMap and PartThemeList then
            for _, PartTheme in ipairs(PartThemeList) do
                local Part = PartTheme.Part
                local CheckResul = CheckResultMap[Part]
                local Equip = {}
                Equip.Part = Part
                Equip.PartThemeID = self:GetPartThemeID(Part)
                Equip.ViewType = FashionEvaluationDefine.EFashionView.Record
                if CheckResul then
                    Equip.AppearanceID = CheckResul.Equip and CheckResul.Equip.AppearanceID or 0
                    Equip.BaseScore = CheckResul.Score
                    Equip.OwnScore = CheckResul.OwnScore
                    Equip.MatchThemeScore = CheckResul.MatchThemeScore
                    Equip.Special = CheckResul.Special
                    Equip.IsMatchTheme = CheckResul.MatchThemeScore and CheckResul.MatchThemeScore > 0
                    Equip.IsOwn = CheckResul.OwnScore and CheckResul.OwnScore > 0
                    Equip.IsSuperMatch = CheckResul.Special and CheckResul.Special > 0
                    Equip.IsTracked = self:IsTracked(Equip.AppearanceID)
                else
                    Equip.AppearanceID = 0
                    Equip.IsMatchTheme = false
                    Equip.IsSuperMatch = false
                    Equip.IsOwn = false
                    Equip.IsTracked = false
                    Equip.DefaultAppearanceID = PartTheme.DefaultAppearanceID
                    Equip.DefaultEquipID = PartTheme.DefaultEquipID
                    Equip.BaseScore = 0
                    Equip.OwnScore = 0
                    Equip.MatchThemeScore = 0
                    Equip.Special = 0
                end
                Equip.Key = FashionEvaluationVMUtils.GetAppearanceKey(Equip.ViewType,
                Index, Part, Equip.AppearanceID),
                table.insert(HistoryEquipInfo.AppearanceList, Equip)

                BaseScore = BaseScore + Equip.BaseScore
                if Equip.IsOwn then
                    OwnNum = OwnNum + 1
                    OwnScore = OwnScore + Equip.OwnScore
                end
                
                if Equip.IsSuperMatch then
                    SuperMatchNum = SuperMatchNum + 1
                    SuperMatchScore = SuperMatchScore + Equip.Special
                elseif Equip.IsMatchTheme then
                    MatchNum = MatchNum + 1
                    MatchScore = MatchScore + Equip.MatchThemeScore
                end
            end
        end

        local ScoreRule = FashionEvaluationVMUtils.GetScoreRuleInfo()
        if ScoreRule then
            HistoryEquipInfo.MatchScore = MatchScore
            HistoryEquipInfo.SuperMatchScore = SuperMatchScore
            if CheckResultMap then
                HistoryEquipInfo.BaseScore = BaseScore
            end
        end
        HistoryEquipInfo.OwnNum = OwnNum
        HistoryEquipInfo.MatchNum = MatchNum
        HistoryEquipInfo.SuperMatchNum = SuperMatchNum
        HistoryEquipInfo.OwnScore = OwnScore
        -- 部位升序排序
        table.sort(HistoryEquipInfo.AppearanceList, FashionEvaluationDefine.PartSortFun)
        self.EvaluationHistoryIndexList[Index] = Index
        table.insert(self.EvaluationHistoryList, HistoryEquipInfo)
    end

    --最后一次挑战外观列表
    local Length = #self.EvaluationHistoryList
    if Length > 0 then
        local LastHistory = self.EvaluationHistoryList[Length]
        if LastHistory then
            self.LastWearAppearanceList = LastHistory.AppearanceList
        end
    end
    self.EvaluationHistoryIndexVMList:UpdateByValues(self.EvaluationHistoryIndexList, nil)
end

---@type 历史记录索引被选中
function FashionEvaluationFittingVM:OnHistoryIndexSelected(Index)
    self.CurHistoryIndex = Index
    local HistoryInfo = self.EvaluationHistoryList[self.CurHistoryIndex]
    if HistoryInfo == nil then
        return
    end
    self.CurSelectedHistoryList = {}
    self.CurSelectedHistoryScore = HistoryInfo.TotalScore
    self.CurSelectedHistoryScoreBG = FashionEvaluationVMUtils.GetPlayerScoreBG(self.CurSelectedHistoryScore)
    local HistoryEquipList = HistoryInfo.AppearanceList
    if HistoryEquipList == nil then
        return
    end
    
    for _, History in pairs(HistoryEquipList) do
        History.IsTracked = self:IsTracked(History.AppearanceID)
        History.ViewType = FashionEvaluationDefine.EFashionView.Record
    end
    self.CurSelectedHistoryList = HistoryEquipList
    self.EvaluationHistoryVMList:UpdateByValues(self.CurSelectedHistoryList, nil)
end

function FashionEvaluationFittingVM:GetCurSelectedHistoryInfo()
    return self.EvaluationHistoryList[self.CurHistoryIndex]
end

function FashionEvaluationFittingVM:GetCurSelectedHistoryList()
    return self.CurSelectedHistoryList
end

---@type 一键穿戴历史记录外观
function FashionEvaluationFittingVM:FittingSelectedHistoryEquips()
    local CurHistoryInfo = self.EvaluationHistoryList[self.CurHistoryIndex]
    if CurHistoryInfo == nil then
        return
    end

    local HistoryAppearanceList = CurHistoryInfo.AppearanceList
    if HistoryAppearanceList == nil then
        return
    end
    self.IsEquipedHistory = true
    self:UpdateThemePartList(HistoryAppearanceList)
end


return FashionEvaluationFittingVM