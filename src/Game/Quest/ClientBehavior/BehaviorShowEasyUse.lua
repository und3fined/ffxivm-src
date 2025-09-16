---
--- Author: sammrli
--- DateTime: 2024-8-28
--- Description:客户端行为 触发道具快捷使用提示
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local ProtoRes = require("Protocol/ProtoRes")

local ClientBehaviorCfg = require("TableCfg/QuestClientActionCfg")

---@class BehaviorShowEasyUse
local BehaviorShowEasyUse = LuaClass(BehaviorBase, true)

function BehaviorShowEasyUse:Ctor(_, Properties)
    self.ItemID = tonumber(Properties[1]) or 0
    self.DelayTime = tonumber(Properties[2]) or 0
    if self.DelayTime == 0 then
        self.DelayTime = 3
    end
end

function BehaviorShowEasyUse:DoStartBehavior()
    local IsLoadingWorld = _G.PWorldMgr:IsLoadingWorld()
    if IsLoadingWorld then
        -- 正在切图异常情况处理
        _G.TimerMgr:AddTimer(self, self.DelayShow, self.DelayTime)
        return
    end

    local Item = _G.BagMgr:GetItemByResID(self.ItemID)
    if Item then
        _G.SidePopUpMgr:AddSidePopUp(ProtoRes.side_popup_type.SIDE_POPUP_EASY_USE, _G.UIViewID.SidePopUpEasyUse, Item)
    end
end

function BehaviorShowEasyUse:PassiveStartBehavior()
    local Item = _G.BagMgr:GetItemByResID(self.ItemID)
    if Item then
        _G.SidePopUpMgr:AddSidePopUp(ProtoRes.side_popup_type.SIDE_POPUP_EASY_USE, _G.UIViewID.SidePopUpEasyUse, Item)
    end
end

function BehaviorShowEasyUse:DelayShow()
    -- 保护,断线或其他异常
    local ClientBehaviorCfgItem = ClientBehaviorCfg:FindCfgByKey(self.BehaviorID)
    if ClientBehaviorCfgItem then
        if _G.QuestMgr.ChapterMap[ClientBehaviorCfgItem.ChapterID] then
            local Item = _G.BagMgr:GetItemByResID(self.ItemID)
            if Item then
                _G.SidePopUpMgr:AddSidePopUp(ProtoRes.side_popup_type.SIDE_POPUP_EASY_USE, _G.UIViewID.SidePopUpEasyUse, Item)
            end
        end
    end
end

return BehaviorShowEasyUse