---
--- Author: anypkvcai
--- DateTime: 2021-03-02 10:07
--- Description:
---
---
local IE_Pressed = _G.UE.EInputEvent.IE_Pressed
local IE_Released = _G.UE.EInputEvent.IE_Released

local InputCallback = require("Game/Input/InputCallback")

local InputConfig = {}

InputConfig.InputActionConfig = {
	{ Action = "ShowGMUI", Event = IE_Pressed, Callback = InputCallback.OnShowGMUI },
	{ Action = "HideUI", Event = IE_Released, Callback = InputCallback.OnHideUI },
	{ Action = "HidePreviewUI", Event = IE_Released, Callback = InputCallback.OnHideUI },
	{ Action = "HandleDebugTool", Event = IE_Released, Callback = InputCallback.OnShowDebugTool},
	{ Action = "CastSkill0", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = 0 },
	{ Action = "CastSkill0", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 0 },
	{ Action = "CastSkill1", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = 1 },
	{ Action = "CastSkill1", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 1 },
	{ Action = "CastSkill2", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = 2 },
	{ Action = "CastSkill2", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 2 },
	{ Action = "CastSkill3", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = 3 },
	{ Action = "CastSkill3", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 3 },
	{ Action = "CastSkill4", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = 4 },
	{ Action = "CastSkill4", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 4 },
	{ Action = "CastSkill5", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = 5 },
	{ Action = "CastSkill5", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 5 },
	{ Action = "CastSkill6", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = 6 },
	{ Action = "CastSkill6", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 6 },
	{ Action = "CastSkill7", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = 7 },
	{ Action = "CastSkill7", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 7 },
	{ Action = "CastSkill8", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = 8 },
	{ Action = "CastSkill8", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 8 },
	{ Action = "CastSkill9", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = 9 },
	{ Action = "CastSkill9", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 9 },
	{ Action = "CastSkill10", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = 10 },
	{ Action = "CastSkill10", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 10 },
	{ Action = "HandleB", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "B" },
	{ Action = "HandleB", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "B" },
	{ Action = "HandleA", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "A" },
	{ Action = "HandleA", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "A" },
	{ Action = "HandleX", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "X" },
	{ Action = "HandleX", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "X" },
	{ Action = "HandleY", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "Y" },
	{ Action = "HandleY", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "Y" },
	{ Action = "HandleUp", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "U" },
	{ Action = "HandleUp", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "U" },
	{ Action = "HandleDown", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "D" },
	{ Action = "HandleDown", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "D" },
	{ Action = "HandleLeft", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "L" },
	{ Action = "HandleLeft", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "L" },
	{ Action = "HandleRight", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "R" },
	{ Action = "HandleRight", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "R" },
	{ Action = "HandleLB", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "LB" },
	{ Action = "HandleLB", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "LB" },
	{ Action = "HandleRB", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "RB" },
	{ Action = "HandleRB", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "RB" },
	{ Action = "HandleLT", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "LT" },
	{ Action = "HandleLT", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "LT" },
	{ Action = "HandleRT", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "RT" },
	{ Action = "HandleRT", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "RT" },
	{ Action = "HandleSpecialRight", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "SR" },
	{ Action = "HandleSpecialRight", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "SR" },
	{ Action = "HandleSpecialLeft", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params = "SL" },
	{ Action = "HandleSpecialLeft", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params = "SL" },
}

InputConfig.InputAxisConfig = {

}


function InputConfig:FindActionConfig(Action, Event)
	for _, v in pairs(InputConfig.InputActionConfig) do
		if v.Action == Action and v.Event == Event then
			return v
		end
	end
end


return InputConfig