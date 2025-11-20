--[[
Author: pengxingran_ds pengxingran@dasheng.tv
Date: 2025-09-11 11:04:22
LastEditors: pengxingran_ds pengxingran@dasheng.tv
LastEditTime: 2025-09-12 10:43:07
FilePath: \Script\Game\Photo\PhotoActorUtil\PhotoActorUtil.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local PhotoActorUtil = {}

local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local AnimationUtil = require("Utils/AnimationUtil")

local FriendMgr = _G.FriendMgr
local TeamMgr = _G.TeamMgr
local ArmyMgr = _G.ArmyMgr
local CompanionMgr = _G.CompanionMgr
local EActorSubType = _G.UE.EActorSubType
local EAvatarPartType = _G.UE.EAvatarPartType

function PhotoActorUtil.GetActorByEID(EID)
    return ActorUtil.GetActorByEntityID(EID)
end

local function CheckMates(Player)
    if not Player then
        return false
    end
    local AttrComponent = Player:GetAttributeComponent()
    if AttrComponent then
        local RID = AttrComponent.RoleID
        if RID then
            if FriendMgr:IsFriend(RID) then
                return true
            end

            if TeamMgr:IsTeamMemberByRoleID(RID) then
                return true
            end

            if ArmyMgr:GetMemberDataByRoleID(RID) then
                return true
            end
        end
    end
    return false
end

function PhotoActorUtil.IsMates(Player)
    return CheckMates(Player)
end

function PhotoActorUtil.GetMateEIDSet(IgnoreMajor)
    local UActorManager = _G.UE.UActorManager:Get()
    local All = UActorManager:GetAllPlayers()

    local Set = {}
    local MajorEID = MajorUtil.GetMajorEntityID()

    if nil == All or All:Length() <= 0 then
        if IgnoreMajor then
            Set[MajorEID] = nil
        else
            Set[MajorEID] = true
        end

		return Set
	end
    
    for i = 1, All:Length() do
		local Player = All:Get(i)
		local AttrComponent = Player:GetAttributeComponent()

		if CheckMates(Player) then
            Set[AttrComponent.EntityID] = true
		end
	end

    if IgnoreMajor then
        Set[MajorEID] = nil
    else
        Set[MajorEID] = true
    end

    return Set
end

-- Region Ctrl
function PhotoActorUtil.GetMajor()
    return MajorUtil.GetMajor()
end

function PhotoActorUtil.GetMajorPet()
    local EID = CompanionMgr.CallingOutCompanionEntityID

    if EID then
        return PhotoActorUtil.GetActorByEID(EID)
    end
end

-- 陆行鸟
function PhotoActorUtil.GetMajorChocobo()
    local UActorManager = _G.UE.UActorManager:Get()
    local EActorType = _G.UE.EActorType

    local All = UActorManager:GetAllActors()
    local MateEIDSet = PhotoActorUtil.GetMateEIDSet()

    local Ret = {}

    if nil == All or All:Length() <= 0 then
		return Ret
	end

    local function Check(Actor)
		local AttrComponent = Actor:GetAttributeComponent()
		
        if AttrComponent then
            local Owner = AttrComponent.Owner
            if MateEIDSet[Owner] and AttrComponent:GetActorSubType() == _G.UE.EActorSubType.Buddy then
                return true
            end
        end

		return false
	end
    
    for i = 1, All:Length() do
		local Actor = All:Get(i)
		if Check(Actor) then
            table.insert(Ret, Actor)
		end
	end

    return Ret
end

function PhotoActorUtil.GetMajorSummons()
    local UActorManager = _G.UE.UActorManager:Get()
    local EActorType = _G.UE.EActorType

    local All = UActorManager:GetAllActors()
    local MateEIDSet = PhotoActorUtil.GetMateEIDSet()

    local Ret = {}

    if nil == All or All:Length() <= 0 then
		return Ret
	end

    local function Check(Actor)
		local AttrComponent = Actor:GetAttributeComponent()
		
        if AttrComponent then
            local Owner = Actor.FollowEntityID
            -- print('testinfo Owner = ' .. tostring(Owner) .. " Type = " .. tostring(AttrComponent.ObjType))
            if MateEIDSet[Owner] and AttrComponent.ObjType == EActorType.Summon then
                return true
            end
        end

		return false
	end
    
    for i = 1, All:Length() do
		local Actor = All:Get(i)
		if Check(Actor) then
            table.insert(Ret, Actor)
		end
	end

    return Ret
end

-- 亲信
function PhotoActorUtil.GetEntourates()
    -- 亲信还没做
    return {}
end

-- 伙伴 队友|部队|好友
function PhotoActorUtil.GetMates()
    local Mates = PhotoActorUtil.GetMateEIDSet(true)

    local Ret = {}

    for EID, _ in pairs(Mates) do
        local Mate = ActorUtil.GetActorByEntityID(EID)
        table.insert(Ret, Mate)
    end

    return Ret
end

-- 队友的宠物
function PhotoActorUtil.GetMatePets()
    local UActorManager = _G.UE.UActorManager:Get()
    local All = UActorManager:GetAllCompanions()
    local MateEIDSet = PhotoActorUtil.GetMateEIDSet()

    local Ret = {}

    if nil == All or All:Length() <= 0 then
		return Ret
	end

    local function Check(Pet)
		local AttrComponent = Pet:GetAttributeComponent()
        if AttrComponent then
            local Owner = AttrComponent.Owner

            if MateEIDSet[Owner] then
                return true
            end
        end

		return false
	end
    
    for i = 1, All:Length() do
		local Pet = All:Get(i)
		if Check(Pet) then
            table.insert(Ret, Pet)
		end
	end

    return Ret
end

-- Region Can not ctrl

-- 除了玩家\队员
function PhotoActorUtil.GetPlayerOthers()
    local UActorManager = _G.UE.UActorManager:Get()
    local All = UActorManager:GetAllPlayers()
    local MateEIDSet = PhotoActorUtil.GetMateEIDSet()

    local Ret = {}

    if nil == All or All:Length() <= 0 then
		return Ret
	end

    local function Check(Player)
		local AttrComponent = Player:GetAttributeComponent()
		
        if AttrComponent then
            local EID = AttrComponent.EntityID

            if MateEIDSet[EID] then
                return false
            end
        end

		return true
	end
    
    for i = 1, All:Length() do
		local Player = All:Get(i)
		if Check(Player) then
            table.insert(Ret, Player)
		end
	end

    return Ret
end

function PhotoActorUtil.GetPlayerOtherChocobos()
    local UActorManager = _G.UE.UActorManager:Get()
    local EActorType = _G.UE.EActorType

    local All = UActorManager:GetAllActors()
    local MateEIDSet = PhotoActorUtil.GetMateEIDSet()

    local Ret = {}

    if nil == All or All:Length() <= 0 then
		return Ret
	end

    local function Check(Actor)
		local AttrComponent = Actor:GetAttributeComponent()
		
        if AttrComponent then
            local Owner = AttrComponent.Owner
            -- print('testinfo name = ' .. tostring(ActorUtil.GetActorName(AttrComponent.EntityID)))
            if not MateEIDSet[Owner] and AttrComponent:GetActorSubType() == _G.UE.EActorSubType.Buddy then
                -- print('testinfo Pick')
                return true
            end
        end

		return false
	end
    
    for i = 1, All:Length() do
		local Actor = All:Get(i)
		if Check(Actor) then
            table.insert(Ret, Actor)
		end
	end

    return Ret
end

function PhotoActorUtil.GetPlayerOtherSummons()
    local UActorManager = _G.UE.UActorManager:Get()
    local EActorType = _G.UE.EActorType

    local All = UActorManager:GetAllActors()
    local MateEIDSet = PhotoActorUtil.GetMateEIDSet()

    local Ret = {}

    if nil == All or All:Length() <= 0 then
		return Ret
	end

    local function Check(Actor)
		local AttrComponent = Actor:GetAttributeComponent()
		
        if AttrComponent then
            local Owner = Actor.FollowEntityID
            -- print('testinfo Owner = ' .. tostring(Owner) .. " Type = " .. tostring(AttrComponent.ObjType))
            if not MateEIDSet[Owner] and AttrComponent.ObjType == EActorType.Summon then
                return true
            end
        end

		return false
	end
    
    for i = 1, All:Length() do
		local Actor = All:Get(i)
		if Check(Actor) then
            table.insert(Ret, Actor)
		end
	end

    return Ret
end

function PhotoActorUtil.GetPlayerOtherPets()
    local UActorManager = _G.UE.UActorManager:Get()

    local All = UActorManager:GetAllCompanions()
    local MateEIDSet = PhotoActorUtil.GetMateEIDSet()

    local Ret = {}

    if nil == All or All:Length() <= 0 then
		return Ret
	end

    local function Check(Actor)
		local AttrComponent = Actor:GetAttributeComponent()
		
        if AttrComponent then
            local Owner = AttrComponent.Owner
            if MateEIDSet[Owner] then
                return false
            end
        end

		return true
	end
    
    for i = 1, All:Length() do
		local Actor = All:Get(i)
		if Check(Actor) then
            table.insert(Ret, Actor)
		end
	end

    return Ret
end

function PhotoActorUtil.GetNPCs()
    local UActorManager = _G.UE.UActorManager:Get()

    local Ret = {}

    local VisionActorList = UActorManager:GetAllActors()
    for i = 1, VisionActorList:Length() do
		local Actor = VisionActorList:Get(i)
        if Actor then
            local AttrComp = Actor:GetAttributeComponent()
            if AttrComp then 
                if ActorUtil.IsNpc(AttrComp.EntityID) then
                    table.insert(Ret, Actor)
                end
            end
        end
	end

    return Ret
end

function PhotoActorUtil.GetMonsters()
    local UActorManager = _G.UE.UActorManager:Get()

    local Ret = {}

    local All = UActorManager:GetAllMonsters()
    for i = 1, All:Length() do
		local Actor = All:Get(i)

        local AttrComponent = Actor:GetAttributeComponent()
		
        if AttrComponent then
            if AttrComponent:GetActorSubType() ~= _G.UE.EActorSubType.Buddy then
                table.insert(Ret, Actor)
            end
        end
	end

    return Ret
end

-------------------------------------------------------------------------------------------------------
---@region 所有Actor

function PhotoActorUtil.GetAllActorUEArray()
    local UActorManager = _G.UE.UActorManager:Get()

    local All = UActorManager:GetAllActors()

    return All
end

function PhotoActorUtil.GetAllActor()
    local UActorManager = _G.UE.UActorManager:Get()

    local Ret = {}

    local All = UActorManager:GetAllActors()
    for i = 1, All:Length() do
		local Actor = All:Get(i)
        table.insert(Ret, Actor)
	end

    return Ret
end

-------------------------------------------------------------------------------------------------------
---@region 暂停
local OtherParts = {EAvatarPartType.RIDE_MASTER, EAvatarPartType.Ornament_Umbrella, EAvatarPartType.Ornament_Wing}
function PhotoActorUtil.PauseAnim(Actor, IsPause)
    AnimationUtil.SetPauseAnimAndOtherPart(Actor, IsPause, OtherParts)
end

function PhotoActorUtil.PauseActorAnim(Actor, IsPause)
    if not Actor then return end
    -- local AnimComponent = Actor:GetAnimationComponent()
    -- if AnimComponent then
    --     --AnimComponent:PauseAnimation(IsPause)
    --     AnimComponent:PauseAnimationByPartType(EAvatarPartType.RIDE_MASTER, IsPause)
    -- end
    PhotoActorUtil.PauseAnim(Actor, IsPause)
    local EmojiAnimInst = Actor:GetEmojiAnimInst()
	if EmojiAnimInst and EmojiAnimInst.SetNeedToPauseEye ~= nil then
		EmojiAnimInst:SetNeedToPauseEye(IsPause)
	end
end

-- function PhotoActorUtil.PauseAcotrAnim(Actor, IsPause)
--     local Major = PhotoActorUtil.GetMajor()
--     PhotoActorUtil.PauseActorAnim(Major, IsPause)
-- end

function PhotoActorUtil.PauseAllActorAnim(IsPause)
    local UActorManager = _G.UE.UActorManager:Get()
    local All = UActorManager:GetAllActors()
    for i = 1, All:Length() do
		local Actor = All:Get(i)
        PhotoActorUtil.PauseActorAnim(Actor, IsPause)
	end

    if IsPause then
        _G.UE.UVisionMgr.Get():PauseActorEnterShow()
    else
        _G.UE.UVisionMgr.Get():ResumeActorEnterShow()
    end
end

function PhotoActorUtil.PauseActorMovement(Actor, IsPause)
    local EActorType = _G.UE.EActorType
    if Actor ~= nil then
        local ActorType = Actor:GetActorType()
        if ActorType == EActorType.Major or ActorType == EActorType.Player or
            ActorType == EActorType.Companion or ActorType == EActorType.Summon then
            if IsPause then
                Actor:DoClientModeEnter()
            else
                Actor:DoClientModeExit()
            end
        end
    end
end

function PhotoActorUtil.PauseActorMovementByEntityID(EntityID, IsPause)
    local UActorManager = _G.UE.UActorManager:Get()
    local Actor = UActorManager:GetActorByEntityID(EntityID)
    PhotoActorUtil.PauseActorMovement(Actor, IsPause)
end

function PhotoActorUtil.PauseAllActorMovement(IsPause)
    local UActorManager = _G.UE.UActorManager:Get()
    local All = UActorManager:GetAllActors()
    for i = 1, All:Length() do
		local Actor = All:Get(i)
        PhotoActorUtil.PauseActorMovement(Actor, IsPause)
	end
end

function PhotoActorUtil.IsActorMoving(EntityID)
    local UActorManager = _G.UE.UActorManager:Get()
    local Actor = UActorManager:GetActorByEntityID(EntityID)
    if Actor and Actor.CharacterMovement and Actor.CharacterMovement.Velocity then
		return Actor.CharacterMovement.Velocity:Size() > 1
	end
end

-------------------------------------------------------------------------------------------------------
---@region Major matters

function PhotoActorUtil.GetMajorRotator()
    local Major = PhotoActorUtil.GetMajor()
    return Major:FGetActorRotation()
end

function PhotoActorUtil.GetSettingTypeByEntityID(EntityID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then return end

    local ActorSubType = ActorUtil.GetActorSubType(EntityID)
    local ActorType = ActorUtil.GetActorType(EntityID)
    local OwnerEntityID = ActorUtil.GetActorOwner(EntityID)

    local MainTypes = PhotoDefine.RoleSettingType
    local SubTypes =  PhotoDefine.RoleCtrlSetting
    local IsMate = false
    local SettingType, SubType

    if ActorUtil.IsPlayer(EntityID) then
        IsMate = CheckMates(Actor) -- 是否有关系（是否可控）
        SettingType = IsMate and MainTypes.Ctrl or MainTypes.UnCtrl
        SubType = IsMate and SubTypes.Ctrl.Mate or SubTypes.UnCtrl.Other
    elseif ActorSubType == EActorSubType.Buddy then
        IsMate = CheckMates(ActorUtil.GetActorByEntityID(OwnerEntityID))
        SettingType = IsMate and MainTypes.Ctrl or MainTypes.UnCtrl
        SubType = IsMate and SubTypes.Ctrl.Chocobo or SubTypes.UnCtrl.OtherChocobo
    elseif ActorType == _G.UE.EActorType.Summon then
        IsMate = CheckMates(ActorUtil.GetActorByEntityID(OwnerEntityID))
        SettingType = IsMate and MainTypes.Ctrl or MainTypes.UnCtrl
        SubType = IsMate and SubTypes.Ctrl.Summon or SubTypes.UnCtrl.OtherSummon
    --elseif Actor:Cast(_G.UE.ACompanionCharacter) then
    elseif ActorType == _G.UE.EActorType.Companion then
        local isMyPet = OwnerEntityID == MajorUtil.GetMajorEntityID()
        IsMate = CheckMates(ActorUtil.GetActorByEntityID(OwnerEntityID))
        SettingType = (isMyPet or IsMate) and MainTypes.Ctrl or MainTypes.UnCtrl
        if isMyPet then
            SubType = SubTypes.Ctrl.MyPet
        else
            SubType = IsMate and SubTypes.Ctrl.MatePet or SubTypes.UnCtrl.OtherPet 
        end
    elseif ActorUtil.IsNpc(EntityID) then
        SettingType = MainTypes.UnCtrl
        SubType = SubTypes.UnCtrl.NPC
    elseif ActorType == _G.UE.EActorType.Monster then
        SettingType = MainTypes.UnCtrl
        SubType = SubTypes.UnCtrl.Enemy
    end
    return SettingType, SubType
end

return PhotoActorUtil