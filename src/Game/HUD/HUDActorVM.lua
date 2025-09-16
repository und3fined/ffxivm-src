---
--- Author: anypkvcai
--- DateTime: 2021-07-07 15:44
--- Description: 玩家、怪物、NPC等Actor头顶UI的ViewModel
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local HUDType = require("Define/HUDType")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local NpcCfg = require("TableCfg/NpcCfg")
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")
local MonsterCfg = require("TableCfg/MonsterCfg")
local EnmityCfg = require("TableCfg/EnmityCfg")
local NPCBaseCfg = require("TableCfg/NpcbaseCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local TitleDefine = require("Game/Title/TitleDefine")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local FateDefine = require("Game/Fate/FateDefine")
local HUDConfig = require("Define/HUDConfig")
local ActorUIUtil = require("Utils/ActorUIUtil")
local CommonUtil = require("Utils/CommonUtil")
local EObjCfg = require("TableCfg/EobjCfg")
local TargetmarkCfg = require("TableCfg/TargetmarkCfg")
local UserDataID = require("Define/UserDataID")
local ProtoCS = require("Protocol/ProtoCS")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local NPC_TYPE = ProtoRes.NPC_TYPE
local EActorType = _G.UE.EActorType
local LSTR = _G.LSTR
local RoleGender = ProtoCommon.role_gender
local OpenTitleState = TitleDefine.OpenTitleState

---@class HUDActorVM : UIViewModel
local HUDActorVM = LuaClass(UIViewModel)

---Ctor
function HUDActorVM:Ctor()
	self.HUDType = nil

	self.EntityID = nil
	self.RoleID = nil

	self.Name = nil
	self.NameColor = nil
	self.NameOutlineColor = nil
	self.NameVisible = true

	self.IsDraw = true
	self.IsMovieState = false
	self.IsCaptain = nil
	self.IsTeamMember = nil
	self.IsRecruiting = false
	self.CaptainStateIcon = nil

	self.SpectrumAmount = 0
	self.SpectrumVisible = false
	self.SpectrumColor = nil
	self.SpectrumAsset = nil
	self.SpectrumBgAsset = nil
	self.SpectrumTextureSize = nil
	self.SpectrumPadding = nil

	self.HPFillAmount = 1
	self.HPBarVisible = false
	self.HPBarFillColor = nil
	self.HPBarShadowColor = nil
	self.HPBarBgColor = nil

	self.SelectVisible = nil
	self.SelectArrowColor = nil

	self.ConfigTextColor = nil
	self.ConfigOutlineColor = nil

	--头顶状态图标(任务、幻卡等)
	self.StateVisible = true
	self.StateIconAsset = nil
	self.SecondStateIconAsset = nil

	--怪物来源
	--self.MonsterSourceType = nil
	self.MonsterTypeIcon = nil

	--称号
	self.TopTitleVisible = false
	self.TopTitleText = nil
	self.BelowTitleVisible = false
	self.BelowTitleText = nil

	-- 在线状态图标 or 陆行鸟编号
	self.OnlineStatusIcon = nil

	self.ProfIcon = nil
	self.ProfIconOffsetX = 0

	self.ActorUIType = 0  -- 目前在UpdateUIColor中更新

	self.TargetMarkIcon = nil  -- 目标标记图标
	self.TargetMarkVisible = true

	self.IsInteractiveTarget = false

	self.EidMountPoint = ""
	self.OffsetY = 0

	self.CombatStateID = -1
end

function HUDActorVM:UpdateVM(EntityID, Type)
	self.Name = nil
	self.NameColor = nil
	self.NameOutlineColor = nil
	self.NameVisible = true
	self.ArmyShortName = nil
	self.IsDraw = true
	self.IsMovieState = false
	self.IsCaptain = nil
	self.IsTeamMember = nil
	self.IsRecruiting = false
	self.CaptainStateIcon = nil
	self.SpectrumAmount = 0
	self.SpectrumVisible = false
	self.SpectrumColor = nil
	self.SpectrumAsset = nil
	self.SpectrumBgAsset = nil
	self.SpectrumTextureSize = nil
	self.SpectrumPadding = nil
	self.HPFillAmount = 1
	self.HPBarVisible = false
	self.HPBarFillColor = nil
	self.HPBarShadowColor = nil
	self.HPBarBgColor = nil
	self.SelectVisible = nil
	self.SelectArrowColor = nil
	self.ConfigTextColor = nil
	self.ConfigOutlineColor = nil
	self.StateVisible = true
	self.StateIconAsset = nil
	self.SecondStateIconAsset = nil
	--self.MonsterSourceType = nil
	self.MonsterTypeIcon = nil

	self.OnlineStatusIcon = nil
	self.ProfIcon = nil
	self.ProfIconOffsetX = 0

	self.TargetMarkIcon = nil
	self.TargetMarkVisible = true

	self.IsInteractiveTarget = false

	self.EntityID = EntityID
	self.HUDType = Type
	self.RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
	self.TargetID = _G.TargetMgr:GetTarget(self.EntityID)  -- TODO(loiafeng): 好像没用上，找机会清理掉
	--self.PickTimesLeft  这个字段在UpdateNameInfo中刷新，以及GatherAttrChange事件刷新

	self.EidMountPoint = ""
	self.OffsetY = 0

	self:UpdateEidMountPoint()

	self:UpdateUIColor()

	self:UpdateNameInfo()
	self:UpdateNameVisible()

	self.bInDelayDraw = false

	local DelayTime = self:DelayDrawTime()
	if DelayTime > 0 then
		self.IsDraw = false
		self.bInDelayDraw = true
		_G.TimerMgr:AddTimer(nil, function()
			self.bInDelayDraw = false
			self:UpdateIsDraw()
		end, DelayTime)
	else
		self:UpdateIsDraw()
	end

	self:UpdateTitleInfo()
	self:UpdateTargetMarkState() -- 需要早于UpdateStateIcon()

	if self.HUDType == HUDType.PlayerInfo then
		if _G.ChocoboRaceMgr:IsShowChocoboRacerHUD(self.EntityID) then
			self:UpdateChocoboRacerInfo()
		else
			-- loiafeng: 更新在线状态图标
			self:UpdateOnlineStatus()
			self:InitHP()

			-- 水晶冲突中需要显示职业图标
			if _G.PWorldMgr:CurrIsInPVPColosseum() then
				local ProfID = ActorUtil.GetActorProfID(self.EntityID)
				self.ProfIcon = RoleInitCfg:FindRoleInitProfIcon(ProfID)
			end
			self:UpdateArmyShortName()
		end
	elseif(self.HUDType == HUDType.NPCInfo)
	or (self.HUDType == HUDType.MonsterInfo)
	or (self.HUDType == HUDType.InteractObjInfo)
	or (self.HUDType == HUDType.BuddyInfo) then
		self:UpdateStateIcon()
		self:InitHP()
	elseif self.HUDType == HUDType.GatherInfo then
		local Actor = ActorUtil.GetActorByEntityID(EntityID)
		if nil == Actor then
			return
		end

		local AttributeComponent = Actor:GetAttributeComponent()
		if nil == AttributeComponent then
			return
		end

		local MaxHp = _G.GatherMgr:GetMaxGatherCount(AttributeComponent.ResID, AttributeComponent.ListID)
		self:UpdateHP(AttributeComponent.PickTimesLeft, MaxHp)
	end

	if self.HUDType == HUDType.MonsterInfo then
		self:UpdateMonsterTypeIcon()
	end

	self:UpdateIsInteractiveTarget()
end

---更新UI颜色，包括名字、血条、选中箭头图标的颜色。注意函数中会更新ActorUIType
function HUDActorVM:UpdateUIColor()
	local ActorUIType = ActorUIUtil.GetActorUIType(self.EntityID)
	self.ActorUIType = ActorUIType

	local ColorConfig = ActorUIUtil.GetUIColorFromUIType(ActorUIType)

	-- 死亡状态特殊处理
	if ActorUtil.IsDeadState(self.EntityID) then
		self.NameColor = "B2B2B2FF"
		self.NameOutlineColor = "000000FF"
	else
		self.NameColor = ColorConfig.Text
		self.NameOutlineColor = ColorConfig.TextOutline
	end

	self.HPBarFillColor = ColorConfig.HPBarFill
	self.HPBarShadowColor = ColorConfig.HPBarShadow
	self.HPBarBgColor = ColorConfig.HPBarBackground
	self.SelectArrowColor = ColorConfig.SelectArrow
end

function HUDActorVM:UpdateNameInfo()
	self.Name = HUDActorVM.GetActorName(self.EntityID)
end

function HUDActorVM:UpdateNameVisible()
	local IsBuddy = self.HUDType == HUDType.MonsterInfo and ActorUtil.GetActorSubType(self.EntityID) == _G.UE.EActorSubType.Buddy
	local EntityID = IsBuddy and ActorUtil.GetActorOwner(self.EntityID) or self.EntityID
	local ActorType = ActorUtil.GetActorType(EntityID)

	local SaveKey
	if EActorType.Major == ActorType then
		SaveKey = IsBuddy and "HUDNameVisibleMajorBuddy" or "HUDNameVisibleMajor"
	elseif EActorType.Player == ActorType then
		if ActorUIUtil.IsTeamMember(EntityID) then
			SaveKey = IsBuddy and "HUDNameVisibleTeammateBuddy" or "HUDNameVisibleTeammate"
		elseif _G.FriendMgr:IsFriend(ActorUtil.GetRoleIDByEntityID(EntityID)) then
			SaveKey = IsBuddy and "HUDNameVisibleFriendBuddy" or "HUDNameVisibleFriend"
		else
			SaveKey = IsBuddy and "HUDNameVisiblePlayerBuddy" or "HUDNameVisiblePlayer"
		end
	else
		SaveKey = IsBuddy and "HUDNameVisibleOtherBuddy" or "HUDNameVisibleOther"
	end

	self.NameVisible = _G.SettingsMgr:GetValueBySaveKey(SaveKey) == 1
end

function HUDActorVM:UpdateTitleInfo()
	if self.CombatStateID ~= -1 then -- 战斗状态与称号公用一个位置，战斗状态恢复时会调用一次本函数
		return
	end

	self.TopTitleVisible = false
	self.TopTitleText = ""
	self.BelowTitleVisible = false
	self.BelowTitleText = ""
	local TitleMgr = _G.TitleMgr
	if(self.HUDType == HUDType.NPCInfo) then
		local ResID = ActorUtil.GetActorResID(self.EntityID)
		self.TopTitleVisible = false
		self.TopTitleText = ""
		local NpcTitleText = NpcCfg:FindValue(ResID, "Title") or ""
		self.BelowTitleVisible = NpcTitleText ~= ""
		self.BelowTitleText = TitleMgr:DecorationTitle(NpcTitleText)
	elseif self.HUDType == HUDType.PlayerInfo then
		local IsOpenTitle = OpenTitleState.Close
		local ActorType = ActorUtil.GetActorType(self.EntityID)
		if EActorType.Major == ActorType then
			IsOpenTitle = _G.SettingsMgr:GetValueBySaveKey("ShowSelfTitle")
		elseif EActorType.Player == ActorType then
			if ActorUIUtil.IsTeamMember(self.EntityID) then
				IsOpenTitle = _G.SettingsMgr:GetValueBySaveKey("ShowTeamMemberTitle")
			elseif _G.FriendMgr:IsFriend(ActorUtil.GetRoleIDByEntityID(self.EntityID)) then
				IsOpenTitle = _G.SettingsMgr:GetValueBySaveKey("ShowFriendTitle")
			else
				IsOpenTitle = _G.SettingsMgr:GetValueBySaveKey("ShowStrangerTitle")
			end
		end
		local TitleID = HUDActorVM.GetActorTitleID(self.EntityID) or 0
		if IsOpenTitle == OpenTitleState.Open and TitleID ~= 0 then
			local Gender = HUDActorVM.GetActorGender(self.EntityID)
			if TitleMgr:GetTargetTitleTextLocation(TitleID) == 1 then
				self.TopTitleVisible = true
				self.TopTitleText = TitleMgr:DecorationTitle(TitleMgr:GetTargetTitleText(TitleID, Gender))
				self.BelowTitleVisible = false
				self.BelowTitleText = ""
			else
				self.TopTitleVisible = false
				self.TopTitleText = ""
				self.BelowTitleVisible = true
				self.BelowTitleText = TitleMgr:DecorationTitle(TitleMgr:GetTargetTitleText(TitleID, Gender))
			end
		end

	-- 搭档和宠物需要在BelowTitleText处显示主人名称
	elseif self.HUDType == HUDType.CompanionInfo or
	(self.HUDType == HUDType.MonsterInfo and ActorUtil.GetActorSubType(self.EntityID) == _G.UE.EActorSubType.Buddy) then
		self.TopTitleVisible = false
		self.TopTitleText = ""
		local OwnerID = ActorUtil.GetActorOwner(self.EntityID)
		local OwnerName = ActorUtil.GetActorName(OwnerID)
		if string.isnilorempty(OwnerName) then
			_G.FLOG_WARNING("HUDActorVM.UpdateTitleInfo(): Empty owner name. EntityID is %d. OwnerID is %d.", self.EntityID, OwnerID)
			self.BelowTitleVisible = false
			self.BelowTitleText = ""
		else
			self.BelowTitleVisible = true
			self.BelowTitleText = TitleMgr:DecorationTitle(OwnerName)
		end
	elseif self.HUDType == HUDType.MonsterInfo then
		local ResID = ActorUtil.GetActorResID(self.EntityID)
		-- 怪物称号
		local UserData = ActorUtil.GetUserData(self.EntityID, UserDataID.Fate)
		if (UserData ~= nil and UserData.FateID ~= nil and UserData.FateID > 0) then
			-- 如果是高危的FATE，那么优先显示高危词
			-- 这里要过滤掉迷失少女
			if (not _G.FateMgr:IsLostLadyResID(ResID)) then
				local TableData = _G.FateMgr:GetFateHighRiskTableDataByHighRiskState(UserData.HighRiskType)
				if (TableData ~= nil) then
					self.TopTitleVisible = false
					self.BelowTitleVisible = true
					self.BelowTitleText = TitleMgr:DecorationTitle(TableData.ShortTitle)
				else
					self.BelowTitleVisible = false
				end
			end
		else
			if ResID then
				local Title = MonsterCfg:FindValue(ResID, "Title")
				self.BelowTitleVisible = not string.isnilorempty(Title)
				self.BelowTitleText = TitleMgr:DecorationTitle(Title)
			end
		end
	end
end

function HUDActorVM:UpdateChocoboRacerInfo()
	self.Name = _G.ChocoboRaceMgr:GetRacerNameByID(self.EntityID)
	local IsReady = _G.ChocoboRaceMgr:IsAfterCutsceneByEntityID(self.EntityID)
	if IsReady then
		self:SetOnlineStatusIcon(_G.ChocoboRaceMgr:GetRacerIndexAsset(self.EntityID))
	end
	local CurStamina = _G.ChocoboRaceMgr:GetRacerCurStamina(self.EntityID)
	local MaxStamina = _G.ChocoboRaceMgr:GetRacerMaxStamina(self.EntityID)
	local IsNpcChallenge = _G.ChocoboRaceMgr:IsNpcChallengeByEntityID(self.EntityID)
	if IsNpcChallenge then
		local ColorConfig = ActorUIUtil.GetUIColorFromColorID(6)
		self.HPBarFillColor = ColorConfig.HPBarFill
		self.HPBarShadowColor = ColorConfig.HPBarShadow
		self.HPBarBgColor = ColorConfig.HPBarBackground
		self.SelectArrowColor = ColorConfig.SelectArrow
	end
	
	self:UpdateHP(CurStamina, MaxStamina)
end

function HUDActorVM:UpdateMagicCardTourneyInfo(IsVisible)
	if IsVisible == false then
		self:SetOnlineStatusIcon(nil)
		return
	end

	local RoleID = ActorUtil.GetRoleIDByEntityID(self.EntityID)
	local IndexAsset = _G.MagicCardTourneyMgr:GetRankIndexAsset(RoleID)
	if IndexAsset ~= nil then
		self:SetOnlineStatusIcon(IndexAsset)
	end
end

function HUDActorVM:GetQuestIconAsset()
	local ResID = ActorUtil.GetActorResID(self.EntityID)
	local QuestParamsList

	if self.HUDType == HUDType.NPCInfo then
		local bIsNpcMoving = _G.QuestMgr:CheckClientNpcMoving(ResID)
		if bIsNpcMoving then return nil end

		_G.QuestMgr:EnableQuestCheckInfo(true)
		QuestParamsList = _G.QuestMgr:GetNPCQuestParamsList(ResID)
		_G.QuestMgr:EnableQuestCheckInfo(false)

	elseif self.HUDType == HUDType.MonsterInfo then
		QuestParamsList = _G.QuestMgr:GetMonsterQuestParamsList(ResID)

	elseif self.HUDType == HUDType.InteractObjInfo then
		QuestParamsList = _G.QuestMgr:GetEObjQuestParamsList(ResID)

	else
		return nil
	end

	local FirstQuestID = next(QuestParamsList) and QuestParamsList[1].QuestID
	if not FirstQuestID then return nil end
	local QuestType = next(QuestParamsList) and QuestParamsList[1].QuestType

	local bMonster = (self.HUDType == HUDType.MonsterInfo)
	return _G.QuestMgr:GetQuestIconAtHUD(FirstQuestID, QuestType, bMonster)
end

function HUDActorVM:UpdateNpcStateIcon()
	local Icon

	Icon = _G.FateMgr:GetNPCHudIcon(self.EntityID)

	if nil == Icon then
		Icon = self:GetQuestIconAsset()
	end

	local MagicCardIcon = _G.MagicCardMgr:GetNPCHudIcon(self.EntityID)
	if nil == Icon then
		Icon = MagicCardIcon
		self.SecondStateIconAsset = nil
	else
		-- 尝试在第二个位置显示幻卡状态
		self.SecondStateIconAsset = MagicCardIcon
	end

	if nil == Icon then
		Icon = _G.GoldSauserMgr:GetNPCHudIcon(self.EntityID)
	end

	-- if nil == Icon then
	-- 	Icon = _G.GoldSauserActivityMgr:GetGoldActivityNPCHudIcon(self.EntityID)
	-- end

	if nil == Icon then
		Icon = _G.MysterMerchantMgr:GetNPCHudIcon(self.EntityID)
	end

	if nil == Icon then
		Icon = _G.ChocoboTransportMgr:GetNPCHudIcon(self.EntityID)
	end

	if nil == Icon then
		Icon = _G.LeveQuestMgr:GetNPCHudIcon(self.EntityID)
	end

	if nil == Icon then
		Icon = _G.MapMgr:GetNPCHudIcon(self.EntityID)
	end

	if nil == Icon then
		Icon =  _G.MapMgr:GetMappingHudIcon(self.EntityID)
	end

	if nil == Icon then
		Icon =  _G.MapMgr:GetMainlineTrackingHudIcon(self.EntityID)
	end

	if nil == Icon then
		Icon = _G.TouringBandMgr:GetTouringBandManagerHudIcon(self.EntityID)
	end

	self.StateIconAsset = (not string.isnilorempty(Icon) and Icon) or nil

    -- 为空的时候要去刷新一下，返回默认状态，目前被设置为FATE状态下，VM没有回收的时候会出现ICON不更新的情况
    -- 因此要刷新一下
	if (self.StateIconAsset == nil or self.StateIconAsset == "") then
		if self.HUDType == HUDType.MonsterInfo then
			self:UpdateMonsterTypeIcon()
		end
	end
end

function HUDActorVM:UpdateMonStateIcon()
	local Icon = self:GetQuestIconAsset()
	self.StateIconAsset = Icon
	self.SecondStateIconAsset = nil
end

function HUDActorVM:UpdateEObjStateIcon()
	local Icon = self:GetQuestIconAsset()
	if nil == Icon then
		Icon =  _G.MapMgr:GetMappingHudIcon(self.EntityID)
	end
	self.StateIconAsset = Icon
	self.SecondStateIconAsset = nil
end

function HUDActorVM:UpdateMonsterTypeIcon()
	-- 优先显示玩法相关的怪物图标，不涉及玩法的情况下才按照Rank显示主被动图标

	-- 玩法：Fate怪物图标
	local FateUserData = ActorUtil.GetUserData(self.EntityID, UserDataID.Fate)
	if FateUserData ~= nil and FateUserData.FateID > 0 then
		if (FateUserData.HighRiskType ~= nil and FateUserData.HighRiskType > 0) then
			self.MonsterTypeIcon = FateDefine.GetIcon(ProtoRes.FateIconType.ICON_MONSTER_NAME_HIGH_RISK)
		else
			self.MonsterTypeIcon = FateDefine.GetIcon(ProtoRes.FateIconType.ICON_MONSTER_NAME)
		end

		return
	end

	-- 寻宝：宝箱怪图标
	local UserData = ActorUtil.GetUserData(self.EntityID, UserDataID.TreasureHunt)
	if UserData ~= nil and UserData.BoxID ~= nil then
		if UserData.BoxID > 0 then
			self.MonsterTypeIcon = "/Game/UI/Atlas/HUD/Frames/TargetInfo_Icon_Team_TreasureBox_png.TargetInfo_Icon_Team_TreasureBox_png"
			return
		end
	end

	--如果是友好、中立阵营的，则当成npc，不显示怪物图标
	local Relation = SelectTargetBase:GetCampRelationByEntityID(self.EntityID)
	if ProtoRes.camp_relation.camp_relation_enemy ~= Relation then
		return
	end

	local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
	if nil == Actor then
		FLOG_ERROR("HUDActorVM.UpdateMonsterTypeIcon: Actor is nil.")
		return
	end

	local AttributeComponent = Actor:GetAttributeComponent()
	if nil == AttributeComponent then
		FLOG_ERROR("HUDActorVM.UpdateMonsterTypeIcon: AttributeComponent is nil.")
		return
	end

	local ResID = AttributeComponent.ResID
	local Cfg = MonsterCfg:FindCfgByKey(ResID)
	if Cfg == nil then
		FLOG_ERROR("HUDActorVM.UpdateMonsterTypeIcon: Can not find ResID (%d) in MonsterCfg.", ResID)
		return
	end

	local ProfileName = tonumber(Cfg.ProfileName)
	if ProfileName == nil then
		FLOG_ERROR("HUDActorVM.UpdateMonsterTypeIcon: ProfileName is not a number.")
		return
	end

	local RankType = NPCBaseCfg:FindValue(ProfileName, "Rank")
	if RankType ~= nil and RankType < ProtoRes.NPC_RANK_TYPE.Hidden then
		local IsActiveEnmity = EnmityCfg:FindValue(Cfg.EnmityID, "IsActiveEnmity")
		self.MonsterTypeIcon = HUDConfig:GetMonsterRankTypeIcon(RankType, IsActiveEnmity == 1)
	end
end

---更新目标的标记状态图标
---@param StateID number|nil 不传入则通过SignsMgr查询
function HUDActorVM:UpdateTargetMarkState(StateID)
	StateID = StateID or _G.SignsMgr:GetMarkingByEntityID(self.EntityID)
	if StateID == 0 then
		self.TargetMarkIcon = ""
	else
		self.TargetMarkIcon = TargetmarkCfg:FindValue(StateID, "IconPath") or ""
	end
end

function HUDActorVM:UpdateTargetMarkStateVisible(IsVisible)
	self.TargetMarkVisible = IsVisible
end

function HUDActorVM:UpdateStateIcon()
	-- 在有目标标记时，不显示角色State图标
	if not string.isnilorempty(self.TargetMarkIcon) then
		self.StateIconAsset = nil
		self.SecondStateIconAsset = nil
		return
	end

	if self.HUDType == HUDType.NPCInfo then
		self:UpdateNpcStateIcon()
	elseif self.HUDType == HUDType.MonsterInfo then
		self:UpdateMonStateIcon()
	elseif self.HUDType == HUDType.InteractObjInfo then
		self:UpdateEObjStateIcon()
	end
end

function HUDActorVM:UpdateStateIconVisbible(IsVisible)
	self.StateVisible = IsVisible
end

function HUDActorVM:UpdateSelectTarget(IsSelected)
	self.SelectVisible = IsSelected
end

function HUDActorVM:UpdateMovieInfo(IsMovieState)
	if nil == IsMovieState then
		self.IsMovieState = _G.TeamMgr:IsInMovieState(self.RoleID)
	else
		self.IsMovieState = IsMovieState
	end
end

function HUDActorVM:SetHPBarVisible(IsVisible)
	self.HPBarVisible = IsVisible
end

function HUDActorVM:InitHP()
	local EntityID = self.EntityID
	local CurHP = ActorUtil.GetActorHP(EntityID)
	local MaxHP = ActorUtil.GetActorMaxHP(EntityID)
	if CurHP < MaxHP then
		FLOG_INFO("HUDActorVM:InitHP CurHP=%d MaxHP=%d  EntityID=%d ActorName=%s", CurHP, MaxHP, EntityID, ActorUtil.GetActorName(EntityID))
	end
	self:UpdateHP(CurHP, MaxHP)
end

function HUDActorVM:UpdateHP(CurHP, MaxHP)
	local OldPercent = self.HPFillAmount or 0
	local NewPercent = MaxHP > 0 and math.clamp(CurHP / MaxHP, 0, 1) or 0
	local bShowChocoboRacerHUD = _G.ChocoboRaceMgr:IsShowChocoboRacerHUD(self.EntityID)
	if bShowChocoboRacerHUD then
		self.HPBarVisible = true
	end
	
	if OldPercent == NewPercent then return end

	self.HPFillAmount = NewPercent
	self.HPBarVisible = bShowChocoboRacerHUD or (NewPercent > 0 and NewPercent < 1)

	if (self.HUDType == HUDType.MonsterInfo and (OldPercent == 1 or NewPercent == 1)) or
	(OldPercent == 0 or NewPercent == 0) then
		self:UpdateUIColor()
	end
end

function HUDActorVM:UpdateIsDraw(IsDraw)
	if self.bInDelayDraw then
		self.IsDraw = false
	elseif IsDraw == nil then
		self.IsDraw = self:CheckShowActorInfo(self.EntityID)
	else
		self.IsDraw = IsDraw
	end
end

---@return number
function HUDActorVM:DelayDrawTime()
    local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
    if nil == Actor then return 0 end

	local AttributeComponent = Actor:GetAttributeComponent()
	if nil == AttributeComponent then return 0 end

	local ActorType = AttributeComponent:GetActorType()
	self.ActorType = ActorType

	if EActorType.EObj == ActorType then
		local Cfg = EObjCfg:FindCfgByKey(AttributeComponent.ResID)
		if Cfg ~= nil and (Cfg.NameShowTime or 0) > 0 then
			return Cfg.NameShowTime
		end
	end

	return 0
end

function HUDActorVM:UpdateOnlineStatus()
	if _G.ChocoboRaceMgr:IsShowChocoboRacerHUD(self.EntityID) then
		return
	end

	if _G.DemoMajorType ~= 0 then
		self:SetOnlineStatusIcon(nil)
        return
    end

	-- 水晶冲突不显示状态图标
	if _G.PWorldMgr:CurrIsInPVPColosseum() then
		self:SetOnlineStatusIcon(nil)
		return
	end

	local OnlineStatus = _G.OnlineStatusMgr:GetStatusByEntityID(self.EntityID)
	local Icon = OnlineStatusUtil.GetVisionStatusIcon(OnlineStatus, self.EntityID)
	self:SetOnlineStatusIcon(Icon)
end

---GetActorName
---@param EntityID number
---@return string
function HUDActorVM.GetActorName(EntityID, IsReport)
	if MajorUtil.IsMajor(EntityID) then
		--如果有变身，显示变身后的名字
		local Name = ActorUtil.GetChangeRoleNameOrNil(EntityID) or MajorUtil.GetMajorName()
		-- FLOG_INFO("HUDActorVM.GetActorName debug major: ChangeRoleName=\"%s\". MajorName=\"%s\".",
		--	ActorUtil.GetChangeRoleNameOrNil(EntityID) or "nil", MajorUtil.GetMajorName() or "nil")
		return Name
	end

	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if nil == Actor then
		FLOG_ERROR("HUDActorVM.GetActorName Actor is nil")
		return
	end

	local AttributeComponent = Actor:GetAttributeComponent()
	if nil == AttributeComponent then
		FLOG_ERROR("HUDActorVM.GetActorName AttributeComponent is nil")
		return
	end

	local ActorType = AttributeComponent:GetActorType()
	--如果有变身，显示变身后的名字
	-- local ActorName = ActorUtil.GetActorName(EntityID)
	local ActorName = ActorUtil.GetChangeRoleNameOrNil(EntityID) or ActorUtil.GetActorName(EntityID)

	if EActorType.Major == ActorType or EActorType.Player == ActorType or EActorType.Gather == ActorType then
		if string.isnilorempty(ActorName) then
			FLOG_ERROR("HUDActorVM.GetActorName Get an invalid Name. ChangeRoleName=\"%s\". ActorName=\"%s\".",
				ActorUtil.GetChangeRoleNameOrNil(EntityID) or "nil", ActorUtil.GetActorName(EntityID) or "nil")
		end
		return ActorName

	elseif EActorType.Monster == ActorType then
		local ResID = AttributeComponent.ResID
		ActorName = _G.SelectMonsterMgr:GetMonsterNameHasTagStr(ResID, EntityID, ActorName)

		local Level = AttributeComponent.Level

		if ActorUtil.GetActorSubType(EntityID) == _G.UE.EActorSubType.Buddy then
			local OwnerID = ActorUtil.GetActorOwner(EntityID)
			local AttrComp = ActorUtil.GetActorAttributeComponent(OwnerID)
			local BuddyName = (AttrComp or {}).BuddyName or ""  -- 找不到主人时显示空名字

			if string.isnilorempty(BuddyName) and MajorUtil.IsMajor(OwnerID) then
				BuddyName = _G.BuddyMgr:GetBuddyName()
			end

			ActorName = BuddyName
			Level = (AttrComp or {}).Level or Level
		end

		if not string.isnilorempty(ActorName) then
			local IsHideLevel = MonsterCfg:FindValue(ResID, "IsHideLevel")
			if IsHideLevel ~= 0 then
				return string.format(LSTR(510001), ActorName)  -- 510001-??级 %s
			elseif AttributeComponent.Level > 0 and not IsReport then
				return string.format(LSTR(510006), Level, ActorName)  -- 510006-%d级 %s
			else
				return string.format("%s", ActorName)
			end
		end
	else
		if EActorType.EObj == ActorType then
			local ResID = AttributeComponent.ResID
			-- 探索笔记探索点特殊处理(需隐藏)
			local DiscoverNoteMgr = _G.DiscoverNoteMgr
			if DiscoverNoteMgr and (DiscoverNoteMgr:IsNormalNotePoint(ResID) or DiscoverNoteMgr:IsPerfectNotePoint(ResID)) then
				return ""
			end
		end--]]

		if AttributeComponent.Level > 0 then
			return string.format(LSTR(510006), AttributeComponent.Level, ActorName)  -- 510006-%d级 %s
		else
			return ActorName
		end
	end
