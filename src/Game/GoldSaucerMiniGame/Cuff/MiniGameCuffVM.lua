--
-- Author: Leo
-- Date: 2024-1-10 19:32
-- Description:金蝶小游戏 重击吉尔伽美什
--

local LuaClass = require("Core/LuaClass")
local MiniGameBaseVM = require("Game/GoldSaucerMiniGame/MiniGameBaseVM")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local GoldSaucerCuffGameResultItemVM = require("Game/GoldSaucerGame/View/Cuff/ItemVM/GoldSaucerCuffGameResultItemVM")
local GoldSaucerCuffGameInteractiveItemVM = require("Game/GoldSaucerGame/View/Cuff/ItemVM/GoldSaucerCuffGameInteractiveItemVM")

local ProtoRes = require("Protocol/ProtoRes")

local UIBindableList = require("UI/UIBindableList")
local MiniGameState = GoldSaucerMiniGameDefine.MiniGameStageType
local LSTR = _G.LSTR
local TimerMgr = _G.TimerMgr
---@class MiniGameCuffVM
local MiniGameCuffVM = LuaClass(MiniGameBaseVM)

---Ctor
function MiniGameCuffVM:Ctor()
    self.AllSubViewVM = {} 
    self.bCuffScoreVisible = false
    self.CuffScore = "+0"
    self.TextStrengthValue = ""
    self.StrengthPro = 0
    self.TextMultiple = ""
    self.bTextMultipleVisible = false
    self.bPanelNormalVisible = true
    self.bPanelResultVisible = false
    self.bFailed = false
    self.bSuccessed = false
    self.RewardGot = "0" -- 获取奖励数量
    self.CuffAddRewardGot = "0"
    local CoinID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE -- 金碟币ID
	local IconPath = _G.ScoreMgr:GetScoreIconName(CoinID)
    self.AwardIconPath = IconPath
    self.TextHint = ""
    self.bTextHintVisible = false
    self.JDCoinColor = "#FFFFFF"
    self.RightBtnContent = LSTR(250001) -- 再 战
    self.bEnterEndState = false
    self.ResultText = ""
    self.CriticalText = ""
    self.bCriticalVisible = false
    -- self.TextTipsTitle = "" -- 界面功能提示

    self.ResultVMList = UIBindableList.New(GoldSaucerCuffGameResultItemVM)
    self.InteractiveVMList = UIBindableList.New(GoldSaucerCuffGameInteractiveItemVM)
    self.CenterBlowVM = GoldSaucerCuffGameInteractiveItemVM.New()
end

function MiniGameCuffVM:Reset()
    self.AllSubViewVM = {} 
    self.bCuffScoreVisible = false
    self.CuffScore = "+0"
    self.TextStrengthValue = ""
    self.StrengthPro = 0
    self.TextMultiple = ""
    self.bTextMultipleVisible = false
    self.bPanelNormalVisible = true
    self.bPanelResultVisible = false
    self.bFailed = false
    self.bSuccessed = false
    self.RewardGot = "0" -- 获取奖励数量
    self.CuffAddRewardGot = "0"
    local CoinID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE -- 金碟币ID
	local IconPath = _G.ScoreMgr:GetScoreIconName(CoinID)
    self.AwardIconPath = IconPath
    self.TextHint = ""
    self.bTextHintVisible = false
    self.JDCoinColor = "#FFFFFF"
    self.RightBtnContent = LSTR(250001) -- 再 战
    self.bEnterEndState = false
    self.ResultText = ""
    self.CriticalText = ""
    self.bCriticalVisible = false
    -- self.TextTipsTitle = "" -- 界面功能提示

    self.ResultVMList:Clear()
    self.InteractiveVMList:Clear()
    self.CenterBlowVM:ResetVM()
end

--- 全部更新
function MiniGameCuffVM:OnUpdateVM()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    self:UpdateData()
    if GameInst.ResultListData ~= nil then
        self:UpdateList(self.ResultVMList, GameInst.ResultListData)
    end
    if not GameInst.IsBegin then
        return
    end
    if self.CurRoundID == GameInst.CurRound then -- 不符合业务
        return
    end
    self.CurRoundID = GameInst.CurRound

    local NextRoundInteractionCfg = GameInst.NextRoundInteractionCfg
    local Length = #NextRoundInteractionCfg
    if Length > 1 then
        self:UpdateInteractiveList(self.InteractiveVMList, NextRoundInteractionCfg)
        self.CenterBlowVM:ResetVM()
    elseif Length == 0 then
        if NextRoundInteractionCfg.Pos ~= nil then
            self.InteractiveVMList:Clear()
            self.CenterBlowVM:UpdateVM(NextRoundInteractionCfg)
        end
    end

    
    _G.ObjectMgr:CollectGarbage(false)
end

--- 刷新时间显示
function MiniGameCuffVM:OnUpdateTimeShow()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    local TimeSecondsInteger = GameInst:GetRemainSecondsInteger()
    self.MonsterTossTextTitle = TimeSecondsInteger
    self.TextStrengthValue = string.format(LSTR(250006), GameInst:GetTextStrengthValue()) -- 力量值%dPZ
    self.bTextMultipleVisible = GameInst.bTextMultipleVisible
