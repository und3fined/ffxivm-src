--
-- Author: Carl
-- Date: 2024-05-10 16:57:14
-- Description:神秘商人VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MerchantTaskInfoVM = require("Game/MysterMerchant/VM/MerchantTaskInfoVM")
local GoodsItemVM = require("Game/MysterMerchant/VM/Item/MerchantGoodsListItemVM")
local MerchantDefine = require("Game/MysterMerchant/MysterMerchantDefine")
local MerchantUnlockListItemVM = require("Game/MysterMerchant/VM/Item/MerchantUnlockListItemVM")
local MysterMerchantUtils = require("Game/MysterMerchant/MysterMerchantUtils")
local ProtoRes = require("Protocol/ProtoRes")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local LSTR = _G.LSTR
local TimeUtil = _G.TimeUtil

---@class MysterMerchantVM : UIViewModel
---@field FriendlinessEXPTotal number @累计友好度经验
---@field CurLevelLeftExp number @当前等级剩余友好度经验
---@field NextFriendlinessEXP number @下一等级所需友好度经验
---@field FriendlinessLevel number @友好度等级
---@field Coins number @货币数量
---@field CoinID number @货币ID
---@field GoodsList table @商品列表
---
local MysterMerchantVM = LuaClass(UIViewModel)

function MysterMerchantVM:Ctor()
    self.CoinID = SCORE_TYPE.SCORE_TYPE_GOLD_CODE --金币ID
    self.GoodsVMList = UIBindableList.New(GoodsItemVM)
    self.UnlockGoodsVMList = UIBindableList.New(MerchantUnlockListItemVM)
    self.TaskInfoVM = MerchantTaskInfoVM.New()
end

function MysterMerchantVM:OnInit()
    self.FriendlinessEXPTotal = 0
    self.PreFriendlinessEXPTotal = 0
    self.AddExp = 0 --经验增加值
    self.CurLevelLeftExp = 0
    self.PrevLevelLeftExp = 0
    self.NextFriendlinessEXP = 0
    self.FriendlinessLevel = 1
    self.PrevFriendlinessLevel = 0
    self.FriendlinessEXPText = "" -- 主界面经验文本
    self.FriendlinessEXPSettlementText = "" -- 结算界面的经验文本
    self.Coins = 0
    self.GoodsList = {}
    self.UnlockGoodsList = {}
    self.IsInitExpInfo = false
    self.EXPPercent = 0
    self.PreEXPPercent = 0
    
    self.MerchantID = 0 --商人ID
    self.MapResID = 0 --地图ID
    self.TaskID = 0 --任务ID
    self.ExpireTime = 0 --商人回收时间|0=不回收
end

function MysterMerchantVM:OnBegin()

end

function MysterMerchantVM:OnEnd()

end

function MysterMerchantVM:OnShutdown()

end


---@type 更新商人友好度
function MysterMerchantVM:UpdateMerchantInfo(LevelExp)
    if LevelExp == nil then
        return
    end
    self:ResetPerformExpInfo()

    self.Coins = _G.ScoreMgr:GetScoreValueByID(self.CoinID)
    self.FriendlinessEXPTotal = LevelExp
    
    self.LevelInfo = MysterMerchantUtils.GetFriendlinessLevelInfo(self.FriendlinessEXPTotal)
    if self.LevelInfo == nil then
        return
    end

    self.CurLevelLeftExp = self.LevelInfo.LevelLeftExp
    self.NextFriendlinessEXP = self.LevelInfo.NextLevelRequiredExp
    self.FriendlinessEXPSettlementText = string.format("%s/%s", self.CurLevelLeftExp, self.NextFriendlinessEXP)
    if self.LevelInfo.IsGetMaxLevel then
        self.FriendlinessEXPText = MerchantDefine.MaxLevelText --"友好度已满"
        self.EXPPercent = 0
    else
        self.FriendlinessEXPText = string.format(MerchantDefine.FriendlinessLevelText, self.CurLevelLeftExp, self.NextFriendlinessEXP)
        if self.NextFriendlinessEXP and self.NextFriendlinessEXP > 0 then
            self.EXPPercent = self.CurLevelLeftExp / self.NextFriendlinessEXP
        end
    end
    self.FriendlinessLevel = self.LevelInfo.Level
    
    local IsLevelUp = self:IsLevelUp()
    if IsLevelUp then
        self.UnlockGoodsList = MysterMerchantUtils.GetUnlockGoodsList(self.FriendlinessLevel)
    else
        self.UnlockGoodsList = {}
    end
    self.UnlockGoodsVMList:UpdateByValues(self.UnlockGoodsList, nil, true)

    if not self.IsInitExpInfo then
        self.IsInitExpInfo = true
        self:ResetPerformExpInfo()
    end
end

---@type 获取友好度经验
function MysterMerchantVM:GetFriendlinessEXPTotal()
    return self.FriendlinessEXPTotal
end

---@type 重置升级表现经验信息 用于升级表现
function MysterMerchantVM:ResetPerformExpInfo()
    self.PrevLevelLeftExp = self.CurLevelLeftExp
    self.PrevFriendlinessLevel = self.FriendlinessLevel
    self.PreEXPPercent = self.EXPPercent
    self.PreFriendlinessEXPTotal = self.FriendlinessEXPTotal
end

