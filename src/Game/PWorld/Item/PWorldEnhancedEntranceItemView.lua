---
--- Author: Administrator
--- DateTime: 2025-02-10 18:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ModuleOpenCfg = require("TableCfg/ModuleOpenCfg")
local ItemGetaccesstypeCfg = require("TableCfg/ItemGetaccesstypeCfg")
local ItemUtil = require("Utils/ItemUtil")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestMgr = require("Game/Quest/QuestMgr")
local HelpCfg = require("TableCfg/HelpCfg")
local AdventureRecommendTaskMgr = require("Game/Adventure/AdventureRecommendTaskMgr")
local TipsUtil = require("Utils/TipsUtil")
local LSTR = nil
local UIViewMgr = nil
local UIViewID = nil

---@class PWorldEnhancedEntranceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field Icon UFImage
---@field ImgPoster UFImage
---@field PanelGoto UFCanvasPanel
---@field PanelLock UFCanvasPanel
---@field RichTextContent URichTextBox
---@field TextGoto UFTextBlock
---@field TextLock UFTextBlock
---@field TextLock_1 UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldEnhancedEntranceItemView = LuaClass(UIView, true)

function PWorldEnhancedEntranceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.Icon = nil
	--self.ImgPoster = nil
	--self.PanelGoto = nil
	--self.PanelLock = nil
	--self.RichTextContent = nil
	--self.TextGoto = nil
	--self.TextLock = nil
	--self.TextLock_1 = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldEnhancedEntranceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldEnhancedEntranceItemView:OnInit()
	LSTR = _G.LSTR
	UIViewMgr = require("UI/UIViewMgr")
	UIViewID = require("Define/UIViewID")
end

function PWorldEnhancedEntranceItemView:OnDestroy()

end

function PWorldEnhancedEntranceItemView:OnShow()
	if not self.Params or not self.Params.Data then
		return
	end
	local CfgData = self.Params.Data
	if self.PanelLock then
		UIUtil.SetIsVisible(self.PanelLock, false)
	end
	if self.TextTitle then
		local EntranceTitle = CfgData.Name
		self.TextTitle:SetText(EntranceTitle)
	end
	if self.TextGoto then
		self.TextGoto:SetText(LSTR("1540006"))
	end
	if self.Icon then
		UIUtil.ImageSetBrushFromAssetPath(self.Icon, CfgData.PromoteIcon)
	end
	if self.ImgPoster then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgPoster, CfgData.Img)
	end

	self:SetUnlockedText()
end

--处理未解锁时显示的提示文本
function PWorldEnhancedEntranceItemView:SetUnlockedText()
	if not self.Params then return end
	local CfgData = self.Params.Data	--PromoteLevelUpCfg
	if not CfgData then return end
	if not CfgData.SystemOpenID or CfgData.SystemOpenID == 0 then
		self.IsOpen = true		--默认已解锁
		return
	end
	local ModuleID = _G.ModuleOpenMgr:CheckIDType(CfgData.SystemOpenID)
	local ModuleCfg = ModuleOpenCfg:FindCfgByKey(CfgData.SystemOpenID)
	if not ModuleCfg then return end
	local GetWayCfg = ItemGetaccesstypeCfg:FindCfgByKey(CfgData.JumpID)
	if GetWayCfg == nil then return end

	self.IsOpen = ItemUtil.QueryIsUnLock(GetWayCfg.FunType, ModuleID, nil)	--ProtoCommon.ModuleID.ModuleIDDailyRand 每日随机
	if self.IsOpen then return end	--已解锁则return

	UIUtil.SetIsVisible(self.PanelLock, true)
	UIUtil.SetIsVisible(self.PanelGoto, false)
	if self.TextLock then
		self.TextLock:SetText(LSTR(1540008))		--"未解锁"
	end

	local TaskID = ModuleCfg.PreTask and ModuleCfg.PreTask[1]
	if TaskID then
		local QuestCfg = QuestHelper.GetQuestCfgItem(TaskID)
		if QuestCfg then
			-- if self.IconLock_1 then
			-- 	local Icon = QuestMgr:GetChapterIconAtLog(QuestCfg.ChapterID, nil, false)
			-- 	UIUtil.ImageSetBrushFromAssetPath(self.IconLock_1, Icon) 	-- 设置任务图标
			-- end
			local UnlockedText = ""

			-- 不使用具体任务名来显示文本
			if not string.isnilorempty(CfgData.UnlockedText) then
				UnlockedText = CfgData.UnlockedText		--优先使用未解锁文本
			else
				local HelpCfgs = HelpCfg:FindAllHelpIDCfg(CfgData.HelpID)	--B帮助说明表
				if HelpCfgs and HelpCfgs[1] then
					UnlockedText = HelpCfgs[1].SecContent
				end
			end

			--使用首个任务名来显示文本
			-- local QCfg = QuestHelper.GetChapterCfgItem(QuestCfg.ChapterID)
			-- if QCfg then
			-- 	if not string.isnilorempty(CfgData.UnlockedText) then
			-- 		UnlockedText = CfgData.UnlockedText
			-- 	else
			-- 		UnlockedText = string.format("%d%s %s",QCfg.MinLevel, LSTR(1210002), QCfg.QuestName)
			-- 	end
			-- end
			
			if self.RichTextContent then
				self.RichTextContent:SetText(UnlockedText)
			end
			if self.TextLock_1 then
				self.TextLock_1:SetText(UnlockedText)
			end
		end
	end
