--[[
Author: andre_lightpaw <andre@lightpaw.com>
Date: 2024-08-07 14:18:26
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-10-21 17:26:14
FilePath: \Script\Game\PWorld\Entrance\Entourage\PWorldEntourageMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")

local GameNetworkMgr = nil
local CS_CMD = ProtoCS.CS_CMD.CS_CMD_ENTOURAGE
local SUB_CMD = ProtoCS.Entourage.EntourageCmd

---@class PWorldEntourageMgr: MgrBase
local PWorldEntourageMgr = LuaClass(MgrBase)

function PWorldEntourageMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
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
        if _G.UIViewMgr:IsViewVisible(_G.UIViewID.PWorldEntouragePanel) then
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


return PWorldEntourageMgr
