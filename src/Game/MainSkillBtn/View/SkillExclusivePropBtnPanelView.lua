---
--- Author: henghaoli
--- DateTime: 2024-08-19 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local ShowTipsDelay <const> = 3.0  -- 进入副本后隔一会再弹提示

---@class SkillExclusivePropBtnPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SkillExclusivePropBtn SkillExclusivePropBtnView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillExclusivePropBtnPanelView = LuaClass(UIView, true)

function SkillExclusivePropBtnPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SkillExclusivePropBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillExclusivePropBtnPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SkillExclusivePropBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillExclusivePropBtnPanelView:OnInit()

end

function SkillExclusivePropBtnPanelView:OnDestroy()

end

function SkillExclusivePropBtnPanelView:OnShow()
	self:OnEntityIDUpdate(_G.PWorldMgr.MajorEntityID, true)
	local Params = self.Params
	if not Params then
		return
	end

	local Content = Params.TipsContent
	if Content then
		self:RegisterTimer(function()
			MsgTipsUtil.ShowTips(Content, nil, Params.TipsDuration)
		end, ShowTipsDelay, 0, 1)
	end
end

function SkillExclusivePropBtnPanelView:OnHide()

end

function SkillExclusivePropBtnPanelView:OnRegisterUIEvent()

end

function SkillExclusivePropBtnPanelView:OnRegisterGameEvent()
	local EventID = _G.EventID
	self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
end

function SkillExclusivePropBtnPanelView:OnRegisterBinder()

end

function SkillExclusivePropBtnPanelView:OnEntityIDUpdate(EntityID, bMajor)
	self.EntityID = EntityID
	self.bMajor = bMajor
	local SubViews = self.SubViews
	for _, value in ipairs(SubViews) do
		if value["OnEntityIDUpdate"] ~= nil then
			value:OnEntityIDUpdate(EntityID, self.bMajor)
		end
	end
end

function SkillExclusivePropBtnPanelView:OnMajorLevelUpdate(RoleDetail)
	local ProfID = RoleDetail.ProfID
    if ProfID ~= MajorUtil.GetMajorProfID() then
        return
    end

	local SubViews = self.SubViews
	for _, value in ipairs(SubViews) do
		if value["Refresh"] ~= nil then
			value:Refresh()
		end
	end
end

return SkillExclusivePropBtnPanelView