--
-- Author: Leo
-- Date: 2024-1-10 19:32
-- Description:金蝶小游戏 重击吉尔伽美什
--

local LuaClass = require("Core/LuaClass")
local MiniGameBaseVM = require("Game/GoldSaucerMiniGame/MiniGameBaseVM")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local CommInteractionResultTipVM = require("Game/GoldSaucerMiniGame/CommInteractionResultTipVM")
local CrystalTowerParamCfg = require("TableCfg/CrystalTowerParamCfg")

local CrystalTowerInteractionVM = require("Game/GoldSaucerGame/View/CrystalTowerStriker/ItemVM/CrystalTowerInteractionVM")
local CrystalTowerResultItemVM = require("Game/GoldSaucerGame/View/CrystalTowerStriker/ItemVM/CrystalTowerResultItemVM")
local CrystalTowerInteractResultVM = require("Game/GoldSaucerMiniGame/CrystalTower/CrystalTowerInteractResultVM")
local CrystalTowerInteractResultItemVM = require("Game/GoldSaucerGame/View/CrystalTowerStriker/ItemVM/CrystalTowerInteractResultItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local UIBindableList = require("UI/UIBindableList")
local AudioUtil = require("Utils/AudioUtil")
local CrystalTowerAudioDefine = require("Game/GoldSaucerMiniGame/CrystalTower/CrystalTowerAudioDefine")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local CrystalTowerParamType = ProtoRes.Game.CrystalTowerParamType

local Anim = MiniGameClientConfig[MiniGameType.CrystalTower].Anim
local EventID = _G.EventID
local EventMgr = _G.EventMgr
local UE = _G.UE
local LSTR = _G.LSTR
local TimerMgr = _G.TimerMgr
---@class MiniGameCrystalTowerVM
local MiniGameCrystalTowerVM = LuaClass(MiniGameBaseVM)

---Ctor
function MiniGameCrystalTowerVM:Ctor()
    self.AllInteractionVM = {} 
    self.bAddScoreVisible = false
    self.AddScoreOutLineColor = "D34C2EFF"
    self.AddScoreColor = "D8FFDBFF"
    self.AddScore = "0"
    self.AddScorePos = UE.FVector2D(0, 0)
    self.TextQuantityValue = "0"
    self.CTStrengthPro = 0
    self.CTTextMultiple = ""
    self.bTextMultipleVisible = false
    self.bPanelNormalVisible = true
    self.bPanelResultVisible = false
    self.bFailed = false
    self.bSuccessed = false
    self.RewardGot = "0" -- 获取奖励数量
    local CoinID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE -- 金碟币ID
	local IconPath = _G.ScoreMgr:GetScoreIconName(CoinID)
    self.AwardIconPath = IconPath
    self.TextHint = ""
    -- self.bTextHintVisible = false
    self.JDCoinColor = "#FFFFFF"
    self.RightBtnContent = LSTR(250001) -- 再 战
    self.bEnterEndState = false
    self.ResultText = ""
    self.ResultTextColor = ""
    self.bImgMask2Visible = false
    self.AccruedScore = 0
    self.CTAddRewardGot = 0

        
    self.CriticalText = ""
    self.bCriticalVisible = false
    -- self.TextTipsTitle = "" -- 界面功能提示

    self.EndResultVMList = UIBindableList.New(CrystalTowerResultItemVM)
    -- self:CreateAllInteractionVM()
    self.InteractResultVM = CrystalTowerInteractResultVM.New()
    self.InteractionResultTipVM = CommInteractionResultTipVM.New()

    self.InteractResultVMList = UIBindableList.New(CrystalTowerInteractResultItemVM)
    self.CenterInteractResultVM = CrystalTowerInteractResultItemVM.New()
    self.bShootingTipVisible = false
    self.bInEndRound = false
end

function MiniGameCrystalTowerVM:InitVM()
    self.TextQuantityValue = "0"
    self.CTStrengthPro = 0

end

--- 全部更新
function MiniGameCrystalTowerVM:OnUpdateVM()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    self:UpdateData()

    if GameInst.ResultListData ~= nil then
        self:UpdateList(self.EndResultVMList, GameInst.ResultListData)
    end
end

--- 刷新时间显示
function MiniGameCrystalTowerVM:OnUpdateTimeShow()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    local TimeSecondsInteger = GameInst:GetRemainSecondsInteger()
    self.MonsterTossTextTitle = TimeSecondsInteger
end

--- @type 刷新单个VM
function MiniGameCrystalTowerVM:UpdateSingleSubViewVM(ID, InteractionData)
    local VM = self.AllInteractionVM[ID]
    if VM then
        VM:UpdateVM(InteractionData)
    end
end

--- @type 只刷数据不刷SubView的VM
function MiniGameCrystalTowerVM:UpdateData()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    self.CTTextMultiple = GameInst.CTTextMultiple
    local Cfg = CrystalTowerParamCfg:FindCfgByKey(CrystalTowerParamType.CrystalTowerParamPowerDoubleTime)
    if Cfg ~= nil then
        self.bTextMultipleVisible = GameInst.bTextMultipleVisible
        if self.bTextMultipleVisible then
            TimerMgr:AddTimer(self, function() 
                self.bTextMultipleVisible = false
                GameInst:SetTextMutiAndVisible(1)
                -- local MultiScale = tonumber(string.sub(GameInst.CTTextMultiple, 2, #GameInst.CTTextMultiple))
                self.TextQuantityValue = GameInst:GetStrengthValue()
                EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimaNumber)
            end, Cfg.Value / 1000)
        end
    end
    
    self.bPanelNormalVisible = GameInst.bPanelNormalVisible
    self.bPanelResultVisible = GameInst.bPanelResultVisible
    self.bFailed = GameInst.bFailed
    self.bSuccessed = GameInst.bSuccessed
    self.RewardGot = GameInst.RewardGot
    if tonumber(GameInst.CTAddRewardGot) ~= 0 then
        self.CTAddRewardGot = GameInst.CTAddRewardGot
        -- EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimObtainNumberIn)
    end
    self.TextHint = GameInst.TextHint
    -- self.bTextHintVisible = GameInst.bTextHintVisible
    self.JDCoinColor = GameInst.JDCoinColor
    self.RightBtnContent = GameInst.RightBtnContent
    self.bEnterEndState = GameInst.bEnterEndState
    self.ResultText = GameInst.ResultText
    self.ResultTextColor = GameInst.ResultTextColor
    self.bImgMask2Visible = GameInst.bImgMask2Visible

    self.CriticalText = GameInst.CriticalText
    self.bCriticalVisible = GameInst.bCriticalVisible
end

--- @type 创建16个VM
function MiniGameCrystalTowerVM:CreateAllInteractionVM()
    local AllInteractionVM = self.AllInteractionVM
    for i = 1, 16 do
        local InteractionVM = CrystalTowerInteractionVM.New()
        table.insert(AllInteractionVM, InteractionVM)
    end
end

function MiniGameCrystalTowerVM:SetbShootingTipVisible(bVisible)
    self.bShootingTipVisible = bVisible
end

--- @type 单独刷新奖励
function MiniGameCrystalTowerVM:UpdateRewardGotSingle()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    self.RewardGot = GameInst.RewardGot
end


--- @type 重置所有SubViewVM
function MiniGameCrystalTowerVM:ResetAllSubViewVM()
    local AllInteractionVM = self.AllInteractionVM
    for index, v in pairs(AllInteractionVM) do
        local VM = v
        VM:ResetVM()
    end
end


function MiniGameCrystalTowerVM:GetCenterBlowVM()
    return self.CenterBlowVM
end

--- @type 获得所有SubView的VM
function MiniGameCrystalTowerVM:GetAllInteractionVM()
    return self.AllInteractionVM
end

--- @type 获得VM
function MiniGameCrystalTowerVM:GetInteractionVM(Pos)
    local AllInteractionVM = self.AllInteractionVM
    for _, v in pairs(AllInteractionVM) do
        local VM = v
        if VM.Pos == Pos then
            return VM
        end
    end
end
 --------------------------------------------------------------
function MiniGameCrystalTowerVM:GetCenterInteractResultVM()
    return self.CenterInteractResultVM
end

function MiniGameCrystalTowerVM:UpdateCenterInteractResultVM(Data)
    self.CenterInteractResultVM:UpdateVM(Data)
end

--- @type 获取中间Tip的VM
function MiniGameCrystalTowerVM:GetInteractionResultTipVM()
    return self.InteractionResultTipVM
end

--- @type 在某位置插入元素
function MiniGameCrystalTowerVM:UpdateListItemByPos(Value, Pos)
    local InteractResultVMList = self.InteractResultVMList
    local AllItems = InteractResultVMList:FindAll(function() return true end)
    if Pos > #AllItems then -- 对应中间的结果
        self:UpdateCenterInteractResultVM(Value)
        return
    end
    local VM = AllItems[Pos]
    VM:UpdateVM(Value)
end

-- --- @type 加载tableviews
function MiniGameCrystalTowerVM:UpdateResultVMList(Data)
    local List = self.InteractResultVMList
    if List == nil or Data == nil then
        return
    end

    if Data[1] == nil then
        List:Clear()
        return
    end

    if nil ~= List and List:Length() > 0 then
        List:Clear()
    end

    List:UpdateByValues(Data)
end

--- @type 获取交互结果页面VM
function MiniGameCrystalTowerVM:GetInteractResultVM()
    return self.InteractResultVM
end
 --------------------------------------------------------------

--- @type 是否是最后一轮
function MiniGameCrystalTowerVM:SetbInEndRound(bInEndRound)
    self.bInEndRound = bInEndRound
    self.InteractResultVM:SetbInEndRound(bInEndRound)
end

--- @type 更新增加分数
function MiniGameCrystalTowerVM:UpdateAddScore(ReasonIsInteracte)
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    local UpdateTime = 0.6  
    
    self:UpdateStrengthPro(GameInst, UpdateTime, ReasonIsInteracte)
   
    local Score = GameInst.AddScore
    self:AddAccruedScore(Score)
    GameInst.AddScore = 0
    print("AccruedScore = %s", self.AccruedScore)

    if self.ShowAddScoreTimer ~= nil and Score ~= nil and GameInst.CurRoundIndex < GameInst.DefineCfg.MaxRound then
        TimerMgr:CancelTimer(self.ShowAddScoreTimer)
    end

    local function ShowAddScore()
        self.bAddScoreVisible = tonumber(self.AccruedScore) ~= 0
        self.ShowAddScoreTimer = nil
        -- self.AddScore = AddScore
        if self.bAddScoreVisible then
            self.TextQuantityValue = GameInst:GetTextQuantityValue()--string.format(LSTR("力量值%dPZ"), GameInst:GetTextQuantityValue())

            local AccruedScore = tonumber(self.AccruedScore)
           
            self:UpdateAddScoreFormat(AccruedScore)     -- 根据积累的分获得需要展示的分数
            
            self:UpdateAddScoreColor(AccruedScore)      -- 根据积累的分获得颜色样式
            
            self:ResetAccruedScore()                                 -- 积累得分用完了，重置
            
            self:UpdateAddScorePos(GameInst)                -- 更新位置
        
            EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AddScoreAnimIn)

            if self.HideTimer ~= nil then
                TimerMgr:CancelTimer(self.HideTimer)
            end
            self.HideTimer = TimerMgr:AddTimer(self, function()
                GameInst:SetAddScoreVisibleFalse()
                self.HideTimer = nil
            end, 1)
        end
    end
    if tonumber(self.AccruedScore) ~= 0 and GameInst.CurRoundIndex < GameInst.DefineCfg.MaxRound and GameInst.IsBegin then
        self.ShowAddScoreTimer = TimerMgr:AddTimer(self, ShowAddScore, UpdateTime)
    end

