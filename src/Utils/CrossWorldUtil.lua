--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-06-20 09:50:02
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-07-07 10:37:21
FilePath: \Script\Utils\CrossWorldUtil.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local MajorUtil = require("Utils/MajorUtil")

local CrossWorldUtil = {}

-- --- 是否 加入队伍邀请 需要跨服弹窗
-- function CrossWorldUtil.IsTeamInviteNeedCrossWorld(CaptainWorldID)
--     local MajorRoleWorldID = (MajorUtil.GetMajorRoleVM() or {}).CurWorldID or 0 
-- 	if MajorRoleWorldID == 0 or CaptainWorldID == 0 then 
--         FLOG_INFO(string.format("CrossWorldUtil.IsTeamInviteNeedCrossWorld MajorRoleWorldID is %s CaptainWorldID is %s",MajorRoleWorldID, CaptainWorldID))
--         return false 
--     end

-- 	return MajorRoleWorldID ~= CaptainWorldID
-- end

--- 无水晶传送
---@param TargetWorldID             目标服务器ID
---@param MainContent               主标题
---@param SubContent                副标题
---@param ConfirmCallBack           跨服弹窗确认按钮Callback
---@param CrossSuccesssCallback     跨服成功Callback
---@param CheckRoleID               确认跨服时需再次检测目标roleid的world的需传入
---@param CrossAfterEvent           招募 需要加入招募队伍才会跨服 处理需要前置操作结束后 接收时间后进行跨服
function CrossWorldUtil.CrossWorldWithoutCrtstal(TargetWorldID, MainContent, SubContent, ConfirmCallBack, CrossSuccesssCallback, CheckRoleID, CrossAfterEvent)
    if not TargetWorldID then
        FLOG_ERROR("CrossWorldUtil.CrossWorldWithoutCrtstal Got Nil TargetWorldID")
        return
    end

    local Params = {
        WorldID = TargetWorldID,
        ConfirmCallBack = ConfirmCallBack,
        CrossSuccesssCallback = CrossSuccesssCallback,
        MainContent = MainContent or "",
        SubContent = SubContent or "",
        CheckRoleID = CheckRoleID,
        CrossAfterEvent = CrossAfterEvent,
    }

    _G.UIViewMgr:ShowView(_G.UIViewID.TeamTeleportWinPanel, Params)
end

return CrossWorldUtil