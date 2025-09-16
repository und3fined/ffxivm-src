---
--- Author: xingcaicao
--- DateTime: 2023-05-25 16:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")

---@class TeamRecruitQuickInputItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNormal UFImage
---@field TextContent UFTextBlock
---@field ToggleButtonMsg UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitQuickInputItemView = LuaClass(UIView, true)

function TeamRecruitQuickInputItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNormal = nil
	--self.TextContent = nil
	--self.ToggleButtonMsg = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitQuickInputItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitQuickInputItemView:OnInit()

end

function TeamRecruitQuickInputItemView:OnDestroy()

end

function TeamRecruitQuickInputItemView:OnShow()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.TextContent:SetText(Params.Data.Text or "")

	--是否被选择
	local ID = Params.Data.ID
	local IsChecked = ID and table.contain(TeamRecruitVM.EditQuickTextIDs, ID) or false
	self.ToggleButtonMsg:SetChecked(IsChecked, false)
end

function TeamRecruitQuickInputItemView:OnHide()

end

function TeamRecruitQuickInputItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonMsg, self.OnStateChangedEvent)
end

function TeamRecruitQuickInputItemView:OnRegisterGameEvent()

end

function TeamRecruitQuickInputItemView:OnRegisterBinder()

end

function TeamRecruitQuickInputItemView:OnStateChangedEvent(ToggleButton, State)
	local Params = self.Params
	if nil == Params or nil == Params.Data or nil == Params.Data.ID then
		return
	end

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	TeamRecruitVM:UpdateEditTempQuickID(Params.Data.ID, IsChecked)
end

return TeamRecruitQuickInputItemView