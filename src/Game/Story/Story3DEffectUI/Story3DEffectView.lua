---
--- Author: lydianwang
--- DateTime: 2025-04-10 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class Story3DEffectView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Story3DEffectView = LuaClass(UIView, true)

function Story3DEffectView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Story3DEffectView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Story3DEffectView:OnInit()
	self.EffectActor = nil
end

function Story3DEffectView:OnDestroy()

end

function Story3DEffectView:OnShow()
	local BPPath = "Blueprint'/Game/UI/BP/Story/Story3DEffectUI/Story3DEffectActor.Story3DEffectActor_C'"
	local BPClass = _G.ObjectMgr:LoadClassSync(BPPath)
	if BPClass ~= nil then
		local Z = 100000
		self.EffectActor = _G.CommonUtil.SpawnActor(BPClass, _G.UE.FVector(0, 0, Z))
	end
end

function Story3DEffectView:OnHide()
	if self.EffectActor ~= nil then
		_G.CommonUtil.DestroyActor(self.EffectActor)
	end
end

function Story3DEffectView:OnRegisterUIEvent()

end

function Story3DEffectView:OnRegisterGameEvent()

end

function Story3DEffectView:OnRegisterBinder()

end

return Story3DEffectView