---
--- Author: stellahxhu
--- DateTime: 2022-07-26 16:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class TeamAttriAddJobItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Base1 UFImage
---@field FImg_Base2 UFImage
---@field FImg_Base3 UFImage
---@field FImg_Base4 UFImage
---@field FImg_Special1 UFImage
---@field FImg_Special2 UFImage
---@field FImg_Special3 UFImage
---@field JobListItem UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamAttriAddJobItemView = LuaClass(UIView, true)

function TeamAttriAddJobItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Base1 = nil
	--self.FImg_Base2 = nil
	--self.FImg_Base3 = nil
	--self.FImg_Base4 = nil
	--self.FImg_Special1 = nil
	--self.FImg_Special2 = nil
	--self.FImg_Special3 = nil
	--self.JobListItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamAttriAddJobItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamAttriAddJobItemView:OnInit()
	self.WidgetList = {self.FImg_Base1, self.FImg_Base2, self.FImg_Base3, self.FImg_Base4, self.FImg_Special1, self.FImg_Special2, self.FImg_Special3}
	self.Binders = {
		{ "TeamProfList", UIBinderValueChangedCallback.New(self, nil, self.OnTeamProfListChanged) },
	}
end

function TeamAttriAddJobItemView:OnRegisterBinder()
	if _G.PWorldMgr:CurrIsInDungeon() then
		self.VM = _G.PWorldTeamVM
	else
		self.VM = _G.TeamVM
	end
	self:RegisterBinders(self.VM, self.Binders)
end

function TeamAttriAddJobItemView:SetPredefinedProfs(Profs)
	self.PredefinedProfs = Profs
	for i = 1, 7 do
		local ProfID = (self.PredefinedProfs[i] or {}).Prof
		self:SetWidget(self.WidgetList[i], ProfID, false)
	end
end

function TeamAttriAddJobItemView:OnTeamProfListChanged(ProfList)
	if self.PredefinedProfs == nil then
		return
	end

	ProfList = ProfList or {}

	for i = 1, 7 do
		local ProfID = (self.PredefinedProfs[i] or {}).Prof
		self:SetWidget(self.WidgetList[i], ProfID, ProfID and ProfList[ProfID] == true)
	end
end

function TeamAttriAddJobItemView:SetWidget(Widget, ProfID, IsActive)
	if Widget == nil then
		return
	end

	if nil == ProfID then
		UIUtil.SetIsVisible(Widget, false)
		return
	end

	if IsActive then
		local ProfIcon = RoleInitCfg:FindRoleInitProfIconSimple2nd(ProfID)
		if not string.isnilorempty(ProfIcon) then
			UIUtil.ImageSetBrushFromAssetPath(Widget, ProfIcon)
		end

		UIUtil.ImageSetColorAndOpacity(Widget, 1, 1, 1, 1)

	else
		local ProfIcon = RoleInitCfg:FindRoleInitProfIconSimple(ProfID)
		if not string.isnilorempty(ProfIcon) then
			UIUtil.ImageSetBrushFromAssetPath(Widget, ProfIcon)
		end

		UIUtil.ImageSetColorAndOpacity(Widget, 0.14, 0.14, 0.14, 1)
	end

	UIUtil.SetIsVisible(Widget, true)
end

return TeamAttriAddJobItemView