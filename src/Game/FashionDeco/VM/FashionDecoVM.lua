local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MajorUtil = require("Utils/MajorUtil")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local FashionDecorateCfg = require("TableCfg/FashionDecorateCfg")
local FashionDecorateSkillCfg = require("TableCfg/FashionDecorateSkillCfg")
local AnimMgr = require("Game/Anim/AnimMgr")
local AnimationUtil = require("Utils/AnimationUtil")
local ObjectGCType = require("Define/ObjectGCType")
local ActorUtil = require("Utils/ActorUtil")
local SaveKey = require("Define/SaveKey")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local USaveMgr = _G.UE.USaveMgr
local LSTR = _G.LSTR
---@class FashionDecoVM : UIViewModel
local FashionDecoVM = LuaClass(UIViewModel)

function FashionDecoVM:Ctor()
    --已解锁道具Map
  self.FashionDecorateMap = {}
    --当前装备Map
  self.CurrentClothingMap = {}
  --self.CurrentClothingMap[FashionDecoDefine.FashionDecoType.Umbrella] = nil
  --self.CurrentClothingMap[FashionDecoDefine.FashionDecoType.Umbrella] = nil
    --界面VM，其实目前在考虑做成Event减少依赖
  self.MainVM = nil
    --AutoUse类型
  self.ChooseType = FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByNone
    --玩家操作的主界面使用
  self.IsInFashionDecorateState = true
    --所有玩家当前装备Map
  self.PlayerEquipMap = {}
    --玩家播放的Action列表
  self.ActionPlayList = {}
  self.HasElemNumByType = {}
  self.PrecallMap = {}
  self.EntitySingStateRecordMap = {}
  self.ReSetTimeRecordSeconds = {}
  self.EmptySlotVMCache = {}
end

--添加全场玩家装备Map
function FashionDecoVM:AddPlayerEquipMap(InEntityID,InUmID,InWingID)
    local MajorEntityID = MajorUtil.GetMajorEntityID()

    if MajorEntityID ~= InEntityID then
        self.PlayerEquipMap[InEntityID]=
        {
            EntityID = InEntityID,
            UmID = InUmID,
            WingID = InWingID,
        }
    end
end

--获取全场玩家装备数据
function FashionDecoVM:GetPlayerEquipMapData(InEntityID)
    return self.PlayerEquipMap[InEntityID]
end

--移除全场玩家装备数据
function FashionDecoVM:RemovePlayerEquipMap(InEntityID)
    if self.PlayerEquipMap[InEntityID] ~= nil then
        self.PlayerEquipMap[InEntityID] = nil
    end

end

--通过时尚配饰ID获取类型
function FashionDecoVM:GetTypeByID(InID)
    local itemCurrentSelectedCfg = FashionDecorateCfg:FindCfgByKey(InID)
    if itemCurrentSelectedCfg ~= nil then
        return itemCurrentSelectedCfg.DecorationType
    end
    return 0
end

--播放技能
function FashionDecoVM:PlaySkillAction(InCurrentSelectedID,InID)
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local Major = MajorUtil.GetMajor()
    if Major then
        local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(MajorEntityID)
        local itemcfg = FashionDecorateSkillCfg:FindCfgByKey(InID)

        local UseAnimName = AnimMgr:GetActionTimeLinePath(itemcfg.HumanActiontimeline)
        local UseAnim = _G.ObjectMgr:LoadObjectSync(UseAnimName, ObjectGCType.LRU)
        if self.ActionPlayList[MajorEntityID] ~= nil then
            AnimationUtil.MontageStop(PlayerAnimInst, self.ActionPlayList[MajorEntityID].SavedMontage)
        end

        if Major.CharacterMovement then
            local Velocity = Major.CharacterMovement.Velocity
            if (Velocity.X ~= 0 or Velocity.Y ~= 0 or Velocity.Z ~= 0)  then
                _G.MsgTipsUtil.ShowTips(LSTR(1030015))--移动中无法释放技能
                return
            end
        end
        local SavedMontage = AnimationUtil.PlayAnyAsMontage(MajorEntityID, UseAnim, "WholeBody", nil, nil, "")

        local AnimComp = Major:GetAnimationComponent()
        if AnimComp == nil then return end

        local OtherMontage = AnimComp:PlayAnimation(AnimMgr:GetActionTimeLinePath(itemcfg.OtherActiontimeline),1.0,0.25,0.25,true,3202,true,true)
        self.ActionPlayList[MajorEntityID] ={SavedMontage = SavedMontage,OtherMontage = OtherMontage}
    end
