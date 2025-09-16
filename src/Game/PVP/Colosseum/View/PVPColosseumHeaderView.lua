---
--- Author: peterxie
--- DateTime:
--- Description: 战场态势
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PVPColosseumHeaderVM = require("Game/PVP/Colosseum/VM/PVPColosseumHeaderVM")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local ColosseumTeam = PVPColosseumDefine.ColosseumTeam

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")

local ImgPosition = _G.UE.FVector2D()
local CrystalPanelHalfWidth = 204

local Side =
{
    Left = 1,
    Right = 2,
}

---双方配置
local BothSideConfig =
{
	-- 队伍背景
	BlueRedTeamBg = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarTeam1_png.UI_PVPMain_Img_ProbarTeam1_png'",
	RedBlueTeamBg = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarTeam2_png.UI_PVPMain_Img_ProbarTeam2_png'",

	-- 进度条背景
	BlueRedProbarBg = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarBg_png.UI_PVPMain_Img_ProbarBg_png'",
	RedBlueProbarBg = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarBg1_png.UI_PVPMain_Img_ProbarBg1_png'",
}

---蓝方配置
local BlueSideConfig =
{
	-- 文本
	TextColor = "FFFFFFFF",
	OutlineColor = "187EB9B3",

	-- 目标点图标
    GoalIcon = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_GoalStart_png.UI_PVPMain_Img_GoalStart_png'",

    -- 进度条颜色与队伍颜色相反，进度条贴图有渐变不对称，区分左右
    ProgressBgL = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarRed_png.UI_PVPMain_Img_ProbarRed_png'",
    ProgressBgLightL = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarRedLight_png.UI_PVPMain_Img_ProbarRedLight_png'",
	ProgressBgR = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarRed1_png.UI_PVPMain_Img_ProbarRed1_png'",
    ProgressBgLightR = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarRedLight1_png.UI_PVPMain_Img_ProbarRedLight1_png'",
}

---红方配置
local RedSideConfig =
{
	TextColor = "FFFFFFFF",
	OutlineColor = "BA2A44B3",

    GoalIcon = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_GoalEnd_png.UI_PVPMain_Img_GoalEnd_png'",

	ProgressBgL = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarBlue1_png.UI_PVPMain_Img_ProbarBlue1_png'",
    ProgressBgLightL = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarBlueLight1_png.UI_PVPMain_Img_ProbarBlueLight1_png'",
    ProgressBgR = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarBlue_png.UI_PVPMain_Img_ProbarBlue_png'",
    ProgressBgLightR = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_ProbarBlueLight_png.UI_PVPMain_Img_ProbarBlueLight_png'",
}


---@class PVPColosseumHeaderView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Crystal PVPColosseumCrystalItemView
---@field IconTime UFImage
---@field ImgCheck1 UFImage
---@field ImgCheck2 UFImage
---@field ImgGoalBg1 UFImage
---@field ImgGoalBg2 UFImage
---@field ImgProbarBg UFImage
---@field ImgProbarExtraTime UFImage
---@field ImgProbarLight1 UFImage
---@field ImgProbarLight2 UFImage
---@field ImgTeamBg UFImage
---@field PanelProBarTeam1 UFCanvasPanel
---@field PanelProBarTeam2 UFCanvasPanel
---@field ProgressBar1 UProgressBar
---@field ProgressBar2 UProgressBar
---@field TextGoalNum1 UFTextBlock
---@field TextGoalNum2 UFTextBlock
---@field TextName1 UFTextBlock
---@field TextName2 UFTextBlock
---@field TextNum1 UFTextBlock
---@field TextNum2 UFTextBlock
---@field TextTime UFTextBlock
---@field AnimOvertime UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumHeaderView = LuaClass(UIView, true)

