local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EquipmentMgr = _G.EquipmentMgr
local ProtoRes = require("Protocol/ProtoRes")
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ColorCfg = require("TableCfg/DyeColorCfg")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
local UIUtil = require("Utils/UIUtil")
local ClosetCfg = require("TableCfg/ClosetCfg")
local ItemUtil = require("Utils/ItemUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")

local EndureState = EquipmentDefine.EndureState
local WearableState = EquipmentDefine.WearableState

---@class EquipmentSlotItemVM : UIViewModel
local EquipmentSlotItemVM = LuaClass(UIViewModel)

local QualityIconMap =
{
	[ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_01.UI_Quality_Slot_NQ_01'",
	[ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_02.UI_Quality_Slot_NQ_02'",
	[ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_03.UI_Quality_Slot_NQ_03'",
	[ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_04.UI_Quality_Slot_NQ_04'",
}

local WearableColorMap =
{
	[WearableState.Unwearable] = "6fbee9",
	[WearableState.OtherProfWearable] = "6fbee9",
}

function EquipmentSlotItemVM:Ctor()
	self.__IsSlotItemVM = true
    self.IconPath = nil
    self.Part = nil
	self.GID = nil
	self.ResID = nil
	self.bSelect = false
	self.bMask = false
	self.bBtnVisibel = true
	self.r = ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_NONE
	self.IsInScheme = false
	self.ProgressValue = 1.0
	self.bShowProgress = true
	self.OnClick = nil
	self.bInUse = false
	self.bShowQuality = true
	self.QualityIcon = ""
	self.EmptySlotOpacity = 1.0
	self.EndureState = EndureState.Normal
	self.bIsWearable = true
	self.WearableColor = WearableColorMap[WearableState.Wearable]

	self.bCheckShowRepair = false
	self.bShowRepair = false
	self.PlayRepairEffect = false
	self.bPlayAnimChange = false

	--region Glamours
	-- --self.bInGlamours = false -- 是否处于幻化系统(控制幻化Panel是否显示)
	-- self.DyeColor = nil -- 幻影模板染色id
	-- self.bShowArchiveActiveState = false --是否显示图鉴的激活状态
	-- self.ActiveStateText = "" --激活状态显示
	-- self.ActiveStateTextColor = "" --激活状态颜色
	-- self.ActivateState = 0 --激活状态
	-- self.InProjectionList = true --是否在幻影列表中
	-- self.bShowGlamourNotVisible = false --是否显示幻影在列表中不可见标志
	-- self.bShowImgDyeState = false --是否显示染色状态
	-- self.DyeColorValue = "ffffffff"
	-- self.DyeStatePath = ""
	-- self.bShowImgImproper = false --是否显示不可投影标志
	-- self.bAllStainUnlock = false --是否全部染色解锁
	--endRegion
end

function EquipmentSlotItemVM:IsEqualVM(Value)
    return true
end

function EquipmentSlotItemVM:UpdateVM(Value)
	local InPart = Value.Part
	local InResID = Value.ResID
	local InGID = Value.GID
	self.ParentType = Value.ParentType
	self:SetPart(InPart, InResID, InGID)
	self.bShowProgress = Value.bShowProgress
	local ActiveState = false
	self.ActivateState = ActiveState
	self.InProjectionList = Value.InProjectionList
	self.bShowArchiveActiveState = Value.bShowArchiveActiveState
	self.bShowGlamourNotVisible = Value.bShowGlamourNotVisible
	self.ActiveStateTextColor = Value.ActiveStateTextColor
	self.ActiveStateText = Value.ActiveStateText
	self.bMask = Value.bMask
	self.bAllStainUnlock = Value.bAllStainUnlock
	self.bBtnVisibel = Value.bBtnVisibel
	self.OnClick = Value.OnClick
end

---@param InPart ProtoCommon.equip_part
function EquipmentSlotItemVM:SetPart(InPart, InResID, InGID, IsAppearance)
	self.GID = InGID
    self.Part = InPart
	self.ResID = InResID
	self.Item = EquipmentMgr:GetItemByGID(self.GID)


	if (self.GID ~= nil and self.ResID == nil) then 
		self.ResID = self.Item and self.Item.ResID
	end

	local Cfg = nil
	if IsAppearance then
		Cfg = ClosetCfg:FindCfgByKey(self.ResID)
	else
		Cfg = ItemCfg:FindCfgByKey(self.ResID)
	end
	
	if Cfg ~= nil then
		self.EmptySlotOpacity = 1.0
		local WardrobeIconPath = WardrobeUtil.GetEquipmentAppearanceIcon(self.ResID)
		self.IconPath = IsAppearance and WardrobeIconPath or ItemCfg.GetIconPath(Cfg.IconID)
		local ItemColor = nil ~= Cfg.ItemColor and Cfg.ItemColor or ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_NONE
		self.QualityIcon = IsAppearance and QualityIconMap[ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] or ItemUtil.GetItemColorIcon(self.ResID)
		self.bShowQuality = true
	else
		self.EmptySlotOpacity = 0.1
		self.IconPath = EquipmentMgr:GetPartIcon(InPart)
		self.bShowQuality = false
	end

	self.CanImprove = _G.EquipmentMgr:CheckCanImprove(InResID)
	---更新耐久度
	self:UpdateEndureDeg()

	---更新可穿戴
	self:UpdateWearableState()
end

function EquipmentSlotItemVM:UpdateSchemeInfo()
	if self.Item then
		self.IsInScheme = self.Item.Attr.Equip.IsInScheme
	end
end

function EquipmentSlotItemVM:UpdateEndureDeg()
	if self.Item then
		self.ProgressValue = self.Item.Attr.Equip.EndureDeg / 10000
		self.EndureState = self.ProgressValue == 1.0 and EndureState.Full or EndureState.Normal
	else
		self.ProgressValue = 1.0
		self.EndureState = EndureState.Unavailable
	end
end

function EquipmentSlotItemVM:UpdateWearableState()
	if nil ~= self.Item then
		if EquipmentMgr:CanEquiped(self.Item.ResID, false) then
			self.bMask = false
			self.bIsWearable = true
		else
			self.bMask = true
			self.bIsWearable = false
			local OtherProfWearable = false
			local MajorRoleDetail = _G.ActorMgr:GetMajorRoleDetail()
			if nil ~= MajorRoleDetail then
				for _, ProfData in pairs(MajorRoleDetail.Prof.ProfList) do
					OtherProfWearable = OtherProfWearable or EquipmentMgr:CanEquiped(self.Item.ResID, false, ProfData.ProfID, ProfData.Level)
				end
			end
			self.WearableColor = OtherProfWearable and WearableColorMap[WearableState.OtherProfWearable] or
			 WearableColorMap[WearableState.Unwearable]
		end
	else
		self.bMask = false
		self.bIsWearable = true
	end
end

function EquipmentSlotItemVM:CheckInUse()
	local InUseItem = EquipmentMgr:GetEquipedItemByPart(self.Part)
	self.bInUse = InUseItem ~= nil and InUseItem.GID == self.GID
end

return EquipmentSlotItemVM