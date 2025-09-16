local CfgExternalFunctions = require("Game/SystemConfig/CfgExternalFunctions")
local SaveKey = require("Define/SaveKey")
local USaveMgr = _G.UE.USaveMgr

local WidgetType = {
	ToggleGroup = 1,
	Slider = 2,
	Button = 3,
}

local ButtonCfg = {
	[1] = {Desc = "开启力反馈", IsSwitch = true, DefaultState = false, SaveKey = nil, Callback = CfgExternalFunctions.ForceFeedbackSwitch},
	[2] = {Desc = "显示轴向", IsSwitch = true, DefaultState = false, SaveKey = nil, Callback = CfgExternalFunctions.ShowEffectAxis},
	-- [2] = {Desc = "wagagagaame", DefaultState = false, Callback = CfgExternalFunctions.AntiAliasing},
}

local CombatFXList = {"完全显示", "简单显示", "不显示"}

local CfgList = {
	-- [1] = {Section = 1, Title = "帧数", Type = WidgetType.ToggleGroup, Count = 5, DescList = {"15", "30", "60", "90", "120"}, DefaultIndex = 3, Callback = CfgExternalFunctions.FrameNumber},
	[1] = {Section = 1, Title = "画质等级",  Type = WidgetType.ToggleGroup, SaveKey = SaveKey.QualityLevel, Count = 5, DescList = {"0", "1", "2", "3", "4"}, DefaultIndex = 4, Callback = CfgExternalFunctions.QualityLevel},
	-- [2] = {Section = 1, Title = "渲染精度", Type = WidgetType.ToggleGroup, SaveKey = SaveKey.RenderingAccuracy, Count = 5, DescList = {"极低", "低", "中", "高", "极高"}, DefaultIndex = 3, Callback = CfgExternalFunctions.RenderingAccuracy},
	-- [3] = {Section = 1, Title = "同屏人数", Type = WidgetType.Slider, SaveKey = SaveKey.ScreenPeopleNumber, MinValue = 0, MaxValue = 100, CurValue = 10, bInt = true, Callback = CfgExternalFunctions.ScreenPeopleNumber},
	-- [4] = {Section = 1, Title = "抗锯齿", Type = WidgetType.Button, Buttons = {ButtonCfg[1], ButtonCfg[2]}},
	-- [2] = {Section = 6, Title = "自己",  Type = WidgetType.ToggleGroup, SaveKey = SaveKey.CombatFXSelf, Count = 3, DescList = CombatFXList, DefaultIndex = 0, Callback = CfgExternalFunctions.CombatFX},
	-- [3] = {Section = 6, Title = "小队",  Type = WidgetType.ToggleGroup, SaveKey = SaveKey.CombatFXTeam, Count = 3, DescList = CombatFXList, DefaultIndex = 0, Callback = CfgExternalFunctions.CombatFX},
	-- [4] = {Section = 6, Title = "他人",  Type = WidgetType.ToggleGroup, SaveKey = SaveKey.CombatFXPlayer, Count = 3, DescList = CombatFXList, DefaultIndex = 0, Callback = CfgExternalFunctions.CombatFX},
	-- [5] = {Section = 6, Title = "对战时的敌方玩家",  Type = WidgetType.ToggleGroup, SaveKey = SaveKey.CombatFXEnemy, Count = 3, DescList = CombatFXList, DefaultIndex = 0, Callback = CfgExternalFunctions.CombatFX},
	[2] = {Section = 1, Title = "力反馈设置", Type = WidgetType.Button, Buttons = {ButtonCfg[1]}},
	[3] = {Section = 7, Title = "摇杆是否维持跑步状态",  Type = WidgetType.ToggleGroup, SaveKey = SaveKey.MaxSpeedConstState, Count = 2, DescList = {"是", "否"}, DefaultIndex = 0, Callback = CfgExternalFunctions.SetSpeedConst},
	[4] = {Section = 7, Title = "摇杆死区是否屏蔽停止移动",  Type = WidgetType.ToggleGroup, SaveKey = SaveKey.MaxSpeedBlindConstState, Count = 2, DescList = {"是", "否"}, DefaultIndex = 0, Callback = CfgExternalFunctions.SetBlindSpeedConst},
	[5] = {Section = 1, Title = "技能特效轴向显示",  Type = WidgetType.Button, Buttons = {ButtonCfg[2]}},
	[6] = {Section = 8, Title = "角色脚步特效",  Type = WidgetType.ToggleGroup, SaveKey = SaveKey.FootstepEffect, Count = 3, DescList = {"不显示", "只显示自己", "显示所有"}, DefaultIndex = 1, Callback = CfgExternalFunctions.SetFootstepEffect},
}

local CfgEntrance = {
    ClassificationList = {
        "自定义", "省电", "流畅", "精致", "高清", "战斗特效", "摇杆设置", "角色设置"
    },
    WidgetType = WidgetType,
    ButtonCfg = ButtonCfg,
    CfgList = CfgList,
}


function CfgEntrance.GetValue(InSaveKey)
	if not InSaveKey then
		return
	end
	for _, value in ipairs(CfgEntrance.CfgList) do
		if value.Type == WidgetType.ToggleGroup then
			if value.SaveKey == InSaveKey then
				return value.DefaultIndex
			end
		elseif value.Type == WidgetType.Slider then
			if value.SaveKey == InSaveKey then
				return value.CurValue
			end
		elseif value.Type == WidgetType.Button then
			for _, Buttons in ipairs(value.Buttons) do
				if Buttons.SaveKey == InSaveKey then
					return Buttons.DefaultState
				end
			end
		end
	end
end

function CfgEntrance.LoadConfig()
	for _, value in ipairs(CfgEntrance.CfgList) do
		if value.Type == WidgetType.ToggleGroup then
			if value.SaveKey then
				value.DefaultIndex = USaveMgr.GetInt(value.SaveKey, value.DefaultIndex, true)
				value.Callback(nil, value.DefaultIndex, value.DescList[value.DefaultIndex + 1], value)
			end
		elseif value.Type == WidgetType.Slider then
			if value.SaveKey then
				value.CurValue = USaveMgr.GetFloat(value.SaveKey, value.CurValue, true)
				value.Callback(value.CurValue)
			end
		elseif value.Type == WidgetType.Button then
			for _, Buttons in ipairs(value.Buttons) do
				if Buttons.SaveKey then
					Buttons.DefaultState = USaveMgr.GetInt(Buttons.SaveKey, Buttons.DefaultState and 1 or 0, true) == 1 and true or false
					Buttons.Callback(Buttons.DefaultState)
				end
			end
		end
	end
end

return CfgEntrance