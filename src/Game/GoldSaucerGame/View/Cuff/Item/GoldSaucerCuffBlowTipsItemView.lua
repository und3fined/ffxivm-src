---
--- Author: Administrator
--- DateTime: 2024-02-04 11:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local CuffDefine = GoldSaucerMiniGameDefine.CuffDefine
local DelayTime = GoldSaucerMiniGameDefine.DelayTime
local ActorUtil = require("Utils/ActorUtil")
local CuffRewardCfg = require("TableCfg/CuffRewardCfg")
local MajorUtil = require("Utils/MajorUtil")
local UE = _G.UE
local ScoreStage = { Best = 3, Nice = 2, Good = 1}
---@class GoldSaucerCuffBlowTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgFullBlow UFImage
---@field ImgNumberHundred UFImage
---@field ImgNumberIndivual UFImage
---@field ImgNumberTen UFImage
---@field ImgNumberThousand UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCuffBlowTipsItemView = LuaClass(UIView, true)

function GoldSaucerCuffBlowTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgFullBlow = nil
	--self.ImgNumberHundred = nil
	--self.ImgNumberIndivual = nil
	--self.ImgNumberTen = nil
	--self.ImgNumberThousand = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffBlowTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffBlowTipsItemView:OnInit()
	self.ResultPath = {
		Best = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Img_ScoreFullBlow_png.UI_GoldSaucer_Cuff_Img_ScoreFullBlow_png'",
		Nice = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Img_ScoreFeelGood_png.UI_GoldSaucer_Cuff_Img_ScoreFeelGood_png'",
		Good = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Img_ScoreFeelitNow_png.UI_GoldSaucer_Cuff_Img_ScoreFeelitNow_png'",
		Fail = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Img_ScoreFail_png.UI_GoldSaucer_Cuff_Img_ScoreFail_png'"
	}
	if self.AllRewardCfg == nil then
		self.AllRewardCfg = CuffRewardCfg:FindAllCfg()
	end
	self.ResultValue = {
		Best = self.AllRewardCfg[ScoreStage.Best].Score,
		Nice = self.AllRewardCfg[ScoreStage.Nice].Score,
		Good = self.AllRewardCfg[ScoreStage.Good].Score,
	}

	self.ENum = {
		[0] = "Zero",
		[1] = "One",
		[2] = "Two",
		[3] = "Three",
		[4] = "Four",
		[5] = "Five",
		[6] = "Six",
		[7] = "Seven",
		[8] = "Eight",
		[9] = "Nine",
	}

	self.NumPath = {
		Zero = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score0_png.UI_GoldSaucer_Cuff_Number_Score0_png'",
		One = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score1_png.UI_GoldSaucer_Cuff_Number_Score1_png'",
		Two = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score2_png.UI_GoldSaucer_Cuff_Number_Score2_png'",
		Three = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score3_png.UI_GoldSaucer_Cuff_Number_Score3_png'",
		Four = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score4_png.UI_GoldSaucer_Cuff_Number_Score4_png'",
		Five = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score5_png.UI_GoldSaucer_Cuff_Number_Score5_png'",
		Six = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score6_png.UI_GoldSaucer_Cuff_Number_Score6_png'",
		Seven = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score7_png.UI_GoldSaucer_Cuff_Number_Score7_png'",
		Eight = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score8_png.UI_GoldSaucer_Cuff_Number_Score8_png'",
		Nine = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score9_png.UI_GoldSaucer_Cuff_Number_Score9_png'"
	}
	self.ScreenLocation = _G.UE.FVector2D()
	self.DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)  --获取视口大小
end

function GoldSaucerCuffBlowTipsItemView:OnDestroy()

end

function GoldSaucerCuffBlowTipsItemView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	local StrengthValue = Params.StrengthValue
	self:SetResultByValue(StrengthValue)
	self:SetStrengthValue(StrengthValue)
	-- self:UpdatePos()
	UIUtil.CanvasSlotSetPosition(self, CuffDefine.ResultUIPos)
	self:RegisterTimer(function() self:Hide() end, DelayTime.ResultUIHideTime)
