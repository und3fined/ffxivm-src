---
--- Author: loiafeng
--- DateTime: 2025-02-10 19:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local TargetMgr = _G.TargetMgr ---@type TargetMgr

local EnmityImgAsset = {
	FirstEnmity = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Hatred_Img_Hatred1_png.UI_Main_Hatred_Img_Hatred1_png'",  -- 红色
	Normal = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Hatred_Img_Hatred2_png.UI_Main_Hatred_Img_Hatred2_png'",  -- 灰色
}

local TargetLockType_Hard <const> = _G.UE.ETargetLockType.Hard

---@class MainHatredItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnHatred UFButton
---@field HatredItemPanel UFCanvasPanel
---@field ImgHatred UFImage
---@field ImgSelect UFImage
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainHatredItemView = LuaClass(UIView, true)

function MainHatredItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnHatred = nil
	--self.HatredItemPanel = nil
	--self.ImgHatred = nil
	--self.ImgSelect = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainHatredItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainHatredItemView:OnInit()
	self.EntityID = 0
	self.bPressed = false

	self.Binders = {
		{ "EntityID", UIBinderValueChangedCallback.New(self, nil, self.OnEntityIDChanged) },
		{ "RankInMonsterEnmityList", UIBinderValueChangedCallback.New(self, nil, self.OnRankInMonsterEnmityListChanged) },
		{ "bLastIsDisplay", UIBinderValueChangedCallback.New(self, nil, self.OnLastIsDisplayChanged) },
	}
end

function MainHatredItemView:OnDestroy()

end

function MainHatredItemView:OnShow()

end

function MainHatredItemView:OnHide()

end

function MainHatredItemView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.BtnHatred, self.OnPressed)
    UIUtil.AddOnReleasedEvent(self, self.BtnHatred, self.OnReleased)
end

function MainHatredItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TargetChangeMajor, self.OnGameEventTargetChangeMajor)
end

function MainHatredItemView:OnRegisterBinder()
	local ItemVM = (self.Params or {}).Data
	if nil == ItemVM then
		return
	end

	self:RegisterBinders(ItemVM, self.Binders)
end

function MainHatredItemView:OnGameEventTargetChangeMajor(EntityID)
	UIUtil.SetIsVisible(self.ImgSelect, EntityID == self.EntityID)
end

function MainHatredItemView:OnPressed()
	self.bPressed = true
	self.HatredItemPanel:SetRenderScale(_G.UE.FVector2D(1.1, 1.1))
end

function MainHatredItemView:OnReleased()
	if not self.bPressed then
		return
	end

	self.bPressed = false
	self.HatredItemPanel:SetRenderScale(_G.UE.FVector2D(1.0, 1.0))

	local TargetActor = ActorUtil.GetActorByEntityID(self.EntityID)
	if SelectTargetBase:IsCanBeSelect(TargetActor, false) then
		local EventParams = _G.EventMgr:GetEventParams()
		EventParams.ULongParam1 = self.EntityID
		EventParams.IntParam2 = TargetLockType_Hard
		_G.EventMgr:SendCppEvent(_G.EventID.ManualSelectTarget, EventParams)
	end
end

function MainHatredItemView:OnEntityIDChanged(EntityID)
	local OldEntityID = self.EntityID
	self.EntityID = EntityID

	if EntityID <= 0 then
		UIUtil.SetIsVisible(self.HatredItemPanel, false)
		return
	end

	if EntityID == OldEntityID then
		return
	end

	UIUtil.SetIsVisible(self.HatredItemPanel, true)

	local Name = ActorUtil.GetActorName(EntityID)
	self.TextTitle:SetText(Name)

	UIUtil.SetIsVisible(self.ImgSelect, TargetMgr:GetMajorSelectedTarget() == EntityID)

	self.bPressed = false
	self.HatredItemPanel:SetRenderScale(_G.UE.FVector2D(1.0, 1.0))
end

function MainHatredItemView:OnRankInMonsterEnmityListChanged(Rank)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgHatred, Rank == 1 and EnmityImgAsset.FirstEnmity or EnmityImgAsset.Normal)
end

function MainHatredItemView:OnLastIsDisplayChanged(bLastIsDisplay)
	if not bLastIsDisplay then
		self:PlayInsertAnim()
	end
end

function MainHatredItemView:PlayInsertAnim()
	self:PlayAnimation(self.AnimIn)
end

return MainHatredItemView
