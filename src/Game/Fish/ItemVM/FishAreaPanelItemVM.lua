local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local FishIconItemVM = require("Game/Fish/ItemVM/FishIconItemVM")
local FishLocationCfg = require("TableCfg/FishLocationCfg")
local FishCfg = require("TableCfg/FishCfg")
local FishNotesMgr = require("Game/FishNotes/FishNotesMgr")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local FishMgr = _G.FishMgr

local FishAreaNameUnLocked = "???"


---@class FishAreaPanelItemVM : UIViewModel
local FishAreaPanelItemVM = LuaClass(UIViewModel)

function FishAreaPanelItemVM:Ctor()
    self.FishAreaName = ""
    self.FishAreaID = 0
    self.FishAreaLocked = true

    self.FishItemList = UIBindableList.New(FishIconItemVM)
    self.ReleaseFishList = {}
    self.FishLockMap = {}
    self.FishIDCache = {}

    self.bShowPanel = true
    self.bHidePanel = false
    self.bFishLockInit = false -- 鱼类的解锁列表由FishNotesMgr负责管理中，且只有在打开过钓鱼笔记界面时才会初始化，这里不清楚是否已初始化，因此在此标记
    self.bFishAreaLockInit = false -- 渔场的解锁列表默认打开钓鱼笔记界面时才会初始化。这里不清楚是否已初始化，因此在此标记

    self.GameVersion = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION).Value -- 当前游戏版本号，判定渔场表内鱼类该版本是否解锁
    self.ClickedIndex = 0
end

function FishAreaPanelItemVM:SetFishAreaID(FishAreaID)
    rawset(self, "FishAreaID", FishAreaID)
    local LocationCfg = FishLocationCfg:FindCfgByKey(FishAreaID)
    if LocationCfg then
        -- 判断渔场是否已解锁
        --假如钓鱼笔记中的渔场解锁情况未初始化，则手动初始化
        if not self.bFishAreaLockInit then
            FishNotesMgr:SendMsgGetFishGroundList()
            FLOG_INFO("[Fish] SetFishAreaID FishNote not Init")
            return
        end
        local IsLocked = FishNotesMgr:CheckFishLocationbLock(FishAreaID)
        self.FishAreaLocked = IsLocked
        if not IsLocked then
            self.FishAreaName = LocationCfg.Name or "ERROR"
            FLOG_INFO("[Fish] SetFishAreaID FishAreaID %d , FishAreaName %s",FishAreaID, self.FishAreaName)
        else
            self.FishAreaName = FishAreaNameUnLocked
            FLOG_INFO("[Fish] SetFishAreaID FishAreaID %d is Locked",FishAreaID)
        end
        local FishIDs = LocationCfg.FishID
        local FishIsLocked = true
        self.FishIDCache = FishIDs
        self.FishItemList:Clear(false)
        if FishIDs then
            for i = 1, #FishIDs do
                local Cfg = FishCfg:FindCfgByKey(FishIDs[i])
                if Cfg then
                    -- 判定鱼是否在该版本已解锁
                    if UE.UVersionMgr.IsBelowOrEqualGameVersion(Cfg.VersionName) then
                        local Item = self.FishItemList:AddByValue({ResID = Cfg.ItemID, Num = 0, IsMask = true}, nil, false)
                        -- 由于Icon相关属性无法在ItemVM里Update，在此手动初始化
                        Item:UpdateIconVM(false, Cfg.Level)
                        -- 假如鱼类解锁情况已经初始化，则存储，未初始化则不存储
                        if self.bFishLockInit then
                            FishIsLocked = FishNotesMgr:CheckFishbUnLock(FishIDs[i])
                            self.FishLockMap[Cfg.ItemID] = FishIsLocked
                        end
                    end
                else
                    FLOG_WARNING("[Fish] FishID %d in FishArea %d not find", FishIDs[i] or 0, FishAreaID)
                end
            end
        end
        -- 假如钓鱼笔记中鱼类解锁情况未初始化，则手动初始化
        if not self.bFishLockInit then
            FishNotesMgr:SendMsgGetUnlockFishList()
        else
            self:UpdateFishListLocked()
        end
    end
end

-- 渔场解锁状态更新后更新渔场UI
function FishAreaPanelItemVM:UpdateFishAreaLockState(FishAreaID)
    self.bFishAreaLockInit = true
    -- 当渔场已解锁就不存在渔场解锁状态的更新了
    if self.FishAreaLocked == true then
        self:SetFishAreaID(FishAreaID)
    end
end

