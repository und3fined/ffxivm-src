---
--- Author: xingcaicao
--- DateTime: 2023-07-24 16:15:20
--- Description: 搜索内容合法性（敏感词）
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local GameNetworkMgr = require("Network/GameNetworkMgr")

local CS_CMD = ProtoCS.CS_CMD
local LSTR = _G.LSTR

-- @class JudgeSearchMgr : MgrBase
local JudgeSearchMgr = LuaClass(MgrBase)

function JudgeSearchMgr:OnInit()
    self:Reset()
end

function JudgeSearchMgr:OnBegin()

end

function JudgeSearchMgr:OnEnd()

end

function JudgeSearchMgr:OnShutdown()
    self:Reset()
end

function JudgeSearchMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_JUDGE_SEARCH_INPUT, 0, self.OnNetMsgJudgeSearchInput)
end

function JudgeSearchMgr:Reset()
    self.QueryCallback = nil
    self.IsShowIllegalTips = false
    self.CustomTipsText = nil 
end

function JudgeSearchMgr:SendJudgeSearchInputReq( Text )
    local MsgID = CS_CMD.CS_CMD_JUDGE_SEARCH_INPUT
	local MsgBody = { Text = Text }

    GameNetworkMgr:SendMsg(MsgID, 0, MsgBody)
end

function JudgeSearchMgr:OnNetMsgJudgeSearchInput( MsgBody )
    local Result = MsgBody.Result

    if self.IsShowIllegalTips then
        if Result < 0 then
            MsgTipsUtil.ShowTips(LSTR(10037)) -- "您输入的信息内容过长，请重新输入" 

        elseif Result > 0 then
            local Text = self.CustomTipsText
            if string.isnilorempty(Text) then
                Text = LSTR(10038) -- "当前文本不可使用，请重新输入"
            end

            MsgTipsUtil.ShowTips(Text)
        end
    end

    if self.QueryCallback ~= nil then
        self.QueryCallback(Result == 0, MsgBody.Text)
    end

    self:Reset()
end

-------------------------------------------------------------------------------------------------
--- 对外接口

---查询文本是否合法（敏感词）
---@param Text string @文本内容
---@param Callback function @查询结果回调函数，参数1，查询结果(是否包含敏感词true/false)；参数2，查询的原始文本Text
---@param IsShowTips boolean @查询结果为非法后，是否飘字提示，默认true
---@param CustomTipsText boolean @查询结果为非法后，自定义的飘字提示内容
function JudgeSearchMgr:QueryTextIsLegal(Text, Callback, IsShowTips, CustomTipsText)
    if string.isnilorempty(Text) then
        if Callback ~= nil then
            Callback(Text, false)
        end

        return
    end

    self.QueryCallback = Callback
    self.IsShowIllegalTips = IsShowTips ~= false
    self.CustomTipsText = CustomTipsText
    self:SendJudgeSearchInputReq(Text)
end

return JudgeSearchMgr