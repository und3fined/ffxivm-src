
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MiniCactpotKeyItemVM = require("Game/MiniCactpot/MiniCactpotKeyItemVM")
local MiniCactpotPayItemVM = require("Game/MiniCactpot/MiniCactpotPayItemVM")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")

local EventMgr = _G.EventMgr
local EventID = _G.EventID
local LSTR = _G.LSTR
---@class MiniCactpotMainVM : UIViewModel
local MiniCactpotMainVM = LuaClass(UIViewModel)

MiniCactpotMainVM.ArrowState = {
    Gray = 1,       --不可点击
    Normal = 2,     --可以点选   选择一条线
    Locked = 3,     --开奖后所选择的那条线会变成Locked
    AwardView = 4,  --奖励预览
}

--开奖后的，选择线进行奖励预览的话，单独处理。因为效果是叠加的
MiniCactpotMainVM.CellState = {
	Masked = 1,	--蒙版ing，可以点击开格子
	Opend = 2,	--开过格子，正常显示数字
	Select = {MaxAward = 10000, MiddleAward = 3600, OtherAward = 3 },	--确定线之后，线上的格子处于选中的状态
    UnSelect = 4, --
}

-- MiniCactpotMainVM.PreviewItemState = {
--     Normal = 1,     --常规
--     Locked = 2,     --开奖后对应的奖励
--     AwardView = 3,  --奖励预览对应的
-- }

MiniCactpotMainVM.Arrow2CellList = 
{
    [1] = {7, 8, 9},
    [2] = {4, 5, 6},
    [3] = {1, 2, 3},
    [4] = {1, 5, 9},
    [5] = {1, 4, 7},
    [6] = {2, 5, 8},
    [7] = {3, 6, 9},
    [8] = {3, 5, 7},
}

function MiniCactpotMainVM:Ctor()
    self.CurTermStr = LSTR(230019) -- "000001期"
    self.OwnerJDCoins = ""
    for index = 1, 9 do
        self["GridNum" .. index] = ""
    end
    self.ClearGridNums = true

    self.ArrowGroupState = {Index = -1, State = MiniCactpotMainVM.ArrowState.Gray}
    -- for index = 1, 8 do
    --     self.ArrowState = {Index = index, State = MiniCactpotMainVM.ArrowState.Gray}
    -- end
    --9个格子上层的这招的顶层panel，隐藏后，所有格子都会显示出来
    self.GridMaskPanel = true
    self.CostCoinValue = 0 -- 本次购买需要消耗的金碟币数量
    self.CostCoinColor = "#FFFFFF" -- 默认白色 af4c58红色
    self.CostCoinColor2 = "#513826"
    self.RemainPurCount = "" -- 今日剩余购买次数提示

    self.PlayAnim = ""
    -- self.ControlTip = ""
    self.OperationTip = LSTR(230001) -- 请刮开任意3个格子

    self.ArrowGroupOpacity = 0.5

    -- self.UpdateCellData = {0, 0, 0, 0, 0, 0, 0, 0, 0}
    self.CellVMList = UIBindableList.New(MiniCactpotKeyItemVM)

    self.MiniCactpotFinish = {}

    self.AwardVMList1 = UIBindableList.New(MiniCactpotPayItemVM)
    self.AwardVMList2 = UIBindableList.New(MiniCactpotPayItemVM)
end

function MiniCactpotMainVM:OnInit()
    for index = 1, 9 do
        local BindProperty = self.BindableProperties["GridNum" .. index]
        if BindProperty then
            BindProperty:SetNoCheckValueChange(true)
        end
    end
    self.OwnerJDCoins = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
end

function MiniCactpotMainVM:GetPreviewItemVM(Sum)
    if Sum < 20 then
        return self.AwardVMList1:Get(Sum - 5)
    end

    return self.AwardVMList2:Get(Sum - 19)
end

