--
-- Author: ZhengJanChuan
-- Date: 2025-07-22 20:32
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local OpsReturnSigninRewardItemVM = require("Game/Ops/VM/OpsReturn/Item/OpsReturnSigninRewardItemVM")

---@class OpsReturnSigninItemVM : UIViewModel
local OpsReturnSigninItemVM = LuaClass(UIViewModel)

---Ctor
function OpsReturnSigninItemVM:Ctor()
    self.Index = 0
	self.NodeID = 0
	self.Day = ""
	self.RewardsStatus = ProtoCS.Game.Activity.RewardStatus.RewardStatusNo
	self.RewardList = UIBindableList.New(OpsReturnSigninRewardItemVM)
end

function OpsReturnSigninItemVM:OnInit()
end

function OpsReturnSigninItemVM:OnBegin()
end

function OpsReturnSigninItemVM:OnEnd()
end

function OpsReturnSigninItemVM:OnShutdown()
end

function OpsReturnSigninItemVM:UpdateVM(Value)
	self.Index =  Value.Index
	self.NodeID = Value.NodeID
	self.Day = string.format(_G.LSTR("%d天"), self.Index)
	self.RewardsStatus = Value.RewardsStatus
	local IsWillGet = ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet == Value.RewardsStatus
	local IsGot = ProtoCS.Game.Activity.RewardStatus.RewardStatusDone == Value.RewardsStatus
    local TempItemList = Value.RewardList or {}
	local ItemList = {}
	for _, v in ipairs(TempItemList) do
		if v.ItemID and v.ItemID ~= 0 then
			local Item = ItemUtil.CreateItem(v.ItemID, v.Num)
			Item.IsShowNum = true
			Item.IsReward = IsWillGet
			Item.IsMask = IsGot
			table.insert(ItemList, Item)
		end
	end
	self.RewardList:UpdateByValues(ItemList)
end

function OpsReturnSigninItemVM:IsEqualVM()
	return false
end

--要返回当前类
return OpsReturnSigninItemVM