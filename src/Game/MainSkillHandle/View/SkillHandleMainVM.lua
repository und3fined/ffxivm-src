

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local HandleTypeDefine = SettingsHandleDefine.HandleType
local IE_Pressed = _G.UE.EInputEvent.IE_Pressed

---@class SkillHandleMainVM : UIViewModel
local SkillHandleMainVM = LuaClass(UIViewModel)

function SkillHandleMainVM:Ctor()
	self.IsSwitchPanelVisible = false
    self.IsTopHighLight = false
    self.IsBottomHighLight = false
    self.LTPress = false
    self.RTPress = false
end

function SkillHandleMainVM:OnInit()
end

function SkillHandleMainVM:OnBegin()
end

function SkillHandleMainVM:OnEnd()
end

function SkillHandleMainVM:OnShutdown()
end

function SkillHandleMainVM:SetHighLight(HandleType, EventType)
    local bHighlight = false
    if EventType == IE_Pressed then
       bHighlight = true
    end
    if HandleType == HandleTypeDefine.HandleRT then
        self.RTPress = bHighlight
    else
        self.LTPress = bHighlight
    end
    if self.RTPress then
        self.IsTopHighLight = false
        self.IsBottomHighLight = true
    elseif self.LTPress and self.RTPress == false then
        self.IsTopHighLight = true
        self.IsBottomHighLight = false
    elseif self.RTPress == false and self.LTPress == false then
        self.IsTopHighLight = false
        self.IsBottomHighLight = false
    end
end


return SkillHandleMainVM