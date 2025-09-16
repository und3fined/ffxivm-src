local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

local MountVM = require("Game/Mount/VM/MountVM")
local MountSlotVM = require("Game/Mount/VM/MountSlotVM")
local MountFilterTipsVM = require("Game/Mount/VM/MountFilterTipsVM")
local BagDefine = require("Game/Bag/BagDefine")
local RideCfg = require("TableCfg/RideCfg")
local RideTextCfg = require("TableCfg/RideTextCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemGetaccesstypeCfg = require("TableCfg/ItemGetaccesstypeCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local TimeUtil = require("Utils/TimeUtil")
local GlobalCfg = require("TableCfg/GlobalCfg")
local UIBindableList = require("UI/UIBindableList")
local CommDropDownListItemNewVM = require("Game/Common/DropDownList/VM/CommDropDownListItemNewVM")
local LSTR = nil

---@class MountArchivePanelVM : UIViewModel
local MountArchivePanelVM = LuaClass(UIViewModel)

function MountArchivePanelVM:Ctor()
    LSTR = _G.LSTR
    self.ListSlotVM = nil
    self.IsShowFilter = false
    self.IsShowSkillTips = false
    self.GetWayFilterTypes = nil
    self.ShowGetWayFilter = {}
    self.IsSearch = false
    self.IsShowDetail = false
    self.AllMountList = nil
    self.ShowMountList = nil
    self.AllRideTable = nil
    self.IsShowRideNum = false
    self.IsShowID = false
    self.IsShowMessage = false
    self.TextOwnNubmber = "已拥有（-）"
    self.ListMountSlotMp = nil
    self.AllMountMp = nil
    self.TextShowName = ""
    self.TextShowMember = ""
    self.IsShowGridMount = true
    self.IsShowRowMount  = false
    self.TextSortType = "缩略图模式"
    self.IsOnlyShowOwned = false
    self.LastSelectMount = nil
    self.AttachType = nil
    self.IsShowPlayer = false
    self.IsShowExpository = false
    self.TextShowExpository = ""
    self.TextShowDesc = ""
    self.TextGetSource = ""
    self.IsShowShop = false
    self.TextShowID = ""
    self.IsShowPanelNone = false
    --self.IsShowPanelBtnBar = true
    --记录选中的
    self.SelectedMountID = nil
    self.SelectedMountIndex = nil
    self.RequestQueue = {}
    self.IsShowCommonBoard = false
    --版本屏蔽
    self.IsShowVersion = false
    -- 是否筛选结果为空
    self.IsSearchEmpty  = false
    self.IsSelectedOwned = false
    
    self.IsShowTextGetWay = false

    -- 剧情保护展示的问号
    self.IsShowNameImg = false

    -- 音效控制
    self.IsShowBGM = true

    -- 脚印图标
    self.MountTrackIcon = nil

    self.IsCustomMadeRedDotVisible = nil
    
    self.ActionTableList = nil
    self.DescribeTitle = ""
    self.ProportionText = ""
    self.ShowGetSourceText = false
    self.ResID = nil    --此ResID为接通用获取途径时调用的物品id,并非坐骑id（坐骑id请参见Mount.ResID）
    self.SkillTagList = nil
    self.IsShowImgMountType = false
    self.ShowBtnGo = true
    self.EmptyText = ""
    self.Source = BagDefine.ItemGetWaySource.Mount
    self.bShowActionBtn = false
    self.bShowPanelCustomMadeBtn = false    --滑板定制按钮
end

function MountArchivePanelVM:UpdateData()
    self:UpdateMountList()
end

function MountArchivePanelVM:GetAllMounts()
    if self.AllMountList ~= nil then return end
    local AllRideTable = {}
    AllRideTable = RideCfg:GetPackageCfg()

    local GMList = self.ShowAllMount    --GM命令
    if GMList == true then
        AllRideTable = RideCfg:FindAllCfg()
        print("[MountArchive]GM命令=",GMList)
    elseif table.is_array(GMList) then
        print("[MountArchive]GM命令=",GMList)
        for _, ID in pairs(GMList) do
            local IsInsert = true
            for _, v in pairs(AllRideTable) do
                if ID == v.ID then
                    IsInsert = false
                    break
                end
            end
            if IsInsert then
                local GMRideCfg = RideCfg:FindCfgByKey(ID)
                if GMRideCfg then
                    table.insert(AllRideTable, 1, GMRideCfg)  
                end
            end
        end
    end
    
    self.AllMountList = {}
    self.AllMountMp = {}
    local ServerTime = TimeUtil.GetServerTime()
    local VersGloCfg = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION)
    local VersG = VersGloCfg and VersGloCfg.Value or {2,0,0}
    for _,v in ipairs(AllRideTable) do
        local bOnLine = self:IsOnLine(ServerTime, v.OnTime)     --时间锁
        local bVersion = self:IsVersion(VersG, v.VersionName)   --版本锁

        if GMList == true then  --GM命令
            bOnLine = true
            bVersion = true
        elseif table.is_array(GMList) then
            if table.find_item(GMList, v.ID) then
                bOnLine = true
                bVersion = true
            end
        end

        if bOnLine and bVersion and (v.ID ~= nil) then
            local MountText = ""
            local MountTextCry = ""
            local c_RideText_Cfg = RideTextCfg:FindCfgByKey(v.ID)
            if  c_RideText_Cfg ~= nil then
                MountText = c_RideText_Cfg.Expository
                MountTextCry = c_RideText_Cfg.Cry
            end
            local GetAccess ={}
            local Cfg = ItemCfg:FindCfgByKey(v.ItemID)
            if Cfg then
                GetAccess = Cfg.Access
            end
            local Mount = {Flag = 0, LikeTime = 0, ResID = v.ID, Name = v.Name, SeatCount = v.SeatCount + 1, AccessGetList = GetAccess,
            SkeletonId = v.SkeletonId, PatternId = v.PatternId, ImeChanId = v.ImeChanId, IsStoryProtect = v.IsStoryProtect,
            MountExpository = MountText, MountCry = MountTextCry, ItemID = v.ItemID, ModelScaling = v.ModelScaling, MountTrack = v.MountTrack,
            RotationX = v.RotationX or 0, RotationY = v.RotationY or 0, RotationZ = v.RotationZ or 0, OffsetX = v.LocationX or 0, OffsetY = v.LocationY or 0, OffsetZ = v.LocationZ or 0, BgmID = v.MountBgm}
            table.insert(self.AllMountList, Mount)
            self.AllMountMp[Mount.ResID] = Mount
        end
    end
