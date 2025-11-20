---
--- Author: Administrator
--- DateTime: 2025-07-18 19:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")

---@class StoreFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreFilterItemView = LuaClass(UIView, true)

function StoreFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreFilterItemView:OnInit()

end

function StoreFilterItemView:OnDestroy()

end

function StoreFilterItemView:OnShow()
	self.Text:SetText(self.Params.Data.Text)
	UIUtil.SetIsVisible(self.ImgSelect, self.Params.Data.bSelect)
end

function StoreFilterItemView:OnHide()

end

function StoreFilterItemView:OnRegisterUIEvent()

end

function StoreFilterItemView:OnRegisterGameEvent()

end

function StoreFilterItemView:OnRegisterBinder()

end

function StoreFilterItemView:OnSelectChanged(bSelect)
	UIUtil.SetIsVisible(self.ImgSelect, bSelect)
	if bSelect then
		if not StoreMainVM.bIsFilter == (self.Params.Data.Index == 2) then
			StoreMainVM.bIsFilter = self.Params.Data.Index == 2
		end
	end
end

return StoreFilterItemView