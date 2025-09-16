---
--- Author: xingcaicao
--- DateTime: 2024-07-16 11:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LinkShellActivitySimpleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellActivitySimpleItemView = LuaClass(UIView, true)

function LinkShellActivitySimpleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellActivitySimpleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellActivitySimpleItemView:OnInit()

end

function LinkShellActivitySimpleItemView:OnDestroy()

end

function LinkShellActivitySimpleItemView:OnShow()

end

function LinkShellActivitySimpleItemView:OnHide()

end

function LinkShellActivitySimpleItemView:OnRegisterUIEvent()

end

function LinkShellActivitySimpleItemView:OnRegisterGameEvent()

end

function LinkShellActivitySimpleItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		self.Data = nil
		return
	end

	local Data = Params.Data

	-- 图标
	local IconPath = Data.Icon
	if not string.isnilorempty(IconPath) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
	end
end

function LinkShellActivitySimpleItemView:GetTipsWinPosNode()
	return self.ImgIcon
end

return LinkShellActivitySimpleItemView