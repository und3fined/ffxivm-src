---
--- Author: xingcaicao
--- DateTime: 2023-05-18 20:11
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")
local PWorldQuestUtil = require("Game/PWorld/Quest/PWorldQuestUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local SceneMode = ProtoCommon.SceneMode


---@class UIBinderSetSceneModeIcon : UIBinder
local UIBinderSetSceneModeIcon = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetSceneModeIcon:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetSceneModeIcon:OnValueChanged(NewValue, OldValue)
	if nil == NewValue then
		return
	end

    if NewValue == SceneMode.SceneModeNormal then
        UIUtil.SetIsVisible(self.Widget, false)
        return
    else
        UIUtil.SetIsVisible(self.Widget, true)
    end

    local Icon = PWorldQuestUtil.GetSceneModeIcon(NewValue)
    if Icon then
        UIUtil.ImageSetBrushFromAssetPath(self.Widget.ImgIcon, Icon)
    end
end

return UIBinderSetSceneModeIcon