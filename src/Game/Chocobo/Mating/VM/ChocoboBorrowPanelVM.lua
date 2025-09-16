--Author:Easy
--DateTime: 2023/1/10

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local UIBindableList = require("UI/UIBindableList")
local ChocoboInfoAttrItemVM = require("Game/Chocobo/Life/VM/ChocoboInfoAttrItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local ChocoboUiIconCfg = require("TableCfg/ChocoboUiIconCfg")
local ChocoboNameCfg = require("TableCfg/ChocoboNameCfg")
local BuddyColorCfg = require("TableCfg/BuddyColorCfg")
local ChocoboRentCfg = require("TableCfg/ChocoboRentCfg")

local ChocoboBorrowPanelVM = LuaClass(UIViewModel)
function ChocoboBorrowPanelVM:Ctor()
    self.CurChocoboID = 0
    self.TextLevel = nil
    self.TextName = nil
    self.Color = ChocoboDefine.DEFAULT_HEAD_COLOR
    self.TextColor = nil
    self.GenderPath = nil
    self.StainID = nil

    self.RadialProcess = nil
    self.TextBorrowedNum = nil

    self.BtnBorrowText = ""
    self.CanRefresh = false
    self.CanBorrow = false
    self.RefreshCost = 0
    self.RentCost = 0
    self.RefreshCostText = ""
    self.RentCostText = ""
    self.RentCostTextColor = "dc5868FF"
    self.CanBtnSub = false
    self.CanBtnAdd = false

    self.Gender = 0
    self.Generation = 1
    self.AttrVMList = UIBindableList.New(ChocoboInfoAttrItemVM)
end

function ChocoboBorrowPanelVM:OnInit()
end

function ChocoboBorrowPanelVM:OnBegin()
end

function ChocoboBorrowPanelVM:Clear()
end

function ChocoboBorrowPanelVM:OnEnd()
end

function ChocoboBorrowPanelVM:OnShutdown()
end

function ChocoboBorrowPanelVM:SetGender(InGender)
    if self.Gender == InGender then
        return
    end
    self.Gender = InGender
    _G.ChocoboMgr:RentInfoReq(self.Gender, self.Generation)
end

function ChocoboBorrowPanelVM:SetGeneration(InGeneration)
    InGeneration = math.clamp(InGeneration, 1, ChocoboDefine.GENERATION_MAX)
    self.CanBtnAdd = InGeneration < ChocoboDefine.GENERATION_MAX
    self.CanBtnSub = InGeneration > 1
    
    if self.Generation == InGeneration then
        return
    end
    self.Generation = InGeneration
    _G.ChocoboMgr:RentInfoReq(self.Gender, self.Generation)
end

function ChocoboBorrowPanelVM:UpdateRentInfo(InRentInfo)
    if not InRentInfo or not InRentInfo.Info then return end

    local Data = InRentInfo.Info.Info
    if Data == nil then return end
    
    self.CurChocoboID = Data.ID
    local NameCfg1 = ChocoboNameCfg:FindValue(Data.Name.Name1, "Name") or ""
    local NameCfg2 = ChocoboNameCfg:FindValue(Data.Name.Name2, "Name") or ""
    self.TextName = string.format("%s %s", NameCfg1, NameCfg2)
    self.GenderPath = ChocoboUiIconCfg:FindPathByKey(
            Data.Gender == 0 and ProtoRes.CHOCOBO_UI_ICON_TYPE.GENDER_BOY or ProtoRes.CHOCOBO_UI_ICON_TYPE.GENDER_GIRL
    )

    self.TextLevel = (Data.Mating or {}).Generation or 1
    self.StainID = Data.Color.RGB
    local ColorCfg = BuddyColorCfg:FindCfgByKey(Data.Color.RGB)
    if ColorCfg then
        self.TextColor = ColorCfg.Name
        self.Color = _G.UE.FLinearColor(ColorCfg.R / 255, ColorCfg.G / 255, ColorCfg.B / 255, 1)
    end

    self:UpdateAttrInfo(Data.Attr.Attr, Data.Attr.Max, Data.Gene)
    self:UpdateCost(InRentInfo)
    self:UpdateBorrowedProcess()
end

function ChocoboBorrowPanelVM:UpdateAttrInfo(Attr, Max, Gene)
    local AttrInfoList = {}
    for i = 1, #Attr do
        local TempData = {
            AttrID = i,
            AttrName = ChocoboDefine.CHOCOBO_ATTR_TYPE_NAME[i],
            AttrValue = Attr[i],
            MaxAttrValue = Max[i],
            GeneRed = Gene.GeneRed[i] or 0,
            GeneBlue = Gene.GeneBlue[i] or 0
        }
        table.insert(AttrInfoList, TempData)
    end
    self.AttrVMList:UpdateByValues(AttrInfoList)
end

function ChocoboBorrowPanelVM:UpdateCost(InRentInfo)
    if not (InRentInfo and InRentInfo.Info) then return end

    local RentData = ChocoboRentCfg:FindCfgByKey(self.Generation)
    if not RentData then return end

    local RefreshCount = InRentInfo.Info.RefreshCount or 0
    local ScoreValue = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)

    local IsFirstRefreshFree = (RefreshCount == 0)
    self.RefreshCost = IsFirstRefreshFree and 0 or RentData.RefreshCost
    self.RentCost = RentData.RentCost

    self.CanRefresh = IsFirstRefreshFree or (ScoreValue >= self.RefreshCost)
    self.CanBorrow = (ScoreValue >= self.RentCost)

    self.RefreshCostText = IsFirstRefreshFree and _G.LSTR(420173) or tostring(self.RefreshCost)
    self.RentCostText = tostring(self.RentCost)
    self.RentCostTextColor = self.CanBorrow and "d5d5d5FF" or "dc5868FF"
end

function ChocoboBorrowPanelVM:UpdateBorrowedProcess()
    local Count = _G.ChocoboMainVM:GetBorrowCount()
    self.RadialProcess = Count / _G.ChocoboMgr.RentLimit
    self.TextBorrowedNum = string.format("%d/%d", Count, _G.ChocoboMgr.RentLimit)
end

function ChocoboBorrowPanelVM:UpdateBorrowBtn(Value)
    local Count = _G.ChocoboMainVM:GetBorrowCount()
    if Count >= _G.ChocoboMgr.RentLimit then
        self.CanBorrow = false
        self.BtnBorrowText = _G.LSTR(420085) -- "租借"
        return
    end

    local ScoreValue = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
    if ScoreValue < self.RentCost then
        self.CanBorrow = false
        self.BtnBorrowText = _G.LSTR(420085) -- "租借"
        return
    end

    self.CanBorrow = Value
    self.BtnBorrowText = Value and _G.LSTR(420085) or _G.LSTR(420153) -- "租借" 或 "已租借"
end

return ChocoboBorrowPanelVM
