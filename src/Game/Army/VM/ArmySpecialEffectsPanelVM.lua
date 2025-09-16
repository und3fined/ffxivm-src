---
--- Author: star
--- DateTime: 2024-06-04 16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local ArmySpecialEffectsUsedItemVM = require("Game/Army/ItemVM/ArmySpecialEffectsUsedItemVM")
local ArmySpecialEffectsGroupItemVM = require("Game/Army/ItemVM/ArmySpecialEffectsGroupItemVM")
local ArmySpecialEffectsGetItemVM = require("Game/Army/ItemVM/ArmySpecialEffectsGetItemVM")

local GroupBonusStateCfg = require("TableCfg/GroupBonusStateCfg")
local GroupBonusStateDataCfg = require("TableCfg/GroupBonusStateDataCfg")
local GroupBonusStateGroupShowDataCfg = require("TableCfg/GroupBonusStateGroupShowDataCfg")
local GroupBonusStateGroupCfg = require("TableCfg/GroupBonusStateGroupCfg")
local GroupUplevelpermissionCfg = require("TableCfg/GroupUplevelpermissionCfg")
local GroupReputationLevelCfg = require("TableCfg/GroupReputationLevelCfg")
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")
local RichTextUtil = require("Utils/RichTextUtil")

local TimeUtil = require("Utils/TimeUtil")
local ArmyMgr
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyUpLevelPerermissionType = ArmyDefine.ArmyUpLevelPerermissionType
local ProtoRes = require("Protocol/ProtoRes")

---@class ArmySpecialEffectsPanelVM : UIViewModel
---@field CurBonusStateGroupName string @当前特效名字
---@field CurBonusStateGroupDesc string @当前特效描述
---@field UsedBonusStateList string @正在使用的特效列表
---@field AllBonusStateGroupList string @特效组列表
---@field SelectedBonusStateList string @特效列表
local ArmySpecialEffectsPanelVM = LuaClass(UIViewModel)
--- todo 等全局配置表配置
local ArmyUsedBonusStateMaxNum
local ArmyBonusStateMaxNum
local AllBonusStateGroupCfg
local ArmyLevelPermissionCfg
local BonusStateGroupSort = function(A, B)
    if A.IsHave ~= B.IsHave then
        return A.IsHave
    else
        return A.ID < B.ID
    end
end

local UsedBonusStateSort = function(A, B)
    return A.Index < B.Index
end

local SelectedBonusStateSort = function(A, B)
    return A.Level < B.Level
end
---Ctor
function ArmySpecialEffectsPanelVM:Ctor()
    self.CurBonusStateGroupName = nil
    self.CurBonusStateGroupDesc = nil
    self.CurBonusStateGroup = nil
    self.CurBonusStateGroupSelectedIndex = nil
    self.UsedBonusStateList = nil
    self.AllBonusStateGroupList = nil
    self.SelectedBonusStateList = nil
    self.HaveStateNum = nil
    self.Ups = nil
    self.GainNum = nil
    self.SelectedUsedBonusState = nil
    self.BonusStateNumStr = nil
    self.BonusStateNum = nil
    self.GrandTypeIcon = nil
    self.GrandCompanyType = nil
    self.BGMaskColor = nil
    ---权限判定
    self.IsPremission = nil
    --self.AvailableLevel = nil
end

function ArmySpecialEffectsPanelVM:OnInit()
    ArmyMgr = require("Game/Army/ArmyMgr")
    self.UsedBonusStateList = UIBindableList.New(ArmySpecialEffectsUsedItemVM)
    self.AllBonusStateGroupList = UIBindableList.New(ArmySpecialEffectsGroupItemVM)
    self.SelectedBonusStateList = UIBindableList.New(ArmySpecialEffectsGetItemVM)
    AllBonusStateGroupCfg = GroupBonusStateGroupShowDataCfg:FindAllCfg()
    ArmyLevelPermissionCfg = GroupUplevelpermissionCfg:FindAllCfg()
    self.HaveStateNum = {}
    ArmyBonusStateMaxNum = ArmyMgr:GetArmyMaxBonusStatesNum() or 0
    ArmyUsedBonusStateMaxNum= ArmyMgr:GetArmyMaxUsedBonusStatesNum() or 0
    self.AvailableLevel = 0
    self.GrandCompanyType = 0
    self.BGMaskColor = "0000007f"