end

--- @type 刷新单个VM
function MiniGameCuffVM:UpdateSingleSubViewVM(ID, InteractionData)
    local VM = self.AllSubViewVM[ID]
    VM:UpdateVM(InteractionData)
end

--- @type 只刷数据不刷SubView的VM
function MiniGameCuffVM:UpdateData(bInteractive)
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    -- self.RewardGot = GameInst.RewardGot
    self.StrengthPro = GameInst.StrengthPro

    local LastCuffScore = string.gsub(self.CuffScore, "+", "")
    local NeedCuffScore = GameInst.CuffScore

    if bInteractive then -- 因为交互而产生的数据变化
        self.bCuffScoreVisible = GameInst.bCuffScoreVisible
        if self.bCuffScoreVisible then
            NeedCuffScore = NeedCuffScore + tonumber(LastCuffScore)
            self.CuffScore = string.format("+%s", NeedCuffScore)
        -- end
        -- if self.bCuffScoreVisible then
            if self.AddScoreTimer ~= nil then
                TimerMgr:CancelTimer(self.AddScoreTimer)
                self.AddScoreTimer = nil
            end
            self.AddScoreTimer = TimerMgr:AddTimer(self, function()
                GameInst:SetCuffScoreVisibleFalse()
                self.bCuffScoreVisible = false
                self.CuffScore = "+0"  
            end, 1.2)
        end
    end
    self.CriticalText = GameInst.CriticalText
    self.bCriticalVisible = GameInst.bCriticalVisible
    self.TextStrengthValue = string.format(LSTR(250006), GameInst:GetTextStrengthValue()) -- 力量值%dPZ
    self.TextMultiple = GameInst.TextMultiple
    self.bPanelNormalVisible = GameInst.bPanelNormalVisible
    self.bPanelResultVisible = GameInst.bPanelResultVisible
    self.bFailed = GameInst.bFailed
    self.bSuccessed = GameInst.bSuccessed
    self.RewardGot = GameInst.RewardGot
    if tonumber(GameInst.CuffAddRewardGot) ~= 0 then
        self.CuffAddRewardGot = GameInst.CuffAddRewardGot
        -- EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimObtainNumberIn)
    end
    self.TextHint = GameInst.TextHint
    self.bTextHintVisible = GameInst.bTextHintVisible
    self.JDCoinColor = GameInst.JDCoinColor
    self.RightBtnContent = GameInst.RightBtnContent
    self.bEnterEndState = GameInst.bEnterEndState
    self.ResultText = GameInst.ResultText
end

--- @type 单独刷新奖励
function MiniGameCuffVM:UpdateRewardGotSingle()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    self.RewardGot = GameInst.RewardGot
end

function MiniGameCuffVM:SetOriginReward()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    
    self.RewardGot = GameInst:GetOriginRewardGot()
end

-- --- @type 刷新所有SubViewVM
-- function MiniGameCuffVM:UpdateAllSubViewVM(NextRoundInteractionCfgs)
--     local AllSubViewVM = self.AllSubViewVM
--     for index, v in pairs(NextRoundInteractionCfgs) do
--         local InteractionCfg = v
--         for i = 1, 10 do
--             local VM = AllSubViewVM[i]
--             local ID = VM:GetID()
--             if InteractionCfg.Pos == ID then
--                 VM:UpdateVM(NextRoundInteractionCfgs[index])
--                 break
--             end
--         end
--     end
-- end

function MiniGameCuffVM:SetbTextHintVisible()
    local GameInst = self.MiniGame
    if GameInst == nil then
        return
    end
    self.TextHint = GameInst.TextHint
    self.bTextHintVisible = GameInst.bTextHintVisible
end


function MiniGameCuffVM:UpdateStrengthPro(StrengthPro)
    self.StrengthPro = StrengthPro
end


--- @type 重置所有SubViewVM
function MiniGameCuffVM:ResetAllSubViewVM()
    local AllSubViewVM = self.AllSubViewVM
    for index, v in pairs(AllSubViewVM) do
        local VM = v
        VM:ResetVM()
    end
end


function MiniGameCuffVM:GetCenterBlowVM()
    return self.CenterBlowVM
end

--- @type 获得所有SubView的VM
function MiniGameCuffVM:GetAllSubViewVMs()
    return self.AllSubViewVM
end

--- @type 获得VM
function MiniGameCuffVM:GetSubViewVM(ID)
    return self.AllSubViewVM[ID]
end

--- @type 加载tableviews
function MiniGameCuffVM:UpdateInteractiveList(List, Data)
    if List == nil then
        return
    end
    List:Clear()

    for _, v in pairs(Data) do
        local Elem = v
        local VM = GoldSaucerCuffGameInteractiveItemVM.New()
        VM:UpdateVM(Elem)
        List:Add(VM)
    end
end

--- @type 加载tableviews
function MiniGameCuffVM:UpdateList(List, Data)
    if List == nil then
        return
    end
    List:Clear()
    List:UpdateByValues(Data, nil)
end

return MiniGameCuffVM