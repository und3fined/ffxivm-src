---
--- Author: zimuyi
--- DateTime: 2024-03-20 14:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
-- local SaveKey = require("Define/SaveKey")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

-- local LightDefine = require("Game/Light/LightDefine")
local RechargingDefine = require("Game/Recharging/RechargingDefine")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local RechargingBgModelVM = require("Game/Recharging/VM/RechargingBgModelVM")
local LightMgr = require("Game/Light/LightMgr")
local HeadEIDName = "EID_HEAD_CENTER"

local USaveMgr = _G.UE.USaveMgr
local FLOG_INFO = _G.FLOG_INFO

---@class RechargingBgModelPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTataruBody UFButton
---@field BtnTataruHead UFButton
---@field ImgBg UFImage
---@field ModelToImage CommonModelToImageView
---@field PanelModel UFCanvasPanel
---@field AnimGiftIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimReturn UWidgetAnimation
---@field AnimTataruGiftIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RechargingBgModelPanelView = LuaClass(UIView, true)

function RechargingBgModelPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTataruBody = nil
	--self.BtnTataruHead = nil
	--self.ImgBg = nil
	--self.ModelToImage = nil
	--self.PanelModel = nil
	--self.AnimGiftIn = nil
	--self.AnimIn = nil
	--self.AnimReturn = nil
	--self.AnimTataruGiftIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RechargingBgModelPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ModelToImage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RechargingBgModelPanelView:OnInit()
	self.bShowCharacter = false
	self.Binders =
	{
		{ "bInGift", UIBinderValueChangedCallback.New(self, nil, self.OnInGiftChanged) },
	}
end

function RechargingBgModelPanelView:OnDestroy()

end

function RechargingBgModelPanelView:OnShow()
	-- 是否显示看板娘
	self.bShowCharacter = RechargingMgr:ShouldShowShopkeeper()
	if self.bShowCharacter then
		self:SwitchInteract(true)
		self:InitModelToImage()
		LightMgr:EnableUIWeather(23)

		-- 看板娘出现表现
		-- local bIsFirstShow = self:CheckFirstShowAction()
		-- if not bIsFirstShow then
		-- 	RechargingMgr:CheckRewardAction(RechargingDefine.RewardActionType.Welcome)
		-- end
		RechargingMgr:PlayAnimation(RechargingMgr:GetCharacterShowAction())

		self:AdjustCamera(HeadEIDName)
	end

	--面片背景测试 add by sammrli
	if _G.CommonModelToImageMgr.TestModelBgMode then
		UIUtil.SetIsVisible(self.ImgBg, false)
		_G.CommonModelToImageMgr:CreateModelBg(_G.UE.FVector(-100200, -17, 100056), _G.UE.FRotator(0, -90, 90), _G.UE.FVector(3.7, 1.9, 1))
	end
end

function RechargingBgModelPanelView:OnHide()
	if self.bShowCharacter then
		RechargingMgr:DestroyScene()
		LightMgr:DisableUIWeather()
	end
end

function RechargingBgModelPanelView:OnActive()
	local ShopKeeper = RechargingMgr:GetShopkeeper()
	if nil ~= ShopKeeper then
		ShopKeeper:SetActorVisibility(true, _G.UE.EHideReason.Common)
	end
end

function RechargingBgModelPanelView:OnInactive()
	local ShopKeeper = RechargingMgr:GetShopkeeper()
	if nil ~= ShopKeeper then
		ShopKeeper:SetActorVisibility(false, _G.UE.EHideReason.Common)
	end
end

function RechargingBgModelPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTataruHead, self.OnHeadClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnTataruBody, self.OnBodyClicked)
end

function RechargingBgModelPanelView:OnRegisterGameEvent()

end

function RechargingBgModelPanelView:OnRegisterBinder()
	self:RegisterBinders(RechargingBgModelVM, self.Binders)
end

function RechargingBgModelPanelView:OnInGiftChanged(NewValue, OldValue)
	if nil == OldValue then
		return
	end
	self:StopAllAnimations()
	if NewValue == true then
		local Animation = self.bShowCharacter and self.AnimTataruGiftIn or self.AnimGiftIn
		self:PlayAnimation(Animation)
	else
		self:PlayAnimation(self.AnimReturn)
	end
end

function RechargingBgModelPanelView:OnHeadClicked()
	if RechargingBgModelVM.bInGift then
		return
	end
	RechargingMgr:PlayActionTimeline(RechargingMgr:GetCharacterInteractActionID(RechargingDefine.ShopkeeperInteractType.Head))
	self:CooldownInteract()
end

function RechargingBgModelPanelView:OnBodyClicked()
	if RechargingBgModelVM.bInGift then
		return
	end
	RechargingMgr:PlayActionTimeline(RechargingMgr:GetCharacterInteractActionID(RechargingDefine.ShopkeeperInteractType.Body))
	self:CooldownInteract()
