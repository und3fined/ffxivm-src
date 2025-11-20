local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local HouseLandListWinItemVM = require("Game/House/VM/Item/HouseLandListWinItemVM")
local UIBindableList = require("UI/UIBindableList")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")

local HouseLandListWinViewVM = LuaClass(UIViewModel)

function HouseLandListWinViewVM:Ctor()
    self.LandVMList = UIBindableList.New(HouseLandListWinItemVM)
    self.CurSelectLandSizeTab = ProtoRes.LandSizeType.LandSizeType_Min
    self.CurSelectBuyTypeTab = ProtoRes.LandBuyType.LandBuyType_Min
    self.CurSelectLandStatuTab = 1
    self.EmptyVisible = nil
    self.ResidenceNumber = 1
    self.AreaNumber = 1
    self.SubAreaNumber = 1
end

function HouseLandListWinViewVM:UpdateVM()
    self.LandVMList:EmptyItems()
    local LandListSrc = _G.HouseLandMgr.CurLandListData.LandListHandleData
    local DataLandStatu = _G.HouseLandMgr.CurLandListData.LandStatus
    local CurSelectStatu = HouseLocalDef.LandStateTabList[self.CurSelectLandStatuTab].LandStatu
    if LandListSrc == nil or DataLandStatu ~= CurSelectStatu then
        return
    end

    -- 稳定排序
    table.sort(LandListSrc, function(A, B)
        local LandStatusA = A.LandStatus == 2 and 1 or (A.LandStatus == 1 and 2 or A.LandStatus)
        local LandStatusB = B.LandStatus == 2 and 1 or (B.LandStatus == 1 and 2 or B.LandStatus)
        if LandStatusA == LandStatusB then
            return A.LandNumber < B.LandNumber
        else
            return LandStatusA < LandStatusB
        end
    end)

    local LandList = table.find_all_by_predicate(LandListSrc, function(item)
        item.WidgetClassIndex = 1
        item.AreaNumber = _G.HouseLandMgr.CurLandListData.AreaNumber
        item.ResidenceNumber = _G.HouseLandMgr.CurLandListData.ResidenceNumber
        local ItemBuyCond = item.BuyType == self.CurSelectBuyTypeTab or self.CurSelectBuyTypeTab == ProtoRes.LandBuyType.LandBuyType_Min
            or item.BuyType == ProtoRes.LandBuyType.LandBuyType_All  ---- 购买类型
        local result = (ItemBuyCond) and   ---- 购买类型
            (item.LandSize == self.CurSelectLandSizeTab or self.CurSelectLandSizeTab == ProtoRes.LandSizeType.LandSizeType_Min) ----- 房屋大小
            and ((item.LandStatus == CurSelectStatu or (CurSelectStatu == ProtoCS.LandStatusType.LandStatusType_Min and 
            self.CurSelectLandStatuTab == 1) or (self.CurSelectLandStatuTab == 5 and item.IsCollect))
            and item.HouseID == 0
            )
        return result
    end)

    if LandList and next(LandList) then
        self.EmptyVisible = false
    else
        self.EmptyVisible = true
    end

    local PhaseItem = {
        WidgetClassIndex = 0,
        LandStatu = CurSelectStatu,
        ReadyEndTime = _G.HouseLandMgr.CurLandListData.ReadyEndTime,
        PhaseEndTime = _G.HouseLandMgr.CurLandListData.PhaseEndTime
    }

    if self.CurSelectLandStatuTab == 1 or self.CurSelectLandStatuTab == 5 then
        local SaleIndex = nil
        local ReadyIndex = nil
        local PublicIndex = nil
        for i, p in ipairs(LandList) do
            if SaleIndex == nil and p.LandStatus == ProtoCS.LandStatusType.LandStatusType_Sale then
                SaleIndex = i
                PhaseItem.LandStatu = ProtoCS.LandStatusType.LandStatusType_Sale
                table.insert(LandList, SaleIndex, PhaseItem)
            end
            if ReadyIndex == nil and p.LandStatus == ProtoCS.LandStatusType.LandStatusType_Ready then
                ReadyIndex = i
                PhaseItem.LandStatu = ProtoCS.LandStatusType.LandStatusType_Ready
                table.insert(LandList, ReadyIndex, PhaseItem)
            end
            if PublicIndex == nil and p.LandStatus == ProtoCS.LandStatusType.LandStatusType_Public then
                PublicIndex = i
                PhaseItem.LandStatu = ProtoCS.LandStatusType.LandStatusType_Public
                table.insert(LandList, PublicIndex, PhaseItem)
            end
        end
    else
        table.insert(LandList, 1, PhaseItem)
    end

    if not self.EmptyVisible then
        self.LandVMList:UpdateByValues(LandList)
    else
        self.LandVMList:UpdateByValues({})
    end
end

function HouseLandListWinViewVM:SetTabIndex(Type, Index)
    if Type == 1 then
        self.CurSelectBuyTypeTab = Index - 1
    elseif Type == 2 then
        self.CurSelectLandSizeTab = Index - 1
    end
    self:UpdateVM()
end

function HouseLandListWinViewVM:SetLandStatuTabIndex(Index, LandStatu)
    self.CurSelectLandStatuTab = Index
    _G.HouseLandMgr:SendLandQueryArea(self.ResidenceNumber, self.AreaNumber, self.SubAreaNumber, LandStatu, {}, HouseLocalDef.LandQuerySceneType.LandList)
end

return HouseLandListWinViewVM
