--
-- Author: sammrli
-- Date: 2024-4-3 14:55
-- Description:陆行鸟NPC交互入口
--

local LuaClass = require("Core/LuaClass")

local NpcCfg = require("TableCfg/NpcCfg")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")

local EntranceNpc = require("Game/Interactive/EntranceItem/EntranceNpc")
local ChocoboTransportDefine = require ("Game/Chocobo/Transport/ChocoboTransportDefine")

local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local FunctionItemFactory = require("Game/Interactive/FunctionItemFactory")

local EntranceChocoboNpc = LuaClass(EntranceNpc)

function EntranceChocoboNpc:OnInit()
    local Cfg = NpcCfg:FindCfgByKey(self.ResID)
    self.DisplayName = Cfg.Name
    --self.TargetName = Cfg.Name
    self.Cfg = Cfg
    self.NpcID = Cfg.ID or 0

    if not self.Distance or self.Distance <= 0 and self.EntityID then
        local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
        if Actor then
            self.Distance = Actor:GetDistanceToMajor()
        end
    end

    self.FunctionItemsList = {}

    local IdList = Cfg.InteractiveIDList
    if IdList and #IdList > 0 then
        local FisrtCfg = InteractivedescCfg:FindCfgByKey(IdList[1])

        if FisrtCfg and FisrtCfg.IsUseIconAndName == 1 then
            self.IconPath = FisrtCfg.IconPath
            self.DisplayName = FisrtCfg.DisplayName
        end
    end

    local MapID = _G.PWorldMgr:GetCurrMapResID()
    self.IsBook =  _G.ChocoboTransportMgr:IsBook(MapID, self.NpcID)
    if not self.IsBook then
        self.DisplayName = _G.LSTR(90006)
    end
end

function EntranceChocoboNpc:Update()
    local MapID = _G.PWorldMgr:GetCurrMapResID()
    self.IsBook =  _G.ChocoboTransportMgr:IsBook(MapID, self.NpcID)
    if self.IsBook then
        if self.Cfg then
            self.DisplayName = self.Cfg.Name
            self:UpdateUI()
        end
    end
end

function EntranceChocoboNpc:OnClick()
    --[[
    local MapID = _G.PWorldMgr:GetCurrMapResID()
    local AttributeComp = ActorUtil.GetActorAttributeComponent(self.EntityID)
    if not AttributeComp then
        return
    end
    ]]
    if MajorUtil.IsMajorCombat() then
        _G.MsgTipsUtil.ShowTips(_G.LSTR(90007))
        return
    end
    if self.IsBook then
        local FunctionList = self:GenFunctionList()
        if FunctionList then
            if #FunctionList > 2 then
                _G.InteractiveMgr:SetFunctionList(FunctionList)
            elseif #FunctionList > 1 then
                FunctionList[1]:Click() --只有两个(一个是离开),不显示二级菜单直接执行Function 1
            end
        end
    else
        local DefaultDialogID = self:GetDefaultDialogID(self.NpcID)
        if DefaultDialogID and DefaultDialogID > 0 then
            local function DialogFinishCallBack()
                --陆行鸟Npc登记
                local MapID = _G.PWorldMgr:GetCurrMapResID()
                _G.ChocoboTransportMgr:SendChocoboTransferBook(MapID)
            end
            if self.Cfg then
                self.DisplayName = self.Cfg.Name
                self:UpdateUI()
            end
            _G.NpcDialogMgr:PlayDialogLib(DefaultDialogID, self.EntityID, true, DialogFinishCallBack, true, true)
        else
            FLOG_ERROR(string.format("[ChocoboTransport] MapID=%s Npc=%s dont have DefaultDialogID ", tostring(MapID), tostring(self.NpcID)))
        end
    end
end

function EntranceChocoboNpc:GetDefaultDialogID(NpcResID)
    if NpcResID then
        local NpcCfgItem = NpcCfg:FindCfgByKey(NpcResID)
        if NpcCfgItem then
            return NpcCfgItem.SwitchTalkID
        end
    end
    return nil
end

function EntranceChocoboNpc:OnGenFunctionList()
    local FunctionList = {}
    if not self.IsBook then
        return FunctionList
    end

    -- NPC表中的功能选项
    local NpcResID = self.ResID
    local Cfg = self.Cfg
    local IdList = Cfg.InteractiveIDList

    for i = 1, #IdList do
        local ReUse = false
        for idx = 1, #self.FunctionItemsList do
            local FunctionItem = self.FunctionItemsList[idx]
            if FunctionItem.FuncParams.FuncValue == IdList[i] then
                ReUse = true
                table.insert(FunctionList, FunctionItem)
                table.remove(self.FunctionItemsList, idx)
                break
            end
        end

        if not ReUse then
            local InteractFunctionUnit = FunctionItemFactory:CreateInteractiveDescFunc(
                        {FuncValue = IdList[i], EntityID = self.EntityID, ResID = NpcResID}) 
            if InteractFunctionUnit then
                table.insert(FunctionList, InteractFunctionUnit)
            end
        end
    end

    local QuitFunctionUnit = FunctionItemFactory:CreateFunction(_G.LuaFuncType.NPCQUIT_FUNC
            , _G.LSTR(90003), { FuncValue = Cfg.EndDialogID, EntityID = self.EntityID, ResID = NpcResID})
        table.insert(FunctionList, QuitFunctionUnit)

    return FunctionList
end


function EntranceChocoboNpc:GetIconPath()
    return ChocoboTransportDefine.ICON_ACTIVE_MARKER
end

return EntranceChocoboNpc