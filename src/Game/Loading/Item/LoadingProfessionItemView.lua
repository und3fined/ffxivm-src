---
--- Author: loiafeng
--- DateTime: 2024-05-09 10:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

---@class LoadingProfessionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconProfession UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoadingProfessionItemView = LuaClass(UIView, true)

function LoadingProfessionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconProfession = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingProfessionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingProfessionItemView:OnInit()

end

function LoadingProfessionItemView:OnDestroy()

end

function LoadingProfessionItemView:OnShow()
	local Data = (self.Params or {}).Data
	local ProfID = (Data or {}).ProfID
	if nil == ProfID then
		UIUtil.SetIsVisible(self, false)
		return
	end

	local ProfIcon = RoleInitCfg:FindRoleInitProfIconSimple2nd(ProfID)
	UIUtil.ImageSetBrushFromAssetPathSync(self.IconProfession, ProfIcon)
end

function LoadingProfessionItemView:OnHide()

end

function LoadingProfessionItemView:OnRegisterUIEvent()

end

function LoadingProfessionItemView:OnRegisterGameEvent()

end

function LoadingProfessionItemView:OnRegisterBinder()

end

return LoadingProfessionItemView