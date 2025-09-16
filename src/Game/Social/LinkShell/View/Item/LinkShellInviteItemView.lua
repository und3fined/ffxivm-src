---
--- Author: xingcaicao
--- DateTime: 2024-07-11 11:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LinkShellInviteItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellInviteItemView = LuaClass(UIView, true)

function LinkShellInviteItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellInviteItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellInviteItemView:OnInit()

end

function LinkShellInviteItemView:OnDestroy()

end

function LinkShellInviteItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	
	local Data = Params.Data
	if nil == Data then
		return
	end

	self.TextName:SetText(Data.Name or "")
end

function LinkShellInviteItemView:OnHide()

end

function LinkShellInviteItemView:OnRegisterUIEvent()

end

function LinkShellInviteItemView:OnRegisterGameEvent()

end

function LinkShellInviteItemView:OnRegisterBinder()

end

function LinkShellInviteItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
end

return LinkShellInviteItemView