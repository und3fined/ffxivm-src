---
--- Author: anypkvcai
--- DateTime: 2021-08-17 16:20
--- Description:https://iwiki.woa.com/pages/viewpage.action?pageId=2015889015

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local CondCfg = require("TableCfg/CondCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local BagMgr = require("Game/Bag/BagMgr")
-- local ColorUtil = require("Utils/ColorUtil")
local ITEM_TYPE = ProtoCommon.ITEM_TYPE
local ItemSource = ItemDefine.ItemSource
local ProtoRes = require("Protocol/ProtoRes")
local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE

local FLinearColor = _G.UE.FLinearColor


---@class ItemVM : UIViewModel
---@field Item table @Item
---@field IsValid boolean @是否有效物品
---@field GID number    @服务器生成的物品ID
---@field ResID number    @物品资源ID 对应c_item_cfg中的ResID
---@field Num number    @普通数量
---@field Name string @物品名
---@field Icon string @图标资源路径
---@field ItemType number  @类型
---@field ItemColor string @颜色
---@field ItemLevel number @品级
---@field IsBind boolean @是否绑定
---@field IsUnique boolean  @是否唯一
---@field IsHQ boolean @是否HQ
---@field NQHQItemID boolean @NQHQ物品ID
---@field NumVisible boolean @是否显示数量
---@field IsInScheme boolean @是否显示套装标志
local ItemVM = LuaClass(UIViewModel)

--物品选中后的表现
ItemVM.SelectMode = {
	Select = "IsSelect",
	Preview = "IsPreview",
	Tick = "IsSelectTick",
	IsFishLoop = "IsFishLoop",
}

ItemVM.SelcteStatus = {Change = 1, Superposition = 2} -- 1，改变选中状态，2，叠加选中状态支持多种

ItemVM.ItemColorType =
{
	-- ITEM_COLOR_WHITE = 1,	-- 白
	-- ITEM_COLOR_GREEN = 2,	-- 绿
	-- ITEM_COLOR_BLUE = 3,	-- 蓝
	-- ITEM_COLOR_PURPLE = 4,	-- 紫
	-- ITEM_COLOR_RED = 6,	-- 红,
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_01.UI_Quality_Slot_NQ_01'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_02.UI_Quality_Slot_NQ_02'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_03.UI_Quality_Slot_NQ_03'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_04.UI_Quality_Slot_NQ_04'",
}

ItemVM.ItemHQColorType =
{
	-- ITEM_COLOR_WHITE = 1,	-- 白
	-- ITEM_COLOR_GREEN = 2,	-- 绿
	-- ITEM_COLOR_BLUE = 3,	-- 蓝
	-- ITEM_COLOR_PURPLE = 4,	-- 紫
	-- ITEM_COLOR_ORANGE = 5,	-- 橙
	-- ITEM_COLOR_RED = 6,	-- 红,
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_01.UI_Quality_Slot_HQ_01'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_02.UI_Quality_Slot_HQ_02'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_03.UI_Quality_Slot_HQ_03'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_04.UI_Quality_Slot_HQ_04'",
}

---Ctor
function ItemVM:Ctor()
	self.Source = nil
	self.IsCanBeSelected = true
	self.IsShowNum = true
	self.IsShowNumProgress = false
	self.IsQualityVisible = true

	self.Item = nil
	self.IsValid = false

	self.GID = nil
	self.ResID = nil
	self.Num = nil
	self.Name = nil
	self.Icon = nil

	self.ItemType = nil
	self.ItemColor = nil
	self.ItemLevel = 0

	self.IsBind = false
	self.IsUnique = false

	self.IsHQ = false
	self.NQHQItemID = 0

	self.NumVisible = true

	self.ItemLevelVisible = false
	self.IconChooseVisible = false
	self.IconReceivedVisible = false

	self.IsMask = false

	self.IsObtain = false
	self.ItemQualityIcon = self.ItemColorType[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE]

	self.SingID = nil
	self.IsNeedProps = nil


	self.IsShowGetway = true
	self.IsShowHorizontalBox = true
	self.IsShowItemGrade = true
	self.IsShowFavorite = false
	self.FavoriteToggle = false
	self.IsShowStatus = true

	self.Cond = nil --物品状态/限制
	self.Func = nil -- 物品功能


	--选中样式
	for key, value in pairs(ItemVM.SelectMode) do
		self[value] = false
		self[key] = false
	end
	self.SelectChangedCallback = nil

	self.ItemColorAndOpacity = FLinearColor(1, 1, 1, 1) --物品颜色透明度设置

end

function ItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.GID == self.GID
end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数， {Source = ItemSource.Bag, IsCanBeSelected = false, IsShowNum = false}
---物品等级是否需要隐藏 已经有了 ShowItemLevel 麻烦就用这一个。不要每个人都加一个不同的变量。
function ItemVM:UpdateVM(Value, Params)
	local IsValid = nil ~= Value and Value.ResID ~= nil
	self.IsValid = IsValid

	if not IsValid then
		return
	end

	if Value.ResID == 0 then
		self.Icon = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_Empty.UI_Quality_Slot_Empty'"
		self.IsQualityVisible = Value.IsQualityVisible or false
	end
	if Params == nil or Params.IsShowSelectStatus == nil then
		self.IsShowSelectStatus = true
	else
		self.IsShowSelectStatus = Params.IsShowSelectStatus
	end
	self.IsDaily = false
	if Params ~= nil then
		if Params.Source ~= ItemSource.MatchReward then
			self.SelectedMode = ItemVM.SelectMode.Select
		end
		if Params.Source == ItemSource.FishBait then
			self.SelectedMode = ItemVM.SelectMode.Tick
		end

		self.SelectChangedCallback = Params.SelectChangedCallback
		Params.SelectedMode = Value.SelectedMode
		self:UpdateParams(Params)
	else
		self:UpdateParams({SelectedMode = Value.SelectedMode})
	end

	local ValueAwardID = Value.AwardID
	local ValueResID = Value.ResID
	self.Item = Value
	self.GID = Value.GID
	self.ResID = ValueResID
	self.PlayAddEffect = Value.PlayAddEffect
	self.OriginalNum = Value.OriginalNum
	self.IncrementedNum = Value.IncrementedNum
	
	if self.IsShowNumProgress == true then
		self.Num = ItemUtil.GetNumProgressFormat(Value.LeveQuest ~= nil and _G.LeveQuestMgr:GetCanPayItemNum(ValueResID) or BagMgr:GetItemNum(ValueResID), Value.Num)
	else
		self.Num = ItemUtil.GetItemNumText(Value.Num)
	end

	self.IsMask = Value.IsMask or false

	if ValueAwardID ~= nil then
		self.AwardID = ValueAwardID
		self.ExpireTime = Value.ExpireTime
	end

	if Value.IsQualityVisible ~= nil then
		self.IsQualityVisible = Value.IsQualityVisible
	else
		self.IsQualityVisible = true
	end

	if Value.IsObtain ~= nil then
		self.Obtained = Value.IsObtain
	end

	if nil ~= Value.ShowChoose then
		self.IconChooseVisible = Value.ShowChoose
	end

	if nil ~= Value.ShowReceived then
		self.IconReceivedVisible = Value.ShowReceived
	else
		self.IconReceivedVisible = false
	end

	local selfFuncID = nil
	local selfCondID = nil
	if Value.IsScore then
		local Cfg = ScoreCfg:FindCfgByKey(ValueResID)
		if nil == Cfg then
			return
		end

		self.Icon = Cfg.IconName
	else
		local Cfg = ItemCfg:FindCfgByKey(ValueResID)
		if nil == Cfg then
			return
		end

		if Value.ItemName ~= nil then
			self.Name = Value.ItemName
		else
			self.Name = ItemCfg:GetItemName(ValueResID)
		end

		if Cfg.IconID ~= nil and Cfg.IconID ~= 0 then
			self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
		end

		self.ItemMainType = Cfg.ItemMainType
		self.ItemType = Cfg.ItemType
		self.Classify = Cfg.Classify

		self.ItemLevel = Cfg.ItemLevel
		self.IsTaskItem = (Cfg.IsTaskItem == 1)
		self.InitBindState = Cfg.InitBindState
		self.Grade = Cfg.Grade
		self.IsMarketable = Cfg.IsMarketable
		self.IsRecoverable = Cfg.IsRecoverable
		self.IsCanStore = Cfg.IsCanStore
		self.IsCanBatchUse = Cfg.IsCanBatchUse
		self.IsCanDrop = Cfg.IsCanDrop

		self.IsUnique = Cfg.IsUnique > 0

		self.NumVisible = (self.IsShowNum and Cfg.MaxPile > 1 ) or self.IsShowNumProgress == true
		if Value.IsShowNum ~= nil then --Value传入的IsShowNum优先级更高
			self.NumVisible = Value.IsShowNum
		end

		self.IsHQ = (1 == Cfg.IsHQ)
		if self.IsHQ then
			self.ItemQualityIcon = ItemVM.ItemHQColorType[Cfg.ItemColor]
		else
			self.ItemQualityIcon = ItemVM.ItemColorType[Cfg.ItemColor]
		end

		if Params and Params.ItemSlotType ~= nil then
			self.ItemQualityIcon = ItemUtil.GetSlotColorIcon(self.ResID, Params.ItemSlotType)
		end

		self.NQHQItemID = Cfg.NQHQItemID


		self.SingID = Cfg.SingID
		self.IsNeedProps = Cfg.IsNeedProps
		selfCondID = Cfg.UseCond
		selfFuncID = Cfg.UseFunc
	end

	self.IsBind = Value.IsBind

	if selfFuncID ~= nil then
		self.Func =  FuncCfg:FindCfgByKey(selfFuncID) -- 物品功能
	end
	if selfCondID ~= nil then
		self.Cond = CondCfg:FindCfgByKey(selfCondID) --物品状态/限制
	end

	local Attr = Value.Attr
	if nil == Attr then
		return
	end

	local ItemType = Attr.ItemType
	if ItemType == ITEM_TYPE.ITEM_TYPE_TASK then
		self.IsUnique = false
		self.IsTaskItem = true
		self.IsMarketable = false
		self.IsRecoverable = false
		self.IsCanStore = false
		self.IsCanBatchUse = false
		self.IsCanDrop = false
	end
end

--物品等级是否需要隐藏 已经有了 ShowItemLevel 麻烦就用这一个。不要每个人都加一个不同的变量。
function ItemVM:UpdateParams(Params)
	if nil == Params then
		return
	end
	local ParamsIsCanBeSelected = Params.IsCanBeSelected
	local ParamsIsShowNum = Params.IsShowNum
	local ParamsIsShowNumProgress = Params.IsShowNumProgress
	self.Source = Params.Source

	if nil ~= ParamsIsCanBeSelected then
		self.IsCanBeSelected = ParamsIsCanBeSelected
	end

	if nil ~= ParamsIsShowNum then
		self.IsShowNum = ParamsIsShowNum
	end

	if nil ~= ParamsIsShowNumProgress then
		self.IsShowNumProgress = ParamsIsShowNumProgress
	else
		self.IsShowNumProgress = false
	end

	local ItemVMSelectMode = ItemVM.SelectMode
	local ParamsSelcteStatus = Params.SelcteStatus
	if nil ~= Params.SelectedMode then
		for key, value in pairs(ItemVMSelectMode) do
			if ParamsSelcteStatus ~= nil and ParamsSelcteStatus == ItemVM.SelcteStatus.Superposition and value == Params.SelectedMode then
				self[key] = true
			else
				if value == Params.SelectedMode then
					self[key] = true
				else
					self[key] = false
					self[value] = false
				end
			end
		end
		self.SelectedMode = Params.SelectedMode
	end

	if nil ~= Params.ShowItemLevel then
		self.ItemLevelVisible = Params.ShowItemLevel
	end
	
end


function ItemVM:SetNumProgress(Value)
	self.Num = ItemUtil.GetNumProgressFormat(Value, self.Item.Num)
end

function ItemVM:SetLeveQuestNumProgress(Value)
	self.Num = ItemUtil.GetNumProgressFormat(_G.LeveQuestMgr:GetCanPayItemNum(Value), self.Item.Num)
end

function ItemVM:SetItemOpacity(Opacity)
	local ColorAndOpacity =  FLinearColor(1, 1, 1, Opacity)
	self.ItemColorAndOpacity = ColorAndOpacity
end


function ItemVM:AdapterOnGetCanBeSelected()
	return self.IsCanBeSelected
end


function ItemVM:OnSelectedChange(bSelect)
	if self.SelectChangedCallback then
		self.SelectChangedCallback(self, bSelect)
		return
	end
	if not self.IsShowSelectStatus then
		for key, value in pairs(ItemVM.SelectMode) do
			if self[key] then
				self[value] = false
			end
			if not self[key] then
				self[value] = false
			end
		end
		return
	end
	for key, value in pairs(ItemVM.SelectMode) do
		local SelcteStatus = self[key]
		if self.SelectedMode == value and not SelcteStatus then
			self[key] = true
		end
		if self[key] then
			self[value] = bSelect
		end
		if not self[key] then
			self[value] = false
		end
	end
end

return ItemVM
