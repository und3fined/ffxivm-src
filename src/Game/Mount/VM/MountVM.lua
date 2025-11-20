local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SaveKey = require("Define/SaveKey")
local MajorUtil = require("Utils/MajorUtil")
local USaveMgr = _G.UE.USaveMgr
local MountUtil = require("Game/Mount/MountUtil")
local RideCfg = require("TableCfg/RideCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local prof_type = ProtoCommon.prof_type
local ProtoCS = require("Protocol/ProtoCS")

local BtnRideIcon = {
	"PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Mount_Btn_Lately_png.UI_Skill_Mount_Btn_Lately_png'",
	"PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Mount_Btn_All_png.UI_Skill_Mount_Btn_All_png'",
	"PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Mount_Btn_Collect_png.UI_Skill_Mount_Btn_Collect_png'",
}

local BtnCancelCallIcon = "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Mount_Btn_Lift_png.UI_Skill_Mount_Btn_Lift_png'"
local BtnCancelFallingIcon = "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Mount_Btn_Cancel_png.UI_Skill_Mount_Btn_Cancel_png'"

local AllIconBookPath = {
	[prof_type.PROF_TYPE_MINER] = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900157.UI_Icon_900157'",	-- 采矿工
	[prof_type.PROF_TYPE_BOTANIST] = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900155.UI_Icon_900155'",	-- 园艺工
	[prof_type.PROF_TYPE_FISHER] = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900156.UI_Icon_900156'",	-- 捕鱼人
}

local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local ParentRedDotName = "Root/Menu/Mount"

---@class MountVM : UIViewModel
local MountVM = LuaClass(UIViewModel)

function MountVM:Ctor()
    -- message Mount
    -- {
    -- int32 ResID = 1;
    -- int32 Flag = 2;
    -- MountFrom From = 3;
    -- }
    self:Reset()
end

function MountVM:OnInit()
    
end

function MountVM:OnBegin()
    
end

function MountVM:OnEnd()
    self:Reset()
end

function MountVM:Reset()
    self.MountList = nil
    self.CustomMadeUnlockList = nil
    self.MountSpeedLevelMap = {}
    self.MountSpeedItemMap = {}
    self.GetwayFilterValue = (0xffff)
    self.VersionFilterValue = (0xffff)
    self.LikeFilterValue = (0xffff)

    self.NewMap = {}
    self.MountMap = {}

    self.CallSetting = 1
    self.CurRideResID = 0
    self.CurCustomMadeID = 0
    self.PlayActionList = nil
    self.MountSkillVMList = {}
    self.RecentCall = 0

    self.IsInRide = false
    self.IsInOtherRide = false
    self.IsMajorInFly = false
    self.IsOnGround = true
    self.IsMountFall = false
    self.IsCombatState = nil
    self.FlyHigh = false
    self.IsTransporting = nil
    self.AllowFlyRide = true
    self.AllowGetDownMount = true
    self.IsHostRideFull = false

    self.SkillMountIcon = nil
    self.SkillMusicIcon = nil
    self.IsShowNextSeatButton = nil
    self.IsPanelVisible = true
    self.IsMainMountCallButtonVisible = nil 
    self.MountCallBtnVisibleState = nil  --记录主界面乘骑Call按钮的visible状态
    self.FlyHigh = false

    self.NotesVisible = false
    self.IsJumpBtnVisible = nil
    self.IsFlyBtnVisible = nil
    self.IsBtnTransferVisible = false
    self.IsPanelFlyingVisible = nil
    self.IsPanelOtherRideVisible = nil
    self.IsControlMountBtnVisible = nil
    self.BtnGatherIconPath = ""
    self.SkillMountBtnIconOpacity = nil

    self.CombatPanelState = false
    self.bRideProbationState = false
    self.RedDotNameMap = {}

    self.HandleSkillViewFight = false
end

function MountVM:OnShutdown()
    
end

function MountVM:SetCallSetting(Index)
    self.CallSetting = Index
    self:UpdateSkillMountButtonState()
    USaveMgr.SetInt(SaveKey.MountCallSetting, self.CallSetting, true)
end

function MountVM:SetRecentCall(ResID)
    self.RecentCall = ResID
    USaveMgr.SetInt(SaveKey.MountRecentCall, ResID, true)
end

function MountVM:SetPanelVisible(IsVisible)
    self.IsPanelVisible = IsVisible
end

--各个业务系统调用这个(这样外部不需要记录状态了)
function MountVM:SetMountCallBtnVisible(IsVisible)
    if self.MountCallBtnVisibleState then
        self.IsMainMountCallButtonVisible = IsVisible
    end
end

function MountVM:LoadSavedSettings()
    self.CallSetting = USaveMgr.GetInt(SaveKey.MountCallSetting, 1, true)
    self:UpdateSkillMountButtonState()
    self.RecentCall = USaveMgr.GetInt(SaveKey.MountRecentCall, 0, true)
end

function MountVM:AddNew(MountData)
    if MountData == nil then return end
    -- FLOG_ERROR("self.NewMap = %s", table_to_string(self.NewMap))
    if not self:IsFlagSet(MountData.Flag, ProtoCS.MountFlagBitmap.MountFlagNew) then
        return
    end
    if self.NewMap[MountData.ResID] ~= nil then
        return
    end

    self.NewMap[MountData.ResID] = 1
    self.RedDotNameMap[MountData.ResID] = RedDotMgr:AddRedDotByParentRedDotName(ParentRedDotName)
    self:SaveNewInfo()
end

function MountVM:ClearNew()
    for k, _ in pairs(self.NewMap) do
        self.NewMap[k] = 0
        RedDotMgr:DelRedDotByName(self.RedDotNameMap[k])
    end
    self:SaveNewInfo()
end

function MountVM:ClearNewByResID(InResID)
    if InResID == nil then return end
    self.NewMap[InResID] = 0
    RedDotMgr:DelRedDotByName(self.RedDotNameMap[InResID])
    self:SaveNewInfo()
end

function MountVM:GetRedDotName(InResID)
    return self.RedDotNameMap and self.RedDotNameMap[InResID] or ""
end

function MountVM:IsNew(InResID)
    return self.NewMap[InResID] == 1
end

-- FlagBit的类型为ProtoCS.MountFlagBitmap
function MountVM:IsFlagSet(Flag, FlagBit)
    return Flag ~= nil and (Flag & FlagBit == FlagBit)
end

function MountVM:IsNotOwnedMount(InResID)
    return self.MountMap[InResID] == nil
end

function MountVM:SetRideState()
    local Major = MajorUtil:GetMajor()
    if Major == nil then return end
    local RideComp = Major:GetRideComponent()
    if RideComp == nil then return end


    --这里可能有问题MountCustomMadeVM:GetCustomMadeID(MountID, ImeChanID, PatternID)
    --在坐骑组件中保存的ImeChanID并不一定是坐骑动作外观表ID
    self.PlayActionList = _G.MountMgr:GetPlayActionList(RideComp:GetRideResID(), RideComp:GetImeChanID(RideComp:GetRideResID()))

    self.OldIsInOtherRide = self.IsInOtherRide
    self.IsInOtherRide = RideComp:IsInOtherRide()
    self.CurRideResID = RideComp:GetRideResID()
    self.IsInRide = RideComp:IsInRide()
    self.IsShowNextSeatButton = RideComp:GetSeatCount() > 1
    self:UpdateSkillMountButtonState()
end

function MountVM:SetIsMountFall(Value)
    self.IsMountFall = Value
    self:UpdateSkillMountButtonState()
end

function MountVM:UpdateVM()
end

function MountVM:SaveNewInfo()

    MountUtil.SaveMap(self.NewMap, SaveKey.MountNewMap)
end

function MountVM:LoadNewInfo()
    self.NewMap = MountUtil.LoadMap(SaveKey.MountNewMap)
end

function MountVM:RefreshFilterValue()
    self.GetwayFilterValue = (0xffff)
    self.VersionFilterValue = (0xffff)
    self.LikeFilterValue = (0xffff)
end

function MountVM:SetGetwayFilterValue(InGetwayValue, InValue)
    if InValue == true then
        self.GetwayFilterValue = self.GetwayFilterValue | (1 << InGetwayValue)
    else
        self.GetwayFilterValue = self.GetwayFilterValue & (~(1 << InGetwayValue))
    end
end

function MountVM:SetVersionFilterValue(InVersionValue, InValue)
    if InValue == true then
        self.VersionFilterValue = self.VersionFilterValue | (1 << InVersionValue)
    else
        self.VersionFilterValue = self.VersionFilterValue & (~(1 << InVersionValue))
    end
end

function MountVM:SetLikeFilterValue(InLikeValue, InValue)
    if InValue == true then
        self.LikeFilterValue = self.LikeFilterValue | (1 << InLikeValue)
    else
        self.LikeFilterValue = self.LikeFilterValue & (~(1 << InLikeValue))
    end
end

function MountVM:IsGetwayFilterValue(InGetwayValue)
    return self.GetwayFilterValue & (1 << InGetwayValue) > 0
end

function MountVM:IsVersionFilterValue(InVersionValue)
    return self.VersionFilterValue & (1 << InVersionValue) > 0
end

function MountVM:IsLikeFilterValue(InLikeValue)
    return self.LikeFilterValue & (1 << InLikeValue) > 0
end

function MountVM:SetNoteBookVisible(IsVisible)
    self.NotesVisible = IsVisible
    if IsVisible then
        local ProfID = MajorUtil.GetMajorProfID()
        if ProfID then
            local ProfIconBookPath = AllIconBookPath[ProfID]
            if ProfIconBookPath then
                self.BtnGatherIconPath = ProfIconBookPath
            end
        end
    end
end

function MountVM:UpdateSkillMountButtonState()
    if self.IsInRide then
        if self.IsMountFall then
            self.SkillMountIcon = BtnCancelFallingIcon
        else
            self.SkillMountIcon = BtnCancelCallIcon
        end
    else
        self.SkillMountIcon = BtnRideIcon[self.CallSetting]
    end
end

--peace false/fight true
function MountVM:UpdateCombatPanelState(State)
    self.CombatPanelState = State
end

function MountVM:SetCustomMadeID(MountResID, CustomMadeID)
    self.MountMap[MountResID].Facade = CustomMadeID
end

function MountVM:SetHandleSkillViewFight(bFight)
    self.HandleSkillViewFight = bFight
end

return MountVM