end

function MountArchivePanelVM:UpdateShowText(Mount)
    if Mount == nil then return end
    self.MountTrackIcon = Mount.MountTrack
    self.TextShowName = Mount.Name
    self.IsShowNameImg = false
    self.TextShowMember = Mount.SeatCount..LSTR(1090074)
    --细节面板文本显示
    self.TextShowExpository = Mount.MountExpository
    if self.TextShowExpository == nil or #self.TextShowExpository < 36 then
        self.TextShowExpository = "                                          "
    end
    self.DescribeTitle = LSTR(1090040)..self.TextShowName
    self.TextShowDesc = Mount.MountCry
    --编号
    self.TextShowID = string.format("%03d", Mount.ResID)
    --隐藏坐骑的文本显示和功能
    if (self.ListMountSlotMp == nil) then return end
    local MountSlot = self.ListMountSlotMp[Mount.ResID]
    if MountSlot.IsMountStory == 1 then
        self.IsShowImgMountType = false
        self.IsShowNameImg = true
        --self.TextShowMember = "?"
        self.TextShowExpository = LSTR(1090038)
        self.IsShowPanelNone = true
        --self.IsShowPanelBtnBar = false
        self.IsSelectedOwned = false
        if MountSlot.IsMountNotOwn == true then
        -- self.IsShowRideNum = false
        -- self.IsShowID = false
        end
        self.ShowBtnGo = false
    elseif MountSlot.IsMountNotOwn == true then
        self.IsShowPanelNone = false
        if string.isnilorempty(self.MountTrackIcon) then
            self.IsShowImgMountType = false
        else
            self.IsShowImgMountType = true
        end
        --self.IsShowPanelBtnBar = false
        -- self.IsShowRideNum = false
        -- self.IsShowID = false
        self.IsSelectedOwned = false
        self.ShowBtnGo = true
    else
        self.IsShowRideNum = true
        self.IsShowID = true
        self.IsShowPanelNone = false
        if string.isnilorempty(self.MountTrackIcon) then
            self.IsShowImgMountType = false
        else
            self.IsShowImgMountType = true
        end
        --self.IsShowPanelBtnBar = true
        self.IsSelectedOwned = true
        self.ShowBtnGo = true
    end
    self.ListMountSlotMp[Mount.ResID] = MountSlot
    -- 显示获得途径按钮
    self.ShowGetSourceText = false
    self.TextGetSource = ""
    self.ResID = Mount.ItemID or 0

    -- 显示滑板定制入口按钮
	local IsCustomized = _G.MountMgr:IsCustomMadeEnabled(Mount.ResID)
	if IsCustomized then
		if MountSlot.IsMountNotOwn then
			self.bShowPanelCustomMadeBtn = false
		else
			self.bShowPanelCustomMadeBtn = true
			self.ShowBtnGo = false
		end
	else
        self.bShowPanelCustomMadeBtn = false
    end
