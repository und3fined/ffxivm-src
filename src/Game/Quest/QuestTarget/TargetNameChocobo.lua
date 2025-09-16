---
--- Author: sammrli
--- DateTime: 2024-02-19
--- 目标：给陆行鸟取名

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local QuestHelper = require("Game/Quest/QuestHelper")
local ProtoRes = require("Protocol/ProtoRes")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local EventID = require("Define/EventID")

local QuestTargetNameType = ProtoRes.Quest_Target_Name_Type

---@class TargetNameChocobo
local TargetNameChocobo = LuaClass(TargetBase, true)

function TargetNameChocobo:Ctor(_, Properties)
    self.BeforeDialogID = tonumber(Properties[1]) or 0
    self.NpcID = tonumber(Properties[2]) or 0
    self.AfterDialogID = tonumber(Properties[3]) or 0
    self.NameType = tonumber(Properties[4]) or 0
end

function TargetNameChocobo:DoStartTarget()
    if self.NameType == QuestTargetNameType.BUDDY then
        if self.NpcID > 0 then
            QuestHelper.AutoNPCDialog(self.QuestID, self.TargetID, self.NpcID, self.BeforeDialogID)
        end
    elseif self.NameType == QuestTargetNameType.RACE_CHOCOBO then
        _G.UIViewMgr:ShowView(_G.UIViewID.ChocoboSelectSexView, {Source = ChocoboDefine.SOURCE.TASK})
    end

    self:RegisterEvent(EventID.BuddyRenameSuccess, self.OnEventBuddyRenameSuccess)
    self:RegisterEvent(EventID.ChocoboNameTaskRevert, self.OnEventChocoboNameTaskRevert)
end

function TargetNameChocobo:FinishDialog()
    if self.NameType == QuestTargetNameType.BUDDY then
        _G.BuddyMgr:OpenRenamePanel()
    end
end

function TargetNameChocobo:OnEventBuddyRenameSuccess()
    if self.NameType == QuestTargetNameType.BUDDY then
        local CallBack = function()
            _G.QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
        end
        _G.NpcDialogMgr:PlayDialogLib(self.AfterDialogID, nil, nil, CallBack)
    elseif self.NameType == QuestTargetNameType.RACE_CHOCOBO then
        _G.QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
    end
end

function TargetNameChocobo:OnEventChocoboNameTaskRevert()
    if self.NameType == QuestTargetNameType.RACE_CHOCOBO then
        _G.QuestMgr:SendTargetRevert(self.TargetID)
    end
end

function TargetNameChocobo:GetNpcID()
    return self.NpcID
end

function TargetNameChocobo:GetDialogID()
    return self.BeforeDialogID
end

return TargetNameChocobo