---
--- Author: anypkvcai
--- DateTime: 2021-09-01 14:58
--- Description:弃用，待删除
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local ItemUtil = require("Utils/ItemUtil")
local MajorUtil = require("Utils/MajorUtil")
local BagMgr = require("Game/Bag/BagMgr")
local ProtoCommon = require("Protocol/ProtoCommon")


local ItemDBCfg = require("TableCfg/ItemCfg")
local AttrDefCfg = require("TableCfg/AttrDefCfg")
-- local RoleInitCfg = require("TableCfg/RoleInitCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")

local EquipmentAttrItemVM = require("Game/Equipment/VM/EquipmentAttrItemVM")
local EquipmentMsgItemVM = require("Game/Equipment/VM/EquipmentMsgItemVM")

local LSTR = _G.LSTR
local FLOG_WARNING = _G.FLOG_WARNING
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL

---@class ItemTipsVM : UIViewModel
---@field Item table @Item
---@field GID number    @服务器生成的物品ID
---@field ResID number    @物品资源ID 对应c_item_cfg中的ResID
---@field Num number    @普通数量
---@field HQNum number @高品质数量
---@field Name string @物品名
---@field Icon string @图标资源路径
---@field IsBind boolean @是否绑定
---@field IsUnique boolean  @是否唯一
---@field IsEquipment boolean @是否装备
---@field TypeName string @类型名
---@field ItemType number  @类型
---@field ItemColor string @颜色
---@field ItemLevel number @品级
---@field LevelName string @品级名称 一般物品：品级 幻卡：稀有度
---@field LevelText string @品级 一般物品只显示数值"Level" 装备要显示数值及和已装备的物品比较增加或减少的数值"Level([+|-]x)"
---@field IsShowLevel boolean
---@field Desc string    @物品描述
---@field IsHQ boolean
---@field FreezeTime number
---@field IsMarketable boolean
---@field IsRecoverable boolean
---@field RecoverNum number
---@field IsCanDrop boolean
---@field InfoLstVisible boolean
---@field BindableListInfo table<EquipmentMsgItemVM>
local ItemTipsVM = LuaClass(UIViewModel)

---Ctor
---@param Source number
---@param Index number
function ItemTipsVM:Ctor(Source, Index)
	self.Source = Source
	self.Index = Index
	self.Item = nil

	self.GID = nil
	self.ResID = nil
	self.Num = 0
	self.HQNum = 0
	self.PageTabIndex = 0 --用于记录背包页签索引

	self.Name = nil
	self.Icon = nil

	self.IsBind = false
	self.IsUnique = false
	self.IsEquipment = false

	self.TypeName = ""

	self.ItemType = nil
	self.ItemColor = nil
	self.ItemLevel = nil

	self.LevelText = ""
	self.IsShowLevel = true

	self.Desc = ""
	self.InHeadingDescVisible = false
	self.PanelDescVisible = false
	self.IsHQ = false

	self.FreezeTime = 0
	self.IsMarketable = false
	self.IsRecoverable = false
	self.RecoverNum = 0

	self.IsCanDrop = false
	self.IsUpdateButton = false
	self.InfoLstVisible = false
	self.BindableListInfo = nil
	self.lstEquipmentMoreFilterItemVM = nil

	self.IsClicked = true
	self.CD = 0 -- 当前被选中ItemCD
	self.CurrentSelectedItemVM = nil --当前被选中ItemVM

	self.SlotNum = 5	--魔晶石
	self.EmptyAllSlot = nil
	self.Slot01 = nil
	self.Slot02 = nil
	self.Slot03 = nil
	self.Slot04 = nil
	self.Slot05 = nil

	self.IsShowGetway = true
end

