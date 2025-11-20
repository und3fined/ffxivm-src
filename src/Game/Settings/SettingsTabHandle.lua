
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local SaveKey = require("Define/SaveKey")
local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local SettingsCfg = require("TableCfg/SettingsCfg")
local LSTR = _G.LSTR
local USaveMgr

local SettingsTabHandle = {}


local HandleCustomActionConfig<const> = SettingsHandleDefine.HandleCustomActionConfig
local HandleMainType<const> = SettingsHandleDefine.HandleMainType
local HandleInputActionConfig<const> = SettingsHandleDefine.HandleInputActionConfig
local HandleCombatType<const> = SettingsHandleDefine.HandleCombatType
local HandleFunctionType<const> = SettingsHandleDefine.HandleFunctionType
local HandleSkillType<const> = SettingsHandleDefine.HandleSkillType
local HandleCombatText<const> = SettingsHandleDefine.HandleCombatText
local HandleFunctionText<const> = SettingsHandleDefine.HandleFunctionText
local HandleSkillText<const> = SettingsHandleDefine.HandleSkillText
local HandleDefaultCustomAction<const> = SettingsHandleDefine.HandleDefaultCustomAction
local HandleModeType<const> = SettingsHandleDefine.HandleModeType
local InputActionType<const> = SettingsHandleDefine.InputActionType
local HandleCustomActionType<const> = SettingsHandleDefine.HandleCustomActionType
local ProfSaveKeyStart<const> = SettingsHandleDefine.ProfSaveKeyStart
local HandleCombinationType<const> = SettingsHandleDefine.HandleCombinationType

function SettingsTabHandle:OnInit()
    self.HandleCustomActionMap = {}
    for key, vaule in pairs(HandleDefaultCustomAction) do
        self.HandleCustomActionMap[key] = vaule
    end
    self:InitCustomTypeList()
    --手柄辅助模式
    self.HandleMode = HandleModeType.Off
    --是否连接手柄
    self.IsHandleAttached = false
    --最后一次用户输入的类型
    self.LastInputActionType = InputActionType.Other

    self.CursorSpeed = 1

    self.CursorSpeedCfg = {}
end

function SettingsTabHandle:OnBegin()
    USaveMgr = _G.UE.USaveMgr
    --检查是否存在重复的CustomAction
    local InputActionMap = {}
    for key, _ in pairs(self.HandleCustomActionMap) do
        local SaveAction = USaveMgr.GetInt(SaveKey[key], -1, true)
        if nil == InputActionMap[SaveAction] or SaveAction == HandleCustomActionType.SkillEmpty or 
        SaveAction == HandleCustomActionType.CombatEmpty or SaveAction == HandleCustomActionType.FunctionEmpty then
            InputActionMap[SaveAction] = key
        else
            self:ResetCustomAction(true)
            break
        end
    end
    self.CursorSpeedCfg = SettingsCfg:GetCfgBySaveKey("HandleCursorSpeed")
    if self.CursorSpeedCfg then
        self.CursorSpeedCfg = self.CursorSpeedCfg[1]
    end
end

function SettingsTabHandle:OnEnd()

end

function SettingsTabHandle:OnShutdown()

end

--光标速度相关
function SettingsTabHandle:SetHandleCursorSpeed(Value, IsSave)
     if nil == SettingsUtils.CurSetingCfg then
        return
    end
    local CurSaveKey = SettingsUtils.CurSetingCfg.SaveKey
    self.CursorSpeed = Value
    if IsSave then
        USaveMgr.SetInt(SaveKey[CurSaveKey], Value, true)
        USaveMgr.SetInt(SaveKey[CurSaveKey], Value, false)
    end
    _G.EventMgr:SendEvent(EventID.CursorSpeedChange, self.CursorSpeed)
end

--手柄连接状态相关
function SettingsTabHandle:SetIsHandleAttached(Value)
    if self.IsHandleAttached ~= Value then
        self.IsHandleAttached = Value
        --发送输入类型改变事件
        _G.EventMgr:SendEvent(EventID.InputActionTypeChange, self.IsHandleAttached)
    end
    -- if self.IsHandleAttached then
    --     self:SetLastInputActionType(InputActionType.Handle)
    -- else
    --     self:SetLastInputActionType(InputActionType.Other)
    -- end
