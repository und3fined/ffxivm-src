--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-22 16:07:49
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-22 16:43:00
FilePath: \Client\Source\Script\Game\FishNotesNew\View\Item\FishHelpInfoContentItemLView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class FishHelpInfoContentItemLView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishHelpInfoContentItemLView = LuaClass(UIView, true)

function FishHelpInfoContentItemLView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishHelpInfoContentItemLView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishHelpInfoContentItemLView:OnInit()
	self.Binders = 
	{
		{"RichTextContent", UIBinderSetText.New(self, self.RichTextContent)},
	}
end

function FishHelpInfoContentItemLView:OnDestroy()

end

function FishHelpInfoContentItemLView:OnShow()
	
end

function FishHelpInfoContentItemLView:OnHide()

end

function FishHelpInfoContentItemLView:OnRegisterUIEvent()

end

function FishHelpInfoContentItemLView:OnRegisterGameEvent()

end

function FishHelpInfoContentItemLView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data

	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return FishHelpInfoContentItemLView