end

function HUDActorVM:CheckShowActorInfo(EntityID)
	if not _G.HUDMgr:IsShowActor(EntityID) then
		return false
	end

	local ActorType = ActorUtil.GetActorType(EntityID)
	if ActorType == EActorType.Gather then
		-- FLOG_INFO("pcw bShow: " .. tostring(rlt) .. " entityid: " .. EntityID)
		return true
	elseif ActorType == EActorType.EObj then
		local EObj = ActorUtil.GetActorByEntityID(EntityID) or {}
		-- TODO(loiafeng): 部队物件使用后台的枚举
		if EObj.EObjType == ProtoRes.ClientEObjType.ClientEObjTypeGroup then
			return _G.ArmyMgr:IsInArmy()
		end
	end

	if not ActorUtil.IsInShowHeadUIState(EntityID) then
		FLOG_INFO("HUDActorVM.CheckShowActorInfo(): hide hud of %s(%s) by IsInShowHeadUIState()", ActorUtil.GetActorName(EntityID), tostring(EntityID))
		return false
	end

	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if nil == Actor then
		FLOG_ERROR("HUDActorVM.CheckShowActorInfo(): Actor is invalid")
		return false
	end

	if not Actor:GetHUDVisibility() then
		FLOG_INFO("HUDActorVM.CheckShowActorInfo(): hide hud of %s(%s) by GetHUDVisibility()", ActorUtil.GetActorName(EntityID), tostring(EntityID))
		return false
	end

	return true
