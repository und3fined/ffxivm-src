--
-- Author: frankjfwang
-- Date: 2021-12-05
-- Description:共鸣水晶一级入口
--


local LuaClass = require("Core/LuaClass")
local EntranceBase = require("Game/Interactive/EntranceItem/EntranceBase")
local FunctionItemFactory = require("Game/Interactive/FunctionItemFactory")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local MountVM = require("Game/Mount/VM/MountVM")
local ProtoCS = require("Protocol/ProtoCS")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")
local CS_QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local LSTR = _G.LSTR
--local LuaEntranceType = _G.LuaEntranceType
local LuaFuncType = _G.LuaFuncType

---@class EntranceCrystalPortal : EntranceBase
local EntranceCrystalPortal = LuaClass(EntranceBase)
function EntranceCrystalPortal:Ctor()
    self.TargetType = _G.LuaEntranceType.CRYSTAL
end

--计算Distance、入口的显示字符串
function EntranceCrystalPortal:OnInit()
    self.Distance = 0
    self.EntranceHalf = 100

    local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
    self.Crystal = CrystalMgr:GetCrystalByEntityId(self.EntityID)

    if not self.Crystal then
        return
    end

    if not self.Crystal.IsActivated then
        self.DisplayName = _G.LSTR(90008)
    else
        --self.DisplayName = self.Crystal.DBConfig.CrystalName
        if self.Crystal.DBConfig.Type == 2 then
            self.DisplayName = _G.LSTR(90009)
        else
            --self.DisplayName = self.Crystal.DBConfig.CrystalName
            self.DisplayName = _G.LSTR(90010)
        end
    end

    --self.TargetName = self.Crystal.DBConfig.CrystalName

    if self.Crystal.DBConfig then
        --水晶都长的一样，这里写死高度
        if self.Crystal.DBConfig.Type == 1 then
            self.EntranceHalf = 1000
        else
            self.EntranceHalf = 150
        end
    end
end

-- 覆盖Base方法
function EntranceCrystalPortal:CheckEyeLineBlock()
    -- if self.Crystal and self.Crystal.DBConfig then
    --     local Config = self.Crystal.DBConfig
    --     local Major = MajorUtil.GetMajor()
    --     if Major then
    --         local EntranceActorPos = _G.UE.FVector(Config.X, Config.Y, Config.Z)
    --         local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
    --         if  _G.UE.UActorUtil.EyeLineTraceByPos(MajorPos, EntranceActorPos) then
    --             --FLOG_WARNING("InteractiveMgr %d Cann't See", self.EntityID)
    --             return false
    --         end
    --     end
    -- end

    return true
end

function EntranceCrystalPortal:CheckInterative(EnableCheckLog)
    if not self.Crystal then
        if self.EntityID then --有值,尝试恢复数据
            local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
            self.Crystal = CrystalMgr:GetCrystalByEntityId(self.EntityID)
            self:Update()
        end
    end
    if self.Crystal then
        if self.Crystal.IsActivated and self.Crystal.DBConfig then
            if self.Crystal.DBConfig.TransferPopup == 0 then
                return false
            end
        end
    else
        return false
    end
    if not self:CheckEyeLineBlock() then
        return false
    end

    if MountVM.IsMajorInFly then
        return false
    end

    return true
end

function EntranceCrystalPortal:OnUpdateDistance()
    --_G.FLOG_INFO("EntranceCrystalPortal:OnUpdateDistance, IsActivated:%s", tostring(self.Crystal.IsActivated))
    if nil ~= self.Crystal and not self.Crystal.IsActivated then
        self.Distance = 0
        self.InteractivePriority = 1
    else
        self.Distance = 5000
        self.InteractivePriority = 0
    end
end

--Entrance的响应逻辑
function EntranceCrystalPortal:OnClick()
    if not self.Crystal then
        return nil
    end

    --打断当前技能(如果有)
    local CombatComponent = MajorUtil.GetMajorCombatComponent()
    if CombatComponent then
        CombatComponent:BreakSkill()
    end

    if self.EntityID then
        local CrystalPort = self.Crystal
        local TargetPos = _G.UE.FVector(CrystalPort.Pos.X, CrystalPort.Pos.Y, CrystalPort.Pos.Z)
        MajorUtil.LookAtPos(TargetPos)
    end

    if not self.Crystal.IsActivated then
        local DBConfig = self.Crystal.DBConfig
        if DBConfig and DBConfig.ActiviteQuestID and DBConfig.ActiviteQuestID > 0 then
            local QuestStatus = _G.QuestMgr:GetQuestStatus(DBConfig.ActiviteQuestID)
            local IsCanActivite = QuestStatus == CS_QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS or QuestStatus == CS_QUEST_STATUS.CS_QUEST_STATUS_FINISHED
            if IsCanActivite then
                local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
                CrystalMgr:SendActivateReq(self.Crystal)
            else
                if not string.isnilorempty(DBConfig.PromptText) then
                    _G.MsgTipsUtil.ShowTips(DBConfig.PromptText)
                end
            end
        else
            local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
            CrystalMgr:SendActivateReq(self.Crystal)
        end
    else
        --self:AfterClickEntrance()
        if self.Crystal.DBConfig.Type == 2 then
            --小水晶不具备分线查询功能，直接显示当前地图
            _G.WorldMapMgr:ShowWorldMap()
        else
            _G.InteractiveMgr:StopQueryPWorldBranchTimer()
            _G.InteractiveMgr:StartQueryPWorldBranchTimer()
            _G.InteractiveMgr:SetCurCrystalEntrance(self)
        end
    end