function PVPColosseumHeaderView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Crystal = nil
	--self.IconTime = nil
	--self.ImgCheck1 = nil
	--self.ImgCheck2 = nil
	--self.ImgGoalBg1 = nil
	--self.ImgGoalBg2 = nil
	--self.ImgProbarBg = nil
	--self.ImgProbarExtraTime = nil
	--self.ImgProbarLight1 = nil
	--self.ImgProbarLight2 = nil
	--self.ImgTeamBg = nil
	--self.PanelProBarTeam1 = nil
	--self.PanelProBarTeam2 = nil
	--self.ProgressBar1 = nil
	--self.ProgressBar2 = nil
	--self.TextGoalNum1 = nil
	--self.TextGoalNum2 = nil
	--self.TextName1 = nil
	--self.TextName2 = nil
	--self.TextNum1 = nil
	--self.TextNum2 = nil
	--self.TextTime = nil
	--self.AnimOvertime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumHeaderView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Crystal)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumHeaderView:OnInit()
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, "mm:ss", nil)

	self.Binders =
	{
        { "EndTime", UIBinderUpdateCountDown.New(self, self.AdapterCountDownTime, 1, true, true)},
		{ "IsSuddenDeath", UIBinderSetIsVisible.New(self, self.IconTime) },
		{ "IsSuddenDeath", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedIsSuddenDeath) },

		{ "CrystalPos", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCrystalPos) },
		{ "Goal_Team1", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedGoadTeam1) },
        { "Goal_Team2", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedGoadTeam2) },

        { "IconCheckState_Team1", UIBinderSetBrushFromAssetPath.New(self, self.ImgCheck1) },
        { "IconCheckState_Team2", UIBinderSetBrushFromAssetPath.New(self, self.ImgCheck2) },
        { "StrCheckProgress_Team1", UIBinderSetText.New(self, self.TextNum1) },
        { "StrCheckProgress_Team2", UIBinderSetText.New(self, self.TextNum2) },
        { "VisibleCheckProgress_Team1", UIBinderSetIsVisible.New(self, self.TextNum1) },
        { "VisibleCheckProgress_Team2", UIBinderSetIsVisible.New(self, self.TextNum2) },

		{ "IsSuddenDeath", UIBinderSetIsVisible.New(self, self.ImgProbarExtraTime) },
		{ "OvertimeBehindTargetProgress", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedOvertimeBehindTargetProgress) },
	}
end

function PVPColosseumHeaderView:OnDestroy()

end

function PVPColosseumHeaderView:OnShow()
	self:SetupTeam()
end

function PVPColosseumHeaderView:OnHide()

end

function PVPColosseumHeaderView:OnRegisterUIEvent()

end

function PVPColosseumHeaderView:OnRegisterGameEvent()

end

function PVPColosseumHeaderView:OnRegisterBinder()
	self:RegisterBinders(PVPColosseumHeaderVM, self.Binders)
end


-- 初始化队伍红蓝方显示，1队即星极队在左，2队即灵极队在右，我方队伍为蓝方
function PVPColosseumHeaderView:SetupTeam()
    local LSTR = _G.LSTR
	self.TextName1:SetText(LSTR(810001))
	self.TextName2:SetText(LSTR(810002))

    local MyTeamIndex = _G.PVPColosseumMgr:GetTeamIndex()
    if MyTeamIndex == ColosseumTeam.COLOSSEUM_TEAM_1 then
        -- 左蓝右红
		UIUtil.ImageSetBrushFromAssetPath(self.ImgTeamBg, BothSideConfig.BlueRedTeamBg)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgProbarBg, BothSideConfig.BlueRedProbarBg)
		self:SetupTeamSide(Side.Left, true)
        self:SetupTeamSide(Side.Right, false)
    else
        -- 左红右蓝
		UIUtil.ImageSetBrushFromAssetPath(self.ImgTeamBg, BothSideConfig.RedBlueTeamBg)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgProbarBg, BothSideConfig.RedBlueProbarBg)
		self:SetupTeamSide(Side.Left, false)
        self:SetupTeamSide(Side.Right, true)
    end
end