end

function HUDActorVM:OnGatherAttrChange(Params)
	self.PickTimesLeft = Params.IntParam1
	self:UpdateNameInfo()    --这里还会获取刷新一次 PickTimesLeft
	self:UpdateUIColor()

	local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
	if nil == Actor then
		return
	end

	local AttributeComponent = Actor:GetAttributeComponent()
	if nil == AttributeComponent then
		return
	end

	local MaxHp = _G.GatherMgr:GetMaxGatherCount(AttributeComponent.ResID, AttributeComponent.ListID)
	self:UpdateHP(self.PickTimesLeft, MaxHp)
end

---GetActorTitleID
---@param EntityID number
---@return number
function HUDActorVM.GetActorTitleID(EntityID)
	local ActorType = ActorUtil.GetActorType(EntityID)
	if EActorType.Major == ActorType then
		return _G.TitleMgr:GetCurrentTitle()
	else
		return _G.TitleMgr:GetTitleDataFromEntityID(EntityID)
	end
end

---GetActorGender
---@param EntityID number
---@return RoleGender
function HUDActorVM.GetActorGender(EntityID)
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if nil == Actor then
		return RoleGender.GENDER_UNKNOWN
	end
	local AttributeComponent = Actor:GetAttributeComponent()
	if nil == AttributeComponent then
		FLOG_ERROR("HUDActorVM.GetActorGender AttributeComponent is nil")
		return RoleGender.GENDER_UNKNOWN
	end
	local Attr = MajorUtil.GetMajorAttributeComponent()
	if Attr ~= nil then
		return Attr.Gender
	end
	return RoleGender.GENDER_UNKNOWN
