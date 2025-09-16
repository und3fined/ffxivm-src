---
--- Author: Administrator
--- DateTime: 2024-03-22 10:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local GatherPointCfg = require("Tablecfg/GatherPointcfg")
local HPBarLikeAnimProxyFactory = require("Game/Main/HPBarLikeAnimProxyFactory")

local EActorType = _G.UE.EActorType

---@class GatheringJobBarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ProBar UProgressBar
---@field ProBarLight UFImage
---@field TextLevel UFTextBlock
---@field TextNumber UFTextBlock
---@field TextPlace UFTextBlock
---@field AnimLightAdd UWidgetAnimation
---@field AnimLightSubtract UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringJobBarItemView = LuaClass(UIView, true)

function GatheringJobBarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ProBar = nil
	--self.ProBarLight = nil
	--self.TextLevel = nil
	--self.TextNumber = nil
	--self.TextPlace = nil
	--self.AnimLightAdd = nil
	--self.AnimLightSubtract = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.BarValueChangedCallback = nil
end

function GatheringJobBarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringJobBarItemView:OnInit()
	self.TextLevel:SetText("")

	self.HpAnimProxy =
        HPBarLikeAnimProxyFactory.CreateShapeProxy(
        self,
        self.ProBar,
        self.AnimLightAdd,
        self.AnimLightSubtract,
        self.probarlight,
        self.probarlight
    )
	self.HpAnimProxy:Reset()
end

function GatheringJobBarItemView:OnDestroy()
end

function GatheringJobBarItemView:OnShow()
	UIUtil.SetIsVisible(self.ProBarLight, false)
end

function GatheringJobBarItemView:OnHide()
	_G.EventMgr:SendEvent(EventID.GatheringJobShowBarView, false)
end

function GatheringJobBarItemView:OnRegisterUIEvent()

end

function GatheringJobBarItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.GatherAttrChange, self.OnGatherAttrChangeEvent)
end

function GatheringJobBarItemView:OnRegisterBinder()

end


function GatheringJobBarItemView:OnGatherAttrChangeEvent(Params)
	local EntityID = Params.ULongParam1
	if self.EntityID and EntityID and self.EntityID == EntityID then
		self:RefreshBarViewByEntityID(self.EntityID)
	end
end


function GatheringJobBarItemView:RefreshBarView(CurNum, TotalNum)
	local Percent = CurNum > 0 and CurNum / TotalNum or 0
    self.ProBar:SetPercent(Percent)
	self.HpAnimProxy:Upd(Percent)
	self.TextNumber:SetText(string.format("%d/%d", CurNum, TotalNum))
	local GatherItemID = ActorUtil.GetActorResID(self.EntityID) --采集点ID
    local GatherPointItemCfg = GatherPointCfg:FindCfgByKey(GatherItemID)
	local ActorName = GatherPointItemCfg and GatherPointItemCfg.Name or ""
	self.TextPlace:SetText(ActorName)
end

function GatheringJobBarItemView:RefreshBarViewByEntityID(EntityID)
	self.EntityID = EntityID
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	local AttributeComponent = Actor and Actor:GetAttributeComponent()
	local IsShow = false
	if AttributeComponent then
		local AttributeComponent = Actor:GetAttributeComponent()
		local ActorType = AttributeComponent:GetActorType()
		if EActorType.Gather == ActorType then
			local CurHP = AttributeComponent.PickTimesLeft
			local MaxHP = _G.GatherMgr:GetMaxGatherCount(AttributeComponent.ResID, AttributeComponent.ListID)
			self.LastMaxHP = MaxHP
			self:RefreshBarView(CurHP, MaxHP)
			IsShow = true
		end
	else
		self:RefreshBarView(0, self.LastMaxHP or 4)
		IsShow = true
	end
	UIUtil.SetIsVisible(self.Object, IsShow)
	_G.EventMgr:SendEvent(EventID.GatheringJobShowBarView, IsShow)
end

return GatheringJobBarItemView