end
--播放技能
function FashionDecoVM:PlaySingBarAnim(InID,InEntityID)

        local Animations = {
            [1] = {AnimPath = "/Game/Assets/Character/Action/normal/item_start.item_start"},
            [2] = {AnimPath = "/Game/Assets/Character/Action/normal/item_loop.item_loop"},
            [3] = {AnimPath = "/Game/Assets/Character/Action/normal/item_end.item_end"},
        }
        local QueueID = _G.AnimMgr:PlayAnimationMulti(InEntityID, Animations)

        if self.PrecallMap == nil then
            self.PrecallMap = {}
        end

        if self.EntitySingStateRecordMap == nil then
            self.EntitySingStateRecordMap = {}
        end

        if self.PrecallMap[InEntityID] == nil then
            self.PrecallMap[InEntityID] = {}
        end

        self.PrecallMap[InEntityID].QueueID = QueueID

        local function PrecallTimeout()
            self.EntitySingStateRecordMap[InEntityID] = false
            if self.PrecallMap[InEntityID] ~= nil then
                _G.AnimMgr:StopAnimationMulti(InEntityID, self.PrecallMap[InEntityID].QueueID)
            end
            local UseAnimName = AnimMgr:GetActionTimeLinePath("normal/item_end")
            local UseAnim = _G.ObjectMgr:LoadObjectSync(UseAnimName, ObjectGCType.LRU)
            AnimationUtil.PlayAnyAsMontage(InEntityID, UseAnim, "WholeBody", nil, nil, "")
            _G.EventMgr:SendEvent(_G.EventID.FashionDecorateShowThirdPersonAll,InEntityID)
        end
        local Actor = ActorUtil.GetActorByEntityID(InEntityID)
        local TimerHandle = _G.TimerMgr:AddTimer(Actor, PrecallTimeout, 3)

        self.PrecallMap[InEntityID].TimerHandle = TimerHandle
        self.EntitySingStateRecordMap[InEntityID] = true

end

function FashionDecoVM:StopSingBar(InEntityID)
    if self.PrecallMap ~= nil and  self.PrecallMap[InEntityID] ~= nil then
        if self.PrecallMap[InEntityID].QueueID ~= nil then
            _G.AnimMgr:StopAnimationMulti(InEntityID, self.PrecallMap[InEntityID].QueueID)
        end

        if self.PrecallMap[InEntityID].TimerHandle ~= nil then
            _G.TimerMgr:CancelTimer(self.PrecallMap[InEntityID].TimerHandle)
            self.PrecallMap[InEntityID].TimerHandle = nil
            _G.EventMgr:SendEvent(_G.EventID.FashionDecorateShowThirdPersonAll,InEntityID)
        end

        if self.EntitySingStateRecordMap ~= nil then
            self.EntitySingStateRecordMap[InEntityID] = false
        end
    end
end

function FashionDecoVM:IsFashionDecoSing(InEntityID)
    if self.EntitySingStateRecordMap ~= nil then
       return self.EntitySingStateRecordMap[InEntityID]
    end
    return false
end

