---
--- Author: Administrator
--- DateTime: 2023-09-25 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommJumpWayIconItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommJumpWayIconItemView = LuaClass(UIView, true)

function CommJumpWayIconItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommJumpWayIconItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommJumpWayIconItemView:OnInit()

end

function CommJumpWayIconItemView:OnDestroy()

end

function CommJumpWayIconItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	if nil == Params.Data then
		return
	end

	self:UpdateItem(Params.Data)
end

function CommJumpWayIconItemView:OnHide()
end

function CommJumpWayIconItemView:OnRegisterUIEvent()
end

function CommJumpWayIconItemView:OnRegisterGameEvent()
end

function CommJumpWayIconItemView:OnRegisterBinder()
end

function CommJumpWayIconItemView:UpdateItem(Data)
	if nil == Data then
		return
	end

	local IconPath = Data.Icon
	if nil ~= IconPath then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
	end

	--- 禁用态
	if not Data.IsSelected then
		self.ImgIcon:SetIsEnabled(Data.IsEnabled)
	else
		self.ImgIcon:SetIsEnabled(true)
	end
end

function CommJumpWayIconItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
end

return CommJumpWayIconItemView