local EventID = require("Define/EventID")
local InputCallback = require("Game/Input/InputCallback")
local LSTR = _G.LSTR

local SaveKeyStart = 19000
local ProfSaveKeyStart = 20000

local HandleType = {
    HandleLT = 1,
    HandleRT = 2,
    HandleLS = 3,
    HandleRS = 4,
    HandleLB = 5,
    HandleRB = 6,
}

local HandleCombinationType = {
    ["HandleRTB"] = 0,
	["HandleRTY"] = 1,
	["HandleRTA"] = 2,
	["HandleRTX"] = 3,
	["HandleRTRight"] = 4,
	["HandleRTUp"] = 5,
	["HandleRTDown"] = 6,
	["HandleRTLeft"] = 7,
	["HandleLTB"] = 8,
	["HandleLTY"] = 9,
	["HandleLTA"] = 10,
	["HandleLTX"] = 11,
	["HandleLTRight"] = 12,
	["HandleLTUp"] = 13,
	["HandleLTDown"] = 14,
	["HandleLTLeft"] = 15,
}

local HandleSkillType ={
    AbleSkill1 = 1,
    AbleSkill2 = 2,
    AbleSkill3 = 3,
    AbleSkill4 = 4,
    AbleSkill5 = 5,
    TriggerSkill1 = 6,
    TriggerSkill2 = 7,
    GuardSkill = 8, --护身技
    FightSkill = 9, --奋战技
    AbleExtend = 10, --极限技
    FunctionSkill = 11, --职能技
    SpectrumSkill1 = 12, --量谱技能
    SpectrumSkill2 = 13, --量谱技能
    SpectrumSkill3 = 14,  --量谱技能
    PVPcommonskill = 15,
    Empty = 16,
}

local HandleCombatType = {
    NormalSkill = 1,
    Jump = 2,
    SpeedSkill = 3,
    Empty = 4,
}

local HandleFunctionType = {
    ChangeTarget = 1,
    ChatSystem = 2,
    EmotionSystem = 3,
    Empty = 4,
}

local HandleMainType = {
    CombatType = 1,
    FunctionType = 2,
    SkillType = 3,
    Other = 4,
}

local HandleInputActionConfig= {
    HandleB = {Index = 1, MainType = HandleMainType.CombatType, Text = "B"},
    HandleY = {Index = 2, MainType = HandleMainType.CombatType, Text = "Y"},
    HandleA = {Index = 3, MainType = HandleMainType.CombatType, Text = "A"},
    HandleX = {Index = 4, MainType = HandleMainType.CombatType, Text = "X"},
    HandleRight = {Index = 5, MainType = HandleMainType.FunctionType, 
    Interactive = "InteractiveRight", Text = LSTR(110095)},
    HandleUp = {Index = 6, MainType = HandleMainType.FunctionType, 
    Interactive = "InteractiveUp", Text = LSTR(110092)},
    HandleDown = {Index = 7, MainType = HandleMainType.FunctionType, 
    Interactive = "InteractiveDown", Text = LSTR(110093)},
    HandleLeft = {Index = 8, MainType = HandleMainType.FunctionType, 
    Interactive = "InteractiveLeft", Text = LSTR(110094)},
    HandleRTB = {Index = 9, MainType = HandleMainType.SkillType},
    HandleRTY = {Index = 10, MainType = HandleMainType.SkillType},
    HandleRTA = {Index = 11, MainType = HandleMainType.SkillType},
    HandleRTX = {Index = 12, MainType = HandleMainType.SkillType},
    HandleRTRight = {Index = 13, MainType = HandleMainType.SkillType},
    HandleRTUp = {Index = 14, MainType = HandleMainType.SkillType},
    HandleRTDown = {Index = 15, MainType = HandleMainType.SkillType},
    HandleRTLeft = {Index = 16, MainType = HandleMainType.SkillType},
    HandleLTB = {Index = 17, MainType = HandleMainType.SkillType},
    HandleLTY = {Index = 18, MainType = HandleMainType.SkillType},
    HandleLTA = {Index = 19, MainType = HandleMainType.SkillType},
    HandleLTX = {Index = 20, MainType = HandleMainType.SkillType},
    HandleLTRight = {Index = 21, MainType = HandleMainType.SkillType},
    HandleLTUp = {Index = 22, MainType = HandleMainType.SkillType},
    HandleLTDown = {Index = 23, MainType = HandleMainType.SkillType},
    HandleLTLeft = {Index = 24, MainType = HandleMainType.SkillType},
    HandleLB = {Index = 25, MainType = HandleMainType.Other},
    HandleRB = {Index = 26, MainType = HandleMainType.Other},
    HandleR = {Index = 27, MainType = HandleMainType.Other},
    HandleRS = {Index = 28, MainType = HandleMainType.Other},
    HandleL = {Index = 29, MainType = HandleMainType.Other},
    HandleSpecialLeft = {Index = 30, MainType = HandleMainType.Other},
    HandleSpecialRight = {Index = 31, MainType = HandleMainType.Other},
    HandleLT = {Index = 32, MainType = HandleMainType.Other},
    HandleRT = {Index = 33, MainType = HandleMainType.Other},
}


