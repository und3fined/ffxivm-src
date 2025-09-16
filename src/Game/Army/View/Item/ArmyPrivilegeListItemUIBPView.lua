---
--- Author: Administrator
--- DateTime: 2024-04-29 10:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")


---@class ArmyPrivilegeListItemUIBPView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfo UFButton
---@field FCanvasPanel_All UFCanvasPanel
---@field ImgIcon UFImage
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyPrivilegeListItemUIBPView = LuaClass(UIView, true)

function ArmyPrivilegeListItemUIBPView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInfo = nil
	--self.FCanvasPanel_All = nil
	--self.ImgIcon = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyPrivilegeListItemUIBPView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyPrivilegeListItemUIBPView:OnInit()
	self.Binders = {
        {"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
        {"Permission", UIBinderSetText.New(self, self.TextContent)},
        {"IsEmpty", UIBinderSetIsVisible.New(self, self.FCanvasPanel_All, true)},
	}
end

function ArmyPrivilegeListItemUIBPView:OnDestroy()

end

function ArmyPrivilegeListItemUIBPView:OnShow()

end

function ArmyPrivilegeListItemUIBPView:OnHide()

end

function ArmyPrivilegeListItemUIBPView:OnRegisterUIEvent()

end

function ArmyPrivilegeListItemUIBPView:OnRegisterGameEvent()

end

function ArmyPrivilegeListItemUIBPView:OnRegisterBinder()
	if self.Params and self.Params.Data then
		self.PrivilegeItemVM = self.Params.Data
		self:RegisterBinders(self.PrivilegeItemVM, self.Binders)
	end
end

return ArmyPrivilegeListItemUIBPView