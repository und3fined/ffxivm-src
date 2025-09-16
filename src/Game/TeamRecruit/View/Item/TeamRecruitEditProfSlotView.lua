---
--- Author: xingcaicao
--- DateTime: 2023-05-26 10:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")

---@class TeamRecruitEditProfSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgProf UFImage
---@field ImgProfSelected UFImage
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitEditProfSlotView = LuaClass(UIView, true)

function TeamRecruitEditProfSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgProf = nil
	--self.ImgProfSelected = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitEditProfSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitEditProfSlotView:OnInit()

end

function TeamRecruitEditProfSlotView:OnDestroy()

end

function TeamRecruitEditProfSlotView:OnShow()

end

function TeamRecruitEditProfSlotView:OnHide()

end

function TeamRecruitEditProfSlotView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtn, self.OnStateChangedEvent)
end

function TeamRecruitEditProfSlotView:OnRegisterGameEvent()

end

function TeamRecruitEditProfSlotView:OnRegisterBinder()

end

function TeamRecruitEditProfSlotView:OnStateChangedEvent(ToggleButton, State)
	if nil == self.Prof then
		return
	end

	local ProfVM = TeamRecruitVM:GetCurSelectTempEditProfVM()
	if nil == ProfVM then
		return
	end

	if UIUtil.IsToggleButtonChecked(State) then
		ProfVM:AddProf(self.Prof)
	else
		ProfVM:RemoveProf(self.Prof)
	end

	local ProfUtil = require("Game/Profession/ProfUtil")
	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	local ClassType = ProfUtil.GetProfClass(self.Prof)
	if ClassType and ClassType > 0 and ClassType < 6 then
		ProfVM:BatchRemove(TeamRecruitUtil.GetOpenNonBattleProfs())
	end

	if self.ParentView then
		self.ParentView:CheckSingleBoxAllSelectState()
	end
end

function TeamRecruitEditProfSlotView:SetProf(Prof, Icon )
	self.Prof = Prof

	if string.isnilorempty(Icon) then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgProf, Icon)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgProfSelected, Icon)
end

function TeamRecruitEditProfSlotView:SetIsChecked( IsChecked, bBroacast )
	self.ToggleBtn:SetIsChecked(IsChecked, bBroacast == true)
end

function TeamRecruitEditProfSlotView:SetParentView( View )
	self.ParentView = View 
end

return TeamRecruitEditProfSlotView