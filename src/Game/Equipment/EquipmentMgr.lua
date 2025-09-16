local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local GameNetworkMgr = require("Network/GameNetworkMgr")

local EquipReceiptCfg = require("TableCfg/EquipReceiptCfg")
local EquipImproveCfg = require("TableCfg/EquipImproveCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ProfDefine = require("Game/Profession/ProfDefine")
local ActorUtil = require("Utils/ActorUtil")

local EquipImproveMaterialCfg = require("TableCfg/EquipImproveMaterialCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local EquipParamCfg = require("TableCfg/EquipParamCfg")
local MagicsparAttrCfg = require("TableCfg/MagicsparAttrCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")

local SaveKey = require("Define/SaveKey")
local ObjectGCType = require("Define/ObjectGCType")
local MagicsparDefine = require("Game/Magicspar/MagicsparDefine")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
local EquipmentUtil = require("Game/Equipment/EquipmentUtil")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local ActorMgr = require("Game/Actor/ActorMgr")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local CommonUtil = require("Utils/CommonUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local Json = require("Core/Json")
local EquipmentMainVM = require("Game/Equipment/VM/EquipmentMainVM")

local BagMgr
local CS_CMD = ProtoCS.CS_CMD
local EQUIP_SUB_ID = ProtoCS.CS_EQUIP_CMD
local NOTE_SUB_ID = ProtoCS.CS_NOTE_CMD 
local LSTR = _G.LSTR
local EquipmentType = ProtoRes.EquipmentType
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

local EquipPartName =
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = LSTR(1050014),
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = LSTR(1050036),
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = LSTR(1050052),
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = LSTR(1050128),
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = LSTR(1050076),
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = LSTR(1050117),
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = LSTR(1050113),
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = LSTR(1050143),
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = LSTR(1050056),
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = LSTR(1050046),
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = LSTR(1050115),
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = LSTR(1050110),
}

local EquipmentTypeName =
{
	[ProtoRes.EquipmentType.OTHER] = LSTR(1050025),
	[ProtoRes.EquipmentType.TWO_HAND_STAFF] = LSTR(1050043),
	[ProtoRes.EquipmentType.TWO_HAND_BOW] = LSTR(1050062),
	[ProtoRes.EquipmentType.ONE_HAND_SWORD] = LSTR(1050037),
	[ProtoRes.EquipmentType.ONE_HAND_SHIELD] = LSTR(1050103),
	[ProtoRes.EquipmentType.HEAD_ARMOUR] = LSTR(1050053),
	[ProtoRes.EquipmentType.BODY_ARMOUR] = LSTR(1050129),
	[ProtoRes.EquipmentType.ARM_ARMOUR] = LSTR(1050077),
	[ProtoRes.EquipmentType.LEG_ARMOUR] = LSTR(1050118),
	[ProtoRes.EquipmentType.FOOT_ARMOUR] = LSTR(1050114),
	[ProtoRes.EquipmentType.WAIST_ARMOUR] = LSTR(1050116),
	[ProtoRes.EquipmentType.NECKLACE] = LSTR(1050142),
	[ProtoRes.EquipmentType.RING] = LSTR(1050074),
	[ProtoRes.EquipmentType.BRACELET] = LSTR(1050078),
	[ProtoRes.EquipmentType.EARRING] = LSTR(1050111),
	[ProtoRes.EquipmentType.TWO_HAND_SWORD] = LSTR(1050041),
	[ProtoRes.EquipmentType.TWO_HAND_STAFF1] = LSTR(1050042),
	[ProtoRes.EquipmentType.CELESTIAL_GLOBE] = LSTR(1050051),
	[ProtoRes.EquipmentType.GRIMOIRE] = LSTR(1050144),
	[ProtoRes.EquipmentType.GUN_BLADE] = LSTR(1050091),
	[ProtoRes.EquipmentType.FIGHTING_WEAPON] = LSTR(1050092),
	[ProtoRes.EquipmentType.DOUBLE_SWORDS] = LSTR(1050040),
	[ProtoRes.EquipmentType.STAB_SWORD] = LSTR(1050033),
	[ProtoRes.EquipmentType.THROW_WEAPON] = LSTR(1050080),
	[ProtoRes.EquipmentType.GIANT_AXE] = LSTR(1050050),
	[ProtoRes.EquipmentType.GRIMOIRE_FOR_SCHOLAR] = LSTR(1050145),
	[ProtoRes.EquipmentType.KATANA] = LSTR(1050096),
	[ProtoRes.EquipmentType.SPEAR] = LSTR(1050138),
	[ProtoRes.EquipmentType.FIRELOCK] = LSTR(1050098),
	[ProtoRes.EquipmentType.GREEN_MAGIC_WAND] = LSTR(1050141),
	[ProtoRes.EquipmentType.BOW_QUIVER] = LSTR(1050063),

	[ProtoRes.EquipmentType.EQUIP_MAIN_ALCHEMY] = LSTR(1050099),
	[ProtoRes.EquipmentType.EQUIP_MAIN_COOK] = LSTR(1050101),
	[ProtoRes.EquipmentType.EQUIP_MAIN_FORGE] = LSTR(1050136),
	[ProtoRes.EquipmentType.EQUIP_MAIN_AMOR] = LSTR(1050134),
	[ProtoRes.EquipmentType.EQUIP_MAIN_CARVE] = LSTR(1050034),
	[ProtoRes.EquipmentType.EQUIP_MAIN_GOLDSMITH] = LSTR(1050139),
	[ProtoRes.EquipmentType.EQUIP_MAIN_CLOTH] = LSTR(1050120),
	[ProtoRes.EquipmentType.EQUIP_MAIN_LEATHER] = LSTR(1050031),
	[ProtoRes.EquipmentType.EQUIP_MAIN_MINE] = LSTR(1050131),
	[ProtoRes.EquipmentType.EQUIP_MAIN_GARDEN] = LSTR(1050048),
	[ProtoRes.EquipmentType.EQUIP_MAIN_FISH] = LSTR(1050081),
  
	[ProtoRes.EquipmentType.EQUIP_SECONDARY_ALCHEMY] = LSTR(1050100),
	[ProtoRes.EquipmentType.EQUIP_SECONDARY_COOK] = LSTR(1050102),
	[ProtoRes.EquipmentType.EQUIP_SECONDARY_FORGE] = LSTR(1050137),
	[ProtoRes.EquipmentType.EQUIP_SECONDARY_AMOR] = LSTR(1050135),
	[ProtoRes.EquipmentType.EQUIP_SECONDARY_CARVE] = LSTR(1050035),
	[ProtoRes.EquipmentType.EQUIP_SECONDARY_GOLDSMITH] = LSTR(1050140),
	[ProtoRes.EquipmentType.EQUIP_SECONDARY_CLOTH] = LSTR(1050121),
	[ProtoRes.EquipmentType.EQUIP_SECONDARY_LEATHER] = LSTR(1050032),
	[ProtoRes.EquipmentType.EQUIP_SECONDARY_MINE] = LSTR(1050132),
	[ProtoRes.EquipmentType.EQUIP_SECONDARY_GARDEN] = LSTR(1050049),
	[ProtoRes.EquipmentType.EQUIP_SECONDARY_FISH] = LSTR(1050082),
}

local EquipPartToItemTypeDetail =
{
	-- [ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = LSTR(1050014),
	-- [ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = LSTR(1050036),
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = ProtoCommon.ITEM_TYPE_DETAIL.ARMOR_HEAD,
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = ProtoCommon.ITEM_TYPE_DETAIL.ARMOR_BODY,
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = ProtoCommon.ITEM_TYPE_DETAIL.ARMOR_HANDS,
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = ProtoCommon.ITEM_TYPE_DETAIL.ARMOR_LEGS,
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = ProtoCommon.ITEM_TYPE_DETAIL.ARMOR_FEET,
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = ProtoCommon.ITEM_TYPE_DETAIL.ACCESSORY_NECKLACE,
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = ProtoCommon.ITEM_TYPE_DETAIL.ACCESSORY_RING,
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = ProtoCommon.ITEM_TYPE_DETAIL.ACCESSORY_RING,
	[ProtoCommon.equip_part.EQUIP_PART_FINGER] = ProtoCommon.ITEM_TYPE_DETAIL.ACCESSORY_RING,
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = ProtoCommon.ITEM_TYPE_DETAIL.ACCESSORY_BRACELETS,
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = ProtoCommon.ITEM_TYPE_DETAIL.ACCESSORY_EARRINGS,
}

local ItemTypeDetailToEquipParts =
{
	[ProtoCommon.ITEM_TYPE_DETAIL.ARMOR_HEAD] = {ProtoCommon.equip_part.EQUIP_PART_HEAD},
	[ProtoCommon.ITEM_TYPE_DETAIL.ARMOR_BODY] = {ProtoCommon.equip_part.EQUIP_PART_BODY},
	[ProtoCommon.ITEM_TYPE_DETAIL.ARMOR_HANDS] = {ProtoCommon.equip_part.EQUIP_PART_ARM},
	[ProtoCommon.ITEM_TYPE_DETAIL.ARMOR_LEGS] = {ProtoCommon.equip_part.EQUIP_PART_LEG},
	[ProtoCommon.ITEM_TYPE_DETAIL.ARMOR_FEET] = {ProtoCommon.equip_part.EQUIP_PART_FEET},
	[ProtoCommon.ITEM_TYPE_DETAIL.ACCESSORY_NECKLACE] = {ProtoCommon.equip_part.EQUIP_PART_NECK},
	[ProtoCommon.ITEM_TYPE_DETAIL.ACCESSORY_RING] = {ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER, ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER},
	[ProtoCommon.ITEM_TYPE_DETAIL.ACCESSORY_BRACELETS] = {ProtoCommon.equip_part.EQUIP_PART_WRIST},
	[ProtoCommon.ITEM_TYPE_DETAIL.ACCESSORY_EARRINGS] = {ProtoCommon.equip_part.EQUIP_PART_EAR},
}

local PartIconMap = 
{
	[1] = "MainHand1";
	[2] = "OffHand";
	[3] = "Head";
	[4] = "Body";
	[5] = "Hand";
	[6] = "Legs";
	[7] = "Feet";
	[8] = "Neck";
	[9] = "Finger";
	[10] = "Finger";
	[11] = "Wrists";
	[12] = "Ears";
}

local RoleIconCfg =
{
	---战斗职业
    [ProtoCommon.prof_type.PROF_TYPE_BARD] = "UI_Icon_Job_Poet";
    [ProtoCommon.prof_type.PROF_TYPE_WHITEMAGE] = "UI_Icon_Job_Devil";
    [ProtoCommon.prof_type.PROF_TYPE_PALADIN] = "UI_Icon_Job_Kight";
	---生产职业
    --[ProtoCommon.prof_type.PROF_TYPE_PALADIN] = "UI_Role_Produce_Armor";
    [ProtoCommon.prof_type.PROF_TYPE_FISHER] = "UI_Role_Produce_Fish";
    [ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH] = "UI_Role_Produce_Iron";
    [ProtoCommon.prof_type.PROF_TYPE_LEATHER_WORK] = "UI_Role_Produce_Tanning";
}

local QualityIconRgbTable = {
	[1] = "<span color=\"#d5d5d5\">",
	[2] = "<span color=\"#89bd88\">",
	[3] = "<span color=\"#6fb1e9\">",
	[4] = "<span color=\"#ac88bd\">",
}
local CharacterClass = "Class'/Game/BluePrint/Character/UIComplexCharacter_BP.UIComplexCharacter_BP_C'"
local EquipmentLightConfig = "LightPreset'/Game/UI/Render2D/LightPresets/DA_BP_Render2DLoginActor01.DA_BP_Render2DLoginActor01'"
local EquipmentBGPath = "Class'/Game/UI/Render2D/Equipment/BP_EquipmentBackground.BP_EquipmentBackground_C'"

---@class EquipmentMgr : MgrBase
local EquipmentMgr = LuaClass(MgrBase)

--装备界面左侧职业切换按钮的点击频率
EquipmentMgr.JobBtnClickInterval = 1000
EquipmentMgr.LastJobBtnClickTime = 0
EquipmentMgr.JobBtnClickDelayTimerID = nil

function EquipmentMgr:SwitchProfByID(ProfID)
	-- 检查职业是否被激活
	local RoleDetail = ActorMgr:GetMajorRoleDetail()
	if nil == RoleDetail or nil == RoleDetail.Prof.ProfList[ProfID] then
		self:SwitchUIActor(ProfID)
		return
	end

	-- 检查装备完整性
	local SuitIntegrityState = nil
	local RawWeaponName = nil
	local ReplaceWeaponItem = nil
	SuitIntegrityState, RawWeaponName, ReplaceWeaponItem = _G.EquipmentMgr:CheckSuitIntegrity(ProfID)

	local ReplaceWeaponGID = nil
	if nil ~= ReplaceWeaponItem then
		ReplaceWeaponGID = ReplaceWeaponItem.GID
	end

	local DelayTime = 1
	local SwitchProfFunc = nil
	--没有计时器的时候，就直接转职（相当于第一次click直接转职，不等待，同时启动一个计时器）
	--	如果快速连续点击，
	self:HideAllUINpc()
	if not self.JobBtnClickDelayTimerID then
		SwitchProfFunc = function()
			--FLOG_INFO("======= EquipmentMgr:SwitchProfByID First =======")
			local Data = {IsUnlock = false, ProfTable = {}, ProfID = ProfID}
			_G.EventMgr:SendEvent(_G.EventID.SwitchLockProf, Data)
			if ProfID == MajorUtil:GetMajorProfID() then return end
			_G.ProfMgr:SwitchProfByID(ProfID, ReplaceWeaponGID)
			local EmptyDelayCallBack = function()
				--FLOG_INFO("======= EquipmentMgr EmptyDelayCallBack =======")
				self.JobBtnClickDelayTimerID = nil
			end

			self.JobBtnClickDelayTimerID = self:RegisterTimer(EmptyDelayCallBack
				, DelayTime, 0, 1)
		end
	else
		SwitchProfFunc = function()
			--已经有计时器了，重新开始计时
			self:UnRegisterTimer(self.JobBtnClickDelayTimerID)

			local DelayCallBack = function()
				local Data = {IsUnlock = false, ProfTable = {}, ProfID = ProfID}
				_G.EventMgr:SendEvent(_G.EventID.SwitchLockProf, Data)
				if ProfID == MajorUtil:GetMajorProfID() then return end
				_G.ProfMgr:SwitchProfByID(ProfID, ReplaceWeaponGID)
				self.JobBtnClickDelayTimerID = nil
				--FLOG_INFO("======= EquipmentMgr DelayCallBack =======")
			end
		
			---FLOG_INFO("EquipmentMgr SwitchProfByID ResetTimer and Delay Switch")
			self.JobBtnClickDelayTimerID = self:RegisterTimer(DelayCallBack
				, DelayTime, 0, 1)
		end
	end
	
	if SuitIntegrityState == EquipmentDefine.SuitIntegrityState.LackWeapon and nil ~= RawWeaponName and nil ~= ReplaceWeaponItem then
		local ReplaceWeaponName = ItemCfg:FindValue(ReplaceWeaponItem.ResID, "ItemName")
		local BindSuffix = ReplaceWeaponItem.IsBind and "" or LSTR(1050004)
		RawWeaponName = CommonUtil.GetTextFromStringWithSpecialCharacter(RawWeaponName)
		ReplaceWeaponName = CommonUtil.GetTextFromStringWithSpecialCharacter(ReplaceWeaponName)
		local Message = string.format(LSTR(1050097), RawWeaponName, ReplaceWeaponName, BindSuffix)
		MsgBoxUtil.ShowMsgBoxTwoOp(true, "", Message, SwitchProfFunc, function ()
			_G.EventMgr:SendEvent(_G.EventID.ReSelectMajorProf)
		end)
	else
		SwitchProfFunc()
	end

	self.LastJobBtnClickTime = TimeUtil.GetLocalTimeMS()
end

function EquipmentMgr:OnInit()
	self.NeedShowEndureDeg = false
	self.CreatedNPCEntityIDList = {}
	self.StrongestEquipInfos = {}
	self.CanPlayStrongestAnimNum = 8
	self.HasPlayStrongestAnimNumR = 0
	self.HasPlayStrongestAnimNumL = 0
	self.SoulBtnClickTimeTable = {}
	self.LocalProfExpTable = {}
	self.SceneFinishLog = {}
	self:ResetStrongestEquipInfos()
	self.EquipmentProfSpecialization = ProtoCommon.specialization_type.SPECIALIZATION_TYPE_NULL
end

function EquipmentMgr:OnBegin()
	BagMgr = require("Game/Bag/BagMgr")
	_G.ObjectMgr:PreLoadObject(EquipmentBGPath, _G.UE.EObjectGC.Hold)
end

function EquipmentMgr:OnEnd()
	
end

function EquipmentMgr:OnShutdown()
	
end

function EquipmentMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EQUIPMENT, EQUIP_SUB_ID.CS_CMD_EQUIP_ON, self.OnEquipOn)						--装备穿着
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EQUIPMENT, EQUIP_SUB_ID.CS_CMD_EQUIP_OFF, self.OnEquipOff)					--装备脱去
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EQUIPMENT, EQUIP_SUB_ID.CS_CMD_EQUIP_GEM_INLAY, self.OnEquipGemInlay) 		--宝石镶嵌
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EQUIPMENT, EQUIP_SUB_ID.CS_CMD_EQUIP_GEM_UNINLAY, self.OnEquipGemUnInlay) 	--宝石卸下
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EQUIPMENT, EQUIP_SUB_ID.CS_CMD_EQUIP_REPAIR, self.OnEquipRepair) 				--装备修理
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EQUIPMENT, EQUIP_SUB_ID.CS_CMD_EQUIP_INFO, self.OnEquipInfoRsp) 					--装备详细信息
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOGOUT, 0, self.OnNetMsgRoleLogoutRes)
	-- self:RegisterGameNetMsg(CS_CMD.CS_CMD_PROF, ProtoCS.ProfSubMsg.ProfSubMsgDetail, self.OnProfDetailRsp) 					--获取职业详情
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EQUIPMENT, EQUIP_SUB_ID.CS_CMD_EQUIP_EXCHANGE_RECEIPT, self.OnEquipExchangeReceipt)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EQUIPMENT, EQUIP_SUB_ID.CS_CMD_EQUIP_IMPROVE, self.OnEquipImproveBack)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, NOTE_SUB_ID.CS_CMD_SCENE_FINISH_LOG, self.OnSceneFinishLogRsp)
end

function EquipmentMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.EquipUpdate, self.OnEquipUpdate)
	self:RegisterGameEvent(_G.EventID.UpdateQuestTrack, self.OnGameEventUpdateQuestTrack)
	self:RegisterGameEvent(_G.EventID.BagUpdate, self.OnBagUpdate)
	self:RegisterGameEvent(_G.EventID.UpdateQuest, self.OnUpdateQuest)
	self:RegisterGameEvent(_G.EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(_G.EventID.ClientSetupPost, self.ClientSetupPost)
	self:RegisterGameEvent(_G.EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
	self:RegisterGameEvent(_G.EventID.NetStateUpdate,self.OnCombatStateUpdate)
	self:RegisterGameEvent(_G.EventID.PWorldExit, self.OnPWorldExit)
	self:RegisterGameEvent(_G.EventID.PWorldReady, self.OnPWorldReady)
    self:RegisterGameEvent(_G.EventID.TutorialLoadingFinish, self.OnLoadingFinishMainViewActive)
	self:RegisterGameEvent(_G.EventID.EnterGatherState, self.NeedCheckTipsForEndureDeg)
	self:RegisterGameEvent(_G.EventID.CrafterEnterRecipeState, self.NeedCheckTipsForEndureDeg)
	self:RegisterGameEvent(_G.EventID.ExitGatherState, self.OnCrafterExit)
	self:RegisterGameEvent(_G.EventID.CrafterExitRecipeState, self.OnCrafterExit)

	self:RegisterGameEvent(_G.EventID.ActorReviveNotify, self.OnEnduredegChange) --主角复活
	self:RegisterGameEvent(_G.EventID.HideUI, self.OnGameEventHideUI)
	self:RegisterGameEvent(_G.EventID.LeveQuestExpUpdate, self.OnMajorExpUpdate) -- 经验变动
	self:RegisterGameEvent(_G.EventID.Attr_Change_ChangeRoleId, self.OnGameEventChangeRoleIDChanged)
	self:RegisterGameEvent(_G.EventID.PWorldFinished, self.OnGameEventPWorldFinished)
end

function EquipmentMgr:RegisterCombatAttrMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_ATTR_UPDATE, self.OnCombatAttrUpdate) 					--动态属性
end

function EquipmentMgr:UnRegisterCombatAttrMsg()
	self:UnRegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_ATTR_UPDATE, self.OnCombatAttrUpdate) 					--动态属性
end

-----------------------------------------------Rsp start-----------------------------------------------
function EquipmentMgr:OnEquipOn(MsgBody)
	if MsgBody.On.OnList == nil or table.size(MsgBody.On.OnList) == 0 then
		MsgTipsUtil.ShowTips(LSTR(1050106))
		return
	end
	MsgTipsUtil.ShowTips(LSTR(1050107))
	---更新已穿戴装备数据
	for Part, Item in pairs(MsgBody.On.OnList) do
		---添加新的装备
		if Item.ResID > 0 and Item.GID > 0 then
			---先删除同part部位的已装备的部位
			EquipmentVM.ItemList[Part] = nil
			EquipmentVM.ItemList[Part] = Item
			self:UpdateStrongestEquip(Part, EquipmentVM.ItemList[Part], true, true)
		end
	end

	EquipmentVM.OnList = MsgBody.On.OnList
	self:UpdateSchemeInfo2RoleSimple()
	self:UpdateSchemeInfo2RoleDetail()
	self:CheckTipsForEndureDeg()
end

function EquipmentMgr:OnEquipOff(MsgBody)
	if MsgBody.Off.OffList == nil or table.size(MsgBody.Off.OffList) == 0 then
		local BagLeftNum = _G.BagMgr:GetBagLeftNum()
		local TipText = BagLeftNum <= 0 and 1050231 or 1050232
		MsgTipsUtil.ShowTips(LSTR(TipText))
		return
	end
	MsgTipsUtil.ShowTips(LSTR(1050039))
	FLOG_ERROR("MsgBody.Off.OffList = %s", table_to_string(MsgBody.Off.OffList))
	---更新已穿戴装备数据
	for _, EquipInfo in pairs(MsgBody.Off.OffList) do
		local TakeOffItem = EquipmentVM.ItemList[EquipInfo.Part]
		EquipmentVM.ItemList[EquipInfo.Part] = nil
		self:UpdateStrongestEquip(EquipInfo.Part, TakeOffItem, true, false)
	end
	EquipmentVM.OffList = MsgBody.Off.OffList
	self:UpdateSchemeInfo2RoleSimple()
	self:UpdateSchemeInfo2RoleDetail()
end

function EquipmentMgr:OnEquipGemInlay(MsgBody)
	local EquipInlayRsp = MsgBody.Inlay
	local EquipGID = EquipInlayRsp.EquipGID
	local GemIndex = EquipInlayRsp.GemIndex
	local GemResID = EquipInlayRsp.GemResID
	local Item = self:GetItemByGID(EquipGID)
	if Item and Item.Attr and Item.Attr.Equip and Item.Attr.Equip.GemInfo and Item.Attr.Equip.GemInfo.CarryList then
		Item.Attr.Equip.GemInfo.CarryList[GemIndex] = GemResID
		_G.EventMgr:SendEvent(_G.EventID.MagicsparInlaySucc, {GID = EquipGID, Index = GemIndex, ResID = GemResID})
	end
