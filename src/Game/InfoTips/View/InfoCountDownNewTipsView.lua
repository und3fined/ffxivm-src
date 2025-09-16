---
--- Author: Administrator
--- DateTime: 2024-08-15 16:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local AudioUtil = require("Utils/AudioUtil")
local CommonUtil = require("Utils/CommonUtil")

local Type2DefaultIconPath = "PaperSprite'/Game/UI/Atlas/InfoTips/Frames/UI_Info_Icon_NPCTalk_FrameIcon_02_png.UI_Info_Icon_NPCTalk_FrameIcon_02_png'"
local Type3DefaultIconPath = "PaperSprite'/Game/UI/Atlas/InfoTips/Frames/UI_Info_Icon_NPCTalk_FrameIcon_03_png.UI_Info_Icon_NPCTalk_FrameIcon_03_png'"
local Type4DefaultIconPath = "Texture2D'/Game/UI/Texture/InfoTips/UI_Info_Img_NPCTalk_NPC01.UI_Info_Img_NPCTalk_NPC01'"
---@class InfoCountDownNewTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_0 UFCanvasPanel
---@field ImgNPCHead01 UFImage
---@field ImgNPCHead02 UFImage
---@field ImgNameBG UFImage
---@field ImgProbar URadialImage
---@field PanelBG01 UFCanvasPanel
---@field PanelBG02 UFCanvasPanel
---@field PanelBG03 UFCanvasPanel
---@field PanelBG04 UFCanvasPanel
---@field PanelCoordinate UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field RichTextNPCDialog URichTextBox
---@field RichTextNPCName URichTextBox
---@field RichTextNPCName02 URichTextBox
---@field RichTextNPCName03 URichTextBox
---@field RichTextNPCName24 URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoCountDownNewTipsView = LuaClass(UIView, true)

function InfoCountDownNewTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_0 = nil
	--self.ImgNPCHead01 = nil
	--self.ImgNPCHead02 = nil
	--self.ImgNameBG = nil
	--self.ImgProbar = nil
	--self.PanelBG01 = nil
	--self.PanelBG02 = nil
	--self.PanelBG03 = nil
	--self.PanelBG04 = nil
	--self.PanelCoordinate = nil
	--self.PanelTips = nil
	--self.RichTextNPCDialog = nil
	--self.RichTextNPCName = nil
	--self.RichTextNPCName02 = nil
	--self.RichTextNPCName03 = nil
	--self.RichTextNPCName24 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoCountDownNewTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoCountDownNewTipsView:OnInit()
	self.ContentList = {}
	self.Timer = nil
	self.CurLoopCount = 0
	--玩家头像这规矩暂时没定，后面用起来再决定是否删除多余的
	UIUtil.SetIsVisible(self.ImgNPCHead01, true)
	UIUtil.SetIsVisible(self.ImgNPCHead02, false)
end

function InfoCountDownNewTipsView:OnDestroy()

end

function InfoCountDownNewTipsView:AddShowContent(Params)
	table.insert(self.ContentList, Params)
	if #self.ContentList > 0 and self.Timer == nil then
		self:ShowContent(self.ContentList[1])
	end
end

function InfoCountDownNewTipsView:OnShow()
	if self.Params == nil then
		return 
	end
	--self:AddShowContent(self.Params)
	--table.insert(self.ContentList, 1, self.Params)
	
	self:ShowContent(self.Params)
end