end

function ArmySpecialEffectsPanelVM:OnBegin()
end

function ArmySpecialEffectsPanelVM:OnEnd()
end

function ArmySpecialEffectsPanelVM:OnShutdown()
end

--- 设置界面信息
function ArmySpecialEffectsPanelVM:UpdateBonusStateData(BonusStateData)
    ---权限判定
    self.IsPremission = ArmyMgr:GetSelfIsHavePermisstion(ProtoRes.GroupPermissionType.GroupPermissionTypeBonusState)
    local BonusStateNum = ArmyMgr:GetArmyBonusStatesNum() or 0
    self.BonusStateNum = BonusStateNum
    -- LSTR string:特效持有数：
    local NumStr = LSTR(910175)
    self.BonusStateNumStr = string.format("%s %d/%d", NumStr, BonusStateNum, ArmyBonusStateMaxNum)
    self.Ups = BonusStateData.Ups
    local IDs = BonusStateData.IDs 
    self.Reputation = BonusStateData.Reputation
    ---todo 等待转表
    self.BonusStateDiscount = 0
    local Cfg
    if Cfg and self.Reputation then
        self.BonusStateDiscount = Cfg:FindCfgByKey(self.Reputation)
    end
    --- 获取当前可购买特效等级,配置表有配置解锁等级，看如果可购买等级和升级权限强相关，是否改为权限等级判断
    self.AvailableLevel = 0
    local ArmyLevel = ArmyMgr:GetArmyLevel()
    for _, Data in ipairs(ArmyLevelPermissionCfg) do
        if Data.Level <= ArmyLevel then
            if Data.Type == ArmyUpLevelPerermissionType.ArmySELevel then
                if Data.FuncLevel > self.AvailableLevel then
                    self.AvailableLevel = Data.FuncLevel
                end
            end
        end
    end
    --- 组装已有特效数据
    self.HaveStateNum = {}
    for _, ID in ipairs(IDs) do
        if self.HaveStateNum[ID] then
            self.HaveStateNum[ID] = self.HaveStateNum[ID] + 1
        else
            self.HaveStateNum[ID] = 1
        end
    end
    --- 组装所有部队特效组的数据并更新列表
    local AllBonusStateGroupData = {}
    for _, Cfg in ipairs(AllBonusStateGroupCfg) do
       if Cfg.IsShow == 1 then
            local BonusStateGroupItem = {}
            BonusStateGroupItem.ID = Cfg.ID
            BonusStateGroupItem.Name = Cfg.Name
            BonusStateGroupItem.Desc = Cfg.Desc
            BonusStateGroupItem.Icon = Cfg.Icon
            BonusStateGroupItem.States = {}
            BonusStateGroupItem.IsHave = false
            BonusStateGroupItem.IsSelected = false
            BonusStateGroupItem.Count = 0
            local GroupCommonData = GroupBonusStateGroupCfg:FindCfgByKey(BonusStateGroupItem.ID)
            for _, CommonGroupCfg in ipairs(GroupCommonData.States) do
                    local State = {}
                    State.ID = CommonGroupCfg.ID
                    State.Level = CommonGroupCfg.Level
                    State.IsHave = false
                    for _, ID in ipairs(IDs) do
                        if State.ID == ID then
                            State.IsHave = true
                            BonusStateGroupItem.IsHave = true
                            BonusStateGroupItem.Count = BonusStateGroupItem.Count + 1
                        end
                    end
                    table.insert(BonusStateGroupItem.States, State)
            end
            table.insert(AllBonusStateGroupData, BonusStateGroupItem)
        end
    end
    self.AllBonusStateGroupList:UpdateByValues(AllBonusStateGroupData, BonusStateGroupSort)
    if self.Ups then
        --- 组装使用中的部队特效的数据并更新列表
        local CurTime = TimeUtil.GetServerTime()
        local UsedBonusStateDataList = {}
        for Index = 1, ArmyUsedBonusStateMaxNum do
            local EmptyItem = {
                Index = Index,
                ID = -Index,
                IsEmpty = true,
                IsSelected = false,
            }
            table.insert(UsedBonusStateDataList, EmptyItem)
        end
        local DelIDs = {}
        for _, UsedState in ipairs(self.Ups) do
            local State = {}
            State.ID = UsedState.ID
            State.EndTime = UsedState.EndTime
            State.Index = UsedState.Index
            local Time = State.EndTime - CurTime
            if Time > 0 then
                State.Time = State.EndTime - CurTime
                local StateShowCfg = GroupBonusStateDataCfg:FindCfgByKey(State.ID)
                if StateShowCfg then
                    State.Name = StateShowCfg.EffectName
                    State.Desc = StateShowCfg.Desc
                end
                local ArmyStateCfg = GroupBonusStateCfg:FindCfgByKey(State.ID)
                if ArmyStateCfg then
                    State.Icon = ArmyStateCfg.Icon
                end
                -- local StateCfg = GroupBonusStateCfg:FindCfgByKey(State.ID)
                for _, GroupData in ipairs(AllBonusStateGroupData) do
                    for _, GroupState in ipairs(GroupData.States) do
                        if GroupState.ID == State.ID then
                            State.GroupID = GroupData.ID
                            UsedState.GroupID = GroupData.ID
                        end
                    end
                end
                --table.insert(UsedBonusStateDataList, State)
                UsedBonusStateDataList[State.Index] = State
            else
                table.insert(DelIDs, State.ID)
            end   
        end
        for _, DelID in ipairs(DelIDs) do
            ArmyMgr:DelArmyUsedBonusState(DelID)
        end
        ---有孔位设计，不在末尾填充空item
        --self:UpdateUsedBonusStateData(UsedBonusStateDataList)
        self.UsedBonusStateList:UpdateByValues(UsedBonusStateDataList, UsedBonusStateSort)
    end

    ---部队友好度关系
    self.Reputation = BonusStateData.Reputation or {Level = 1, Exp = 0}
    self:UpdateReputationData()

    ---进入界面无选中，默认选中第一个
    if self.CurBonusStateGroupSelectedIndex == nil then
        self:SetBonusStateGroupSelected(1)
    else
        if self.CurBonusStateGroup then
            self.CurBonusStateGroupSelectedIndex = nil
            local Items = self.AllBonusStateGroupList:GetItems()
            local SelectedID = self.CurBonusStateGroup.ID
            for Index, Item in ipairs(Items) do
                if SelectedID == Item.ID then
                    self:SetCurBonusStateGroupSelectedIndex(Index)
                    break
                end
            end
            if self.CurBonusStateGroupSelectedIndex then
                self:SetBonusStateGroupSelected(self.CurBonusStateGroupSelectedIndex)
            else
                self:SetBonusStateGroupSelected(1)
            end
        else
            self:SetBonusStateGroupSelected(1)
        end
    end
