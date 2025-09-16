---
--- Author: Administrator
--- DateTime: 2024-01-09 15:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class BattlePassPrivilegeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassPrivilegeItemView = LuaClass(UIView, true)

function BattlePassPrivilegeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassPrivilegeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassPrivilegeItemView:OnInit()
	self.Binders = {
		{ "Content", UIBinderSetText.New(self, self.TextContent) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
	}

end

function BattlePassPrivilegeItemView:OnDestroy()

end

function BattlePassPrivilegeItemView:OnShow()

end

function BattlePassPrivilegeItemView:OnHide()

end

function BattlePassPrivilegeItemView:OnRegisterUIEvent()

end

function BattlePassPrivilegeItemView:OnRegisterGameEvent()

end

function BattlePassPrivilegeItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return BattlePassPrivilegeItemView