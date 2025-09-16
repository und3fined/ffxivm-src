--
-- Author: Leo
-- Date: 2024-1-10 19:32
-- Description:金蝶小游戏 怪物投籃
--

local LuaClass = require("Core/LuaClass")
local MiniGameBaseVM = require("Game/GoldSaucerMiniGame/MiniGameBaseVM")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local GoldSaucerMonsterTossBallItemVM = require("Game/GoldSaucerGame/View/MonsterToss/ItemVM/GoldSaucerMonsterTossBallItemVM")
local CommInteractionResultTipVM = require("Game/GoldSaucerMiniGame/CommInteractionResultTipVM")
local MiniGameMonsterTossResultVM = require("Game/GoldSaucerMiniGame/MonsterToss/MiniGameMonsterTossResultVM")
local MiniGameState = GoldSaucerMiniGameDefine.MiniGameStageType --
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local Anim = MiniGameClientConfig[MiniGameType.MonsterToss].Anim

local EventMgr = _G.EventMgr
local EventID = _G.EventID
local UE = _G.UE
local LSTR = _G.LSTR
---@class MiniGameMonsterTossVM
local MiniGameMonsterTossVM = LuaClass(MiniGameBaseVM)

---Ctor
function MiniGameMonsterTossVM:Ctor()
    self.AllBallVM = {}
    self.MonsterTossTimeText = 60
    self.TimeTextColor = "#FFFFFF"
    self.bTenthsVisible = false
    self.TenthsText = ""
    self.CurScoreColor = ""
    self.MaxScoreColor = ""
    self.bActBtnEnable = true -- 动作按钮是否生效
    self.MaxScore = 0       -- 历史最高得分
    self.CurScore = 0
    self.RewardGot = "0" -- 获取奖励数量
    self.RewardGotEnd = "+0"
    self.AddRewardGot = "0"
    self.bResultVisible = false
    self.bNormalVisible = true
    self.bShootTipVisible = false
    self.bResultMoneyVisible = false
    self.bGameTipVisible = true

    self.bMultipleTipVisible = false
    self.MultipleTipText = 1
    -- self.ComboPercent = 0
    self.bImgPointerFocusVisible = false
    self.bAddScoreTextVisible = false
    self.AddScoreText = ""
    self.AddScoreColor = "FFEED97F"
    self.AddScoreOutLineColor = "8E5C137F"
    self.ComboNum = 0
    self.AddScorePos = UE.FVector2D(0, 0)

    self.PurpleProportOrder = 0
    self.BlueProportOrder = 0
    self.RedProportOrder = 0
    self.BluePercent = 0
    self.PurplePercent = 0
    self.RedPercent = 0

    self.TextScore1Text = ""
    self.bTextScore1TipVisible = false
    self.bTextScore2TipVisible = false

    self.PointerAngle = -90
    self.ShootingResultTipVM = CommInteractionResultTipVM.New()

    self.CriticalText = ""
    self.bCriticalVisible = false

    -- 结算界面
    self.ResultVM = MiniGameMonsterTossResultVM.New()
    self:CreateBallVM()
end

