--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_SignMarker_C
require "UnLua"
local Class = _G.Class

local SignMarkerEffectActor = Class()

function SignMarkerEffectActor:Initialize(Initializer)
    self.SignsMainSlotView = nil
end

function SignMarkerEffectActor:SetParent(SignsMainSlotView)
    self.SignsMainSlotView = SignsMainSlotView
end

function SignMarkerEffectActor:OnMoveEnd(IgnoreActors)
    local Res = self:ConfirmActorMoveLocation(IgnoreActors)

    if self.SignsMainSlotView ~= nil then
        local ActorLocation = self:K2_GetActorLocation()

        if ActorLocation.x == 0 and ActorLocation.y == 0 and ActorLocation.z == 0 then
            self.SignsMainSlotView:ConfirmActorMoveLocation(false)
        else
            self.SignsMainSlotView:ConfirmActorMoveLocation(true)
        end

        self.SignsMainSlotView = nil
    end
end

-- function M:UserConstructionScript()
-- end

-- function M:ReceiveBeginPlay()
-- end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

return SignMarkerEffectActor
