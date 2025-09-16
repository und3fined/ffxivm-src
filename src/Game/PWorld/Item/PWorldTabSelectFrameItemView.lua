--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2024-05-14 17:00:48
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2024-05-14 17:07:52
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PworldSelectionItemView = require("Game/PWorld/Entrance/View/PWorldSelectionItemView")

---@class PWorldTabSelectFrameItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelSelect UFCanvasPanel
---@field AnimCheck UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldTabSelectFrameItemView = LuaClass(PworldSelectionItemView, true)

function PWorldTabSelectFrameItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelSelect = nil
	--self.AnimCheck = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldTabSelectFrameItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end


function PWorldTabSelectFrameItemView:OnShow()

end

function PWorldTabSelectFrameItemView:OnSelectChanged(IsSelected, Index)
	self:StopAnimation(self.AnimCheck)
    self:StopAnimation(self.AnimUncheck)

	if IsSelected then
		self.IsSelected = true
		self:PlayAnimation(self.AnimCheck)
	else
		self.IsSelected = false
		self:PlayAnimation(self.AnimUncheck)
	end
end

return PWorldTabSelectFrameItemView