
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ItemCfg = require("TableCfg/ItemCfg")

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Game.ChooseTreasureChest

---@class TreasureChestMgr : MgrBase
local TreasureChestMgr = LuaClass(MgrBase)

function TreasureChestMgr:OnInit()
	self.CurrentTreasureGID = 0
	self.CurrentTreasureResID = 0
end

function TreasureChestMgr:OnBegin()
end

function TreasureChestMgr:OnEnd()
end

function TreasureChestMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHOOSETREASURECHEST, SUB_MSG_ID.CS_CHOOSETREASURECHEST_CMD.EXCHANGE, self.OnNetMsgChooseTreasure)
end

function TreasureChestMgr:OnRegisterGameEvent()
end

function TreasureChestMgr:OnNetMsgChooseTreasure(MsgBody)
	local ExchangeItemInfo = MsgBody.ExchangeRsp.ExchangeItemInfo
	if nil == ExchangeItemInfo then
		return
	end
	local ItemList = {}
	for _, value in ipairs(ExchangeItemInfo) do
		local ItemResID = value.ItemResID
		local ItemNum = value.ItemNum
		if ItemNum > 0 then
			local TempItemCfg = ItemCfg:FindCfgByKey(ItemResID)
			local MaxPile = TempItemCfg.MaxPile or 0
			if ItemNum <= MaxPile then
				--- 没超过堆叠上限，正常insert
				local ItemData = {}
				ItemData.ResID = ItemResID
				ItemData.Num = ItemNum
				table.insert(ItemList,ItemData)
			else
				--- 超过堆叠上限，每次insert进去堆叠上限个，最后一个把剩下的放进去
				local ForeachNum = math.ceil(ItemNum / MaxPile)
				for Index = 1, ForeachNum do
					local ItemData = {}
					ItemData.ResID = ItemResID
					ItemData.Num = Index ~= ForeachNum and MaxPile or ItemNum % MaxPile == 0 and MaxPile or ItemNum % MaxPile
					table.insert(ItemList,ItemData)
				end
			end
		end
	end
	_G.UIViewMgr:HideView(UIViewID.BagTreasureChestWin)
	if not table.is_nil_empty(ItemList) then
		_G.LootMgr:SetDealyState(true)
		_G.UIViewMgr:ShowView(UIViewID.CommonRewardPanel, { Title = LSTR(1230010), ItemList = ItemList } )--- 1230010 获得物品
	end
end

function TreasureChestMgr:SendChatMsgPushMessage(ExchangeItem)
	local MsgID = CS_CMD.CS_CMD_CHOOSETREASURECHEST
	local SubMsgID = SUB_MSG_ID.CS_CHOOSETREASURECHEST_CMD.EXCHANGE

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.ExchangeReq = {
		TreasureChestGID = self.CurrentTreasureGID,
		TreasureChestItemResID = self.CurrentTreasureResID,
		ExchangeItem = ExchangeItem
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 从背包使用自选宝箱道具
function TreasureChestMgr:OnUsedItemFromBag(ResID, GID, Num)
	_G.TreasureChestVM:UpdateViewDataByResID(ResID, Num)
	self.CurrentTreasureResID = ResID
	self.CurrentTreasureGID = GID
end

return TreasureChestMgr