--- 更新小游戏VM
function MiniGameMonsterTossVM:OnUpdateVM()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    self.bResultVisible = GameInst.bResultVisible
    self.bNormalVisible = GameInst.bNormalVisible
    self.MaxScore = GameInst.MaxScore
    self.MaxScoreColor = tonumber(GameInst.MaxScore) > 0 and "#FFFFFF" or "#828282"

    self.RewardGot = GameInst.RewardGot
    self.RewardGotEnd = "+"..self.RewardGot
    if tonumber(GameInst.AddRewardGot) ~= 0 then
        self.AddRewardGot = GameInst.AddRewardGot
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimObtainNumberIn)
    end
    self.CurScore = GameInst.CurScore
    self.CurScoreColor = tonumber(GameInst.CurScore) > 0 and "#FFFFFF" or "#828282"

    self.CriticalText = GameInst.CriticalText
    self.bCriticalVisible = GameInst.bCriticalVisible
    self.ComboNum = GameInst.ComboNum
    self.AddScoreText = GameInst.AddScoreText
    self.bAddScoreTextVisible = GameInst.bAddScoreTextVisible
    self.AddScoreColor = GameInst.AddScoreColor
    self.AddScoreOutLineColor = GameInst.AddScoreOutLineColor
    self.AddScorePos = GameInst.AddScorePos
    self.TextScore1Text = GameInst.TextScore1Text
    self.bTextScore1TipVisible = GameInst.bTextScore1TipVisible
    self.bTextScore2TipVisible = GameInst.bTextScore2TipVisible
    self.bResultMoneyVisible = GameInst.bResultMoneyVisible
    self.bGameTipVisible = GameInst.bGameTipVisible
    self.ShootingResultTipVM:UpdateVM(GameInst.ShootResultData)
    self.bShootTipVisible = GameInst.bShootTipVisible

    self:SetTimeText(GameInst)

    
    local CurStageDiffParams = GameInst.CurStageDiffParams

    if CurStageDiffParams.ScoreMul ~= nil then
        self.MultipleTipText = string.format(LSTR(270003), CurStageDiffParams.ScoreMul) -- %s倍分数
        self.bMultipleTipVisible = tonumber(CurStageDiffParams.ScoreMul) > 1
    end

    -- self.ComboPercent = math.clamp(GameInst.ComboNum / 8, 0, 1)
    if #self.AllBallVM < 1 then
        self:CreateBallVM()
    end
    -- self:UpdateBallVMByPos(GameInst.AllBallData)
    self:UpdateAllBallVM(GameInst.AllBallData)
    if GameInst.AllResultData ~= nil then
        self.ResultVM:UpdateVM(GameInst.AllResultData)
    end

end

--- 实时刷新
function MiniGameMonsterTossVM:OnUpdateTimeShow()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end

    self.bShootTipVisible = GameInst.bShootTipVisible
    local CurStageDiffParams = GameInst.CurStageDiffParams
    self.MultipleTipText = string.format(LSTR(270003), CurStageDiffParams.ScoreMul) -- %s倍分数
    if CurStageDiffParams.ScoreMul ~= nil then
        self.bMultipleTipVisible = tonumber(CurStageDiffParams.ScoreMul) > 1
    end

    -- local ZOrderCfg = CurStageDiffParams.ZOrderCfg
    -- if ZOrderCfg ~= nil then
    --     self.PurpleProportOrder = ZOrderCfg.PurpleProportOrder
    --     self.BlueProportOrder = ZOrderCfg.BlueProportOrder
    --     self.RedProportOrder = ZOrderCfg.RedProportOrder
    -- end
    -- local ColorCfg = CurStageDiffParams.ColorCfg
    -- if ColorCfg ~= nil then
    --     self.BluePercent = ColorCfg.BluePercent
    --     self.PurplePercent = ColorCfg.PurplePercent
    --     self.RedPercent = ColorCfg.RedPercent
        
    --     -- print("BluePercent"..tostring(ColorCfg.BluePercent))
    --     -- print("PurplePercent"..tostring(ColorCfg.PurplePercent))
    --     -- print("RedPercent"..tostring(ColorCfg.RedPercent))
    -- end

    self:SetTimeText(GameInst)
end

--- @type 更新鉴定成功轮盘的布局
function MiniGameMonsterTossVM:UpdateProportLayOut()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end

    local CurStageDiffParams = GameInst.CurStageDiffParams
    local ZOrderCfg = CurStageDiffParams.ZOrderCfg
    if ZOrderCfg ~= nil then
        self.PurpleProportOrder = ZOrderCfg.PurpleProportOrder
        self.BlueProportOrder = ZOrderCfg.BlueProportOrder
        self.RedProportOrder = ZOrderCfg.RedProportOrder
    end

    local ColorCfg = CurStageDiffParams.ColorCfg
    if ColorCfg ~= nil then
        self.BluePercent = ColorCfg.BluePercent
        self.PurplePercent = ColorCfg.PurplePercent
        self.RedPercent = ColorCfg.RedPercent
    end
end

--- @type 单独刷新奖励
function MiniGameMonsterTossVM:UpdateRewardGotSingle()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    -- self.RewardGot = GameInst.RewardGot
    self.ResultVM.RewardGot = GameInst.RewardGot
end

function MiniGameMonsterTossVM:UpdatePointerAngle(PointerAngle)
    self.MiniGameMonsterTossVM = PointerAngle
end

