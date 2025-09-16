
local Util = {}

local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")



function Util.GetActorByEID(EID)
    return ActorUtil.GetActorByEntityID(EID)
end

function Util.GetMateEIDSet(IgnoreMajor)

    local FriendMgr = _G.FriendMgr
    local TeamMgr = _G.TeamMgr
    local ArmyMgr = _G.ArmyMgr


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

    local function Check(Player)
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
    
    for i = 1, All:Length() do
		local Player = All:Get(i)
		local AttrComponent = Player:GetAttributeComponent()

		if Check(Player) then
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
function Util.GetMajor()
    return MajorUtil.GetMajor()
end

function Util.GetMajorPet()
    local EID = _G.CompanionMgr.CallingOutCompanionEntityID

    if EID then
        return Util.GetActorByEID(EID)
    end
end

-- 陆行鸟
function Util.GetMajorChocobo()
    local UActorManager = _G.UE.UActorManager:Get()
    local EActorType = _G.UE.EActorType

    local All = UActorManager:GetAllActors()
    local MateEIDSet = Util.GetMateEIDSet()

    local Ret = {}

    if nil == All or All:Length() <= 0 then
		return Ret
	end

    local function Check(Actor)
		local AttrComponent = Actor:GetAttributeComponent()
		
        if AttrComponent then
            local Owner = AttrComponent.Owner
            if MateEIDSet[Owner] and AttrComponent.ObjType == _G.UE.EActorSubType.Buddy then
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

function Util.GetMajorSummons()
    local UActorManager = _G.UE.UActorManager:Get()
    local EActorType = _G.UE.EActorType

    local All = UActorManager:GetAllActors()
    local MateEIDSet = Util.GetMateEIDSet()

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
function Util.GetEntourates()
    -- 亲信还没做
    return {}
end

-- 伙伴 队友|部队|好友
function Util.GetMates()
    local Mates = Util.GetMateEIDSet(true)

    local Ret = {}

    for EID, _ in pairs(Mates) do
        local Mate = ActorUtil.GetActorByEntityID(EID)
        table.insert(Ret, Mate)
    end

    return Ret
end

-- 队友的宠物
function Util.GetMatePets()
    local UActorManager = _G.UE.UActorManager:Get()
    local All = UActorManager:GetAllCompanions()
    local MateEIDSet = Util.GetMateEIDSet(true)

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
function Util.GetPlayerOthers()
    local UActorManager = _G.UE.UActorManager:Get()
    local All = UActorManager:GetAllPlayers()
    local MateEIDSet = Util.GetMateEIDSet()

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

function Util.GetPlayerOtherChocobos()
    local UActorManager = _G.UE.UActorManager:Get()
    local EActorType = _G.UE.EActorType

    local All = UActorManager:GetAllActors()
    local MateEIDSet = Util.GetMateEIDSet()

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

function Util.GetPlayerOtherSummons()
    local UActorManager = _G.UE.UActorManager:Get()
    local EActorType = _G.UE.EActorType

    local All = UActorManager:GetAllActors()
    local MateEIDSet = Util.GetMateEIDSet()

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

function Util.GetPlayerOtherPets()
    local UActorManager = _G.UE.UActorManager:Get()

    local All = UActorManager:GetAllCompanions()
    local MateEIDSet = Util.GetMateEIDSet()

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

function Util.GetNPCs()
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

function Util.GetMonsters()
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

function Util.GetAllActorUEArray()
    local UActorManager = _G.UE.UActorManager:Get()

    local All = UActorManager:GetAllActors()

    return All
end

function Util.GetAllActor()
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

local MountBone = 3001

function Util.PauseActorAnim(Actor, IsPause)
    local AnimComponent = Actor:GetAnimationComponent()

    if AnimComponent then
        AnimComponent:PauseAnimation(IsPause)
        AnimComponent:PauseAnimationByPartType(MountBone, IsPause)
    end

    local EmojiAnimInst = Actor:GetEmojiAnimInst()
	if EmojiAnimInst and EmojiAnimInst.SetNeedToPauseEye ~= nil then
		EmojiAnimInst:SetNeedToPauseEye(IsPause)
	end
end

-- function Util.PauseAcotrAnim(Actor, IsPause)
--     local Major = Util.GetMajor()
--     Util.PauseActorAnim(Major, IsPause)
-- end

function Util.PauseAllActorAnim(IsPause)
    local UActorManager = _G.UE.UActorManager:Get()
    local All = UActorManager:GetAllActors()
    for i = 1, All:Length() do
		local Actor = All:Get(i)
        Util.PauseActorAnim(Actor, IsPause)
	end

    if IsPause then
        _G.UE.UVisionMgr.Get():PauseActorEnterShow()
    else
        _G.UE.UVisionMgr.Get():ResumeActorEnterShow()
    end
end

function Util.PauseActorMovement(Actor, IsPause)
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

function Util.PauseActorMovementByEntityID(EntityID, IsPause)
    local UActorManager = _G.UE.UActorManager:Get()
    local Actor = UActorManager:GetActorByEntityID(EntityID)
    Util.PauseActorMovement(Actor, IsPause)
end

function Util.PauseAllActorMovement(IsPause)
    local UActorManager = _G.UE.UActorManager:Get()
    local All = UActorManager:GetAllActors()
    for i = 1, All:Length() do
		local Actor = All:Get(i)
        Util.PauseActorMovement(Actor, IsPause)
	end
end

function Util.IsActorMoving(EntityID)
    local UActorManager = _G.UE.UActorManager:Get()
    local Actor = UActorManager:GetActorByEntityID(EntityID)
    if Actor and Actor.CharacterMovement and Actor.CharacterMovement.Velocity then
		return Actor.CharacterMovement.Velocity:Size() > 1
	end
end

-------------------------------------------------------------------------------------------------------
---@region Major matters

function Util.GetMajorRotator()
    local Major = Util.GetMajor()
    return Major:FGetActorRotation()
end

return Util