end

-- 更新列表方式，暂时不用
function MountArchivePanelVM:UpdateSlotItem(Mount)
    if Mount == nil then return end
    local MountSlot = self.ListMountSlotMp[Mount.ResID]
    if self.IsShowRowMount and MountSlot~= nil then
        --清除其他选项
        local LastMount = self.LastSelectMount
        if LastMount ~= nil and LastMount ~=Mount and self.ListMountSlotMp[LastMount.ResID] ~= nil then
            self.ListMountSlotMp[LastMount.ResID].IsSelect = false
        end
        MountSlot.IsSelect = false
        self.LastSelectMount = Mount
    end
    self.ListMountSlotMp[Mount.ResID] = MountSlot
end

function MountArchivePanelVM:SetShowMounts()
    if self.IsOnlyShowOwned == true then
        self.ShowMountList = self.ExistMountList
    else
        self.ShowMountList = self.AllMountList
    end
end

function MountArchivePanelVM:IsShowMount(Mount, InName)
    local c_ride_cfg = RideCfg:FindCfgByKey(Mount.ResID)
    if c_ride_cfg == nil then return false end
    local IsVersion = MountVM:IsVersionFilterValue(c_ride_cfg.OpenVersion)
    if IsVersion == false then return false end

    if self.IsShowFilter and not self.IsSearch then  --获取途径
        if Mount.AccessGetList and self.ShowGetWayFilter ~= {} then
            for _, AccessID in pairs(Mount.AccessGetList) do
                local AccessCfg = ItemGetaccesstypeCfg:FindCfgByKey(AccessID)
                if AccessCfg ~= nil and AccessCfg.FunType ~= nil then
                    return self.ShowGetWayFilter[AccessCfg.FunType] ~= nil
                end
            end
        end
        return false
    end

    if self.IsSearch then  --全局搜索
        if InName and string.len(InName) > 0 then
            -- 精确搜索-提审版本临时处理
            --if c_ride_cfg.Name == InName then
            --    return true
            --end
            -- 模糊搜索-提审版本临时处理
            if string.find(c_ride_cfg.Name, InName) ~= nil then 
                return true
            end
            return false
        end
    end
    
    return true
end

local function SortFunc(MountSlotVM1, MountSlotVM2)

    -- 新增排序
    --local NewValue1 = MountSlotVM1.IsMountNew and 1 or 0
    --local NewValue2 = MountSlotVM2.IsMountNew and 1 or 0

    --if NewValue1 ~= NewValue2 then
        --return NewValue1 > NewValue2
    --end

    -- 已有排序
    -- 提审版本特殊处理
    --local MountOwned1 = MountSlotVM1.IsMountNotOwn and 1 or 0
    --local MountOwned2 = MountSlotVM2.IsMountNotOwn and 1 or 0
    --if MountOwned1 ~= MountOwned2 then
        --return MountOwned1 < MountOwned2
    --end

    return MountSlotVM1.ResID < MountSlotVM2.ResID
end

