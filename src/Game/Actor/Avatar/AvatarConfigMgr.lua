--
-- Author: anypkvcai
-- Date: 2020-11-03 09:51:17
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")


---@class AvatarConfigMgr : MgrBase
local AvatarConfigMgr = LuaClass(MgrBase)

function AvatarConfigMgr:OnInit()
end

function AvatarConfigMgr:OnBegin()
	local ShowDefaultValue = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_SHOW_DEFAULT_EQUIPMENT, "Value")
	if ShowDefaultValue then
		_G.UE.UAvatarPartModifier_MeshMatch.SetOpenMissingLogic(ShowDefaultValue[1] == 1)
	end
	local AvatarMgr = _G.UE.UAvatarMgr:Get()
	local AvatarPartType = _G.UE.EAvatarPartType

	if AvatarMgr then
		AvatarMgr:RegisterBudget("AvatarPartModifier_BlendShape", 0.001)
		AvatarMgr:RegisterBudget("AvatarPartModifier_Stain", 0.0005)
		AvatarMgr:RegisterBudget("AvatarPartModifier_DressUp", 0.0005)		-- 捏脸后可能紧跟TaskDone，所以要分配预算
		AvatarMgr:RegisterBudget("DoExecuteTasksIfValid", 0.001)
		AvatarMgr:RegisterBudget("InitModifiers", 0.0015)

		-- debug
		-- AvatarMgr:AddPosKeyToWhiteList(AvatarPartType.NAKED_BODY_HEAD)
		-- AvatarMgr:AddPosKeyToWhiteList(_G.UE.EAvatarPartType.NAKED_BODY_HAIR)
		-- AvatarMgr:AddPosKeyToWhiteList(_G.UE.EAvatarPartType.HEAD_ARMOUR)
		-- AvatarMgr:AddPosKeyToWhiteList(_G.UE.EAvatarPartType.HEAD_ARMOUR)
		-- AvatarMgr:AddPosKeyToWhiteList(_G.UE.EAvatarPartType.BODY_ARMOUR)
		-- AvatarMgr:AddPosKeyToWhiteList(_G.UE.EAvatarPartType.ARM_ARMOUR)
		-- AvatarMgr:AddPosKeyToWhiteList(_G.UE.EAvatarPartType.LEG_ARMOUR)
		-- AvatarMgr:AddPosKeyToWhiteList(_G.UE.EAvatarPartType.FOOT_ARMOUR)
		-- AvatarMgr:AddPosKeyToWhiteList(AvatarPartType.MASTER)
		-- AvatarMgr:AddPosKeyToWhiteList(AvatarPartType.OTHER)
	end

	local AvatarComClass = _G.UE.UAvatarComponent
	if AvatarComClass then
		AvatarComClass.AddClientNotDelPartType(AvatarPartType.MERGED_PART)
		AvatarComClass.AddClientNotDelPartType(AvatarPartType.MASTER)
		AvatarComClass.AddClientNotDelPartType(AvatarPartType.WEAPON_SYSTEM)
		AvatarComClass.AddClientNotDelPartType(AvatarPartType.NAKED_BODY_HAIR)
		AvatarComClass.AddClientNotDelPartType(AvatarPartType.NAKED_BODY_HEAD)
		AvatarComClass.AddClientNotDelPartType(AvatarPartType.NAKED_BODY_EAR)
		AvatarComClass.AddClientNotDelPartType(AvatarPartType.NAKED_BODY_TAIL)
	end

	local FMaterialUtils = _G.UE.FMaterialUtils
	local EMotherMaterialType = _G.UE.EMotherMaterialType
	if FMaterialUtils then
		FMaterialUtils.AddMotherMaterialType("M_Character_Skin", EMotherMaterialType.SKIN)
		FMaterialUtils.AddMotherMaterialType("M_Character_Eyes_New", EMotherMaterialType.EYE)
		FMaterialUtils.AddMotherMaterialType("M_Character_Eyes", EMotherMaterialType.EYE)
		FMaterialUtils.AddMotherMaterialType("M_Character_Hair", EMotherMaterialType.HAIR)
		FMaterialUtils.AddMotherMaterialType("M_Character_legacy_Hair", EMotherMaterialType.HAIR)
		FMaterialUtils.AddMotherMaterialType("M_Character_Equitment", EMotherMaterialType.EQUIP)
		FMaterialUtils.AddMotherMaterialType("M_Character_Base", EMotherMaterialType.EQUIP)
		FMaterialUtils.AddMotherMaterialType("M_Character_Base_Translucent", EMotherMaterialType.EQUIP)
		FMaterialUtils.AddMotherMaterialType("M_Character_Base_Index", EMotherMaterialType.EQUIP)
		FMaterialUtils.AddMotherMaterialType("M_Character_Boss", EMotherMaterialType.EQUIP)
		FMaterialUtils.AddMotherMaterialType("M_Character_etc", EMotherMaterialType.ETC)
		FMaterialUtils.AddMotherMaterialType("M_Character_etc_Masked", EMotherMaterialType.ACC)
	end

	-- 非编辑器使用Editor维护的Checker数据
	if not _G.UE.UPlatformUtil.IsWithEditor() then
		_G.UE.FActorCommonLib.ReloadMaterialExistenceChecker("/MaterialLibrary/MaterialStatistics/MaterialExistenceChecker.mec")
	end

	_G.UE.FMaterialUtils.AddMotherMaterialType(_G.UE.EMotherMaterialType.SKIN, "M_Character_Skin")
	_G.UE.FMaterialUtils.AddMotherMaterialType(_G.UE.EMotherMaterialType.EYE, "M_Character_Eyes_New")
	_G.UE.FMaterialUtils.AddMotherMaterialType(_G.UE.EMotherMaterialType.EYE, "M_Character_Eyes")
	_G.UE.FMaterialUtils.AddMotherMaterialType(_G.UE.EMotherMaterialType.HAIR, "M_Character_Hair")
	_G.UE.FMaterialUtils.AddMotherMaterialType(_G.UE.EMotherMaterialType.HAIR, "M_Character_legacy_Hair")
	_G.UE.FMaterialUtils.AddMotherMaterialType(_G.UE.EMotherMaterialType.EQUIP, "M_Character_Equitment")
	_G.UE.FMaterialUtils.AddMotherMaterialType(_G.UE.EMotherMaterialType.EQUIP, "M_Character_Base")
	_G.UE.FMaterialUtils.AddMotherMaterialType(_G.UE.EMotherMaterialType.EQUIP, "M_Character_Base_Index")
	_G.UE.FMaterialUtils.AddMotherMaterialType(_G.UE.EMotherMaterialType.EQUIP, "M_Character_Boss")
	_G.UE.FMaterialUtils.AddMotherMaterialType(_G.UE.EMotherMaterialType.ETC, "M_Character_etc")
	_G.UE.FMaterialUtils.AddMotherMaterialType(_G.UE.EMotherMaterialType.ACC, "M_Character_etc_Masked")
end

function AvatarConfigMgr:OnRegisterTimer()
end

function AvatarConfigMgr:OnEnd()

end

function AvatarConfigMgr:OnTimer()
end

function AvatarConfigMgr:UpdateActorVM()
end

function AvatarConfigMgr:OnShutdown()
end

function AvatarConfigMgr:OnRegisterNetMsg()
end

function AvatarConfigMgr:OnRegisterGameEvent()
end


return AvatarConfigMgr