
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local TreasureChestItemVM = require("Game/TreasureChest/VM/TreasureChestItemVM")
local TreasureChestCfg = require("TableCfg/TreasurechestCfg")

---@class TreasureChestVM : UIViewModel
local TreasureChestVM = LuaClass(UIViewModel)

---Ctor
function TreasureChestVM:Ctor()
	self.OptionList = UIBindableList.New(TreasureChestItemVM)

	self.CurrentNum = 0
	self.MAXNum = 0
	self.TextHintText = nil
	self.GID = 0

	self.SingleMiniKeyCallBackFlag = true
end

function TreasureChestVM:OnInit()
	self.CurrentNum = 0
	self.MAXNum = 0
	self.TextHintText = nil
end

function TreasureChestVM:OnShutdown()
	
end

function TreasureChestVM:UpdateViewDataByResID(ResID, Num)
	self.MAXNum = Num
	self:UpdateTextHintText()
	local TempTreasureChestCfg = TreasureChestCfg:FindCfgByKey(ResID)

	if TempTreasureChestCfg == nil then
		FLOG_ERROR("TreasureChestVM:UpdateViewDataByResID   TempTreasureChestCfg is nil")
		return
	end

	local Data = {}
	local CfgItems = TempTreasureChestCfg.Item
	if CfgItems == nil then
		return
	end
	for i = 1, #CfgItems do
		if CfgItems[i].ItemID ~= nil and CfgItems[i].ItemID ~= 0 then
			table.insert(Data, CfgItems[i])
		end
	end
	self.OptionList:UpdateByValues(Data, nil, true)
end

function TreasureChestVM:UpdateViewData()
	local Items = self.OptionList:GetItems()
	if Items == nil then
		return
	end
	for _, value in ipairs(Items) do
		value:OnInit()
	end

	self:UpdateCurrentNum()
end

function TreasureChestVM:OnCheckNumIsValid()
	local MaxNum = self.MAXNum or 0
	local CurrentNum = self.CurrentNum or 0
	return CurrentNum < MaxNum
end

function TreasureChestVM:UpdateTextHintText()
	if self.MAXNum == nil then
		self.MAXNum = 0
	end
	if self.CurrentNum == nil then
		self:SetCurrentNum(0)
	end
	self.TextHintText = string.format(LSTR(1230004), self.CurrentNum, self.MAXNum)	--- "可选择奖励次数：%d%/d"
end

function TreasureChestVM:UpdateCurrentNum()
	local TempCurrentNum = 0
	local Items = self.OptionList:GetItems()
	if Items == nil then
		return
	end
	for _, value in ipairs(Items) do
		if value.IsSelected then
			TempCurrentNum = TempCurrentNum + value.SelectedNum
		end
	end
	self:SetCurrentNum(TempCurrentNum)
	self:UpdateTextHintText()
	_G.EventMgr:SendEvent(_G.EventID.BagTreasureChestNumChanged)

	self:SetSingleFlag(true)
end

function TreasureChestVM:SetCurrentNum(NewValue)

	if NewValue == nil or NewValue < 0 then
		NewValue = 0
	end
	if NewValue > self.MAXNum then
		return
	end

	self.CurrentNum = NewValue
end

function TreasureChestVM:OnClickRecommend()
	local ExchangeItem = {}
	local Items = self.OptionList:GetItems()
	if Items == nil then
		FLOG_ERROR("TreasureChestVM:OnClickRecommend Items is nil")
		return
	end
	for _, value in ipairs(Items) do
		if value.IsSelected then
			local ItemData = {
				ItemResID = value.ResID,
				ItemNum = value.SelectedNum
			}
			table.insert(ExchangeItem, ItemData)
		end
	end


	_G.TreasureChestMgr:SendChatMsgPushMessage(ExchangeItem)
end

function TreasureChestVM:GetSingleFlag()
	return self.SingleMiniKeyCallBackFlag
end

function TreasureChestVM:SetSingleFlag(Value)
	self.SingleMiniKeyCallBackFlag = Value
end

return TreasureChestVM