function MountArchivePanelVM:UpdateMountList(NameFilter)
    if self.ShowMountList == nil then
        self.ShowMountList = self.AllMountList
        return
    end
    if MountVM.MountList == nil then
        return
    end
    --local MountList = MountVM.MountList
    local MountList = self.ShowMountList
	if (MountList == nil) then return end
    self.ListMountSlotMp = {}
    local ListSlotVMp = {}
    for _, Mount in ipairs(MountList) do
        if self:IsShowMount(Mount, NameFilter) then
            local SlotVM = MountSlotVM.New()
            --MountSlotVM:UpdateData(Mount)
            SlotVM:UpdateArchiveData(Mount)
            ListSlotVMp[#ListSlotVMp + 1] = SlotVM
            self.ListMountSlotMp[Mount.ResID] = SlotVM
        end
    end
    ---排序
    table.sort(ListSlotVMp, SortFunc)
    self.ListSlotVM = ListSlotVMp
    self.IsShowDetail = false
    
    self.ExistMountList = {}    -- 未拥有的坐骑
    for k, v in ipairs(self.AllMountList) do
        local _, NewIndex = _G.TableTools.FindTableElementByPredicate(MountVM.MountList, function(A)
            return A.ResID == v.ResID
        end)
        if not NewIndex then
            table.insert(self.ExistMountList, self.AllMountList[k])
        end
    end

    local MyNum = #self.AllMountList - #self.ExistMountList    --"已激活"
    local AllNum = #self.AllMountList   --"已收录"
    self.ProportionText = LSTR(1090041)..tostring(MyNum).."/"..tostring(AllNum)

    -- 查询结果是否为空
    if self.ListMountSlotMp == nil or table.size(self.ListMountSlotMp) == 0 then
        self.IsSearchEmpty = true

        if self.IsSearch then               --搜索中
            self.EmptyText = LSTR(1090034)  --"未搜索到..."
        elseif self.IsOnlyShowOwned then    --勾选未拥有
            self.EmptyText = LSTR(1090075)  --"已拥有当前版本全部坐骑"
        else
            self.EmptyText = LSTR(1090034)
        end
    else
        self.IsSearchEmpty = false
    end
    if self.IsSearchEmpty then
        self.bShowPanelCustomMadeBtn = false
        self.ShowBtnGo = false
        self.IsShowImgMountType = false
        self.bShowActionBtn = false
    end
end

-- 获取途径
function MountArchivePanelVM:UpdateFilterItemList()
    if self.RideGetWay == nil then
        self.RideGetWay = {}
        for i, Mount in ipairs(self.AllMountList) do
            for j, AccessID in pairs(Mount.AccessGetList or {}) do
                local AccessCfg = ItemGetaccesstypeCfg:FindCfgByKey(AccessID)
                if AccessCfg ~= nil then
                    local Name = ProtoEnumAlias.GetAlias(ProtoRes.ItemAccessFunType, AccessCfg.FunType)
                    if not self.RideGetWay[AccessCfg.FunType] then
                        self.RideGetWay[AccessCfg.FunType] = {ItemData = { FilterType = AccessCfg.FunType}, Name = Name}
                    end
                end
            end
        end
    end

    local FilterItemList = { { ItemData = { FilterType = 0 }, Name = LSTR(120016) }, }
    for FunType, Value in pairs(self.RideGetWay) do
        FilterItemList[#FilterItemList + 1] = Value
    end

    self.DownListVMList = UIBindableList.New(CommDropDownListItemNewVM)
    self.DownListVMList:UpdateByValues(FilterItemList)
    self.GetWayFilterTypes = FilterItemList
end

--- 判断坐骑可视性
function MountArchivePanelVM:IsMountVisible()
	local bShow = true
	if self.IsShowPanelNone == true then
		bShow = false
	elseif self.IsSearchEmpty == true then
		bShow = false
	elseif self.ShowMountList == nil then
		bShow = false
	elseif #self.ShowMountList == 0 then
		bShow = false
	end
	return bShow
end

--- 上线时间
function MountArchivePanelVM:IsOnLine(ServerTime, OnTime)
    if not string.isnilorempty(OnTime) then
        local OnTimeCfg = TimeUtil.GetTimeFromString(OnTime)
        if OnTimeCfg < ServerTime then
            return true
        end
    end
end

--- 版本号
function MountArchivePanelVM:IsVersion(VersGlobal, VersionName)
	local VeList = string.split(VersionName, ".")
    if nil == VeList or VeList[1] == nil then
        return false
    end
    for i = 1, #VeList, 1 do
        VeList[i] = tonumber(VeList[i])
    end
    if VersGlobal[1] > VeList[1] then      --若主版本直接满足则为true
        return true
    elseif VersGlobal[1] == VeList[1] then --若主版本可能满足，再判断次版本
        if VersGlobal[2] > VeList[2] then
            return true
        elseif VersGlobal[2] == VeList[2] then
            if VersGlobal[3] >= VeList[3] then
                return true
            end
        end
    end
end

return MountArchivePanelVM