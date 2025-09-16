---
--- Author: anypkvcai
--- DateTime: 2021-05-21 11:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local AudioUtil = require("Utils/AudioUtil")

---@class CommonPlaySoundView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SoundPathOnShow SoftObjectPath
---@field SoundPathOnHide SoftObjectPath
---@field SoundPathOnActive SoftObjectPath
---@field SoundPathOnInactive SoftObjectPath
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonPlaySoundView = LuaClass(UIView, true)

function CommonPlaySoundView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SoundPathOnShow = nil
	--self.SoundPathOnHide = nil
	--self.SoundPathOnActive = nil
	--self.SoundPathOnInactive = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonPlaySoundView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonPlaySoundView:OnInit()

end

function CommonPlaySoundView:OnDestroy()

end

function CommonPlaySoundView:OnShow()
	AudioUtil.LoadAndPlayUISound(self.SoundPathOnShow:ToString())
end

function CommonPlaySoundView:OnHide()
	AudioUtil.LoadAndPlayUISound(self.SoundPathOnHide:ToString())
end

function CommonPlaySoundView:OnActive()
	AudioUtil.LoadAndPlayUISound(self.SoundPathOnActive:ToString())
end

function CommonPlaySoundView:OnInactive()
	AudioUtil.LoadAndPlayUISound(self.SoundPathOnInactive:ToString())
end

return CommonPlaySoundView