---
--- Author: xingcaicao
--- DateTime: 2024-07-08 15:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FriendFindStyleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendFindStyleItemView = LuaClass(UIView, true)

function FriendFindStyleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendFindStyleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendFindStyleItemView:OnInit()

end

function FriendFindStyleItemView:OnDestroy()

end

function FriendFindStyleItemView:OnShow()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local Data = Params.Data

	-- 图标
	local IconPath = Data.Icon
	if not string.isnilorempty(IconPath) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
	end
end

function FriendFindStyleItemView:OnHide()

end

function FriendFindStyleItemView:OnRegisterUIEvent()

end

function FriendFindStyleItemView:OnRegisterGameEvent()

end

function FriendFindStyleItemView:OnRegisterBinder()

end

function FriendFindStyleItemView:GetTipsWinPosNode()
	return self.ImgIcon
end

return FriendFindStyleItemView