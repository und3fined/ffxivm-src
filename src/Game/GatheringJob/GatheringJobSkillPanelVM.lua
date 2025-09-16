--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2023-12-08 11:24
FilePath: \Client\Source\Script\Game\GatheringJob\GatheringJobSkillPanelVM
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local GatherPointCfg = require("Tablecfg/GatherPointcfg")
local ItemCfg = require("TableCfg/ItemCfg")
local CollectInfoCfg = require("TableCfg/CollectInfoCfg")
local UIViewID = require("Define/UIViewID")
local ActorUtil = require("Utils/ActorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ItemUtil = require("Utils/ItemUtil")
local CommonUtil = require("Utils/CommonUtil")
local FLinearColor = _G.UE.FLinearColor

---@class GatheringJobSkillPanelVM : UIViewModel
local GatheringJobSkillPanelVM = LuaClass(UIViewModel)

function GatheringJobSkillPanelVM:Ctor()
    --头顶相关
    self.GatherPointName = ""
    self.GatherLevel = ""
    self.LeftTimesInfo = ""
    self.GatherHPBarPercent = 0

    --GatherCollection界面头顶Item
    self.QualityIcon = ""
    self.GatherName = ""
    self.GatherIcon = ""

    --刷新RadialImg
    self.RadialPercentGreen = 0 --当前值的绿圈
    self.CollectionValueMax = 500 --环中间最大值，读db
    self.CurrentVal = 0
    self.CollectionVal = 0 ----环中间显示的收藏价值（长按显示预测值，否则显示当前值）
    self.CollectionValColor = FLinearColor.FromHex("89BD88FF")
    self.CollectionRedVal = 0
    self.CollectionRedValColor = FLinearColor.FromHex("D1906DFF")
    self.CollectionRedValVisible = false


    --技能信息相关
    self.SkillIcon = ""
    self.SkillName = ""
    self.SkillTypeStr = ""
    self.SkillDesc = ""

    --3个提纯技能按钮上显示的数值
    self.ScourSkill = 0
    self.BrazenSkill = 0
    self.MetiSkill = 0
    self.ValueUpRate = 0 --价值提升
    self.FreeMetiProb = 0 --沉稳

    self.bCollectorStandard = false --洞察是否触发
    self.bArrow1 = false
    self.bArrow2 = false
    self.bCanCollect = false
    self.bCanScour = true
    self.Scrutiny = false
    self.LastLeftTimes = -1
end

--公有，初始化模块自身数据，其他同级模块在其OnInit之后可以访问到
function GatheringJobSkillPanelVM:OnInit()
    --k:index  v:skillid
    self.SkillGroup = {
        --采矿工
        [ProtoCommon.prof_type.PROF_TYPE_MINER] = {
            [5] = 30107, --提纯
            [4] = 30108, --大胆提纯
            [3] = 30109, --谨慎提纯
            [2] = 30110, --集中检查
            [1] = 30105, --高产
            [0] = 30111, --收藏品采集
            --被动技能
            [6] = 100001, --洞察
            [7] = 100002 --沉稳,
        },
        --园艺工
        [ProtoCommon.prof_type.PROF_TYPE_BOTANIST] = {
            [5] = 30207, --提纯
            [4] = 30208, --大胆提纯
            [3] = 30209, --谨慎提纯
            [2] = 30210, --集中检查
            [1] = 30205, --高产
            [0] = 30211, --收藏品采集
            --被动技能
            [6] = 100001, --洞察
            [7] = 100002 --沉稳,
        }
    }

    self.BuffCheck = 27 --集中检查BuffID
    self.BuffPenetrate = 29 --洞察BuffID


    self.QualityIconMap = {
        [ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_01.UI_Quality_Slot_NQ_01'",
        [ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_02.UI_Quality_Slot_NQ_02'",
        [ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_03.UI_Quality_Slot_NQ_03'",
        [ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_04.UI_Quality_Slot_NQ_04'"
    }

    self.BtnValueFormateStr1 =
        '<span color="#D1BA8E" outline="2;#00000099" size="19">%d~</><span color="#fc8b7c" outline="2;#00000099" size="19">%d</>'
    self.BtnValueFormateStr2 = '<span color="#D1BA8E" outline="2;#00000099" size="19">%d</>'
end

--私有，每一次打开界面都重新赋值，可引用其他同级模块中OnInit（公开）中的数据
function GatheringJobSkillPanelVM:OnBegin()
end

function GatheringJobSkillPanelVM:OnEnd()
    self:OnExitCollection()
end

function GatheringJobSkillPanelVM:OnShutdown()
end

function GatheringJobSkillPanelVM:GetSkillIndex(ProfID, SkillID)
    for index, value in ipairs(self.SkillGroup[ProfID]) do
        if value == SkillID then
            return index
        end
    end
end

--进入收藏品采集状态，初始化网络数据=============================================================================================1**
function GatheringJobSkillPanelVM:EnterCollection(CollectionRsp)
    self.CollectionRsp = CollectionRsp
    self.LastLeftTimes = self.CollectionRsp.LeftTimes
    --Get采集产出物ID——采集笔记配置**——收藏品模板ID————收藏品最大价值**
    --采集点的数据记录在GatherMgr，采集产出物的数据记录在CollectionMgr
    self.GatherResID = _G.CollectionMgr:GetGatherItem().ResID
    if not self.GatherResID then
        FLOG_ERROR("Gather EnterCollection Collection Gather Item error")
        return
    end

    local CollectionCfg = CollectInfoCfg:FindCfgByKey(self.GatherResID)
    if CollectionCfg then
        local CollectValue = CollectionCfg.CollectValue
        self.CollectionValueMax = CollectValue[3]
    else
        self.CollectionValueMax = 0
        FLOG_ERROR("GatheringJobSkillPanelVM:EnterCollection CollectionCfg is nil")
    end

    --初始化界面数据
    self:InitPanel(CollectionRsp)
end

--离开收藏品采集状态
function GatheringJobSkillPanelVM:OnExitCollection()
    self.CollectionRsp = nil
    self.CurActiveGatherNoteCfg = nil
    self.CurCollectionTemplateCfg = nil
    self.AttributeComponent = nil
    self.CollectionValueMax = nil
    self.GatherItemID = nil
    self.GatherPointItemCfg = nil
    self.GatherResID = nil
    self.CurrentVal = 0
end

--界面初始化===================================================================================================================2**
function GatheringJobSkillPanelVM:InitPanel(CollectionRsp)
    FLOG_INFO("Init GatheringJobSkillPanel")
    self.CollectionRsp = CollectionRsp

    --收藏面板
    self.RadialPercentGreen = 0
    local ItemCfg = ItemCfg:FindCfgByKey(_G.CollectionMgr:GetGatherItem().ResID)
    if nil == ItemCfg then
        FLOG_ERROR("GatheringJobSkillPanelVM:InitPanel：GatherItemCfg is nil")
        return
    end
    --标题：
    self.GatherIcon = _G.UIUtil.GetIconPath(ItemCfg.IconID)
    local GatherColor = nil ~= ItemCfg.ItemColor and ItemCfg.ItemColor or ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_NONE
    self.QualityIcon = self.QualityIconMap[GatherColor]
    self.GatherName = CommonUtil.GetTextFromStringWithSpecialCharacter(ItemCfg.ItemName)
    self:OnRefreshCollectionPanel()

    --耐久条
    self.GatherItemID = ActorUtil.GetActorResID(_G.GatherMgr.CurActiveEntityID) --采集点ID
    self.GatherPointItemCfg = GatherPointCfg:FindCfgByKey(self.GatherItemID)
    self.GatherPointName = self.GatherPointItemCfg.Name
    local TotalCount = _G.GatherMgr:GetMaxGatherCount(self.GatherItemID, _G.GatherMgr.CurGatherListID)
    self.TotalCount = TotalCount

    self:OnRreshSkillGroup()
    _G.EventMgr:SendEvent(_G.EventID.OnCastSkillUpdateMask, false)
end

--刷新收藏面板中间的环&值(是初始化，或技能回包后，或长按松了后 直接赋值)
function GatheringJobSkillPanelVM:OnRefreshCollectionPanel()
    self.CurrentVal = self.CollectionRsp.CurrentVal
    --换中间的收藏价值（不是长按,显示当前值）
    self.CollectionVal = self.CurrentVal
    --只显示绿环
    self:DoMove("G", self.RadialPercentGreen, self.CollectionRsp.CurrentVal / self.CollectionValueMax)
    self:DoMove("Y", 0, 0)
    self:DoMove("R", 0, 0)
    --红色的值也不显示
    self.CollectionRedValVisible = false
    --当前值设置成绿色
    self.CollectionValColor = FLinearColor.FromHex("89BD88FF")
end

--刷新上方的耐久条
function GatheringJobSkillPanelVM:OnRefreshProBar(PickCountLeft)
    --Get采集物及属性组件
    local Actor = ActorUtil.GetActorByEntityID(_G.GatherMgr.CurActiveEntityID)
    if nil == Actor then
        FLOG_ERROR("Gather OnRefreshProBar Actor is nil")
        return
    end
    self.AttributeComponent = Actor:GetAttributeComponent()
    if nil == self.AttributeComponent then
        FLOG_ERROR("Gather EnterCollection AttributeComponent is nil")
        return
    end
    
    self.LeftTimes = PickCountLeft or self.CollectionRsp.LeftTimes
    self.AttributeComponent.PickTimesLeft = self.LeftTimes
    self.LeftTimesInfo = self.LeftTimes .. "/" .. self.TotalCount
    self.GatherHPBarPercent = self.LeftTimes / self.TotalCount

    --同步给属性组件
    _G.GatherMgr:OnGatherAttrChange(_G.GatherMgr.CurActiveEntityID, self.CollectionRsp.LeftTimes, true)
end

function GatheringJobSkillPanelVM:SetAttackBtnMask(bShowMask)
    if bShowMask then
        self.bCanCollect = false
    else
        if self.CollectionRsp ~= nil and self.CollectionRsp.CurrentVal <= 0 then
            self.bCanCollect = false
        else
            self.bCanCollect = true
        end
    end
end

--刷新技能组的数值显示
function GatheringJobSkillPanelVM:OnRreshSkillGroup()
    self.bCanScour = self.CollectionRsp.CurrentVal < self.CollectionValueMax

    --3个提纯技能按钮上显示的数值
    self.ScourSkill = string.format(self.BtnValueFormateStr2, self.CollectionRsp.ScourVal)
    self.BrazenSkill =
        string.format(self.BtnValueFormateStr1, self.CollectionRsp.BrazenMinval, self.CollectionRsp.BrazenMaxval)
    self.MetiSkill = string.format(self.BtnValueFormateStr2, self.CollectionRsp.MetiVal)

    --价值提升和沉稳的下方显示的概率
    self.ValueUpRate = math.floor(self.CollectionRsp.ValueUpRate / 100) .. "%"
    self.FreeMetiProb = math.floor(self.CollectionRsp.FreeMetiProb / 100) .. "%"

    --价值提升触发
    if self.CollectionRsp.ValueUp then
        MsgTipsUtil.ShowTipsByID(MsgTipsID.PriceUp)
    end

    self.bCollectorStandard = self.CollectionRsp.CollectorStandard
    self.Scrutiny = self.CollectionRsp.Scrutiny
    --洞察或集中检查，控制使箭头显示
    self.bArrow1 = self.Scrutiny or self.bCollectorStandard
    self.bArrow2 = self.Scrutiny
    if self.CollectionRsp.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_SCOUR and self.Scrutiny then
        MsgTipsUtil.ShowTipsByID(MsgTipsID.Check)
    end

    --洞察触发(假如是集中检查回来的包，集中检查肯定为true，提纯回的包，集中检查肯定为false，而洞察只有在提纯之后有概率触发，集中检查回来的包中洞察为true就是已经提示过的了)
    if
        self.CollectionRsp.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_SCOUR and self.bCollectorStandard and
            not self.Scrutiny
     then
        MsgTipsUtil.ShowTipsByID(MsgTipsID.Collector)
    end

    --判断沉稳，减少耐久
    if self.CollectionRsp.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_SCOUR and self.CollectionRsp.FreeMeti then
        MsgTipsUtil.ShowTipsByID(MsgTipsID.FreeMeti)
    else
        self:OnRefreshProBar()
    end
end

--技能回包（提纯，集中检查）==================================================================================================3**
function GatheringJobSkillPanelVM:OnCollectionScourSkill(CollectionRsp)
    if nil == CollectionRsp then
        return
    end
    if self.CollectionRsp and self.CollectionRsp.CurrentVal < self.CollectionValueMax and CollectionRsp.CurrentVal >= self.CollectionValueMax then
        MsgTipsUtil.ShowTipsByID(MsgTipsID.CollectionMax)
    end

    if self.LastLeftTimes and self.LastLeftTimes > CollectionRsp.LeftTimes then
        self:OnDurationChange(CollectionRsp.LeftTimes)
    end

    --保存上一次的耐久
    self.LastLeftTimes = self.CollectionRsp and self.CollectionRsp.LeftTimes
    self.CollectionRsp = CollectionRsp

    --增加收藏价值
    self:OnRefreshCollectionPanel()

    --刷新技能组的数值显示
    self:OnRreshSkillGroup()

    --如果耐久没了并且还没退出采集状态的话，发送退出收藏状态，并发送退出采集状态
    if CollectionRsp.LeftTimes <= 0 then
        if _G.GatherMgr.IsGathering == true then
            if _G.CollectionMgr.SkillIndex ~= -1 then
                FLOG_INFO("GatheringJobSkillPanelVM:CollectionRsp.LeftTimes <= 0")
                MsgTipsUtil.ShowTipsByID(MsgTipsID.NoLeftCount)
            end
            _G.CollectionMgr:DelayExitCollectionStateReq()
        else
            _G.CollectionMgr.IsCollectionState = false
            _G.GatherMgr:DelayHidePanel()
            FLOG_INFO("GatheringJobSkillPanelVM:OnCollectionScourSkill GatherMgr:DelayHidePanel")
        end
    end
end

function GatheringJobSkillPanelVM:OnDurationChange(Duration)
    local TotalCount = _G.GatherMgr:GetMaxGatherCount(self.GatherItemID, _G.GatherMgr.CurGatherListID)
    if TotalCount <= Duration then
        self.bHighYield = false
        return
    end
    self.bHighYield = true
end

--长按主动技能显示：文本+环 动态显示预测值~最大值，+显示技能tip
function GatheringJobSkillPanelVM:LongClickedScour(index)
    --如果是提纯，动效显示预测值~最大值
    local RadialYellowVal = self.CurrentVal
    local RadialRedVal = self.CurrentVal
    if index == 5 then
        RadialYellowVal = RadialYellowVal + self.CollectionRsp.ScourVal
    elseif index == 4 then
        RadialYellowVal = RadialYellowVal + self.CollectionRsp.BrazenMinval
        RadialRedVal = RadialRedVal + self.CollectionRsp.BrazenMaxval
    elseif index == 3 then
        RadialYellowVal = RadialYellowVal + self.CollectionRsp.MetiVal
    end
    RadialYellowVal = math.min(RadialYellowVal, self.CollectionValueMax)
    RadialRedVal = math.min(RadialRedVal, self.CollectionValueMax)

    --绿环（不变化）
    --self:DoMove("G", self.RadialPercentGreen, self.CurrentVal / self.CollectionValueMax)
    --黄环
    self:DoMove("Y", 0, RadialYellowVal / self.CollectionValueMax)
    --把当前值设置成黄色并显示值（三个提纯都显示此值，提纯-提纯；大胆提纯-黄色最小值；慎重提纯-黄色慎重值），松开时设置为绿色
    self.CollectionValColor = FLinearColor.FromHex("D1BA8EFF")
    self.CollectionVal = RadialYellowVal
    if index == 4 then
        self:DoMove("R", 0, RadialRedVal / self.CollectionValueMax)
        --红色值显示，设置颜色，并赋值
        self.CollectionRedValVisible = true
        self.CollectionRedValColor = FLinearColor.FromHex("D1906DFF")
        self.CollectionRedVal = RadialRedVal
    else
        --否则红环不显示，红色的值也不显示
        self.CollectionRedValVisible = false
    end
end

function GatheringJobSkillPanelVM:DoMove(BarType, Value, TargetPercent)
    local Params = {Type = BarType, Start = Value, Target = TargetPercent}
    _G.EventMgr:SendEvent(_G.EventID.GatheringCollectionProBarDoMove, Params)
    if BarType == "G" then
        self.RadialPercentGreen = TargetPercent
    end
end

return GatheringJobSkillPanelVM
