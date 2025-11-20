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
	{ Action = "ShowGMUI", Event = IE_Pressed, Callback = InputCallback.OnShowGMUI  },
	{ Action = "HideUI", Event = IE_Released, Callback = InputCallback.OnHideUI  },
	{ Action = "HidePreviewUI", Event = IE_Released, Callback = InputCallback.OnHideUI  },
	{ Action = "HandleDebugTool", Event = IE_Released, Callback = InputCallback.OnShowDebugTool },
	--{ Action = "SimulatedSkill0", Event = IE_Pressed, Callback = InputCallback.SimulatedTouchStart, Params = 0 },
	{ Action = "SimulatedSkill1", Event = IE_Pressed, Callback = InputCallback.SimulatedTouchStart, Params = 0 },
	{ Action = "SimulatedSkill1", Event = IE_Released, Callback = InputCallback.SimulatedTouchEnd, Params = 0 },
	--{ Action = "CastSkill0", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = 0 },
	{ Action = "CastSkill0", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = { Index = 0  , bSimulatedClick = false }},
	{ Action = "CastSkill0", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = { Index = 0  , bSimulatedClick = false }},
	{ Action = "CastSkill1", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params = { Index = 1  , bSimulatedClick = false } },
	{ Action = "CastSkill1", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params = { Index = 1  , bSimulatedClick = false } },
	{ Action = "CastSkill2", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params  = { Index =  2  , bSimulatedClick = false } },
	{ Action = "CastSkill2", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params  = { Index =  2  , bSimulatedClick = false } },
	{ Action = "CastSkill3", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params  = { Index =  3  , bSimulatedClick = false } },
	{ Action = "CastSkill3", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params  = { Index =  3  , bSimulatedClick = false } },
	{ Action = "CastSkill4", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params  = { Index =  4  , bSimulatedClick = false } },
	{ Action = "CastSkill4", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params  = { Index =  4  , bSimulatedClick = false } },
	{ Action = "CastSkill5", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params  = { Index =  5  , bSimulatedClick = false } },
	{ Action = "CastSkill5", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params  = { Index =  5  , bSimulatedClick = false } },
	{ Action = "CastSkill6", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params  = { Index =  6  , bSimulatedClick = false } },
	{ Action = "CastSkill6", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params  = { Index =  6  , bSimulatedClick = false } },
	{ Action = "CastSkill7", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params  = { Index =  7  , bSimulatedClick = false } },
	{ Action = "CastSkill7", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params  = { Index =  7  , bSimulatedClick = false } },
	{ Action = "CastSkill8", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params  = { Index =  8  , bSimulatedClick = false } },
	{ Action = "CastSkill8", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params  = { Index =  8  , bSimulatedClick = false } },
	{ Action = "CastSkill9", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params  = { Index =  9  , bSimulatedClick = false } },
	{ Action = "CastSkill9", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params  = { Index =  9  , bSimulatedClick = false } },
	{ Action = "CastSkill10", Event = IE_Pressed, Callback = InputCallback.OnSkillPressed, Params  = { Index =  10  , bSimulatedClick = false } },
	{ Action = "CastSkill10", Event = IE_Released, Callback = InputCallback.OnSkillReleased, Params  = { Index =  10  , bSimulatedClick = false } },
	{ Action = "HandleB", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleB"  , bSimulatedClick = false } },
	{ Action = "HandleB", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleB"  , bSimulatedClick = false } },
	{ Action = "HandleA", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleA"  , bSimulatedClick = false } },
	{ Action = "HandleA", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleA"  , bSimulatedClick = false } },
	{ Action = "HandleX", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleX"  , bSimulatedClick = false } },
	{ Action = "HandleX", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleX"  , bSimulatedClick = false } },
	{ Action = "HandleY", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleY"  , bSimulatedClick = false } },
	{ Action = "HandleY", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleY"  , bSimulatedClick = false } },
	{ Action = "HandleUp", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleUp"  , bSimulatedClick = false } },
	{ Action = "HandleUp", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleUp"  , bSimulatedClick = false } },
	{ Action = "HandleDown", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleDown"  , bSimulatedClick = false } },
	{ Action = "HandleDown", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleDown"  , bSimulatedClick = false } },
	{ Action = "HandleLeft", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLeft"  , bSimulatedClick = false } },
	{ Action = "HandleLeft", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleLeft"  , bSimulatedClick = false } },
	{ Action = "HandleRight", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRight"  , bSimulatedClick = false } },
	{ Action = "HandleRight", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleRight"  , bSimulatedClick = false } },
	{ Action = "HandleLB", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLB"  , bSimulatedClick = false } },
	{ Action = "HandleLB", Event = IE_Released, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLB"  , bSimulatedClick = false } },
	{ Action = "HandleRB", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRB"  , bSimulatedClick = false } },
	{ Action = "HandleRB", Event = IE_Released, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRB"  , bSimulatedClick = false } },
	{ Action = "HandleLT", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLT"  , bSimulatedClick = false } },
	{ Action = "HandleLT", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleLT"  , bSimulatedClick = false } },
	{ Action = "HandleRT", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRT"  , bSimulatedClick = false } },
	{ Action = "HandleRT", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleRT"  , bSimulatedClick = false } },
	{ Action = "HandleSpecialRight", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleSpecialRight"  , bSimulatedClick = false } },
	{ Action = "HandleSpecialRight", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleSpecialRight"  , bSimulatedClick = false } },
	{ Action = "HandleSpecialLeft", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleSpecialLeft"  , bSimulatedClick = false } },
	{ Action = "HandleSpecialLeft", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleSpecialLeft"  , bSimulatedClick = false } },
	{ Action = "HandleLTRight", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLTRight"  , bSimulatedClick = true } },
	{ Action = "HandleLTRight", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleLTRight"  , bSimulatedClick = true } },
	{ Action = "HandleLTUp", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLTUp"  , bSimulatedClick = true } },
	{ Action = "HandleLTUp", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleLTUp"  , bSimulatedClick = true } },
	{ Action = "HandleLTDown", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLTDown"  , bSimulatedClick = true } },
	{ Action = "HandleLTDown", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleLTDown"  , bSimulatedClick = true } },
	{ Action = "HandleLTLeft", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLTLeft"  , bSimulatedClick = true } },
	{ Action = "HandleLTLeft", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleLTLeft"  , bSimulatedClick = true } },
	{ Action = "HandleLTB", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLTB"  , bSimulatedClick = true } },
	{ Action = "HandleLTB", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleLTB"  , bSimulatedClick = true } },
	{ Action = "HandleLTY", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLTY"  , bSimulatedClick = true } },
	{ Action = "HandleLTY", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleLTY"  , bSimulatedClick = true } },
	{ Action = "HandleLTA", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLTA"  , bSimulatedClick = true } },
	{ Action = "HandleLTA", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleLTA"  , bSimulatedClick = true } },
	{ Action = "HandleLTX", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleLTX"  , bSimulatedClick = true } },
	{ Action = "HandleLTX", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleLTX"  , bSimulatedClick = true } },
	{ Action = "HandleRTRight", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRTRight"  , bSimulatedClick = true } },
	{ Action = "HandleRTRight", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleRTRight"  , bSimulatedClick = true } },
	{ Action = "HandleRTUp", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRTUp"  , bSimulatedClick = true } },
	{ Action = "HandleRTUp", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleRTUp"  , bSimulatedClick = true } },
	{ Action = "HandleRTDown", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRTDown"  , bSimulatedClick = true } },
	{ Action = "HandleRTDown", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleRTDown"  , bSimulatedClick = true } },
	{ Action = "HandleRTLeft", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRTLeft"  , bSimulatedClick = true } },
	{ Action = "HandleRTLeft", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleRTLeft"  , bSimulatedClick = true } },
	{ Action = "HandleRTB", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRTB"  , bSimulatedClick = true } },
	{ Action = "HandleRTB", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleRTB"  , bSimulatedClick = true } },
	{ Action = "HandleRTY", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRTY"  , bSimulatedClick = true } },
	{ Action = "HandleRTY", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleRTY"  , bSimulatedClick = true } },
	{ Action = "HandleRTA", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRTA"  , bSimulatedClick = true } },
	{ Action = "HandleRTA", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleRTA"  , bSimulatedClick = true } },
	{ Action = "HandleRTX", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRTX"  , bSimulatedClick = true } },
	{ Action = "HandleRTX", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleRTX"  , bSimulatedClick = true } },
	{ Action = "HandleRS", Event = IE_Pressed, Callback = InputCallback.OnHandlePressed, Params  = { BtnName =  "HandleRS"  , bSimulatedClick = false } },
	{ Action = "HandleRS", Event = IE_Released, Callback = InputCallback.OnHandleReleased, Params  = { BtnName =  "HandleRS"  , bSimulatedClick = false } },
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