end

function EntranceCrystalPortal:AfterClickEntrance()
    if _G.InteractiveMgr.bHasPWorldBranch or self:HasCrossFunction() then
        local FunctionList = self:GenFunctionList()
        if FunctionList and #FunctionList > 0 then
            _G.InteractiveMgr:SetFunctionList(FunctionList)
        end
    else
        --没有地图分线直接打开当前地图
        _G.WorldMapMgr:ShowWorldMap()
    end
    _G.InteractiveMgr:SetCurCrystalEntrance(nil)
end

function EntranceCrystalPortal:HasCrossFunction()
    if self.Crystal and self.Crystal.DBConfig then
        local CrossTransferInterativeID = self.Crystal.DBConfig.CrossTransferInterativeID
        if CrossTransferInterativeID then
            return CrossTransferInterativeID > 0
        end
    end
    return false
end

function EntranceCrystalPortal:OnTimerAfterClick()
    _G.InteractiveMgr:ShowMainPanel()
end

function EntranceCrystalPortal:OnGenFunctionList()
    if self.Crystal == nil then
        return {}
    end

    local DBConfig = self.Crystal.DBConfig
    if not DBConfig then
        _G.MsgTipsUtil.ShowTips(_G.LSTR(90011))
        return {}
    else
        local FunctionList = {}

        local FuncParams = {
            FuncValue = DBConfig.TransferInterativeID,
            EntityID = DBConfig.ID,
            ResID = DBConfig.CrystalID,
            OverwriteIcon = "Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Icon_OpenMap.UI_NPC_Icon_OpenMap'",
            DisplayName = _G.LSTR(90012)
        }

        local FunctionUnit = FunctionItemFactory:CreateInteractiveDescFunc(FuncParams)
        if FunctionUnit then
            table.insert(FunctionList, FunctionUnit)
        end

        local CrossTransferInterativeID = DBConfig.CrossTransferInterativeID
        local CrystalID = DBConfig.CrystalID
        if CrossTransferInterativeID and CrossTransferInterativeID > 0 then
            local CrossParams = {
                FuncValue = CrossTransferInterativeID,
                EntityID = DBConfig.ID,
                ResID = CrystalID,
                CrystalID = CrystalID,
                IsTransferInterAct = true
            }
            local CrossUnit = FunctionItemFactory:CreateInteractiveDescFunc(CrossParams)
            if CrossUnit then
                table.insert(FunctionList, CrossUnit)
            end
        end

        if _G.InteractiveMgr.bHasPWorldBranch then
            local BranchLineParams = {
                FuncValue = DBConfig.TransferInterativeID,
                EntityID = DBConfig.ID,
                ResID = DBConfig.CrystalID,
                IsSwitchPWorldBranch = true,
                OverwriteIcon = "Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Icon_EthericLight.UI_NPC_Icon_EthericLight'",
                DisplayName = _G.LSTR(90013)
            }

            local BranchLineUnit = FunctionItemFactory:CreateInteractiveDescFunc(BranchLineParams)
            if BranchLineUnit then
                table.insert(FunctionList, BranchLineUnit)
            end

        end

        -- 默认的离开选项
        local FunctionQuit = FunctionItemFactory:CreateFunction(LuaFuncType.QUIT_FUNC, _G.LSTR(90003), {})
        table.insert(FunctionList, FunctionQuit)

        return FunctionList
    end
end

---GetIconPath
---@return string
function EntranceCrystalPortal:GetIconPath()
    if self.Crystal then
        local CfgId = self.Crystal.IsActivated and self.Crystal.DBConfig.TransferInterativeID or self.Crystal.DBConfig.ActiviteInterativeID
        local Cfg = InteractivedescCfg:FindCfgByKey(CfgId)
        if Cfg then
            return Cfg.IconPath
        end
    end
    return self.IconPath
end

function EntranceCrystalPortal:Update()
    if not self.Crystal then
        return
    end
    if not self.Crystal.IsActivated then
        self.DisplayName = _G.LSTR(90008)
        self.Distance = 0
        self.InteractivePriority = 1
    else
        self.Distance = 5000
        self.InteractivePriority = 0
        if self.Crystal.DBConfig.Type == 2 then
            self.DisplayName = _G.LSTR(90009)
        else
            self.DisplayName = _G.LSTR(90010)
        end
    end
    self:UpdateUI()
end

return EntranceCrystalPortal
