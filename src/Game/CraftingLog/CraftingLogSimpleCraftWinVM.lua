--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-03-11 09:42:23
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-03-11 15:31:29
FilePath: \Client\Source\Script\Game\CraftingLog\CraftingLogSimpleCraftWinVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CraftingLogMgr = require("Game/CraftingLog/CraftingLogMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")

---@class CraftingLogSimpleCraftWinVM : UIViewModel

local CraftingLogSimpleCraftWinVM = LuaClass(UIViewModel)

function CraftingLogSimpleCraftWinVM:OnInit()
end

---Ctor
---@field slotItemImg string @物品图标
---@field TextNameLabel string @物品名称
---@field TextAmountLabel string @制作数量
---@field TextCostLabel string @制作消耗
function CraftingLogSimpleCraftWinVM:Ctor()
    self:Reset()
end

function CraftingLogSimpleCraftWinVM:Reset()
    self.TextNameLabel = ""
    self.TextAmountLabel = ""
    self.TextCostLabel = ""
    self.SlotItemImg = ""
    self.ItemQualityImg = ""
    self.ProgressValue = 0
    self.CostScoreColor = nil
    self.IsClickCloseBtn = false
    self:ResetCounts()
end

function CraftingLogSimpleCraftWinVM:OnShutdown()
    self:Reset()
    self.MakeState = nil
end

function CraftingLogSimpleCraftWinVM:OnEnd()
end

function CraftingLogSimpleCraftWinVM:ResetCounts()
    self.TotalMakeCount = 0
    self.MakeCount = 0
end

function CraftingLogSimpleCraftWinVM:AddMakeCounts(Num)
    if self:GetProgress() == 1 then
        return
    end
    local TotalMakeCount = self.TotalMakeCount
    local MakeCount = self.MakeCount + Num
    self.MakeCount = MakeCount >= TotalMakeCount and TotalMakeCount or MakeCount
end

function CraftingLogSimpleCraftWinVM:GetProgress()
	return self.MakeCount / self.TotalMakeCount
end

function CraftingLogSimpleCraftWinVM:GetLeftNum()
	return self.TotalMakeCount - self.MakeCount
end

function CraftingLogSimpleCraftWinVM:OnShow(Data, TotalMakeCount, bIsReconnect)
    if not bIsReconnect then
        self:ResetCounts()
    end
    self.TotalMakeCount = TotalMakeCount
    self.SlotItemImg = ItemCfg.GetIconPath(ItemCfg:FindCfgByKey(CraftingLogMgr.NowPropData.ProductID).IconID)
    local ResID = Data.CanHQ == 0 and Data.ProductID or Data.HQProductID
    self.TextNameLabel = ItemCfg:GetItemName(ResID)
    self.ItemQualityImg = ItemUtil.GetSlotColorIcon(ResID, ItemDefine.ItemSlotType.Item96Slot)
    self:Update()
end

--- 设置成功失败
function CraftingLogSimpleCraftWinVM:Update()
    self.TextAmountLabel = string.format("%d/%d", self.MakeCount, self.TotalMakeCount)
    local PropData = CraftingLogMgr.NowPropData
    local Cost = PropData.FastCraft == 1 and PropData.FastCraftCost or PropData.SimpleCraftCost
    self.TextCostLabel = (self.TotalMakeCount - self.MakeCount) * Cost
    local PlayerHaveScore = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
    if self.TextCostLabel and tonumber(self.TextCostLabel) > PlayerHaveScore then
        _G.CraftingLogMgr.ScoreNotEnough = true
        self.CostScoreColor = "EF9FABFF" --红色
    else
        _G.CraftingLogMgr.ScoreNotEnough = false
        self.CostScoreColor = "D1BA8EFF" --金色
    end
end

function CraftingLogSimpleCraftWinVM:OnSimpleMakeRltCounts(CrafterSimpleRsp)
	FLOG_INFO("37Craft:OnSimpleMakeRltCounts")
	if CrafterSimpleRsp then
		self:AddMakeCounts(CrafterSimpleRsp.SuccessNum)
        _G.EventMgr:SendEvent(_G.EventID.CraftingSimpleRefreshUI)
		--SimpleVM:GetProgress() == 1用来确定是否为立即完成的回包（有可能是上次制作的回包）
		if self.IsClickRightAway and self:GetProgress() == 1 then
			self.IsClickRightAway = false
		end
	end
end

function CraftingLogSimpleCraftWinVM:OnSimpleMakeOver()
	FLOG_INFO("37Craft:OnSimpleMakeOver")
	--中止了就请求退出状态
	if self.IsClickCloseBtn then
		self.IsClickCloseBtn = false
		self:QuitSimpleMake()
		return
	end

	--还没完成就继续制作
    if self:GetProgress() ~= 1 then
	    _G.EventMgr:SendEvent(_G.EventID.CraftingSimpleToMake)
    end
end

function CraftingLogSimpleCraftWinVM:QuitSimpleMake()
	--_G.CrafterMgr:QuitMake()
    _G.CrafterMgr:QuitMakState()
end

return CraftingLogSimpleCraftWinVM
