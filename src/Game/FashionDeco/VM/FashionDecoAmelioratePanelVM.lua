local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionDecoAmeliorateCfg = require("TableCfg/FashionDecoAmeliorateCfg")
local FashionDecorateCfg = require("TableCfg/FashionDecorateCfg")
local FashionDecoAmeliorateSlotVM = require("Game/FashionDeco/VM/FashionDecoAmeliorateSlotVM")
local FashionDecoAmeliorateTabItemVM = require("Game/FashionDeco/VM/FashionDecoAmeliorateTabItemVM")
local FashionDecoActionItemVM = require("Game/FashionDeco/VM/FashionDecoActionItemVM")
local UIBindableList = require("UI/UIBindableList")
local FashionDecoVM = require("Game/FashionDeco/VM/FashionDecoVM")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")


---@class FashionDecoAmelioratePanelVM : UIViewModel
local FashionDecoAmelioratePanelVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR
local MsgTipsUtil = _G.MsgTipsUtil

function FashionDecoAmelioratePanelVM:Ctor()
    self.SeriesList = {} --系列的列表 纯数据
    self.AmeliorateWingList = {} --本系列中改良的翅膀列表 纯数据

    self.SeriesBindableList = UIBindableList.New(FashionDecoAmeliorateTabItemVM) --系列的显示数据列表
    self.AmeliorateWingBindableList = UIBindableList.New(FashionDecoAmeliorateSlotVM) --本系列中改良的翅膀的显示数据列表
    self.ListActionItemListVM = UIBindableList.New(FashionDecoActionItemVM) --技能列表

    self.SeriesName = "" --主界面右上角系列的名字

    self.AttachType = nil
    self.bIsShowWeapon = false --是否显示武器
    self.bIsHoldWeapon = false --是否拔出武器
    self.bIsShowHat = true      --是否显示帽子
    self.bIsShowHatOrgan = false --头盔机关开关

    self.SelectSeriesType = 1 --选中的系列类型
    self.SelectAmeliorateWingId = 1 --选中的改良翅膀
    self.SelectAmeliorateWingData = {} --当前选中的翅膀的状态数据，里面参数含义在 FashionDecoAmelioratePanelVM:GetAmeliorateWingData
end

function FashionDecoAmelioratePanelVM:OnShutdown()
    self.ClearData()
end

function FashionDecoAmelioratePanelVM:ClearData()
    self.SeriesList = {} --系列的列表
    self.AmeliorateWingList = {} --本系列中改良的翅膀列表

    self.SeriesBindableList:Clear()
    self.AmeliorateWingBindableList:Clear()
    self.ListActionItemListVM:Clear()
end

--初始化改良界面默认数据
function FashionDecoAmelioratePanelVM:InitDefualtData(InSelectWingId)
    --初始化系列的数据-暂时取到第5类
    self.SeriesBindableList = self:ResetBindableList(self.SeriesBindableList,FashionDecoAmeliorateTabItemVM)
    local WingInitNum = FashionDecoDefine.DecoAmeliorateSeriesInitNum.Wing
    for i = 1, WingInitNum do
        local Cfg = FashionDecoAmeliorateCfg:FindCfg(string.format("SeriesType = %d", i))
        if Cfg then
            local Data = {}
            Data.SeriesType = Cfg.SeriesType
            Data.ImgItemIcon = Cfg.SeriesIcon --图标on --图标
            Data.IsSelect = false
            Data.IsShowRedDot = self:IsSeriesCanShowRedDot(Cfg.SeriesType)

            --判断第一个母体解锁后，此系列就算解锁了
            if Cfg.UpgradeType == 1 then
                Data.IsUnlocked = FashionDecoVM:IsUnlockedById(Cfg.ID)
            end
            table.insert(self.SeriesList, Data)
        end
    end
    self.SeriesBindableList:UpdateByValues(self.SeriesList, nil)

    --根据在时尚配饰界面传过来的翅膀ID取当前系列的数据
    local DefualtSelectWingId = self:GetDefualtSelectWingIdById(InSelectWingId)
    local Cfg = FashionDecoAmeliorateCfg:FindCfgByKey(DefualtSelectWingId)
    if Cfg then
        self:UpdateSelectedSeries(Cfg.SeriesType, DefualtSelectWingId)
        self:ChangeSeriesListSelect(Cfg.SeriesType)
    end