local HandleCombatText = {
    [HandleCombatType.NormalSkill] = LSTR(110050),
    [HandleCombatType.Jump] = LSTR(110051),
    [HandleCombatType.SpeedSkill] = LSTR(110052),
    [HandleCombatType.Empty] = LSTR(110054),
}

local HandleFunctionText = {
    [HandleFunctionType.ChangeTarget] = LSTR(110053),
    [HandleFunctionType.ChatSystem] = LSTR(110088),
    [HandleFunctionType.EmotionSystem] = LSTR(110089),
    [HandleFunctionType.Empty] = LSTR(110054),
}


local HandleSkillText = {
    [HandleSkillType.AbleSkill1] = LSTR(110055),
    [HandleSkillType.AbleSkill2] = LSTR(110056),
    [HandleSkillType.AbleSkill3] = LSTR(110057),
    [HandleSkillType.AbleSkill4] = LSTR(110058),
    [HandleSkillType.AbleSkill5] = LSTR(110059),
    [HandleSkillType.TriggerSkill1] = LSTR(110060),
    [HandleSkillType.TriggerSkill2] = LSTR(110061),
    [HandleSkillType.AbleExtend] = LSTR(110062),
    [HandleSkillType.FunctionSkill] = LSTR(110063),
    [HandleSkillType.GuardSkill] = LSTR(110064),
    [HandleSkillType.FightSkill] = LSTR(110065),
    [HandleSkillType.SpectrumSkill1] = LSTR(110096),
    [HandleSkillType.SpectrumSkill2] = LSTR(110097),
    [HandleSkillType.SpectrumSkill3] = LSTR(110098),
    [HandleSkillType.PVPcommonskill] = LSTR(110099),
    [HandleSkillType.Empty] = LSTR(110054),
}

local HandleOtherText = {
    [HandleInputActionConfig.HandleLB.Index] = LSTR(110087),
    [HandleInputActionConfig.HandleRB.Index] = LSTR(110054),
    [HandleInputActionConfig.HandleR.Index] = LSTR(110075),
    [HandleInputActionConfig.HandleRS.Index] = LSTR(110076),
    [HandleInputActionConfig.HandleL.Index] = LSTR(110074),
    [HandleInputActionConfig.HandleSpecialLeft.Index] = LSTR(110090),
    [HandleInputActionConfig.HandleSpecialRight.Index] = LSTR(110091),
}

local HandleOtherActionConfig ={
    ["HandleLB"] = {Index = 1, Params = {"GamePadCursor"}},
    ["HandleRB"] = {Index = 2, Params = {"SkillCancel", HandleType.HandleRB}},
    ["HandleR"] = {Index = 3, Params = {"ChangeView"}},
    ["HandleRS"] = {Index = 4, Params = {"SwitchSkillPanel"}},
    ["HandleL"] = {Index = 5, Params = {"MajorMove"}},
    ["HandleSpecialLeft"] = {Index = 6, Params = {"OpenBag"}},
    ["HandleSpecialRight"] = {Index = 7, Params = {"OpenMenu"}},
    ["HandleLT"] = {Params = {"SkillHighLight", HandleType.HandleLT}},
    ["HandleRT"] = {Params = {"SkillHighLight", HandleType.HandleRT}},
}