end

---更新关系数据
function ArmySpecialEffectsPanelVM:UpdateReputationData()
    local Level = self.Reputation.Level
    local Cfg = GroupReputationLevelCfg:FindCfgByKey(Level)
    self.SaleValue = 0
    if Cfg then
        self.ReputationText = Cfg.Text
        self.SaleValue =  Cfg.BonusStateDiscount ---百分制配置
        local SaleStr = ""
        if self.SaleValue ~= 0 then
            SaleStr = string.format("-%s%%", self.SaleValue)
            self.ReputationColor = Cfg.Color
            SaleStr = RichTextUtil.GetText(SaleStr, self.ReputationColor)
        end
        ---LSTR:特效折扣
        local SaleText = LSTR(910400)
        self.SaleText = string.format("%s %s", SaleText, SaleStr)
    end
    self.GrandCompanyType = ArmyMgr:GetArmyUnionType()
    local GrandCompanyDataCfg = GrandCompanyCfg:FindCfgByKey(self.GrandCompanyType)
    self.GrandFlagIcon = GrandCompanyDataCfg.EditIcon
    self.GrandCompanyName = GrandCompanyDataCfg.Name
end

--- 设置当前生效加成
function ArmySpecialEffectsPanelVM:UpdateUsedBonusStateData(UsedBonusStateDataList)
    ---生效特效列表数据处理
    if UsedBonusStateDataList then
        local UsedBonusStateNum = #UsedBonusStateDataList
        --- 大于最大限制报错
        if UsedBonusStateNum > ArmyUsedBonusStateMaxNum then
            print("ArmyError: UsedBonusStateNum > ArmyUsedBonusStateMaxNum")
            return
        elseif  UsedBonusStateNum == ArmyUsedBonusStateMaxNum then
            self.UsedBonusStateList:UpdateByValues(UsedBonusStateDataList, UsedBonusStateSort)
        else
            local TempListData = table.clone(UsedBonusStateDataList)
            self:AddEmptyData(ArmyUsedBonusStateMaxNum - UsedBonusStateNum, TempListData)
            self.UsedBonusStateList:UpdateByValues(TempListData, UsedBonusStateSort)
        end
    else
        local TempListData = {}
        self:AddEmptyData(ArmyUsedBonusStateMaxNum, TempListData)
        self.UsedBonusStateList:UpdateByValues(TempListData, UsedBonusStateSort)
    end