-- 等待鱼类解锁情况更新后，重新存储
function FishAreaPanelItemVM:InitFishLockMap()
    local FishIDs = self.FishIDCache
    local FishIsLocked = true
    for i = 1, #FishIDs do
        local Cfg = FishCfg:FindCfgByKey(FishIDs[i])
        if Cfg then
            FishIsLocked = FishNotesMgr:CheckFishbUnLock(FishIDs[i])
            self.FishLockMap[Cfg.ItemID] = FishIsLocked
        end
    end
    self.bFishLockInit = true
    self:UpdateFishListLocked()
end

function FishAreaPanelItemVM:SetFishSelected(index)
    local length = self.FishItemList:Length()
    self.ClickedIndex = index
    local ItemVM
    for i = 1 , length , 1 do
        ItemVM = self.FishItemList:Get(i)
        if i == index then
            ItemVM:SetSelected(true)
        else
            ItemVM:SetSelected(false)
        end
    end
end

function FishAreaPanelItemVM:SetFishUnSelected()
    local index = self.ClickedIndex
    if index ~= 0 then
        local ItemVM = self.FishItemList:Get(index)
        ItemVM:SetSelected(false)
        self.ClickedIndex = 0
    end
end

function FishAreaPanelItemVM:FindFishItemByFishID(FishID)
    local Cfg = FishCfg:FindCfgByKey(FishID)
	local ItemID = 0
	if FishID > 0 then
		ItemID = Cfg and Cfg.ItemID or 0
	end
    return self.FishItemList:Find(function ( ItemVM )
		return ItemVM.ResID == ItemID
	end)
end

function FishAreaPanelItemVM:OnFishLift(FishID,AddNum)
    local ItemVM = self:FindFishItemByFishID(FishID)
    if ItemVM then
        ItemVM:AddFishNum(AddNum)
    else
        FLOG_WARNING("FishAreaPanelItemVM:OnFishLift():Can not find FishItem by FishID = ".. FishID)
    end
end

function FishAreaPanelItemVM:OnShowPanel(bShowPanel)
    self.bShowPanel = bShowPanel
    self.bHidePanel = not bShowPanel
end

function FishAreaPanelItemVM:StorageReleaseFishData(FishID)
    local FishItem = self.FishItemList:Find(function(Item) return Item.ResID == FishID end)
    if self.ReleaseFishList[FishID] == 1 then
        self.ReleaseFishList[FishID] = nil
        if FishItem then
            FishItem:SetAutoRelease(false)
        end
    else
        self.ReleaseFishList[FishID] = 1
        if FishItem then
            FishItem:SetAutoRelease(true)
        end
    end
    FishMgr:SetFishReleaseList(self.ReleaseFishList)
end

function FishAreaPanelItemVM:ClearStorageReleaseFishData()
    local FishItem = nil
    for key, _ in pairs(self.ReleaseFishList) do
        FishItem = self.FishItemList:Find(function(Item) return Item.ResID == key end)
        if FishItem then
            FishItem:SetAutoRelease(false)
        end
    end
    self.ReleaseFishList = {}
    FishMgr:SetFishReleaseList(self.ReleaseFishList)
end

-- 判断是否是第一次钓到鱼
function FishAreaPanelItemVM:FishIsNew(FishID)
    local FishItemVM =  self:FindFishItemByFishID(FishID)
    if FishItemVM then
        return (tonumber(FishItemVM.Num) == 0)
    else
        --存在bug，利用FishID未能查到Item，具体原因未知
        FLOG_WARNING("FishAreaPanelItemVM:FishIsNew can not get FishItemVM FishID = "..FishID)
        return false
    end
end

-- 更新FishItemList中所有鱼的解锁状态
function FishAreaPanelItemVM:UpdateFishListLocked()
    local length = self.FishItemList:Length()
    local ItemVM
    local ItemID
    for i = 1 , length , 1 do
        ItemVM = self.FishItemList:Get(i)
        ItemID = ItemVM.ResID
        -- 假如渔场未解锁，则渔场中的所有的鱼均未解锁
        if self.FishAreaLocked == false and self.FishLockMap and self.FishLockMap[ItemID] == true then
            ItemVM:SetUnLock()
        else
            ItemVM:SetLocked()
        end
    end
    -- 由于前面时直接调用ItemVM中的方法，因此这里要手动更新一下
    self.FishItemList:OnUpdateList()
end

-- 版本号对比
function FishAreaPanelItemVM:IsCurVersionUnLock(FishVersion)
    local FishVersionTab = string.split(FishVersion, ".")
    local GameVersionTab = self.GameVersion

    if nil == FishVersionTab or #FishVersionTab < 3 then
        return true
    end

    for i = 1, #GameVersionTab do
        if GameVersionTab[i] > tonumber(FishVersionTab[i]) then
            return true
        elseif GameVersionTab[i] < tonumber(FishVersionTab[i]) then
            return false
        end
    end
    -- 版本号完全一致
    return true
end

return FishAreaPanelItemVM