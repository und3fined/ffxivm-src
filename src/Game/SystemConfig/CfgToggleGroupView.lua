---
--- Author: chaooren
--- DateTime: 2021-10-26 09:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CfgToggleGroupView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ToggleGroupDynamic_1 UToggleGroupDynamic
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CfgToggleGroupView = LuaClass(UIView, true)

function CfgToggleGroupView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ToggleGroupDynamic_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CfgToggleGroupView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CfgToggleGroupView:OnInit()

end

function CfgToggleGroupView:OnDestroy()

end

function CfgToggleGroupView:OnShow()

end

function CfgToggleGroupView:OnHide()

end

function CfgToggleGroupView.OnToggleGroupStateChanged(_, ToggleGroup, View, ToggleButton, Index, State)
	if ToggleGroup ~= nil then
		local Count = ToggleGroup:GetNumEntries()
		for i = 0, Count - 1 do
			local TB = ToggleGroup:GetEntry(i)
			if TB then
				TB:OnToggleGroupStateChanged(Index == TB:GetIndex())
			end
		end
	end
end

function CfgToggleGroupView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupDynamic_1, CfgToggleGroupView.OnToggleGroupStateChanged, self.ToggleGroupDynamic_1)
end

function CfgToggleGroupView:OnRegisterGameEvent()

end

function CfgToggleGroupView:OnRegisterBinder()

end

return CfgToggleGroupView