function MiniGameMonsterTossVM:SetTimeText(GameInst)
    local TimeSeconds
    if GameInst.RemainSeconds > 10 then
        local bTenthsVisible = self.bTenthsVisible
        TimeSeconds = GameInst:GetRemainSecondsInteger()
        self.TimeTextColor = "#FFFFFF"
        if bTenthsVisible then
            self.bTenthsVisible = false
        end
    else
        self.bTenthsVisible = true
        TimeSeconds = math.ceil(GameInst.RemainSeconds * 10)
        TimeSeconds = TimeSeconds / 10
        self.TimeTextColor = "#dc5868"
        self.TenthsText = "."..tostring(math.floor((TimeSeconds - math.floor(TimeSeconds)) * 10))
    end
    self.MonsterTossTimeText = tostring(math.floor(TimeSeconds))

end

function MiniGameMonsterTossVM:FindZOrderByColorType(ZOrderCfg)

end

--- @type 给四个篮球创建VM
function MiniGameMonsterTossVM:CreateBallVM()
    local AllBallVM = {}
    for i = 1, 4 do
        local VM = GoldSaucerMonsterTossBallItemVM.New()
        VM:UpdatePos(i)
        table.insert(AllBallVM, VM)
    end
    self.AllBallVM = AllBallVM
end

--- @type 刷新四个篮球的VM
function MiniGameMonsterTossVM:UpdateAllBallVM(AllBallData)
    local AllBallVM = self.AllBallVM
    for i = 1, #AllBallVM do
        local BallVM = AllBallVM[i]
        BallVM:UpdatePos(i)
        BallVM:UpdateVM(AllBallData[i])
    end
end

--- @type 刷新四个篮球的VM
-- function MiniGameMonsterTossVM:UpdateBallVMByPos(AllBallData)
--     local AllBallVM = self.AllBallVM
--     for i = 1, #AllBallVM do
--         local BallVM = AllBallVM[i]
--         local Pos = BallVM:GetPos()
--         -- _G.FLOG_ERROR("Pos:"..tostring(Pos).." ".. "Type")

--         BallVM:UpdateVM(AllBallData[tonumber(Pos)])
--     end
-- end

--- @type 获得篮球的VM
function MiniGameMonsterTossVM:GetAllBallVM()
    return self.AllBallVM
end

function MiniGameMonsterTossVM:SetGameInstVM()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    GameInst:SetViewModel(self)
end

--- @type 获取投篮结果提示的VM
function MiniGameMonsterTossVM:GetMonsterTossShootingResultTipVM()
    return self.ShootingResultTipVM
end


--- @type 获取结算结果的VM
function MiniGameMonsterTossVM:GetResultPanelVM()
    return self.ResultVM
end

function MiniGameMonsterTossVM:Reset()
    local AllBallVM = self.AllBallVM
    for i = 1, #AllBallVM do
        local BallVM = AllBallVM[i]
        BallVM:ResetVM()
    end
    self.MonsterTossTimeText = 60
    self.TimeTextColor = "#FFFFFF"
    self.bTenthsVisible = false
    self.TenthsText = ""
    self.CurScoreColor = ""
    self.MaxScoreColor = ""
    self.bActBtnEnable = true -- 动作按钮是否生效
    self.MaxScore = 0       -- 历史最高得分
    self.CurScore = 0
    self.RewardGot = "0" -- 获取奖励数量
    self.AddRewardGot = "0"
    self.bResultVisible = false
    self.bNormalVisible = true
    self.bShootTipVisible = false
    self.bResultMoneyVisible = false
    self.bGameTipVisible = true

    self.bMultipleTipVisible = false
    self.MultipleTipText = 1
    -- self.ComboPercent = 0
    self.bImgPointerFocusVisible = false
    self.bAddScoreTextVisible = false
    self.AddScoreText = ""
    self.ComboNum = 0
    self.AddScorePos = UE.FVector2D(0, 0)

    self.PurpleProportOrder = 0
    self.BlueProportOrder = 0
    self.RedProportOrder = 0
    self.BluePercent = 0
    self.PurplePercent = 0
    self.RedPercent = 0

    self.TextScore1Text = ""
    self.bTextScore1TipVisible = false
    self.bTextScore2TipVisible = false
    self.ShootingResultTipVM:Reset()

    -- 结算界面
    self.ResultVM:Reset()
end

return MiniGameMonsterTossVM