---
--- Author: zimuyi
--- DateTime: 2023-05-23 20:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class RoleProfRangeItemNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon_Range UFImage
---@field ImgBg UFImage
---@field RangeItem UFCanvasPanel
---@field RoleProfListItemNew_UIBP_C_0 RoleProfListItemNewView
---@field TableViewProf UTableView
---@field Text_Range UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RoleProfRangeItemNewView = LuaClass(UIView, true)

function RoleProfRangeItemNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon_Range = nil
	--self.ImgBg = nil
	--self.RangeItem = nil
	--self.RoleProfListItemNew_UIBP_C_0 = nil
	--self.TableViewProf = nil
	--self.Text_Range = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RoleProfRangeItemNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RoleProfListItemNew_UIBP_C_0)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RoleProfRangeItemNewView:OnInit()

end

function RoleProfRangeItemNewView:OnDestroy()

end

function RoleProfRangeItemNewView:OnShow()

end

function RoleProfRangeItemNewView:OnHide()

end

function RoleProfRangeItemNewView:OnRegisterUIEvent()

end

function RoleProfRangeItemNewView:OnRegisterGameEvent()

end

function RoleProfRangeItemNewView:OnRegisterBinder()

end

return RoleProfRangeItemNewView