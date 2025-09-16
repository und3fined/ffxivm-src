
local SettingsUtils = require("Game/Settings/SettingsUtils")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")

local LSTR = _G.LSTR
--未归类的，一些页签内容比较少，就没必要新增一个页签，就放这里得了

local SettingsTabUnCategory = {}

function SettingsTabUnCategory:OnInit()

end

function SettingsTabUnCategory:OnBegin()
end

function SettingsTabUnCategory:OnEnd()

end

function SettingsTabUnCategory:OnShutdown()

end

----------------------------------  其他设置 -----------------------------------------------
--- 导航
function SettingsTabUnCategory:GetNavigationState()
end

function SettingsTabUnCategory:SetNavigationState( Value, IsSave )
        local NaviDecalMgr = _G.NaviDecalMgr
        if Value == 1 then
                _G.QuestTrackMgr:SettingEnableNavigation()
		NaviDecalMgr:NaviPathToPos(NaviDecalMgr.TargetPos, NaviDecalMgr.CurNaviType, NaviDecalMgr.EForceType.TickForce)
        elseif Value == 2 then
                _G.QuestTrackMgr:SettingDisableNavigation()
                NaviDecalMgr:HideNaviPath()
        end

        -- if IsSave then
        --     USaveMgr.SetInt(SaveKey.NavigationState, Value, true)
        -- end
end

--界面设置：新手引导
function SettingsTabUnCategory:SetTutorialState(Value, IsSave)
        if Value == 1 then
                _G.NewTutorialMgr:EnableTutorial()
        elseif Value == 2 then
                _G.NewTutorialMgr:DisableTutorial()
        end

        if IsSave then
                -- USaveMgr.SetInt(SaveKey.TutorialState, Value, true)
                --- 发送给服务器
                _G.NewTutorialMgr:SendTutorialState()
        end
end

function SettingsTabUnCategory:SetTutorialGuideState(Value, IsSave)
        if Value == 1 then
                _G.TutorialGuideMgr:EnableTutorialGuide()
        elseif Value == 2 then
                _G.TutorialGuideMgr:DisableTutorialGuide()
        end

        if IsSave then
                -- USaveMgr.SetInt(SaveKey.TutorialState, Value, true)
                --- 发送给服务器
                _G.TutorialGuideMgr:SendTutorialGuideState()
        end
end

----------------------------------   -----------------------------------------------

return SettingsTabUnCategory