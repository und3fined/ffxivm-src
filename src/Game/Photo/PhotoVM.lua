local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoVM = LuaClass(UIViewModel)
local PhotoDefine = require("Game/Photo/PhotoDefine")

local UIBindableList = require("UI/UIBindableList")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")
local PhotoActorUtil = require("Game/Photo/Util/PhotoActorUtil")
local PhotoSceneUtil = require("Game/Photo/Util/PhotoSceneUtil")


-- local ItemVM = require("Game/Item/ItemVM")
local PhotoSubTabItemVM = require("Game/Photo/ItemVM/PhotoSubTabItemVM")

local LSTR = _G.LSTR

local PWorldQuestMgr
local PWorldMgr
local PWorldTeamMgr


function PhotoVM:Ctor()
    self.SubTabList = UIBindableList.New(PhotoSubTabItemVM)
    self:Reset()
end

function PhotoVM:Reset()
    self.Title = ""
    self.SubTitle = PhotoDefine.UITabNameMain[PhotoDefine.UITabMain.Camera]

    self.MainTabIdx = 1
    self.SubTabIdx  = 1

    -- 眼神跟随
    self.IsFollowWithEye = false

    -- 面向跟随
    self.IsFollowWithFace = true


    -- 九宫格
    self.IsShowCheckerboard = false

    -- 关闭UI
    self.IsHideUI = false

    -- 移动冻结
    self.IsBanMove = false

    -- 对象暂停
    self.IsPauseSelect = false
    self.IsPauseWeather = true
    self.IsPauseAll = false
    self.IsShowPausePanel = false

    -- 全体赋予
    self.IsGiveAll = false

    -- Visiable
    self.CanGiveAll = false

    self.IsShowLP = true
    self.IsShowRP = true

    self.IsHideContent = false --是否显示UI

    self.IsInMoveMode = false
end

function PhotoVM:OnInit()
end

function PhotoVM:InitSubTabData()
    self.SubTabData = {}

    -- 临时屏蔽时间天气，等监修过在删除代码开放
    local Copy = table.deepcopy(PhotoDefine.UITabSub)
    Copy[3].Scene = nil

    for MainTab, SubTabDef in pairs(Copy) do
        self.SubTabData[MainTab] = {}
        for _, Idx in pairs(SubTabDef) do
            self.SubTabData[MainTab][Idx] = {
                Idx = Idx,
                Name = PhotoDefine.UITabNameSub[MainTab][Idx]
            }
        end
    end
end

function PhotoVM:OnBegin()
    -- PWorldQuestMgr = _G.PWorldQuestMgr
    -- PWorldMgr = _G.PWorldMgr
    -- PWorldTeamMgr = _G.PWorldTeamMgr

    self:InitSubTabData()
end

function PhotoVM:OnEnd()
end

function PhotoVM:OnShutdown()
end

function PhotoVM:UpdateVM()
    self:Reset()
    self:UpdCanGiveAll()
    
end

function PhotoVM:OnTimer()
end

-------------------------------------------------------------------------------------------------------
---@region Update

function PhotoVM:UpdCanGiveAll()
    local CanGiveAll = true
    local MainIdx = PhotoDefine.UITabMain.Role
    if self.MainTabIdx == MainIdx and self.SubTabIdx == PhotoDefine.UITabSub[MainIdx].Stat then
        CanGiveAll = _G.TeamMgr:IsInTeam()
    end

    self.CanGiveAll = CanGiveAll
end

function PhotoVM:UpdSubTabList()
    local MainData = self.SubTabData[self.MainTabIdx]

    if MainData then
        self.SubTabList:UpdateByValues(MainData)
    end
end

-------------------------------------------------------------------------------------------------------
---@region Set

function PhotoVM:SetMainTabIdx(Idx)
    self.MainTabIdx  = Idx
    self.SubTabIdx = nil
    self.SubTitle = PhotoDefine.UITabNameMain[self.MainTabIdx] or ""
    self:UpdSubTabList()
end

function PhotoVM:SetSubTabIdx(Idx)
    self.SubTabIdx = Idx
    -- if PhotoDefine.UITabNameSub[self.MainTabIdx] then
    --     self.SubTitle = PhotoDefine.UITabNameSub[self.MainTabIdx][Idx]
    -- end
end

function PhotoVM:SetIsInMoveMode(V)
    self.IsInMoveMode = V

    self:UpdIsShowLP()
    self:UpdIsShowRP()
end

function PhotoVM:SetIsHideContent(V)
    self:SetIsBanMove(V)
    self.IsHideContent  = V

    if not V then
        _G.UE.USelectEffectMgr.Get():ShowDecal(true)
    else
        _G.UE.USelectEffectMgr.Get():ShowDecal(false)
    end
end

function PhotoVM:TryRptPause()
    if self.IsPauseSelect then
        self:SetIsPauseSelect(false)
    end
end

function PhotoVM:SetIsPauseSelect(V)
    if _G.PhotoMgr:IsCurSeltMajor() then
        self:SetIsBanMove(V)
    end
    self.IsPauseSelect = V
    _G.PhotoMgr:PauseSeltAnim(V)
end

function PhotoVM:SetIsPauseWeather(V)
    self.IsPauseWeather  = V
    PhotoSceneUtil.PauseWeather(V)
end

function PhotoVM:SetIsPauseAll(V)
    self:SetIsBanMove(V)
    self.IsPauseAll = V
    PhotoActorUtil.PauseAllActorAnim(V)
end

function PhotoVM:SetIsBanMove(V)
    self.IsBanMove = V

    if V then
		CommonUtil.HideJoyStick()
        CommonUtil.DisableShowJoyStick(true)
	else
        CommonUtil.DisableShowJoyStick(false)
		CommonUtil.ShowJoyStick()
	end

    -- _G.PhotoRoleStatVM:TryRptStat()
end

-------------------------------------------------------------------------------------------------------
---@region Update Property

function PhotoVM:UpdIsShowLP()
    self.IsShowLP = not self.IsInMoveMode
end

function PhotoVM:UpdIsShowRP()
    self.IsShowRP = not self.IsInMoveMode
end

-------------------------------------------------------------------------------------------------------
---@region template setting

function PhotoVM:TemplateSave(InTemplate)
    PhotoTemplateUtil.SetMain(InTemplate, self.IsFollowWithFace, self.IsFollowWithEye)
end

function PhotoVM:TemplateApply(InTemplate)
    local Info = PhotoTemplateUtil.GetMain(InTemplate)

    if Info then
        self.IsFollowWithFace = Info.IsFollowFace
        self.IsFollowWithEye = Info.IsFollowEye
    end
end

return PhotoVM