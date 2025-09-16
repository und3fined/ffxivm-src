---
--- Author: peterxie
--- DateTime:
--- Description: 入场介绍界面，队伍展示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local ColosseumTeam = PVPColosseumDefine.ColosseumTeam


---@class PVPColosseumIntroductionView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgA1 UFImage
---@field ImgA2 UFImage
---@field ImgBg1 UFImage
---@field ImgBg2 UFImage
---@field ImgS1 UFImage
---@field ImgV1 UFImage
---@field PanelVS1 UFCanvasPanel
---@field TableView1 UTableView
---@field TableView2 UTableView
---@field TextName1 UFTextBlock
---@field TextName2 UFTextBlock
---@field AnimBlueIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimRedIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumIntroductionView = LuaClass(UIView, true)

function PVPColosseumIntroductionView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgA1 = nil
	--self.ImgA2 = nil
	--self.ImgBg1 = nil
	--self.ImgBg2 = nil
	--self.ImgS1 = nil
	--self.ImgV1 = nil
	--self.PanelVS1 = nil
	--self.TableView1 = nil
	--self.TableView2 = nil
	--self.TextName1 = nil
	--self.TextName2 = nil
	--self.AnimBlueIn = nil
	--self.AnimOut = nil
	--self.AnimRedIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumIntroductionView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumIntroductionView:OnInit()
	self.TableViewAdapter1 = UIAdapterTableView.CreateAdapter(self, self.TableView1)
	self.TableViewAdapter2 = UIAdapterTableView.CreateAdapter(self, self.TableView2)
end

function PVPColosseumIntroductionView:OnDestroy()

end

function PVPColosseumIntroductionView:OnShow()
	self:SetupTeam()
	self:ShowTeam()
end

function PVPColosseumIntroductionView:OnHide()
	local AudioUtil = require("Utils/AudioUtil")
	AudioUtil.LoadAndPlay2DSound(PVPColosseumDefine.AudioPath.IntroductionOut)
end

function PVPColosseumIntroductionView:OnRegisterUIEvent()

end

function PVPColosseumIntroductionView:OnRegisterGameEvent()

end

function PVPColosseumIntroductionView:OnRegisterBinder()

end

-- 初始化队伍红蓝方显示，1队即星极队在上，2队即灵极队在下，我方队伍为蓝方
function PVPColosseumIntroductionView:SetupTeam()
	local BlueStarPath = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_BlueStar.UI_PVPColosseum_Img_BlueStar'"
	local BlueSpiritPath = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_BlueSpirit.UI_PVPColosseum_Img_BlueSpirit'"
	local RedStarPath =  "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_RedStar.UI_PVPColosseum_Img_RedStar'"
	local RedSpiritPath = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_RedSpirit.UI_PVPColosseum_Img_RedSpirit'"

	local BlueLine = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPColosseum_Img_LineBlue_png.UI_PVPColosseum_Img_LineBlue_png'"
	local RedLine = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPColosseum_Img_LineRed_png.UI_PVPColosseum_Img_LineRed_png'"
	local BlueLine1 = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPColosseum_Img_LineBlue1_png.UI_PVPColosseum_Img_LineBlue1_png'"
	local RedLine1 = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPColosseum_Img_LineRed1_png.UI_PVPColosseum_Img_LineRed1_png'"

	local BlueV = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_V1.UI_PVPColosseum_Img_V1'"
	local RedV = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_V2.UI_PVPColosseum_Img_V2'"
	local RedS = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_S1.UI_PVPColosseum_Img_S1'"
	local BlueS = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_S2.UI_PVPColosseum_Img_S2'"

	local LSTR = _G.LSTR
	self.TextName1:SetText(LSTR(810001))
	self.TextName2:SetText(LSTR(810002))

	local MyTeamIndex = _G.PVPColosseumMgr:GetTeamIndex()
	if MyTeamIndex == ColosseumTeam.COLOSSEUM_TEAM_1 then
		-- 上面蓝方，下面红方
		UIUtil.ImageSetBrushFromAssetPath(self.ImgBg1, BlueStarPath)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgBg2, RedSpiritPath)

		UIUtil.ImageSetBrushFromAssetPath(self.ImgA1, BlueLine)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgA2, RedLine)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgV1, BlueV)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgS1, RedS)

		self:PlayAnimation(self.AnimRedIn)
	else
		-- 上面红方，下面蓝方
		UIUtil.ImageSetBrushFromAssetPath(self.ImgBg1, RedStarPath)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgBg2, BlueSpiritPath)

		UIUtil.ImageSetBrushFromAssetPath(self.ImgA1, RedLine1)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgA2, BlueLine1)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgV1, RedV)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgS1, BlueS)

		self:PlayAnimation(self.AnimBlueIn)
	end
end

-- 双方队伍成员显示
function PVPColosseumIntroductionView:ShowTeam()
	local PlayerMemberVMList = _G.PVPTeamMgr:GetPVPTeamVM():GetTeamMemberList()
	local EnemyMemberVMList = _G.PVPTeamMgr:GetPVPTeamVM():GetEnemyMemberList()

	local MyTeamIndex = _G.PVPColosseumMgr:GetTeamIndex()
	if MyTeamIndex == ColosseumTeam.COLOSSEUM_TEAM_1 then
		self.TableViewAdapter1:UpdateAll(PlayerMemberVMList)
		self.TableViewAdapter2:UpdateAll(EnemyMemberVMList)
	else
		self.TableViewAdapter1:UpdateAll(EnemyMemberVMList)
		self.TableViewAdapter2:UpdateAll(PlayerMemberVMList)
	end
end

return PVPColosseumIntroductionView