function MiniCactpotMainVM:OnBegin()
    self.CellVMList:Clear()
    for index = 1, 9 do
        local CellVM = MiniCactpotKeyItemVM.New()
        CellVM.Index = index
        CellVM.SetCellState = MiniCactpotMainVM.CellState.Masked
        CellVM.CellIsChecked = false
        CellVM.NumberIconPath = ""
        CellVM.Number = 0
        self.CellVMList:Add(CellVM)
    end

    --6-19
    self.AwardVMList1:Clear()
    for index = 1, 14 do
        local PreviewItemVM = MiniCactpotPayItemVM.New()
        PreviewItemVM.Sum = index + 5
        local Text = _G.MiniCactpotMgr.AwardOverviewMap[PreviewItemVM.Sum] or 0
        local MoneyText = UIBinderSetTextFormatForMoney:GetText(Text)
        PreviewItemVM.AwardNum = MoneyText
        PreviewItemVM.IsChecked = false
        PreviewItemVM.IsSelected = false
        self.AwardVMList1:Add(PreviewItemVM)
    end

    --20-24
    self.AwardVMList2:Clear()
    for index = 1, 5 do
        local PreviewItemVM = MiniCactpotPayItemVM.New()
        PreviewItemVM.Sum = index + 19
        local Text = _G.MiniCactpotMgr.AwardOverviewMap[PreviewItemVM.Sum] or 0
        local MoneyText = UIBinderSetTextFormatForMoney:GetText(Text)
        PreviewItemVM.AwardNum = MoneyText
        PreviewItemVM.IsChecked = false
        PreviewItemVM.IsSelected = false
        self.AwardVMList2:Add(PreviewItemVM)
    end
    
    self.LastPrewviewItemVM = nil
end

function MiniCactpotMainVM:OnEnd()
    self:Reset()
end

function MiniCactpotMainVM:OnShutdown()
end

function MiniCactpotMainVM:Reset()
    --先重置，否则view-viewmodel重新绑定的时候会显示tip：选择一条线
    -- self.ControlTip = ""

    --重置
    for index = 1, 9 do
        local CellVM = self.CellVMList:Get(index)
        CellVM.SetCellState = MiniCactpotMainVM.CellState.Masked
        CellVM.CellIsChecked = false
        CellVM.Number = 0
        CellVM.NumberIconPath = ""
    end
    self.OperationTip = LSTR(230001) -- 请刮开任意3个格子
    self.ClearGridNums = true

    for index = 1, 9 do
        self["GridNum" .. index] = ""
    end

    _G.MiniCactpotMgr.CanClickCellNum = 3
    self.MiniCactpotFinish = {}
    self.LastPrewviewItemVM = nil

    --6-19
    for index = 1, 14 do
        local PreviewItemVM = self.AwardVMList1:Get(index)
        PreviewItemVM.IsChecked = false
        PreviewItemVM.IsSelected = false
    end

    --20-24
    for index = 1, 5 do
        local PreviewItemVM = self.AwardVMList2:Get(index)
        PreviewItemVM.IsChecked = false
        PreviewItemVM.IsSelected = false
    end

    if self.SelectPreviewItemVM ~= nil then
        self.SelectPreviewItemVM.IsSelected = false
        self.SelectPreviewItemVM = nil
    end

    MiniCactpotMainVM.OwnerJDCoins = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
end

function MiniCactpotMainVM:OnMiniCactpotCellOpen(CellIndex, CellNumber, IsFirstEnter)
	if IsFirstEnter then
        self:Reset()

        self.GridMaskPanel = true
        for i = 1, 9 do
            self["GridNum" .. i] = ""
        end

        self.CurTermStr = string.format(LSTR(230020), _G.MiniCactpotMgr:GetCurTurm()) -- %06d期
        --一开始，8条线的按钮都是Gray的状态
        self.ArrowGroupState = {Index = -1, State = MiniCactpotMainVM.ArrowState.Gray}
        self.ArrowGroupOpacity = 0.5

    else
        _G.MiniCactpotMgr.CanClickCellNum = _G.MiniCactpotMgr.CanClickCellNum - 1

        if _G.MiniCactpotMgr.CanClickCellNum == 2 then
            self.OperationTip = LSTR(230002) -- "还可刮开2个格子"
        elseif _G.MiniCactpotMgr.CanClickCellNum == 1 then
            self.OperationTip = LSTR(230003) -- "还可刮开1个格子"
        else
            self.ArrowGroupState = {Index = -1, State = MiniCactpotMainVM.ArrowState.Normal}

            self.OperationTip = LSTR(230004) -- "请点击箭头选择一条线"
            EventMgr:SendEvent(EventID.MiniCactpotOpenRemuner)
            self.ArrowGroupOpacity = 1
        end
	end

	if CellIndex and CellIndex >= 1 and CellIndex <= 9 and CellNumber then
		self["GridNum" .. CellIndex] = CellNumber

        --回调：播放umg动效
        EventMgr:SendEvent(EventID.MiniCactpotAnimOpenGrid, string.format("AnimOpenGrid%s", CellIndex))
        -- self.PlayAnim = 

        local CellVM = self.CellVMList:Get(CellIndex)
        if CellVM then
            CellVM.NumberIconPath = _G.MiniCactpotMgr.Number2PathMap[CellNumber]
            CellVM.SetCellState = MiniCactpotMainVM.CellState.Opend
            CellVM.Number = CellNumber
        end
	end