---@type 更新商品列表
function MysterMerchantVM:UpdateGoodsInfo(NewGoodsList)
    if NewGoodsList == nil or next(NewGoodsList) == nil then
        return
    end

    self.GoodsList = {}
    for _, Data in ipairs(NewGoodsList) do
        local GoodsID = Data.GoodsID
        local BuyCount = Data.BuyNum
        local GoodsInfo = MysterMerchantUtils.GetGoodsInfo(GoodsID)
        if GoodsInfo then
            local NewGoodsInfo = {
                GoodsId = GoodsID, --商品ID
                BoughtCount = BuyCount, --已购数量
                ItemID = GoodsInfo.ItemID, -- 物品ID
                RestrictionType = GoodsInfo.RestrictionType, --限购类型
                LimitNum = GoodsInfo.LimitNum, --限购数量
                Price = GoodsInfo.Price, --价格
                Discount = GoodsInfo.Discount, --折扣
                ItemInfo = GoodsInfo.ItemInfo,
                IsSoldOut = BuyCount >= GoodsInfo.LimitNum,
                bBuy = true, -- 是否可买 
                bBuyDesc = "", --购买条件描述
                -- DiscountDurationStart = self:GetTimeInfo(GoodsInfo.DiscountDurationStart),
                -- DiscountDurationEnd = self:GetTimeInfo(GoodsInfo.DiscountDurationEnd),
                -- PurchaseConditions = GoodsInfo.PurchaseConditions,
                -- CounterInfo = {
                --     CounterFirst = {CounterID = 0, CounterNum = 0}, -- 计数器
                --     CounterSecond = {CounterID = 0, CounterNum = 0},
                -- }
            }
            NewGoodsInfo.bBuy, NewGoodsInfo.bBuyDesc = self:IsCanBuy(NewGoodsInfo)
            table.insert(self.GoodsList, NewGoodsInfo)
        end
    end
    
    table.sort(self.GoodsList, function(a, b) 
        if a.IsSoldOut ~= b.IsSoldOut then
            return b.IsSoldOut
        end
        return false
    end)
    self.GoodsVMList:UpdateByValues(self.GoodsList, nil, true)
end

--- 根据返回消息更新购买后前台商店信息
---@param MsgBody table @消息体
function MysterMerchantVM:UpdateGoodsInfoAfterBuy(GoodInfo)
	local GoodsIDInMsg = GoodInfo.GoodsID
	local Count = GoodInfo.BuyNum
    if self.GoodsList == nil or next(self.GoodsList) == nil then
        return
    end

    for i = 1, #self.GoodsList do
        local GoodsInfo = MysterMerchantUtils.GetGoodsInfo(GoodsIDInMsg)
        local GoodsItemData = self.GoodsList[i]
        local BoughtCount = GoodsItemData.BoughtCount + Count
        local LimitNum = GoodsInfo and GoodsInfo.LimitNum or 0

        if GoodsItemData.GoodsId == GoodsIDInMsg then
            GoodsItemData.BoughtCount = BoughtCount --已购数量
            GoodsItemData.IsSoldOut = BoughtCount >= LimitNum
            GoodsItemData.bBuy, GoodsItemData.bBuyDesc = self:IsCanBuy(GoodsItemData)
            local UpdateGoodsVM = self.GoodsVMList and self.GoodsVMList:Get(i)
            if UpdateGoodsVM then
                UpdateGoodsVM:UpdateByValue(GoodsItemData, nil, false)
            end
        end
    end
end

--- 商品是否可购买
---@param GoodsId number@商品id
---@return boolean @是否可购买
---@return string @不可购买原因
---已售罄算在不可购买里
function MysterMerchantVM:IsCanBuy(GoodsInfo)
	local TmpGoodsCfg = GoodsInfo
	if TmpGoodsCfg == nil then
		return false, ""
	end

	---限购检查
    local IsSoldOut = TmpGoodsCfg.IsSoldOut
    if IsSoldOut then
        return false, LSTR(1200032)
    end
	
	return true, ""
end

function MysterMerchantVM:GetTimeInfo(Time)
    if Time == nil or Time == "" then
        return 0
    end

    local pattern = "(%d+)-(%d+)-(%d+)_(%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = Time:match(pattern)
    local timestamp = os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec})

    return timestamp
end

---@type 更新任务信息
function MysterMerchantVM:UpdateTaskInfo(TaskInfo)
    if TaskInfo == nil then
        return
    end
    self.AddExp = TaskInfo.AddExp
    
    self.TaskInfoVM:UpdateTaskInfo(TaskInfo)
end

function MysterMerchantVM:OnEnterTaskRange(MerchantInfo)
    if MerchantInfo == nil then
        return
    end
    self.MerchantID = MerchantInfo.MerchantID
end

function MysterMerchantVM:OnLeaveTaskRange(MerchantInfo)
    if MerchantInfo == nil then
        return
    end
    self.MerchantID = 0
end

function MysterMerchantVM:GetFriendlinessLevel()
    return self.FriendlinessLevel
end

function MysterMerchantVM:GetPrevFriendlinessLevel()
    return self.PrevFriendlinessLevel
end

function MysterMerchantVM:GetCurLevelLeftExp()
    return self.CurLevelLeftExp
end

function MysterMerchantVM:GetPrevLevelLeftExp()
    return self.PrevLevelLeftExp
end

function MysterMerchantVM:GetEXPPercent()
    return self.EXPPercent
end

function MysterMerchantVM:GetPreEXPPercent()
    return self.PreEXPPercent
end

function MysterMerchantVM:IsLevelUp()
    return self.FriendlinessLevel > self.PrevFriendlinessLevel
end

function MysterMerchantVM:IsMaxLevel(Level)
    if self.LevelInfo == nil or Level == nil then
        return false
    end
    return self.LevelInfo.LevelMax == Level
end

function MysterMerchantVM:GetTaskInfoVM()
   return self.TaskInfoVM
end

return MysterMerchantVM