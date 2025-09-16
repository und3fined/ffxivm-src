---
--- Author: loiafeng
--- DateTime: 2024-05-09 10:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoadingVM = require("Game/Loading/LoadingVM")
local ProtoRes = require("Protocol/ProtoRes")
local CommonUtil = require("Utils/CommonUtil")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local EUMGSequencePlayMode = _G.UE.EUMGSequencePlayMode

---@class LoadingProBarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCactus UFImage
---@field ImgMoogle UFImage
---@field ProBar UProgressBar
---@field AnimProBar UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoadingProBarItemView = LuaClass(UIView, true)

function LoadingProBarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCactus = nil
	--self.ImgMoogle = nil
	--self.ProBar = nil
	--self.AnimProBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingProBarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingProBarItemView:OnInit()
	self.Binders = {
		{ "ProBarType", UIBinderValueChangedCallback.New(self, nil, self.ProBarTypeChangedCallback) },
	}

	self.AnimEndProgress = 0
end

function LoadingProBarItemView:OnDestroy()
end

function LoadingProBarItemView:OnShow()
	self:SetAnimProgress(0, 0.9, 4)
end

function LoadingProBarItemView:OnHide()
end

function LoadingProBarItemView:OnRegisterUIEvent()
end

function LoadingProBarItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.WorldPostLoad, self.OnGameEventWorldPostLoad)
end

function LoadingProBarItemView:OnRegisterBinder()
	self:RegisterBinders(LoadingVM, self.Binders)
end

---SetProBarProgress
---@param Start number 开始进度
---@param Start number 结束进度
---@param Start number 动画持续时间
function LoadingProBarItemView:SetAnimProgress(Start, End, Time)
	if End > Start then
		self:PlayLoadingAnimationTimeRange(self.AnimProBar, Start, End, 1, 
			EUMGSequencePlayMode.Forward, (Start - End) / Time, false)
		self.AnimEndProgress = End
	end
end

---GetProBarProgress 获取当前进度条动画进度
---@return number
function LoadingProBarItemView:GetAnimProgress()
	if self:IsAnimationPlaying(self.AnimProBar) then
		return self:GetAnimationCurrentTime(self.AnimProBar)
	else
		return self.AnimEndProgress
	end
end

function LoadingProBarItemView:OnGameEventWorldPostLoad()
	self:SetAnimProgress(self:GetAnimProgress(), 1, 0.3)
end

function LoadingProBarItemView:ProBarTypeChangedCallback(NewValue)
	local UseCactus = (NewValue == ProtoRes.LoadingProBarType.LOADING_PROBAR_CACTUAR)
	UIUtil.SetIsVisible(self.ImgCactus, UseCactus)
	UIUtil.SetIsVisible(self.ImgMoogle, not UseCactus)  -- 默认莫古力
end

return LoadingProBarItemView