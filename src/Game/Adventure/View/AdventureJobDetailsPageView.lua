--[[
Author: luojiewen_ds luojiewen@dasheng.tv
Date: 2024-07-29 15:07:04
LastEditors: luojiewen_ds luojiewen@dasheng.tv
LastEditTime: 2024-07-29 16:44:03
FilePath: \Script\Game\Adventure\View\AdventureJobDetailsPageView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: Administrator
--- DateTime: 2024-07-29 15:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local LightDefine = require("Game/Light/LightDefine")
--VM
local AdventureDetailVM = require("Game/Adventure/AdventureDetailVM")

--Cfg
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProfModelCfg = require("TableCfg/ProfModelCfg")

--binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local ProtoCommon = require("Protocol/ProtoCommon")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local EquipmentCameraControlDataLoader = require("Game/Equipment/EquipmentCameraControlDataLoader")

---@class AdventureJobDetailsPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AdventureJob1 AdventureJobItemView
---@field AdventureJob2 AdventureJobItemView
---@field BtnGo CommBtnLView
---@field BtnTryRole CommBtnLView
---@field CommonRedDot2 CommonRedDot2View
---@field CommonRender2D CommonRender2DView
---@field IconArrow1 UFImage
---@field IconArrow2 UFImage
---@field IconJob1 UFImage
---@field IconJob2 UFImage
---@field ImgLogo UFImage
---@field PanelInfo_1 UFCanvasPanel
---@field ScorllBoxProfDesc UScrollBox
---@field TextInfo UFTextBlock
---@field TextPreview UFTextBlock
---@field TextPreview2 UFTextBlock
---@field TextPreview3 UFTextBlock
---@field TextRoleName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureJobDetailsPageView = LuaClass(UIView, true)

function AdventureJobDetailsPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AdventureJob1 = nil
	--self.AdventureJob2 = nil
	--self.BtnGo = nil
	--self.BtnTryRole = nil
	--self.CommonRedDot2 = nil
	--self.CommonRender2D = nil
	--self.IconArrow1 = nil
	--self.IconArrow2 = nil
	--self.IconJob1 = nil
	--self.IconJob2 = nil
	--self.ImgLogo = nil
	--self.PanelInfo_1 = nil
	--self.ScorllBoxProfDesc = nil
	--self.TextInfo = nil
	--self.TextPreview = nil
	--self.TextPreview2 = nil
	--self.TextPreview3 = nil
	--self.TextRoleName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureJobDetailsPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AdventureJob1)
	self:AddSubView(self.AdventureJob2)
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.BtnTryRole)
	self:AddSubView(self.CommonRedDot2)
	self:AddSubView(self.CommonRender2D)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureJobDetailsPageView:OnInit()
	self.ViewModel = AdventureDetailVM.New()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
end

function AdventureJobDetailsPageView:OnShow()
	local DelayTime = self.AnimIn:GetEndTime() or 0
	self:RegisterTimer(function()
		self:PlayAnimation(self.AnimIn, DelayTime, 1, 0, 1.0, false)
	end, DelayTime, 0, 0)

	self:OnSelectJobChange(self.Params.Prof or 0)
	--显示模型，Render2D显示一个，拖另一个Npc旋转s
	if self.Params.NeedRenderActor then
		UIUtil.SetIsVisible(self.TextPreview3, false)
	else
		UIUtil.SetIsVisible(self.TextPreview3, true)
	end

	--_G.LightMgr:LoadLightLevel(LightDefine.LightLevelID.LIGHT_LEVEL_ID_PROFCAREER)
	UIUtil.SetRenderOpacity(self.AdventureJob1.ImgBG, 0.45)
	UIUtil.SetRenderOpacity(self.AdventureJob2.ImgBG, 0.45)
	UIUtil.SetIsVisible(self.BtnTryRole, self.Params.NeedRenderActor and true or false)
	self.TextPreview3:SetText(LSTR(520060))
	self.BtnTryRole.TextContent:SetText(LSTR(520061))
	self.BtnGo.TextContent:SetText(LSTR(520062))
	self.TextPreview:SetText(LSTR(520063))