end

function RechargingBgModelPanelView:InitModelToImage()
	local function OpenSceneCallback()
		local ShopKeeper = ActorUtil.GetActorByEntityID(RechargingMgr.ShopkeeperEntityID)
		if nil ~= ShopKeeper and nil ~= RechargingMgr.SceneActor then
			self.ModelToImage:SetFOV(30) -- 用较小FOV，尽量减小相机畸变
			self.ModelToImage:Show(ShopKeeper, RechargingMgr.SceneActor:GetComponentByClass(_G.UE.UCameraComponent))
			-- SceneCapture特性更新
			local SceneCaptureComp = RechargingMgr.SceneActor:GetComponentByClass(_G.UE.USceneCaptureComponent2D)
			self.ModelToImage:SetDrawEffectNoGamma(true)
			if nil ~= SceneCaptureComp then
				SceneCaptureComp.ShowFlagSettings:Clear()
				local FlagsSetting = _G.UE.FEngineShowFlagsSetting()
				FlagsSetting.Enabled = true

				FlagsSetting.ShowFlagName = "Bloom"
				SceneCaptureComp.ShowFlagSettings:Add(FlagsSetting)

				FlagsSetting.ShowFlagName = "DynamicShadows"
				SceneCaptureComp.ShowFlagSettings:Add(FlagsSetting)

				FlagsSetting.ShowFlagName = "EyeAdaptation"
				SceneCaptureComp.ShowFlagSettings:Add(FlagsSetting)

				FlagsSetting.ShowFlagName = "Tonemapper"
				SceneCaptureComp.ShowFlagSettings:Add(FlagsSetting)

				SceneCaptureComp:UpdateShowFlags()
			end

			--面片背景测试 add by sammrli
			if _G.CommonModelToImageMgr.TestModelBgMode then
				UIUtil.SetIsVisible(self.ModelToImage, false)
				local function TimeOverCallBack()
					local ShopkeeperActor = RechargingMgr:GetShopkeeper()
					if ShopkeeperActor then
						ShopkeeperActor:K2_SetActorLocation(_G.UE.FVector(-100047.0, -40, 100040), false, nil, false)
						ShopkeeperActor:K2_SetActorRotation(_G.UE.FRotator(0, 8, 0), false)
					end
				end
				_G.TimerMgr:AddTimer(nil, TimeOverCallBack, 0, 2)
			end
		end
	end

	self.ModelToImage:SetAutoCreateDefaultScene(false)
	RechargingMgr:OpenScene(OpenSceneCallback)
end

function RechargingBgModelPanelView:AdjustCamera(EIDName)
	local HeadUIHalfSize = UIUtil.GetWidgetSize(self.BtnTataruHead) * 0.5
	local HeadUICenter = UIUtil.GetWidgetAbsoluteTopLeft(self.BtnTataruHead) + HeadUIHalfSize
	local ModelUIHalfSize = UIUtil.GetWidgetSize(self.ModelToImage) * 0.5
	local ModelUICenter = UIUtil.GetWidgetAbsoluteTopLeft(self.ModelToImage) + ModelUIHalfSize
	local OffsetCenterRatioY = (ModelUICenter.Y - HeadUICenter.Y) / ModelUIHalfSize.Y

	-- print("HeadUIHalfSize: "..tostring(HeadUIHalfSize))
	-- print("HeadUICenter: "..tostring(HeadUICenter))
	-- print("ModelUIHalfSize: "..tostring(ModelUIHalfSize))
	-- print("ModelUICenter: "..tostring(ModelUICenter))

	RechargingMgr:FocusSceneCapture(OffsetCenterRatioY, EIDName)
end

-- function RechargingBgModelPanelView:CheckFirstShowAction()
-- 	if USaveMgr.GetInt(SaveKey.bIsShopKeeperExist, 0, true) == 0 then
-- 		FLOG_INFO("Shopkeeper appears for the first time!")
-- 		USaveMgr.SetInt(SaveKey.bIsShopKeeperExist, 1, true)
-- 		RechargingMgr:PlayActionTimeline(RechargingMgr:GetCharacterShowActionID(), 0.3)
-- 		return true
-- 	else
-- 		FLOG_INFO("Shopkeeper already appeared!")
-- 		return false
-- 	end
-- end

function RechargingBgModelPanelView:SwitchInteract(bOn)
	self.BtnTataruHead:SetIsEnabled(bOn)
	self.BtnTataruBody:SetIsEnabled(bOn)
end

function RechargingBgModelPanelView:CooldownInteract()
	local CooldownTime = RechargingMgr:GetInteractCD()
	if nil == CooldownTime then
		return
	end
	self:SwitchInteract(false)
	self:RegisterTimer(function() self:SwitchInteract(true) end, CooldownTime)
end

return RechargingBgModelPanelView
