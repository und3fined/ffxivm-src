---
--- Author: chriswang
--- DateTime: 2022-04-22 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local EventID = require("Define/EventID")

---@class SelectMonsterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FButton_Select UFButton
---@field FImg_Select UFImage
---@field FText_MonsterName UFTextBlock
---@field FText_MonsterTag UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SelectMonsterItemView = LuaClass(UIView, true)

function SelectMonsterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FButton_Select = nil
	--self.FImg_Select = nil
	--self.FText_MonsterName = nil
	--self.FText_MonsterTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SelectMonsterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SelectMonsterItemView:OnInit()
	self.EntranceItem = nil
	UIUtil.SetIsVisible(self.FImg_Select, false)
end

function SelectMonsterItemView:OnDestroy()

end

function SelectMonsterItemView:OnShow()
	if nil == self.Params then
		return
	end

	self:PlayAnimation(self.AnimReady)

	local Data = self.Params.Data
	if Data then
		self:FillEntrance(Data)
	end
end

function SelectMonsterItemView:OnHide()

end

function SelectMonsterItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButton_Select, self.OnClicked)
end

function SelectMonsterItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.SelectMonsterIndex, self.OnSelectMonster)

    -- self:RegisterGameEvent(EventID.SKillSelectTarget, self.OnSwitchTarget)
end

function SelectMonsterItemView:OnRegisterBinder()

end

function SelectMonsterItemView:OnSelectMonster(EntityID)
	if EntityID ~= self.EntranceItem.EntityID then
		UIUtil.SetIsVisible(self.FImg_Select, false)

		if self:IsAnimationPlaying(self.AnimSelectLoop) == true then
			self:StopAnimation(self.AnimSelectLoop)
		end
	else
		UIUtil.SetIsVisible(self.FImg_Select, true)
		self:PlayAnimation(self.AnimSelect)
	end
end

function SelectMonsterItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimSelect then
		self:PlayAnimation(self.AnimSelectLoop, 0, 0)
	end
end

-- function SelectMonsterItemView:OnSwitchTarget(EventParams)
-- 	if EventParams.ULongParam1 ~= self.EntranceItem.EntityID then
-- 		UIUtil.SetIsVisible(self.FImg_Select, false)
-- 	else
-- 		UIUtil.SetIsVisible(self.FImg_Select, true)
-- 	end
-- end

function SelectMonsterItemView:FillEntrance(EntranceItem)
	if not EntranceItem then
		return
	end
	
	if self.EntranceItem and EntranceItem and EntranceItem.EntityID == self.EntranceItem.EntityID then
		return
	end

	self.EntranceItem = EntranceItem

	local ActorName = ActorUtil.GetActorName(EntranceItem.EntityID)
	self.FText_MonsterName:SetText(ActorName)
	
	local PostStr = _G.SelectMonsterMgr:GetMonsterStrTag(EntranceItem.ResID, EntranceItem.EntityID)
	self.FText_MonsterTag:SetText(PostStr)

end

function SelectMonsterItemView:OnClicked()
	_G.SelectMonsterMgr:SelectMonster(self.EntranceItem.EntityID)
end

return SelectMonsterItemView