end
-- message EquipUnInlayRsp
-- {
--   int32 GemIndex = 1;
--   int32 GemResID = 2;
--   uint64 EquipGID = 3;
-- }
function EquipmentMgr:OnEquipGemUnInlay(MsgBody)
	local EquipUnInlayRsp = MsgBody.UnInlay
	local EquipGID = EquipUnInlayRsp.EquipGID
	local GemIndex = EquipUnInlayRsp.GemIndex
	local GemResID = EquipUnInlayRsp.GemResID
	local Item = self:GetItemByGID(EquipGID)
	if Item then
		Item.Attr.Equip.GemInfo.CarryList[GemIndex] = nil
		_G.EventMgr:SendEvent(_G.EventID.MagicsparUnInlaySucc, {GID = EquipGID, Index = GemIndex, ResID = GemResID})
	end
end

function EquipmentMgr:OnEquipRepair(MsgBody)
	local EquipRepairRsp = MsgBody.Repair
	for _, GID in pairs(EquipRepairRsp.gidList) do
		local Item = self:GetItemByGID(GID)
		--装备耐久度改成1w份
		Item.Attr.Equip.EndureDeg = 10000
	end
	if #EquipRepairRsp.gidList > 0 then
		_G.EventMgr:SendEvent(_G.EventID.EquipRepairSucc, EquipRepairRsp.gidList,MsgBody.SubCmd)
	end
end

--从RoleDetail.Equip更新过来的
function EquipmentMgr:OnEquipInfo(EquipInfo)
	local lstItem = {}
	for Key, Item in pairs(EquipInfo.EquipList) do
		if Item.ResID > 0 and Item.GID > 0 then
			lstItem[Key] = Item
		end
	end
	EquipmentVM.ItemList = lstItem

	if nil ~= self.StrongestEquipInfos then
		for Part, Item in pairs(EquipmentVM.ItemList) do
			self:UpdateStrongestEquip(Part, Item, true, true)
		end
	end
	_G.EventMgr:SendEvent(_G.EventID.EquipUpdate)
end

function EquipmentMgr:OnEquipInfoRsp(MsgBody)
	local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
	if RoleDetail and RoleDetail.Equip then
		RoleDetail.Equip.EquipList = MsgBody.Info.ItemList
	end
end

function EquipmentMgr:OnEquipExchangeReceipt(MsgBody)
	local ItemList = {}
	if MsgBody and MsgBody.ExchangeReceipt and MsgBody.ExchangeReceipt.ConsumeID then
		if next(MsgBody.ExchangeReceipt.ConsumeID) then
			local TotalNum = 0
			local ResID = 0
			for _, value in pairs(MsgBody.ExchangeReceipt.ConsumeID) do
				-- body
				local Cfg = EquipReceiptCfg:FindCfgByKey(value)
				TotalNum = TotalNum + Cfg.Num
				ResID = Cfg.MaterialID
			end
			local ItemList = {{ResID = ResID, Num = TotalNum}}
			_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, {Title = LSTR(1050119), ItemList = ItemList})
		end
	end
	_G.EventMgr:SendEvent(_G.EventID.ExchangeNetEvent)
end

function EquipmentMgr:SendSceneFinishLogReq()
	local MsgID = CS_CMD.CS_CMD_NOTE
	local SubMsgID = NOTE_SUB_ID.CS_CMD_SCENE_FINISH_LOG

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function EquipmentMgr:OnSceneFinishLogRsp(MsgBody)
	self.SceneFinishLog = MsgBody.SceneFinishLog.SceneFinishLogs
end

function EquipmentMgr:GetProfLevelItemIcon(Prof)
	if not ProfUtil.IsCombatProf(Prof) or not ProfUtil.IsAdvancedProf(Prof) then
		return RoleInitCfg:FindRoleInitProfIconSimple2nd(Prof)
	end
	local MaxLevelCfg = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_MAX_LEVEL) or {}
    local MaxLevel = MaxLevelCfg.Value[1] or 50
	local ProfLevel = MajorUtil.GetMajorLevelByProf(Prof) or 0
	local IsClearScene = self:IsClearFinalScene(Prof)
	if IsClearScene and tonumber(ProfLevel) >= tonumber(MaxLevel) then
		local PathBase = "MaterialInstanceConstant'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID%d.MI_DX_UI_Prof_ProfID%d'"
		return  string.format(PathBase, Prof, Prof)
	else
		return RoleInitCfg:FindRoleInitProfIconSimple2nd(Prof)
	end
end

function EquipmentMgr:IsClearFinalScene(Prof)
	local CountCfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_FINAL_DUNGEON_COUNT_ID) or {}
	local SceneID = CountCfg.Value[1] or 1205013
	if self.SceneFinishLog and next(self.SceneFinishLog) then
		for key, value in pairs(self.SceneFinishLog) do
			if value.ProfID == Prof and SceneID == value.SceneID then
				return true
			end
		end
	end
end

function EquipmentMgr:OnEquipImproveBack(MsgBody)
	local ItemList = {}
	if MsgBody and MsgBody.Improve and MsgBody.Improve then
		local ItemData = {ResID = MsgBody.Improve.TargetID, Num = 1}
		table.insert(ItemList, ItemData)
		if MsgBody.Improve.HasGem then
			_G.MsgTipsUtil.ShowTips(LSTR(1050186))
		end
		_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, {Title = LSTR(1050119), ItemList = ItemList})
	end
	_G.EventMgr:SendEvent(_G.EventID.ExchangeNetEvent)
end

function EquipmentMgr:OnNetMsgRoleLogoutRes()
	self.IsPreviewProf = false
	self.PreviewProfID = nil
end

function EquipmentMgr:OnEquipUpdate()
	MajorUtil.SetEquipScore(self:CalculateEquipScore())
end

function EquipmentMgr:OnGameEventUpdateQuestTrack(Params)
	if not Params.PartRequirementMap or not next(Params.PartRequirementMap) then
		self.PartRequirementMap = {}
		return
	end
	self.PartRequirementMap = Params.PartRequirementMap
end

function EquipmentMgr:OnGameEventLoginRes(Params)
	self.IsPreviewProf = false
	self.PreviewProfID = nil
	self:GetVersionName()
	EquipmentMainVM:SetProf(0)
	local bShowHead = _G.UE.USaveMgr.GetInt(SaveKey.ShowHead, 1, true) == 1 and true or false
	EquipmentMainVM:HideHead(bShowHead)
	self:SendSceneFinishLogReq()
	--登录检查耐久度
	if Params.bReconnect then return end
	self.NeedShowEndureDeg = true
end

function EquipmentMgr:OnGameEventPWorldFinished()
	self:SendSceneFinishLogReq()
end

function EquipmentMgr:OnCombatStateUpdate(Params)
	if MajorUtil.IsMajor(Params.ULongParam1) then
		if Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_COMBAT then
			if MajorUtil.IsMajorCombat() then
				self:CheckTipsForEndureDeg()
			end
			self.LockEndureDegEventSend = Params.BoolParam1
			if not Params.BoolParam1 then
				self:OnEnduredegChange()
			end
		end
	end
end

function EquipmentMgr:OnPWorldExit()
	self.NeedShowEndureDeg = true
end

function EquipmentMgr:OnPWorldReady()
	self:OnEnduredegChange()
end

function EquipmentMgr:OnLoadingFinishMainViewActive()
	if self.NeedShowEndureDeg then
		self:CheckTipsForEndureDeg()
		self.NeedShowEndureDeg = false
	end
end

function EquipmentMgr:NeedCheckTipsForEndureDeg()
	self:LocalSetWeaponVisible(true)
	self:CheckTipsForEndureDeg()
end

function EquipmentMgr:OnCrafterExit()
	self:LocalSetWeaponVisible(false)
end

function EquipmentMgr:LocalSetWeaponVisible(IsEnter)
	local Major = MajorUtil.GetMajor()
	if not Major or not _G.UE.UCommonUtil.IsObjectValid(Major) then return end
	if IsEnter then
		Major:HideMasterHand(false)
		Major:HideSlaveHand(false)
	else
		--不同职业动画不同，延迟避免穿帮
		self:RegisterTimer(function()
			local SettingRole = EquipmentMainVM:GetSettingsTabRole()
			local IsShow = SettingRole.ShowWeaponIdx == 1
			Major:HideMasterHand(not IsShow)
			Major:HideSlaveHand(not IsShow)
		end , 2, 0, 1)
	end
end

function EquipmentMgr:OnEnduredegChange()
	local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
	local ItemList = nil
	if RoleDetail and RoleDetail.Equip then
		ItemList = RoleDetail.Equip.EquipList
	end
    if ItemList == nil then
		return
	end
	local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon() or _G.PWorldMgr:CurrIsInPVPColosseum()
	local Cfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_EQUIPMENT_ENDDUREDEG)
	for Key, Item in pairs(ItemList) do
		if Item.Attr.Equip.EndureDeg <= Cfg.Value[1] * 100 then
			if not IsInDungeon and not self.LockEndureDegEventSend then
				_G.EventMgr:SendEvent(_G.EventID.EnduredegChange, Cfg.Value[1] or 40)
				self:UnRegisterGameEvent(EventID.HideUI, self.OnGameEventHideUI)
				return
			end
		end
	end
end

function EquipmentMgr:OnGameEventHideUI(Params)
	local ViewID = Params
	if ViewID == _G.UIViewID.GatheringJobPanel or ViewID == _G.UIViewID.CraftingLog then
		self:OnEnduredegChange()
	end
end

function EquipmentMgr:OnMajorExpUpdate(Params)
	if Params and next(Params) then
		if Params.ULongParam4 and Params.ULongParam4 ~= 0 then
			self.LocalProfExpTable[Params.ULongParam4] = Params.ULongParam3
		end
	end
end

function EquipmentMgr:ClientSetupPost(EventParams)
	local Params = EventParams

    if Params == nil then
        return
    end

    local Key = Params.IntParam1
	local Value = Params.StringParam1

    if Key == ClientSetupID.RoleChgProfRedPoint then
        self:ParseEquipmentNetSyncData(Value)
		self:UpdateRoleRedDot()
    end

	if Key == ClientSetupID.RoleWeaponVisible then
		EquipmentVM.bIsShowWeapon = tonumber(Value) == 1 and true or false
	end
end

function EquipmentMgr:ParseEquipmentNetSyncData(Value)
	local Data = Json.decode(Value)

    if Data == nil then
        return
    end

    self.SoulBtnClickTimeTable = Data
end

function EquipmentMgr:OnUpdateQuest(Params)
	if Params == nil then        
        return
    end

    local Quests = Params.UpdatedRspQuests
    if table.is_nil_empty(Quests) then        
        return
    end
	local Cfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_STORNGEST_EQUIPMENT)
	if (Cfg == nil or Cfg.Value[1] <= 0) then
		FLOG_ERROR("ClientGlobalCfg table STORNGEST_EQUIPMENT no value set!")
		return
	end

	for _, RspQuest in pairs(Quests) do		
		local QuestID = RspQuest.QuestID

		--指定的任务ID
		if (QuestID == Cfg.Value[1] and RspQuest.Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED) then
			self:EquipOnStrongest()
			break
		end
	end
end