end

--更新选中系列的翅膀列表
---@SeriesType 选中的系列
---@SelectWingId 选中的翅膀ID
function FashionDecoAmelioratePanelVM:UpdateSelectedSeries(InSeriesType, InSelectWingId)
    self.SelectSeriesType = InSeriesType

    self.AmeliorateWingList = {}
    self.AmeliorateWingBindableList = self:ResetBindableList(self.AmeliorateWingBindableList,FashionDecoAmeliorateSlotVM)
    --更新右边本系列中所有的翅膀列表
    local EquipWingId = _G.FashionDecoMgr:GetCurrentEquip(FashionDecoDefine.FashionDecoType.Wing)
    local CfgList = FashionDecoAmeliorateCfg:FindAllCfg(string.format("SeriesType == %d", InSeriesType))
    table.sort(CfgList, function(A, B) return A.UpgradeType < B.UpgradeType end)
	for _, Cfg in pairs(CfgList) do
        if Cfg then
            self.SeriesName = Cfg.SeriesName
            local Data = {}
            Data.Id = Cfg.ID
            Data.SeriesType = InSeriesType
            Data.AmeliorateWingData = self:GetAmeliorateWingData(Cfg.ID)
            Data.LastName = Cfg.LastName
            local TempFashionDecorateCfg = FashionDecorateCfg:FindCfgByKey(Cfg.ID) --时尚配饰表
            if TempFashionDecorateCfg then
                Data.ImgItemIcon = TempFashionDecorateCfg.Icon --图标
            end
            Data.IsSelect = false
            Data.Cfg = Cfg
            table.insert(self.AmeliorateWingList, Data)
        end
	end
    self.AmeliorateWingBindableList:UpdateByValues(self.AmeliorateWingList, nil)

    self:UpdateSelectAmeliorateWingData(InSelectWingId)
end

--通过配饰改良界面传进来选中的翅膀，获取默认选中的翅膀
function FashionDecoAmelioratePanelVM:GetDefualtSelectWingIdById(InSelectWingId)
    local Cfg = FashionDecoAmeliorateCfg:FindCfgByKey(InSelectWingId)
    local TempSelectWingId = InSelectWingId
    --是否在配饰改良中有此选中的翅膀ID
    local CfgList = nil
    if Cfg then
        CfgList = FashionDecoAmeliorateCfg:FindAllCfg(string.format("SeriesType == %d", Cfg.SeriesType))
        table.sort(CfgList, function(A, B) return A.UpgradeType < B.UpgradeType end)
    else
        CfgList = FashionDecoAmeliorateCfg:FindAllCfg(string.format("SeriesType == 1"))
        table.sort(CfgList, function(A, B) return A.UpgradeType < B.UpgradeType end)
        TempSelectWingId = nil --如果改良表中不存在选中的翅膀，则传nil进云，让其默认选中改良系统中的翅膀
    end
    return self:GetDefualtSelectWingId(CfgList, TempSelectWingId)
end
--切换系列时，获取默认选中的翅膀
function FashionDecoAmelioratePanelVM:GetDefualtSelectWingIdBySeries(InSeriesType)
    local CfgList = FashionDecoAmeliorateCfg:FindAllCfg(string.format("SeriesType == %d", InSeriesType))
    return self:GetDefualtSelectWingId(CfgList, nil)
end
--获取翅膀升级改良列表中默认选中的翅膀
function FashionDecoAmelioratePanelVM:GetDefualtSelectWingId(CfgList, InSelectWingId)
    --判断母体解锁没
    local IsOwnedFirst = false
    local FirstId = nil
    for index, value in ipairs(CfgList) do
        if value.UpgradeType == 1 then
            IsOwnedFirst = FashionDecoVM:IsUnlockedById(value.ID)
            FirstId = value.ID
            break
        end
    end
    if not IsOwnedFirst then
       return FirstId
    end

    --判断上一个是否已解锁
    local bLastUnlocked = false 
    for index, value in ipairs(CfgList) do
        local bCurUnlockedById = FashionDecoVM:IsUnlockedById(value.ID)
        if bLastUnlocked and not bCurUnlockedById then
            return value.ID --上一个已解锁，当前没解锁，默认选中当前的这个
        end
        bLastUnlocked = bCurUnlockedById
    end
    --上面条件都不满足，默认选中第一个
    if InSelectWingId ~= nil then
        return InSelectWingId
    end
    return FirstId
