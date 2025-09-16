
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local GatheringJobMaterialItemVM = require("Game/GatheringJob/GatheringJobMaterialItemVM")

local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

local LSTR = _G.LSTR
local EToggleButtonState = _G.UE.EToggleButtonState

local SimpleTypeTitle = LSTR(160066) --"简易采集"

---@class GatheringJobPanelVM : UIViewModel

local GatheringJobPanelVM = LuaClass(UIViewModel)

function GatheringJobPanelVM:Ctor()
    self.ItemVMList = UIBindableList.New(GatheringJobMaterialItemVM)
    self.SetTextTitle = LSTR(160047) --160047"挖掘"
    self.bGatherItemList = true
    self.bSimpleGatherPanel = false
    self.bSimpleGatherStatus = false
    self.CheckState = EToggleButtonState.UnChecked
    self.BreakBtnEnable = true
    -- self.bIconMining = false
    -- self.bIconGardener = false

    self.SimpleGatherItemVM = GatheringJobMaterialItemVM.New()
    self.SimpleGatherItemVM:OnInit()
end

function GatheringJobPanelVM:OnInit()
    self.GatherNoteItemList = {}

    -- --这2个绑定的数据，不检查是否有变化，必然OnValueChange
    -- local BindProperty = self:FindBindableProperty("GatherNoteItemList")
    -- if BindProperty then
    --     BindProperty:SetNoCheckValueChange(true)
    -- end
end

function GatheringJobPanelVM:OnBegin()
end

function GatheringJobPanelVM:OnEnd()
end

function GatheringJobPanelVM:OnShutdown()
    self.ItemVMList:Clear()
end

function GatheringJobPanelVM:OnShow(FunctionList)
    self.bGatherItemList = true
    self.bSimpleGatherPanel = false
    self.bSimpleGatherStatus = false
    -- self.CheckState = EToggleButtonState.UnChecked

    -- if MajorUtil.GetMajorProfID() == ProtoCommon.prof_type.PROF_TYPE_MINER then
    --     self.bIconMining = true
    --     self.bIconGardener = false
    -- else
    --     self.bIconMining = false
    --     self.bIconGardener = true
    -- end

    self:SetFunctionItems(FunctionList, true)

    self.SimpleGatherItemVM.BeginSimpleGather = false
    self.SimpleGatherItemVM.EndSimpleGather = false

    self:RefreshTitle()
end

function GatheringJobPanelVM:SetCheckState(bChecked)
    if bChecked then    --简易采集
        self.CheckState = EToggleButtonState.Checked
    else
        self.CheckState = EToggleButtonState.UnChecked
    end
    self:RefreshTitle()
end

function GatheringJobPanelVM:BeginSimpleGather()
    FLOG_INFO("===== BeginSimpleGather ======")
    self:RefreshGatherJobPanel()
    self.SimpleGatherItemVM.BeginSimpleGather = true
    self.SimpleGatherItemVM.EndSimpleGather = false

    self.BreakBtnEnable = true
end

function GatheringJobPanelVM:EndSimpleGather()
    FLOG_INFO("===== EndSimpleGather ======")
    self.SimpleGatherItemVM.BeginSimpleGather = false
    self.SimpleGatherItemVM.EndSimpleGather = true
end

--中断简易采集
function GatheringJobPanelVM:BreakSimpleGather()
    FLOG_INFO("===== BreakSimpleGather ======")
    self.SimpleGatherItemVM.BeginSimpleGather = false
    self.SimpleGatherItemVM.EndSimpleGather = false
    self.SimpleGatherItemVM.BreakSimpleGather = true

    self.BreakBtnEnable = false
end

function GatheringJobPanelVM:OnSkillRsp()
    FLOG_INFO("===== Gather OnSkillRsp ======")
    self.SimpleGatherItemVM.bSkillRsp = true
end

function GatheringJobPanelVM:ResetUIMode()
    self.bGatherItemList = true
    self.bSimpleGatherPanel = false
end

