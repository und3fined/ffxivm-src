local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIBindableList = require("UI/UIBindableList")
local BagTidyListItemVM = require("Game/NewBag/VM/BagTidyListItemVM")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ProtoRes = require("Protocol/ProtoRes")

local NormalColor = "#D5D5D5FF"
local WarningColor = "#DC5868FF"

---@class BagTidyWinVM : UIViewModel
local BagTidyWinVM = LuaClass(UIViewModel)

---Ctor
function BagTidyWinVM:Ctor()
    self.ConsumMoney1 = nil
    self.ConsumMoney2 = nil
    self.ConsumMoney1Visiable = false
    self.ConsumMoney2Visiable = false
    self.ObtainMoney1 = nil
    self.ObtainMoney2 = nil
    self.ConsumMoney2Color = nil
    self.ObtainMoney1Visiable = false
    self.ObtainMoney2Visiable = false
    self.ObtainLimitVisiable = false
    self.BagTidyItemVMList = UIBindableList.New(BagTidyListItemVM)
end

function BagTidyWinVM:UpdateVM()
    -- 清理缓存，确保数据是最新的
    self.CachedAppearanceList = nil
    self.CachedEquipmentItems = nil
    
    self.ItemsData = {
        [1] = {
            TextTitle = LSTR(990135),
            TextGoto = "",
            GotoVisiable = false,
            Choose1TextVisiable = false,
            Choose2TextVisiable = false,
            HelpInfoID = 11200,
            Choose1Text = "",
            Choose2Text = "",
            Index = 1,
            IsToggle1Enabled = true,
            SingleBox1Enabled = true,
        },
        [2] = {
            TextTitle = LSTR(990136),
            TextGoto = LSTR(990137),
            GotoVisiable = true,
            Choose1TextVisiable = true,
            Choose2TextVisiable = true,
            HelpInfoID = 11201,
            Index = 2,
			IsToggle1Enabled = true,
			IsToggle2Enabled = false,
        },
        [3] = {
            TextTitle = LSTR(990138),
            TextGoto = LSTR(990139),
            GotoVisiable = true,
            Choose1TextVisiable = true,
            Choose2TextVisiable = true,
            HelpInfoID = 11202,
            Index = 3,
			IsToggle1Enabled = true,
			IsToggle2Enabled = false,
        },
        [4] = {
            TextTitle = LSTR(990140),
            TextGoto = "",
            GotoVisiable = false,
            Choose1TextVisiable = true,
            Choose2TextVisiable = true,
            HelpInfoID = 11203,
            Index = 4,
			IsToggle1Enabled = true,
			IsToggle2Enabled = false,
        }
    }
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDCompanySeal) and _G.CompanySealMgr.GrandCompanyID ~= 0 then
        self.ShowRecycleCompanySeal = true
    else
        self.ShowRecycleCompanySeal = false
    end
	self:UpdateTidyWin()
end

function BagTidyWinVM:UpdateItemTexts(ItemIndex, Value1, Value2)
    local Text = {
        [2] = {
            Choose1Text = LSTR(990141),
            Choose2Text = LSTR(990142),
        },
        [3] = {
            Choose1Text = LSTR(990143),
            Choose2Text = LSTR(990144),
        },
        [4] = {
            Choose1Text = LSTR(990143),
            Choose2Text = LSTR(990144),
        }
    }
    local Item = self.ItemsData[ItemIndex]
    if Item then
        if Value1 then
            Item.Choose1Text = string.format(Text[ItemIndex].Choose1Text, Value1)
        end

        if Value2 then
            Item.Choose2Text = string.format(Text[ItemIndex].Choose2Text, Value2)
        end
    end
end

