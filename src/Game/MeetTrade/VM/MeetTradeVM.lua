local LuaClass = require("Core/LuaClass")
local MeetTradeItemVM = require("Game/MeetTrade/VM/MeetTradeItemVM")
local UIViewModel = require("UI/UIViewModel")
local UIBindableBagSlotList = require("Game/NewBag/VM/UIBindableBagSlotList")
local ScoreMgr = require("Game/Score/ScoreMgr")
local BagMgr = require("Game/Bag/BagMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
---@class MeetTradeVM : UIViewModel
local MeetTradeVM = LuaClass(UIViewModel)

---Ctor
function MeetTradeVM:Ctor()

end
	
function MeetTradeVM:OnInit()
    ---我方交易列表
    self.MajorTradeItemVMList = UIBindableBagSlotList.New(MeetTradeItemVM, {OtherInfomation = false})
    ---对方交易列表
    self.RoleTradeItemVMList = UIBindableBagSlotList.New(MeetTradeItemVM, {OtherInfomation = true})
    ---用于构建和全量更新我方交易列表的参数
    self.MajorTradeItemListParams	= {}
    ---用于构建和全量更新对方交易列表的参数
    self.RoleTradeItemListParams	= {}
    self:ResetVMInfo()
    self:SetParams()
end

function MeetTradeVM:Reset()
    ---用于构建和全量更新我方交易列表的参数
    table.clear(self.MajorTradeItemListParams)
    ---用于构建和全量更新对方交易列表的参数
    table.clear(self.RoleTradeItemListParams)
    ---我方交易列表
    if nil ~= self.MajorTradeItemVMList then
        self.MajorTradeItemVMList:FreeAllItems()
    end
    ---对方交易列表
    if nil ~= self.RoleTradeItemVMList then
        self.RoleTradeItemVMList:FreeAllItems()
    end
    self:SetParams()
end

--设置除列表以外的参数
function MeetTradeVM:SetParams()
    ---我方交易的金币数量
    self.MajorGoldForTrade = 0
    ---对方交易的金币数量
    self.RoleGoldForTrade = 0
    ---我方显示的交易税
    self.MajorGoldTax = 0
    ---交易金币的选中是否可见
    self.GlodNumForTradeVisible = false
    --- 面对面交易的格子数量
    --- TODO 读表还是直接写死比较好
    self.Capacity = 15
    self.EmptyItemCache = {}
    self.IsLock = false
end

---角色相关信息要在界面关闭时清空，不能在界面show时清空，因为绑定在OnShow之前
function MeetTradeVM:ResetVMInfo()
    ---主角自身的VM
    self.MajorVM = nil
    ---对方角色的VM
    self.RoleVM = nil
    ---我方的RoleID
    self.MajorID = nil
    ---对方的RoleID
    self.RoleID = nil
end
---根据月卡状态设置交易税率
function MeetTradeVM:SetTradeTaxRate(TaxRate)
    if not TaxRate then
        return
    end
    if TaxRate <0.14 then
        self.MajorGoldTaxRate = 0.1
        self.MajorGoldTaxRateText = string.format(LSTR(1490003), RichTextUtil.GetText("10%","#d1ba8e"))
    elseif TaxRate >0.14 then
        self.MajorGoldTaxRate = 0.15
        self.MajorGoldTaxRateText = string.format(LSTR(1490003), "15%")
    end
end

function MeetTradeVM:OnBegin()
end

function MeetTradeVM:OnEnd()

end

function MeetTradeVM:SetRoleID(RoleID)
    self.RoleID = RoleID
end

function MeetTradeVM:SetMajorID(MajorID)
    self.MajorID = MajorID
end

function MeetTradeVM:UpdateRoleInfo(RoleVM)
    self.RoleVM = RoleVM
    self:SetRoleID(RoleVM.RoleID)
end

function MeetTradeVM:UpdateMajorInfo(MajorVM)
    self.MajorVM = MajorVM
    self:SetMajorID(MajorVM.RoleID)
end
function MeetTradeVM:GetRoleVM()
    return self.RoleVM
end
function MeetTradeVM:GetMajorVM()
    return self.MajorVM
end
--- 初始化用
function MeetTradeVM:UpdateMajorTradeItemListInfo(Items)
    if(nil ~= Items and #Items > self.Capacity) then
        FLOG_ERROR("MeetTradeVM:MajorTradeItemVMList capacity is %d, but Items count is %d", self.Capacity, #Items)
        return
    end
    local ItemList = Items or {}
    --- 在第一个空ItemList后添加设置“+”显示
    if(#ItemList < self.Capacity) then
        local Index = #ItemList + 1
        ItemList[Index] = {ImgAddOpacity = 1}
    end
	ItemList = self:FillCapacityByEmptyItem(ItemList)
    for i, v in ipairs(ItemList) do
        v.BtnAddVisible = true
        v.Index = i
    end
	self.MajorTradeItemVMList:UpdateByValues(ItemList)
end

---初始化用
function MeetTradeVM:UpdateRoleTradeItemListInfo(Items)
    if(nil ~= Items and #Items > self.Capacity) then
        FLOG_ERROR("MeetTradeVM:RoleTradeItemVMList capacity is %d, but Items count is %d", self.Capacity, #Items)
        return
    end
    local ItemList = Items or {}
    ItemList = self:FillCapacityByEmptyItem(ItemList)
    for _, v in ipairs(ItemList) do
        v.BtnAddVisible = false
    end
    self.RoleTradeItemVMList:UpdateByValues(ItemList)
end

function MeetTradeVM:FillCapacityByEmptyItem(ItemList)
	local ResultList = ItemList or {}
	local ItemLen = #ResultList
	for i = 1, self.Capacity - ItemLen do
		ResultList[ItemLen + i] = self.EmptyItemCache
	end
	return ResultList
end

function MeetTradeVM:SendMajorGoldNumForTrade(NewNum)
    if NewNum >= 0 and NewNum <= self:GetMajorMaxGoldNumForTrade() then
        self:SetMajorGoldNumForTrade(NewNum)
        --- 向服务器上报ItemList
        local SendParams = {}
        local Params = self.MajorTradeItemListParams
        for i = 1, #Params do
            local ItemParam = {
                GID = Params[i].GID,
                ResID = Params[i].ResID,
                Num = Params[i].Num,
            }
            if nil ~= ItemParam then
                table.insert(SendParams, ItemParam)
            end
        end
        _G.MeetTradeMgr:SendMeetTradePlaceItem(SendParams,NewNum)
    end
end

function MeetTradeVM:SetMajorGoldNumForTrade(NewNum)
	self.MajorGoldForTrade = NewNum
    self.MajorGoldTax = math.floor(self.MajorGoldForTrade * self.MajorGoldTaxRate)
end

function MeetTradeVM:SetRoleGoldNumForTrade(NewNum)
    self.RoleGoldForTrade = NewNum
end

function MeetTradeVM:GetMajorCurrentGoldNumForTrade()
    return self.MajorGoldForTrade
end

function MeetTradeVM:GetRoleCurrentGoldNumForTrade()
    return self.RoleGoldForTrade
end

function MeetTradeVM:GetMajorMaxGoldNumForTrade()
    return ScoreMgr:GetScoreValueByID(BagMgr.RecoveryScoreID)
end

function MeetTradeVM:GetMajorGoldTax()
    return self.MajorGoldTax
end

function MeetTradeVM:UpdateMajorTradeItemList(Params)
    local CreateParams = {}
    local GoldNumCheck = false
    self.MajorTradeItemListParams = {}
    for i = 1, #Params do
        local ItemParam = self:GetTradeItemListParams(Params[i])
        if nil ~= ItemParam then
            if ItemParam.ResID == _G.BagMgr.RecoveryScoreID then --表示金币
               self:SetMajorGoldNumForTrade(ItemParam.Num)
               GoldNumCheck = true
            else
                table.insert(CreateParams, ItemParam)
                table.insert(self.MajorTradeItemListParams, ItemParam)
            end
        end
    end
    if GoldNumCheck == false then
        self:SetMajorGoldNumForTrade(0)
    end
    self:UpdateMajorTradeItemListInfo(CreateParams)
end

function MeetTradeVM:UpdateRoleTradeItemListParams(Params)
    local CreateParams = {}
    local GoldNumCheck = false
    self.RoleTradeItemListParams = {}
    for i = 1, #Params do
        local ItemParam = self:GetTradeItemListParams(Params[i])
        if nil ~= ItemParam then
            if ItemParam.ResID == _G.BagMgr.RecoveryScoreID then --表示金币
               self:SetRoleGoldNumForTrade(ItemParam.Num)
               GoldNumCheck = true
            else
                table.insert(CreateParams, ItemParam)
                table.insert(self.RoleTradeItemListParams, ItemParam)
            end
        end
    end
    if GoldNumCheck == false then
        self:SetRoleGoldNumForTrade(0)
    end
    self:UpdateRoleTradeItemListInfo(CreateParams)
end

function MeetTradeVM:GetIsLock()
    return self.IsLock
end

function MeetTradeVM:SetIsLock(IsLock)
    self.IsLock = IsLock
end

function MeetTradeVM:GetTradeItemListParams(ItemParams)
    if nil ~= ItemParams then
        local Params = {
            ItemQualityIcon = ItemParams.ItemQualityIcon,
            Icon = ItemParams.Icon,
            IsNew = false,
            Num = ItemParams.Num,
            NumVisible = ItemParams.NumVisible,
            IsSelect = false,
            IsRecieived = false,
            IsMask = ItemParams.IsMask,
            IsChosen = false,
            GID = ItemParams.GID,
            ResID = ItemParams.ResID,
            Name = ItemParams.Name,
            LevelVisible = false,
            ImgAddOpacity = 0,
            ItemVisible = ItemParams.ItemVisible,
            IsValid = ItemParams.IsValid,
        }
        return Params
    end
end

function MeetTradeVM:CheckMajorItemListChange(Params)
    Params = Params or {}
    if #Params ~= #self.MajorTradeItemListParams then
        return true
    end
    --- 顺序改变也算改变
    for i = 1, #Params do
        local ItemParam = Params[i]
        local ItemParam2 = self.MajorTradeItemListParams[i]
        if ItemParam.GID ~= ItemParam2.GID or ItemParam.Num ~= ItemParam2.Num then
            return true
        end
    end
    return false
end

--传入的参数带有金币,所以需要先检查金币有没有变化
function MeetTradeVM:CheckRoleItemListChange(Params)
    local CreateParams = {}
    local NewGoldNum = 0
    for i = 1, #Params do
        local ItemParam = Params[i]
        if ItemParam.ResID == _G.BagMgr.RecoveryScoreID then --表示金币
            NewGoldNum = ItemParam.Num
        else
            table.insert(CreateParams, ItemParam)
        end
    end
    ---先检查金币有没有变化
    if NewGoldNum ~= self:GetRoleCurrentGoldNumForTrade() then
        return true
    end
    if #CreateParams ~= #self.RoleTradeItemListParams then
        return true
    end
    --- 顺序改变也算改变
    for i = 1, #CreateParams do
        local ItemParam = CreateParams[i]
        local ItemParam2 = self.RoleTradeItemListParams[i]
        if ItemParam.GID ~= ItemParam2.GID or ItemParam.Num ~= ItemParam2.Num then
            return true
        end
    end
    return false
end
return MeetTradeVM