--播放雨伞技能
function FashionDecoVM:PlayUmSkillActionByIndex(InEntityID,InFashionDecorateID,ActionID)
    local Actor = ActorUtil.GetActorByEntityID(InEntityID)
    if Actor then
        local itemCurrentSelectedCfg = FashionDecorateCfg:FindCfgByKey(InFashionDecorateID)
        if itemCurrentSelectedCfg ~= nil then
            local itemSkillcfg =FashionDecorateSkillCfg:FindCfgByKey(ActionID)
            if itemSkillcfg ~= nil then
                local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(InEntityID)
                local UseAnimName = AnimMgr:GetActionTimeLinePath(itemSkillcfg.HumanActiontimeline)
                local UseAnim = _G.ObjectMgr:LoadObjectSync(UseAnimName, ObjectGCType.LRU)
                local AnimComp =  ActorUtil.GetActorAnimationComponent(InEntityID)
                if self.ActionPlayList[InEntityID] ~= nil then
                    AnimationUtil.MontageStop(PlayerAnimInst, self.ActionPlayList[InEntityID].SavedMontage)
                    local LocalAnimInstance = AnimComp:GetPartAnimInstance(3202)
                    if LocalAnimInstance ~= nil then
                        AnimationUtil.MontageStop(LocalAnimInstance, self.ActionPlayList[InEntityID].OtherMontage)
                    end
                end
                if MajorUtil.GetMajorEntityID() == InEntityID then
                    if Actor.CharacterMovement then
                        local Velocity = Actor.CharacterMovement.Velocity
                        if (Velocity.X ~= 0 or Velocity.Y ~= 0 or Velocity.Z ~= 0)  then
                            _G.MsgTipsUtil.ShowTips(LSTR(1030015))--移动中无法释放技能
                            return
                        end
                    end
                end

                local SavedMontage = AnimationUtil.PlayAnyAsMontage(InEntityID, UseAnim, "WholeBody", nil, nil, "")

                local OtherMontage
                if AnimComp ~= nil then 
                    OtherMontage = AnimComp:PlayAnimation(AnimMgr:GetActionTimeLinePath(itemSkillcfg.OtherActiontimeline),1.0,0.25,0.25,true,3202,true,true)
                end
                self.ActionPlayList[InEntityID] ={SavedMontage = SavedMontage,OtherMontage = OtherMontage}
            end
        end

    end
end
--停止指定的角色播放表演动作
function FashionDecoVM:StopMontageByEntityID(InEntityID)
    if InEntityID ~= nil and self.ActionPlayList[InEntityID] ~= nil and self.ActionPlayList[InEntityID].SavedMontage ~= nil then
       local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(InEntityID)
       if PlayerAnimInst ~= nil and AnimationUtil.MontageIsPlaying(PlayerAnimInst, self.ActionPlayList[InEntityID].SavedMontage) then
            AnimationUtil.MontageStop(PlayerAnimInst, self.ActionPlayList[InEntityID].SavedMontage)
            local AnimComp =  ActorUtil.GetActorAnimationComponent(InEntityID)
            if AnimComp then
                local LocalAnimInstance = AnimComp:GetPartAnimInstance(3202)
                if LocalAnimInstance == nil then return end
                AnimationUtil.MontageStop(LocalAnimInstance, self.ActionPlayList[InEntityID].OtherMontage)
            end
       end
    end

end
--更新主界面绑定的状态
function FashionDecoVM:SetFashionDecorateState(InNewState)
    self.IsInFashionDecorateState = InNewState
end
function  FashionDecoVM:UpdateDryRestTime()
    local tempCurrentMS = TimeUtil.GetLocalTimeMS()
    for Key,v in pairs(self.ReSetTimeRecordSeconds) do
        if  v ~= nil then
            if (tempCurrentMS - v.LastRecordTime) > 30000 then
                local Actor = ActorUtil.GetActorByEntityID(Key)
                if Actor ~= nil  and ActorUtil.IsPlayerOrMajor(Key)   then
                    if v.bByRain then
                        Actor:SetWetByRain(false)
                    else
                        Actor:SetWetBySwim(false)
                    end
                end
                self.ReSetTimeRecordSeconds[Key] = nil
            end
        end
    end
end

function  FashionDecoVM:ReSetWetToDryRestTime(InEntityID,bByRain)
    if self.ReSetTimeRecordSeconds[InEntityID] ~= nil  then
        self.ReSetTimeRecordSeconds[InEntityID].LastRecordTime = TimeUtil.GetLocalTimeMS()
        self.ReSetTimeRecordSeconds[InEntityID].bByRain = bByRain
    else
        self.ReSetTimeRecordSeconds[InEntityID] = {LastRecordTime = TimeUtil.GetLocalTimeMS(), bByRain = bByRain}
    end
end
function  FashionDecoVM:GetLastWetTime(InEntityID)
    if self.ReSetTimeRecordSeconds[InEntityID] ~= nil  then
        return self.ReSetTimeRecordSeconds[InEntityID].LastRecordTime
    end
