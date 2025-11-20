---
--- Author: yutingzhan
--- DateTime: 2025-05-27 18:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class BagTidyListChooseItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSingleBox CommSingleBoxView
---@field IconComplete UFImage
---@field ImgLoading UFImage
---@field RichText URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BagTidyListChooseItemView = LuaClass(UIView, true)

function BagTidyListChooseItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSingleBox = nil
	--self.IconComplete = nil
	--self.ImgLoading = nil
	--self.RichText = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BagTidyListChooseItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BagTidyListChooseItemView:OnInit()

end

function BagTidyListChooseItemView:OnDestroy()

end

function BagTidyListChooseItemView:OnShow()
	UIUtil.SetIsVisible(self.IconComplete, false)
	UIUtil.SetIsVisible(self.ImgLoading, false)
	UIUtil.SetIsVisible(self.CommSingleBox, true)
end

function BagTidyListChooseItemView:OnHide()

end

function BagTidyListChooseItemView:OnRegisterUIEvent()

end

function BagTidyListChooseItemView:OnRegisterGameEvent()

end

function BagTidyListChooseItemView:OnRegisterBinder()

end

return BagTidyListChooseItemView