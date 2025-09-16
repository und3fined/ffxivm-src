
local LuaClass = require("Core/LuaClass")
local EntranceBase = require("Game/Interactive/EntranceItem/EntranceBase")
local MajorUtil = require("Utils/MajorUtil")
local AnimationUtil = require("Utils/AnimationUtil")

local EntranceWorldViewObj = LuaClass(EntranceBase)
function EntranceWorldViewObj:Ctor()
    self.TargetType =  _G.LuaEntranceType.WorldViewObj
    self.SitDownEmotionID = 50
end

function EntranceWorldViewObj:OnInit()
    self.DisplayName = _G.LSTR(90002)
end

function EntranceWorldViewObj:OnUpdateDistance()
    self.Distance = 10000
end

function EntranceWorldViewObj:CheckInterative(EnableCheckLog)
    return true
end

--Entrance的响应逻辑
function EntranceWorldViewObj:OnClick()
    --椅子，直接坐下
    -- local EmotionID = 50
    -- local MsgID = CS_CMD.CS_CMD_EMOTION
    -- local SubMsgID = EMOTION_SUB_ID.EmotionSubMsgEnter
    -- local MsgBody = {}
	-- MsgBody.SubMsgID = SubMsgID
	-- MsgBody.Enter = { EmotionID = EmotionID, Target = {ID = nil, IDType = EmotionTargetType.EmotionTargetTypeEntity}}
    -- _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    --_G.EventMgr:SendEvent(_G.EventID.ClickWorldViewObjEntranceItem)
    
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(MajorEntityID)
    if PlayerAnimInst then
        local IsWorldViewObj = PlayerAnimInst:FindChair(MajorEntityID)
        if false == IsWorldViewObj then
            -- 在服务器回包后需要二次确认是否超出可交互范围，若此时没检测到椅子则不能坐下
            -- https://tapd.woa.com/tapd_fe/20420083/bug/detail/1020420083136252031
            return false
        end
    end
    local Major = MajorUtil.GetMajor()
    if Major and Major.CharacterMovement then
        local Velocity = Major.CharacterMovement.Velocity
        if Velocity then
            if Velocity:Size() > 0.000000001 then
                return false
            end
        end
    end

    _G.EmotionMgr:SendEmotionReq(self.SitDownEmotionID)
    return true
end

function EntranceWorldViewObj:OnGenFunctionList()
    return {}
end

return EntranceWorldViewObj