--更换最强装备
function EquipmentMgr:EquipOnStrongest()
	local Strongest = self:GetStrongest()
	if (Strongest == nil or #Strongest == 0) then
		return
	end

	if not self:CheckCanOperate(LSTR(1050178), true) then
		return
	end

	local lstEquipInfo = {}
	for _,v in pairs(Strongest) do
		local StrongestItem = v.Strongest
		lstEquipInfo[#lstEquipInfo + 1] = {Part = v.Part, GID = StrongestItem.GID}
	end
	
	self:SendEquipOn(lstEquipInfo)	
end

function EquipmentMgr:OnBagUpdate(Params)
	if nil == Params then
		return
	end

	for _, Value in pairs(Params) do
		local Item = Value.PstItem
		local bOn = Value.Type == ProtoCS.ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_ADD or Params.Type == ProtoCS.ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_RENEW
		self:CheckStrongestEquipByItem(Item, bOn)
	end
end

function EquipmentMgr:CheckStrongestEquipByItem(Item, bOn)
	if nil == Item.Attr then
		return
	end

	-- 检查Item是否是装备
	if Item.Attr.ItemType ~= ProtoCommon.ITEM_TYPE.ITEM_TYPE_EQUIP then
		return
	end

	-- 检查是否可穿戴
	if not self:CanEquiped(Item.ResID, false, MajorUtil.GetMajorProfID()) then
		return
	end

	-- 查找装备相关部位
	local ItemCfgData = ItemCfg:FindCfgByKey(Item.ResID)
	local Parts = ItemTypeDetailToEquipParts[ItemCfgData.ItemType]
	if nil == Parts then
		-- 主副手ItemType与职业有关
		local ProfID = MajorUtil.GetMajorProfID()
		if ItemCfgData.ItemType == RoleInitCfg:FindMainWeaponItemType(ProfID) then
			Parts = {ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND}
		elseif ItemCfgData.ItemType == RoleInitCfg:FindSubWeaponItemType(ProfID) then
			Parts = {ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND}
		end
		if nil == Parts then
			return
		end
	end

	for _, Part in pairs(Parts) do
		self:UpdateStrongestEquip(Part, Item, false, bOn)
	end
end

function EquipmentMgr:CheckIsQuestTrackItem(Part, ResID, Grade)
	if self.PartRequirementMap and next(self.PartRequirementMap) then
		for k, v in pairs(self.PartRequirementMap) do
			if Part == k then
				--优先判断ID
				if v.ID and v.ID ~= 0 then
					return ResID == v.ID
				end
				if v.Level and v.Level ~= 0 then
					return Grade > v.Level
				end
			end
		end
	end
	return false
end

function EquipmentMgr:UpdateSchemeInfo2RoleSimple()
	if nil == EquipmentVM or nil == EquipmentVM.ItemList then
		return
	end
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil == RoleSimple then
		return
	end

	local EquipedItemList = EquipmentVM.ItemList
	local PartsToInsert = {}
	for Part, _ in pairs(EquipedItemList) do
		PartsToInsert[Part] = true
	end

	-- 更新RoleAvatar已有部位的装备ID
	local RoleAvatar = RoleSimple.Avatar
	for _, Avatar in pairs(RoleAvatar.EquipList) do
		local EquipedItem = EquipedItemList[Avatar.Part]
		if nil ~= EquipedItem then
			Avatar.EquipID = EquipedItem.ResID
			PartsToInsert[Avatar.Part] = nil
		else
			Avatar.EquipID = 0
		end
	end

	-- 增加RoleAvatar没有部位的数据
	for Part, _ in pairs(PartsToInsert) do
		local EquipedItem = EquipedItemList[Part]
		local EquipAvatar =
		{
			Part = Part,
			EquipID = EquipedItem.ResID,
			ResID = 0,
			ColorID = 0,
			IsBind = EquipedItem.IsBind,
			RandomID = 0
		}
		table.insert(RoleAvatar.EquipList, EquipAvatar)
	end
end

function EquipmentMgr:UpdateSchemeInfo2RoleDetail()
	local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()

	local EquipList = {}
	if nil ~= EquipmentVM and nil ~= EquipmentVM.ItemList then
		for Key,Equipment in pairs(EquipmentVM.ItemList) do
			EquipList[Key] = Equipment
		end
	end

	if nil == RoleDetail then
		return
	end
	RoleDetail.Equip.EquipList = EquipList
	_G.EventMgr:SendEvent(_G.EventID.EquipUpdate)
end

function EquipmentMgr:OnProfListDetail(ProfList)
	EquipmentVM.lstProfDetail = ProfList
end

function EquipmentMgr:OnCombatAttrUpdate(MsgBody)
	-- _G.UE.FProfileTag.StaticBegin("EquipmentMgr:OnCombatAttrUpdate")
	local CombatAttrUpdateS = MsgBody.AttrUpdate
	local EntityID = CombatAttrUpdateS.ObjID
	if EntityID == MajorUtil.GetMajorEntityID() then
		local UnSteadyMap = {}
		for _,v in pairs(CombatAttrUpdateS.Attrs.UnSteady) do
			UnSteadyMap[v.Attr] = v.Value
		end
		EquipmentVM.UnSteadyMap = UnSteadyMap
	end
	-- _G.UE.FProfileTag.StaticEnd()
end

function EquipmentMgr:UpdateAttrFromAttrCmp()
	-- _G.UE.FProfileTag.StaticBegin("EquipmentMgr:UpdateAttrFromAttrCmp")
	local MajorCmp = MajorUtil.GetMajorAttributeComponent()
	if MajorCmp then
		local UnSteadyMap = {}
		local keys = MajorCmp.UnSteadyAttrMaps:Keys()
		for i = 1, keys:Length() do
			local key = keys:Get(i)
			local value = MajorCmp.UnSteadyAttrMaps:Find(key)
			UnSteadyMap[key] = value
		end
		
		EquipmentVM.UnSteadyMap = UnSteadyMap
	end
	-- _G.UE.FProfileTag.StaticEnd()
end
-----------------------------------------------Rsp end-----------------------------------------------

-----------------------------------------------Req start-----------------------------------------------
-- message EquipInfo
-- {
--   common.equip_part Part = 1;
--   uint64 GID = 2;
-- }
function EquipmentMgr:SendEquipOn(lstEquipInfo)
	local EquipsOnReq = {OnList = lstEquipInfo}
	self:SendEquipCommon(EQUIP_SUB_ID.CS_CMD_EQUIP_ON, "On", EquipsOnReq)
end

function EquipmentMgr:SendEquipOff(lstEquipInfo)
	if not _G.EquipmentMgr:CheckCanOperate(LSTR(1050178), true) then
		return
	end
	local EquipsOffReq = {OffList = lstEquipInfo}
	self:SendEquipCommon(EQUIP_SUB_ID.CS_CMD_EQUIP_OFF, "Off", EquipsOffReq)
end

function EquipmentMgr:SendEquipInlay(InGemResID, InEquipGID, InPart, InGemIndex, InIsOn)
	if InIsOn == false then InPart = 0 end
	local EquipInlayReq = {GemResID = InGemResID, EquipGID = InEquipGID, Part = InPart, GemIndex = InGemIndex}
	self:SendEquipCommon(EQUIP_SUB_ID.CS_CMD_EQUIP_GEM_INLAY, "Inlay", EquipInlayReq)
end

function EquipmentMgr:SendEquipUnInlay(InEquipGID, InPart, InGemIndex, Tag)
	-- if Tag == "Bag" then
	-- 	InPart = ProtoCommon.equip_part.EQUIP_PART_NONE
	-- end
	if self:IsEquiped(InEquipGID) == false then
		InPart = ProtoCommon.equip_part.EQUIP_PART_NONE
	end
	local EquipUnInlayReq = {EquipGID = InEquipGID, Part = InPart, GemIndex = InGemIndex}
	self:SendEquipCommon(EQUIP_SUB_ID.CS_CMD_EQUIP_GEM_UNINLAY, "UnInlay", EquipUnInlayReq)
end

function EquipmentMgr:SendEquipRepair(lstEquipGID, InIsOn)
	if lstEquipGID == nil or #lstEquipGID == 0 then return end		
	local EquipRepairReq = {EquipList = lstEquipGID, IsOn = InIsOn}
	self:SendEquipCommon(EQUIP_SUB_ID.CS_CMD_EQUIP_REPAIR, "Repair", EquipRepairReq)
end

-- function EquipmentMgr:SendEquipInfo()
-- 	self:SendEquipCommon(EQUIP_SUB_ID.CS_CMD_EQUIP_INFO, "Info", nil)
-- end

function EquipmentMgr:SendEquipCommon(SubMsgID, DataKey, DataReq)
	local CsEquipReq = {SubCmd = SubMsgID, [DataKey] = DataReq}
	GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_EQUIPMENT, SubMsgID, CsEquipReq)
end

-- function EquipmentMgr:SendProfDetail()
-- 	local ProfReq = {SubMsgID = ProtoCS.ProfSubMsg.ProfSubMsgDetail}	
-- 	GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PROF, ProtoCS.ProfSubMsg.ProfSubMsgDetail, ProfReq)
-- end

function EquipmentMgr:SendEquipOnChecked(EquipReqInfo, CurEquipItem, NewEquipItem)
	if not _G.EquipmentMgr:CheckCanOperate(LSTR(1050178), true) then
		return
	end
	self:SendEquipOn(EquipReqInfo)
end

-----------------------------------------------Req end-----------------------------------------------

function EquipmentMgr:GetPartCount()
	local Prof = MajorUtil.GetMajorProfID()
	local SubWeapon = RoleInitCfg:FindSubWeaponItemType(Prof)
	if SubWeapon == 0 then
		return 11
	end
	return 12
end

function EquipmentMgr:GetEnabledProf(ProfID)
	if EquipmentVM.lstProfDetail == nil then return nil end
	for _, ProfDetail in pairs(EquipmentVM.lstProfDetail) do
		if ProfDetail.ProfID == ProfID then
			return ProfDetail
		end
    end
	return nil
end

---@return c_equipment_cfg
function EquipmentMgr:GetEquipmentCfgByGID(GID)
	local Item = BagMgr:FindItem(GID)
	if Item then
		return EquipmentCfg:FindCfgByEquipID(Item.ResID)
	end
	return nil
end

---通过GID找到Item
---@return Item
function EquipmentMgr:GetItemByGID(GID)
	local Item, Part = EquipmentMgr:GetEquipedItemByGID(GID)
	---如果没找到，再从背包中找
	if Item == nil then
		if BagMgr == nil then
			BagMgr = require("Game/Bag/BagMgr")
		end
		Item = BagMgr:FindItem(GID)
	end
	return Item, Part
end

---@param InPart ProtoCommon.equip_part
function EquipmentMgr:GetPartName(InPart)
	return EquipPartName[InPart]
end

---@param InPart ProtoCommon.equip_part
function EquipmentMgr:GetPartIcon(InPart)
	-- return string.format("Texture2D'/Game/UI/Texture/Role/%s.%s'", UIName, UIName)
	local UIName = string.format("UI_Equipment_Icon_%s_png", PartIconMap[InPart])
	return string.format("PaperSprite'/Game/UI/Atlas/Equipment/Frames/%s.%s'", UIName, UIName)
end

function EquipmentMgr:GetEquipmentTypeName(InEquipmentType)
	return EquipmentTypeName[InEquipmentType]
end

---武器部位 to 物品类型
function EquipmentMgr:GetItemType(InPart, ProfID)
	if InPart == ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND then
		if nil == ProfID then
			return nil
		end
		return RoleInitCfg:FindMainWeaponItemType(ProfID)
	elseif InPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND then
		if nil == ProfID then
			return nil
		end
		return RoleInitCfg:FindSubWeaponItemType(ProfID)
	else
		return EquipPartToItemTypeDetail[InPart]
	end
end

