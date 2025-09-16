local Util = {}
local PhotoDefine = require("Game/Photo/PhotoDefine")
local AnimType = PhotoDefine.AnimType
local MsgTipsID = require("Define/MsgTipsID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ActorUtil = require("Utils/ActorUtil")

function Util.CheckEmo4Photo(EmoCfg)
    return EmoCfg.PhotoHide ~= 1
end

function Util.ShowAnimTips(InAnimType, ID)
    if InAnimType == AnimType.Motion or InAnimType == AnimType.Face then
        _G.EmotionMgr:ShowCannotUseTips(ID)
    else
        MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionCannotUse)
    end
end

---@param EmotionID 	情感动作ID
---@param EntityID 		玩家EntityID
function Util.IsEnableIDMovement(EntityID)

    local EmotionMgr = _G.EmotionMgr
	
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if not Actor then return end
	local StateCom = ActorUtil.GetActorStateComponent(EntityID)
	if StateCom == nil then return end
	local RideCom = Actor:GetRideComponent()
	if RideCom == nil then return end
	local AttributeComp = ActorUtil.GetActorAttributeComponent(EntityID)
	if AttributeComp == nil then return end

	-- 先使用EmotionMgr数据,后面movement也会合到情感动作
	-- local SitChairID = EmotionMgr.SitChairID
	-- local SitGroundID = EmotionMgr.SitGroundID

	local IsSit = _G.EmotionMgr:IsSitState(EntityID)
	local bIsActiveChangeRole = EmotionMgr.bIsActiveChangeRole
	local bBecomeHuman = EmotionMgr.bBecomeHuman

	local RideID = RideCom:GetRideResID()
	local bIsRiding = RideCom:IsInRide()			--坐骑中
	local bIsSwimming = Actor:IsSwimming()			--游泳中
	local bIsFish = _G.FishMgr:IsInFishState()		--钓鱼中
	local bIsUsingSkill = StateCom:IsUsingSkill()	--技能中
	local bIsStorage = _G.SkillStorageMgr:IsStorage(EntityID)	--蓄力中
	local bIsDead = StateCom:IsDeadState()			--死亡中
	local bIsChange = bIsActiveChangeRole and not bBecomeHuman or false	--变人
	local bSpecialState = bIsUsingSkill or bIsStorage or bIsDead or bIsChange	--特殊状态，所有动作都不可用
	local bIsEnable = true

	if bSpecialState then
		bIsEnable = false
	elseif bIsRiding then   --坐骑状态
		bIsEnable = false
	elseif bIsSwimming then	 --游泳状态
		bIsEnable = false
	elseif bIsFish then		 --钓鱼状态
		bIsEnable = false
	elseif IsSit then
        bIsEnable = false
	end
    
	return bIsEnable
end

return Util