function PVPColosseumHeaderView:SetupTeamSide(SideIndex, IsBlue)
    local SideConfig = IsBlue and BlueSideConfig or RedSideConfig

    UIUtil.ImageSetBrushFromAssetPath(self["ImgGoalBg"..SideIndex], SideConfig.GoalIcon)

    UIUtil.TextBlockSetColorAndOpacityHex(self["TextName"..SideIndex], SideConfig.TextColor)
    UIUtil.TextBlockSetColorAndOpacityHex(self["TextGoalNum"..SideIndex], SideConfig.TextColor)
	UIUtil.TextBlockSetOutlineColorAndOpacityHex(self["TextName"..SideIndex], SideConfig.OutlineColor)
    UIUtil.TextBlockSetOutlineColorAndOpacityHex(self["TextGoalNum"..SideIndex], SideConfig.OutlineColor)

	if SideIndex == Side.Left then
		UIUtil.ProgressBarSetFillImage(self["ProgressBar"..SideIndex], SideConfig.ProgressBgL)
		UIUtil.ImageSetBrushFromAssetPath(self["ImgProbarLight"..SideIndex], SideConfig.ProgressBgLightL)
	else
		UIUtil.ProgressBarSetFillImage(self["ProgressBar"..SideIndex], SideConfig.ProgressBgR)
		UIUtil.ImageSetBrushFromAssetPath(self["ImgProbarLight"..SideIndex], SideConfig.ProgressBgLightR)
	end
end


-- 更新水晶位置
function PVPColosseumHeaderView:OnValueChangedCrystalPos(Value)
    local Progress = math.clamp(Value, -1000, 1000)
	local ProgressPercent = Progress / 1000
    ImgPosition.X = CrystalPanelHalfWidth * ProgressPercent
    ImgPosition.Y = 0
    UIUtil.CanvasSlotSetPosition(self.Crystal, ImgPosition)
end

-- 更新队伍1水晶最长推进进度，队伍1的进度条在右边
function PVPColosseumHeaderView:OnValueChangedGoadTeam1(Value)
	local Percent = Value / 1000

	self.TextGoalNum1:SetText(string.format("%.1f%%",  Value / 10))

	self.ProgressBar2:SetPercent(Percent)

	ImgPosition.X = CrystalPanelHalfWidth * Percent
	ImgPosition.Y = 0
    UIUtil.CanvasSlotSetPosition(self.ImgProbarLight2, ImgPosition)
end

-- 更新队伍2水晶最长推进进度，队伍2的进度条在左边
function PVPColosseumHeaderView:OnValueChangedGoadTeam2(Value)
	local Percent = Value / 1000

	self.TextGoalNum2:SetText(string.format("%.1f%%",  Value / 10))

	self.ProgressBar1:SetPercent(Percent)

	ImgPosition.X = CrystalPanelHalfWidth * Percent * -1 -- 进度条头部发光图标位置计算，-1是因为位置往左边
	ImgPosition.Y = 0
    UIUtil.CanvasSlotSetPosition(self.ImgProbarLight1, ImgPosition)
end

-- 更新劣势方获胜需要达到的推进进度
function PVPColosseumHeaderView:OnValueChangedOvertimeBehindTargetProgress(Value)
	local Progress = PVPColosseumHeaderVM.OvertimeBehindTargetProgress
	local ProgressPercent = Progress / 1000

	local OvertimeBehindTeamIndex = PVPColosseumHeaderVM.OvertimeBehindTeamIndex
    if OvertimeBehindTeamIndex == ColosseumTeam.COLOSSEUM_TEAM_1 then
		ImgPosition.X = CrystalPanelHalfWidth * ProgressPercent
	else
		ImgPosition.X = CrystalPanelHalfWidth * ProgressPercent * -1
	end
    ImgPosition.Y = 0
    UIUtil.CanvasSlotSetPosition(self.ImgProbarExtraTime, ImgPosition)
end

function PVPColosseumHeaderView:OnValueChangedIsSuddenDeath(Value)
	if Value then
		self:PlayAnimation(self.AnimOvertime)
	end
end

return PVPColosseumHeaderView