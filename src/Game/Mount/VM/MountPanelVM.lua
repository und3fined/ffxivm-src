local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

local MountVM = require("Game/Mount/VM/MountVM")
local MountSlotVM = require("Game/Mount/VM/MountSlotVM")
local MountFilterTipsVM = require("Game/Mount/VM/MountFilterTipsVM")

local RideCfg = require("TableCfg/RideCfg")

---@class MountPanelVM : UIViewModel
local MountPanelVM = LuaClass(UIViewModel)

local GetwayConfig = 
{
    [ProtoRes.RideGetWay.MainTask] = "主线任务",
    [ProtoRes.RideGetWay.Loot] = "副本掉落",
    [ProtoRes.RideGetWay.Achievement] = "成就奖励",
    [ProtoRes.RideGetWay.Shopping] = "商城道具",
    [ProtoRes.RideGetWay.PVP] = "PVP",
}
--2——重生之境 3——苍穹之禁城 4——红莲之狂潮 5——暗影之逆焰
local VersionConfig = 
{
    [1] = {Key = 2, Name = "重生之境"},
    [2] = {Key = 3, Name = "苍穹之禁城"},
    [3] = {Key = 4, Name = "红莲之狂潮"},
    [4] = {Key = 5, Name = "暗影之逆焰"},
}

local LikeFilterKey = 1
local UnLikeFilterKey = 2

function MountPanelVM:Ctor()
    self.ListSlotVM = nil
    self.IsShowFilter = false
    self.FilterItemList = nil
    self.IsSearch = false
    self.IsShowDetail = false
    self.IsInRide = false
    self.IsPanelCustomMadeVisible = false
    self.IsCustomMadeRedDotVisible = false
end

function MountPanelVM:UpdateData()
    self:UpdateMountList()
end

function MountPanelVM:Init()
    self.IsShowFilter = false
    self.IsSearch = false
    self.IsShowDetail = false
end

function MountPanelVM:IsShowMount(Mount, InName)
    local IsLike = MountVM:IsFlagSet(Mount.Flag, ProtoCS.MountFlagBitmap.MountFlagLike)
    local IsShowLike = MountVM:IsLikeFilterValue(LikeFilterKey)
    if (IsLike == true and IsShowLike == false) then return false end
    local IsShowUnLike = MountVM:IsLikeFilterValue(UnLikeFilterKey)
    if (IsLike == false and IsShowUnLike == false) then return false end
    local c_ride_cfg = RideCfg:FindCfgByKey(Mount.ResID)
    if c_ride_cfg == nil or c_ride_cfg.PackageName == "" then return false end
    local IsVersion = MountVM:IsVersionFilterValue(c_ride_cfg.OpenVersion)
    if IsVersion == false then return false end

    local GetwayList = c_ride_cfg.GetWay
    local bGetway = false
    for _,v in ipairs(GetwayList) do
        local IsGetway = MountVM:IsGetwayFilterValue(v)
        if IsGetway == true then
            bGetway = true
            break
        end
    end
    if bGetway == false then return false end

    if InName and string.len(InName) > 0 then
        -- 提审需求：模糊匹配改为精准匹配
        if c_ride_cfg.Name == InName then
        --if string.find(c_ride_cfg.Name, InName) ~= nil then
            return true
        end
        return false
    end

    return true
end

local function SortFunc(MountSlotVM1, MountSlotVM2)

    local NewAndCustomMadeValue1 = (MountSlotVM1.IsMountNew and MountSlotVM1.IsCustomMadeEnabled) and 1 or 0
    local NewAndCustomMadeValue2 = (MountSlotVM2.IsMountNew and MountSlotVM2.IsCustomMadeEnabled) and 1 or 0

    if NewAndCustomMadeValue1 ~= NewAndCustomMadeValue2 then
        return NewAndCustomMadeValue1 > NewAndCustomMadeValue2
    end

    local MountLike1 = MountSlotVM1.IsMountLike and 1 or 0
    local MountLike2 = MountSlotVM2.IsMountLike and 1 or 0
    if MountLike1 ~= MountLike2 then
        return MountLike1 > MountLike2
    end

    return MountSlotVM1.ResID < MountSlotVM2.ResID
end

