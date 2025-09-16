--[[
Author: jususchen jususchen@tencent.com
Date: 2025-01-06 15:46:31
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-01-06 16:31:45
FilePath: \Script\Game\TeamRecruit\View\Item\TeamRecruitSetUpListItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class TeamRecruitSetUpListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TextSetUp UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitSetUpListItemView = LuaClass(UIView, true)

function TeamRecruitSetUpListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.TextSetUp = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitSetUpListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitSetUpListItemView:OnPostInit()
	local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
	local UIBinderSetText = require("Binder/UIBinderSetText")

	self.Binders = {
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
		{"Text", UIBinderSetText.New(self, self.TextSetUp)}
	}
end

function TeamRecruitSetUpListItemView:OnRegisterBinder()
	local VM = self.Params and self.Params.Data or nil
	if VM then
		self:RegisterBinders(VM, self.Binders)
	end
end

return TeamRecruitSetUpListItemView