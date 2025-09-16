---
--- Author: yutingzhan
--- DateTime: 2025-02-21 19:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local OpsVersionNoticeContentPanelVM = require("Game/Ops/VM/OpsVersionNoticeContentPanelVM")
local DataReportUtil = require("Utils/DataReportUtil")
local ReportButtonType = require("Define/ReportButtonType")

---@class OpsVersionNoticeContentPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoto CommBtnLView
---@field CloseBtn CommonCloseBtnView
---@field ImgPoster UFImage
---@field TableViewList UTableView
---@field TextTaskDescribe UFTextBlock
---@field TextTaskTitle UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsVersionNoticeContentPanelView = LuaClass(UIView, true)

function OpsVersionNoticeContentPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoto = nil
	--self.CloseBtn = nil
	--self.ImgPoster = nil
	--self.TableViewList = nil
	--self.TextTaskDescribe = nil
	--self.TextTaskTitle = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsVersionNoticeContentPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoto)
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsVersionNoticeContentPanelView:OnInit()
	self.TextTitle:SetText(LSTR(100103))
	self.NoticeTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnClickedSelectMemberItem)
	self.ViewModel = OpsVersionNoticeContentPanelVM.New()
	self.Binders = {
		{"TextTaskTitle", UIBinderSetText.New(self, self.TextTaskTitle)},
		{"TextTaskDescribe", UIBinderSetText.New(self, self.TextTaskDescribe)},
		{"JumpButton", UIBinderSetText.New(self, self.BtnGoto.TextContent)},
		{"BtnGotoVisiable", UIBinderSetIsVisible.New(self, self.BtnGoto)},
        {"NoticeItemVMList", UIBinderUpdateBindableList.New(self, self.NoticeTableViewAdapter)},
	}
end

function OpsVersionNoticeContentPanelView:OnDestroy()

end

function OpsVersionNoticeContentPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self.ViewModel:Update(self.Params)
	self.NoticeTableViewAdapter:SetSelectedIndex(1)
	DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.NewContentOpen), "2", self.Params.ActivityID)
end

function OpsVersionNoticeContentPanelView:OnHide()
	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end

	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.NewContentOpen), "3", self.Params.ActivityID)
end

function OpsVersionNoticeContentPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnGoto, self.OnClickBtnGoto)
end

function OpsVersionNoticeContentPanelView:OnRegisterGameEvent()

end

function OpsVersionNoticeContentPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsVersionNoticeContentPanelView:OnClickBtnGoto()
	DataReportUtil.ReportActivityFlowData("ActivityClickFlow", self.Params.ActivityID, 1, tostring(self.ViewModel.NodeID))
	OpsActivityMgr:Jump(self.ViewModel.JumpType, self.ViewModel.JumpParam)
end

function OpsVersionNoticeContentPanelView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
	self.ViewModel:SetItemChecked(Index)
	if string.match(self.ViewModel.ImgPoster, "http") then
		self:SetUrlPic(self.ViewModel.ImgPoster)
	else
		UIUtil.ImageSetBrushFromAssetPath(self.ImgPoster, self.ViewModel.ImgPoster)
	end
	_G.OpsSeasonActivityMgr:RecordRedDotClicked(ItemData.NodeID)
end

function OpsVersionNoticeContentPanelView:SetUrlPic(Url)

	if string.isnilorempty(Url) then
		return
	end

    local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("OpsVersionContentCDNPoster", true, 100)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
		function(_, texture)
			if texture then
				UIUtil.ImageSetBrushResourceObject(self.ImgPoster, texture)
				UIUtil.SetIsVisible(self.ImgPoster, true)
			end
		end
    )

    ImageDownloader.OnFail:Add(ImageDownloader,
		function()
			UIUtil.SetIsVisible(self.ImgPoster, false)
		end
	)

    ImageDownloader:Start(Url, "", true)
	self.ImageDownloader = ImageDownloader
end

return OpsVersionNoticeContentPanelView