end

function SettingsTabHandle:GetIsHandleAttached()
    return self.IsHandleAttached
end

-- function SettingsTabHandle:SetLastInputActionType(Value)
--     if self.LastInputActionType ~= Value then
--         self.LastInputActionType = Value
--         --发送输入类型改变事件

--     end
-- end



--手柄辅助模式
function SettingsTabHandle:StartHandleMode()
    _G.UIViewMgr:ShowView(UIViewID.SettingHandleOperationWin)
    self:SetIsHandleAttached(true)
    self:SetHandleMode(HandleModeType.On)
    _G.EventMgr:SendEvent(EventID.OnResetHandleCusAction)
end

function SettingsTabHandle:StopHandleMode()
    _G.UIViewMgr:HideView(UIViewID.SettingHandleOperationWin)
    self:SetIsHandleAttached(false)
    self:SetHandleMode(HandleModeType.Off)
    _G.EventMgr:SendEvent(EventID.OnResetHandleCusAction)
end

function SettingsTabHandle:SwitchHandleModeCheck(Index)
    local CurSetingCfg = SettingsUtils.CurSetingCfg
    if nil == CurSetingCfg then
        return false, false
    end
    if CurSetingCfg.Num[Index] > 0 then
        if self.IsHandleAttached then
            self:SetHandleMode(HandleModeType.On)
            return true, false
        else
            self:SetHandleMode(HandleModeType.Off)
            --弹系统提示
            MsgTipsUtil.ShowTips(LSTR("110079"))
            return false, false
        end
    else
        self:SetHandleMode(HandleModeType.Off)
        return true, false
    end
end

function SettingsTabHandle:SetHandleMode(Value)
    self.HandleMode = Value
    _G.EventMgr:SendEvent(EventID.GameHandleMode, self.HandleMode)
end

function SettingsTabHandle:GetHandleModeIndex()
    local CurSetingCfg = SettingsUtils.CurSetingCfg
    if nil == CurSetingCfg or nil == CurSetingCfg.Num then
        return
    end
    for index, value in pairs(CurSetingCfg.Num) do
        if (value > 0) == self.HandleMode then
            return index
        end
    end
    return 
end

function SettingsTabHandle:GetHandleModeText(bPreClickDropDownList, cfg)
    if nil == cfg or nil == cfg.Value then
        return
    end
    return cfg.Value
end

function SettingsTabHandle:GetHandleMode()
    return self.HandleMode
end

--手柄设置
function SettingsTabHandle:ResetCommonCustomAction()
    local ResetCustomActionCallBack = function()
        self:InitCustomTypeList(HandleMainType.CombatType)
        self:InitCustomTypeList(HandleMainType.FunctionType)
        for key, _ in pairs(self.HandleCustomActionMap) do
            if HandleMainType.CombatType == HandleInputActionConfig[key].MainType 
                or HandleMainType.FunctionType == HandleInputActionConfig[key].MainType then
                local CurSaveValue = SettingsHandleDefine.HandleDefaultCustomAction[key]
                self:SetCusActionIndexBySaveKey(key, CurSaveValue)
                USaveMgr.SetInt(SaveKey[key], CurSaveValue, true)
                self[key] = CurSaveValue
                self:RemoveFromCustomTypeList(HandleCustomActionConfig[CurSaveValue].MainType, HandleCustomActionConfig[CurSaveValue].SubType) 
            end
        end
        local CurValue = tonumber(self.CursorSpeedCfg.Value[2])
        SettingsUtils.SetValue(self.CursorSpeedCfg.SetValueFunc, self.CursorSpeedCfg, CurValue, true, false, true)
        _G.EventMgr:SendEvent(EventID.OnResetHandleCusAction)
        _G.EventMgr:SendEvent(EventID.GamePadUpdateCombatType, true)
    end
    _G.MsgBoxUtil.ShowMsgBoxTwoOp(nil, LSTR(110077), LSTR(110078), ResetCustomActionCallBack)
