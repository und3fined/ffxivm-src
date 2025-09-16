--
-- Author: anypkvcai
-- Date: 2020-12-11 14:39:09
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local AudioUtil = require("Utils/AudioUtil")

local InfoTipsBaseView = LuaClass(UIView, true)

function InfoTipsBaseView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoTipsBaseView:OnRegisterTimer()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ShowTime = Params.ShowTime
	--local EndTime = self.AniFadeOut:GetEndTime()
	--local DelayTime = math.max(ShowTime - EndTime, 0)
	if (ShowTime ~= nil and tonumber(ShowTime) ~= nil) then
		self:RegisterTimer(self.OnTimer, ShowTime)
	end
	
	--self:RegisterTimer(self.OnTimerPlayAnimation,DelayTime)
	--self:RegisterTimer(self.OnTimerHide,ShowTime)

end

function InfoTipsBaseView:OnShow()
	if self.Params == nil then
		return
	end
	local SoundName = self.Params.SoundName
	if nil ~= SoundName and string.len(SoundName) > 0 then
		AudioUtil.LoadAndPlay2DSound(SoundName)
	end
	if self.Anim_Aoto_In ~= nil then
		self:PlayAnimation(self.Anim_Aoto_In)
	end
end


--function InfoTipsBaseView:OnTimerPlayAnimation()
--    self:PlayAnimationForward(self.AniFadeOut,1.0,true)
--
--    --self:PlayAnimation(self.AniFadeOut)
--
--    --self.SequencePlayer = self:PlayAnimation(self.AniFadeOut)
--    --self.SequencePlayer = self:PlayAnimationForward(self.AniFadeOut,1.0,true)
--end
--
--function InfoTipsBaseView:OnTimerHide()
--    self:Hide()
--    --self.SequencePlayer = self:PlayAnimation(self.AniFadeOut)
--    --self.SequencePlayer = self:PlayAnimationForward(self.AniFadeOut,1.0,true)
--end


function InfoTipsBaseView:OnTimer()
	self:Hide()

	--self:PlayAnimation(self.AniFadeOut)

	--self.SequencePlayer = self:PlayAnimation(self.AniFadeOut)
	--self.SequencePlayer = self:PlayAnimationForward(self.AniFadeOut,1.0,true)
end

--function InfoTipsBaseView:OnAnimationFinished(Animation)
--	--self.SequencePlayer:RestorePreAnimatedState()
--	--self.SequencePlayer = nil
--	self:Hide()
--end

return InfoTipsBaseView