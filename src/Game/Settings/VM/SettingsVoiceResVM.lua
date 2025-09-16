local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local AudioUtil = require("Utils/AudioUtil")
local SettingsDefine = require("Game/Settings/SettingsDefine")
local LanguageType = SettingsDefine.LanguageType


---@class SettingsVoiceResVM : UIViewModel
local SettingsVoiceResVM = LuaClass(UIViewModel)


function SettingsVoiceResVM:Ctor()
    self.CurrentSelectIndex = 1
    self.LanguageList = {}
end

function SettingsVoiceResVM:OnInit()
    self.DownLoadIdxList = {}
end

function SettingsVoiceResVM:OnBegin()
end

function SettingsVoiceResVM:OnEnd()
    self.DownLoadIdxList = {}
end

function SettingsVoiceResVM:OnShutdown()
end

function SettingsVoiceResVM:RecordDownLoad(Idx)
    if Idx then
        table.insert(self.DownLoadIdxList, Idx)
    end
end

function SettingsVoiceResVM:RefreshLanguageList(bResetIdx)
    local AreaPkgCfgList = SettingsUtils.SettingsTabLanguages:GetVoicePkgsList()
    if AreaPkgCfgList then
        local CurLanguageName = AudioUtil.GetCurrentCulture()
        local NameList = {}
        local CurLanguageDescIdx = SettingsDefine.LanguageType[CurLanguageName]
        local ExistList = AudioUtil.GetExistingCultureList()

        local MBSize = 1024 * 1024

        for index = 1, #AreaPkgCfgList do
            local CfgName = AreaPkgCfgList[index].LanguageName
            local bExist = false
            for j = 1, #ExistList do
                if CfgName == ExistList[j] then
                    FLOG_INFO("setting %s is exist", CfgName)
                    bExist = true
                    break
                end
            end

            if not bExist then  --仅仅是保险了
                for k = 1, #self.DownLoadIdxList do
                    if index == self.DownLoadIdxList[k] then
                        FLOG_INFO("setting %s is DownLoad", CfgName)
                        bExist = true
                    end
                end
            end

            local LanguageType = LanguageType[CfgName]
            local Size = _G.UE.UVersionMgr.Get():GetL10nSize(_G.UE.EGameL10nType.Voices, LanguageType)
            local PkgSize = Size / MBSize

            -- local bDefault = AreaPkgCfgList[index].DefaultVoice
            -- if not bExist then
            --     bDefault = false
            -- end

            if CurLanguageName == CfgName then
                local NameStr = string.format(_G.LSTR(110014)
                    , SettingsDefine.LanguagesDesc[LanguageType]
                    , SettingsDefine.UsingDesc[index])

                table.insert(NameList, {Text = NameStr, IsUsing = bExist, IsExist = bExist, Idx = index
                                        , LanguageName = CfgName, LanguageType = LanguageType
                                        , PkgSize = PkgSize})--, IsDefault = bDefault

                if bResetIdx then
                    self.CurrentSelectIndex = index
                end
            else
                table.insert(NameList, {Text = SettingsDefine.LanguagesDesc[LanguageType], IsExist = bExist, Idx = index
                                        , LanguageName = CfgName, LanguageType = LanguageType
                                        , PkgSize = PkgSize})--, IsDefault = bDefault
            end
        end

        self.LanguageList = NameList
    end
end

function SettingsVoiceResVM:GetCurSelectData()
    return self.LanguageList[self.CurrentSelectIndex]
end

function SettingsVoiceResVM:SetCurSelect(CurIdx)
    self.CurrentSelectIndex = CurIdx
end

return SettingsVoiceResVM