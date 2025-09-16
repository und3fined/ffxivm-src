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

---@class PreviewRoleAppearanceVM : UIViewModel
local PreviewRoleAppearanceVM = LuaClass(UIViewModel)

local EquipmentType = ProtoRes.EquipmentType

function PreviewRoleAppearanceVM:Ctor()
    self.IsPreviewSuit = true -- 是否预览的套装
    
    self.TitleText = nil --标题
    self.ProductName = nil  --时装名称
    self.IsMajorSameGender = true -- 是否与主角同性别

    self.bEnableHatOrganBtn = false --是否有头盔机关(判断按钮是不是灰掉)
    
    self.bIsAllCameraState = true --是否全身镜头,否则半身
    self.bIsShowWeapon = false --是否显示武器
    self.bIsHoldWeapon = false --是否拔出武器
    self.bIsShowHat = true      --帽子开关
    self.bIsShowHatOrgan = false --头盔机关开关
    self.bIsShowRawAvatar = true --素体

    self.EquipPartList = UIBindableList.New(PreviewEquipPartVM)
    self.EquipPartListData = nil
end

function PreviewRoleAppearanceVM:OnShutdown()
    self.EquipPartList:Clear()
end

function PreviewRoleAppearanceVM:UpdateViewDataByPreView(EquipData)
    self.IsPreviewSuit = EquipData.IsPreviewSuit
	self.TitleText = _G.LSTR(StoreDefine.LSTRTextKey.PreviewTittleText)
	self.ProductName = EquipData.Name
    self.IsMajorSameGender = EquipData.IsMajorSameGender
	self:UpdateEquipPartList(EquipData.Items)
end

---@type 刷新右边预览的装备物品列表
---@param EquipItemList table @物品数据
function PreviewRoleAppearanceVM:UpdateEquipPartList(EquipItemList)
    self.EquipPartListData = EquipItemList
    self.EquipPartList:UpdateByValues(EquipItemList, nil)

    --头盔机关
    self.bEnableHatOrganBtn = false
	for Index, v in ipairs(PreviewRoleAppearanceVM.EquipPartListData) do
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

return PreviewRoleAppearanceVM