end

--- 填充使用特效的空Item
function ArmySpecialEffectsPanelVM:AddEmptyData(EmptyItemNum, DataList)
    if nil == DataList then
        return
    end
    for Index = 1, EmptyItemNum do
        local EmptyItemData = {
            ID = -Index,
            IsEmpty = true,
            IsSelected = false,
        }
        table.insert(DataList, EmptyItemData)
    end
end

---设置选中
function ArmySpecialEffectsPanelVM:SetBonusStateGroupSelected(Index)
    if self.CurBonusStateGroup then
        self.CurBonusStateGroup.IsSelected = false
    end
    self.CurBonusStateGroup = self.AllBonusStateGroupList:Get(Index)
    if self.CurBonusStateGroup == nil then
        return
    end
    self.CurBonusStateGroup.IsSelected = true
    self.CurBonusStateGroupName = self.CurBonusStateGroup.Name
    self.CurBonusStateGroupDesc = self.CurBonusStateGroup.Desc
    self.CurBonusStateGroupSelectedIndex = Index
    if self.SelectedUsedBonusState then
        if self.CurBonusStateGroup.ID ~= self.SelectedUsedBonusState.GroupID then
            self.SelectedUsedBonusState.IsSelected = false
            self.SelectedUsedBonusState = nil
        end
    end
    ---组装选中特效组列表数据
    local SelectedBonusStateDataList = {}
    --local ArmyLevel = ArmyMgr:GetArmyLevel()
    for _, State in ipairs(self.CurBonusStateGroup.States) do
        if State.ID and State.ID ~= 0 then
            local SelectedState = {}
            SelectedState.ID = State.ID
            SelectedState.Num = self.HaveStateNum[SelectedState.ID] or 0
            local StateDataCfg = GroupBonusStateDataCfg:FindCfgByKey(SelectedState.ID)
            if StateDataCfg then
                local GroupID = self.CurBonusStateGroup.ID
                SelectedState.Name = StateDataCfg.EffectName
                SelectedState.Desc = StateDataCfg.Desc
                --SelectedState.Icon = StateDataCfg.EffectIcon
                local StateCfg = GroupBonusStateCfg:FindCfgByKey(SelectedState.ID)
                if StateCfg then
                    local IsUsedType = false
                    local UpsNum = #self.Ups
                    SelectedState.Cost = StateCfg.Cost
                    SelectedState.Level = StateCfg.Level
                    SelectedState.Icon = StateCfg.Icon
                    SelectedState.GetType = StateCfg.GetType
                    SelectedState.IsUsed = false
                    SelectedState.UsedIndex = 0
                    SelectedState.SaleValue = self.SaleValue
                    for _, UsedData in ipairs(self.Ups) do
                        if UsedData.ID == SelectedState.ID then
                            SelectedState.IsUsed = true
                            SelectedState.UsedIndex = UsedData.Index
                            IsUsedType = true
                            break
                        elseif GroupID == UsedData.GroupID then
                            IsUsedType = true
                            break
                        end
                    end
                    SelectedState.IsPremission = self.IsPremission
                    local BonusStateNum = self.BonusStateNum or 0
                    SelectedState.bUsed =  SelectedState.Num > 0 and UpsNum < ArmyUsedBonusStateMaxNum and not IsUsedType
                    if self.AvailableLevel then
                        SelectedState.IsUnlock = SelectedState.Level <= self.AvailableLevel and SelectedState.GetType ~=  ArmyDefine.ArmyBonusStateGetType.UnOpen
                        if not SelectedState.IsUnlock then
                            for _, Data in ipairs(ArmyLevelPermissionCfg) do
                                if Data.Type == ArmyUpLevelPerermissionType.ArmySELevel then
                                    if Data.FuncLevel == SelectedState.Level then
                                        SelectedState.UnLockLv = Data.Level
                                    end
                                end
                            end
                        end
                    end
                    --SelectedState.BuyCallBack = self.BuyBonusState
                    table.insert(SelectedBonusStateDataList, SelectedState)
                end
            end
        end
    end
    self.SelectedBonusStateList:UpdateByValues(SelectedBonusStateDataList, SelectedBonusStateSort)
