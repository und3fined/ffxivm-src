--[[
Author: jususchen jususchen@tencent.com
Date: 2025-01-03 14:20:04
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-01-06 15:47:46
FilePath: \Script\Game\TeamRecruit\View\Item\TeamRecruitDropBarView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local PWorldQuestUtil = require("Game/PWorld/Quest/PWorldQuestUtil")
-- local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class TeamRecruitDropBarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSetUpBG UFImage
---@field ImgSetUpIcon UFImage
---@field PanelTaskSet UFCanvasPanel
---@field PanelTaskSetUp UFCanvasPanel
---@field TableViewTasksetUp UTableView
---@field TextTaskSetUp UFTextBlock
---@field ToggleBtnArrow UToggleButton
---@field AnimToggleBtnArrowChecked UWidgetAnimation
---@field AnimToggleBtnArrowUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitDropBarView = LuaClass(UIView, true)

function TeamRecruitDropBarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSetUpBG = nil
	--self.ImgSetUpIcon = nil
	--self.PanelTaskSet = nil
	--self.PanelTaskSetUp = nil
	--self.TableViewTasksetUp = nil
	--self.TextTaskSetUp = nil
	--self.ToggleBtnArrow = nil
	--self.AnimToggleBtnArrowChecked = nil
	--self.AnimToggleBtnArrowUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitDropBarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitDropBarView:OnInit()
	self.AdpTbVDifficulites = UIAdapterTableView.CreateAdapter(self, self.TableViewTasksetUp, self.OnSelectChange, true, nil, true)
	self.BinderListDifficulty = UIBinderUpdateBindableList.New(self, self.AdpTbVDifficulites)
	self.Binders = {}
	self.bToggleShow = false
end

function TeamRecruitDropBarView:OnRegisterBinder()
	if self.Binders and self.DifficultyViewModel then
		self:RegisterBinders(self.DifficultyViewModel, self.Binders)
	end
end

function TeamRecruitDropBarView:OnShow()
	self.bToggleShow = false
	UIUtil.SetIsVisible(self.TableViewTasksetUp, self.bToggleShow)
end

function TeamRecruitDropBarView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnArrow, self.UpdateToggle)
end

function TeamRecruitDropBarView:OnSelectChange(_, ItemData)
	if ItemData then
		self:UpdateToggle()
		self:SetSelectedDifficultyText(ItemData.Text)
		self:SetSelectedDifficultyIcon(ItemData.Icon)
		_G.EventMgr:SendEvent(_G.EventID.RecruitEditDifficulty, ItemData, self)
	end
end

function TeamRecruitDropBarView:UpdateToggle()
	if self.bLockToggle then
		return
	end

	self.bToggleShow = not self.bToggleShow
	UIUtil.SetIsVisible(self.TableViewTasksetUp, true)
	self:PlayAnimation(self.bToggleShow and self.AnimToggleBtnArrowChecked or self.AnimToggleBtnArrowUnchecked)
end

function TeamRecruitDropBarView:OnEditSceneModeChanged(Mode)
	local Icon = PWorldQuestUtil.GetSceneModeIcon(Mode) or ""
	local Text = PWorldQuestUtil.GetSceneModeName(Mode) or ""
	self:SetSelectedDifficultyText(Text)
	self:SetSelectedDifficultyIcon(Icon)
end

function TeamRecruitDropBarView:ToggleCollapse()
	if self.bToggleShow then
		self:UpdateToggle()
	end
end

function TeamRecruitDropBarView:SetBinderKV(K, V)
	if self.Binders == nil then
		self.Binders = {}
	end

	for i = #self.Binders, 1, -1 do
		if self.Binders[i][1] == K then
			table.remove(self.Binders, i)
		end
	end
	
	table.insert(self.Binders, {K, self.BinderListDifficulty})
	self.DifficultyViewModel = V
end

function TeamRecruitDropBarView:SelectIndexByPredicate(Pred, bToggleUpdate)
	if not bToggleUpdate then
		self.bLockToggle = true
	end

	self.AdpTbVDifficulites:SetSelectedByPredicate(Pred)

	self.bLockToggle = nil
end

function TeamRecruitDropBarView:SetSelectedDifficultyText(Text)
	self.TextTaskSetUp:SetText(Text)
end

function TeamRecruitDropBarView:SetSelectedDifficultyIcon(Icon)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgSetUpIcon, Icon)
end

return TeamRecruitDropBarView