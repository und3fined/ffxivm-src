--
-- Author: anypkvcai
-- Date: 2020-11-12 14:51:32
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")

local ObjetListEntryView = LuaClass(UIView, true)

function ObjetListEntryView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ObjetListEntryView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ObjetListEntryView:OnInit()
	print("ObjetListEntryView:OnInit")
end

function ObjetListEntryView:OnDestroy()

end

function ObjetListEntryView:OnShow()
	print("ObjetListEntryView:OnShow")
end

function ObjetListEntryView:OnHide()

end

function ObjetListEntryView:OnRegisterUIEvent()

end

function ObjetListEntryView:OnRegisterGameEvent()

end

function ObjetListEntryView:OnRegisterTimer()

end

function ObjetListEntryView:OnRegisterBinder()

end

function ObjetListEntryView:OnSelectChanged(bSelected)

end



-- function ObjetListEntryView:OnListItemObjectSet(ListItemObject)
-- 	print("ObjetListEntryView OnListItemObjectSet",ListItemObject.ItemIndex)

-- 	if nil ~= self.Adapter then
-- 		self.Adapter:OnListItemObjectSet(self,ListItemObject)
-- 	end
-- end


return ObjetListEntryView