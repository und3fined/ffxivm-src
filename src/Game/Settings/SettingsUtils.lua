--- 
--- Author: xingcaicao
--- DateTime: 2023-03-21 12:02
--- Description:
local MajorUtil = require("Utils/MajorUtil")
-- local SettingsCfg = require("TableCfg/SettingsCfg")
local SettingsDefine = require("Game/Settings/SettingsDefine")
local ItemDisplayStyle = SettingsDefine.ItemDisplayStyle
local ProtoCS = require("Protocol/ProtoCS")

local ClientSetupID = require("Game/ClientSetup/ClientSetupID")

local USaveMgr
local SaveKey = require("Define/SaveKey")

local SettingsMgr = nil

--这样添加一级分类页签的模块，为了能自动化get/set到对应模块，不用经过SettingsUtils
local SettingsTabsConfig = {
    --未归类的，一些页签内容比较少，就没必要新增一个页签，就放SettingsTabUnCategory这里得了
    ["SettingsTabUnCategory"] = "Game/Settings/SettingsTabUnCategory",
    ["SettingsTabBase"] = "Game/Settings/SettingsTabBase",          --基础设置
    ["SettingsTabSound"] = "Game/Settings/SettingsTabSound",        --声音设置
    ["SettingsTabPicture"] = "Game/Settings/SettingsTabPicture",    --图像设置
    ["SettingsTabRole"] = "Game/Settings/SettingsTabRole",          --角色设置
    ["SettingsTabOthers"] = "Game/Settings/SettingsTabOthers",      --角色设置
    ["SettingsTabNameplate"] = "Game/Settings/SettingsTabNameplate",
    ["SettingsTabLanguages"] = "Game/Settings/SettingsTabLanguages", -- 语言设置
}

---@class SettingsUtils
local SettingsUtils = {
    CurSetingCfg = nil, --仅仅是Set期间生效，执行结束就恢复nil

}
-- Uncategorized
function SettingsUtils.OnInit()
    USaveMgr    = _G.UE.USaveMgr
    SettingsMgr = require("Game/Settings/SettingsMgr")  --如果在开头会产生循环依赖

    --这样添加一级分类页签的模块，为了能自动化get/set到对应模块，不用经过SettingsUtils
    for key, Path in pairs(SettingsTabsConfig) do
        SettingsUtils[key] = require(Path)
        SettingsUtils[key]:OnInit()
    end
end

function SettingsUtils.OnBegin()
    for key, _ in pairs(SettingsTabsConfig) do
        SettingsUtils[key]:OnBegin()
    end
end

function SettingsUtils.OnEnd()
    for key, _ in pairs(SettingsTabsConfig) do
        SettingsUtils[key]:OnEnd()
    end
end

function SettingsUtils.OnShutdown()
    for key, _ in pairs(SettingsTabsConfig) do
        SettingsUtils[key]:OnShutdown()
    end
end

function SettingsUtils.GetSettingTabs(Key)
    return SettingsUtils[Key]
end

--默认保存在set函数所在模块中的SaveKey字段，返回它即可
--如果配置了get函数，就优先get函数的执行，不管SaveKey字段的值了
function SettingsUtils.GetValue(FuncName, Cfg, ...)
    if not Cfg then
        return
    end

    --既没有配置get函数，也没有SaveKey字段的，就跳过
    local bGetFuncNotConfig = string.isnilorempty(FuncName)
    if bGetFuncNotConfig and string.isnilorempty(Cfg.SaveKey) then
        FLOG_ERROR("setting Need Config SaveKey, ID:%d", Cfg.ID)
        return
    end

    --如果配置了get函数，就优先get函数的执行
    --如果没配置get函数，但配置了SaveKey，返回set函数的模块中的SaveKey字段

    SettingsUtils.CurSetingCfg = Cfg

    local StrList
    if bGetFuncNotConfig then
        StrList = string.split(Cfg.SetValueFunc, ":")
    else
        StrList = string.split(FuncName, ":")
    end

    local Rlt
    local Cnt = #StrList
    if Cnt == 2 then
        local TabModule = SettingsUtils[StrList[1]]

        if bGetFuncNotConfig then
            Rlt = TabModule[Cfg.SaveKey]
        else
            local Func = TabModule[StrList[2]]
            if Func then
                Rlt = Func(TabModule, ...)
            end
        end

        -- SettingsUtils.CurSetingCfg = nil
        return Rlt
    else
        FLOG_ERROR("Setting config get must like SettingsTabBase:GetMaxFPS")
    end

    return Rlt