function MountPanelVM:UpdateMountList(NameFilter, bCloseDetail)
    local MountList = MountVM.MountList
	if (MountList == nil) then return end
    local ListSlotVMp = {}
    for _, Mount in ipairs(MountList) do
        if self:IsShowMount(Mount, NameFilter) then
            local MountSlot = MountSlotVM.New()
            MountSlot:UpdateData(Mount)
            ListSlotVMp[#ListSlotVMp + 1] = MountSlot
        end
    end
    ---排序
    table.sort(ListSlotVMp, SortFunc)
    self.ListSlotVM = ListSlotVMp
    if bCloseDetail == true then
        self.IsShowDetail = false
    end
end

function MountPanelVM:Clear()
    self.ListSlotVM = {}
    self.IsShowFilter = false
	self.IsSearch = false
	self.IsInRide = false
	self.IsShowDetail = false
end

function MountPanelVM:UpdateCurMountList()
    for _, MountSlotVM in ipairs(self.ListSlotVM) do
        MountSlotVM:UpdateData()
    end
end

function MountPanelVM:GenFilterItemList(Index)
    local FilterItemList = {}
    --获得途径
    do
        local FilterTipsVM = MountFilterTipsVM.New()
        FilterTipsVM.IsTitle = true
        FilterTipsVM.TitleText = "筛选获得途径"
        FilterTipsVM.Key = 1
        FilterTipsVM:SetSelect(Index == FilterTipsVM.Key)
        FilterItemList[#FilterItemList + 1] = FilterTipsVM

        if FilterTipsVM.IsSelect then
            local Category = FilterTipsVM.Key
            for k = 0, ProtoRes.RideGetWay.Other - 1 do
                FilterTipsVM = MountFilterTipsVM.New()
                FilterTipsVM.IsTitle = false
                FilterTipsVM.TitleText = GetwayConfig[k]
                FilterTipsVM.Key = k
                FilterTipsVM.Category = Category
                FilterTipsVM.IsSelect = MountVM:IsGetwayFilterValue(k)
                FilterItemList[#FilterItemList + 1] = FilterTipsVM
            end
        end
    end

    --资料片
    do
        local FilterTipsVM = MountFilterTipsVM.New()
        FilterTipsVM.IsTitle = true
        FilterTipsVM.TitleText = "筛选资料片"
        FilterTipsVM.Key = 2
        FilterTipsVM:SetSelect(Index == FilterTipsVM.Key)
        FilterItemList[#FilterItemList + 1] = FilterTipsVM

        if FilterTipsVM.IsSelect then
            local Category = FilterTipsVM.Key
            for _,v in ipairs(VersionConfig) do
                FilterTipsVM = MountFilterTipsVM.New()
                FilterTipsVM.IsTitle = false
                FilterTipsVM.TitleText = v.Name
                FilterTipsVM.Key = v.Key
                FilterTipsVM.Category = Category
                FilterTipsVM.IsSelect = MountVM:IsVersionFilterValue(v.Key)
                FilterItemList[#FilterItemList + 1] = FilterTipsVM
            end
        end
    end
    --偏好
    do
        local FilterTipsVM = MountFilterTipsVM.New()
        FilterTipsVM.IsTitle = true
        FilterTipsVM.TitleText = "筛选偏好坐骑"
        FilterTipsVM.Key = 3
        FilterTipsVM:SetSelect(Index == FilterTipsVM.Key)
        FilterItemList[#FilterItemList + 1] = FilterTipsVM

        if FilterTipsVM.IsSelect then
            local Category = FilterTipsVM.Key
            FilterTipsVM = MountFilterTipsVM.New()
            FilterTipsVM.IsTitle = false
            FilterTipsVM.TitleText = "偏好坐骑"
            FilterTipsVM.Key = LikeFilterKey
            FilterTipsVM.Category = Category
            FilterTipsVM.IsSelect = MountVM:IsLikeFilterValue(FilterTipsVM.Key)
            FilterItemList[#FilterItemList + 1] = FilterTipsVM

            FilterTipsVM = MountFilterTipsVM.New()
            FilterTipsVM.IsTitle = false
            FilterTipsVM.TitleText = "非偏好坐骑"
            FilterTipsVM.Key = UnLikeFilterKey
            FilterTipsVM.Category = Category
            FilterTipsVM.IsSelect = MountVM:IsLikeFilterValue(FilterTipsVM.Key)
            FilterItemList[#FilterItemList + 1] = FilterTipsVM
        end
        
    end
    self.FilterItemList = FilterItemList
end

return MountPanelVM