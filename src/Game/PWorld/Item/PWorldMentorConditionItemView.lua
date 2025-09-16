--[[
Author: jususchen jususchen@tencent.com
Date: 2024-07-29 15:31:24
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-30 11:32:37
FilePath: \Script\Game\PWorld\Item\PWorldMentorConditionItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class PWorldMentorConditionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldMentorConditionItemView = LuaClass(UIView, true)

function PWorldMentorConditionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldMentorConditionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldMentorConditionItemView:OnInit()
	self.Binders = {
		{"Name", UIBinderSetText.New(self, self.TextContent)},
	}
end

function PWorldMentorConditionItemView:OnRegisterBinder()
	if self.Params and self.Params.Data then
		self:RegisterBinders(self.Params.Data, self.Binders)
	end
end

return PWorldMentorConditionItemView