end

function GoldSaucerCuffBlowTipsItemView:OnHide()

end

function GoldSaucerCuffBlowTipsItemView:OnRegisterUIEvent()

end

function GoldSaucerCuffBlowTipsItemView:OnRegisterGameEvent()

end

function GoldSaucerCuffBlowTipsItemView:OnRegisterBinder()

end

function GoldSaucerCuffBlowTipsItemView:UpdatePos(CharacterID)
	local FromActor = MajorUtil.GetMajor()
	-- local DistanceLocation, RotationAt = self:GetDistance(self.Params.EntityID)  							--镜头距离、夹角
	
	-- local RotationFactor = _G.UE.UKismetMathLibrary.MapRangeClamped(RotationAt, 0, 60, 0.7, 1)	 			--视角修正因素
	-- local DistanceFactor = _G.UE.UKismetMathLibrary.MapRangeClamped(DistanceLocation, 300, 1300, 45, 150)   --高度修正因素
	-- local OffsetFactor = DistanceFactor * RotationFactor													--限制超高

	if FromActor ~= nil then
		--因为角色不同身高，这里可以获取主角头部的骨骼插槽位置来确定UI显示的位置
		local HeadLocation = FromActor:Cast(_G.UE.ABaseCharacter):GetSocketLocationByName("head_M")
		-- HeadLocation.Z = HeadLocation.Z + 
		UIUtil.ProjectWorldLocationToScreen(HeadLocation, self.ScreenLocation)
		UIUtil.CanvasSlotSetPosition(self, self.ScreenLocation / self.DPIScale)
	end
end

function GoldSaucerCuffBlowTipsItemView:SetResultByValue(StrengthValue)
	local ResultPath = self.ResultPath
	local ResultValue = self.ResultValue
	local NeedPath = ""
	if tonumber(StrengthValue) >= ResultValue.Best then
		NeedPath = ResultPath.Best
	elseif tonumber(StrengthValue) >= ResultValue.Nice then
		NeedPath = ResultPath.Nice
	elseif tonumber(StrengthValue) >= ResultValue.Good then
		NeedPath = ResultPath.Good
	else
		NeedPath = ResultPath.Fail
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgFullBlow, NeedPath)
end

function GoldSaucerCuffBlowTipsItemView:SetStrengthValue(StrengthValue)
	local bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = false, false, false, false
	if StrengthValue - 1000 >= 0 then
		bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = true, true, true, true
	elseif StrengthValue - 100 >= 0 then
		bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = true, true, true, false
	elseif StrengthValue - 10 >= 0 then
		bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = true, true, false, false
	elseif StrengthValue - 1 >= 0 then
		bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = true, false, false, false
	else
		bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = false, false, false, false
	end
	UIUtil.SetIsVisible(self.ImgNumberIndivual, bIndivualVisible)
	UIUtil.SetIsVisible(self.ImgNumberTen, bTenVisible)
	UIUtil.SetIsVisible(self.ImgNumberHundred, bHundredVisible)
	UIUtil.SetIsVisible(self.ImgNumberThousand, bThousandVisible)

	local Thousand = math.floor(StrengthValue / 1000)
	local Hundred = math.floor(StrengthValue % 1000 / 100)
	local Ten = math.floor(StrengthValue % 100 /10)
	local Indivaul = math.floor(StrengthValue % 10)
	local ENum = self.ENum
	local NumPath = self.NumPath
	UIUtil.ImageSetBrushFromAssetPath(self.ImgNumberIndivual, NumPath[ENum[Indivaul]] )
	UIUtil.ImageSetBrushFromAssetPath(self.ImgNumberTen, NumPath[ENum[Ten]] )
	UIUtil.ImageSetBrushFromAssetPath(self.ImgNumberHundred, NumPath[ENum[Hundred]] )
	UIUtil.ImageSetBrushFromAssetPath(self.ImgNumberThousand, NumPath[ENum[Thousand]] )
end


return GoldSaucerCuffBlowTipsItemView