---UpdateVM
---@param Value table @csproto.Item
function ItemTipsVM:UpdateVM(Value)
	-- 考虑空格子情况
	if Value.ResID == nil then
		return
	end
	local ValueIsBind = Value.IsBind
	local ResID = Value.ResID
	self.Item = Value
	self.GID = Value.GID
	self.ResID = ResID

	if ItemUtil.BItemHasGetWay(self.ResID)  == false then
		self.IsShowGetway = false
	else
		if Value.IsShowGetway ~= nil then
			self.IsShowGetway = Value.IsShowGetway
		end
	end

	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
		FLOG_WARNING("ItemTipsVM:UpdateVM can't find item cfg, ResID =%d", ResID)
		return
	end
	local CfgNQHQItemID = Cfg.NQHQItemID
	local CfgItemType = Cfg.ItemType
	local CfgIsUnique = Cfg.IsUnique

	local IsHQ = (1 == Cfg.IsHQ)

	local NQItemID = IsHQ and CfgNQHQItemID or ResID
	local HQItemID = IsHQ and ResID or CfgNQHQItemID

	local NQNum = BagMgr:GetItemNum(NQItemID)
	local HQNum = BagMgr:GetItemNum(HQItemID)

	self.Num = NQNum
	self.HQNum = HQNum

	self.IsHQ = IsHQ
	self.IsNumVisible = NQItemID > 0
	self.IsHQNumVisible = HQItemID > 0
	self.IsAndVisible = 0 ~= CfgNQHQItemID

	--self.TypeName = Cfg.TypeName
	self.TypeName = ItemTypeCfg:GetTypeName(CfgItemType)

	self.ItemType = CfgItemType
	self.ItemColor = Cfg.ItemColor
	self.ItemLevel = Cfg.ItemLevel

	self.LevelText = tostring(Cfg.ItemLevel)
	self.IsShowLevel = Cfg.ItemLevel > 0
	-- ITEM_TYPE_DETAIL
	self.Name = ItemCfg:GetItemName(ResID)
	self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
	self.Desc = ItemCfg:GetItemDesc(ResID)
	self.BtnRigIsVisible = false		-- 禁用使用按钮
	if CfgItemType == ITEM_TYPE_DETAIL.COLLAGE_MOUNT then --坐骑描述相关
		self.InHeadingDescVisible = true
		self.PanelDescVisible = true
		self.BtnRigIsVisible = true
	elseif CfgItemType == ITEM_TYPE_DETAIL.MISCELLANY_CURRENCY then --货币类型
		self.IsShowLevel = false
		self.IsShowHorizontalBox = false
		self.PanelDescVisible = true
	elseif self.Desc ~= "" then
		self.PanelDescVisible = true
	else
		self.InHeadingDescVisible = false
		self.PanelDescVisible = false
	end

	self.ProfLimit = Cfg.ProfLimit
	self.FreezeTime = Cfg.FreezeTime
	self.IsMarketable = Cfg.IsMarketable
	self.IsRecoverable = Cfg.IsRecoverable
	self.RecoverNum = Cfg.RecoverNum

	self.IsCanDrop = Cfg.IsCanDrop > 0

	self.IsUnique = CfgIsUnique > 0
	self.IsEquipment = ItemUtil.CheckIsEquipment(Cfg.Classify)

	self.IsBind = ValueIsBind

	self.StatusButtonVisible = ValueIsBind or CfgIsUnique
	self.StatusLineVisible = ValueIsBind and CfgIsUnique

	self.IsClicked = Value.IsClicked -- 当item物品为冷却时使用按钮不可点击
	self.CurrentSelectedItemVM = Value

	_G.EventMgr:SendEvent(_G.EventID.ItemTipsButtonViewOnUpdateBtn)
end

---UpdateTipsButton
---@param Value table
function ItemTipsVM:UpdateTipsButton(Value)
	local ValueIsEquipment = Value.IsEquipment
	local ValueIsCanDrop = Value.IsCanDrop
	if ValueIsEquipment ~= nil then
		self.IsEquipment = ValueIsEquipment
	end
	if ValueIsCanDrop ~= nil then
		self.IsCanDrop = ValueIsCanDrop
	end
	self.IsUpdateButton = true
end


function ItemTipsVM:FindEquipAttrInfo(AttrInfo, Attr)
	for i = 1, #AttrInfo do
		if AttrInfo[i].Attr == Attr then
			return AttrInfo[i]
		end
	end
	return nil
end


function ItemTipsVM:GetCurrentSelectedItemCd()
	return self.CurrentSelectedItemVM.ItemCD
end

function ItemTipsVM:SetRButtonIsEnable()
	if self:GetCurrentSelectedItemCd() == nil then
		return
	end
	if self:GetCurrentSelectedItemCd() > 0 then
		self.IsClicked = false
	else
		self.IsClicked = true
	end

end
return ItemTipsVM