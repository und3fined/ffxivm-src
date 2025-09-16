--
-- Author: lipengzha
-- Date: 2021-09-02
-- Description: 管理显示在场景中的音频位置
--
require "UnLua"

local AudioDebugDrawer = Class()

--function AudioDebugDrawer:Initialize(Initializer)
--end

--function AudioDebugDrawer:UserConstructionScript()
--end

function AudioDebugDrawer:ReceiveBeginPlay()
end

function AudioDebugDrawer:ReceiveEndPlay()
end


-- function AudioDebugDrawer:AddPlaying(InAudioEventItem)
--     self.Overridden.AddPlaying(self,InAudioEventItem)
--     local UserWidget = self.Widget:GetUserWidgetObject()
--     print("add playing event"..InAudioEventItem.EventName..tostring(InAudioEventItem.PlayingID))
--     UserWidget:AddNewEventItem(InAudioEventItem.EventName,InAudioEventItem.PlayingID)
    
-- end

-- function AudioDebugDrawer:Remove(InAudioEventItem)
--     self.Overridden.Remove(self,InAudioEventItem)
--     local UserWidget = self.Widget:GetUserWidgetObject()
--     UserWidget:RemovePlayingEventItem(InAudioEventItem.EventName,InAudioEventItem.PlayingID)
--     print("remove playing event"..InAudioEventItem.EventName..tostring(InAudioEventItem.PlayingID))
-- end

--function AudioDebugDrawer:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function AudioDebugDrawer:ReceiveActorBeginOverlap(OtherActor)
--end

--function AudioDebugDrawer:ReceiveActorEndOverlap(OtherActor)
--end

return AudioDebugDrawer