--
-- Author: ZhengJanChuan
-- Date: 2025-08-04 19:13
-- Description:
--
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

---@class OpsReturnSigninRewardItemVM : UIViewModel
local OpsReturnSigninRewardItemVM = LuaClass(UIViewModel)

---Ctor
function OpsReturnSigninRewardItemVM:Ctor()
    self.ItemQualityIcon = nil
    self.IsQualityVisible = false
    self.Icon = nil
    self.Num = nil
    self.ItemNum = nil
    self.NumVisible = false
    self.IsMask = false
    self.ItemColorAndOpacity =  _G.UE.FLinearColor(1, 1, 1, 1) --物品颜色透明度设置
    self.IconReceivedVisible = false
    self.ItemLevelVisible = false
    self.IsReward = false
    self.Name = ""
    self.ItemSlotType = nil
	self.BtnCheckVisible = false
	self.IconChooseVisible = false
end

function OpsReturnSigninRewardItemVM:OnInit()
end

function OpsReturnSigninRewardItemVM:OnBegin()
end

function OpsReturnSigninRewardItemVM:OnEnd()
end

function OpsReturnSigninRewardItemVM:OnShutdown()
end

function OpsReturnSigninRewardItemVM:UpdateVM(Value, Params)
    local IsValid = nil ~= Value and Value.ResID ~= nil
	self.IsValid = IsValid

	if not IsValid then
		return
	end

    local ValueResID = Value.ResID
	self.Item = Value
	self.GID = Value.GID
	self.ResID = ValueResID

	if nil ~= Value.IsShowNumProgress then
		self.IsShowNumProgress = Value.IsShowNumProgress
	else
		self.IsShowNumProgress = false
	end

    if self.IsShowNumProgress == true then
		self.Num = ItemUtil.GetNumProgressFormat(BagMgr:GetItemNum(ValueResID), Value.Num)
	else
		self.Num = ItemUtil.GetItemNumText(Value.Num)
	end

    self.IsMask = Value.IsMask or false
	self.IconReceivedVisible = Value.IsMask or false

    if Value.IsQualityVisible ~= nil then
		self.IsQualityVisible = Value.IsQualityVisible
	else
		self.IsQualityVisible = true
	end

    if Value and Value.ItemSlotType ~= nil then
        self.ItemSlotType = Value.ItemSlotType
    end

    if self.ItemSlotType then
        self.ItemQualityIcon = ItemUtil.GetSlotColorIcon(self.ResID, self.ItemSlotType)
    else
        self.ItemQualityIcon = ItemUtil.GetItemColorIcon(self.ResID)
    end

    self.NumVisible =  self.IsShowNumProgress == true
    if Value.IsShowNum ~= nil then --Value传入的IsShowNum优先级更高
        self.NumVisible = Value.IsShowNum
    end

    self.IsReward = Value.IsReward or false

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
	end
end

function OpsReturnSigninRewardItemVM:IsEqualVM()
	return false
end

--要返回当前类
return OpsReturnSigninRewardItemVM