local HandleCustomActionType = {
    NormalSkill = 101,
    Jump = 102,
    SpeedSkill = 103,
    CombatEmpty = 104,
    ChangeTarget = 201,
    ChatSystem = 202,
    EmotionSystem = 203,
    FunctionEmpty = 204,
    AbleSkill1 = 301,
    AbleSkill2 = 302,
    AbleSkill3 = 303,
    AbleSkill4 = 304,
    AbleSkill5 = 305,
    TriggerSkill1 = 306,
    TriggerSkill2 = 307,
    GuardSkill = 308, --护身技
    FightSkill = 309, --奋战技
    AbleExtend = 310, --极限技
    FunctionSkill = 311, --职能技
    SpectrumSkill1 = 312, --量谱技能
    SpectrumSkill2 = 313, --量谱技能
    SpectrumSkill3 = 314,
    PVPcommonskill = 315,
    SkillEmpty = 316,
}

local HandleCustomActionConfig = {
    [HandleCustomActionType.NormalSkill] =  {Index = 1, MainType = HandleMainType.CombatType,
                                            SubType = HandleCombatType.NormalSkill,Params = {"CastSkill", 0},
                                            Interactive = "GamePadEnter"},
    [HandleCustomActionType.Jump] =         {Index = 2, MainType = HandleMainType.CombatType,
                                            SubType = HandleCombatType.Jump, Params = {"Jump"},
                                            Interactive = "GamePadSkip"},
    [HandleCustomActionType.SpeedSkill] =   {Index = 3, MainType = HandleMainType.CombatType,
                                            SubType = HandleCombatType.SpeedSkill, Params = {"SpeedSkill"},
                                            Interactive = "GamePadCancel"},
    [HandleCustomActionType.ChangeTarget] = {Index = 4, MainType = HandleMainType.FunctionType,
                                            SubType = HandleFunctionType.ChangeTarget, Params = {"SwitchTarget"},
                                             Interactive = "InteractiveSwitchTarget"},
    [HandleCustomActionType.CombatEmpty] =  {Index = 5, MainType = HandleMainType.CombatType,
                                            SubType = HandleCombatType.Empty, Params = {}},
    --SkillType
    [HandleCustomActionType.AbleSkill1] =   {Index = 6, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.AbleSkill1, Params = {"CastSkill", 1}},
    [HandleCustomActionType.AbleSkill2] =   {Index = 7, MainType = HandleMainType.SkillType,
                                             SubType = HandleSkillType.AbleSkill2, Params = {"CastSkill", 2}},
    [HandleCustomActionType.AbleSkill3] =   {Index = 8, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.AbleSkill3, Params = {"CastSkill", 3}},
    [HandleCustomActionType.AbleSkill4] =   {Index = 9, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.AbleSkill4, Params = {"CastSkill", 4}},
    [HandleCustomActionType.AbleSkill5] =   {Index = 10, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.AbleSkill5, Params = {"CastSkill", 5}},
    [HandleCustomActionType.TriggerSkill1] = {Index = 11, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.TriggerSkill1, Params = {"CastSkill", 6}},
    [HandleCustomActionType.TriggerSkill2] = {Index = 12, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.TriggerSkill2, Params = {"CastSkill", 7}},
    [HandleCustomActionType.GuardSkill] =   {Index = 13, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.GuardSkill, Params = {"CastSkill", 8}},
    [HandleCustomActionType.FightSkill] =   {Index = 14, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.FightSkill, Params = {"CastSkill", 9}},
    [HandleCustomActionType.AbleExtend] =   {Index = 15, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.AbleExtend, Params = {"CastSkill", 15}},
    [HandleCustomActionType.FunctionSkill] = {Index = 16, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.FunctionSkill, Params = {"CastSkill", 11}},
    [HandleCustomActionType.SkillEmpty] =   {Index = 17, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.Empty, Params = {}},
    [HandleCustomActionType.FunctionEmpty] =  {Index = 18, MainType = HandleMainType.FunctionType,
                                            SubType = HandleFunctionType.Empty, Params = {}},
    [HandleCustomActionType.ChatSystem] =  {Index = 19, MainType = HandleMainType.FunctionType,
                                            SubType = HandleFunctionType.ChatSystem, Params = {"OpenChatSystem"}},                                       
    [HandleCustomActionType.EmotionSystem] =  {Index = 20, MainType = HandleMainType.FunctionType,
                                            SubType = HandleFunctionType.EmotionSystem, Params = {"OpenEmotionSystem"}},
    [HandleCustomActionType.SpectrumSkill1] =  {Index = 21, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.SpectrumSkill1, Params = {"CastSkill", 19}},
    [HandleCustomActionType.SpectrumSkill2] =  {Index = 22, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.SpectrumSkill2, Params = {"CastSkill", 20}},
    [HandleCustomActionType.SpectrumSkill3] =  {Index = 23, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.SpectrumSkill3, Params = {"CastSkill", 21}},
    [HandleCustomActionType.PVPcommonskill] =  {Index = 24, MainType = HandleMainType.SkillType,
                                            SubType = HandleSkillType.PVPcommonskill, Params = {"CastSkill", 13}},
    
}