function GatheringJobPanelVM:RefreshGatherJobPanel()
    local GatheringPanel = _G.UIViewMgr:FindView(_G.UIViewID.GatheringJobPanel)
    if not GatheringPanel then
        return
    end

    if self.CheckState == EToggleButtonState.Checked then
        GatheringPanel:ShowGatherUIMode(2)
        -- self.bGatherItemList = false
        -- self.bSimpleGatherPanel = true
    else
        GatheringPanel:ShowGatherUIMode(1)
        -- self.bGatherItemList = true
        -- self.bSimpleGatherPanel = false
    end
end

function GatheringJobPanelVM:ExitSimpleGatherPanel()
    --不是移动所致的简易采集退出，点击中断采集的按钮中断的简易采集退出 才切换ui
    if not _G.GatherMgr:GetIsMoveExit() then
        local GatheringPanel = _G.UIViewMgr:FindView(_G.UIViewID.GatheringJobPanel)
        if GatheringPanel then
            GatheringPanel:ShowGatherUIMode(1)
        end

        -- self.bGatherItemList = true
        -- self.bSimpleGatherPanel = false
    end

    _G.GatherMgr:OnSimpleGatherStateChange(false)
end

function GatheringJobPanelVM:GetFunctionItems()
    return self.ItemVMList:GetItems()
end

function GatheringJobPanelVM:SetFunctionItems(FunctionList, bShow)
    if FunctionList then
        local ItemVMCnt = self.ItemVMList:Length()
        if bShow or #FunctionList ~= self.ItemVMList:Length() then
            self.ItemVMList:UpdateByValues(FunctionList)
        else
            for i = 1, ItemVMCnt do
                local FunctionItem = FunctionList[i]
                local bFind = false
                for j = 1, ItemVMCnt do
                    local ItemVM = self.ItemVMList:Get(j)
                    if ItemVM and FunctionItem.ResID == ItemVM.FunctionItem.ResID then
                        bFind = true
                        ItemVM:UpdateVM(FunctionItem)
                    end
                end

                if not bFind then
                    self.ItemVMList:UpdateByValues(FunctionList)
                    break
                end
            end
        end
        self.GatherNoteItemList = FunctionList
        FLOG_INFO("Gather SetFunctionItems Num:%d", #FunctionList)
    end
end

function GatheringJobPanelVM:GetCondValue(AttrID)
	local Value = _G.UE.UMajorUtil.GetAttrValue(AttrID)
	-- if AttrID == ProtoRes.CONDITION_TYPE.CONDITION_TYPE_GATHER_POWER
    --     or AttrID == ProtoRes.CONDITION_TYPE.CONDITION_TYPE_OBTAIN_POWER
    --     or AttrID == ProtoRes.CONDITION_TYPE.CONDITION_TYPE_IDENTIFY_POWER then
    --     Value = _G.UE.UMajorUtil.GetAttrValue(AttrID)
    -- else
    --     --特殊类型，比如不是属性的，在这里获取
    --     Value = _G.UE.UMajorUtil.GetAttrValue(AttrID)
	-- end

	return Value
end

function GatheringJobPanelVM:GetBonusPointStr(BonusType, BonusPoint)
    local Str = nil
    if BonusType == ProtoRes.EFFECT_TYPE.EFFECT_TYPE_OBTAIN_GATE
        or BonusType == ProtoRes.EFFECT_TYPE.EFFECT_TYPE_EXTERN_DROP then
        Str = string.format("+%d%%", math.floor(BonusPoint / 100))
    else
        Str = string.format("+%d",BonusPoint)
    end

    return Str
end

function GatheringJobPanelVM:RefreshTitle()
    if not _G.GatherMgr.CurGatherEntranceItem then
        return
    end
    local SimpleStr
    if self.CheckState == EToggleButtonState.Checked then
        SimpleStr = SimpleTypeTitle
    end
    self.SetTextTitle = SimpleStr or _G.GatherMgr:GetCurGatherPointTypeName()
end

return GatheringJobPanelVM