end

function SettingsTabHandle:ResetSkillCustomAction()
    local ResetCustomActionCallBack = function()
        self:InitCustomTypeList(HandleMainType.SkillType)
        for key, _ in pairs(self.HandleCustomActionMap) do
            if HandleMainType.SkillType == HandleInputActionConfig[key].MainType then
                local CurSaveValue = SettingsHandleDefine.HandleDefaultCustomAction[key]
                --重置所有技能映射不单独发送事件，减少每个事件的单独处理
                self:SetCusActionIndexBySaveKey(key, CurSaveValue, true)
                USaveMgr.SetInt(SaveKey[key], CurSaveValue, true)
                self[key] = CurSaveValue
                self:RemoveFromCustomTypeList(HandleCustomActionConfig[CurSaveValue].MainType, HandleCustomActionConfig[CurSaveValue].SubType) 
            end
        end
        _G.EventMgr:SendEvent(EventID.OnResetHandleCusAction, HandleMainType.SkillType)
    end
    _G.MsgBoxUtil.ShowMsgBoxTwoOp(nil, LSTR(110077), LSTR(110083), ResetCustomActionCallBack)
end

function SettingsTabHandle:ResetCustomAction(IsSave)
    self:InitCustomTypeList()
    for key, _ in pairs(self.HandleCustomActionMap) do
        local DeafultSaveValue = SettingsHandleDefine.HandleDefaultCustomAction[key]
        self:SetCusActionIndexBySaveKey(key, DeafultSaveValue)
        if IsSave then
            USaveMgr.SetInt(SaveKey[key], DeafultSaveValue, true)
        end
        self[key] = DeafultSaveValue
        self:RemoveFromCustomTypeList(HandleCustomActionConfig[DeafultSaveValue].MainType, HandleCustomActionConfig[DeafultSaveValue].SubType) 
    end
    _G.EventMgr:SendEvent(EventID.OnResetHandleCusAction)
end

function SettingsTabHandle:GetHandleCustomActionMap()
    return self.HandleCustomActionMap
end

--定义
--输入事件: InputAction = SaveKey
--下拉列表Index: DropDownIndex
--InputAction对应的CusAction的Index: CusActionIndex

--获取InputAction对应的CusActionIndex
function SettingsTabHandle:GetCusActionIndexBySaveKey(SaveKey)
    if nil == SaveKey then
        return 
    end
    return self.HandleCustomActionMap[SaveKey]
end

function SettingsTabHandle:GetOtherActionByCusAction(CusAction)
     if nil == CusAction then
        return 
    end
    for key, value in pairs(HandleInputActionConfig) do
        if CusAction == value.Index then
            return key
        end
    end
end

function SettingsTabHandle:SetCusActionIndexBySaveKey(SaveKey, CusActionIndex, bDontSendEvent)
    self.HandleCustomActionMap[SaveKey] = CusActionIndex
    local CurActionText = self:GetCusActionTextBySaveKey(SaveKey)
    if not bDontSendEvent then
        _G.EventMgr:SendEvent(EventID.OnUpdateHandleCusAction, {SaveKey = SaveKey, CurActionText = CurActionText, CusActionIndex = CusActionIndex})
    end
end

function SettingsTabHandle:GetCusActionTextBySaveKey(SaveKey)
    local CusActionIndex = self:GetCusActionIndexBySaveKey(SaveKey)
    if CusActionIndex then
        if nil ~= HandleCustomActionConfig[CusActionIndex] then
        if HandleCustomActionConfig[CusActionIndex].MainType == HandleMainType.CombatType then
            return HandleCombatText[HandleCustomActionConfig[CusActionIndex].SubType]
        elseif HandleCustomActionConfig[CusActionIndex].MainType == HandleMainType.FunctionType then
            return HandleFunctionText[HandleCustomActionConfig[CusActionIndex].SubType]
        elseif HandleCustomActionConfig[CusActionIndex].MainType == HandleMainType.SkillType then
            return HandleSkillText[HandleCustomActionConfig[CusActionIndex].SubType]
        end
    end
    else
        local InputActionIndex = HandleInputActionConfig[SaveKey].Index
        return SettingsHandleDefine.HandleOtherText[InputActionIndex]
    end