end

--更新当前选中的翅膀
function FashionDecoAmelioratePanelVM:UpdateSelectAmeliorateWingData(InSelectAmeliorateWingId)
    self.SelectAmeliorateWingId = InSelectAmeliorateWingId
    local Cfg = FashionDecoAmeliorateCfg:FindCfgByKey(InSelectAmeliorateWingId)
    if Cfg == nil then
        return
    end

    --技能列表
    self.ListActionItemListVM = self:ResetBindableList(self.ListActionItemListVM, FashionDecoActionItemVM)
    local TempActionList = _G.FashionDecoMgr:GetActionListDataByID(InSelectAmeliorateWingId,FashionDecoActionItemVM)
    self.ListActionItemListVM:UpdateByValues(TempActionList)

    --改变选中翅膀效果
    self:ChangeAmeliorateWingListSelect(Cfg.UpgradeType, false)

    self.SelectAmeliorateWingData = self:GetAmeliorateWingData(InSelectAmeliorateWingId)
end

--当前配饰是否能改良升级(规则就是，比如ID 3后面还可升为4，而且3已解锁，但4未解锁，则3就显示可升级改良)
function FashionDecoAmelioratePanelVM:IsCanAmeliorate(InFashionDecorateID)
    local Cfg = FashionDecoAmeliorateCfg:FindCfgByKey(InFashionDecorateID)
    if Cfg ~= nil and Cfg.ImprovedID ~= nil and Cfg.ImprovedID ~= 0 then
        local DecorateUnlocked = FashionDecoVM:IsUnlockedById(InFashionDecorateID)
        local ImprovedUnlocked = FashionDecoVM:IsUnlockedById(Cfg.ImprovedID)
        return DecorateUnlocked and not ImprovedUnlocked
    end
    return false
end

