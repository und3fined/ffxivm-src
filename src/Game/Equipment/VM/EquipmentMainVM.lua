local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoRes = require("Protocol/ProtoRes")
local SaveKey = require("Define/SaveKey")
local SettingsTabRole = nil
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")

---@class EquipmentMainVM : UIViewModel
local EquipmentMainVM = LuaClass(UIViewModel)

---PaperSprite'/Game/UI/Atlas/Role/Frames/UI_Role_Job_Icon_Fight_png.UI_Role_Job_Icon_Fight_png'
local ProfClassIconPathMap = 
{
    [ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT] = "UI_Role_Job_Icon_Fight_png",
    [ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION] = "UI_Role_Job_Icon_Produce_png",
}

local DefaultCrystalSoulIconPath = "Texture2D'/Game/UI/Texture/Equipment/UI_Equipment_Btn_SoulCrystal_Empty.UI_Equipment_Btn_SoulCrystal_Empty'"

function EquipmentMainVM:Ctor()
    self.ProfID = ProtoCommon.prof_type.PROF_TYPE_NULL
    self.Level = 0
    self.EquipScore = 0
    self.bIsHoldWeapon = false
	
    self.bIsShowWeapon = nil
    self.bIsShowHead = nil
	self.bIsHelmetGimmickOn = nil

    self.bPVE = true
    self.ProfList = {}
    self.TabList = {}
    self.bStrongest = false
    self.ProfSpecialization = nil
    self.EquipmentOtherPanel = true
	self.bHasSubtitle = false
	self.Subtitle = ""
	self.ProfDescription = ""
	self.bIsAdvancedProf = false
	self.SoulCrystalIcon = ""
	self.bEnableHelmetBtn = false
	self.bUnlockProf = false
end

function EquipmentMainVM:OnInit()

end

function EquipmentMainVM:OnBegin()
end

function EquipmentMainVM:OnEnd()
    self.bIsShowWeapon = nil
    self.bIsShowHead = nil
	self.bIsHelmetGimmickOn = nil
end

function EquipmentMainVM:OnShutdown()

end

function EquipmentMainVM:SetProfSpecialization(ProfSpecialization)
    self.ProfSpecialization = ProfSpecialization
end

function EquipmentMainVM:UpdateLevelValue(Params)
    local Level = MajorUtil.GetMajorLevel()
	if Params then Level = Params.RoleDetail.Simple.Level end
    self.Level = Level
end

function EquipmentMainVM:SetEquipmentOtherPanelVisible(bVisible)
    self.EquipmentOtherPanel = bVisible
end

function EquipmentMainVM:SetProf(ProfID)
	if ProfID == self.ProfID then
		return
	end
	self.ProfID = ProfID
	local ProfCfgData = RoleInitCfg:FindCfgByKey(ProfID)
	if nil ~= ProfCfgData then
		self.ProfDescription = ProfCfgData.ProfExplain
		self.bIsAdvancedProf = ProfCfgData.ProfLevel == ProtoRes.prof_level.PROF_LEVEL_ADVANCED
		self.bIsShowSoulCrystalIcon = ProfCfgData.Specialization ~= ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
		self.SoulCrystalIcon = ProfCfgData.SoulCrystalIcon
		if self.SoulCrystalIcon == "" then
			self.SoulCrystalIcon = DefaultCrystalSoulIconPath
		end
	end
end

--要发包给服务器，服务器会同步给其他视野内的玩家的
function EquipmentMainVM:SetIsShowWeapon(IsShow, IsSave)
	if IsShow == self.bIsShowWeapon then
		return
	end
	self.bIsShowWeapon = IsShow
	FLOG_INFO("Setting SetIsShowWeapon %s", tostring(IsShow))
	-- local Major = MajorUtil.GetMajor()
	-- if Major then
	-- 	Major:HideMasterHand(IsShow)
	-- 	Major:HideSlaveHand(IsShow)
	-- end
	
	if IsSave then
		if IsShow then
			_G.EquipmentMgr:SendEquipOn({{Part = ProtoCommon.equip_part.EquipHandShow, GID = 1}})
		else
			_G.EquipmentMgr:SendEquipOn({{Part = ProtoCommon.equip_part.EquipHandShow, GID = 0}})
		end

		local Idx = IsShow and 1 or 2
		_G.UE.USaveMgr:SetInt(SaveKey.ShowWeapon, Idx, true)
		self:GetSettingsTabRole().ShowWeaponIdx = Idx
		_G.ClientSetupMgr:SendSetReq(ClientSetupID.ShowWeapon, tostring(Idx))
	end
end

function EquipmentMainVM:GetSettingsTabRole()
	if not SettingsTabRole then
		SettingsTabRole = require("Game/Settings/SettingsTabRole")
	end

	return SettingsTabRole
end

function EquipmentMainVM:HideHead(IsHide, IsSave)
	if not IsHide == self.bIsShowHead then
		return
	end
	self.bIsShowHead = not IsHide

	FLOG_INFO("Setting HideHead %s", tostring(IsHide))
	-- local Major = MajorUtil.GetMajor()
	-- if Major then
	-- 	Major:HideHead(IsHide)
	-- end

	if IsSave then
		if self.bIsShowHead then
			_G.EquipmentMgr:SendEquipOn({{Part = ProtoCommon.equip_part.EquipHeadShow, GID = 1}})
		else
			_G.EquipmentMgr:SendEquipOn({{Part = ProtoCommon.equip_part.EquipHeadShow, GID = 0}})
		end
	
		local Idx = IsHide and 2 or 1
		_G.UE.USaveMgr:SetInt(SaveKey.ShowHead, Idx, true)
		self:GetSettingsTabRole().ShowHeadIdx = Idx
		_G.ClientSetupMgr:SendSetReq(ClientSetupID.ShowHead, tostring(Idx))
	end
end

function EquipmentMainVM:SwitchHelmet(bIsHelmetGimmickOn, IsSave)
	if bIsHelmetGimmickOn == self.bIsHelmetGimmickOn then
		return
	end
	self.bIsHelmetGimmickOn = bIsHelmetGimmickOn

	FLOG_INFO("Setting SwitchHelmet %s", tostring(bIsHelmetGimmickOn))
	-- local Major = MajorUtil.GetMajor()
	-- if Major then
	-- 	Major:SwitchHelmet(bIsHelmetGimmickOn)
	-- end

	if IsSave then	
		if self.bIsHelmetGimmickOn then
			_G.EquipmentMgr:SendEquipOn({{Part = ProtoCommon.equip_part.EquipSwitchShow, GID = 1}})
		else
			_G.EquipmentMgr:SendEquipOn({{Part = ProtoCommon.equip_part.EquipSwitchShow, GID = 0}})
		end

		local Idx = bIsHelmetGimmickOn and 1 or 2
		_G.UE.USaveMgr:SetInt(SaveKey.HelmetGimmickOn, Idx, true)
		self:GetSettingsTabRole().SwitchHelmetIdx = Idx
		_G.ClientSetupMgr:SendSetReq(ClientSetupID.HelmetGimmickOn, tostring(Idx))
	end
end

return EquipmentMainVM