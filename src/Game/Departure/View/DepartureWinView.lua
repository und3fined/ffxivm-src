---
--- Author: Administrator
--- DateTime: 2025-03-24 20:46
--- Description:回收界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local DepartOfLightMgr = require("Game/Departure/DepartOfLightMgr")
local DepartOfLightDefine = require("Game/Departure/DepartOfLightDefine")
local DepartOfLightVMUtils = require("Game/Departure/DepartOfLightVMUtils")
local DepartOfLightVM = require("Game/Departure/VM/DepartOfLightVM")

---@class DepartureWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Banner DepartureBigBannerItemView
---@field BtnShare CommBtnLView
---@field CloseBtn CommonCloseBtnView
---@field CommonTitle CommonTitleView
---@field ImgBanerPaper UFImage
---@field ImgBanner UFImage
---@field NewBanner UScaleBox
---@field RichTextInfo URichTextBox
---@field TableView_46 UTableView
---@field TextHighlight UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureWinView = LuaClass(UIView, true)

function DepartureWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Banner = nil
	--self.BtnShare = nil
	--self.CloseBtn = nil
	--self.CommonTitle = nil
	--self.ImgBanerPaper = nil
	--self.ImgBanner = nil
	--self.NewBanner = nil
	--self.RichTextInfo = nil
	--self.TableView_46 = nil
	--self.TextHighlight = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Banner)
	self:AddSubView(self.BtnShare)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureWinView:OnInit()
	self.HighLightPerformTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_46, self.OnActivitySelected, true, false)
	self.Binders = {
		{"HighLightPerformVMList", UIBinderUpdateBindableList.New(self, self.HighLightPerformTableViewAdapter)},
		{"RecycleContent", UIBinderSetText.New(self, self.RichTextInfo)},
		{"HighLightBigIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBanerPaper)},
		{"HighLightBigIcon", UIBinderSetBrushFromAssetPath.New(self, self.Banner.ImgBanner)},
		{"FirstHightLightGameID", UIBinderValueChangedCallback.New(self, nil, self.OnFirstHightLightGameIDChanged)},
	}
end

function DepartureWinView:OnDestroy()

end

function DepartureWinView:OnShow()
	self:SetLSTR()
	AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.RecycelPanel)
	UIUtil.SetIsVisible(self.ImgBanerPaper, false)
	UIUtil.SetIsVisible(self.Banner.BtnBanner, true, false)
	UIUtil.SetIsVisible(self.Banner.BtnWardrobeL, true, false)
	UIUtil.SetIsVisible(self.Banner.BtnWardrobeR, true, false)
end

function DepartureWinView:OnHide()
	_G.EventMgr:SendEvent(_G.EventID.OnDepartRecycleViewVisibleChange, false)
end

function DepartureWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnShare, self.OnBtnShareClicked)
end

function DepartureWinView:OnRegisterGameEvent()

end

function DepartureWinView:OnRegisterBinder()
	self:RegisterBinders(DepartOfLightVM, self.Binders)
end

function DepartureWinView:SetLSTR()
	self.CommonTitle:SetTextTitleName(_G.LSTR(1620001)) --1620001("光之启程")
	self.TextTitle:SetText(_G.LSTR(1620012)) --1620012("启程出发")
	self.TextHighlight:SetText(_G.LSTR(1620013)) --1620013("高光表现")
	self.BtnShare:SetBtnName(_G.LSTR(1620027)) --1620027("分享")
end

-- 分享
function DepartureWinView:OnBtnShareClicked()
	UIUtil.SetIsVisible(self.BtnShare, false)
	self:ReqTakeScreenShot()
end

function DepartureWinView:ReqTakeScreenShot()
    if self.TakeScreenShotTimerID then
        return
    end

    self.TakeScreenShotTimerID = self:RegisterTimer(self.OnTimerTakeScreenShot,0.2,0.05,1)
end

function DepartureWinView:OnTimerTakeScreenShot()
	local function OnTakeScreenShotEnd()
		if self.TakeScreenShotTimerID then
			self:UnRegisterTimer(self.TakeScreenShotTimerID)
			self.TakeScreenShotTimerID = nil
		end
		UIUtil.SetIsVisible(self.BtnShare, true)
	end
	_G.ShareMgr:OpenScreenShotShare(OnTakeScreenShotEnd)
end

function DepartureWinView:OnFirstHightLightGameIDChanged(GameID)
	local DescInfo = DepartOfLightVMUtils.GetActivityDescInfoByGameID(GameID)
	if DescInfo then
		local ActivityID = DescInfo.ActivityID
		self.Banner:OnSwitchActivity(ActivityID)
	end
end

return DepartureWinView