end

function AdventureJobDetailsPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickOpenMap)
	UIUtil.AddOnClickedEvent(self, self.BtnTryRole, self.OnClickOpenSkillPanel)
end

function AdventureJobDetailsPageView:OnRegisterBinder()
	local Binders = {
		{"JobName", UIBinderSetText.New(self, self.TextRoleName)},
		{"DetailText", UIBinderSetText.New(self, self.TextInfo)},
		{"PreviewText", UIBinderSetText.New(self, self.TextPreview2)},
		{"AdventureJobText1", UIBinderSetText.New(self, self.AdventureJob1.TextOngoing)},
		{"AdventureJobText2", UIBinderSetText.New(self, self.AdventureJob2.TextOngoing)},
		{"ButtonText",UIBinderSetText.New(self, self.BtnTryRole.TextContent)},


		{"LogoPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgLogo)},
		{"NowJobIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconJob1)},
		{"NextJobIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconJob2)},

		{"bIsShowNowJobIcon", UIBinderSetIsVisible.New(self, self.SizeBox1)},
		{"bIsShowNextJobIcon", UIBinderSetIsVisible.New(self, self.SizeBox2)},
		{"bIsArrowShow", UIBinderSetIsVisible.New(self, self.PanelArrow)},
		{"bIsPreviewTextShow", UIBinderSetIsVisible.New(self, self.TextPreview2)},
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

--选中职业改变
function AdventureJobDetailsPageView:OnSelectJobChange(Prof)
	self:PlayAnimation(self.AnimUpdate)
	self.TextInfo:ScrollToStart()
	self.ViewModel:OnSelectJobChange(Prof)
	--改成图片显示
	self:SwitchUIActor(self.ViewModel.Prof)
end

--前往转职
function AdventureJobDetailsPageView:OnClickOpenMap()
	local MajorUtil = require("Utils/MajorUtil")
	local RoleVM = MajorUtil.GetMajorRoleVM()
	local ProfList = RoleVM.ProfSimpleDataList
	local MaxLevel = 1
	for _, v in pairs(ProfList) do
		if v.Level > MaxLevel then
			MaxLevel = v.Level
		end
	end
	local StartQuestCfg = _G.AdventureCareerMgr:GetCurProfChangeProfData(self.ViewModel.Prof)
	if not StartQuestCfg or not next(StartQuestCfg) then return end
	local tLevel = StartQuestCfg.Level
	--战斗职业判断等级
	if self.ViewModel.Specialization and
	self.ViewModel.Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
		if MaxLevel < tLevel then
			MsgTipsUtil.ShowErrorTips(string.format(LSTR(520044), tLevel))
			return
		end
	end

	_G.WorldMapMgr:ShowWorldMapQuest(StartQuestCfg.AcceptMapID, StartQuestCfg.AcceptUIMapID, StartQuestCfg.StartQuestID)

	if self.MapAnimationTimer and self.MapAnimationTimer ~= 0 then
		self:UnRegisterTimer(self.MapAnimationTimer)
	end
	local WorldMapPanel = _G.UIViewMgr:FindView(_G.UIViewID.WorldMapPanel)
	local MarkerView = WorldMapPanel.MapContent:GetMapMarkerByID(StartQuestCfg.StartQuestID)
	self.MapAnimationTimer = self:RegisterTimer(function()
		if MarkerView then
            MarkerView:playAnimation(MarkerView.AnimNew)
        end
	end, 0, 2.97, 3)
end

function AdventureJobDetailsPageView:OnClickOpenSkillPanel()
	local Params = {IndependentView = true}
	_G.EquipmentMgr:SetPreviewProfID(true, self.ViewModel.Prof)
	_G.UIViewMgr:ShowView(UIViewID.SkillMainPanel, Params)
end
------------------------模型相关--------------------
---切换未解锁职业Npc
function AdventureJobDetailsPageView:SwitchUIActor(ProfID)
end

return AdventureJobDetailsPageView