end

---@param Name? string 可以为空
function HUDActorVM:UpdateArmyShortName(Name)
	if _G.DemoMajorType ~= 0 then
		-- 创角态不显示部队简称
		self.ArmyShortName = ""
		return
	end

	local ResultName = Name

	-- 跨界状态需要特殊显示
	local IsCrossWorld = false
	if MajorUtil.IsMajor(self.EntityID) then
		local RoleVM = MajorUtil.GetMajorRoleVM()
		if RoleVM then
			local OriginWorldID = _G.LoginMgr:GetWorldID()  -- 原始WorldID
			IsCrossWorld = RoleVM.CrossZoneWorldID > 0 and RoleVM.CrossZoneWorldID ~= OriginWorldID
		end
	else
		local StateComp = ActorUtil.GetActorStateComponent(self.EntityID)
		IsCrossWorld = StateComp and StateComp:IsInNetState(ProtoCommon.CommStatID.CommStatCrossWorld)
	end

	if IsCrossWorld then
		ResultName = LSTR(510008)  -- 放浪神加护
	end

	if string.isnilorempty(ResultName) then
		if MajorUtil.IsMajor(self.EntityID) then
			-- 主角的部队简称从部队系统查询
			ResultName = _G.ArmyMgr:GetArmyAlias()
		else
			-- 其他的由视野包同步
			local AttributeComp = ActorUtil.GetActorAttributeComponent(self.EntityID)
			if nil ~= AttributeComp then
				ResultName = AttributeComp.ArmyShortName
			end
		end
	end

	self.ArmyShortName = ResultName
