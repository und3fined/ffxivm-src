---
--- Author: michealyang_lightpaw
--- DateTime: 2025-07-31
--- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local SeanceScratchLotteryItemVM = LuaClass(UIViewModel)

--物品选中后的表现

SeanceScratchLotteryItemVM.SelcteStatus = {Change = 1, Superposition = 2} -- 1，改变选中状态，2，叠加选中状态支持多种

---Ctor
function SeanceScratchLotteryItemVM:Ctor()
    self.PhaseIndex = 0 -- 阶段下标
    self.SlotIndex = 0 -- 自己的下标
    self.ItemID = 0 -- 物品ID
    self.Icon = "" -- 图标路径
    self.bCanGet = false -- 是否能获取
    self.bGetted = false -- 是否已经获取
    self.bGetBigPrize = false -- 获取后是否为大奖
end

function SeanceScratchLotteryItemVM:IsEqualVM(InValue)
    return InValue.PhaseIndex == self.PhaseIndex and InValue.Index == self.Index
end

function SeanceScratchLotteryItemVM:UpdateVM(InData)
    if (InData == nil) then
        return
    end
    -- 顺序很重要，先设置INDEX，status 依赖 index
    self.PhaseIndex = InData.PhaseIndex
    self.SlotIndex = InData.SlotIndex
    self.ItemID = InData.ItemID or 0
    self.Icon = UIUtil.GetItemIconPath(self.ItemID)
    self.bCanGet = InData.bCanGet or false
    self.Num = InData.Num or 0
    self.bGetBigPrize = InData.bGetBigPrize or false
    self.bGetted = InData.bGetted or false
end

function SeanceScratchLotteryItemVM:SetItemData(InItemID, InCount)
    self.ItemID = InItemID or 0
    self.Icon = UIUtil.GetItemIconPath(self.ItemID)
    self.Num = InCount or 0
end

function SeanceScratchLotteryItemVM:UpdateParams(Params)
end

return SeanceScratchLotteryItemVM