end

--默认把Value保存在SaveKey字段
--如果不使用默认的，Setxxx函数里面重新复制该字段（字段名为SaveKey）
function SettingsUtils.SetValue(FuncName, Cfg, ...)
    if not Cfg then
        return
    end

    if string.isnilorempty(FuncName) 
        and string.isnilorempty(Cfg.SaveKey) 
        and string.isnilorempty(Cfg.ClientSetupKey) then
        return
    end

    SettingsUtils.CurSetingCfg = Cfg
    --各个Setxxx接口，都要带上IsSave参数；   客户端启动的时候，如果没保存过的，会使用默认值进行Setxxx
    
    local Value, IsSave, IsLoginInit = ...
    local StrList = string.split(FuncName, ":")
    local Cnt = #StrList
    local bSaveIntByFunc = false
    if Cnt == 2 then
        local TabModule = SettingsUtils[StrList[1]]
        local Func = TabModule[StrList[2]]
        if Func then
            --默认把Value保存在SaveKey字段
            --如果不使用默认的，Setxxx函数里面重新复制该字段（字段名为SaveKey）
            TabModule[Cfg.SaveKey] = Value
            bSaveIntByFunc = Func(TabModule, ...)
        end
    else
        FLOG_ERROR("Setting config set must like SettingsTabBase:SetMaxFPS")
    end

    if IsSave and not bSaveIntByFunc and (Cfg.DisplayStyle == ItemDisplayStyle.Slider 
        or Cfg.DisplayStyle == ItemDisplayStyle.DropDownList 
        or Cfg.DisplayStyle == ItemDisplayStyle.ColorPalette
        or Cfg.DisplayStyle == ItemDisplayStyle.TextByCustomUI
        or Cfg.DisplayStyle == ItemDisplayStyle.CustonBPEmbed) then

        if not string.isnilorempty(Cfg.SaveKey) then
            local bSaveByRoleID = SettingsMgr:IsSaveByRoleID(Cfg)
            USaveMgr.SetInt(SaveKey[Cfg.SaveKey], Value, bSaveByRoleID)
        end

        local Key = ClientSetupID[Cfg.ClientSetupKey]
        if Key ~= nil and not IsLoginInit then
            _G.ClientSetupMgr:SendSetReq(Key, tostring(Value))
        end
    end
    
    SettingsUtils.CurSetingCfg = nil
end

--
function SettingsUtils.GetDefaultIndex(FuncName, Cfg, ...)
    if not Cfg then
        return
    end

    local bGetFuncNotConfig = string.isnilorempty(FuncName)
    if bGetFuncNotConfig then
        return
    end

    SettingsUtils.CurSetingCfg = Cfg

    local StrList
    if bGetFuncNotConfig then
        StrList = string.split(Cfg.SetValueFunc, ":")
    else
        StrList = string.split(FuncName, ":")
    end

    local Rlt
    local Cnt = #StrList
    if Cnt == 2 then
        local TabModule = SettingsUtils[StrList[1]]
        local Func = TabModule[StrList[2]]
        if Func then
            Rlt = Func(TabModule, ...)
        end

        SettingsUtils.CurSetingCfg = nil
        return Rlt
    else
        FLOG_ERROR("Setting config GetDefaultIndex must like SettingsTabBase:GetMaxFPS")
    end

    return Rlt
