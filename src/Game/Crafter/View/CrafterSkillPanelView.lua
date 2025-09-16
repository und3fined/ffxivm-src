---
--- Author: chriswang
--- DateTime: 2023-08-31 17:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local MajorUtil = require("Utils/MajorUtil")
---@class CrafterSkillPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSkillLine UFImage
---@field Skill1 CrafterSkillItemView
---@field Skill2 CrafterSkillItemView
---@field Skill3 CrafterSkillItemView
---@field Skill4 CrafterSkillItemView
---@field Skill5 CrafterSkillItemView
---@field SkillDrugBtn SkillDrugBtnView
---@field SkillMake CrafterSkillMakeItemView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterSkillPanelView = LuaClass(UIView, true)

function CrafterSkillPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSkillLine = nil
	--self.Skill1 = nil
	--self.Skill2 = nil
	--self.Skill3 = nil
	--self.Skill4 = nil
	--self.Skill5 = nil
	--self.SkillDrugBtn = nil
	--self.SkillMake = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterSkillPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Skill1)
	self:AddSubView(self.Skill2)
	self:AddSubView(self.Skill3)
	self:AddSubView(self.Skill4)
	self:AddSubView(self.Skill5)
	self:AddSubView(self.SkillDrugBtn)
	self:AddSubView(self.SkillMake)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterSkillPanelView:OnInit()
	self.SkillItemVisibleMap = {}
end

function CrafterSkillPanelView:OnDestroy()

end

function CrafterSkillPanelView:OnShow()
	self.EntityID = MajorUtil.GetMajorEntityID()

	local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if LogicData == nil then
		return
	end

	local SkillID = 0
	local bShowLine = true
	for index = 1, 5 do
		SkillID = LogicData:GetBtnSkillID(index)
		if SkillID == 0 then
			bShowLine = false
			self.SkillItemVisibleMap[index] = false
			UIUtil.SetIsVisible(self["Skill" .. index], false)
		else
			self.SkillItemVisibleMap[index] = true
			UIUtil.SetIsVisible(self["Skill" .. index], true)
		end
	end

	UIUtil.SetIsVisible(self.ImgSkillLine, bShowLine)
	UIUtil.SetIsVisible(self.SkillDrugBtn, false)

	-- self.SkillDrugBtn.bEnablePress = true
end

function CrafterSkillPanelView:OnHide()
	self:StopAllAnimations()
end

function CrafterSkillPanelView:OnRegisterUIEvent()

end

function CrafterSkillPanelView:OnRegisterGameEvent()
	local EventID = _G.EventID
	self:RegisterGameEvent(EventID.CrafterSkillCostUpdate, self.OnCrafterSkillCostUpdate)
	self:RegisterGameEvent(EventID.CrafterSkillCDUpdate, self.OnCrafterSkillCDUpdate)
	self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
end

function CrafterSkillPanelView:OnRegisterBinder()
	self:PostSkillEntityChange()
end

function CrafterSkillPanelView:PostSkillEntityChange()
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

local CrafterSkillIndexMax <const> = 5

function CrafterSkillPanelView:OnCrafterSkillCostUpdate(Params)
	for Index = 1, CrafterSkillIndexMax do
		if self.SkillItemVisibleMap[Index] then
			self["Skill" .. Index]:OnCrafterSkillCostUpdate(Params)
		end
	end
	self.SkillMake:OnCrafterSkillCostUpdate(Params)
end

function CrafterSkillPanelView:OnCrafterSkillCDUpdate(Params)
	for index = 1, CrafterSkillIndexMax do
		if self.SkillItemVisibleMap[index] then
			self["Skill" .. index]:OnCrafterSkillCDUpdate(Params)
		end
	end
end

function CrafterSkillPanelView:OnMajorLevelUpdate(Params)
	for index = 1, 5 do
		if self.SkillItemVisibleMap[index] then
			self["Skill" .. index]:OnMajorLevelUpdate(Params)
		end
	end
end

return CrafterSkillPanelView