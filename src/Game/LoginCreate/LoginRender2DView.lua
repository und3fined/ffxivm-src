---
--- Author: chriswang
--- DateTime: 2023-10-27 19:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginRender2DView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CanRotate bool
---@field ZoomScale float
---@field CanZoom bool
---@field CurPosX float
---@field StartPosX float
---@field FingerNum int
---@field Touch1StartX float
---@field Touch2StartX float
---@field Touch1CurX float
---@field Touch2CurX float
---@field ClosedSceneComponents SceneComponent
---@field ClosedPostProcessVolumes PostProcessVolume
---@field AllSceneComponents SceneComponent
---@field AllPostProcessVolumes PostProcessVolume
---@field bCompleteOneClick bool
---@field GestureState int
---@field DelayGestureHandle TimerHandle
---@field PrePosX float
---@field AllWindDirectionalSource WindDirectionalSourceComponent
---@field AllWindStrength float
---@field CloseWindDirectionalSource WindDirectionalSourceComponent
---@field Touch1StartY float
---@field Touch2StartY float
---@field Touch1CurY float
---@field Touch2CurY float
---@field StartPosY float
---@field PrePosY float
---@field CurPosY float
---@field CanMove bool
---@field PressTime float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginRender2DView = LuaClass(UIView, true)

function LoginRender2DView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CanRotate = nil
	--self.ZoomScale = nil
	--self.CanZoom = nil
	--self.CurPosX = nil
	--self.StartPosX = nil
	--self.FingerNum = nil
	--self.Touch1StartX = nil
	--self.Touch2StartX = nil
	--self.Touch1CurX = nil
	--self.Touch2CurX = nil
	--self.ClosedSceneComponents = nil
	--self.ClosedPostProcessVolumes = nil
	--self.AllSceneComponents = nil
	--self.AllPostProcessVolumes = nil
	--self.bCompleteOneClick = nil
	--self.GestureState = nil
	--self.DelayGestureHandle = nil
	--self.PrePosX = nil
	--self.AllWindDirectionalSource = nil
	--self.AllWindStrength = nil
	--self.CloseWindDirectionalSource = nil
	--self.Touch1StartY = nil
	--self.Touch2StartY = nil
	--self.Touch1CurY = nil
	--self.Touch2CurY = nil
	--self.StartPosY = nil
	--self.PrePosY = nil
	--self.CurPosY = nil
	--self.CanMove = nil
	--self.PressTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginRender2DView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginRender2DView:OnInit()

end

function LoginRender2DView:OnDestroy()

end

function LoginRender2DView:OnShow()

end

function LoginRender2DView:OnHide()

end

function LoginRender2DView:OnRegisterUIEvent()

end

function LoginRender2DView:OnRegisterGameEvent()

end

function LoginRender2DView:OnRegisterBinder()

end

return LoginRender2DView