end

--
function SettingsUtils.SwitchCheckFunc(FuncName, Cfg, ...)
    if not Cfg then
        return false, false
    end

    if string.isnilorempty(FuncName) then
        return true, true
    end

    SettingsUtils.CurSetingCfg = Cfg

    local StrList = string.split(FuncName, ":")
    local Cnt = #StrList
    if Cnt == 2 then
        local TabModule = SettingsUtils[StrList[1]]
        local Func = TabModule[StrList[2]]
        if Func then
            return Func(TabModule, ...)
        else
            FLOG_ERROR("Setting config CanSwitch, but not lua func")
        end
    else
        FLOG_ERROR("Setting config CanSwitch must like SettingsTabBase:CanXXX")
    end
    
    SettingsUtils.CurSetingCfg = nil

    return false, false
end

function SettingsUtils.CallSettingItemFunc(FuncName, Cfg, ...)
    if not Cfg then
        return nil
    end

    if string.isnilorempty(FuncName) then
        return nil
    end

    SettingsUtils.CurSetingCfg = Cfg

    local TabModuleStr = nil
    if not string.isnilorempty(Cfg.SetValueFunc) then
        TabModuleStr = Cfg.SetValueFunc
    else
        TabModuleStr = Cfg.GetValueFunc
    end

    if not TabModuleStr then
        return nil
    end

    local StrList = string.split(TabModuleStr, ":")
    local Cnt = #StrList
    if Cnt == 2 then
        local TabModule = SettingsUtils[StrList[1]]
        local Func = TabModule[FuncName]
        if Func then
            return Func(TabModule, ...)
        else
            FLOG_ERROR("Setting CallSettingItemFunc %s, but not lua func", FuncName)
        end
    else
        FLOG_ERROR("Setting not Get/Setxxx func %s", FuncName)
    end
    
    SettingsUtils.CurSetingCfg = nil

    return nil
end

function SettingsUtils.GetDropDownListNumValue(Index, DefauleNumValue)
    local NumValue = DefauleNumValue
    if SettingsUtils.CurSetingCfg then
        if SettingsMgr.IsWithEmulatorMode then
            if string.find(SettingsUtils.CurSetingCfg.SaveKey, "QualityLevel") then
                if Index == 6 then
                    return 5
                elseif Index == 7 then
                    return -1
                end
            end
        end

        local Cnt = #SettingsUtils.CurSetingCfg.Num
        if Index >= 1 and Index <= Cnt then
            NumValue = SettingsUtils.CurSetingCfg.Num[Index]
        end
    end

    return NumValue
end

--画质专用：比如抗锯齿，拿手机定级的画质，来匹配抗锯齿是哪一级
--画质的等级0~4， 0和1对应于抗锯齿的index是1,   3和4对应于抗锯齿的index是3
function SettingsUtils.GetDropDownListIndex(Value, SetingCfg)
    if SetingCfg then
        local Cnt = #SetingCfg.Num
        for index = Cnt, 1, -1 do
            if SetingCfg.Num[index] <= Value then
                return index
            end
        end
    end

    return 1
end

--通用的，仅仅是call到对应的Tab里的函数，跟设置表无关；没有特殊逻辑
function SettingsUtils.CallFunc(FuncName, ...)
    local bGetFuncNotConfig = string.isnilorempty(FuncName)
    if bGetFuncNotConfig then
        return
    end


    local StrList = string.split(FuncName, ":")

    local Rlt
    local Cnt = #StrList
    if Cnt == 2 then
        local TabModule = SettingsUtils[StrList[1]]
        local Func = TabModule[StrList[2]]
        if Func then
            Rlt = Func(TabModule, ...)
        end

        return Rlt
    else
        FLOG_ERROR("Setting FuncName must like SettingsTabBase:GetMaxFPS")
    end

    return Rlt
end

return SettingsUtils