end
function  FashionDecoVM:ClearReSetWetToDryRestTime(InEntityID)
    self.ReSetTimeRecordSeconds[InEntityID] = nil
end
function FashionDecoVM:ClearData()
    self.FashionDecorateMap = {}
    self.CurrentClothingMap = {}
    self.MainVM = nil
    self.ChooseType = nil
    self.IsInFashionDecorateState = false
    self.PlayerEquipMap = {}
    self.ActionPlayList = {}
    self.HasElemNumByType = {}
    self.ReSetTimeRecordSeconds = {}
    self.EmptySlotVMCache = {}
end
function FashionDecoVM:OnHideMainView()
    self.EmptySlotVMCache = {}
end
--设置当前AutoUse类型
function FashionDecoVM:SetCurrentChooseType(InChooseType)
    self.ChooseType = InChooseType
    USaveMgr.SetInt(SaveKey.FashionDecoSetting, self.ChooseType, false)
end
--是否是AutoUse类型
function FashionDecoVM:IsInAutoUseType()
    if self.ChooseType == nil then
        return false
    end
    return self.ChooseType > FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByNone
end
--设置是否为新的flag
function  FashionDecoVM:SetFashionDecorateBitmapIsNew(InFashionDecorateBitmapIsNew)
self.FashionDecorateBitmapIsNew = InFashionDecorateBitmapIsNew
end
function  FashionDecoVM:OnChangeLevelClearData()
    self.MainVM = nil
    self.PlayerEquipMap = {}
    self.ActionPlayList = {}
    self.PrecallMap = {}
    self.EntitySingStateRecordMap = {}
end
--查询flag是否为True
function FashionDecoVM:IsFlagSet(Flag, FlagBit)
    if Flag == nil then
        return false
    end

    return Flag & FlagBit == FlagBit
end
--查询设置FlagBit为true
function FashionDecoVM:FlagSet(Flag, FlagBit)
    if Flag == nil then
        return false
    end
    return Flag | FlagBit
end
function FashionDecoVM:GetTypeNum(InType)
    if self.HasElemNumByType[InType]== nil then
        return 0
    end
    return self.HasElemNumByType[InType]
end
--增加新已解锁元素
function FashionDecoVM:AddNewRecordElemFashionDeco(InID,InFlag,InUpdateTime)
    self.FashionDecorateMap[InID] = {ID = InID,Flag = InFlag,UpdateTime = InUpdateTime,IsCollect = false}
    local itemCurrentSelectedCfg = FashionDecorateCfg:FindCfgByKey(InID)
    if itemCurrentSelectedCfg ~= nil then
        self.FashionDecorateMap[InID].DecorationType = itemCurrentSelectedCfg.DecorationType
        if self.HasElemNumByType[itemCurrentSelectedCfg.DecorationType] == nil then
            self.HasElemNumByType[itemCurrentSelectedCfg.DecorationType] = 1
        else
            self.HasElemNumByType[itemCurrentSelectedCfg.DecorationType] = self.HasElemNumByType[itemCurrentSelectedCfg.DecorationType]+1
        end
    end
end

--获取第一个解锁的类型
function FashionDecoVM:GetFirstUnlockedType()
    local LastType = nil
    for _,v in pairs(self.FashionDecorateMap) do
        local itemcfg = FashionDecorateCfg:FindCfgByKey(v.ID)
        if LastType == nil then
            LastType = itemcfg.DecorationType
        else
            if itemcfg.DecorationType < LastType then
                LastType = itemcfg.DecorationType
            end
        end

    end
    if LastType == nil then
        LastType = FashionDecoDefine.FashionDecoType.Umbrella
    end
    return LastType
end

--设置已读
function FashionDecoVM:SetElemRead(InID)
    if self.MainVM ~= nil then
        local Item = self.MainVM:FindItemByID(InID)
        if  Item ~= nil then
            Item.RedDot2Visible = false
        end
        --这里设置已读
        self.FashionDecorateMap[InID].Flag = 0
    end
end
--增加新已收藏元素
function FashionDecoVM:AddCollectNew(InID)

    if self.FashionDecorateMap[InID]~= nil then
        self.FashionDecorateMap[InID].IsCollect = true
    end

