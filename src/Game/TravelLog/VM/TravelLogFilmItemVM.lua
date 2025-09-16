---
--- Author: sammrli
--- DateTime: 2024-02-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIBindableList = require("UI/UIBindableList")
local TravelLogVideoSequenceItemVM = require("Game/TravelLog/VM/TravelLogVideoSequenceItemVM")

local TravelLogCfg = require("TableCfg/TravelLogCfg")

local MajorUtil = require("Utils/MajorUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")

local LSTR = _G.LSTR

---@class TravelLogFilmItemVM : UIViewModel
local TravelLogFilmItemVM = LuaClass(UIViewModel)

function TravelLogFilmItemVM:Ctor()
    self.TextNum = ""
    self.FilmVMList = UIBindableList.New(TravelLogVideoSequenceItemVM)
    self.FilmNum = 0
    self.CurrentSelectedIndex = 0
    self.LogID = 0
    self.FilmLength = 0
end

function TravelLogFilmItemVM:Show(LogID)
    self.LogID = LogID
    self.CurrentSelectedIndex = 1
    self.FilmVMList:FreeAllItems()
    self.FilmLength = 0

    if not LogID then
        return
    end

    self.Cfg = TravelLogCfg:FindCfgByKey(LogID)
    if not self.Cfg then
        return
    end

    local PathList = string.split(self.Cfg.CutscenID, ",")
    if PathList then
        local Lengh = math.max(#PathList, 7)
        for i=1, Lengh do
            local VM = {}
            VM.Index = i
            local Path = PathList[i]
            if Path then
                VM.Path = Path
                VM.Text = tostring(i)
                VM.Selected = i == 1
                self.FilmLength = self.FilmLength + 1
            end
            self.FilmVMList:AddByValue(VM)
        end
    end

    if self.FilmLength > 0 then
        self.TextNum = string.format("（%d/%d）", 1, self.FilmLength)
    else
        self.TextNum = ""
        self.FilmVMList:Clear(true)
    end
    self.FilmNum = self.FilmLength
end

function TravelLogFilmItemVM:Switch(Index)
    for i=1, self.FilmLength do
        local VM = self.FilmVMList:Get(i)
        if VM then
            VM:SetSelected(Index == VM.Index)
        end
    end
    self.CurrentSelectedIndex = Index
    self.TextNum = string.format("（%d/%d）", Index, self.FilmLength)
end

function TravelLogFilmItemVM:Play(TabIndex, ScrollOffset, SubGenreIndex)
    if self.Cfg then
        --职业限制判断
        local ClassJobCategory = self.Cfg.ClassJobCategory
        if ClassJobCategory then
            if next(ClassJobCategory) then --如果有配置才做限制
                local IsMatch = false
                local ProfID = MajorUtil.GetMajorProfID()
                for _, CategoryID in ipairs(ClassJobCategory) do
                    if ProfID == CategoryID then
                        IsMatch = true
                        break
                    end
                end
                if not IsMatch then
                    _G.MsgTipsUtil.ShowTipsByID(70004)
                    return
                end
            end
        end
    end

    -- 已经准备进入战斗副本
    if _G.PWorldVoteVM.IsMajorReady then
        _G.MsgTipsUtil.ShowTips(LSTR(530010)) --530010("副本准备中，不可观看")
        return
    end

    local function PlayFilmList()
        local SequencePathList = {}
        for i=1, self.FilmVMList:Length() do
            local VM = self.FilmVMList:Get(i)
            if VM and not string.isnilorempty(VM.Path) then
                table.insert(SequencePathList, VM.Path)
            end
        end
        if #SequencePathList > 0 then
            _G.TravelLogMgr:PlayFilmList(SequencePathList, TabIndex, ScrollOffset, self.LogID, self.CurrentSelectedIndex, SubGenreIndex)
        end
    end

    if _G.PWorldMatchMgr:IsMatching() then
        local function RightBtnCallback()
            _G.PWorldMatchMgr:CancelAllMatch()
            _G.PWorldMatchMgr:CancelAllCrystallineMatches()
            _G.PWorldMatchMgr:CancelAllChocobosMatches()
            PlayFilmList()
        end
        MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(530001), RightBtnCallback, nil,
        LSTR(10003), LSTR(10002)) --530001("播放会取消匹配，是否继续？")
    else
        PlayFilmList()
    end
end

return TravelLogFilmItemVM
