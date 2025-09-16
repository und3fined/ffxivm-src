
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FishLocationCfg = require("TableCfg/FishLocationCfg")
local FishBaitCfg = require("TableCfg/FishBaitCfg")
local UIBindableList = require("UI/UIBindableList")
local FishItemVM = require("Game/Fish/FishItemVM")
local ItemVM = require("Game/Item/ItemVM")
local ItemDefine = require("Game/Item/ItemDefine")
local ItemSource = ItemDefine.ItemSource
local ItemCfg = require("TableCfg/ItemCfg")
local BagMgr = require("Game/Bag/BagMgr")
--local BagVM = require("Game/Bag/BagVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemUtil = require("Utils/ItemUtil")
local SaveKey = require("Define/SaveKey")
local FishBaitItemVM = require("Game/Fish/ItemVM/FishBaitItemVM")

local SaveMgr = _G.UE.USaveMgr

---@class FishVM : UIViewModel
local FishVM = LuaClass(UIViewModel)

function FishVM:Ctor()
	self.FishAreaID = nil
    self.FishAreaName = nil
    self.FishItemList = UIBindableList.New(FishItemVM)

    self.FishBaitItemList = UIBindableList.New(FishBaitItemVM, {Source = ItemSource.FishBait,SelcteStatus = ItemVM.SelcteStatus.Superposition})

    self.FishBackpackUseText = nil
    self.FishBackpackUseButton = nil

    self.ResID2BaitMap = {}
    self.FishBaitCfgCache = nil
end

function FishVM:OnInit()
end

function FishVM:OnBegin()
end

function FishVM:OnEnd()
end

function FishVM:OnShutdown()
end

function FishVM:SetFishAreaID(FishAreaID)
    if self.PlaceTipsAdapter ~= nil then
        self.PlaceTipsAdapter:CancelSelectedAll()
    end

    rawset(self, "FishAreaID", FishAreaID)
    self.FishItemList:Clear(false)
    local Cfg = FishLocationCfg:FindCfgByKey(FishAreaID)
    if Cfg then
        self.FishAreaName = Cfg.Name or "ERROR"
        local FishIDs = Cfg.FishID
        if FishIDs then
            for i = 1, #FishIDs do
                self.FishItemList:AddByValue({FishID = FishIDs[i], Index = i - 1}, nil, false)
            end
        end
    else
        self.FishAreaName = "ERROR"
    end
end

function FishVM:GetFishAreaID()
    return self.FishAreaID
end

function FishVM:GetFishAreaName()
    return self.FishAreaName
end

function FishVM:FindFishItemByPredicate(Predicate)
    if Predicate then
        return self.FishItemList:Find(Predicate)
    end
    return self.FishItemList
end


local function BaitItemFilter(Item)
    return ItemUtil.IsBaitItem(Item.ResID)
end

local function ToBagBaitItem(BagBaitItemList)
    local Num = 0
    local ResID = 0
    local GID = 0
    for _, value in pairs(BagBaitItemList) do
        Num = Num + value.Num
        ResID = value.ResID
        GID = value.GID
    end
    return {ResID = ResID, Num = Num, GID = GID, IsMask = false}
end

function FishVM:GetBaitList()
    local BaitList = FishBaitCfg:FindAllCfg()
    local BaitItemList = BagMgr:FilterItemByCondition(BaitItemFilter)
    local ResList = {}
    local BagBaitItemList = nil
    local Item = nil
    for _, value in pairs(BaitList) do
        if value.MoochFishID[1] == 0 then
            BagBaitItemList = table.find_all_by_predicate(BaitItemList,
            function(Element)
                return Element.ResID == value.ItemID
            end)
            if not table.empty(BagBaitItemList) then
                Item = ToBagBaitItem(BagBaitItemList)
            else
                Item = {ResID = value.ItemID, Num = 0, GID = 0, IsMask = true}
            end
            table.insert(ResList,Item)
        end
    end
    return ResList
end

function FishVM:GetSortedBaitItemlist()
    local BaitItemList = self:GetBaitList()

    -- 排序规则，首先根据鱼饵品级升序排序，品级相同则根据ResID升序排序,ResID相同则根据GID升序排序
    table.sort(BaitItemList,function(A, B)
        local CfgA = ItemCfg:FindCfgByKey(A.ResID)
        local CfgB = ItemCfg:FindCfgByKey(B.ResID)
        if CfgA.ItemLevel ~=  CfgB.ItemLevel then
            return CfgA.ItemLevel < CfgB.ItemLevel
        elseif A.ResID ~= B.ResID then
            return A.ResID < B.ResID
        end
    end )

    return BaitItemList
end


function FishVM:UpdateBaitItemVM()
    local BaitItemList = self:GetSortedBaitItemlist()
    
    self.FishBaitItemList:UpdateByValues(BaitItemList)
end

--根据鱼饵ID从鱼饵背包中查找该鱼饵,默认寻找数量最少的堆
function FishVM:FindBaitItemByBaitID(BaitID)
    if BaitID == nil then return nil end

    local Cfg = FishBaitCfg:FindCfgByKey(BaitID)
    if Cfg == nil then return nil end

    local BaitItemID = Cfg.ItemID
    local function FindBaitItemByItemID(InItemVM)
        return InItemVM.ResID == BaitItemID
    end

    -- 鱼饵背包改动后一个ID只可能存在一个鱼饵Item
    local Result = self.FishBaitItemList:Find(FindBaitItemByItemID)

    return Result

    -- local Result = self.FishBaitItemList:FindAll(FindBaitItemByItemID)
    -- if Result then
    --     local MinNum = 100 -- 最大堆叠数量为99
    --     local index = 1
    --     for i = 1, #Result do
    --         if MinNum > tonumber(Result[i].Num) then
    --             MinNum = tonumber(Result[i].Num)
    --             index = i
    --         end
    --     end
    --     return Result[index]
    -- end
    -- return nil
end

function FishVM:FindBaitIDByResID(ResID)
    local BaitID = self.ResID2BaitMap[ResID]
    if BaitID ~= nil then
        return BaitID
    end
    if self.FishBaitCfgCache == nil then
        self.FishBaitCfgCache = FishBaitCfg:FindAllCfg("true")
    end
    local AllCfg = self.FishBaitCfgCache or {}
    for key, value in pairs(AllCfg) do
        if value.ItemID == ResID --[[or value.HQItemID == ResID--]] then
            self.ResID2BaitMap[ResID] = key
            return key
        end
    end
    return 0
end

--根据鱼饵背包索引获取鱼饵ID
function FishVM:GetSelectedBait(Index)
    local BaitItem = self.FishBaitItemList:Get(Index)
    if BaitItem then
        local ResID = BaitItem.ResID
        return self:FindBaitIDByResID(ResID)
    end
    return 0
end

--从通用背包查找有效鱼饵
function FishVM:FindValidBaitID(BaitID)
    local BaitItemList = self:GetSortedBaitItemlist()
    local BaitItem = nil
    -- 首次获取鱼饵时ID为0，此时需要读取本地保存的数据
    if BaitID == 0 then
        local SaveKeyParam = SaveKey.SavedFishBaitID
        local SavedBaitID = SaveMgr.GetInt(SaveKeyParam,0,true)
        -- 判断保存的鱼饵背包里是否存在
        if SavedBaitID ~= 0 then
            local ResID = FishBaitCfg:FindValue(SavedBaitID, "ItemID")
            for _, value in ipairs(BaitItemList) do
                if value.ResID == ResID and value.Num ~= 0 then
                    return SavedBaitID, value
                end
            end
        end
    end
    -- 未获取到本地数据/指定鱼饵ID的情况
    local BaitResID = FishBaitCfg:FindValue(BaitID, "ItemID") or 0
    local bFirst = true
    local FirstBaitID = 0
    for _, value in ipairs(BaitItemList) do
        if bFirst and value.Num ~= 0 then
            bFirst = false
            FirstBaitID = self:FindBaitIDByResID(value.ResID)
            BaitItem = value
        end
        -- 未获取到本地数据默认模式使用鱼饵背包里第一个鱼饵
        if BaitResID == 0 and FirstBaitID ~= 0 then
            return FirstBaitID, BaitItem
        elseif value.ResID == BaitResID and value.Num ~= 0 then
            return BaitID, value
        end
    end


    return FirstBaitID, BaitItem
end

function FishVM:SetPlaceTipsTableViewAdapter(Adapter)
    self.PlaceTipsAdapter = Adapter
end

function FishVM:IsInFishReleaseList(InFishID)
    if self.PlaceTipsAdapter ~= nil then
        local SelectedIndex = self.PlaceTipsAdapter:GetSelectedIndex()
        for Key, _ in pairs(SelectedIndex) do
            local Data = self.PlaceTipsAdapter:GetItemDataByIndex(Key)
            if Data.FishID == InFishID then
                return true
            end
        end
        return false
    end
    FLOG_WARNING("[FishVM] PlaceTips Adapter is invalid")
    return false
end

function FishVM:GetFishBaitItemByResID(BaitID)
    local BaitItem = self:FindBaitItemByBaitID(BaitID)
    local BaitIndex = self:GetBaitItemIndex(BaitItem)
    if BaitItem then
        return BaitItem , BaitIndex
    else
        return self.FishBaitItemList:Get(1) , 1
    end
end

-- 修改鱼饵背包Item的使用状态
function FishVM:SetItemUseState(BaitID,bSelect)
    local BaitItem = self:FindBaitItemByBaitID(BaitID)
    if BaitItem then
        BaitItem:SetInUse(bSelect)
    else
        self.FishBaitItemList:Get(1):SetInUse(bSelect)
    end
end

-- 手动修改鱼饵背包Item的选中状态
function FishVM:SetItemSelected(Index ,bSelect)
    local BaitItem = self.FishBaitItemList:Get(Index)
    BaitItem:SetSelected(bSelect)
end

-- 获取鱼饵的限制等级
function FishVM:GetFishBaitLimitLevelByBaitID(BaitID)
    if BaitID == nil then 
        FLOG_WARNING("[FishVM] GetFishBaitLimitLevelByBaitID BaitID is nil")
        return 1 
    end
    local Cfg = FishBaitCfg:FindCfgByKey(BaitID)
    if Cfg == nil then 
        FLOG_WARNING("[FishVM] GetFishBaitLimitLevelByBaitID Cfg is nil ")
        return 1 
    end
    local Level = Cfg.Level
    if Level == nil then
        FLOG_WARNING("[FishVM] GetFishBaitLimitLevelByBaitID Level is nil ")
        return 1 
    end
    return Level
end

function FishVM:GetBaitItemIndex(Item)
   return self.FishBaitItemList:GetItemIndex(Item)
end

return FishVM