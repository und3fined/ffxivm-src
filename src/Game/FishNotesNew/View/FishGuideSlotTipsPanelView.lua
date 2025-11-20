---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local FishGuideVM = require("Game/FishNotes/FishGuideVM")
local ProtoRes = require("Protocol/ProtoRes")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local ChatChannel = require("Game/Chat/ChatDefine").ChatChannel
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class FishGuideSlotTipsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChat UFButton
---@field BtnFishSwitch UFButton
---@field BtnInherit UFButton
---@field BtnMore UFButton
---@field ClockEmpty CommBackpackEmptyView
---@field CommInforBtn CommInforBtnView
---@field CommInforBtnObtain CommInforBtnView
---@field FCanvasPanel_CurrRanking UFCanvasPanel
---@field FHorizontalHistory UFHorizontalBox
---@field FishDetail UFCanvasPanel
---@field FishGuidePlaceI FishGuidePlaceItemView
---@field IconTips UFImage
---@field ImgFish UFImage
---@field ImgFish2 UFImage
---@field ImgFishBg1 UFImage
---@field ImgFishBg2 UFImage
---@field ImgFishDetailBg UFImage
---@field ImgFish_1 UFImage
---@field ImgInch UFImage
---@field ImgRanking1 UFImage
---@field ImgRanking2 UFImage
---@field InheritTips UFCanvasPanel
---@field PanelFish1 UFCanvasPanel
---@field PanelFish2 UFCanvasPanel
---@field TextCurrent1 UFTextBlock
---@field TextCurrent2 UFTextBlock
---@field TextFishDetail UFTextBlock
---@field TextFishName URichTextBox
---@field TextFishNumber UFTextBlock
---@field TextFishSeaboard UFTextBlock
---@field TextHistory UFTextBlock
---@field TextHistory2 UFTextBlock
---@field TextInherit UFTextBlock
---@field TextLevel UFTextBlock
---@field TextMaxSize UFTextBlock
---@field TextNumber UFTextBlock
---@field TextObtain UFTextBlock
---@field TextSize UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimInheritTips UWidgetAnimation
---@field AnimSwitchOff UWidgetAnimation
---@field AnimSwitchOn UWidgetAnimation
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishGuideSlotTipsPanelView = LuaClass(UIView, true)

function FishGuideSlotTipsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChat = nil
	--self.BtnFishSwitch = nil
	--self.BtnInherit = nil
	--self.BtnMore = nil
	--self.ClockEmpty = nil
	--self.CommInforBtn = nil
	--self.CommInforBtnObtain = nil
	--self.FCanvasPanel_CurrRanking = nil
	--self.FHorizontalHistory = nil
	--self.FishDetail = nil
	--self.FishGuidePlaceI = nil
	--self.IconTips = nil
	--self.ImgFish = nil
	--self.ImgFish2 = nil
	--self.ImgFishBg1 = nil
	--self.ImgFishBg2 = nil
	--self.ImgFishDetailBg = nil
	--self.ImgFish_1 = nil
	--self.ImgInch = nil
	--self.ImgRanking1 = nil
	--self.ImgRanking2 = nil
	--self.InheritTips = nil
	--self.PanelFish1 = nil
	--self.PanelFish2 = nil
	--self.TextCurrent1 = nil
	--self.TextCurrent2 = nil
	--self.TextFishDetail = nil
	--self.TextFishName = nil
	--self.TextFishNumber = nil
	--self.TextFishSeaboard = nil
	--self.TextHistory = nil
	--self.TextHistory2 = nil
	--self.TextInherit = nil
	--self.TextLevel = nil
	--self.TextMaxSize = nil
	--self.TextNumber = nil
	--self.TextObtain = nil
	--self.TextSize = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.AnimIn = nil
	--self.AnimInheritTips = nil
	--self.AnimSwitchOff = nil
	--self.AnimSwitchOn = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishGuideSlotTipsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ClockEmpty)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommInforBtnObtain)
	self:AddSubView(self.FishGuidePlaceI)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishGuideSlotTipsPanelView:OnInit()
	--self.PlaceListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPlace, nil, false, false)

	self.Binders = {
		{"SelectFishName", UIBinderSetText.New(self, self.TextFishName)},
		--{"SelectFishNameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextFishName)},
		{"SelectFishLevel", UIBinderSetText.New(self, self.TextLevel)},
		{"SelectFishSeaboard", UIBinderSetText.New(self, self.TextFishSeaboard)},
		{"SelectFishObtainPower", UIBinderSetText.New(self, self.TextObtain)},
		{"SelectFishNumberID", UIBinderSetText.New(self, self.TextNumber)},
		{"SelectFishDetail", UIBinderSetText.New(self, self.TextFishDetail)},
		{"SelectFishNumber", UIBinderSetText.New(self, self.TextFishNumber)},
		{"SelectFishSize", UIBinderSetText.New(self, self.TextSize)},
		{"SelectFishSizeTime", UIBinderSetText.New(self, self.TextTime)},
		{"bSelectFishDetailVisible", UIBinderSetIsVisible.New(self, self.FishDetail)},
		{"bSelectFishDetailVisible", UIBinderSetIsVisible.New(self, self.TextFishNumber)},
		{"FishUnlockText", UIBinderSetText.New(self, self.ClockEmpty.RichTextNoneBright)},
		{"bInheritVisible", UIBinderSetIsVisible.New(self, self.BtnInherit, false, true)},
		{"bInheritVisible", UIBinderSetIsVisible.New(self, self.TextInherit)},
		{"bFishUnlockVisible", UIBinderSetIsVisible.New(self, self.ClockEmpty)},
		{"FishIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgFish)},
		{"QualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgFishBg1)},
		{"PrintingPicture", UIBinderSetBrushFromAssetPath.New(self, self.ImgFishBg2)},
		{"bInheritTipsVisible", UIBinderSetIsVisible.New(self, self.InheritTips)},
		{"InheritTipsText", UIBinderSetText.New(self, self.TextTips)},
		{"InchIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgInch)},
		{"bLargeFontSize", UIBinderValueChangedCallback.New(self, nil, self.OnTextSizeChanged)},
		{"HistoryRanking", UIBinderSetText.New(self, self.TextHistory2)},
		{"CurRanking", UIBinderSetText.New(self, self.TextCurrent2)},
		{"HistoryRankingColor", UIBinderSetColorAndOpacityHex.New(self, self.TextHistory2)},
		{"HistoryRankingColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgRanking1)},
		{"CurRankingColor", UIBinderSetColorAndOpacityHex.New(self, self.TextCurrent2)},
		{"CurRankingColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgRanking2)},
		{"bSizeKing", UIBinderSetIsVisible.New(self, self.ImgFish_1)},
		{"bShowRankingVisible", UIBinderSetIsVisible.New(self, self.FHorizontalHistory)},
		{"bShowRankingVisible", UIBinderSetIsVisible.New(self, self.FCanvasPanel_CurrRanking)},
		{"bShowRankingVisible", UIBinderSetIsVisible.New(self, self.BtnMore, false, true)},
	}
end

function FishGuideSlotTipsPanelView:OnDestroy()

end

function FishGuideSlotTipsPanelView:OnTextSizeChanged(bLargeFontSize)
	local TextCurrentSize = bLargeFontSize and 27 or 22
	UIUtil.TextBlockSetFontSize(self.TextCurrent2, TextCurrentSize)
	local TextHistorySize = bLargeFontSize and 20 or 19
	UIUtil.TextBlockSetFontSize(self.TextHistory2, TextHistorySize)
end

function FishGuideSlotTipsPanelView:OnShow()
	self.TextInherit:SetText(_G.LSTR(180089))--"传承录："
	self.TextMaxSize:SetText(_G.LSTR(180060))--最大尺寸：
	self.FishGuidePlaceI.TextPlace:SetText(_G.LSTR(1120059))--"获取途径"
	self.TextHistory:SetText(_G.LSTR(180105))--历史最高
	self.TextCurrent1:SetText(_G.LSTR(180106))--当前排名
	UIUtil.SetIsVisible(self.BtnChat, false)
	UIUtil.SetIsVisible(self.ImgFish2, false)
	UIUtil.SetIsVisible(self.BtnFishSwitch, false)
	self.CommInforBtn:SetButtonStyle(HelpInfoUtil.HelpInfoType.NewTips)
end

function FishGuideSlotTipsPanelView:OnHide()

end

function FishGuideSlotTipsPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnChat, self.OnClickButtonComment)
	UIUtil.AddOnClickedEvent(self, self.BtnInherit, self.OnClickButtonInherit)
	UIUtil.AddOnClickedEvent(self, self.BtnFishSwitch, self.OnClickButtonFishSwitch)
	UIUtil.AddOnClickedEvent(self, self.FishGuidePlaceI.BtnPlace, self.OnClickButtonPlace)
	UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnClickedShareFish)
	self.CommInforBtn:SetCallback(self, self.OnClickCommInforBtn)
end

function FishGuideSlotTipsPanelView:OnRegisterGameEvent()
end

function FishGuideSlotTipsPanelView:OnRegisterBinder()
	self:RegisterBinders(FishGuideVM, self.Binders)
end

function FishGuideSlotTipsPanelView:OnClickButtonComment()
	FishGuideVM:CommentViewChanged(true)
end

function FishGuideSlotTipsPanelView:OnClickButtonInherit()
	FishGuideVM:ChangeInheritDisplayState()
	if FishGuideVM.bInheritTipsVisible then
		self:PlayAnimation(self.AnimInheritTips)
	end 
end

function FishGuideSlotTipsPanelView:OnClickButtonFishSwitch()
	FishGuideVM.FishSwitchState = not FishGuideVM.FishSwitchState
end

function FishGuideSlotTipsPanelView:OnFishSwitchState(FishSwitchState)
	if FishSwitchState == true then
		self:PlayAnimation(self.AnimSwitchOff)
	else
		self:PlayAnimation(self.AnimSwitchOn)
	end
end

function FishGuideSlotTipsPanelView:OnClickButtonPlace()
	local HauntList = FishGuideVM.HauntList
	local DataList = {}
	for _, Place in pairs(HauntList) do
		local bLock = _G.FishNotesMgr:CheckFishLocationbLock(Place.ID)
		if not bLock then
			table.insert(DataList, {
				ID = Place.ID,
				FunIcon = _G.FishNotesMgr:GetFactionIconByLocationID(Place.ID),
				FunDesc = Place.Name,
				IsUnLock = true,
				IsRedirect = 1,
				ItemID = FishGuideVM.SelectFishItemID,
				LocationInfo = Place,
				ItemAccessFunType = ProtoRes.ItemAccessFunType.Fun_Fishing,
				CanRevealPlot = true
			})
		end
	end
	table.sort(DataList, function(a, b)
		if a.IsRedirect ~= b.IsRedirect then
			return a.IsRedirect > b.IsRedirect
		end
		return a.ID < b.ID
	end)
	local Len = #DataList
    local Num = Len >= 6 and 5.5 or Len
	local Y = Len > 4 and -100 * (Num - 4) or 0
	local TipsWayView = TipsUtil.ShowGetWayTips(FishGuideVM, nil, self.FishGuidePlaceI, _G.UE.FVector2D(2, Y - 2))
	TipsWayView:UpdateView(DataList)
end

function FishGuideSlotTipsPanelView:OnClickCommInforBtn()
	local SaveData = _G.FishNotesMgr:GetUnlockFishData(FishGuideVM.NowData.ID)
	if SaveData == nil then
		_G.FLOG_INFO("FishGuideSlotTipsPanelView OnClickCommInforBtn SaveData is nil")
		return
	end
	local CurrPercent = SaveData.CurrPercent
	local TitleText = string.format('<span color="#d1ba8eFF">%s</>', _G.LSTR(180108))
	if CurrPercent == 0 then
		--180108"尺寸排名比较"  180109"该鱼尺寸未进入排名"
		TipsUtil.ShowSimpleTipsView({Title = TitleText, Content = _G.LSTR(180109)}, self.CommInforBtn, _G.UE.FVector2D(-390, 15))
	else
		--'该鱼当前尺寸排名超过了<span color="#dc5868FF">%d%%</>的玩家(钓起该鱼达到金牌总人数：<span color="#d1ba8eFF">%d</>)'
		local Content = string.format(_G.LSTR(180107), math.floor(CurrPercent * 100), SaveData.TotalNum)
		TipsUtil.ShowSimpleTipsView({Title = TitleText, Content = Content}, self.CommInforBtn, _G.UE.FVector2D(-740, 15))
	end
end

--region 鱼类分享-----------------------------------------------------------------------------------------
local ChannelNames = {
	{ChannelID = ChatChannel.Team, ChannelName = _G.LSTR(50114)},
	{ChannelID = ChatChannel.Army, ChannelName = _G.LSTR(50113)},
	{ChannelID = ChatChannel.Nearby, ChannelName = _G.LSTR(50116)},
	{ChannelID = ChatChannel.Area, ChannelName = _G.LSTR(50117)},
}

local function SendFishCardToChat(Channel, ChannelName)
	local ID, Size, LocationType, SizeTime, HighestRanking = FishGuideVM:GetShareFishInfo()
	local Succ = _G.ChatMgr:ShareFish(Channel, ID, Size, LocationType, SizeTime, HighestRanking)
    if Succ then
		_G.MsgTipsUtil.ShowTips(string.sformat(_G.LSTR(1310114), ChannelName))--已分享至%s
    end
end

function FishGuideSlotTipsPanelView:OnClickedShareFish()
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.CommStorageTipsView) then
		_G.UIViewMgr:HideView(_G.UIViewID.CommStorageTipsView)
		return
	end

	local TransData = {}

	--频道
	for _, v in pairs(ChannelNames) do
		if _G.ChatMgr:IsInChannel(v.ChannelID) then
			table.insert(TransData, {
				Content = v.ChannelName,
				ClickItemCallback = function()
					SendFishCardToChat(v.ChannelID, v.ChannelName)
					_G.UIViewMgr:HideView(_G.UIViewID.CommStorageTipsView)
				end
			})
		end
	end

	--复制信息
	table.insert(TransData, {
		Content = _G.LSTR(1310023),--复制信息
		ClickItemCallback = function()
			_G.FishGuideVM:SetClipboard(FishGuideVM:GetShareFishInfo())
			_G.UIViewMgr:HideView(_G.UIViewID.CommStorageTipsView)
		end,
		View = self,
	})

	local BtnSize = UIUtil.GetWidgetSize(self.BtnMore)
	TipsUtil.ShowStorageBtnsTips(TransData, self.BtnMore, _G.UE.FVector2D(-BtnSize.X, BtnSize.Y), _G.UE.FVector2D(1, 1), true)
end
--endregion

return FishGuideSlotTipsPanelView