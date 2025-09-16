---
--- Author: chriswang
--- DateTime: 2024-07-16 14:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local MajorUtil = require("Utils/MajorUtil")
---@class GatherDrugSkillPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SkillDrugBtn SkillDrugBtnView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatherDrugSkillPanelView = LuaClass(UIView, true)

function GatherDrugSkillPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SkillDrugBtn = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatherDrugSkillPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SkillDrugBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatherDrugSkillPanelView:OnInit()

end

function GatherDrugSkillPanelView:OnDestroy()

end

function GatherDrugSkillPanelView:OnShow()
	self.EntityID = MajorUtil.GetMajorEntityID()

	local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if LogicData == nil then
		return
	end

	self.SkillDrugBtn.bEnablePress = true
end

function GatherDrugSkillPanelView:OnHide()

end

function GatherDrugSkillPanelView:OnRegisterUIEvent()

end

function GatherDrugSkillPanelView:OnRegisterGameEvent()

end

function GatherDrugSkillPanelView:OnRegisterBinder()
	self:PostSkillEntityChange()
end

function GatherDrugSkillPanelView:PostSkillEntityChange()
	local MajorEntityID = MajorUtil.GetMajorEntityID()
    if MajorEntityID == 0 then
        MajorEntityID = _G.PWorldMgr.MajorEntityID
    end
	local SubViews = self.SubViews
    for _, value in ipairs(SubViews) do
        if value["OnEntityIDUpdate"] ~= nil then
            value:OnEntityIDUpdate(MajorEntityID, true)
        end
    end
end

return GatherDrugSkillPanelView