end

function SettingsTabHandle:GetCusActionIndexBySubType(MainType, SubType)
    return MainType*100 + SubType
end

function SettingsTabHandle:GetCurDropDownIndexBySubType(MainType, SubType)
    local CurDropDownIndex = 0
    if MainType == HandleMainType.CombatType then
        for index, value in ipairs(self.CustomCombatTypeList) do
            if value > 0 or index == SubType then
                CurDropDownIndex = CurDropDownIndex + 1
                if index == SubType then
                    break
                end
            end
        end
    elseif MainType == HandleMainType.FunctionType then
        for index, value in ipairs(self.CustomFunctionTypeList) do
            if value > 0 or index == SubType then
                CurDropDownIndex = CurDropDownIndex + 1
                if index == SubType then
                    break
                end
            end
        end
    else
        for index, value in ipairs(self.CustomSkillTypeList) do
             if value > 0 or index == SubType then
                CurDropDownIndex = CurDropDownIndex + 1
                if index == SubType then
                    break
                end
            end
        end
    end
    return CurDropDownIndex
end

function SettingsTabHandle:GetCurSubTypebyDropDownIndex(MainType, LastSubType , DropDownIndex)
    local CurDropDownIndex = 0
     if MainType == HandleMainType.CombatType then
        for index, value in ipairs(self.CustomCombatTypeList) do
            if value > 0 or index == LastSubType then
                CurDropDownIndex = CurDropDownIndex + 1
                if CurDropDownIndex == DropDownIndex then
                    return index
                end
            end
        end
    elseif MainType == HandleMainType.FunctionType then
        for index, value in ipairs(self.CustomFunctionTypeList) do
            if value > 0 or index == LastSubType then
                CurDropDownIndex = CurDropDownIndex + 1
                if CurDropDownIndex == DropDownIndex then
                    return index
                end
            end
        end
    else
        for index, value in ipairs(self.CustomSkillTypeList) do
             if value > 0 or index == LastSubType then
                CurDropDownIndex = CurDropDownIndex + 1
                if CurDropDownIndex == DropDownIndex then
                    return index
                end
            end
        end
    end
end

function SettingsTabHandle:GetSaveKeyByCusAction(CusAction)
    for key, value in pairs(self.HandleCustomActionMap) do
        if value == CusAction then
            return key
        end
    end
end
--------------------------------------------
function SettingsTabHandle:GetDefaultCusActionIndex()
    if nil == SettingsUtils.CurSetingCfg then
        return
    end
    local CurSaveKey = SettingsUtils.CurSetingCfg.SaveKey
    local CurActionIndex = self:GetCusActionIndexBySaveKey(CurSaveKey)
    if CurActionIndex then
        return CurActionIndex
    end
end

function SettingsTabHandle:SetCusActionIndex(Value, IsSave, IsLoginInit, IsBySelect)
    if nil == SettingsUtils.CurSetingCfg then
        return
    end
    local CurSaveKey = SettingsUtils.CurSetingCfg.SaveKey
    local LastActionIndex = self:GetCusActionIndexBySaveKey(CurSaveKey)
    local CurSaveValue = Value
    if nil == CurSaveValue or nil == LastActionIndex then
        return
    end 
     local ProfID = MajorUtil.GetMajorProfID()
    ProfID = ProfUtil.GetAdvancedProf(ProfID)
    if IsBySelect then
        local LastSubType = HandleCustomActionConfig[LastActionIndex].SubType
        self:SetCustomTypeList(HandleCustomActionConfig[LastActionIndex].MainType, LastSubType)
        local CurSubtype = self:GetCurSubTypebyDropDownIndex(HandleInputActionConfig[CurSaveKey].MainType, LastSubType, Value)
        CurSaveValue = self:GetCusActionIndexBySubType(HandleInputActionConfig[CurSaveKey].MainType, CurSubtype)
        USaveMgr.SetInt(SaveKey[CurSaveKey], CurSaveValue, true)
        self:SetValueByProfSaveKey(CurSaveValue, CurSaveKey, ProfID)
    else
        if IsSave then
            USaveMgr.SetInt(SaveKey[CurSaveKey], CurSaveValue, true)
            self:SetValueByProfSaveKey(CurSaveValue, CurSaveKey, ProfID)
        end
    end
    --保存的数据错误，重置
    if nil ==  HandleCustomActionConfig[CurSaveValue] then
        self:ResetCustomAction(true)
        return
    end
    self[SettingsUtils.CurSetingCfg.SaveKey] = CurSaveValue
    self:RemoveFromCustomTypeList(HandleCustomActionConfig[CurSaveValue].MainType, HandleCustomActionConfig[CurSaveValue].SubType)
    self:SetCusActionIndexBySaveKey(CurSaveKey, CurSaveValue)
    --交互/主界面显示相关
    if IsBySelect and HandleCustomActionConfig[CurSaveValue].MainType == HandleMainType.CombatType then
        _G.EventMgr:SendEvent(EventID.GamePadUpdateCombatType, true)
    end
    return true
