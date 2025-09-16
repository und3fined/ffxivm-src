_G.LifeMgrModule = _G.LifeMgrModule or {}

LifeMgrModule.mc_UseOldFunction = false
LifeMgrModule.mc_CurLife = _G.UE.EGameLifeType.Game
             
function LifeMgrModule.StartAccountLife(accountName)
    FLOG_INFO("LifeMgrModule:StartAccountLife")
    local inst = _G.UE.ULifeManager.GetInst()
    if inst then
        if LifeMgrModule.mc_CurLife and LifeMgrModule.mc_CurLife > _G.UE.EGameLifeType.Account then
            LifeMgrModule.mc_CurLife = _G.UE.EGameLifeType.Account
        end
        if LifeMgrModule.mc_UseOldFunction then
            inst:StartAccountLife(accountName)
        else
            inst:AddLifeOperate(_G.UE.EGameLifeType.Account, true, true, accountName)
        end
    end
end

function LifeMgrModule.StartRoleLife(roleName)
    FLOG_INFO("LifeMgrModule:StartRoleLife")
    local inst = _G.UE.ULifeManager.GetInst()
    if inst then
        if LifeMgrModule.mc_CurLife and LifeMgrModule.mc_CurLife > _G.UE.EGameLifeType.Role then
            LifeMgrModule.mc_CurLife = _G.UE.EGameLifeType.Role
        end
        if LifeMgrModule.mc_UseOldFunction then
            inst:StartRoleLife(roleName)
        else
            inst:AddLifeOperate(_G.UE.EGameLifeType.Role, true, true, roleName)
        end
    end
end

function LifeMgrModule.StartLevelLife(levelName)
    FLOG_INFO("LifeMgrModule:StartLevelLife")
    local inst = _G.UE.ULifeManager.GetInst()
    if inst then
        if LifeMgrModule.mc_CurLife and LifeMgrModule.mc_CurLife > _G.UE.EGameLifeType.Level then
            LifeMgrModule.mc_CurLife = _G.UE.EGameLifeType.Level
        end
        if LifeMgrModule.mc_UseOldFunction then
            inst:StartLevelLife(levelName)
        else
            inst:AddLifeOperate(_G.UE.EGameLifeType.Level, true, true, levelName)
        end
    end
end

function LifeMgrModule.ShutdownAccountLife()
    FLOG_INFO("LifeMgrModule:ShutdownAccountLife")
    local inst = _G.UE.ULifeManager.GetInst()
    if inst then
        if LifeMgrModule.mc_CurLife and LifeMgrModule.mc_CurLife < _G.UE.EGameLifeType.Game then
            LifeMgrModule.mc_CurLife = _G.UE.EGameLifeType.Game
        end
        if LifeMgrModule.mc_UseOldFunction then
            inst:ShutdownAccountLife(true)
        else
            inst:AddLifeOperate(_G.UE.EGameLifeType.Account, false, true, "")
        end
    end
end

function LifeMgrModule.ShutdownRoleLife()
    FLOG_INFO("LifeMgrModule:ShutdownRoleLife")
    local inst = _G.UE.ULifeManager.GetInst()
    if inst then
        if LifeMgrModule.mc_CurLife and LifeMgrModule.mc_CurLife < _G.UE.EGameLifeType.Account then
            LifeMgrModule.mc_CurLife = _G.UE.EGameLifeType.Account
        end
        if LifeMgrModule.mc_UseOldFunction then
            inst:ShutdownRoleLife(true)
        else
            inst:AddLifeOperate(_G.UE.EGameLifeType.Role, false, true, "")
        end
    end
end

function LifeMgrModule.ShutdownLevelLife()
    FLOG_INFO("LifeMgrModule:ShutdownLevelLife")
    local inst = _G.UE.ULifeManager.GetInst()
    if inst then
        if LifeMgrModule.mc_CurLife and LifeMgrModule.mc_CurLife < _G.UE.EGameLifeType.Role then
            LifeMgrModule.mc_CurLife = _G.UE.EGameLifeType.Role
        end
        if LifeMgrModule.mc_UseOldFunction then
            inst:ShutdownLevelLife(true)
        else
            inst:AddLifeOperate(_G.UE.EGameLifeType.Level, false, true, "")
        end
    end
end

function LifeMgrModule.OnStartLifePercent(Percent)
    FLOG_INFO("LifeMgrModule:OnStartLifePercent:%d", Percent)
    EventMgr:SendEvent(EventID.StartLifePercent, Percent)
end

function LifeMgrModule.OnStartLifeCompleted(LifeType)
    FLOG_INFO("LifeMgrModule:OnStartLifeCompleted:%s", tostring(LifeType))
    EventMgr:SendEvent(EventID.StartLifeCompleted, LifeType)
end

function LifeMgrModule.OnShutdownLifeStart(LifeType)
    FLOG_INFO("LifeMgrModule:OnShutdownLifeStart:%s", tostring(LifeType))
    EventMgr:SendEvent(EventID.ShutdownLifeStart, LifeType)
end

function LifeMgrModule.OnShutdownCompleted(LifeType)
    FLOG_INFO("LifeMgrModule:OnShutdownCompleted:%s", tostring(LifeType))
    EventMgr:SendEvent(EventID.ShutdownLifeCompleted, LifeType)
end

function LifeMgrModule.GetCurLifeType()
    local inst = _G.UE.ULifeManager.GetInst()
    if nil ~= inst then
        return inst:GetCurLifeType()
    end
    return nil
end

-- --- 网络失连触发
-- function LifeMgrModule.OnNetworkDisconnected(p_NetWorkModule, InType)
--     -- 游戏网络失连 -- 设置角色状态为不在线
--     if InType == 1 then
--         RoleModule:SetIsPlayerOnline(false)    
--     end
    
--     local t_Inst = _G.UE.ULifeManager.GetInst()
--     if t_Inst then
--         local t_Res = t_Inst:OnNetworkDisconnected(p_NetWorkModule)
--         if t_Res then
--             LogMgr:Log(0, "LifeMgrModule:OnNetworkDisconnected", InType)
--         end
--     end
    
--     -- broadcast event for some file not module
--     if InType == 1 then
--         EventMgr:SendEvent(EventDef.EVENT_Role_OnDisconnect, InType)
--     end
    
-- end
-- --- 网络恢复触发
-- function LifeMgrModule.OnNetworkRecovered(p_NetWorkModule, InType)
--     local t_Inst = _G.UE.ULifeManager.GetInst()
--     if t_Inst then
--         local t_Res = t_Inst:OnNetworkRecovered(p_NetWorkModule)
--         if t_Res then
--             LogMgr:Log(0, "LifeMgrModule:OnNetworkRecovered", InType)
--         end
--     end
-- end

function LifeMgrModule.IsModuleValid(module)
    return module ~= nil
end

return LifeMgrModule
