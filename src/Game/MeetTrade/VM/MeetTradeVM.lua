local LuaClass = require("Core/LuaClass")
local MeetTradeItemVM = require("Game/MeetTrade/VM/MeetTradeItemVM")
local UIViewModel = require("UI/UIViewModel")
local UIBindableBagSlotList = require("Game/NewBag/VM/UIBindableBagSlotList")
local ScoreMgr = require("Game/Score/ScoreMgr")
local BagMgr = require("Game/Bag/BagMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local ItemUtil = require("Utils/ItemUtil")
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
    self.MajorGoldForTradeText = "0"
    ---对方交易的金币数量
    self.RoleGoldForTrade = 0
    self.RoleGoldForTradeText = "0"
    ---我方显示的交易税
    self.MajorGoldTax = 0
    self.MajorGoldTaxText = "0"
    ---交易金币的选中是否可见
    self.GlodNumForTradeVisible = false
    --- 面对面交易的格子数量
    self.EmptyItemCache = {}
    self.IsLock = false
    self.PlayGoldNumChangeAnimation = nil
    self:SetBindPropertyNoCheckValueChange("PlayGoldNumChangeAnimation")
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
    self.IsClickLock = nil
end
---设置交易税率
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
    local CurNickName = _G.FriendMgr:GetFriendNickname(RoleVM.RoleID)
    if CurNickName and CurNickName ~= "" then
        self.RoleVM.NickName = "(" .. CurNickName .. ")"
        self.RoleVM.NickNameVisible = true
    else
        self.RoleVM.NickNameVisible = false
    end
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
    local Capacity = self:GetItemCapacity()
    if(nil ~= Items and #Items > Capacity) then
        FLOG_ERROR("MeetTradeVM:MajorTradeItemVMList capacity is %d, but Items count is %d", Capacity, #Items)
        return
    end
    local ItemList = Items or {}
    --- 在第一个空ItemList后添加设置“+”显示
    if(#ItemList < Capacity) then
        local Index = #ItemList + 1
        ItemList[Index] = {ImgAddOpacity = 1}
    end
	ItemList = self:FillCapacityByEmptyItem(ItemList)
    for i, v in ipairs(ItemList) do
        v.BtnAddVisible = true
        v.Index = i
        v.ImgAdd = "Texture2D'/Game/UI/Texture/Icon/UI_Icon_PlusSign_Noraml.UI_Icon_PlusSign_Noraml'"
    end
	self.MajorTradeItemVMList:UpdateByValues(ItemList)
end

---初始化用
function MeetTradeVM:UpdateRoleTradeItemListInfo(Items)
    local Capacity = self:GetItemCapacity()
    if(nil ~= Items and #Items > Capacity) then
        FLOG_ERROR("MeetTradeVM:RoleTradeItemVMList capacity is %d, but Items count is %d", Capacity, #Items)
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
    local Capacity = self:GetItemCapacity()
	local ResultList = ItemList or {}
	local ItemLen = #ResultList
	for i = 1, Capacity - ItemLen do
		ResultList[ItemLen + i] = self.EmptyItemCache
	end
	return ResultList
end
function MeetTradeVM:GetItemCapacity()
	return _G.MeetTradeMgr.SelectListCapacity
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
    self.MajorGoldForTradeText = ItemUtil.GetItemNumTextWithoutBehind(self.MajorGoldForTrade)
    self.MajorGoldTax = math.ceil(self.MajorGoldForTrade * self.MajorGoldTaxRate)
    self.MajorGoldTaxText = ItemUtil.GetItemNumTextWithoutBehind(self.MajorGoldTax)
end

function MeetTradeVM:SetRoleGoldNumForTrade(NewNum)
    self.AnimNum = {OldNum = self.RoleGoldForTrade, Num = NewNum}
    if NewNum > self.RoleGoldForTrade then
        self.PlayGoldNumChangeAnimation = 1
    elseif NewNum < self.RoleGoldForTrade then
        self.PlayGoldNumChangeAnimation = 2
    else
        self.PlayGoldNumChangeAnimation = 0
    end
    self.RoleGoldForTrade = NewNum
    --self.RoleGoldForTradeText = ItemUtil.GetItemNumTextWithoutBehind(self.RoleGoldForTrade)
end

function MeetTradeVM:GetMajorCurrentGoldNumForTrade()
    return self.MajorGoldForTrade
end

function MeetTradeVM:GetRoleCurrentGoldNumForTrade()
    return self.RoleGoldForTrade
end

function MeetTradeVM:GetMajorMaxGoldNumForTrade()
    local CurrentHaveGoldNum = ScoreMgr:GetScoreValueByID(BagMgr.RecoveryScoreID)
    local MajorMaxGoldNumForTrade = math.floor(CurrentHaveGoldNum / (1 + self.MajorGoldTaxRate))
    -- 向下取整，保证不会超过当前持有金币数
    return MajorMaxGoldNumForTrade
end

function MeetTradeVM:GetMajorGoldTax()
    return self.MajorGoldTax
end

function MeetTradeVM:UpdateImgAdd(IsReadyForTrade)
    local ImgAdd = "Texture2D'/Game/UI/Texture/Icon/UI_Icon_PlusSign_Noraml.UI_Icon_PlusSign_Noraml'"
    if IsReadyForTrade then
        ImgAdd = "Texture2D'/Game/UI/Texture/MeetTrade/UI_Icon_MeetTrade_Add.UI_Icon_MeetTrade_Add'"
    end
    local Items = self.MajorTradeItemVMList.Items
    for _, Item in ipairs(Items) do
        if Item.ImgAddOpacity == 1 then
            Item.ImgAdd = ImgAdd
            Item:UpdateByValue(Item)
            break
        end
    end
end

function MeetTradeVM:UpdateMajorTradeItemList(Params)
    local CreateParams = {}
    self.MajorTradeItemListParams = {}
    for i = 1, #Params do
        local ItemParam = self:GetTradeItemListParams(Params[i])
        if nil ~= ItemParam then
            if ItemParam.ResID == _G.BagMgr.RecoveryScoreID then --表示金币
               self:SetMajorGoldNumForTrade(ItemParam.Num)
            else
                table.insert(CreateParams, ItemParam)
                table.insert(self.MajorTradeItemListParams, ItemParam)
            end
        end
    end
    self:UpdateMajorTradeItemListInfo(CreateParams)
end

function MeetTradeVM:UpdateRoleTradeItemListParams(Params)
    local CreateParams = {}
    local GoldNumCheck = false
    local OldRoleTradeItemListParams = self.RoleTradeItemListParams
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
    if #CreateParams > #OldRoleTradeItemListParams then
        for i = 1, #OldRoleTradeItemListParams do
            local ItemParam = CreateParams[i]
            local ItemParam2 = OldRoleTradeItemListParams[i]
            if ItemParam.GID ~= ItemParam2.GID or ItemParam.Num ~= ItemParam2.Num then
                CreateParams[i].PlayAnim = true
            else
                CreateParams[i].PlayAnim = false
            end
        end
        for i = #OldRoleTradeItemListParams + 1, #CreateParams do
            CreateParams[i].PlayAnim = true
        end
    else
        for i = 1, #CreateParams do
            local ItemParam = CreateParams[i]
            local ItemParam2 = OldRoleTradeItemListParams[i]
            if ItemParam.GID ~= ItemParam2.GID or ItemParam.Num ~= ItemParam2.Num then
                CreateParams[i].PlayAnim = true
            else
                CreateParams[i].PlayAnim = false
            end
        end
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
function MeetTradeVM:MarkRoleItemListChange(Params)
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

function MeetTradeVM:SetTotalMoneyNumStrByAminVlaue(AminVlaue)
    local AnimNum = self.AnimNum
	local OldNum = AnimNum.OldNum
	local Num = AnimNum.Num
	if OldNum and Num and AminVlaue then
		local TotalNum = (Num - OldNum) * AminVlaue + OldNum
		self.RoleGoldForTradeText = _G.ArmyMgr:FormatMoneyNumber(TotalNum)
	end
end

function MeetTradeVM:SetBindPropertyNoCheckValueChange(BindName)
    local BindProperty = self:FindBindableProperty(BindName)
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end
end
return MeetTradeVM