end

--- @type 积累得分
function MiniGameCrystalTowerVM:AddAccruedScore(Score) -- 20 -40 20
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    local StrengthValue = tonumber(GameInst:GetStrengthValue())
    local LastStrengthValue = tonumber(self.TextQuantityValue) -- 0
    self.AccruedScore = StrengthValue - LastStrengthValue
end

--- @type 清空积累的分
function MiniGameCrystalTowerVM:ResetAccruedScore()
    self.AccruedScore = 0
end

--- @type 根据积累得分变成颜色
function MiniGameCrystalTowerVM:UpdateAddScoreColor(AccruedScore)
    self.AddScoreOutLineColor = AccruedScore > 0 and "D34C2EFF" or "#23232399"
    self.AddScoreColor = AccruedScore > 0 and "D8FFDBFF" or "#d5d5d5"
end

function MiniGameCrystalTowerVM:UpdateAddScoreFormat(AccruedScore)
    if AccruedScore > 0 then
        self.AddScore = string.format("+%s", AccruedScore)
    elseif AccruedScore == 0 then
        self.AddScore = AccruedScore
    else
        self.AddScore = string.format("%s", AccruedScore)
    end
end

--- @type 更新进度条
function MiniGameCrystalTowerVM:UpdateStrengthPro(GameInst, UpdateTime, ReasonIsInteracte)
    if self.UpdateProTimer ~= nil then
        TimerMgr:CancelTimer(self.UpdateProTimer)
    end
    if not ReasonIsInteracte then
        self.CTStrengthPro = 0
    end

    local CurPro = self.CTStrengthPro
    local TargetPro = GameInst.CTStrengthPro
    if CurPro == nil or TargetPro == nil then
        return
    end
    local IntervalTime = 0.05
    local LoopCount = UpdateTime / IntervalTime
    local AddProOneLoop = (TargetPro - CurPro) / LoopCount
    -- FLOG_INFO("MiniGameCrystalTowerVM CurPro = %s, TargetPro = %s LoopCount = %s", CurPro, TargetPro, LoopCount)

    local function UpdatePro()
        self.CTStrengthPro = self.CTStrengthPro + AddProOneLoop
        if AddProOneLoop > 0 and ReasonIsInteracte then
            AudioUtil.LoadAndPlayUISound(CrystalTowerAudioDefine.AudioPath.AddStrengthPro)
        end
    end
    self.UpdateProTimer = TimerMgr:AddTimer(self, UpdatePro, 0, IntervalTime, LoopCount)
end

function MiniGameCrystalTowerVM:UpdateAddScorePos(GameInst)
    local StrengthValue = GameInst:GetStrengthValue()
    local EndPosY = 340--225
    local FullStrengthVal = 500
    local TotalYLength = 592
    local PosY = EndPosY - math.clamp(StrengthValue / FullStrengthVal, 0, 1) * TotalYLength
    self.AddScorePos = UE.FVector2D(-310, PosY) -- 242 -350
end

--- @type 加载tableviews
function MiniGameCrystalTowerVM:UpdateList(List, Data)
    if List == nil then
        return
    end
    List:Clear()
    List:UpdateByValues(Data, nil)
end

return MiniGameCrystalTowerVM