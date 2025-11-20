--[[
Author: andre_lightpaw <andre@lightpaw.com>
Date: 2024-08-07 14:18:26
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-10-21 17:26:14
FilePath: \Script\Game\PWorld\Entrance\Entourage\PWorldEntourageMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local LogableMgr = require("Common/LogableMgr")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")

local GameNetworkMgr = nil
local CS_CMD = ProtoCS.CS_CMD.CS_CMD_ENTOURAGE
local SUB_CMD = ProtoCS.Entourage.EntourageCmd

local PWorldEntourageVM = require("Game/PWorld/Entrance/Entourage/PWorldEntourageVM")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")

local SidebarType = SidebarDefine.SidebarType

---@class PWorldEntourageMgr: LogableMgr
local PWorldEntourageMgr = LuaClass(LogableMgr)

function PWorldEntourageMgr:OnInit()
    self:SetLogName("PWorldEntourageMgr")
end

function PWorldEntourageMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
end

function PWorldEntourageMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnMajorProfSwitch)
    self:RegisterGameEvent(EventID.AppEnterForeground, self.OnAppEnterForeground)
    self:RegisterGameEvent(EventID.SidebarExpandOpen, self.OnSidebarExpandOpen)
end

function PWorldEntourageMgr:ReqEntourage(SubCmd, Params)
    local MsgBody = Params
    MsgBody.Cmd = SubCmd
	GameNetworkMgr:SendMsg(CS_CMD, SubCmd, MsgBody)
end

function PWorldEntourageMgr:ReqEnterSceneEntourage(EntID)
    EntID = EntID or _G.PWorldEntourageVM.CurEntID
    local NpcList = {}
    local RawNpcList = _G.PWorldEntourageVM:GenMemList(EntID)

    for _, Item in pairs(RawNpcList) do
        table.insert(NpcList, Item.ID)
    end

    local Params = {}
    local Prepare = {
        SceneID = EntID,
        NpcID = NpcList,
    }
    Params.Prepare = Prepare
    self:ReqEntourage(SUB_CMD.EntouragePrepare, Params)
end

function PWorldEntourageMgr:OpenEntourageMainUI(EntID)
    local function Nav()
        if _G.UIViewMgr:IsViewVisible(UIViewID.PWorldEntouragePanel) then
            _G.PWorldEntourageVM:OnMainPanelShow(EntID)
            return
        end
    
        -- compatible interact system
        _G.UIViewMgr:ShowView(UIViewID.PWorldEntouragePanel, {[2] = EntID})
    end
    
    if self.TimerOpenEntourageMain then
       self:UnRegisterTimer(self.TimerOpenEntourageMain) 
    end

    self.TimerOpenEntourageMain = self:RegisterTimer(Nav, 0.01, nil, nil, nil)
end

function PWorldEntourageMgr:GetConfirmState()
    return self.ConfirmStartTime ~= nil and not self:IsConfirmExpired()
end

---@deprecated
function PWorldEntourageMgr:StartConfirm(ExpireFunc)
    local CurTime = _G.TimeUtil.GetLocalTime()
    if self.ConfirmStartTime == nil or self:IsConfirmExpired() then
       self.ConfirmStartTime =  CurTime
    end

    self:ClearExpireTimer()

    local ElapsedTime = CurTime - self.ConfirmStartTime
    if ElapsedTime < 0 then
       ElapsedTime = 0 
    end

    local RemainTime = self:GetExpireDuration() - ElapsedTime
    local DelayTime = RemainTime
    if DelayTime <= 0 then
        -- avoid close instantly when onshow
       DelayTime = 0.1 
    end
    
    if type(ExpireFunc) == 'function' then
        self.ExpireTimerID = self:RegisterTimer(function ()
            ExpireFunc()
        end, DelayTime) 
    end

    return RemainTime
end

function PWorldEntourageMgr:EndConfirm()
    self:ClearExpireTimer()
    self.ConfirmStartTime = nil
end

function PWorldEntourageMgr:GetExpireDuration()
    return 60   --#TODO REFINE WITH CONFIG
end

function PWorldEntourageMgr:IsConfirmExpired()
    if self.ConfirmStartTime == nil then
        return false 
    end

    return _G.TimeUtil.GetLocalTime() - self.ConfirmStartTime >= self:GetExpireDuration()
end

function PWorldEntourageMgr:GetConfirmStartTime()
    return self.ConfirmStartTime
end

---@private
function PWorldEntourageMgr:ClearExpireTimer()
    if self.ExpireTimerID then
        self:UnRegisterTimer(self.ExpireTimerID)
        self.ExpireTimerID = nil
    end
end

function PWorldEntourageMgr:OnMajorProfSwitch()
    PWorldEntourageVM:UpdateVM()
end

function PWorldEntourageMgr:OnAppEnterForeground()
    if not self:GetConfirmState() then
        _G.UIViewMgr:HideView(UIViewID.EntourageConfirm)
        _G.SidebarMgr:RemoveSidebarItem(SidebarType.EntourageEnterConfirm)
        self:EndConfirm()
    end
end

function PWorldEntourageMgr:OnSidebarExpandOpen(ItemVM)
    if ItemVM.Type ~= SidebarType.EntourageEnterConfirm then
        return
    end

    -- 随从副本确认
    if self:GetConfirmState() then
        _G.UIViewMgr:ShowView(UIViewID.EntourageConfirm)
    else
        self:LogWarn("PWorldEntourageMgr:OnSidebarExpandOpen not in confirm state")
    end
end


return PWorldEntourageMgr