end

function PWorldEnhancedEntranceItemView:OnHide()
	self:UnRegisterTimer(self.ClickButtonTimer)
end

function PWorldEnhancedEntranceItemView:OnRegisterUIEvent()
	self.ClickButtonTimer = self:RegisterTimer(function()
		if self and self.BtnSelect then
			UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickButtonItem)
		end
	end, 1)
end

function PWorldEnhancedEntranceItemView:OnRegisterGameEvent()

end

function PWorldEnhancedEntranceItemView:OnRegisterBinder()

end

function PWorldEnhancedEntranceItemView:OnClickButtonItem()
	local CfgData = self.Params.Data
	if not CfgData then return end
	local GetCfg = ItemGetaccesstypeCfg:FindCfgByKey(CfgData.JumpID)
	if GetCfg == nil then return end
	if self.IsOpen then
		_G.PromoteLevelUpMgr:JumpPanelByGetWayID(CfgData.JumpID)
		return
	end

	---未解锁
	local ModuleOpenData = ModuleOpenCfg:FindCfgByKey(CfgData.SystemOpenID)
	if not ModuleOpenData then return end
	if not ModuleOpenData.PreTask or #ModuleOpenData.PreTask == 0 then
		_G.MsgTipsUtil.ShowTipsByID(GetCfg.UnLockTipsID)
		return
	end
	local IsRecommendTask = false
	local TaskID
	local HelpInfoID = self.Params.Data.HelpID
	---目前只显示一个任务,默认显示配置第一个
	for _, ID in ipairs(ModuleOpenData.PreTask) do
		local QuestCfg = QuestHelper.GetQuestCfgItem(ID)
		if QuestCfg ~= nil then
			local RecommendTask = AdventureRecommendTaskMgr:GetRecommendTask()
			if RecommendTask then
				IsRecommendTask =  table.contain(RecommendTask, QuestCfg.ChapterID)
			end
			break
		end
	end
	if IsRecommendTask then
		HelpInfoID = self.Params.Data.HelpID
	end
	if ModuleOpenData.PreTask and ModuleOpenData.PreTask[1] then
		TaskID = ModuleOpenData.PreTask[1]
	end
	if TaskID then
		local Offset = _G.UE.FVector2D( 0, 0 )
		local TargetWidgetSize = _G.UE.UUIUtil.GetLocalSize(self)
		local Params
		Params = {
			ID = HelpInfoID,
			TitleText = LSTR(1210001),
			InTargetWidget = self,	
			Offset = Offset,
			Alignment = _G.UE.FVector2D( 1, 0 ),
			IsAutoFlip = true,
			TaskID = TaskID,
			IsShowTaskUI = true,
			IsAdaptationX = true,
		}
	 	UIViewMgr:ShowView(UIViewID.Main2ndHelpInfoTips, Params)
	end
	return
end

return PWorldEnhancedEntranceItemView