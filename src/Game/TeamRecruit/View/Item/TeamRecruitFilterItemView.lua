--[[
Author: jususchen jususchen@tencent.com
Date: 2025-01-03 10:09:54
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-01-03 14:26:09
FilePath: \Script\Game\TeamRecruit\View\Item\TeamRecruitFilterItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE{}
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class TeamRecruitFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgFrame1 UFImage
---@field ImgFrame2 UFImage
---@field ImgSelect UFImage
---@field PanelHighlyDifficult UFCanvasPanel
---@field TextCondition UFTextBlock
---@field TextHighlyDifficult UFTextBlock
---@field TextName UFTextBlock
---@field MsgLimitWidth float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitFilterItemView = LuaClass(UIView, true)

function TeamRecruitFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgFrame1 = nil
	--self.ImgFrame2 = nil
	--self.ImgSelect = nil
	--self.PanelHighlyDifficult = nil
	--self.TextCondition = nil
	--self.TextHighlyDifficult = nil
	--self.TextName = nil
	--self.MsgLimitWidth = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitFilterItemView:OnPostInit()
	if self.TextCondition then
		UIUtil.SetIsVisible(self.TextCondition, false)
	end
end

function TeamRecruitFilterItemView:OnShow()
	local Data = self.Params and self.Params.Data or nil
	if not Data then
		return
	end

	self.TextName:SetText(Data.TaskName or "")

	local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
	local bPrettyHard = PWorldEntUtil.IsPrettyHardPWorld(Data.Task)
	UIUtil.SetIsVisible(self.PanelHighlyDifficult, bPrettyHard)
	if bPrettyHard then
		self.TextHighlyDifficult:SetText(_G.LSTR(1320232))
	end
end

function TeamRecruitFilterItemView:OnSelectChanged(bSelected)
	UIUtil.SetIsVisible(self.ImgSelect, bSelected)
end

return TeamRecruitFilterItemView