end

function SettingsTabHandle:GetCusActionIndex()
    if nil == SettingsUtils.CurSetingCfg then
        return
    end
    local CurSaveKey = SettingsUtils.CurSetingCfg.SaveKey
    local CurActionIndex = self:GetCusActionIndexBySaveKey(CurSaveKey)
    if CurActionIndex then
        if nil ~= HandleCustomActionConfig[CurActionIndex] then
           return self:GetCurDropDownIndexBySubType(HandleCustomActionConfig[CurActionIndex].MainType, HandleCustomActionConfig[CurActionIndex].SubType)
        end
    end
end

function SettingsTabHandle:GetCusActionText(bPreClickDropDownList, cfg)
    if nil == cfg then
        return
    end
    local CurSaveKey = cfg.SaveKey
    local CurActionIndex = self:GetCusActionIndexBySaveKey(CurSaveKey)
    if CurActionIndex then
        return self:GetCustomTypeList(HandleInputActionConfig[CurSaveKey].MainType, CurActionIndex)
    end
end


function SettingsTabHandle:RemoveFromCustomTypeList(MainType, SubType)
    if MainType == HandleMainType.CombatType then
        if HandleCombatType.Empty == SubType then
            return
        end
        self.CustomCombatTypeList[SubType] = 0
    elseif MainType == HandleMainType.FunctionType then
        if HandleFunctionType.Empty == SubType then
            return
        end
        self.CustomFunctionTypeList[SubType] = 0
    else
        if HandleSkillType.Empty == SubType then
            return
        end
        self.CustomSkillTypeList[SubType] = 0
    end
end

function SettingsTabHandle:SetCustomTypeList(MainType, SubType)
    if MainType == HandleMainType.CombatType then
        if HandleCombatType.Empty == SubType then
            return
        end
        self.CustomCombatTypeList[SubType] = SubType
    elseif MainType == HandleMainType.FunctionType then
        if HandleFunctionType.Empty == SubType then
            return
        end
        self.CustomFunctionTypeList[SubType] = SubType
    else
        if HandleSkillType.Empty == SubType then
            return
        end
        self.CustomSkillTypeList[SubType] = SubType
    end
end

function SettingsTabHandle:InitCustomTypeList(MainType)
    if MainType == HandleMainType.CombatType or nil == MainType then
        self.CustomCombatTypeList = {}
        for i = 1, HandleCombatType.Empty do
            table.insert(self.CustomCombatTypeList, i)
        end
    end
     if MainType == HandleMainType.FunctionType or nil == MainType then
        self.CustomFunctionTypeList = {}
        for i = 1, HandleFunctionType.Empty do
            table.insert(self.CustomFunctionTypeList, i)
        end
    end
    if MainType == HandleMainType.SkillType or nil == MainType then
        self.CustomSkillTypeList = {}
        for i = 1, HandleSkillType.Empty do
            table.insert(self.CustomSkillTypeList, i)
        end
    end
end