function BagTidyWinVM:SetWoradrobeItemState()
    -- 缓存外观列表，避免重复获取
    if not self.CachedAppearanceList then
        self.CachedAppearanceList = _G.WardrobeMgr:GetQuickUnlockAppearanceList()
        table.sort(self.CachedAppearanceList, function(a, b)
            local aSpecial = WardrobeUtil.GetIsSpecial(a) and #WardrobeUtil.GetAchievementIDList(a) == 0
            local bSpecial = WardrobeUtil.GetIsSpecial(b) and #WardrobeUtil.GetAchievementIDList(b) == 0
            if aSpecial and not bSpecial then
                return true
            elseif not aSpecial and bSpecial then
                return false
            else
                return a < b
            end
        end)
    end
    
    local AppearanceList = self.CachedAppearanceList
	local EquipNum = 0
	local FashionNum = 0
	local CostPrismNum = 0
    local CostGoldNum = 0
    local ConsumPrism = 0
    self.UnlockItems = {}
    self.UnlockGIDs = {}
    self.IsGoldEnough = true
	for _, AppearanceID in ipairs(AppearanceList) do
		if WardrobeUtil.GetIsSpecial(AppearanceID) and  #WardrobeUtil.GetAchievementIDList(AppearanceID) == 0 then
            if self.ItemsData[2].IsToggle1Enabled and not self.ItemsData[2].IsToggle2Enabled then
                if FashionNum < 50 then
                    FashionNum = FashionNum + 1
                    if self.ItemsData[2].IsToggle1Enabled then
                        self:GetUnLockList(AppearanceID)
                    end
                else
                    break
                end
            elseif self.ItemsData[2].IsToggle1Enabled and self.ItemsData[2].IsToggle2Enabled then
                if FashionNum < (50 - EquipNum) then
                    FashionNum = FashionNum + 1
                    if self.ItemsData[2].IsToggle1Enabled then
                        self:GetUnLockList(AppearanceID)
                    end
                else
                   break
                end
            else
                FashionNum = FashionNum + 1
                if self.ItemsData[2].IsToggle1Enabled then
                    self:GetUnLockList(AppearanceID)
                end
            end
        elseif #WardrobeUtil.GetAchievementIDList(AppearanceID) == 0 then
            if self.ItemsData[2].IsToggle2Enabled and not self.ItemsData[2].IsToggle1Enabled then
                if EquipNum < 50 then
                    EquipNum = EquipNum + 1
                    CostPrismNum = CostPrismNum + WardrobeUtil.GetUnlockCostItemNum(AppearanceID)
                    if self.ItemsData[2].IsToggle2Enabled then
                        self:GetUnLockList(AppearanceID)
                    end
                else
                    break
                end
            elseif self.ItemsData[2].IsToggle2Enabled and self.ItemsData[2].IsToggle1Enabled then
                if EquipNum < (50 - FashionNum) then
                    EquipNum = EquipNum + 1
                    CostPrismNum = CostPrismNum + WardrobeUtil.GetUnlockCostItemNum(AppearanceID)
                    if self.ItemsData[2].IsToggle2Enabled then
                        self:GetUnLockList(AppearanceID)
                    end
                else
                    break
                end
            else
                EquipNum = EquipNum + 1
                CostPrismNum = CostPrismNum + WardrobeUtil.GetUnlockCostItemNum(AppearanceID)
                if self.ItemsData[2].IsToggle2Enabled then
                    self:GetUnLockList(AppearanceID)
                end
            end
		end
	end
	local OwnedPrismNum = _G.BagMgr:GetItemNum(60700004)
    local OwnedGoldNum = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)

    if OwnedPrismNum < CostPrismNum then
        CostGoldNum = (CostPrismNum - OwnedPrismNum) * 500
        self.PurchasePrismNum = CostPrismNum - OwnedPrismNum
        if CostGoldNum > OwnedGoldNum then
            self.ConsumMoney2Color = WarningColor
            self.IsGoldEnough = false
        else
            self.ConsumMoney2Color = NormalColor
        end
        ConsumPrism = OwnedPrismNum
    else
        ConsumPrism = CostPrismNum
    end
    self.ConsumMoney1Visiable = ConsumPrism > 0
    self.ConsumMoney2Visiable = CostGoldNum > 0
    self.CostGoldNum = CostGoldNum
    self.ConsumMoney2 = _G.ScoreMgr.FormatScore(CostGoldNum)
    self.ConsumMoney1 = _G.ScoreMgr.FormatScore(ConsumPrism)
	self:UpdateItemTexts( 2, FashionNum, EquipNum)
	self.ItemsData[2].Value1 = FashionNum
	self.ItemsData[2].Value2 = EquipNum
    self.ItemsData[2].SingleBox1Enabled = FashionNum > 0
    self.ItemsData[2].SingleBox2Enabled = EquipNum > 0
    if not self.ItemsData[2].SingleBox1Enabled then
        self.ItemsData[2].IsToggle1Enabled = false
    end
    if not self.ItemsData[2].SingleBox2Enabled then
        self.ItemsData[2].IsToggle2Enabled = false
    end
    if not self.ItemsData[2].IsToggle2Enabled then
        self.ConsumMoney1Visiable = false
        self.ConsumMoney2Visiable = false
        self.IsGoldEnough = true
    end