---获取InPart部位的ProfID相关装备，bCanUse区分是否可用,bWithEquiped区分是否包含已穿戴装备
function EquipmentMgr:GetEquipmentsByPart(InPart, ProfID, bCanUse, bWithEquiped)
	--戒指类型特殊处理一下
	if InPart == ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER or InPart == ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER then
		InPart = ProtoCommon.equip_part.EQUIP_PART_FINGER
	end

	local lstEquipments = BagMgr:FindItemsByItemType(ProtoCommon.ITEM_TYPE.ITEM_TYPE_EQUIP)
	local Ret = {}
	local ItemTypeDetail = self:GetItemType(InPart, ProfID)
	if lstEquipments ~= nil then
		for _,v in ipairs(lstEquipments) do
			local ItemCfg = ItemCfg:FindCfgByKey(v.ResID)
			if ItemCfg and ItemCfg.ItemType == ItemTypeDetail then
				if bCanUse == nil then
					Ret[#Ret + 1] = v
				elseif self:CanEquiped(v.ResID) == bCanUse then
					Ret[#Ret + 1] = v
				end
			end
		end
	end

	---如果是戒指类型特殊处理一下
	if ItemTypeDetail == ProtoCommon.ITEM_TYPE_DETAIL.ACCESSORY_RING then
		local NewRet = {}
		for _, v in ipairs(Ret) do
			local EquipmentCfg = EquipmentCfg:FindCfgByEquipID(v.ResID)
			if EquipmentCfg and InPart == EquipmentCfg.Part then
				NewRet[#NewRet + 1] = v
			end
		end
		Ret = NewRet
	end
	
	if bWithEquiped == true then
		local EquipedItem = EquipmentMgr:GetEquipedItemByPart(InPart)
		if nil ~= EquipedItem and EquipedItem.ItemType == ItemTypeDetail then
			Ret[#Ret + 1] = EquipedItem
		end
	end

	return Ret
end

---获取属性真实类型
------@param InProfClass ProtoCommon.attr_type
function EquipmentMgr:GetAttributeRealType(AttrType, Prof)
	if AttrType == ProtoCommon.attr_type.attr_prof_main_attr then
		return RoleInitCfg:GetMainAttrByProf(Prof)
	end
	return AttrType
end

---获取当前职业类型名字
---@param InProfClass ProtoCommon.class_type
function EquipmentMgr:GetProfClassName(InProfClass)
	return ProfDefine.ProfClassName[InProfClass]
end

---获取当前职业类型Icon
---@param InProfClass ProtoCommon.class_type
function EquipmentMgr:GetProfClassIcon(InProfClass)
	return ProfDefine.ProfClassIconMap[InProfClass]
end

---获取当前职业名字
---@param InProfClass ProtoCommon.prof_type
function EquipmentMgr:GetProfName(InProf)
	return RoleInitCfg:FindRoleInitProfName(InProf)
end

---获取当前职业Icon 装备系统专用的icon
---@param InProfClass ProtoCommon.prof_type
function EquipmentMgr:GetProfIcon(InProf)
	return RoleInitCfg:FindRoleInitProfIconSimple(InProf)
end

---判断某个部位是否是武器
function EquipmentMgr:IsWeapon(InPart)
	if InPart == ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND or InPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND then
		return true
	end
	return false
end

-- 获取装备所有部位名
function EquipmentMgr:GetEquipPartName()
	return EquipPartName
end

---通过Part获取该部位装备的物品
---@param InPart ProtoCommon.equip_part
---@return Item common.Item
function EquipmentMgr:GetEquipedItemByPart(InPart)
	local ItemList = EquipmentVM.ItemList

	for Key, Item in pairs(ItemList) do
		if Key == InPart then
			return Item
		end
	end
	return nil
end

--通过Part获取已装备对比物品
function EquipmentMgr:GetEquipedContrastItemByPart(InPart)
	local ItemList = EquipmentVM.ItemList
	local MinLevel = 0
	local CurIndex = 0
	for Key, Item in pairs(ItemList) do
		if InPart ~=  ProtoCommon.equip_part.EQUIP_PART_FINGER then
			if Key == InPart then
				return Item
			end
		else
			if Key == ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER or Key == ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER then
				local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
				if Cfg then
					if MinLevel == 0 then
						CurIndex = Key
						MinLevel = Cfg.ItemLevel
					else
						CurIndex = Cfg.ItemLevel < MinLevel and Key or CurIndex
					end
				end
			end
		end
	end
	return ItemList[CurIndex]
end

---通过GID获取已装备的物品
---@param GID number
---@return Item common.Item
function EquipmentMgr:GetEquipedItemByGID(GID)
	local ItemList = EquipmentVM.ItemList
	if (ItemList == nil) then return end
	for Key, Item in pairs(ItemList) do
		if GID == Item.GID then
			return Item, Key
		end
	end
	return nil, nil
end

function EquipmentMgr:GetEquipedItemNum(ResID)
	if nil == ResID or ResID <= 0 then
		return 0
	end
	local ItemList = EquipmentVM.ItemList
	if nil == ItemList then
		return 0
	end

	local Num = 0
	for _, v in pairs(ItemList) do
		if v.ResID == ResID then
			Num = Num + v.Num
		end
	end

	return Num
end

function EquipmentMgr:GetEquipedItemByResID(ResID)
	if nil == ResID or ResID <= 0 then
		return nil
	end
	local ItemList = EquipmentVM.ItemList
	if nil == ItemList then
		return nil
	end

	local Num = 0
	for _, v in pairs(ItemList) do
		if v.ResID == ResID then
			return v
		end
	end

	return nil
end

---计算已穿戴装备的装备评分
function EquipmentMgr:CalculateEquipScore()
	local Score = 0
	local ItemList = EquipmentVM.ItemList
	if nil == ItemList then
		return Score
	end
	for _, Item in pairs(ItemList) do
		local ItemCfg = ItemCfg:FindCfgByKey(Item.ResID)
		if (ItemCfg) then
			Score = Score + ItemCfg.ItemLevel
		end
	end
	Score = math.ceil(Score / EquipmentMgr:GetPartCount())
	if nil == EquipmentVM.lstProfDetail then
		EquipmentVM.lstProfDetail = _G.ActorMgr:GetMajorRoleDetail().Prof.ProfList
	end
	local ProfDetail = EquipmentVM.lstProfDetail[MajorUtil.GetMajorProfID()]
	if ProfDetail then
		ProfDetail.EquipScore = Score
    end
	return Score
end

---计算能穿戴的最强装备的评分
function EquipmentMgr:CalculateStrongestScore()
	-- 生成Part索引
	local StrongestList = self:GetStrongest()
	local PartIndexMap = {}
	for Index, Strongest in ipairs(StrongestList) do
		PartIndexMap[Strongest.Part] = Index
	end

	-- 计算最强装备评分，若部位已经最强则取部位已穿戴装备评分
	local Score = 0
	local ItemList = EquipmentVM.ItemList
	if nil == ItemList then
		return Score
	end
	for Part = ProtoCommon.equip_part.EQUIP_PART_NONE + 1, ProtoCommon.equip_part.EQUIP_PART_MAX - 1 do
		if nil ~= PartIndexMap[Part] then
			Score = Score + StrongestList[PartIndexMap[Part]].StrongestScore
		else
			local Item = ItemList[Part]
			if nil ~= ItemList[Part] then
				local ItemCfgData = ItemCfg:FindCfgByKey(Item.ResID)
				if nil ~= ItemCfgData then
					Score = Score + ItemCfgData.ItemLevel
				end
			end
		end
	end
	Score = math.ceil(Score / EquipmentMgr:GetPartCount())

	return Score
end

---判断某件装备是否能穿戴
function EquipmentMgr:CanEquiped(ResID, IsShowTips, ProfID, Level)
	local ItemCfg = ItemCfg:FindCfgByKey(ResID)
	---职业类型限制
	do
		local ClassLimit = ProtoCommon.class_type.CLASS_TYPE_NULL
		if nil ~= ItemCfg then
			ClassLimit = ItemCfg.ClassLimit
		end
		local MajorClass = nil ~= ProfID and RoleInitCfg:FindProfClass(ProfID) or MajorUtil.GetMajorProfClass()
		local MajorProfID = ProfID or MajorUtil.GetMajorProfID()
		local bIsProfClassMatch = true
		if ClassLimit == ProtoCommon.class_type.CLASS_TYPE_COMBAT then
			bIsProfClassMatch = RoleInitCfg:FindProfSpecialization(MajorProfID) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
		elseif ClassLimit == ProtoCommon.class_type.CLASS_TYPE_PRODUCTION then
			bIsProfClassMatch = RoleInitCfg:FindProfSpecialization(MajorProfID) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
		elseif ClassLimit ~= ProtoCommon.class_type.CLASS_TYPE_NULL and ClassLimit ~= MajorClass then
			bIsProfClassMatch = false
		end

		if not bIsProfClassMatch then
			-- print("职业类型限制 ResID = "..ResID)
			if (IsShowTips) then
				MsgTipsUtil.ShowTips(LSTR(1050071))
			end
			return false, 1
		end
	end
	
	---职业限制
	if nil ~= ItemCfg then
		local ProfLimit = ItemCfg.ProfLimit
		if type(ProfLimit) == "table" then
			local MajorProfID = nil ~= ProfID and ProfID or MajorUtil.GetMajorProfID()
			local bHasLimit = false	---是否有职业限制
			local bProfHas = false	---ProfID是否在限制中
			for _, v in pairs(ProfLimit) do
				if v ~= ProtoCommon.prof_type.PROF_TYPE_NULL then
					bHasLimit = true
					if v == MajorProfID then
						bProfHas = true
						break
					end
				end
			end
			if bHasLimit == true and bProfHas == false then
				-- print("职业限制 ResID = "..ResID)
				if (IsShowTips) then
					MsgTipsUtil.ShowTips(LSTR(1050071))
				end
				return false, 2
			end
		end
	end

	---等级,这里取真实等级，关卡等级不作限制
	do
		local MajorLevel = Level or MajorUtil.GetTrueMajorLevel()
		MajorLevel = MajorLevel or 0
		local Grade = 0
		if nil ~= ItemCfg then
			Grade = ItemCfg.Grade
		end
		if MajorLevel < Grade then
			-- print("等级 ResID = "..ResID)
			if (IsShowTips) then
				MsgTipsUtil.ShowTips(LSTR(1050070))
			end
			return false, 3
		end
	end

	---种族与性别
	if nil ~= ItemCfg then
		local ConditionID = ItemCfg.UseCond
		local bCanEquip, ConditionFailReasonList = ConditionMgr:CheckConditionByID(ConditionID)
		if not bCanEquip then
			local FailReason = 0
			if ConditionFailReasonList[CondFailReason.RaceLimit] then
				FailReason = 4
				-- print("种族 ResID = "..ResID)
				if IsShowTips then
					MsgTipsUtil.ShowTips(LSTR(1050069))
				end
			elseif ConditionFailReasonList[CondFailReason.GenderLimit] then
				FailReason = 5
				-- print("性别 ResID = "..ResID)
				if (IsShowTips) then
					MsgTipsUtil.ShowTips(LSTR(1050066))
				end
			end
			return false, FailReason
		end
	end

	return true, 0
end

function EquipmentMgr:CheckCanMosic(ResID)
	local EquipmentCfg = require("TableCfg/EquipmentCfg")
	local MateID = 0
	local Cfg = EquipmentCfg:FindCfgByEquipID(ResID)
	if Cfg ~= nil then
		MateID = Cfg.MateID
	end
	local bOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDGemInfo)
	return MateID > 0 and bOpen
end

------------------------------------装备改良相关接口-----------------------------------
function EquipmentMgr:CheckCanImprove(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	local IsInVersion = true
	if Cfg then
		IsInVersion = self:CheckEquipImproveInVersion(ResID)
	else
		return false
	end
	return Cfg.IsCanImproved > 0 and IsInVersion
end

function EquipmentMgr:CheckEquipImproveInVersion(ResID)
	local VersionName = EquipImproveCfg:GetOpenVersion(ResID)
	return VersionName ~= "" and self:BeIncludedInGameVersion(VersionName) or false
end

function EquipmentMgr:GetFristInVersionMaterial()
	local Cfg = EquipImproveMaterialCfg:FindAllCfg()
	for _, value in pairs(Cfg) do
		local InVersion = _G.EquipmentMgr:BeIncludedInGameVersion(value.Version)
		if InVersion then
			return value.ID
		end
	end
	return nil
end

function EquipmentMgr:CheckMaterailCanGet(ResID)
	local Cfg = EquipImproveMaterialCfg:FindCfgByKey(ResID)
	if Cfg and next(Cfg) then
		local Version = Cfg.Version
		local InVersion = self:BeIncludedInGameVersion(Version)
		return InVersion
	else
		return false
	end
end

---@type 指定版本是否被包含于当前游戏版本,跨大版本不包含
---@param VersionName string @指定版本
function EquipmentMgr:BeIncludedInGameVersion(AssignedVersionName)
    if string.isnilorempty(AssignedVersionName) then
		return
    end
	local GameVertion = string.split(self.VersionName,".")
    local AssignedVersion = string.split(AssignedVersionName,".")
    local GameVertionLen = #GameVertion
    local AssignedVersionLen = #AssignedVersion
    if GameVertionLen < 0 or AssignedVersionLen < 0 then
        return
    end

    if AssignedVersionLen > GameVertionLen then
        local offset = AssignedVersionLen - GameVertionLen
        for _ = 1, offset do
            table.insert(GameVertion,"0")
        end
    else
        local offset = GameVertionLen - AssignedVersionLen
        for _ = 1, offset do
            table.insert(AssignedVersion,"0")
        end
    end

    for i = 1, #AssignedVersion-1 do
        if tonumber(AssignedVersion[i]) > tonumber(GameVertion[i]) then
            return false
        elseif tonumber(AssignedVersion[i]) < tonumber(GameVertion[i]) then
			if i == 1 then
				return false
			else
				return true
			end
        end
    end

    local i = #AssignedVersion
    if tonumber(AssignedVersion[i]) > tonumber(GameVertion[i]) then
        return false
    else
        return true
    end
end

function EquipmentMgr:GetVersionName()
	local GameVersionName = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION)
    local VersionName = GameVersionName.Value
    if not table.is_nil_empty(VersionName) then
        VersionName = string.format("%d.%d.%d",VersionName[1],VersionName[2],VersionName[3])
    else
        _G.FLOG_ERROR("EquipmentMgr:GetGameVersionName GameVersionName.Value is nil")
        VersionName = "2.0.0"
    end
	self.VersionName = VersionName
end

function EquipmentMgr:GMSetEquipmentMgrVersionName(intParam1, intParam2, intParam3)
	self.VersionName = string.format("%d.%d.%d",intParam1, intParam2, intParam3)
end

function EquipmentMgr:GetCanImproveEquipment()
	local lstEquipments = EquipmentVM.ItemList
	local TableList = {}
	for key, value in pairs(lstEquipments) do
		local Cfg = EquipImproveCfg:FindCfgByKey(value.ResID)
		if Cfg ~= nil then
			local ResCfg = ItemCfg:FindCfgByKey(value.ResID)
			if ResCfg ~= nil then
				table.insert(TableList, {ResID = value.ResID, ItemLevel = ResCfg.ItemLevel or 0, Part = ResCfg.Classify or 0})
			end
		end
	end

	return TableList
end

function EquipmentMgr:GetImproveMaterialEnough(ResID)
	local Cfg = EquipImproveCfg:FindCfgByKey(ResID)
	--MarterialID
	if Cfg and next(Cfg) then
		local MarterialID = Cfg.MaterialID
		local HasNum = _G.BagMgr:GetItemNum(MarterialID)
		return HasNum >= Cfg.Num
	end
	return false
end

function EquipmentMgr:GetSwitchMaterialListNum()
	local Cfg = EquipImproveMaterialCfg:FindAllCfg()
	local Num = 0
	if Cfg and next(Cfg) then
		for _, value in pairs(Cfg) do
			--判断版本号
			local VersionName = value.Version
			local InVersion = self:BeIncludedInGameVersion(VersionName)
			local CanExchange = EquipImproveMaterialCfg:GetCanExchange(value.ID)
			if InVersion and CanExchange then
				Num = Num + 1
			end
		end
	end
	return Num
end

---返回true，选择item， 返回false，不选
local function StrongestCondition(Item, StrongestItem, MaxScore, bEquiped)
	if Item == nil then return false end

	local c_item_cfg = ItemCfg:FindCfgByKey(Item.ResID)
	if c_item_cfg == nil then return false end

	local c_equipment_cfg = EquipmentCfg:FindCfgByEquipID(Item.ResID)
	if c_equipment_cfg == nil then return false end

	if MaxScore > c_item_cfg.ItemLevel  then return false end
	if MaxScore < c_item_cfg.ItemLevel  then return true, c_item_cfg.ItemLevel end

	---4.选择装备时，品级若有相同的则优先选择绑定的和高耐久的装备
	if bEquiped then
		return true, c_item_cfg.ItemLevel
	end
	if StrongestItem and Item.IsBind ~= StrongestItem.IsBind then
		return Item.IsBind, c_item_cfg.ItemLevel
	end

	---绑定状态相同， 优先选高耐久
	if StrongestItem then
		return Item.Attr.Equip.EndureDeg > StrongestItem.Attr.Equip.EndureDeg, c_item_cfg.ItemLevel
	end
	return false
end

---获取背包里可装备的最强装备数组
---Strongest元素：{Current = Item, Strongest = Item1, CurrentScore = ItemScore, StrongestScore = Item1Score}
function EquipmentMgr:GetStrongest()
	local Strongest = {}
	local ProfID = MajorUtil.GetMajorProfID()
	local StrongestGIDMap = {}
	for v = ProtoCommon.equip_part.EQUIP_PART_NONE + 1, ProtoCommon.equip_part.EQUIP_PART_MAX - 1 do
		---从背包找Part部位可用装备
		local lstItem = EquipmentMgr:GetEquipmentsByPart(v, ProfID, true)
		local MaxScore = -1
		local StrongestItem = nil
		for _, Item in pairs(lstItem) do
			local bMax, Score = StrongestCondition(Item, StrongestItem, MaxScore)
			if bMax and StrongestGIDMap[Item.GID] == nil then
				StrongestItem = Item
				MaxScore = Score
			end
		end
		
		local EquipedItem = EquipmentMgr:GetEquipedItemByPart(v)
		local EquipedItemScore = 0
		if EquipedItem then
			local EquipedItemCfg = ItemCfg:FindCfgByKey(EquipedItem.ResID)
			if EquipedItemCfg then
				EquipedItemScore = EquipedItemCfg.ItemLevel
			end
		end

		if StrongestItem ~= nil and (EquipedItem == nil or EquipedItemScore < MaxScore) then
			Strongest[#Strongest + 1] = {Part = v, Current = EquipedItem, Strongest = StrongestItem, CurrentScore = EquipedItemScore, StrongestScore = MaxScore}
			StrongestGIDMap[StrongestItem.GID] = 1
		end
	end

	---排序
    local function SortComparison(Left, Right)
        local LeftPart = Left.Part
        local RightPart = Right.Part

        return EquipmentUtil.SortComparison(LeftPart, RightPart)
    end
    table.sort(Strongest, SortComparison)

	return Strongest
end

function EquipmentMgr:OnMajorLevelUpdate(Params)
	for Part = ProtoCommon.equip_part.EQUIP_PART_NONE + 1, ProtoCommon.equip_part.EQUIP_PART_MAX - 1 do
		self.StrongestEquipInfos[Part].Item, self.StrongestEquipInfos[Part].ItemLevel, self.StrongestEquipInfos[Part].bEquiped =
	    self:GetStrongestEquipOfPart(Part, MajorUtil.GetMajorProfID())
		_G.EventMgr:SendEvent(_G.EventID.StrongestEquipUpdate)
	end
end

-- 查找单个部位的最强装备
---GetStrongestEquipOfPart
---@param Part ProtoCommon.equip_part
---@return StrongestItem common.Item
---@return MaxItemLevel number
---@return bEquiped boolean
function EquipmentMgr:GetStrongestEquipOfPart(Part, ProfID)
	-- 从背包找Part上可用的装备
	local Items = EquipmentMgr:GetEquipmentsByPart(Part, ProfID, true)
	local MaxItemLevel = -1
	local StrongestItem = nil
	for _, Item in pairs(Items) do
		local bIsStronger, Score = StrongestCondition(Item, StrongestItem, MaxItemLevel, false)
		if bIsStronger then
			StrongestItem = Item
			MaxItemLevel = Score
		end
	end

	-- Part的当前装备
	local EquipedItem = EquipmentMgr:GetEquipedItemByPart(Part)
	local bEquiped = false
	local bIsStronger, ItemLevel = StrongestCondition(EquipedItem, StrongestItem, MaxItemLevel, true)
	if bIsStronger then
		StrongestItem = EquipedItem
		MaxItemLevel = ItemLevel
		bEquiped = true
	end

	return StrongestItem, MaxItemLevel, bEquiped
end

-- 更新单个部位的最强装备信息
---UpdateStrongestEquip
---@param Part ProtoCommon.equip_part
---@param InItem common.Item
---@param bEquiped boolean
---@param bOn boolean
function EquipmentMgr:UpdateStrongestEquip(Part, InItem, bEquiped, bOn)
	if nil == self.StrongestEquipInfos[Part].Item then
		-- 当前部位最强装备信息未知，更新一次
		self.StrongestEquipInfos[Part].Item, self.StrongestEquipInfos[Part].ItemLevel, self.StrongestEquipInfos[Part].bEquiped =
		  self:GetStrongestEquipOfPart(Part, MajorUtil.GetMajorProfID())
		_G.EventMgr:SendEvent(_G.EventID.StrongestEquipUpdate)
	elseif nil ~= InItem then
		if bOn then
			-- 与当前部位最强装备作比较
			local bStrongestUpdated = false
			local StrongestItemLevel = 0
			bStrongestUpdated, StrongestItemLevel = StrongestCondition(InItem, self.StrongestEquipInfos[Part].Item,
			self.StrongestEquipInfos[Part].ItemLevel, bEquiped)
			if bStrongestUpdated then
				self.StrongestEquipInfos[Part].Item = InItem
				self.StrongestEquipInfos[Part].ItemLevel = StrongestItemLevel
				self.StrongestEquipInfos[Part].bEquiped = bEquiped
				_G.EventMgr:SendEvent(_G.EventID.StrongestEquipUpdate)
			else
				if bOn and bEquiped then
					self.StrongestEquipInfos[Part].bEquiped = false
				end
			end
		elseif self.StrongestEquipInfos[Part].Item.GID == InItem.GID then
			-- 当前部位最强装备被卸载，更新一次
			self.StrongestEquipInfos[Part].Item, self.StrongestEquipInfos[Part].ItemLevel, self.StrongestEquipInfos[Part].bEquiped =
			  self:GetStrongestEquipOfPart(Part, MajorUtil.GetMajorProfID())
			_G.EventMgr:SendEvent(_G.EventID.StrongestEquipUpdate)
		end
	end
end

---判断当前装备是否已经是最强装备（当前仅进入装备界面会全量更新，进入前数据不是最新的）
function EquipmentMgr:IsStrongest()
	local bIsStrongest = true
	for Part, EquipInfo in pairs(self.StrongestEquipInfos) do
		if nil ~= EquipInfo.Item and not EquipInfo.bEquiped then
			--如果当前穿戴是两件一样的装备，不管耐久度
			local EquipedItem = EquipmentMgr:GetEquipedItemByPart(Part)
			if EquipedItem and EquipInfo.Item.ResID ~= EquipedItem.ResID then
				bIsStrongest = false
				break
				--卸下装备且最强装备有记录，则最强为false
			elseif not EquipedItem and EquipInfo.Item then
				bIsStrongest = false
				break
			end
		end
	end
	return bIsStrongest
end

function EquipmentMgr:HasEquipmentNeedRepair()
	--要先判断是否所有装备的耐久度都满
	local bNeedRepair = false

	local ItemList = EquipmentVM.ItemList
    if ItemList == nil then 
		bNeedRepair = false
	else
		for _, Item in pairs(ItemList) do
			--print("%d", Item.ResID)
			if Item.Attr.Equip.EndureDeg < 10000 then
				bNeedRepair = true
				break
			end
		end
	end
	return bNeedRepair
end

function EquipmentMgr:CheckTipsForEndureDeg()
	local ItemList = EquipmentVM.ItemList
    if ItemList == nil then 
		return
	end
	local Count = 0
	for Key, Item in pairs(ItemList) do
		if Item.Attr.Equip.EndureDeg <= 1000 then
			local Tips = LSTR(1050125)
			MsgTipsUtil.ShowTips(Tips)
			return
		end
	end
end

function EquipmentMgr:OpenEquipmentRepair(GID)
	--打开套装修理 要先判断是否所有装备的耐久度都满
	if not self:CheckCanOperate(LSTR(1050147)) then
		return 
	end
	if EquipmentMgr:HasEquipmentNeedRepair() then
		UIViewMgr:ShowView(UIViewID.EquipmentSuitRepair, {GID = GID})
	else
		MsgTipsUtil.ShowTips(LSTR(1050068))
	end
end

function EquipmentMgr:CheckCanOperate(localisionStr, isChangeEquipment)
	
	local BehaviorID = ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CHANGE_EQUIP
	if not CommonStateUtil.CheckBehavior(BehaviorID, false) then
		MsgTipsUtil.ShowTips(string.format(LSTR(1050224),localisionStr))
		return
	end

	if isChangeEquipment then
		local Cnt = _G.PWorldVoteMgr:GetEnterSceneRoleCnt()
		if Cnt > 0 then
			MsgTipsUtil.ShowTips(string.format(LSTR(1050154),localisionStr))
        	return false
		end

		if PWorldEntourageMgr:GetConfirmState() then
			MsgTipsUtil.ShowTips(string.format(LSTR(1050154),localisionStr))
       		return false
		end
	end
	return true
end

--获取可镶嵌的魔晶石列表
function EquipmentMgr:GetMagicsparsFromBag(bNomal)
	local Lst = BagMgr:FindItemsByItemType(ProtoCommon.ITEM_TYPE.ITEM_TYPE_GEM)

	local Ret = {}
	for i = 1, #Lst do
		local ResID = Lst[i].ResID	--60810101
		local Cfg = MagicsparAttrCfg:FindCfgByKey(ResID)
		if Cfg ~= nil then
			if (bNomal == true and Cfg.Type == ProtoCommon.hole_type.HOLE_TYPE_NORMAL) or
				(bNomal == false and Cfg.Type == ProtoCommon.hole_type.HOLE_TYPE_TABOO) then
				Ret[#Ret + 1] = Lst[i]
			end
		end
	end

	return Ret
end

--获取魔晶石属性Key
function EquipmentMgr:GetMagicsparsAttrKey(InResID)
	local Cfg = MagicsparAttrCfg:FindCfgByKey(InResID)
	if Cfg == nil then
		return nil
	end
	return Cfg.Attr.attr or Cfg.Attr.Attr
end

--获取魔晶石属性value
function EquipmentMgr:GetMagicsparsAttrValue(InResID)
	local Cfg = MagicsparAttrCfg:FindCfgByKey(InResID)
	if Cfg == nil then
		return nil
	end
	--return Cfg.Attr.value
	return Cfg.Attr.value or Cfg.Attr.Value
end

function EquipmentMgr:CalculateAttrProfit(AttrKey, AttrValue, c_attr_param_cfg)
	local Profit, Percent, Raito, MaxRaito

	if nil == c_attr_param_cfg then
		return 0, 0, 0
	end

	if AttrKey == ProtoCommon.attr_type.attr_critical then
		---暴击
		---暴击收益=暴击属性值/1.5/暴击等级系数*暴击收益系数+1 
		Profit = AttrValue/1.5/c_attr_param_cfg.CriticalLevel*c_attr_param_cfg.CriticalProfit + 1  
		---暴击伤害倍率加成百分比=(power(0.16+12*(暴击收益-1),0.5)-0.4)/2
		Percent = (((0.16+12*(Profit-1))^0.5)-0.4)/2
		---暴击发生概率百分比=(暴击收益-1)/(1.4+暴击伤害倍率加成百分比-1）
		Raito = (Profit - 1)/(1.4+Percent-1)
		MaxRaito = 0.2

	elseif AttrKey == ProtoCommon.attr_type.attr_direct_atk then
		---直击			
		-- // 直击收益=直击属性值/直击等级系数*直击收益系数+1 
		Profit = AttrValue/c_attr_param_cfg.DirectAtkLevel*c_attr_param_cfg.DirectAtkProfit+1 		
		-- // 直击发生概率百分比=(直击收益-1)*4	 0.4	
		Raito = (Profit-1)*4
		-- // 直击伤害倍率=1.25	
		MaxRaito = 0.4		
	
	elseif AttrKey == ProtoCommon.attr_type.attr_belief then
		-- // 信念收益=信念属性值*0.75/信念等级系数*信念收益系数+1 	
		Profit = AttrValue*0.75/c_attr_param_cfg.BeliefLevel*c_attr_param_cfg.BeliefProfit+1 	
		-- // 信念伤害增益百分比=信念收益-1	 0.15	
		-- // 信念治疗增益百分比=信念收益-1	 0.15
		Percent = Profit-1
		MaxRaito = 0.15

	elseif AttrKey == ProtoCommon.attr_type.attr_quick then
		-- // 急速收益=急速属性值/急速等级系数*急速收益系数+1 	
		Profit = AttrValue/c_attr_param_cfg.QuickLevel*c_attr_param_cfg.QuickProfit+1
		-- // 技能动作加速百分比=急速收益-1			0.1
		-- // 技能冷却减少百分比=急速收益-1			0.1
		-- // 吟唱时间减少百分比=急速收益-1			0.1
		Percent = Profit-1
		MaxRaito = 0.1

	elseif AttrKey == ProtoCommon.attr_type.attr_ductility then
		-- 韧性
		-- // 韧性收益=韧性属性值/韧性等级系数*韧性收益系数+1 
		Profit = AttrValue/c_attr_param_cfg.DuctilityLevel*c_attr_param_cfg.DuctilityProfit+1 
		-- // PVP韧性减伤百分比=(韧性收益-1)/韧性收益	
		Percent = (Profit-1)/Profit

	elseif AttrKey == ProtoCommon.attr_type.attr_puncture then
		-- 穿刺
		-- // 穿刺收益=穿刺属性值/穿刺等级系数*穿刺收益系数+1 	
		Profit = AttrValue/c_attr_param_cfg.PunctureLevel*c_attr_param_cfg.PunctureProfit+1 
		-- // PVP穿刺增伤百分比=穿刺收益-1
		Percent = Profit-1	

	elseif AttrKey == ProtoCommon.attr_type.attr_physic_def or AttrKey == ProtoCommon.attr_type.attr_magic_def then
		-- 防御			
		-- // 防御收益=防御属性值/防御等级系数*防御收益系数+1	
		Profit = AttrValue/c_attr_param_cfg.DefenseLevel*c_attr_param_cfg.DefenseProfit+1			
		-- // 防御免伤百分比=(防御收益-1)/防御收益
		Percent = (Profit-1)/Profit	

	end

	return Percent, Raito, MaxRaito
end

function EquipmentMgr:IsEquiped(GID)
	for _, Item in pairs(EquipmentVM.ItemList) do
		if Item.GID == GID then
			return true
		end
	end

	return false
end

-- 检查职业套装完整性
function EquipmentMgr:CheckSuitIntegrity(ProfID)
	local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
	local SuitIntegrityState = EquipmentDefine.SuitIntegrityState.Integrated
	local ProfLevel = RoleDetail.Prof.ProfList[ProfID].Level
	local RawWeaponName = nil
	local ReplaceWeaponItem = nil

	if nil == RoleDetail.Prof.ProfList[ProfID].EquipScheme then
		return SuitIntegrityState, nil, nil
	end
	
	for Part, EquipInfo in pairs(RoleDetail.Prof.ProfList[ProfID].EquipScheme) do
		local ItemEquip = self:GetItemByGID(EquipInfo.GID)
		-- 未找到装备
		if nil == ItemEquip then
			if Part == ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND then
				-- 未找到武器，查找是否有当前职业的其他主手武器
				RawWeaponName = ItemCfg:FindValue(EquipInfo.ResID, "ItemName")
				local HighestLevel = 0
				SuitIntegrityState = EquipmentDefine.SuitIntegrityState.LackWeapon
				local ItemEquips = self:GetEquipmentsByPart(Part, ProfID, nil, true)
				-- 查找品级最高的武器
				for _, Item in ipairs(ItemEquips) do
					if self:CanEquiped(Item.ResID, false, ProfID, ProfLevel) then
						local FoundItemCfg = ItemCfg:FindCfgByKey(Item.ResID)
						local ItemLevel = 0
						if nil ~= FoundItemCfg then
							ItemLevel = FoundItemCfg.ItemLevel
						end
						ReplaceWeaponItem = ItemLevel > HighestLevel and Item or ReplaceWeaponItem
						HighestLevel = math.max(ItemLevel, HighestLevel)
					end
				end
				break
			else
				-- 未找到非武器装备
				SuitIntegrityState = EquipmentDefine.SuitIntegrityState.LackArmor
			end
		end
	end

	return SuitIntegrityState, RawWeaponName, ReplaceWeaponItem
end

function EquipmentMgr:GetEquipmentCharacterClass()
	return CharacterClass
end

function EquipmentMgr:GetLightConfig()
	return EquipmentLightConfig
end

-------------------- 页面跳转 --------------------
-- 打开职业详情界面
function EquipmentMgr:ShowProfDetail()
	_G.UIViewMgr:ShowView(_G.UIViewID.EquipmentMainPanel)
	EquipmentVM.bShowProfDetail = true
end

-- 打开魔晶石镶嵌界面s
---- @Param {GID, ResID, Tag}
function EquipmentMgr:TryInlayMagicspar(Param)
	if not self:CheckCanOperate(LSTR(1050177)) then
		return
	end
	local MateID = 0
	local EquipmentCfg = EquipmentCfg:FindCfgByEquipID(Param.ResID)
	if EquipmentCfg ~= nil then
		MateID = EquipmentCfg.MateID
	end
	if MateID > 0 then
		_G.UIViewMgr:ShowView(_G.UIViewID.MagicsparInlayMainPanel, Param)
	else
		MsgTipsUtil.ShowTips(LSTR(1050094))
	end
end

-- 装备上是否有魔晶石
function EquipmentMgr:IsEquipHasMagicspar(GID)
	local bInlay = false
	local Item = self:GetItemByGID(GID)
	if Item  ~= nil and Item.Attr ~= nil and Item.Attr.Equip ~= nil and Item.Attr.Equip.GemInfo ~= nil then
		local CarryList = Item.Attr.Equip.GemInfo.CarryList
		if CarryList ~= nil and table.size(CarryList) > 0 then 
			bInlay = true;
		end
	end
	return bInlay;
end

function EquipmentMgr:GetFingerEquipState()
	local lstEquipments = EquipmentVM.ItemList
	if not EquipmentVM.ItemList[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] then
		return ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER
	elseif not EquipmentVM.ItemList[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] then
		return ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER
	else
		return ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER
	end
end

--这里有优化空间，后续处理一下 by luojiewen_ds
---@param ProfID number 职业ID，必须未解锁职业ID
function EquipmentMgr:OpenEquipmentByPreviewProf(ProfID)
	self:SetPreviewProfID(true, ProfID)
	_G.UIViewMgr:ShowView(_G.UIViewID.EquipmentMainPanel, {bPlayAnimIn = false, bPreviewIn = true})
	self:SwitchUIActor(ProfID)
end

---ShowEquipDetail 打开装备详情界面
---@param Params table {Part = Part, GID = GID}
function EquipmentMgr:ShowEquipDetail(Params)
	local MainPanel = _G.UIViewMgr:ShowView(_G.UIViewID.EquipmentMainPanel, {bPlayAnimIn = false})
	local CallBack = function()
		local Part = Params.Part
		if Params.Part == ProtoCommon.equip_part.EQUIP_PART_FINGER then
			Part = self:GetFingerEquipState()
		end
		MainPanel.AdapterTabTableView:SetSelectedIndex(2)
		MainPanel:SwitchPage(2)
		MainPanel:OnSlotClick(Part)
	
		if not MainPanel.CurrrentEquipList or not MainPanel.CurrrentEquipList.EquipmentListPage or
		   not MainPanel.CurrrentEquipList.EquipmentListPage.ViewModel then
			FLOG_ERROR("Equipment list not initialized")
			return
		end
		local ListPageVM = MainPanel.CurrrentEquipList.EquipmentListPage.ViewModel
		ListPageVM:SelectByGID(Params.GID)
	
		--FLOG_ERROR("Not found equipment of GID %d in Part %d", Params.GID, Params.Part)
	end
	if MainPanel then
		MainPanel:SetAssembleCallBack(CallBack)
	end
end

function EquipmentMgr:ShowSkillPreview(Prof)
	local MainPanel = _G.UIViewMgr:ShowView(_G.UIViewID.EquipmentMainPanel, {bPlayAnimIn = false})
	local CallBack = function()
		self:SwitchProfByID(Prof)
		MainPanel.AdapterTabTableView:SetSelectedIndex(2)
		MainPanel:SwitchPage(22)
	end
	MainPanel:SetAssembleCallBack(CallBack)
end

--- 是否可调整设置（头部装备）
---@param ResID number@装备道具ID
function EquipmentMgr:IsEquipHasGimmick(ResID)
    local Ecfg = EquipmentCfg:FindCfgByEquipID(ResID)
	if Ecfg == nil then
		return false
	end

	local EquipType = Ecfg.EquipmentType
	if EquipType == nil then
		return false
	end

	if EquipType ~= EquipmentType.HEAD_ARMOUR then
		return false
   	end

	local ModelString = Ecfg.ModelString
	if ModelString == nil then
		return false
	end

	local ModelIDTag = string.split(ModelString, ",")
	if ModelIDTag == nil or next(ModelIDTag) == nil then
		return false
	end

	local Tag = ModelIDTag[1]
	local TagLen = string.len(Tag)
	while TagLen < EquipmentDefine.ModelIDStandardLength do
		Tag = string.format("0%s", Tag)
		TagLen = TagLen + 1
	end

	local ModelID = string.format("'e%s'", Tag)
	local FindCond = string.format("EquipID = %s", ModelID)
	local ModelCfg = EquipParamCfg:FindCfg(FindCond)
	if ModelCfg == nil then
		return false
	end
	
	return ModelCfg.HasGimmick == 1
end

--- 装备是否可以被投影
---@param ResID number@装备ID
function EquipmentMgr:IsEquipCanBeInprojection(ResID)
	-- todo 装备表添加字段
	return true
end

-- ---判断某个部位是否是防具
-- function EquipmentMgr:IsArmour(InPart)
-- 	if InPart == ProtoCommon.equip_part.EQUIP_PART_HEAD or InPart == ProtoCommon.equip_part.EQUIP_PART_BODY or
-- 		InPart == ProtoCommon.equip_part.EQUIP_PART_ARM or InPart == ProtoCommon.equip_part.EQUIP_PART_LEG or
-- 		InPart == ProtoCommon.equip_part.EQUIP_PART_FEET then
-- 		return true
-- 	end
-- 	return false
-- end

-- ---判断某个部位是否是饰品
-- function EquipmentMgr:IsArmour(InPart)
-- 	if InPart == ProtoCommon.equip_part.EQUIP_PART_NECK or InPart == ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER or
-- 		InPart == ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER or InPart == ProtoCommon.equip_part.EQUIP_PART_WRIST or
-- 		InPart == ProtoCommon.equip_part.EQUIP_PART_EAR then
-- 		return true
-- 	end
-- 	return false
-- end

--- 魔晶石预加载
function EquipmentMgr:PreLoadMagicspar()
	local RenderActorPath = MagicsparDefine.RenderActorPath
	_G.ObjectMgr:LoadClassAsync(RenderActorPath, nil, ObjectGCType.LRU)
end

--- 红点
function EquipmentMgr:SetRedDot(RetDotID, bShow)
	local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
	if not RetDotID  then return end
	
	if bShow then
		RedDotMgr:AddRedDotByID(RetDotID, nil, false)
	end

	if not bShow then
		RedDotMgr:DelRedDotByID(RetDotID)
	end
end

--转职红点刷新
function EquipmentMgr:UpdateRoleRedDot()
	--判断已解锁职业满足要求的红点
	local ProfDetail = _G.ActorMgr:GetMajorRoleDetail()
	if not ProfDetail then return end
	local ProfList = ProfDetail.Prof and ProfDetail.Prof.ProfList or {}
	local ProfRedData = {}
	local HasSoulRedDot = false
	if not ProfList or not next(ProfList) then return end
	for k, v in pairs(ProfList) do
		local Level = v.Level
		--先判断是否是特职
		local ProfID = v.ProfID
		local IsAdvancedProf = ProfUtil.IsAdvancedProf(ProfID)
		--是基职且等级大于12，则加入红点
		local IsProductionProf = ProfUtil.IsProductionProf(ProfID)
		if not IsProductionProf then
			if not IsAdvancedProf then
				if Level and Level > 12 then
					local CurTime = _G.TimeUtil.GetServerTime()
					local ClickTime = self.SoulBtnClickTimeTable[tostring(ProfID)] or 0
					local IsSameDay = self:IsSameDay(CurTime, ClickTime)
					--先判断有没有特职
					local AdvancedProf = RoleInitCfg:FindProfAdvanceProf(ProfID)
					if AdvancedProf and AdvancedProf > 0 and ProfList[AdvancedProf] then
						ProfRedData[ProfID] = false
						self:SetRedDot(tonumber("71"..string.format("%02d", ProfID)), false) 
					else
						if not IsSameDay then
							ProfRedData[ProfID] = true
							self:SetRedDot(tonumber("71"..string.format("%02d", ProfID)), true)
						else
							ProfRedData[ProfID] = false
							self:SetRedDot(tonumber("71"..string.format("%02d", ProfID)), false) 
						end
					end
				else
					ProfRedData[ProfID] = false
					self:SetRedDot(tonumber("71"..string.format("%02d", ProfID)), false)
				end
			else
				local ProfCfg = RoleInitCfg:FindProfForPAdvance(ProfID)
				if ProfCfg and next(ProfCfg) then
					local Prof = ProfCfg.Prof
					ProfRedData[Prof] = false
					self:SetRedDot(tonumber("71"..string.format("%02d", Prof)), false)
				end
			end
		end
	end
	HasSoulRedDot = ProfRedData[EquipmentMainVM.ProfID]
	self:SetRedDot(7010, HasSoulRedDot)
	self.ProfRedData = ProfRedData
end

function EquipmentMgr:GetRoleRedDotData()
	return self.ProfRedData or {}
end
function EquipmentMgr:IsSameDay(timestamp1, timestamp2)
	if timestamp1 == 0 or timestamp2 == 0 then
		return false
	end
	local date1 = os.date("*t", timestamp1)
	local date2 = os.date("*t", timestamp2)
	return date1.year == date2.year and date1.month == date2.month and date1.day == date2.day
end

function EquipmentMgr:SetSoulBtnClickTimeTable(Prof)
	local IsAdvancedProf = ProfUtil.IsAdvancedProf(Prof)
	local IsProductionProf = ProfUtil.IsProductionProf(Prof)
	local Level = RoleInitCfg:FindProfLevel(Prof)
	local CurTime = _G.TimeUtil.GetServerTime()
	if not IsProductionProf and not IsAdvancedProf then
		self.SoulBtnClickTimeTable[tostring(Prof)] = CurTime
		local Params = {}
    	Params.IntParam1 = ClientSetupID.RoleChgProfRedPoint
    	Params.StringParam1 = Json.encode(self.SoulBtnClickTimeTable)
    	_G.ClientSetupMgr:OnGameEventSet(Params)
		self:UpdateRoleRedDot()
	end
end

function EquipmentMgr:SwitchUIActor(ProfID)
	local Data = {IsUnlock = true, ProfID = ProfID}
	_G.EventMgr:SendEvent(_G.EventID.SwitchLockProf, Data)
end

--重置Npc旋转和位置
function EquipmentMgr:ResetActorCamera(ProfID)
end

function EquipmentMgr:CreateActorToUI(ProfID)
end

function EquipmentMgr:HideAllUINpc()
end

function EquipmentMgr:RemoveUINPC()
end 

function EquipmentMgr:ResetStrongestEquipInfos()
	for Part = ProtoCommon.equip_part.EQUIP_PART_NONE + 1, ProtoCommon.equip_part.EQUIP_PART_MAX - 1 do
		self.StrongestEquipInfos[Part] = {}
		self.StrongestEquipInfos[Part].bEquiped = false
		self.StrongestEquipInfos[Part].ItemLevel = 0
		self.StrongestEquipInfos[Part].Item = nil
	end
end

function EquipmentMgr:SetPreviewProfID(IsPreview, Prof)
	self.IsPreviewProf = IsPreview
	self.PreviewProfID = Prof
end

function EquipmentMgr:GetPreviewProfID()
	return self.PreviewProfID
end

---最强装备动画计数，防止Item复用多次播放动画
function EquipmentMgr:SetStrongestAnimPlayNum(isLeft, Num)
	if isLeft then
		self.HasPlayStrongestAnimNumL = Num
	else
		self.HasPlayStrongestAnimNumR = Num
	end
end

function EquipmentMgr:GetCanPlayStrongestAnimNum()
	return self.CanPlayStrongestAnimNum
end

function EquipmentMgr:GetHasPlayStrongestAnimNumL()
	return self.HasPlayStrongestAnimNumL
end

function EquipmentMgr:GetHasPlayStrongestAnimNumR()
	return self.HasPlayStrongestAnimNumR
end

function EquipmentMgr:OpenEquipmentMainPanelAndProfTab(IsFight)
	local ProfSpecialization = IsFight and ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT or 
	ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	self:SetEquipmentProfSpecialization(ProfSpecialization)
	local View = UIViewMgr:ShowView(_G.UIViewID.EquipmentMainPanel)
	View:OnProfDetailClick(_, 1)
end

function EquipmentMgr:SetEquipmentProfSpecialization(ProfSpecialization)
	self.EquipmentProfSpecialization = ProfSpecialization
end

function EquipmentMgr:GetEquipmentProfSpecialization()
	return self.EquipmentProfSpecialization
end

function EquipmentMgr:GetLocalProfExpByID(ProfID)
	if self.LocalProfExpTable and next(self.LocalProfExpTable) then
		if self.LocalProfExpTable[ProfID] then
			return self.LocalProfExpTable[ProfID]
		end
	end
	return -1
end

function EquipmentMgr:GetCanSwitchHatVisble()
	local EntityID = MajorUtil.GetMajorEntityID()
	local AttrComponent = ActorUtil.GetActorAttributeComponent(EntityID)
	if nil ~= AttrComponent then
		local ChangeRoleID = AttrComponent:GetChangeRoleID()
        if ChangeRoleID ~= 0 then
			return false
		else
			return true
        end
    end
end

function EquipmentMgr:OnGameEventChangeRoleIDChanged(Params)
	if not Params then return end
	local EntityID = Params.ULongParam1
	local ChangeRoleID = Params.IntParam1
	if not MajorUtil.IsMajor(EntityID) then
		return
	end
	if ChangeRoleID == 0 then
		local Idx =  EquipmentMainVM:GetSettingsTabRole().ShowHeadIdx
		EquipmentVM.bIsShowHead = Idx == 1
		local SendIndex = Idx == 1 and 1 or 0
		self:SendEquipOn({{Part = ProtoCommon.equip_part.EquipHeadShow, GID = SendIndex}})
	end

end

return EquipmentMgr