end

---@param IsTarget boolean
function HUDActorVM:UpdateIsInteractiveTarget()
	self.IsInteractiveTarget = (_G.HUDMgr.InteractiveTargetEntityID == self.EntityID) and (self.HUDType == HUDType.HouseObjInfo or not string.isnilorempty(self.Name))
end

---@param Eid string
function HUDActorVM:SetEidMountPoint(Eid)
	self.EidMountPoint = Eid
end

function HUDActorVM:ResetEidMountPoint()
	self.EidMountPoint = ""
end

function HUDActorVM:UpdateEidMountPoint()
	local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
	local RideComp = Actor and Actor:GetRideComponent()
	if RideComp and RideComp:IsInRide() then
		local Pos = RideComp:GetSeatIndex()
		local Eid = Pos == 0 and "EID_UI_NAME_MNT" or string.format("EID_UI_NAME_MNT%02d", Pos + 1)
		self:SetEidMountPoint(Eid)
	end
end

function HUDActorVM:SetOffsetY(OffsetY)
	self.OffsetY = OffsetY or 0
end

function HUDActorVM:SetOnlineStatusIcon(Icon)
	self.OnlineStatusIcon = Icon
	-- loiafeng: 新增职业图标后，角色名是列表第三项，无法通过编辑资产将其居中，目前只能先在代码中手动处理偏移
	self.ProfIconOffsetX = string.isnilorempty(Icon) and -1 or -43
end

function HUDActorVM:SetCombatStateID(ID)
	self.CombatStateID = ID
	if ID ~= -1 then
		self.TopTitleVisible = false
	else
		self:UpdateTitleInfo()
	end
end

return HUDActorVM