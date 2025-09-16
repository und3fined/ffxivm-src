---
--- Author: loiafeng
--- DateTime: 2025-01-07 10:47
--- Description: 主界面右上角功能区按钮
---

local MainFunctionDefine = require("Game/Main/FunctionPanel/MainFunctionDefine")

local CommonUtil = require("Utils/CommonUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local AdventureDefine = require("Game/Adventure/AdventureDefine")

local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewID = require("Define/UIViewID")

local ButtonType = MainFunctionDefine.ButtonType

local MainFunctionUtil = {}

--region Unlock

local UnlockStateGetters = {
    [ButtonType.NONE] = false,  -- 固定上锁，不予显示
    [ButtonType.MENU] = true,
    [ButtonType.ROLE] = function()
        return _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_ROLE)
    end,
    [ButtonType.ADVENTURE] = function()
        return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDAdventure)
            and _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_ROLE)
    end,
    [ButtonType.ACTIVITY] = function()
        return not CommonUtil.ShouldDownloadRes()
            and _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDActivitySystem)
    end,
    [ButtonType.STORE] = function()
        return not CommonUtil.ShouldDownloadRes()
            and _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMall)
            and _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MALL)
    end,
    [ButtonType.BATTLE_PASS] = function()
        return not CommonUtil.ShouldDownloadRes()
            and _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBattlePass)
            and _G.BattlePassMgr:GetIsBattlePassOpen()
            and _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_PASSPORT)
    end,
    [ButtonType.SEASON_ACTIVITY] = function()
        return not CommonUtil.ShouldDownloadRes()
    end,
    [ButtonType.NEW_VERSION] = true,
    [ButtonType.PRE_DOWNLOAD] = true,
    [ButtonType.MUR_SURVEY] = function()
        return not CommonUtil.ShouldDownloadRes()
    end,
    [ButtonType.DEPART_OF_LIGHT] = function()
        return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLightJourney)
    end,
}

---IsButtonUnlock
---@param Value number @see MainFunctionButtonType
function MainFunctionUtil.IsButtonUnlock(Type)
    local Getter = UnlockStateGetters[Type]
    if type(Getter) == "boolean" then return Getter end
    return Getter()
end

--endregion

--region OnPressed

local function OnMenuPressed()
    --提审版本未下载全量资源时禁用二级菜单
    if CommonUtil.ShouldDownloadRes() then
        CommonUtil.ShowDownloadResMsgBox()
        return
    end

	_G.UIViewMgr:ShowView(UIViewID.Main2ndPanel)
end

local function OnRolePressed()
    _G.UIViewMgr:ShowView(UIViewID.EquipmentMainPanel)
end

local function OnAdventurePressed()
	DataReportUtil.ReportSystemFlowData("ReTasksInfo", tostring(AdventureDefine.ReportAdventureRecommendTaskType.EnterMethod), UIViewID.MainPanel)
	_G.UIViewMgr:ShowView(UIViewID.AdventruePanel)
end

local function OnActivityPressed()
	_G.UIViewMgr:ShowView(UIViewID.OpsActivityMainPanel)
end

local function OnStorePressed()
    _G.StoreMgr:ShowMainPanel()
end

local function OnBattlePassPressed()
    _G.UIViewMgr:ShowView(UIViewID.BattlePassMainView)
end

local function OnSeasonActivityPressed()
    _G.OpsSeasonActivityMgr:ShowSeasonActivityUI()
end

local function OnNewVersionPressed()
    _G.OpsSeasonActivityMgr:ShowNewVersionContentUI()
end

local function OnPreDownloadPressed()
end

local function OnMURSurveyPressed()
	_G.MURSurveyMgr:OpenMURSurvey(1, false, true, "", false)
end

local function OnDeparturePressed()
	_G.DepartOfLightMgr:ShowDepartMainView()
end

local OnPressedCallbacks = {
    [ButtonType.NONE] = nil,
    [ButtonType.MENU] = OnMenuPressed,
    [ButtonType.ROLE] = OnRolePressed,
    [ButtonType.ADVENTURE] = OnAdventurePressed,
    [ButtonType.ACTIVITY] = OnActivityPressed,
    [ButtonType.STORE] = OnStorePressed,
    [ButtonType.BATTLE_PASS] = OnBattlePassPressed,
    [ButtonType.SEASON_ACTIVITY] = OnSeasonActivityPressed,
    [ButtonType.NEW_VERSION] = OnNewVersionPressed,
    [ButtonType.PRE_DOWNLOAD] = OnPreDownloadPressed,
    [ButtonType.MUR_SURVEY] = OnMURSurveyPressed,
    [ButtonType.DEPART_OF_LIGHT] = OnDeparturePressed,
}

---OnPressed
---@param Value number @see MainFunctionButtonType
function MainFunctionUtil.OnPressed(Type)
    if MainFunctionUtil.IsButtonUnlock(Type) then
        OnPressedCallbacks[Type]()
    else
        _G.FLOG_ERROR("MainFunctionUtil.OnPressed: Pressed a locked button. Type: " .. tostring(Type))
    end
end

--endregion

return MainFunctionUtil