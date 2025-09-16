---
--- Author: xingcaicao
--- DateTime: 2024-04-19 11:32
--- Description:
---
---

local CommonUtil = require("Utils/CommonUtil")
local SettingsDefine = require("Game/Settings/SettingsDefine")
local GamePakAreaCfg = require("TableCfg/GamePakAreaCfg")
local AudioUtil = require("Utils/AudioUtil")
local SettingsDefine = require("Game/Settings/SettingsDefine")

local LanguageType = SettingsDefine.LanguageType

local SettingsTabLanguages = {}

function SettingsTabLanguages:OnInit()
    self.VersionPakAreaCfgList = {}
    self.VersionDefaultVoiceIdx = -1
    self.VersionDefaultLanguageIdx = -1
end

function SettingsTabLanguages:OnBegin()
end

function SettingsTabLanguages:OnEnd()

end

function SettingsTabLanguages:OnShutdown()

end

----------------------------------  游戏语言 -----------------------------------------------

function SettingsTabLanguages:GetCurrentCulture()
    local CurCultureName = CommonUtil.GetCurrentCultureName()
    if string.isnilorempty(CurCultureName) then
        return 1 
    end

    return LanguageType[CurCultureName] or 1
end

function SettingsTabLanguages:SetCurrentCulture( CultureIdx, IsSave)
    if nil == CultureIdx then
        return
    end

    if not IsSave then
        return
    end

    local Languages = table.invert(LanguageType)
    local InCultureName = Languages[CultureIdx]
    if string.isnilorempty(InCultureName) then
        return
    end

    CommonUtil.SetCurrentCulture(InCultureName, true)
    CommonUtil.QuitGame()
end

----------------------------------  游戏语音 -----------------------------------------------
---
function SettingsTabLanguages:GetVoiceCulture( )
    local CurCultureName = AudioUtil.GetCurrentCulture()
    if string.isnilorempty(CurCultureName) then
        return 1 
    end

    return LanguageType[CurCultureName] or 1
end

--设置项右侧显示的Value对应的文本内容
function SettingsTabLanguages:GetContentByPkgVoices(CultureIdx)
    if CultureIdx <= 0 or CultureIdx > #SettingsDefine.LanguagesDesc then
        return "", 0
    end

    local LanguageName = SettingsDefine.LanguagesDesc[CultureIdx]
    return LanguageName, _G.UIViewID.SettingsVoiceResPanel
end

function SettingsTabLanguages:GetDefaultVoiceIdx()
    self:InitVoicePkgsList()
    
    local CurCultureName = AudioUtil.GetCurrentCulture()
    if string.isnilorempty(CurCultureName) then
        FLOG_ERROR("setting GetCurrentCulture Failed")
        -- if self.VersionPakAreaCfgList and self.VersionDefaultVoiceIdx > 0
        --     and #self.VersionPakAreaCfgList >= self.VersionDefaultVoiceIdx then
        --     local Cfg = self.VersionPakAreaCfgList[self.VersionDefaultVoiceIdx]
        --     if Cfg then
        --         local CultureName = Cfg.LanguageName
        --         FLOG_INFO("setting GetDefaultVoiceName1 %s", CultureName)
        --         return LanguageType[CultureName] or 1
        --     end
        -- end
    else
        FLOG_INFO("setting GetDefaultVoiceName2 %s", CurCultureName)
        return LanguageType[CurCultureName] or 1
    end

    return -1
end

function SettingsTabLanguages:SetVoiceCulture( CultureIdx )
    if nil == CultureIdx or CultureIdx <= 0 then
        return
    end

    local Languages = table.invert(LanguageType)
    local InCultureName = Languages[CultureIdx]
    if string.isnilorempty(InCultureName) then
        return
    end

    AudioUtil.SetCurrentCulture(InCultureName)
end

function SettingsTabLanguages:GetVoicePkgsList()
    self:InitVoicePkgsList()
    
    return self.VersionPakAreaCfgList
end

function SettingsTabLanguages:InitVoicePkgsList()
    if self.VersionPakAreaCfgList and #self.VersionPakAreaCfgList > 0 then
        return
    end

    local PkgArea = _G.UE.UVersionMgr.GetGamePkgArea() + 1
    self.VersionPakAreaCfgList = GamePakAreaCfg:FindAllCfg(string.format("PakArea == \"%d\"", PkgArea))
    for index = 1, #self.VersionPakAreaCfgList do
        local Cfg = self.VersionPakAreaCfgList[index]
        if Cfg then
            if Cfg.DefaultVoice == 1 then
                self.VersionDefaultVoiceIdx = index --无用的配置的字段 DefaultVoice
                break
            elseif Cfg.DefaultLanguage == 1 then
                self.VersionDefaultLanguageIdx = index
                break
            end
        end
    end
end

return SettingsTabLanguages