end

--更新存储数据中的当前装备，每个类型一种
function FashionDecoVM:UpdateCurrentEquip(InCurrentID)
    local itemCurrentSelectedCfg = FashionDecorateCfg:FindCfgByKey(InCurrentID)
    if itemCurrentSelectedCfg ~= nil and self.CurrentClothingMap ~= nil and itemCurrentSelectedCfg.DecorationType ~= nil then
        self.CurrentClothingMap[itemCurrentSelectedCfg.DecorationType] = InCurrentID
    end

end

--删除当前装备
function FashionDecoVM:DeleteCurrentEquip(InCurrentType)
    self.CurrentClothingMap[InCurrentType] = nil
end

function FashionDecoVM:GetCurrentEquip(InCurrentType)
    if self.CurrentClothingMap == nil then
        return nil
    end
    return self.CurrentClothingMap[InCurrentType]
end

function FashionDecoVM:GetCurrentChooseType()
    return self.ChooseType
end

--更新收藏状态
function FashionDecoVM:UpdateCollectState(InID,InCurrentCollect)
    if self.FashionDecorateMap[InID] ~= nil then
        self.FashionDecorateMap[InID].IsCollect = InCurrentCollect
        --更新主界面当前收藏按钮
        if self.MainVM.CurrentSelectedID == InID then
            self.MainVM.CurrentSelectedIsCollect = InCurrentCollect
        end
        --更新主界面元素的选中元素右上角图标
        local TargetItem = self.MainVM:FindItemByID(InID)

        if TargetItem ~= nil then
            TargetItem.IconCollectVisible = InCurrentCollect
        end
    end
end

--初始化当前装备列表
function FashionDecoVM:InitCurrentClothingMap(InCurrentMap)
    self.CurrentClothingMap = InCurrentMap
end

--设置主面板VM
function FashionDecoVM:SetMainVM(InCurrentMainVM)
    self.MainVM = InCurrentMainVM
end
--设置穿戴按钮文字
function FashionDecoVM:SetMainVMWeatBtn(InID,InNewText,bIfLight)
    if self.MainVM ~= nil   then
        if InID == self.MainVM.CurrentSelectedID then
            self.MainVM.BtnWearName = InNewText
            self.MainVM.CurrentWearBtnState = bIfLight
            self.MainVM.CurrentSelectedEquip = not bIfLight
        else
            self.MainVM.BtnWearName = LSTR(1030010)--穿戴
            self.MainVM.CurrentWearBtnState = true
        end

    end
end


--更新已装备状态
function FashionDecoVM:UpdateItemClothingState(InID,InNewState)
    if self.MainVM ~= nil then
        local Item = self.MainVM:FindItemByID(InID)
        if  Item ~= nil then
            Item.Equip = InNewState
        end
    end

end
--穿上衣服
function FashionDecoVM:IfHaveDressedEquipment()
    if self.CurrentClothingMap ~= nil then
        for Key,v in pairs(self.CurrentClothingMap) do
            if  v ~= nil and v~= 0 then
                return true
            end
        end
    end
    return false

end
--穿上衣服
function FashionDecoVM:DressUpAllOrnament()
    local MajorActor = MajorUtil.GetMajor()
    if self.CurrentClothingMap ~= nil then
        for Key,v in pairs(self.CurrentClothingMap) do
            if MajorActor ~= nil and v ~= nil and v >0 then
                --_G.FLOG_INFO("ccppeng: Dressup Success")
                MajorActor:SetOrnamentCompData(Key,v)
            end
        end
    end

end