--获取所传翅膀的相关改良状态的数据
function FashionDecoAmelioratePanelVM:GetAmeliorateWingData(InAmeliorateWingId)
    --说明：Data里面变量的含义
    -- Data.IsFirst = false --是否母体
    -- Data.IsOwnedFirst = false --是否拥有母体(已解锁）
	-- Data.IsOwnedLast = false --是否已拥有上一级(已解锁）
    -- Data.UpgradeLastId = nil --改良翅膀的上一级ID
    -- Data.IsBagEnoughCost = false --是否背包中材料足够
	-- Data.IsEquip = false --是否已装备(穿戴)
	-- Data.IsUnlock = false --是否已解锁

    local Data = {}
    local Cfg = FashionDecoAmeliorateCfg:FindCfgByKey(InAmeliorateWingId)
    if Cfg == nil then
        return Data
    end

    local AmeliorateCfgList = FashionDecoAmeliorateCfg:FindAllCfg(string.format("SeriesType == %d", Cfg.SeriesType))
    table.sort(AmeliorateCfgList, function(A, B) return A.UpgradeType < B.UpgradeType end)

    Data.IsFirst = Cfg.UpgradeType == 1
    --是否母体已解锁
    --是否已拥有上一级
    if Cfg.UpgradeType == 1 then
        --选中的是母体(第一个)
        Data.IsOwnedFirst = FashionDecoVM:IsUnlockedById(Cfg.ID)
        Data.IsOwnedLast = Data.IsOwnedFirst
        Data.UpgradeLastId = Cfg.ID
    else
        for index, value in ipairs(AmeliorateCfgList) do
            if value.UpgradeType == 1 then
                Data.IsOwnedFirst = FashionDecoVM:IsUnlockedById(value.ID)
                break
            end
        end
    
        for index, value in ipairs(AmeliorateCfgList) do
            if value.ImprovedID == InAmeliorateWingId then
                Data.UpgradeLastId = value.ID
                Data.IsOwnedLast = FashionDecoVM:IsUnlockedById(value.ID)
                break
            end
        end
    end

    --是否背包中材料足够
    if Cfg then
        local ItemNum = _G.BagMgr:GetItemNum(Cfg.CostID)
        Data.IsBagEnoughCost = ItemNum >= Cfg.CostNum
    end

    --是否已装备(穿戴)
    local EquipWingId = _G.FashionDecoMgr:GetCurrentEquip(FashionDecoDefine.FashionDecoType.Wing)
    Data.IsEquip = EquipWingId == InAmeliorateWingId
    
    --是否已解锁
    Data.IsUnlock = FashionDecoVM:IsUnlockedById(InAmeliorateWingId)
    return Data
end

--获取此(左侧)系列是否能显示红点(感叹号)
function FashionDecoAmelioratePanelVM:IsSeriesCanShowRedDot(InSeriesType)
    local IsShowRedDot = false
    local CfgList = FashionDecoAmeliorateCfg:FindAllCfg(string.format("SeriesType == %d", InSeriesType))
    for index, value in ipairs(CfgList) do
        local AmeliorateWingData = self:GetAmeliorateWingData(value.ID)
        if not AmeliorateWingData.IsUnlock and AmeliorateWingData.IsOwnedLast and AmeliorateWingData.IsBagEnoughCost then
            IsShowRedDot = true
            break
        end
    end
    return IsShowRedDot
end

---@type 变更系列列表中选中的索引
---@param Index number 
function FashionDecoAmelioratePanelVM:ChangeSeriesListSelect(Index)
	if Index == nil then
		for i = 1, self.SeriesBindableList:Length() do
			self.SeriesBindableList.Items[i]:OnSelectedChange(false)
		end
	else
        for i = 1, self.SeriesBindableList:Length() do
            if Index == i then
                self.SeriesBindableList.Items[i]:OnSelectedChange(true)
            else
                self.SeriesBindableList.Items[i]:OnSelectedChange(false)
            end
		end
	end
end

---@type 变更右边升级改良列表中选中的索引
---@param Index number 
function FashionDecoAmelioratePanelVM:ChangeAmeliorateWingListSelect(Index, IsClick)
	if Index == nil then
		for i = 1, self.AmeliorateWingBindableList:Length() do
			self.AmeliorateWingBindableList.Items[i]:OnSelectedChange(false)
		end
	else
        for i = 1, self.AmeliorateWingBindableList:Length() do
            if Index == i then
                self.AmeliorateWingBindableList.Items[i]:OnSelectedChange(true)
                if IsClick then
                    self.AmeliorateWingBindableList.Items[i]:OnClickItem(true)
                end
            else
                self.AmeliorateWingBindableList.Items[i]:OnSelectedChange(false)
                self.AmeliorateWingBindableList.Items[i]:OnClickItem(false)
            end
		end
	end
end

--更新左边系列列表的数据（目前仅红点、后面还可增加....）
function FashionDecoAmelioratePanelVM:UpdateSeriesListData()
    for i = 1, self.SeriesBindableList:Length() do
        local SeriesType = self.SeriesBindableList.Items[i].SeriesType
        local IsShowRedDot = self:IsSeriesCanShowRedDot(SeriesType)
        self.SeriesBindableList.Items[i]:OnShowRedDotChange(IsShowRedDot)
    end
end

--保存此翅膀的new类型红点
function FashionDecoAmelioratePanelVM:OnSaveSelectAneliorateItemRedDot(FashionDecorateId)
    for i = 1, self.AmeliorateWingBindableList:Length() do
        local Item = self.AmeliorateWingBindableList.Items[i]
        if Item and Item.Id == FashionDecorateId then
            self.AmeliorateWingBindableList.Items[i]:OnClickItem(true)
        end
    end
end

function FashionDecoAmelioratePanelVM:ClickCurrentAction(ItemData)
    if ItemData.ChangeState ~=nil and ItemData.ChangeState ~= false then
        _G.FashionDecoMgr:ReqChangeIdleAnim()
    else
        local result = _G.FashionDecoMgr:GetCurrentEquip(FashionDecoDefine.FashionDecoType.Wing)
        if result ~= nil and result >0 then
        else
            _G.FashionDecoMgr:PlaySkillAction(self.CurrentSelectedID,ItemData.ID)
            -- MsgTipsUtil.ShowTips(LSTR(1030019))--穿戴雨伞后方可使用
        end
    end
end

return FashionDecoAmelioratePanelVM