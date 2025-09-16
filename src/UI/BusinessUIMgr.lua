-- Author: muyanli
-- Date: 2025-01-18 10:41:40
-- Description: 业务相关UI管理类
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
local UIViewID = require("Define/UIViewID")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local QuestMgr = require("Game/Quest/QuestMgr")

local FLOG_INFO = _G.FLOG_INFO
-- local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR

---@class BusinessUIMgr : MgrBase

local BusinessUIMgr = LuaClass(MgrBase)

function BusinessUIMgr:OnInit()
    self.CurrentMainUIViewID = nil
end

function BusinessUIMgr:OnBegin()

end

function BusinessUIMgr:OnEnd()

end

function BusinessUIMgr:OnShutdown()
    self.CurrentMainUIViewID = nil
end

function BusinessUIMgr:OnRegisterGameEvent()

end

---@param ViewID UIViewID
---@param Num boolean
function BusinessUIMgr:ShowMainPanel(ViewID, NeedInputMode)
    if ViewID == nil then
        ViewID = UIViewID.MainPanel
    end

    if NeedInputMode == nil then
        NeedInputMode = false
    end

    self.CurrentMainUIViewID = ViewID

    if ViewID == UIViewID.MainPanel then
        if QuestMgr.isUnlockProf then
            return
        end
        if _G.PWorldMgr:CurrIsInPVPColosseum() then
            return
        end
        UIViewMgr:ShowView(UIViewID.MainPanel)
        if NeedInputMode then
            CommonUtil.ShowJoyStick()
            UIUtil.SetInputMode_GameAndUI()
        end

    elseif ViewID == UIViewID.PVPColosseumMain then
        if not _G.PWorldMgr:CurrIsInPVPColosseum() then
            return
        end
        UIViewMgr:ShowView(UIViewID.PVPColosseumMain)

    elseif ViewID == UIViewID.ChocoboRaceMainView then
        UIViewMgr:ShowView(UIViewID.ChocoboRaceMainView)
    end
end

---@param ViewID UIViewID
---@param Num boolean
function BusinessUIMgr:HideMainPanel(ViewID, bImmediatelyHide, Params)
    if self.CurrentMainUIViewID == ViewID then

    end
    UIViewMgr:HideView(ViewID,bImmediatelyHide,Params)
end

---断线重连后恢复当前主界面，要考虑重连跨副本的情况
function BusinessUIMgr:RestoreMainPanel()
    local ViewID = self.CurrentMainUIViewID
    if ViewID == nil then
        ViewID = UIViewID.MainPanel
    end
    self:ShowMainPanel(ViewID)
end

return BusinessUIMgr