--获取技能按钮VM列表(此处专指时尚配饰界面)
function FashionDecoVM:GetActionListDataByID(InCurrentSelectedID,InVMType)
    local List = {}
    local itemCurrentSelectedCfg = FashionDecorateCfg:FindCfgByKey(InCurrentSelectedID)

    if itemCurrentSelectedCfg.DecorationType == FashionDecoDefine.FashionDecoType.Wing then
        return List
    end

    for _,v in pairs(itemCurrentSelectedCfg.Action) do
        if v ~= nil and v ~= 0 then
            local itemcfg =FashionDecorateSkillCfg:FindCfgByKey(v)
            local ItemVM = InVMType.New()
            ItemVM.ID = itemcfg.ID
            ItemVM.cd = itemcfg.cd
            ItemVM.Icon = itemcfg.Icon
            ItemVM.HumanActionTimelinePath = itemcfg.HumanActiontimeline
            ItemVM.OtherActionTimelinePath = itemcfg.OtherActiontimeline
            List[#List + 1] = ItemVM
        end

    end

    local ItemVM = InVMType.New()
    ItemVM.ChangeState = true
    ItemVM.Icon = "Texture2D'/Game/Assets/Icon/ItemIcon/008000/UI_Icon_008101.UI_Icon_008101'";
    List[#List + 1] = ItemVM

    return List
end
function FashionDecoVM:GetAllReadStatus()
    local TypeList = {}
    for _,v in pairs(FashionDecoDefine.FashionDecoType) do
        TypeList[v] = false
    end
    for _,v in pairs(self.FashionDecorateMap) do
        if self:IsFlagSet(v.Flag, self.FashionDecorateBitmapIsNew) then
            TypeList[v.DecorationType] = true
        end
    end
    return TypeList
end
function FashionDecoVM:IsNewToRead(InID)
    if self.FashionDecorateMap[InID] == nil then
        return false
    end

    return self:IsFlagSet(self.FashionDecorateMap[InID].Flag, self.FashionDecorateBitmapIsNew)
end

--获取UI元素
function FashionDecoVM:GetListDataByType(InType,InVMType)
    local List = {}
    if self.CurrentClothingMap == nil then
        self.CurrentClothingMap = {}
        self.CurrentClothingMap[InType] = nil;
    end
    --处理当前装备
    if self.CurrentClothingMap ~= nil and self.CurrentClothingMap[InType] ~= nil then
        local itemcfg = FashionDecorateCfg:FindCfgByKey(self.CurrentClothingMap[InType])
        if itemcfg.DecorationType == InType then
            --_G.FLOG_INFO("ccppeng: Current Equip equip  = %d", self.CurrentClothingMap[InType])
            local ItemVM = InVMType.New()
            ItemVM.Title = string.format(_G.LSTR("%s"), itemcfg.Name)
            ItemVM.New = false
            ItemVM.IsSelect = false
            ItemVM.Icon = itemcfg.Icon;
            ItemVM.Equip = true
            ItemVM.ID = self.CurrentClothingMap[InType]
            ItemVM.ItemLevelVisible = false
            ItemVM.NumVisible = false

            if self.FashionDecorateMap[self.CurrentClothingMap[InType]].Flag ~= nil and self:IsFlagSet(self.FashionDecorateMap[self.CurrentClothingMap[InType]].Flag, self.FashionDecorateBitmapIsNew) ~= false then
                ItemVM.RedDot2Visible = true
            else
                ItemVM.RedDot2Visible = false
            end
            if self.FashionDecorateMap[self.CurrentClothingMap[InType]].IsCollect ~= false then
                ItemVM.IconCollectVisible = true
            else
                ItemVM.IconCollectVisible = false
            end
            List[#List + 1] = ItemVM

        end
    end

    --处理所有的收藏
    for _,v in pairs(self.FashionDecorateMap) do
        if self.CurrentClothingMap ~= nil and self.CurrentClothingMap[InType] ~= v.ID and v.IsCollect  then
            local itemcfg = FashionDecorateCfg:FindCfgByKey(v.ID)
            if itemcfg.DecorationType == InType then
                --_G.FLOG_INFO("ccppeng: Other UnEquip Elem is  = %d", v.ID)
                local ItemVM = InVMType.New()
                ItemVM.Title = string.format(_G.LSTR("%s"), itemcfg.Name)
                ItemVM.New = false
                ItemVM.IsSelect = false
                ItemVM.Icon = itemcfg.Icon;
                ItemVM.Equip = false
                ItemVM.ID = v.ID
                ItemVM.ItemLevelVisible = false
                ItemVM.NumVisible = false

                if v.Flag ~= nil and self:IsFlagSet(v.Flag, self.FashionDecorateBitmapIsNew) ~= false  then
                    ItemVM.RedDot2Visible = true
                else
                    ItemVM.RedDot2Visible = false
                end

                ItemVM.IconCollectVisible = true

                List[#List + 1] = ItemVM

            end
        end
    end

    --处理非收藏
    for _,v in pairs(self.FashionDecorateMap) do
        if self.CurrentClothingMap ~= nil and  self.CurrentClothingMap[InType] ~= v.ID and not v.IsCollect  then
            local itemcfg = FashionDecorateCfg:FindCfgByKey(v.ID)
            if itemcfg.DecorationType == InType then
                --_G.FLOG_INFO("ccppeng: Other UnEquip Elem is  = %d", v.ID)
                local ItemVM = InVMType.New()
                ItemVM.Title = string.format(_G.LSTR("%s"), itemcfg.Name)
                ItemVM.New = false
                ItemVM.IsSelect = false
                ItemVM.Icon = itemcfg.Icon;
                ItemVM.Equip = false
                ItemVM.ID = v.ID
                ItemVM.ItemLevelVisible = false
                ItemVM.NumVisible = false

                if self.FashionDecorateMap[v.ID].Flag ~= nil and self:IsFlagSet(self.FashionDecorateMap[v.ID].Flag, self.FashionDecorateBitmapIsNew) ~= false  then
                    ItemVM.RedDot2Visible = true
                else
                    ItemVM.RedDot2Visible = false
                end

                ItemVM.IconCollectVisible = false

                List[#List + 1] = ItemVM

            end
        end
    end
    local EmptyNum = 16
    if self.GLOBAL_CFG_FASHIONDECO_MAXEMPTYITEMS == nil then
        local Cfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_FASHIONDECO_MAXEMPTYITEMS)
        if (Cfg ~= nil) then
            self.GLOBAL_CFG_FASHIONDECO_MAXEMPTYITEMS = Cfg.Value[1]
        end
    end
    if self.GLOBAL_CFG_FASHIONDECO_MAXEMPTYITEMS ~= nil  then
        EmptyNum = self.GLOBAL_CFG_FASHIONDECO_MAXEMPTYITEMS
    end
    if self.EmptySlotVMCache ~= nil and #self.EmptySlotVMCache < EmptyNum then
        for i = (EmptyNum-#self.EmptySlotVMCache), 1, -1 do
            local ItemVM = InVMType.New()
            ItemVM.Title = "Empty"--不会显示
            ItemVM.New = false
            ItemVM.IsSelect = false
            ItemVM.Icon = "";
            ItemVM.Equip = false
            ItemVM.ItemLevelVisible = false
            ItemVM.NumVisible = false
            ItemVM.RedDot2Visible = false
            ItemVM.IconCollectVisible = false
            self.EmptySlotVMCache[#self.EmptySlotVMCache + 1] = ItemVM
        end
    end
    self:AddEmptySlot(InVMType,List,EmptyNum-#List)


    return List
end

--增加空格子
function FashionDecoVM:AddEmptySlot(InVMType,List,Num)

    for i = Num, 1, -1 do
        List[#List + 1] = self.EmptySlotVMCache[i]
    end

end
function FashionDecoVM:OnInit()

end

function FashionDecoVM:OnBegin()

end

function FashionDecoVM:OnEnd()

end

function FashionDecoVM:CheckHasCollect()

    for _,v in pairs(self.FashionDecorateMap) do
        if  v.IsCollect  then
            local itemcfg = FashionDecorateCfg:FindCfgByKey(v.ID)
            if itemcfg.DecorationType == FashionDecoDefine.FashionDecoType.Umbrella then
                return true;
            end
        end
    end

    return false
end
function FashionDecoVM:GetCollectNum()
    local CurrentCollectNum = 0
    for _,v in pairs(self.FashionDecorateMap) do
        if  v.IsCollect  then
            CurrentCollectNum = CurrentCollectNum + 1
        end
    end

    return CurrentCollectNum
end
function FashionDecoVM:IsItemUnlocked(InID)

    if InID ~= nil and self.FashionDecorateMap[InID] ~= nil and InID > 0 then
        return true
    end

    return false
end
function FashionDecoVM:OnShutdown()
    self.FashionDecorateMap = {}
    self.CurrentClothingMap = nil
    self.MainVM = nil
end


return FashionDecoVM