local HandleCusActionFunc = {
    ["Jump"] = EventID.GamePadJump,
    ["GamePadEnter"] = EventID.GamePadEnter,
    ["GamePadCancel"] = EventID.GamePadCancel,
    ["GamePadSkip"] = EventID.GamePadSkip,
    ["InteractiveSwitchTarget"] = EventID.GamepadDPadSwitchInteractive,
    ["InteractiveUp"] = EventID.GamepadDPadUp,
    ["InteractiveDown"] = EventID.GamepadDPadDown,
    ["OpenChatSystem"] = EventID.GamePadFunction,
    ["OpenEmotionSystem"] = EventID.GamePadFunction,
    ["OpenBag"] = EventID.GamePadFunction,
    ["OpenMenu"] = EventID.GamePadFunction,
}
local IsCurrentFocusInputBox <const> = _G.UE.UUIUtil.IsCurrentFocusInputBox
local IE_Pressed = _G.UE.EInputEvent.IE_Pressed
local IE_Released = _G.UE.EInputEvent.IE_Released

HandleCusActionFunc["CastSkill"] = function(CusActionParam, EventType)
    if not IsCurrentFocusInputBox() then
        if EventType == IE_Released then
		    InputCallback.OnSkillReleased( CusActionParam)
	    elseif EventType == IE_Pressed then
		    InputCallback.OnSkillPressed(CusActionParam)
	    end
    end
end
-- HandleCusActionFunc["SwitchOpenCloseVirtualCursor"] = function(CusActionParam, EventType)
--     if not IsCurrentFocusInputBox() then
--         if EventType == IE_Released then
-- 		    _G.EventMgr:SendCppEvent(EventID.SwitchOpenCloseVirtualCursor)
-- 	    end
--     end
-- end

HandleCusActionFunc["AbleExtend"] = function(CusActionParam, EventType)
    if not IsCurrentFocusInputBox() then
        if EventType == IE_Released then
		    _G.EventMgr:SendEvent(EventID.GamePadAbleExtend)
	    end
    end
end

HandleCusActionFunc["SwitchTarget"] = function(_, EventType)
	if EventType == IE_Released then
		_G.EventMgr:SendEvent(EventID.GamePadSwitchTarget)
	end
end

HandleCusActionFunc["SwitchSkillPanel"] = function(_, EventType)
    if EventType == IE_Released then
		_G.EventMgr:SendEvent(EventID.GamePadSwitchSkillPanel)
	end
end

HandleCusActionFunc["SkillHighLight"] = function(Params, EventType)
    _G.EventMgr:SendEvent(EventID.GamePadSkillHighLight, Params.Index, EventType)
end

HandleCusActionFunc["SkillCancel"] = function(Params, EventType)
    if EventType == IE_Pressed then
		_G.EventMgr:SendEvent(EventID.GamePadSkillCancel, Params.Index)
	end
end

HandleCusActionFunc["SpeedSkill"] = function(Params, EventType)
    if _G.SkillHandleMgr:GetIsInFishingState() then
        _G.EventMgr:SendEvent(EventID.GamePadFishingSit, EventType)
    else
        Params.Index = 10
        HandleCusActionFunc["CastSkill"](Params, EventType)
    end
end

