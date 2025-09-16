local SaveKey = require("Define/SaveKey")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")

local AudioMgr
local AudioType
local LSTR = _G.LSTR

local SettingsTabSound = {}

function SettingsTabSound:OnInit()

end

function SettingsTabSound:OnBegin()
    AudioMgr    = _G.UE.UAudioMgr:Get()
    AudioType   = _G.UE.EWWiseAudioType
end

function SettingsTabSound:OnEnd()

end

function SettingsTabSound:OnShutdown()

end

--------------------------------  声音设置 --------------------------------------------
---整体音量
function SettingsTabSound:SetGlobalVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.Global_Volume, Value)
end

---背景音乐音量
function SettingsTabSound:SetMusicVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.Music, Value)
end

---主角自身
function SettingsTabSound:SetMainPlayerVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.MainPlayer, Value)
end

---音效
function SettingsTabSound:SetSfxVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.Sfx, Value)
end

---语音音量
function SettingsTabSound:SetVoicesVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.Voices, Value)
end

---系统音量(UI声音)
function SettingsTabSound:SetUISoundVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.UI_Menu_Sound, Value)

    _G.CgMgr.G_VideoVolume = Value / 100
    _G.UE.USaveMgr.SetInt(SaveKey.VideoVolume, Value, false)
end

---环境音量
function SettingsTabSound:SetAmbientVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.Ambient_Sound, Value)
end

--乐器演奏
function SettingsTabSound:SetInstrumentsVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.Instruments, Value)
end

function SettingsTabSound:SetInstrumentsMainPlayerVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.Instruments_volume_MainPlayer, Value)
end

function SettingsTabSound:SetInstrumentsOthersVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.Instruments_volume_Others, Value)
end

--小队
function SettingsTabSound:SetTeammateVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.Teammate, Value)
end

--他人
function SettingsTabSound:SetEnemyVol( Value, IsSave )
    AudioMgr:SetAudioVolume(AudioType.Enemy, Value)
end

--乘骑状态下播放音乐
function SettingsTabSound:SetMountBGM( Value, IsSave )
    if Value == 1 then
        _G.MountMgr:PlayMountBGM()
    else
        _G.MountMgr:StopMountBGM()
    end
    _G.EventMgr:SendEvent(_G.EventID.MountBgmSettingChange, Value == 1)
end

--后台语音开关
function SettingsTabSound:SetBgVoice(Value, IsSave , IsLoginInit, IsBySelect)
    if Value == 1 then
        -- 开启
    else
        -- 关闭
        if IsBySelect == true then
            local function CancelCallback()
                _G.UE.USaveMgr.SetInt(SaveKey.BgVoiceSetting, 1, false)
                _G.ClientSetupMgr:SendSetReq(ClientSetupID.CSBgVoiceSetting, "1")
                _G.EventMgr:SendEvent(_G.EventID.BgVoiceCloseCancel, 1)
            end
            local function ConfirmCallback()
                _G.UE.USaveMgr.SetInt(SaveKey.BgVoiceSetting, 2, false)
                _G.ClientSetupMgr:SendSetReq(ClientSetupID.CSBgVoiceSetting, "2")
            end
            -- 110025 提 示
            -- 110048 关闭此功能将关闭后台语音，某些场景下将游戏切至后台可能会导致进程被系统关闭，是否确认关闭？
            -- 110021 取 消
            -- 110032 确 认
            _G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(110025), LSTR(110048), ConfirmCallback, CancelCallback, LSTR(110021), LSTR(110032))
            return true
        end
    end

    if IsSave then
        _G.UE.USaveMgr.SetInt(SaveKey.BgVoiceSetting, Value, false)
        _G.ClientSetupMgr:SendSetReq(ClientSetupID.CSBgVoiceSetting, tostring(Value))
    end

    return true
end

function SettingsTabSound:GetDefaultBgVoiceIndex()
    local IsAudit = _G.UE.UGCloudMgr.Get():IsAppAuditing()
    if IsAudit == true then
        -- 提审状态
        return 2
    end
    return 1
end

--子类别 右侧加按钮的测试
function SettingsTabSound:ResetMountSound()
    _G.MsgTipsUtil.ShowTips("ResetMountSound Test")
end

return SettingsTabSound