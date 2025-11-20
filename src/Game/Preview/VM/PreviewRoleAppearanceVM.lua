---
--- Author: rock
--- DateTime: 2025-3-3 11:06
--- Description:时装预览VM
---
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local UIBindableList = require("UI/UIBindableList")
local PreviewEquipPartVM = require("Game/Preview/VM/PreviewEquipPartVM")
local StoreDefine = require("Game/Store/StoreDefine")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ClosetSuitCfg = require("TableCfg/ClosetSuitCfg")

---@class PreviewRoleAppearanceVM : UIViewModel
local PreviewRoleAppearanceVM = LuaClass(UIViewModel)

local EquipmentType = ProtoRes.EquipmentType

function PreviewRoleAppearanceVM:Ctor()
    self.IsPreviewSuit = true -- 是否预览的套装
	self.EquipPartList = UIBindableList.New(PreviewEquipPartVM)
    self.EquipPartListData = nil
	self.RegionDyesList = nil --染色数据列表(比如套装就包含了里面所有装备染色数据)
    
    self.ProductName = nil  --时装名称
    self.GenderLimit = 0    --所预览装备的性别
    self.bEnableHatOrganBtn = false --是否有头盔机关(判断按钮是不是灰掉)
    
	self:ResetInitState()
end

function PreviewRoleAppearanceVM:OnShutdown()
    self.EquipPartList:Clear()
end

--重置面板状态数据
function PreviewRoleAppearanceVM:ResetInitState()
    self.bIsAllCameraState = true --是否全身镜头,否则半身
    self.bIsShowWeapon = false --是否显示武器
    self.bIsHoldWeapon = false --是否拔出武器
    self.bIsShowHat = true      --帽子开关
    self.bIsShowHatOrgan = false --头盔机关开关
    self.bIsShowRawAvatar = true --素体
end

function PreviewRoleAppearanceVM:UpdateViewDataByPreView(EquipData)
    self.IsPreviewSuit = EquipData.IsPreviewSuit
	self.ProductName = EquipData.Name
    self.GenderLimit = EquipData.GenderLimit
	self.RegionDyesList = EquipData.RegionDyesList
	self:UpdateEquipPartList(EquipData.Items)
end

---@type 刷新右边预览的装备物品列表
---@param EquipItemList table @物品数据
function PreviewRoleAppearanceVM:UpdateEquipPartList(EquipItemList)
    self.EquipPartListData = EquipItemList
    self.EquipPartList:UpdateByValues(EquipItemList, nil)

    --头盔机关
    self.bEnableHatOrganBtn = false
	for Index, v in ipairs(self.EquipPartListData) do
		if v.EquipmentID ~= nil then
			local TempEquipmentCfg = EquipmentCfg:FindCfgByEquipID(v.EquipmentID)
			if TempEquipmentCfg ~= nil and 
			TempEquipmentCfg.Part == ProtoCommon.equip_part.EQUIP_PART_HEAD and 
			TempEquipmentCfg.EquipmentType == EquipmentType.HEAD_ARMOUR then
				if _G.EquipmentMgr:IsEquipHasGimmick(v.EquipmentID) then
					self.bEnableHatOrganBtn = true
					break
				end
			end
		end
	end
end

---@type 变更包含物品列表选中状态
---@param Index number @包含物品索引
function PreviewRoleAppearanceVM:ChangeEquipPart(Index, IsSelect)
	if Index == nil then
		for i = 1, self.EquipPartList:Length() do
			self.EquipPartList.Items[i]:OnSelectedChange(IsSelect)
		end
	else
		self.EquipPartList.Items[Index]:OnSelectedChange(IsSelect)
	end
end

---@type 按钮右上角眼睛状态
---@param Index number @包含物品索引
function PreviewRoleAppearanceVM:GetEquipPartEyeBtnState(Index)
	if Index ~= nil then
		local ItemViewData = self.EquipPartList.Items[Index]
		if ItemViewData ~= nil then
			return not ItemViewData.SelectBtnState
		end
	end
	return false
end

---@type 预览的装备是否有染色
---@param EquipmentID number @装备ID
function PreviewRoleAppearanceVM:GetIsRegionDyes(EquipmentID)
	if self.RegionDyesList == nil or EquipmentID == nil then
		return false
	end
	
	--当前装备的染色数据
	local RegionDyes = {}
	for index, value in ipairs(self.RegionDyesList) do
		if value.EquipID == EquipmentID then
			RegionDyes = value.RegionDyes
			break
		end
	end
	if #RegionDyes <= 0 then
		return false
	end
	for _, v in ipairs(RegionDyes) do
		if v.ID ~= 0 then
			if v.ColorID ~= 0 then
				return true
			end
		end
	end
	return false
end

return PreviewRoleAppearanceVM