---
--- Author: mingyyzhang
--- DateTime: 2025-06-16 14:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class HouseInfoTagItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon UFImage
---@field TextTag UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoTagItemView = LuaClass(UIView, true)

function HouseInfoTagItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon = nil
	--self.TextTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoTagItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoTagItemView:OnInit()

end

function HouseInfoTagItemView:OnDestroy()

end

function HouseInfoTagItemView:OnShow()
    local Params = self.Params
    if Params == nil then
        return
    end
    local Data = Params.Data
    if Data == nil then
        return
    end
    UIUtil.ImageSetBrushFromAssetPath(self.Icon, Data.IconPath)
    self.TextTag:SetText(LSTR(Data.TagText))
end

function HouseInfoTagItemView:OnHide()

end

function HouseInfoTagItemView:OnRegisterUIEvent()

end

function HouseInfoTagItemView:OnRegisterGameEvent()

end

function HouseInfoTagItemView:OnRegisterBinder()

end

return HouseInfoTagItemView