end

function MiniCactpotMainVM:OnMiniCactpotFinish(MiniCactpotFinishRsp)
	if not MiniCactpotFinishRsp or #MiniCactpotFinishRsp.AllCells ~= 9 then
		FLOG_ERROR("Minicactpot OnMiniCactpotFinish")
		return
	end
	for index = 1, 9 do
        local Num = MiniCactpotFinishRsp.AllCells[index]
        local CellVM = self.CellVMList:Get(index)
        if CellVM.Number == 0 then
            self["GridNum" .. index] = Num
            CellVM.NumberIconPath = _G.MiniCactpotMgr.Number2PathMap[Num]
            CellVM.SetCellState = MiniCactpotMainVM.CellState.Opend
            CellVM.Number = Num
        end
	end

    self.GridMaskPanel = false

    self.MiniCactpotFinish =
        {
            IsFinish = true,
            IsBigWard = _G.MiniCactpotMgr:GetMaxAwardNum() <= MiniCactpotFinishRsp.AwardCoins
        }

    local ArrowIdx = _G.MiniCactpotMgr:GetArrowIndex()
    local Sum = 0
    --设置3个为select状态
    local AwardCoins = MiniCactpotFinishRsp.AwardCoins
    local CellIdxList = self.Arrow2CellList[ArrowIdx]
    local Select = MiniCactpotMainVM.CellState.Select
    for idx = 1, #CellIdxList do
        local CellVM = self.CellVMList:Get(CellIdxList[idx])
        if AwardCoins == Select.MaxAward then
            CellVM.SetCellState = Select.MaxAward
        elseif AwardCoins >= Select.MiddleAward then
            CellVM.SetCellState = Select.MiddleAward
        elseif AwardCoins >= Select.OtherAward then
            CellVM.SetCellState = Select.OtherAward
        end
        Sum = Sum + CellVM.Number
    end

    local PreviewItemVM = self:GetPreviewItemVM(Sum)
    self.SelectPreviewItemVM = PreviewItemVM
    PreviewItemVM.IsSelected = true
end

--选择哪条线进行开奖
function MiniCactpotMainVM:OnSelectArrow(ArrowIdx)
    --设置3个为select状态
    local CellIdxList = self.Arrow2CellList[ArrowIdx]

    --重置
    for index = 1, 9 do
        local IsSelect = false
        for idx = 1, #CellIdxList do
            if CellIdxList[idx] == index then
                IsSelect = true
            end
        end

        if not IsSelect then
            local CellVM = self.CellVMList:Get(index)
            CellVM.SetCellState = MiniCactpotMainVM.CellState.UnSelect
        end
    end

    for idx = 1, #CellIdxList do
        local CellVM = self.CellVMList:Get(CellIdxList[idx])
        CellVM.SetCellState = MiniCactpotMainVM.CellState.Select.MiddleAward
    end
end

function MiniCactpotMainVM:OnPreviewArrow(ArrowIdx)
    if self.LastPrewviewItemVM then
        self.LastPrewviewItemVM.IsChecked = false
    end

    local Sum = 0
    --设置3个为select状态
    local CellIdxList = self.Arrow2CellList[ArrowIdx]
    for idx = 1, #CellIdxList do
        local CellVM = self.CellVMList:Get(CellIdxList[idx])
        Sum = Sum + CellVM.Number
    end

    local PreviewItemVM = self:GetPreviewItemVM(Sum)
    PreviewItemVM.IsChecked = true
    self.LastPrewviewItemVM = PreviewItemVM
end

return MiniCactpotMainVM