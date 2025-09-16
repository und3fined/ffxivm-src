---
--- Author: Alex
--- DateTime: 2023-05-29 15:24
--- Description: 设置道具图标（物品和积分）
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ScoreMgr = require("Game/Score/ScoreMgr")

---@class UIBinderSetIconItemAndScore : UIBinder
local UIBinderSetIconItemAndScore = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetIconItemAndScore:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetIconItemAndScore:OnValueChanged(NewValue, OldValue)
    if nil == self.Widget then
		return
	end

    if NewValue == OldValue then
        return
    end

    local Cfg = ItemCfg:FindCfgByKey(NewValue)
	if nil ~= Cfg then
        local Path = UIUtil.GetIconPath(Cfg.IconID)
        if nil == Path then
            return
        end
        UIUtil.ImageSetBrushFromAssetPath(self.Widget, Path)
        return
	end

    local IconPath = ScoreMgr:GetScoreIconName(NewValue)
    if nil == IconPath then
        return
    end
    UIUtil.ImageSetBrushFromAssetPath(self.Widget, IconPath)
end

return UIBinderSetIconItemAndScore