end

---设置生效特效选中
function ArmySpecialEffectsPanelVM:SetUsedBonusStateGroupSelected(Index, ItemData)
    if self.SelectedUsedBonusState then
        if self.SelectedUsedBonusState.ID == ItemData.ID then
            return
        end
        self.SelectedUsedBonusState.IsSelected = false
    end
    self.SelectedUsedBonusState = ItemData
    self.SelectedUsedBonusState.IsSelected = true
    local Items = self.AllBonusStateGroupList:GetItems()
    local SelectIndex
    if self.SelectedUsedBonusState.GroupID then
        for Index, GroupData in ipairs(Items) do
            if GroupData.ID == self.SelectedUsedBonusState.GroupID then
                SelectIndex = Index
            end
        end
    else
        for Index, GroupData in ipairs(Items) do
            for _, GroupState in ipairs(GroupData.States) do
                if GroupState.ID == self.SelectedUsedBonusState.ID then
                    self.SelectedUsedBonusState.GroupID = GroupData.ID
                    SelectIndex = Index
                end
            end
        end
    end
    if SelectIndex then
        self:SetBonusStateGroupSelected(SelectIndex)
    end
end

--- 主要用于退出界面置空
function ArmySpecialEffectsPanelVM:SetCurBonusStateGroupSelectedIndex(Index)
    self.CurBonusStateGroupSelectedIndex = Index
end

--- 更新战绩
function ArmySpecialEffectsPanelVM:UpdateArmyGainNum(GainNum)
    self.GainNum = self:FormatNumber(GainNum)
end

function ArmySpecialEffectsPanelVM:FormatNumber(Number)
    
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

function ArmySpecialEffectsPanelVM:SetGrandTypeIcon(Type)
    self.GrandCompanyType = Type
    self.GrandTypeIcon = ArmyDefine.UnitedArmyTabs[Type].BigBGIcon
    self.BGMaskColor = ArmyDefine.UnitedArmyTabs[Type].MaskColor
end

function ArmySpecialEffectsPanelVM:GetSaleValue()
    return self.SaleValue
end

function ArmySpecialEffectsPanelVM:GetReputationTipsData()
    local ReputationTipsText = string.format(LSTR(910376), self.ReputationText)
	ReputationTipsText = RichTextUtil.GetText(ReputationTipsText, self.ReputationColor)
    local IconStr = RichTextUtil.GetTexture(self.GrandFlagIcon, 42, 47, -16)
    local Title = string.format("%s %s %s", IconStr, self.GrandCompanyName, ReputationTipsText)
    local Content
    self.SaleValue = self.SaleValue or 0
    if self.SaleValue == 0 then
        ---LSTR:友好关系提升后，购买部队特效可获得折扣。
        Content = LSTR(910402)
    else
        local SaleStr = string.format("-%s%%", self.SaleValue)
        SaleStr = RichTextUtil.GetText(SaleStr, self.ReputationColor)
        ---LSTR:\n当前关系可获得%s折扣。显示价格为折后价
        local Str = string.format(LSTR(910409), SaleStr)
        Content = string.format("%s%s",LSTR(910402), Str)
    end
    local Data =  {
        Title = Title,
        Content = Content,
    }
    return Data
end

return ArmySpecialEffectsPanelVM