function InfoCountDownNewTipsView:ShowContent(CutParams)
	if self.Timer ~= nil then
		self:UnRegisterTimer(self.Timer)
		self.Timer = nil
	end
	self.CurLoopCount = 0
	self.ImgProbar:SetPercent(0)
	self:SetShowType(CutParams)
	if (CutParams.SoundName or "") ~= "" then
		AudioUtil.LoadAndPlayUISound(CutParams.SoundName)
	end

	local ShowTime = CutParams.ShowTime
	if ShowTime ~= nil then
		local LerpPro = ShowTime >= 3 and 0.01 or 0.05
		local LoopNum = math.ceil(1 / LerpPro)
		local Interval = ShowTime / LoopNum
		local function SetProPercent(self, LerpPro)
			self.CurLoopCount = self.CurLoopCount + 1
			local CurPro = 1 - LerpPro * self.CurLoopCount
			self.ImgProbar:SetPercent(CurPro)
			if CurPro == 0 then
				self:Hide()
				--[[   队列播放提示
				self:UnRegisterTimer(self.Timer)
				self.Timer = nil
				table.remove(self.ContentList, 1)
				if #self.ContentList > 0 then
					self:ShowContent(self.ContentList[1])
				else
					self:Hide()
				end
				]]
			end
		end
		self.Timer = self:RegisterTimer(SetProPercent, 0, Interval, LoopNum, LerpPro)
	end
end


function InfoCountDownNewTipsView:SetShowType(CutParams)
	local NPCName = CutParams.NPCName
	local ShowType = CutParams.ShowType or 1
	local IconPath = CutParams.IconPath or ""
	if IconPath ~= "" and ShowType == 1 then
		ShowType = 4
	end
	self:SwitchPosFromMainPanel(CutParams.ShowLocation)
	UIUtil.SetIsVisible(self.PanelBG01, false)
	UIUtil.SetIsVisible(self.PanelBG02, false)
	UIUtil.SetIsVisible(self.PanelBG03, false)
	UIUtil.SetIsVisible(self.PanelBG04, false)
	if ShowType == 1 then
		UIUtil.SetIsVisible(self.PanelBG01, true)
		self.RichTextNPCName:SetText(NPCName or "")
	elseif ShowType == 2 then
		UIUtil.SetIsVisible(self.PanelBG02, true)
		if IconPath == "" then
			IconPath = Type2DefaultIconPath
		end
		UIUtil.ImageSetBrushFromAssetPath(self.FImage, IconPath)
		self.RichTextNPCName02:SetText(NPCName or "")
	elseif ShowType == 3 then
		UIUtil.SetIsVisible(self.PanelBG03, true)
		if IconPath == "" then
			IconPath = Type3DefaultIconPath
		end
		UIUtil.ImageSetBrushFromAssetPath(self.FImage_1, IconPath)
		self.RichTextNPCName03:SetText(NPCName or "")
	elseif ShowType == 4 then
		UIUtil.SetIsVisible(self.PanelBG04, true)
		if IconPath == "" then
			IconPath = Type4DefaultIconPath
		end
		UIUtil.ImageSetBrushFromAssetPath(self.ImgNPCHead01, IconPath)
		self.RichTextNPCName24:SetText(NPCName or "")
	end
	local Content = CutParams.Content
	if Content ~= nil then
		self.RichTextNPCDialog:SetText(CutParams.Content)
	end
end

function InfoCountDownNewTipsView:OnHide()

end

function InfoCountDownNewTipsView:OnRegisterUIEvent()

end

function InfoCountDownNewTipsView:OnRegisterGameEvent()

end

function InfoCountDownNewTipsView:OnRegisterBinder()

end

---@type  设置显示位置
---@param ShowLocation int @0 中间偏上  @1 左侧偏上
function InfoCountDownNewTipsView:SwitchPosFromMainPanel(ShowLocation)
	ShowLocation = ShowLocation or 0
	if ShowLocation == 0 then 
		if self.PanelTips:GetParent() ~= self.FCanvasPanel_0 then
			self.PanelCoordinate:RemoveChild(self.PanelTips)
			self.FCanvasPanel_0:AddChild(self.PanelTips)
			UIUtil.CanvasSlotSetAutoSize(self.PanelTips, true)
		end
	else
		if self.PanelTips:GetParent() ~= self.PanelCoordinate then
			self.FCanvasPanel_0:RemoveChild(self.PanelTips)
			self.PanelCoordinate:AddChild(self.PanelTips)
			UIUtil.CanvasSlotSetAutoSize(self.PanelTips, true)
		end
	end
end

return InfoCountDownNewTipsView