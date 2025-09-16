--
-- Author: Alex
-- Date: 2023-10-12 19:32
-- Description:金蝶小游戏 莫古抓球机
--

local LuaClass = require("Core/LuaClass")
local MiniGameBaseVM = require("Game/GoldSaucerMiniGame/MiniGameBaseVM")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MooglePawParamsCfg = require("TableCfg/MooglePawParamsCfg")
local MooglePawTypeCfg = require("TableCfg/MooglePawTypeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local CatchBallParamType = ProtoRes.Game.CatchBallParamType
local MiniGameState = GoldSaucerMiniGameDefine.MiniGameStageType
local MoogleActBtnActiveType = GoldSaucerMiniGameDefine.MoogleActBtnActiveType
local MoogleMoveDir = GoldSaucerMiniGameDefine.MoogleMoveDir
local MoogleInitPos = GoldSaucerMiniGameDefine.MoogleInitPos
local MoogleMoveState = GoldSaucerMiniGameDefine.MoogleMoveState
local BindableVector2D = require("UI/BindableObject/BindableVector2D")
local UIBindableList = require("UI/UIBindableList")
local BitUtil = require("Utils/BitUtil")
local ProtoRes = require("Protocol/ProtoRes")
local MogulBallType = ProtoRes.Game.MogulBallType
local MooglePawBallItemVM = require("Game/GoldSaucerMiniGame/MooglesPaw/Item/MooglePawBallItemVM")
local GoldSaucerCuffGameResultItemVM = require("Game/GoldSaucerGame/View/Cuff/ItemVM/GoldSaucerCuffGameResultItemVM")
local MoogleBallShowState = GoldSaucerMiniGameDefine.MoogleBallShowState
local MoogleBallCaughtState = GoldSaucerMiniGameDefine.MoogleBallCaughtState
local MoogleLimitPos = GoldSaucerMiniGameDefine.MoogleLimitPos


local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local BallItemSlotSum = 36 -- 莫古球分布总格数
local QuadSlotNum = 3 -- 象限格子数


-- 莫古力种类
local EnumMoogleType = {
    ["Large"] = 1,
    ["Small"] = 2,
}

--local MoogleSmallScale = 0.7 -- 小型莫古力的缩小系数

---@class MiniGameMooglesPawVM
local MiniGameMooglesPawVM = LuaClass(MiniGameBaseVM)

---Ctor
function MiniGameMooglesPawVM:Ctor()
    self.TextTipsTitle = "" -- 界面功能提示
    self.RewardGot = "" -- 获取奖励数量
    self.RewardAdd = "" -- 增加奖励数量
    self.bShowRewardAdd = false -- 是否显示奖励增加界面
    self.bShowObtainPanel = false -- 是否显示奖励界面
    --self.bTopTipsShow = false -- 小游戏tips

    self.bShowGameOrSettlementPanel = true -- 显示游戏主界面或者结算界面
    self.BallItems = UIBindableList.New(MooglePawBallItemVM)

    self.bHorizontalActBtnEnable = true -- 左右移动按钮是否可用
    self.bVerticalActBtnEnable = false -- 上下移动按钮是否可用
    
    self.MooglePosition = BindableVector2D.New()
    self.MooglePosition:SetValue(MoogleInitPos.X, MoogleInitPos.Y)

    self.BallCaughtState = MoogleBallCaughtState.None -- 是否抓住球
    self:SetNoCheckValueChange("BallCaughtState", true)

    self.MoogleScale = _G.UE.FVector2D(1, 1) -- 莫古力的大小
    self.MoogleCanvasPos = BindableVector2D.New()

    self.MoogleMoveState = MoogleMoveState.Idle

    self.ResultVMList = UIBindableList.New(GoldSaucerCuffGameResultItemVM)
end

function MiniGameMooglesPawVM:ResetVMInfo()
    self.RewardGot = "" -- 获取奖励数量
    self.RewardAdd = "" -- 增加奖励数量
    self.bShowRewardAdd = false -- 是否显示奖励增加界面
    self.bShowObtainPanel = false -- 是否显示奖励界面
end

--- 更新小游戏VM
function MiniGameMooglesPawVM:OnUpdateVM()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end

    local bCaught = GameInst:GetTheCatchBallResult()
    self.BallCaughtState = bCaught
    self:UpdateActBtnState(GameInst)
    self.bShowObtainPanel = self.RewardGot ~= "" and self.bShowGameOrSettlementPanel
    self.bShowPanelCountDown = self.bShowGameOrSettlementPanel
end

--- 刷新时间显示
function MiniGameMooglesPawVM:OnUpdateTimeShow()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    local TotalTime = GameInst:GetRemainSeconds()
    if self.GameState == MiniGameState.DifficultySelect then
        self.bKeyTime = false
        return
    end
    local StageLimit = GoldSaucerMiniGameDefine.TimeStageLimit
    if TotalTime > StageLimit.Urgent then
        self.bKeyTime = false
    else
        self.bKeyTime = true 
    end

    --莫古力的移动刷新需要放在时间刷新里刷新才能保证连贯
    self:UpdateMoogleMovePath(GameInst)
    --FLOG_ERROR("TimeUpdateMoogleMoveStateBefore: state:%s %s", tostring(self.MoogleMoveState), self)
    self.MoogleMoveState = GameInst:GetMoogleMoveState()
    --FLOG_ERROR("TimeUpdateMoogleMoveStateAfter: state:%s %s", tostring(self.MoogleMoveState), self)
    self:UpdateActBtnState(GameInst)
end

function MiniGameMooglesPawVM:UpdateMoogleMovePath(GameInst)
    local MoveDis = GameInst:GetTheMotionDisInTheRound() or 0
    local MoveDir = GameInst:GetMoogleMoveDir()

    if MoveDis == 0 then
        return
    end

    local MooglePositionVM = self.MooglePosition
    if not MooglePositionVM then
        return
    end

    local PositionX = MoogleInitPos.X
    local PositionY = MoogleInitPos.Y
    if MoveDir == MoogleMoveDir.Horizontal then
        PositionX = PositionX + MoveDis
        local _, PositionYExist = MooglePositionVM:GetValue()
        if PositionYExist and type(PositionYExist) == "number" then
            PositionY = PositionYExist
        end

        if PositionX >= MoogleLimitPos.X then
            GameInst:OnActBtnPressUp()
        end
    elseif MoveDir == MoogleMoveDir.Vertical then
        PositionY = PositionY + MoveDis
        local PositionXExist, _ = MooglePositionVM:GetValue()
        if PositionXExist and type(PositionXExist) == "number" then
            PositionX = PositionXExist
        end
        
        if PositionY >= MoogleLimitPos.Y then
            GameInst:OnActBtnPressUp()
        end
    end

    MooglePositionVM:SetValue(math.min(PositionX, MoogleLimitPos.X), math.min(PositionY, MoogleLimitPos.Y))
end

--- 更新操作按钮的可用状态
function MiniGameMooglesPawVM:UpdateActBtnState(GameInst)
    local ActBtnActiveType = GameInst:GetActBtnTypeActive()
    self.bHorizontalActBtnEnable = ActBtnActiveType == MoogleActBtnActiveType.Horizontal
    self.bVerticalActBtnEnable = ActBtnActiveType == MoogleActBtnActiveType.Vertical
end

function MiniGameMooglesPawVM:ClearBall()
    local BallItems = self.BallItems
    if not BallItems then
        return
    end
    BallItems:Clear()
end

--- 初始化球的分布
function MiniGameMooglesPawVM:InitBallDistribute()
    local GameInst = self.MiniGame
	if not GameInst then
		return
	end

	local BallList = GameInst.BallList
	if not BallList or nil == next(BallList) then
		FLOG_ERROR("GoldSaucerMooglePawMainPanelView:InitBallDistribute BallList is Invalid")
		return
	end

    local BallListWithListIndex = {}
    for _, value in ipairs(BallList) do
        local BallID = value.BallID
        if BallID and type(BallID) == "number" and BallID > 0 then
            local ListIndex, Location = self:ConvertBallID2ListIndex(BallID)
            if ListIndex then
                BallListWithListIndex[ListIndex] = {
                    Location = Location,
                    CsInfo = value
                }
            end
        end
    end

    if nil == next(BallListWithListIndex) then
        return
    end

    local BallItems = self.BallItems
    if not BallItems then
        return
    end
    BallItems:Clear()
    local ListValues = {}
    for index = 1, BallItemSlotSum do
        local Value = {
            BallID = 0,
            BallType = MogulBallType.MogulBallTypeInvalid
        }
        local BallDataExist = BallListWithListIndex[index]
        if BallDataExist then
            local CsInfo = BallDataExist.CsInfo
            Value.BallID = CsInfo.BallID
            Value.BallType = CsInfo.BallType
            local LocationT = BallDataExist.Location
            Value.PosX, Value.PosY = self:World2LocalPosOffset(CsInfo.PosX, CsInfo.PosY, LocationT)
        end
        table.insert(ListValues, Value)
    end
    BallItems:UpdateByValues(ListValues, nil)
end

--- 按照服务器规则将球的ID转换为列表序号
---@param BallID number@球的ID
---@return number, table@列表中的序号，在格子分布坐标系中的坐标
function MiniGameMooglesPawVM:ConvertBallID2ListIndex(BallID)
    if not BallID or type(BallID) ~= "number" then
        return
    end

    local BitsTable = BitUtil.ToBits(BallID)
    local QuadXBits = {}
    local QuadYBits = {}
    local SlotXBits = {}
    local SlotYBits = {}
    for index, value in ipairs(BitsTable) do
        if index < 5 then
            table.insert(SlotYBits, value)
        elseif index < 9 then
            table.insert(SlotXBits, value)
        elseif index < 13 then
            table.insert(QuadYBits, value)
        else
            table.insert(QuadXBits, value)
        end
    end
    local QuadX = BitUtil.ToNumber(QuadXBits)
    local QuadY = BitUtil.ToNumber(QuadYBits)
    local SlotX = BitUtil.ToNumber(SlotXBits)
    local SlotY = BitUtil.ToNumber(SlotYBits)

    local X = (QuadX - 1) * QuadSlotNum + SlotX
    local Y = (QuadY - 1) * QuadSlotNum + SlotY

    return (X - 1) * QuadSlotNum * 2 + Y, { XIndex = X, YIndex = Y }
end

--- 将服务器的坐标数据转换为子控件Item的本地坐标偏移
---@param PosX number @Cs坐标X
---@param PosY number @Cs坐标Y
---@param WorldLocation @象限坐标
function MiniGameMooglesPawVM:World2LocalPosOffset(PosX, PosY, WorldLocation)
    if not PosX or not PosY then
        return
    end

    if not WorldLocation then
        FLOG_ERROR("MiniGameMooglesPawVM:World2LocalPosOffset The param WorldLocation is not valid")
        return
    end

    local WorldX = WorldLocation.XIndex
    if not WorldX or type(WorldX) ~= "number" then
        FLOG_ERROR("MiniGameMooglesPawVM:World2LocalPosOffset The WorldX is not valid")
        return
    end

    local WorldY = WorldLocation.YIndex
    if not WorldY or type(WorldY) ~= "number" then
        FLOG_ERROR("MiniGameMooglesPawVM:World2LocalPosOffset The WorldY is not valid")
        return
    end
    local LenParamCfg = MooglePawParamsCfg:FindCfgByKey(CatchBallParamType.CatchBallParamTypePlaidLength)
    local SlotLen = LenParamCfg and LenParamCfg.Value or 0 -- 格子长度
    local WidParamCfg = MooglePawParamsCfg:FindCfgByKey(CatchBallParamType.CatchBallParamTypePlaidWidth)
    local SlotWid = WidParamCfg and WidParamCfg.Value or 0 -- 格子宽度
    local SlotCenterX = (WorldY - 0.5) * (SlotLen or 0)
    local SlotCenterY = (WorldX - 0.5) * (SlotWid or 0)
    
    return PosX - SlotCenterX, PosY - SlotCenterY
end

--- 展示结果阶段球的显示
function MiniGameMooglesPawVM:HideTheOtherBallWhenShowCatchResult()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end

    local _, BallIDCaught = GameInst:GetTheCatchBallResult()
    if not BallIDCaught or type(BallIDCaught) ~= "number" then
        return
    end

    local BallItems = self.BallItems
    if not BallItems then
        return
    end
    for i = 1, BallItems:Length() do
        local VM = BallItems:Get(i)
        if VM ~= nil then
           VM:ChangeShowState(BallIDCaught == VM.BallID and MoogleBallShowState.Strong or MoogleBallShowState.Weak)
        end
    end
end

function MiniGameMooglesPawVM:GetTheCatchBallVM()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end

    local _, BallIDCaught = GameInst:GetTheCatchBallResult()
    if not BallIDCaught or type(BallIDCaught) ~= "number" then
        return
    end

    local BallItems = self.BallItems
    if not BallItems then
        return
    end
    for i = 1, BallItems:Length() do
        local VM = BallItems:Get(i)
        if VM ~= nil and BallIDCaught == VM.BallID then
            return VM
        end
    end
end

--- 设定莫古力的体型的一半
function MiniGameMooglesPawVM:GetMoogleHalfSize()
    local GameInst = self.MiniGame
    if not GameInst then
        return
    end
    -- 设定莫古力的大小/特效变换莫古力的大小
    local MoogleID = GameInst:GetCurMoogleID()
    if MoogleID then
        local MoogleCfg = MooglePawTypeCfg:FindCfgByKey(MoogleID)
        if not MoogleCfg then
            return
        end
        local MoogleSize = MoogleCfg.BodySize or 0
        return MoogleSize / 2
    end
end

--- 还原球体状态
function MiniGameMooglesPawVM:ResetBallShowStateWhenShowCatchResult()
    local BallItems = self.BallItems
    if not BallItems then
        return
    end
    for i = 1, BallItems:Length() do
        local VM = BallItems:Get(i)
        if VM ~= nil then
           VM:ChangeShowState(MoogleBallShowState.Normal)
        end
    end
end

--- 设定莫古力的体型及偏移
function MiniGameMooglesPawVM:SetMoogleSizeAndCanvasOffset()
    local GameInst = self.MiniGame
    -- 设定莫古力的大小/特效变换莫古力的大小
    local MoogleID = GameInst:GetCurMoogleID()
    if MoogleID then
        local BaseMoogleCfg = MooglePawTypeCfg:FindCfgByKey(EnumMoogleType.Large)
        local MoogleCfg = MooglePawTypeCfg:FindCfgByKey(MoogleID)
        if not BaseMoogleCfg or not MoogleCfg then
            return
        end
        local MoogleSize = MoogleCfg.BodySize or 0
        local BiggestMoogleSize = BaseMoogleCfg.BodySize or 0
        if MoogleSize == 0 or BiggestMoogleSize == 0 then
            return
        end
        local MoogleSmallScale = MoogleSize / BiggestMoogleSize
        local CanvasOffset = MoogleSize / 2 * -1
        self.MoogleScale = _G.UE.FVector2D(MoogleSmallScale, MoogleSmallScale)
        self.MoogleCanvasPos:SetValue(0, CanvasOffset)
        if not self.ReconnectSuccess then
            self.MooglePosition:SetValue(MoogleInitPos.X, MoogleInitPos.Y - CanvasOffset)
        end
    end
end

function MiniGameMooglesPawVM:UpdateResultList(CompleteCounts)
    local GameInst = self.MiniGame
	if not GameInst then
		return
	end

    local ResultVMs = self.ResultVMList
    if not ResultVMs then
        return
    end

    ResultVMs:Clear()
    local bPerfectChallenge = GameInst:GetIsPerfectChallenge()
    --- 达成挑战Item
    ResultVMs:AddByValue(
    {
        VarName = LSTR(360008),
        Value = string.format(LSTR(360009), tostring(CompleteCounts)),
        bIsNewRecord = GameInst:GetCompleteChallengeNewRecord(),
        bIsPerfectChallenge = bPerfectChallenge,
    }, nil, true)

    --- 完美挑战Item
    local PerfectChallengeItem = {
        VarName = LSTR(360010),
        Value = bPerfectChallenge and string.format(LSTR(360011), GameInst:GetPerfectChallengeTime() or 0) or "", 
        bIsNewRecord = GameInst:GetPerfectChallengeNewRecord(),
        bIsPerfectChallenge = bPerfectChallenge,
        bShowUnfinished = not bPerfectChallenge,
    }
    ResultVMs:AddByValue(PerfectChallengeItem)
end

return MiniGameMooglesPawVM