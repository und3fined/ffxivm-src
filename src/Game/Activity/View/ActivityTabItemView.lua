---
--- Author: fish
--- DateTime: 2023-02-02 17:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class ActivityTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconRedDot UFImage
---@field ImgSelectLight UFImage
---@field TaskIcon UToggleButton
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ActivityTabItemView = LuaClass(UIView, true)

function ActivityTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconRedDot = nil
	--self.ImgSelectLight = nil
	--self.TaskIcon = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ActivityTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ActivityTabItemView:OnInit()

end

function ActivityTabItemView:OnDestroy()

end

function ActivityTabItemView:OnShow()
	self.TextTitle:SetText(self.Params.Data.PageName)
end

function ActivityTabItemView:OnHide()

end

function ActivityTabItemView:OnRegisterUIEvent()

end

function ActivityTabItemView:OnRegisterGameEvent()

end

function ActivityTabItemView:OnRegisterBinder()

end

return ActivityTabItemView