local HandleDefaultCustomAction ={
    --CommonType
    ["HandleB"] = HandleCustomActionType.NormalSkill,
    ["HandleY"] = HandleCustomActionType.Jump,
    ["HandleA"] = HandleCustomActionType.SpeedSkill,
    ["HandleX"] = HandleCustomActionType.CombatEmpty,
    ["HandleRight"] = HandleCustomActionType.ChangeTarget,
    ["HandleUp"] = HandleCustomActionType.FunctionEmpty,
    ["HandleDown"] = HandleCustomActionType.ChatSystem,
    ["HandleLeft"] = HandleCustomActionType.EmotionSystem,
    --SkillType
    ["HandleRTB"] = HandleCustomActionType.AbleSkill1,
    ["HandleRTY"] = HandleCustomActionType.AbleSkill2,
    ["HandleRTA"] = HandleCustomActionType.AbleSkill3,
    ["HandleRTX"] = HandleCustomActionType.AbleSkill4,
    ["HandleLTB"] = HandleCustomActionType.TriggerSkill1,
    ["HandleLTY"] = HandleCustomActionType.TriggerSkill2,
    ["HandleLTA"] = HandleCustomActionType.AbleExtend,
    ["HandleLTX"] = HandleCustomActionType.SkillEmpty,
    ["HandleRTRight"] = HandleCustomActionType.AbleSkill5,
    ["HandleRTUp"] = HandleCustomActionType.FunctionSkill,
    ["HandleRTDown"] = HandleCustomActionType.GuardSkill,
    ["HandleRTLeft"] = HandleCustomActionType.FightSkill,
    ["HandleLTRight"] = HandleCustomActionType.PVPcommonskill,
    ["HandleLTUp"] = HandleCustomActionType.SpectrumSkill1,
    ["HandleLTDown"] = HandleCustomActionType.SpectrumSkill3,
    ["HandleLTLeft"] = HandleCustomActionType.SpectrumSkill2,
}

local HandleModeType = {
    Off = false,
    On = true,
}

local InputActionType = {
    Handle = 1,
    Other = 2,
}
local HandleVirtualCursorWidget = "WidgetBlueprint'/Game/UI/BP/MainSkillHandle/SkillHandleCursorPanel_UIBP.SkillHandleCursorPanel_UIBP_C'"

local HandleActionPriority = {
    Cursor = 100,
    CommonUI = 99,
    InteractiveCustom = 98,
    Interactive = 97,
    NpcDialogCustom = 96,
    NpcDialog = 95,
    LimitCast = 10,
}
local FVector2D = _G.UE.FVector2D
local SkillHandleSkillPositionMap <const> = {
		["HandleRTB"] = FVector2D(-161.0, -235.0),
		["HandleRTY"] = FVector2D(-264.0, -307.0),
		["HandleRTA"] = FVector2D(-264.0, -162.0),
		["HandleRTX"] = FVector2D(-366.0, -235.0),
		["HandleRTRight"] = FVector2D(-517.0, -235.0),
		["HandleRTUp"] = FVector2D(-620.0, -307.0),
		["HandleRTDown"] = FVector2D(-620.0, -162.0),
		["HandleRTLeft"] = FVector2D(-722.0, -235.0),
		["HandleLTB"] = FVector2D(-161.0, -510.0),
		["HandleLTY"] = FVector2D(-264.0, -582.0),
		["HandleLTA"] = FVector2D(-264.0, -437.0),
		["HandleLTX"] = FVector2D(-366.0, -510.0),
		["HandleLTRight"] = FVector2D(-517.0, -510.0),
		["HandleLTUp"] = FVector2D(-620.0, -582.0),
		["HandleLTDown"] = FVector2D(-620.0, -437.0),
		["HandleLTLeft"] = FVector2D(-722.0, -510.0),
}

local InValidInputAction = "Null"

local SettingsHandleDefine = {
    --Input相关
    HandleInputActionConfig = HandleInputActionConfig,
    SaveKeyStart = SaveKeyStart,
    HandleSkillType = HandleSkillType,
    HandleMainType = HandleMainType,
    HandleCombatType = HandleCombatType,
    HandleCombatText = HandleCombatText,
    HandleFunctionType = HandleFunctionType,
    HandleFunctionText = HandleFunctionText,
    HandleSkillText = HandleSkillText,
    HandleOtherText = HandleOtherText,
    HandleCustomActionType = HandleCustomActionType,
    HandleDefaultCustomAction = HandleDefaultCustomAction,
    HandleCustomActionConfig = HandleCustomActionConfig,
    HandleOtherActionConfig = HandleOtherActionConfig,
    HandleCusActionFunc = HandleCusActionFunc,
    HandleModeType = HandleModeType,
    InputActionType = InputActionType,
    HandleActionPriority = HandleActionPriority,
    HandleVirtualCursorWidget = HandleVirtualCursorWidget,
    HandleType = HandleType,
    SkillHandleSkillPositionMap = SkillHandleSkillPositionMap,
    InValidInputAction = InValidInputAction,
    ProfSaveKeyStart = ProfSaveKeyStart,
    HandleCombinationType = HandleCombinationType,
}

return SettingsHandleDefine