function SettingsTabHandle:GetCustomTypeList(MainType, ActionIndex)
    local DropDownTextList = {}
    local DropDownIndex = 1
    local SubType= HandleCustomActionConfig[ActionIndex].SubType
    if MainType == HandleMainType.CombatType then
        for index, value in pairs(self.CustomCombatTypeList) do
            if value > 0 or SubType == index then
               DropDownTextList[DropDownIndex] = HandleCombatText[index]
                DropDownIndex = DropDownIndex +1
            end
        end
    elseif MainType == HandleMainType.FunctionType then
        for index, value in pairs(self.CustomFunctionTypeList) do
            if value > 0 or SubType == index then
               DropDownTextList[DropDownIndex] = HandleFunctionText[index]
                DropDownIndex = DropDownIndex +1
            end
        end
    else
         for index, value in pairs(self.CustomSkillTypeList) do
            if value > 0 or SubType == index then
               DropDownTextList[DropDownIndex] = HandleSkillText[index]
                DropDownIndex = DropDownIndex +1
            end
        end
    end
    return DropDownTextList
end
function SettingsTabHandle:GetCursorText()
    local DropDownTextList = {}
    DropDownTextList[1] = LSTR(110087)
    return DropDownTextList
end

--获取当前职业对应的Key
function SettingsTabHandle:GetProfSaveKey(SaveKey, ProfID)
    local ProfSaveKey = SaveKey
    if HandleCombinationType[SaveKey] then
        ProfID = ProfUtil.GetAdvancedProf(ProfID)
        ProfSaveKey = ProfSaveKeyStart + HandleCombinationType[SaveKey] + ProfID * 16
    end
    return ProfSaveKey, ProfSaveKey ~= SaveKey
end

--保存当前profkey的值
function SettingsTabHandle:SetValueByProfSaveKey(Value, SaveKey, ProfID)
    local ProfSaveKey, bSucceed = self:GetProfSaveKey(SaveKey, ProfID)
    if bSucceed then
        USaveMgr.SetInt(ProfSaveKey, Value, true)
    end
end

function SettingsTabHandle:GetValueByProfSaveKey(SaveKey, ProfID)
    local ProfSaveKey, bSucceed= self:GetProfSaveKey(SaveKey, ProfID)
    if bSucceed then
        return USaveMgr.GetInt(ProfSaveKey, -1, true)
    else
        return -1
    end
end

--初始化/切换职业时刷新设置
function SettingsTabHandle:UpdateByMajorProfSwitch()
    if _G.DemoMajorType ~= 1 then
        local ProfID = MajorUtil.GetMajorProfID()
        ProfID = ProfUtil.GetAdvancedProf(ProfID)
        local ProfSaveKeyIsActive = false
        if self:GetValueByProfSaveKey("HandleRTB", ProfID) > 0 then
            ProfSaveKeyIsActive = true
        end
        self:InitCustomTypeList(HandleMainType.SkillType)
        for key, _ in pairs(HandleCombinationType) do
            local CusAction = -1
            if ProfSaveKeyIsActive then
                CusAction = self:GetValueByProfSaveKey(key, ProfID)
            end
            if CusAction <= -1 then
                self:SetCusActionIndexBySaveKey(key,HandleDefaultCustomAction[key],true)
                self:SetValueByProfSaveKey(HandleDefaultCustomAction[key], key, ProfID)
                CusAction = HandleDefaultCustomAction[key]
            else
                self:SetCusActionIndexBySaveKey(key,CusAction, true)
            end
            self[key] = CusAction
            self:RemoveFromCustomTypeList(HandleCustomActionConfig[CusAction].MainType, HandleCustomActionConfig[CusAction].SubType) 
        end
        _G.EventMgr:SendEvent(EventID.OnResetHandleCusAction, HandleMainType.SkillType)
    end
end

--按键设置显示职业

function SettingsTabHandle:GetSkillTypeProfName(SubCategoryName)
    local ProfID = MajorUtil.GetMajorProfID()
    local Name = RoleInitCfg:FindRoleInitProfName(ProfID)
    local CurSubCategoryName = string.format("%s (%s)", SubCategoryName, Name)
    return CurSubCategoryName
end

 return SettingsTabHandle
