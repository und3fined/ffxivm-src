local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PWorldEntPolUtil = require("Game/PWorld/Entrance/Policy/PWorldEntPolUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local EstateInfoCfg = require("TableCfg/EstateInfoCfg")
local ProtoCS = require("Protocol/ProtoCS")
local UIBindableList = require("UI/UIBindableList")
local HouseLandPurchaseTheTermListItemVM = require("Game/House/VM/Item/HouseLandPurchaseTheTermListItemVM")
local LandBuyConditionCfg = require("TableCfg/LandBuyConditionCfg")

local HouseLandMianPanelVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR

function HouseLandMianPanelVM:Ctor()
    self.CurSelectTabIndex = 1

    ----------------House Start----------------
    self.HouseEntranceConf = {{
        Name = "个人房屋"
    }, {
        Name = "部队房屋"
    }, {
        Name = "共享房屋"
    }}
    ----------------House Start----------------
    ----------------Estate Start----------------
    self.PhaseCnt = 0 --当前期
    self.CurSelectPhase = 0
    self.LandHistroyList = UIBindableList.New(HouseLandPurchaseTheTermListItemVM)
    self.BuyStateInfoShow = nil -- 显示的购房状态信息
    self.CurBuyStateInfo = nil -- 当前期购房状态信息
    self.BuyInfoList = nil
    self.AllBuyConditions = {} -- 所有购房条件
    self.AllHouseOpConditions = {-- 房屋操作条件
        [HouseLocalDef.HouseOpType.Destory] = {
            [HouseLocalDef.HouseOpCondition.RecycleAll] = {
                IsPass = true,
                PassFunc = function(HouseID)
                    if HouseID then
                        local Cnt = _G.HousingMgr:GetOwnerHouseFurnitureCount(HouseID)
                        return Cnt == 0
                    else
                        return false
                    end
                end,
            },
            [HouseLocalDef.HouseOpCondition.EmptyDepot] = {
                IsPass = true,
                PassFunc = function(HouseID)
                    if HouseID then
                        local Cnt = _G.HousingMgr:GetOwnerDepotItemCount(HouseID)
                        return Cnt == 0
                    else
                        return false
                    end
                end,
            }
        },
        [HouseLocalDef.HouseOpType.GiveUpLand] = {
            [HouseLocalDef.HouseOpCondition.EmptyLand] = {
                IsPass = false,
                PassFunc = function(HouseID)
                    if HouseID then
                        return _G.HouseInfoMgr:IsCurHouseLandCanGiveUp(HouseID)
                    else
                        return false
                    end
                end
            }
        }
    }
    self.BuyConditionsByBelongType = {}
    self.CurBuyConditionsBelongType = 1
    self.CanApplyLand = false -- 是否可以申请土地   个人部队其中一个满足即可
    self.CanApplyLandArr = {false, false} -- 是否可以申请土地   个人、部队
    self.ConditionPassResultStr = {}
    self.LandSelectInfo = nil -- 参选信息(只是历史最新的选期信息 比如当前6 4参与过 就有4的信息)
    self.Discount = nil -- 抵扣数据
    self.ReturnInfo = nil -- 返还数据
    ----------------Estate End----------------
end

function HouseLandMianPanelVM:UpdateVM(Value, Param)
    local IsValid = nil ~= Value and Value.ResID ~= nil
end

----------------Estate Start----------------

function HouseLandMianPanelVM:SetBuyStatus(MsgBody)
    self.PhaseCnt = MsgBody.PhaseCnt or 0
    local PhaseID = (MsgBody.PhaseID == 0 or MsgBody.PhaseID == nil) and self.PhaseCnt or MsgBody.PhaseID
    self.BuyStateInfoShow = {
        PhaseID = MsgBody.PhaseID or 0,
        PhaseCnt = MsgBody.PhaseCnt or 1,
        Stage = MsgBody.Stage or 1,
        LeftTime = MsgBody.LeftTime or 3600,
        AplStatus = MsgBody.AplStatus or 1,
        BuildStatus = MsgBody.BuildStatus or 1,
        Results = MsgBody.Results or {},
        IsPersonJoin = MsgBody.GroupID == 0 and MsgBody.AplStatus > ProtoCS.ApplyStatus.ApplyStatus_NotApply,
        IsArmyJoin = MsgBody.GroupID ~= 0 and MsgBody.AplStatus > ProtoCS.ApplyStatus.ApplyStatus_NotApply
    }

    if PhaseID == self.PhaseCnt then
        self.CurBuyStateInfo = self.BuyStateInfoShow
        self.AllBuyConditions = self.CurBuyStateInfo.Results
        if self.AllBuyConditions[HouseLocalDef.HouseBuyCondSpecialID] then
            self.AllBuyConditions[HouseLocalDef.HouseBuyCondSpecialID].IsPass = true
        end
    end

    self:SetCurSelectPhase(PhaseID)
    self:SetCanApplyLand()
    local LandHistroyListTmp = {}
    for i = 1, self.PhaseCnt do
        local CurPhaseCnt = self.PhaseCnt + 1 - i
        table.insert(LandHistroyListTmp, {
            PhaseID = CurPhaseCnt,
            Name = string.format(LSTR("第%d期"), CurPhaseCnt),
            IsSelect = self.CurSelectPhase == CurPhaseCnt
        })
    end

    self.LandHistroyList:UpdateByValues(LandHistroyListTmp)
    local LandSelectInfo = {
        [1] = nil,
        [2] = nil
    }
    self.Discount = MsgBody.Discounts
    local PersonApply = MsgBody.LatestApply
    if PersonApply then
        LandSelectInfo[1] = PersonApply
        _G.HouseLandMgr:SendLandQueryArea(PersonApply.ResidenceNumber, PersonApply.AreaNumber, 0, 0, {PersonApply.LandNumber},
        HouseLocalDef.LandQuerySceneType.LandInfo)
    end

    local GroupApply = MsgBody.LatestGroupApply
    if GroupApply then
        LandSelectInfo[2] = GroupApply
        _G.HouseLandMgr:SendLandQueryArea(GroupApply.ResidenceNumber, GroupApply.AreaNumber, 0, 0, {GroupApply.LandNumber},
        HouseLocalDef.LandQuerySceneType.LandInfo)
    end

    local ReturnInfo = nil
    local SelectInfo = LandSelectInfo[HouseLocalDef.BuyHouseBelongType.Personal]
    if SelectInfo ~= nil and SelectInfo.ReturnMoney > 0 and SelectInfo.AplStatus ~=
        ProtoCS.ApplyStatus.ApplyStatus_Return then
        ReturnInfo = SelectInfo
    end
    self.ReturnInfo = ReturnInfo
    self.LandSelectInfo = LandSelectInfo
end

function HouseLandMianPanelVM:UpdateLandSelectInfo(Type, Data)
    if Type and Data then
        self.LandSelectInfo[Type] = Data
    end
end

function HouseLandMianPanelVM:GetBuyConditionByBelongType(BelongType)
    if BelongType == nil then
        BelongType = self.CurBuyConditionsBelongType or 1
    end

    local CfgData = LandBuyConditionCfg:FindAllCfgByBelongType(BelongType)
    self.BuyConditionsByBelongType[BelongType] = {}
    for i, v in ipairs(CfgData) do
        self.BuyConditionsByBelongType[BelongType][i] = v
    end

    if BelongType == HouseLocalDef.BuyHouseBelongType.Army and self.BuyConditionsByBelongType[BelongType] then
        local ConditionData = self.BuyConditionsByBelongType[BelongType] 
        if _G.HouseLandMgr:IsParticipatePersonalLandSelection(BelongType) then
            for i, v in ipairs(ConditionData) do
                if v.ID == HouseLocalDef.HouseBuyCondSpecialID then
                    local ResidenceNumber = self.LandSelectInfo[BelongType].ResidenceNumber
                    local AreaNumber = self.LandSelectInfo[BelongType].AreaNumber
                    local LandNumber = self.LandSelectInfo[BelongType].LandNumber
                    local EstateName = ""
                    local EstateInfo = EstateInfoCfg:FindCfgByKey(ResidenceNumber)
                    if EstateInfo then
                        EstateName = EstateInfo.EstateName
                    end

                    local RepleaceStr = string.format(HouseLocalDef.HouseBuyCondSpecialStr, EstateName, AreaNumber, LandNumber)
                    self.BuyConditionsByBelongType[BelongType][i].Desc = RepleaceStr
                    break
                end
            end
        end
    end

    return self.BuyConditionsByBelongType[BelongType] or {}
end

function HouseLandMianPanelVM:SetCurBuyConditionsBelongType(BelongType)
    self.CurBuyConditionsBelongType = BelongType or 1
end

function HouseLandMianPanelVM:GetBuyConditionPassResultStr(BelongType)
    if BelongType == nil then
        BelongType = HouseLocalDef.BuyHouseBelongType.Personal
    end
    if self.ConditionPassResultStr[BelongType] == nil then
        self:SetCanApplyLand()
    end
    return self.ConditionPassResultStr[BelongType], self.CanApplyLandArr[BelongType]
end

function HouseLandMianPanelVM:SetCanApplyLand()
    local Num = #HouseLocalDef.BuyHouseBelongTypeStr
    self.CanApplyLand = false
    for i = 1, Num do
        local BuyCondition = self:GetBuyConditionByBelongType(i)
        local PassCnt = 0
        for j = 1, #BuyCondition do
            if self:GetBuyConditionHasPass(BuyCondition[j].ID) then
                PassCnt = PassCnt + 1
            end
        end
        self.CanApplyLandArr[i] = false
        self.ConditionPassResultStr[i] = string.format("%d/%d", PassCnt, #BuyCondition)
        if PassCnt == #BuyCondition then
            self.CanApplyLand = true
            self.CanApplyLandArr[i] = true
        end
    end
end

function HouseLandMianPanelVM:GetBuyConditionHasPass(ConditionType)
    local Item = table.find_by_predicate(self.AllBuyConditions, function(item)
        return item.ConditionType == ConditionType
    end)
    return Item and Item.IsPass or false
end

function HouseLandMianPanelVM:GetDefaultTabIndex()
    if _G.HouseInfoMgr.MajorHouseID ~= 0 or _G.HouseInfoMgr.ArmyHouseID ~= 0 then
        return HouseLocalDef.HouseTabIndex.MyHouse
    else
        return HouseLocalDef.HouseTabIndex.LandBuy
    end
end

function HouseLandMianPanelVM:SetHouseOpCondition(HouseID)
    if not HouseID or HouseID == 0 then return end 
    for OpType, Conditions in ipairs(self.AllHouseOpConditions) do
        for CondType, v in ipairs(Conditions) do
            if v.PassFunc then
                self.AllHouseOpConditions[OpType][CondType].IsPass = v.PassFunc(HouseID)
            end
        end
    end
end

function HouseLandMianPanelVM:GetHouseOpConditionAllPass(HouseOpType, HouseID)
    self:SetHouseOpCondition(HouseID)
    local Info = self.AllHouseOpConditions[HouseOpType]
    if Info == nil then
        return true
    end

    local AllPass = true
    for i = 1, #Info do
        if Info[i].IsPass == false then
            AllPass = false
        end
    end

    return AllPass
end

function HouseLandMianPanelVM:GetEstateCfg()
    if self.EstateInfo ~= nil then
        return self.EstateInfo
    end
    self.EstateInfo = EstateInfoCfg:FindAllCfg() or {}
    return EstateInfoCfg:FindAllCfg() or {}
end

function HouseLandMianPanelVM:GetEstateInfo(ID)
    local Cfg = self:GetEstateCfg()
    local Info
    if Cfg then
        Info = Cfg[ID]
    end
    return Info
end

function HouseLandMianPanelVM.GetList()
    local ListData = {}
    -- for _, v in pairs(SettingsDefine.LanguagesDesc or {}) do
    -- 	table.insert(ListData, { Name = v.._ })
    -- end
    return ListData
end

function HouseLandMianPanelVM:GetEstateIsUnlock(ID)
    local estateInfo = self:GetEstateCfg()
    local UnLockTaskID = estateInfo[ID] and estateInfo[ID].UnLockTaskID or 0
    local isLock = UnLockTaskID and UnLockTaskID ~= 0 and not PWorldEntPolUtil.HasPreQuestFinish(UnLockTaskID)
    return not isLock
end

function HouseLandMianPanelVM:SetCurSelectPhase(Phase)
    -- 1参选状态 2抽选结果 3建造房屋
    local BuyInfoList = {}
    for i = 1, 4 do
        table.insert(BuyInfoList, {})
    end
    self.BuyInfoList = BuyInfoList
    self.CurSelectPhase = Phase or 0
end

function HouseLandMianPanelVM:SwitchSelectPhase(Phase)
    _G.HouseLandMgr:SendQueryBuyStatus(Phase)
end
----------------Estate End----------------

----------------HouseEntrance Start----------------

function HouseLandMianPanelVM:GetHouseEntranceIsUnlock(EntranceID)
    local isUnLock = true
    if EntranceID == 1 then
        if _G.HouseInfoMgr.MajorHouseID == 0 then
            isUnLock = false
        end
    elseif EntranceID == 2 then
        if _G.ArmyMgr:CheckIsArmyUnlockLevel() ~= true or _G.ArmyMgr:GetArmyID() == 0 or _G.ArmyMgr:GetArmyLevel() < 9  or _G.HouseInfoMgr.ArmyHouseID == 0 then  --目前部队只有8级 后续需要改成9级
            isUnLock = false
        end
    elseif EntranceID == 3 then
        isUnLock = true
    end
    return isUnLock
end

----------------HouseEntrance End----------------
return HouseLandMianPanelVM