end

function BagTidyWinVM:UpdateItemsData(Param)
    if Param == nil then
       return
    end
    if Param.SingleBoxIndex == 1 then
        self.ItemsData[Param.Index].IsToggle1Enabled = Param.IsChecked
    elseif Param.SingleBoxIndex == 2 then
        self.ItemsData[Param.Index].IsToggle2Enabled = Param.IsChecked
    end
end

function BagTidyWinVM:UpdateTidyWin(Param)
    -- 根据参数决定是否需要重新计算数据，避免不必要的性能消耗
    if Param == nil then
        -- 初始化时需要计算所有数据
        self:SetWoradrobeItemState()
        self:SetCompanySealItemState()
        self:SetEquipItemState()
    else
        -- 勾选框状态变化时，只更新相关的数据
        self:UpdateRelatedItemState(Param)
    end
    
    self.IsToggleChecked = self:GetIsToggleChecked()
    if self.ShowRecycleCompanySeal then
        self.BagTidyItemVMList:UpdateByValues(self.ItemsData)
    else
        self.BagTidyItemVMList:UpdateByValues({self.ItemsData[1], self.ItemsData[2], self.ItemsData[4]})
    end
end

function BagTidyWinVM:SetEquipItemState()
    local RecycleFullEquipNum = 0
    local RecycleNonFullEquipNum = 0
    local RecoveryGoldNum= 0
    self.RecoveryItems = {}
    -- 缓存装备列表，避免重复获取
    if not self.CachedEquipmentItems then
        self.CachedEquipmentItems = _G.BagMgr:FindItemsByItemType(ProtoCommon.ITEM_TYPE.ITEM_TYPE_EQUIP)
    end
    local EquipmentItems = self.CachedEquipmentItems
    if self.ItemsData[1].IsToggle1Enabled then
        local AllStrongestEquips = _G.EquipmentMgr:GetAllStrongest()
        local lookup = {}
        for _, Item in ipairs(AllStrongestEquips) do
            if not table.is_nil_empty(Item.ItemData) then
                for _, Item in ipairs(Item.ItemData) do
                    lookup[Item.GID] = true
                end
            end
        end

        local RecoveryItems = {}
        for _, Item in ipairs(EquipmentItems) do
            if not lookup[Item.GID] then
                table.insert(RecoveryItems, Item)
            end
        end
        for _, Item in ipairs(RecoveryItems) do
            local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
            if Cfg.IsRecoverable == 1 then
                if Cfg.Grade == 50 then
                    RecycleFullEquipNum = RecycleFullEquipNum + 1
                    if self.ItemsData[4].IsToggle2Enabled then
                        RecoveryGoldNum = RecoveryGoldNum + Cfg.RecoverNum
                        table.insert(self.RecoveryItems, Item.GID)
                    end
                else
                    RecycleNonFullEquipNum = RecycleNonFullEquipNum + 1
                    if self.ItemsData[4].IsToggle1Enabled then
                        RecoveryGoldNum = RecoveryGoldNum + Cfg.RecoverNum
                        table.insert(self.RecoveryItems, Item.GID)
                    end
                end
            end
        end
    else
        for _, Item in ipairs(EquipmentItems) do
            local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
            if not ItemUtil.ItemIsInScheme(Item) and Cfg.IsRecoverable == 1 then
                if Cfg.Grade == 50 then
                    if self.ItemsData[4].IsToggle2Enabled then
                        RecoveryGoldNum = RecoveryGoldNum + Cfg.RecoverNum
                        table.insert(self.RecoveryItems, Item.GID)
                    end
                    RecycleFullEquipNum = RecycleFullEquipNum + 1
                else
                    if self.ItemsData[4].IsToggle1Enabled then
                        RecoveryGoldNum = RecoveryGoldNum + Cfg.RecoverNum
                        table.insert(self.RecoveryItems, Item.GID)
                    end
                    RecycleNonFullEquipNum = RecycleNonFullEquipNum + 1
                end
            end
        end
    end
    self.ObtainMoney1 = _G.ScoreMgr.FormatScore(RecoveryGoldNum)
    self.ObtainMoney1Visiable = RecoveryGoldNum > 0
    local CurGoldValue = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
    local MaxGoldValue = _G.ScoreMgr:GetScoreMaxValue(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
    if (RecoveryGoldNum + CurGoldValue) > MaxGoldValue and RecoveryGoldNum > 0 then
        self.IsGoldAtMaxLimit = true
    else
        self.IsGoldAtMaxLimit = false
    end
    self:UpdateItemTexts( 4, RecycleNonFullEquipNum, RecycleFullEquipNum)
    self.ItemsData[4].Value1 = RecycleNonFullEquipNum
	self.ItemsData[4].Value2 = RecycleFullEquipNum
    self.ItemsData[4].SingleBox1Enabled = RecycleNonFullEquipNum > 0
    self.ItemsData[4].SingleBox2Enabled = RecycleFullEquipNum > 0
    if not self.ItemsData[4].SingleBox1Enabled then
        self.ItemsData[4].IsToggle1Enabled = false
    end
    if not self.ItemsData[4].SingleBox2Enabled then
        self.ItemsData[4].IsToggle2Enabled = false
    end
    if self.IsCompanySealAtMaxLimit or self.IsGoldAtMaxLimit then
        self.ObtainLimitVisiable = true
    else
        self.ObtainLimitVisiable = false
    end
end


function BagTidyWinVM:SetCompanySealItemState()
    local RecycleFullEquipNum = 0
    local RecycleNonFullEquipNum = 0
    local RecycleCompanySealNum = 0
    self.RecordRareItems = {}
    -- 复用装备缓存
    if not self.CachedEquipmentItems then
        self.CachedEquipmentItems = _G.BagMgr:FindItemsByItemType(ProtoCommon.ITEM_TYPE.ITEM_TYPE_EQUIP)
    end
    local EquipmentItems = self.CachedEquipmentItems
    if self.ItemsData[1].IsToggle1Enabled then
        local AllStrongestEquips = _G.EquipmentMgr:GetAllStrongest()
        local lookup = {}
        for _, Item in ipairs(AllStrongestEquips) do
            if not table.is_nil_empty(Item.ItemData) then
                for _, Item in ipairs(Item.ItemData) do
                    lookup[Item.GID] = true
                end
            end
        end

        local RecoveryItems = {}
        for _, Item in ipairs(EquipmentItems) do
            if not lookup[Item.GID] then
                table.insert(RecoveryItems, Item)
            end
        end
        for _, Item in ipairs(RecoveryItems) do
            -- local IsImprove = _G.CompanySealMgr:EquipIsImprove(Item.ResID)
            local CarryList = Item.Attr.Equip.GemInfo.CarryList
            local HasCarry = false
            local EquipCfg = EquipmentCfg:FindCfgByEquipID(Item.ResID)
            for _, value in pairs(CarryList) do
                if value then
                    HasCarry = true
                    break
                end
            end

            if EquipCfg then
                if EquipCfg.ExchangeCompanySealNum > 0 and not HasCarry then
                    local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
                    if Cfg.Grade == 50 then
                        RecycleFullEquipNum = RecycleFullEquipNum + 1
                        if self.ItemsData[3].IsToggle2Enabled then
                            RecycleCompanySealNum = RecycleCompanySealNum + EquipCfg.ExchangeCompanySealNum
                            table.insert(self.RecordRareItems, Item.ResID)
                        end
                    else
                        if self.ItemsData[3].IsToggle1Enabled then
                            RecycleCompanySealNum = RecycleCompanySealNum + EquipCfg.ExchangeCompanySealNum
                            table.insert(self.RecordRareItems, Item.ResID)
                        end
                        RecycleNonFullEquipNum = RecycleNonFullEquipNum + 1
                    end
                end
            end
        end
    else
        for _, Item in ipairs(EquipmentItems) do
            local IsImprove = _G.CompanySealMgr:EquipIsImprove(Item.ResID)
            local IsInScheme = Item.Attr.Equip.IsInScheme
            local CarryList = Item.Attr.Equip.GemInfo.CarryList
            local HasCarry = false
            local EquipCfg = EquipmentCfg:FindCfgByEquipID(Item.ResID)
            for _, value in pairs(CarryList) do
                if value then
                    HasCarry = true
                    break
                end
            end

            if EquipCfg then
                if EquipCfg.ExchangeCompanySealNum > 0 and not IsInScheme and not HasCarry and not IsImprove then
                    local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
                    if Cfg.Grade == 50 then
                        if self.ItemsData[3].IsToggle2Enabled then
                            RecycleCompanySealNum = RecycleCompanySealNum + EquipCfg.ExchangeCompanySealNum
                            table.insert(self.RecordRareItems, Item.ResID)
                        end
                        RecycleFullEquipNum = RecycleFullEquipNum + 1
                    else
                        if self.ItemsData[3].IsToggle1Enabled then
                            RecycleCompanySealNum = RecycleCompanySealNum + EquipCfg.ExchangeCompanySealNum
                            table.insert(self.RecordRareItems, Item.ResID)
                        end
                        RecycleNonFullEquipNum = RecycleNonFullEquipNum + 1
                    end
                end
            end
        end
    end
    self.ObtainMoney2 = _G.ScoreMgr.FormatScore(RecycleCompanySealNum)
    if RecycleCompanySealNum > 0 and self.ShowRecycleCompanySeal then
        self.ObtainMoney2Visiable = true
    else
        self.ObtainMoney2Visiable = false
    end
    local ScoreID = CompanySealMgr:GetScoreInfo()
	local CurHas = _G.ScoreMgr:GetScoreValueByID(ScoreID)
    local MaxLimit = CompanySealMgr:GetCurRankScoreMax(CompanySealMgr.GrandCompanyID, CompanySealMgr.MilitaryLevel)
    if (CurHas +  RecycleCompanySealNum)  > MaxLimit and self.ShowRecycleCompanySeal then
        self.IsCompanySealAtMaxLimit = true
    else
        self.IsCompanySealAtMaxLimit = false
    end
    if self.IsCompanySealAtMaxLimit then
        self.ObtainLimitVisiable = true
    else
        self.ObtainLimitVisiable = false
    end
    self:UpdateItemTexts( 3, RecycleNonFullEquipNum, RecycleFullEquipNum)
    self.ItemsData[3].Value1 = RecycleNonFullEquipNum
	self.ItemsData[3].Value2 = RecycleFullEquipNum
    self.ItemsData[3].SingleBox1Enabled = RecycleNonFullEquipNum > 0
    self.ItemsData[3].SingleBox2Enabled = RecycleFullEquipNum > 0
    if not self.ItemsData[3].SingleBox1Enabled or not self.ShowRecycleCompanySeal then
        self.ItemsData[3].IsToggle1Enabled = false
    end
    if not self.ItemsData[3].SingleBox2Enabled or not self.ShowRecycleCompanySeal then
        self.ItemsData[3].IsToggle2Enabled = false
    end
end

-- 刷新缓存数据
function BagTidyWinVM:RefreshCache()
    self.CachedAppearanceList = nil
    self.CachedEquipmentItems = nil
end

function BagTidyWinVM:UpdateRelatedItemState(Param)
    if Param.Index == 2 then
        -- 衣橱相关的勾选框变化
        self:SetWoradrobeItemState()
    elseif Param.Index == 3 then
        -- 军票相关的勾选框变化
        if self.ShowRecycleCompanySeal then
            self:SetCompanySealItemState()
        end
    elseif Param.Index == 4 then
        -- 装备回收相关的勾选框变化
        self:SetEquipItemState()
    end
    -- Index == 1 (一键换装最强) 不需要重新计算数据，只影响其他选项的计算基础
    -- 但为了保持数据一致性，当Index == 1变化时，需要重新计算装备和军票相关数据
    if Param.Index == 1 then
        if self.ShowRecycleCompanySeal then
            self:SetCompanySealItemState()
        end
        self:SetEquipItemState()
    end
end

function BagTidyWinVM:GetIsToggleChecked()
    for Index, ItemData in ipairs(self.ItemsData) do
        if ItemData.IsToggle1Enabled or ItemData.IsToggle2Enabled then
            return true
        end
    end
    return false
end

function BagTidyWinVM:GetUnLockList(AppearanceID)
    local GIDs = {}
    if WardrobeUtil.GetIsSpecial(AppearanceID) then
        -- 插入解锁道具的GID
        local ItemID = WardrobeUtil.GetUnlockCostItemID(AppearanceID)
        if _G.BagMgr:GetItemNum(ItemID) > 0 then
            local BagItem = _G.BagMgr:GetItemByResID(ItemID)
            if BagItem ~= nil then
                table.insert(GIDs, BagItem.GID)
            end
        end
    else

        local IsUnlock = _G.WardrobeMgr:GetIsUnlock(AppearanceID)
        local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(AppearanceID)
        if not table.is_nil_empty(EquipmentCfgs) then
            for _, v in ipairs(EquipmentCfgs) do
                local ItemNum = _G.BagMgr:GetItemNum(v.ID) + _G.EquipmentMgr:GetEquipedItemNum(v.ID)
                if IsUnlock then
                    if  ItemNum > 0 and _G.WardrobeMgr:IsLessReduceConditionEquipment(AppearanceID, v.ID) then
                        local BagItem = _G.BagMgr:GetItemByResID(v.ID)
                        local EquipedItem = _G.EquipmentMgr:GetEquipedItemByResID(v.ID)
                        if EquipedItem ~= nil then
                            table.insert(GIDs, EquipedItem.GID)
                        end
                        if BagItem ~= nil then
                            table.insert(GIDs, BagItem.GID)
                        end
                    end
                else
                    if ItemNum > 0 then
                        local BagItem = _G.BagMgr:GetItemByResID(v.ID)
                        local EquipedItem = _G.EquipmentMgr:GetEquipedItemByResID(v.ID)
                        if EquipedItem ~= nil then
                            table.insert(GIDs, EquipedItem.GID)
                        end
                        if BagItem ~= nil then
                            table.insert(GIDs, BagItem.GID)
                        end
                    end
                end
            end
        end
    end

    table.insert(self.UnlockItems, {ID = AppearanceID, GIDs = GIDs})
    table.insert(self.UnlockGIDs, GIDs)
end

return BagTidyWinVM