local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsVersionNoticeMainPanelVM = require("Game/Ops/VM/OpsVersionNoticeMainPanelVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ProtoCS = require("Protocol/ProtoCS")

---@class OpsVersionNoticeMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTimeItem OpsActivityTimeItemView
---@field BtnCheck UFButton
---@field BtnReceive CommBtnSView
---@field Comm126Slot CommBackpack126SlotView
---@field ImgPoster UFImage
---@field PanelContent1 UFCanvasPanel
---@field PanelContent2 UFCanvasPanel
---@field PanelContent3 UFCanvasPanel
---@field PanelContent4 UFCanvasPanel
---@field PosterM1 OpsVersionNoticePosterMiddleItemView
---@field PosterM2 OpsVersionNoticePosterMiddleItemView
---@field PosterM3 OpsVersionNoticePosterMiddleItemView
---@field PosterS01 OpsVersionNoticePosterSmallItemView
---@field PosterS02 OpsVersionNoticePosterSmallItemView
---@field PosterS03 OpsVersionNoticePosterSmallItemView
---@field PosterS04 OpsVersionNoticePosterSmallItemView
---@field PosterS1 OpsVersionNoticePosterSmallItemView
---@field PosterS2 OpsVersionNoticePosterSmallItemView
---@field ShareTips OpsActivityShareTipsItemView
---@field TableViewTask UTableView
---@field TextInfo UFTextBlock
---@field TextPoster UFTextBlock
---@field TextTask UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsVersionNoticeMainPanelView = LuaClass(UIView, true)

function OpsVersionNoticeMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTimeItem = nil
	--self.BtnCheck = nil
	--self.BtnReceive = nil
	--self.Comm126Slot = nil
	--self.ImgPoster = nil
	--self.PanelContent1 = nil
	--self.PanelContent2 = nil
	--self.PanelContent3 = nil
	--self.PanelContent4 = nil
	--self.PosterM1 = nil
	--self.PosterM2 = nil
	--self.PosterM3 = nil
	--self.PosterS01 = nil
	--self.PosterS02 = nil
	--self.PosterS03 = nil
	--self.PosterS04 = nil
	--self.PosterS1 = nil
	--self.PosterS2 = nil
	--self.ShareTips = nil
	--self.TableViewTask = nil
	--self.TextInfo = nil
	--self.TextPoster = nil
	--self.TextTask = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsVersionNoticeMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTimeItem)
	self:AddSubView(self.BtnReceive)
	self:AddSubView(self.Comm126Slot)
	self:AddSubView(self.PosterM1)
	self:AddSubView(self.PosterM2)
	self:AddSubView(self.PosterM3)
	self:AddSubView(self.PosterS01)
	self:AddSubView(self.PosterS02)
	self:AddSubView(self.PosterS03)
	self:AddSubView(self.PosterS04)
	self:AddSubView(self.PosterS1)
	self:AddSubView(self.PosterS2)
	self:AddSubView(self.ShareTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsVersionNoticeMainPanelView:OnInit()
	UIUtil.SetIsVisible(self.Comm126Slot.IconChoose, false)
	self.ViewModel = OpsVersionNoticeMainPanelVM.New()
	self.TaskTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTask)
	self.Binders = {
        {"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextInfo", UIBinderSetText.New(self, self.TextInfo)},
		{"TextTask", UIBinderSetText.New(self, self.TextTask)},
		{"TextBtn", UIBinderSetText.New(self, self.BtnReceive)},
        {"TaskVMList", UIBinderUpdateBindableList.New(self, self.TaskTableViewAdapter)},
		{"RewardSlotNum", UIBinderSetText.New(self, self.Comm126Slot.RichTextQuantity)},
		{"RewardSlotNumVisiable", UIBinderSetIsVisible.New(self, self.Comm126Slot.RichTextQuantity)},
		{"RewardSlotIcon", UIBinderSetBrushFromAssetPath.New(self, self.Comm126Slot.Icon)},
		{"RewardSlotQuality", UIBinderSetBrushFromAssetPath.New(self, self.Comm126Slot.ImgQuanlity)},
		{"RewardReceivedVisiable", UIBinderSetIsVisible.New(self, self.Comm126Slot.IconReceived)},
		{"RewardReceivedVisiable", UIBinderSetIsVisible.New(self, self.Comm126Slot.ImgMask)},
		{"Panel1Visiable", UIBinderSetIsVisible.New(self, self.PanelContent1)},
		{"Panel2Visiable", UIBinderSetIsVisible.New(self, self.PanelContent2)},
		{"Panel3Visiable", UIBinderSetIsVisible.New(self, self.PanelContent3)},
		{"Panel4Visiable", UIBinderSetIsVisible.New(self, self.PanelContent4)},
		{"Panel1TextPoster1", UIBinderSetText.New(self, self.TextPoster)},
		{"Panel2TextPoster1", UIBinderSetText.New(self, self.PosterM1.TextPoster)},
		{"Panel2TextPoster2", UIBinderSetText.New(self, self.PosterM2.TextPoster)},
		{"Panel3TextPoster1", UIBinderSetText.New(self, self.PosterM3.TextPoster)},
		{"Panel3TextPoster2", UIBinderSetText.New(self, self.PosterS1.TextPoster)},
		{"Panel3TextPoster3", UIBinderSetText.New(self, self.PosterS2.TextPoster)},
		{"Panel4TextPoster1", UIBinderSetText.New(self, self.PosterS01.TextPoster)},
		{"Panel4TextPoster2", UIBinderSetText.New(self, self.PosterS02.TextPoster)},
		{"Panel4TextPoster3", UIBinderSetText.New(self, self.PosterS03.TextPoster)},
		{"Panel4TextPoster4", UIBinderSetText.New(self, self.PosterS04.TextPoster)},
    }
end

function OpsVersionNoticeMainPanelView:OnDestroy()

end

function OpsVersionNoticeMainPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self.ViewModel:Update(self.Params)
	self.ShareTips.Params = self.Params
	UIUtil.SetIsVisible(self.ShareTips, self.ViewModel.ShareTipsVisiable)
	self:SetBtnState()
	self:SetPosterCDNPic()
end

function OpsVersionNoticeMainPanelView:OnHide()
	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end
end

function OpsVersionNoticeMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnCheck, self.OnBtnCheckClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnReceive, self.OnBtnReceiveClick)
	UIUtil.AddOnClickedEvent(self,  self.Comm126Slot.Btn, self.OnClickRewardSlot)

end

function OpsVersionNoticeMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.UpdateActivity)
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.UpdateActivity)
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdateInfo, self.UpdateActivity)
end

function OpsVersionNoticeMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsVersionNoticeMainPanelView:OnBtnCheckClick()
	if self.ViewModel then
		_G.PreviewMgr:OpenPreviewView(self.ViewModel.RewardItemID)
	end
end

function OpsVersionNoticeMainPanelView:OnBtnReceiveClick()
	OpsActivityMgr:SendActivityNodeGetReward(self.ViewModel.MainAccumulativeNodeID)
end

function OpsVersionNoticeMainPanelView:OnClickRewardSlot()
	ItemTipsUtil.ShowTipsByResID(self.ViewModel.RewardItemID, self.Comm126Slot, nil, nil, 30)
end

function OpsVersionNoticeMainPanelView:SetBtnState()
	if self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		self.BtnReceive:SetIsDisabledState(true, false)
		self.BtnReceive:SetText(LSTR(100036))
		self.ViewModel.RewardReceivedVisiable = false
	elseif self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		self.BtnReceive:SetIsRecommendState(true)
		self.BtnReceive:SetText(LSTR(10021))
		self.ViewModel.RewardReceivedVisiable = false
	elseif self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		self.BtnReceive:SetIsDoneState(true, LSTR(100037))
		self.ViewModel.RewardReceivedVisiable = true
	end
end

function OpsVersionNoticeMainPanelView:UpdateActivity(MsgBody)
	if self.Params == nil then
		return
	end

	if self.Params.ActivityID == nil then
		return
	end

	local Activity = self.Params.Activity
    local Detail = _G.OpsActivityMgr.ActivityNodeMap[self.Params.ActivityID] or {}
    self.Params:UpdateVM({Activity = Activity, Detail = Detail})
	local IsUpdateActivity = true
	self.ViewModel:Update(self.Params, IsUpdateActivity)
	self.ShareTips.Params = self.Params
	UIUtil.SetIsVisible(self.ShareTips, self.ViewModel.ShareTipsVisiable)
	self:SetBtnState()
	if MsgBody and MsgBody.Reward then
		local Params = {}
		local Rewards = {}
		table.insert(Rewards, {ResID = self.ViewModel.RewardItemID, Num = self.ViewModel.RewardSlotNum})
		Params.ShowBtn = false
		Params.ItemList = Rewards
		_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, Params)
	end
end

function OpsVersionNoticeMainPanelView:SetPosterCDNPic()
    local PanelConfigs = {
        { Visible = "Panel1Visiable", Posters = { "Panel1ImgPoster1" }, Count = 1 },
        { Visible = "Panel2Visiable", Posters = { "Panel2ImgPoster1", "Panel2ImgPoster2" }, Count = 2 },
        { Visible = "Panel3Visiable", Posters = { "Panel3ImgPoster1", "Panel3ImgPoster2", "Panel3ImgPoster3" }, Count = 3 },
        { Visible = "Panel4Visiable", Posters = { "Panel4ImgPoster1", "Panel4ImgPoster2", "Panel4ImgPoster3", "Panel4ImgPoster4" }, Count = 4 }
    }

    for _, Config in ipairs(PanelConfigs) do
        if self.ViewModel[Config.Visible] then
            for i = 1, Config.Count do
                local PosterUrl = self.ViewModel[Config.Posters[i]]
                if PosterUrl then
                    self:ProcessPoster(Config.Count, i, PosterUrl)
                end
            end
            break
        end
    end
end

function OpsVersionNoticeMainPanelView:ProcessPoster(PanelNum, PosterNum, PosterUrl)
    local IsWebImage = string.match(PosterUrl, "http")
    local ImgWidget = self:GetPosterWidget(PanelNum, PosterNum)

    if not ImgWidget then return end

    if IsWebImage then
        self:SetUrlPic(PosterUrl, PanelNum, PosterNum)
    else
        UIUtil.ImageSetBrushFromAssetPath(ImgWidget, PosterUrl)
    end
end

function OpsVersionNoticeMainPanelView:GetPosterWidget(panelNum, posterNum)
    local PosterMap = {
        [1] = { self.ImgPoster },
        [2] = { self.PosterM1.ImgPoster, self.PosterM2.ImgPoster },
        [3] = { self.PosterM3.ImgPoster, self.PosterS1.ImgPoster, self.PosterS2.ImgPoster },
        [4] = { self.PosterS01.ImgPoster, self.PosterS02.ImgPoster, self.PosterS03.ImgPoster, self.PosterS04.ImgPoster }
    }

    local Panel = PosterMap[panelNum]
    return Panel and Panel[posterNum] or nil
end


function OpsVersionNoticeMainPanelView:SetUrlPic(Url, PanelNum, PosterNum)
	local ImgWidget = self:GetPosterWidget(PanelNum, PosterNum)
    if nil == ImgWidget then
        return
    end

	if string.isnilorempty(Url) then
		return
	end

    local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("OpsVersionNoticCDNPoster", true, 100)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
		function(_, texture)
			if texture then
				UIUtil.ImageSetBrushResourceObject(ImgWidget, texture)
				UIUtil.SetIsVisible(ImgWidget, true)
			end
		end
    )

    ImageDownloader.OnFail:Add(ImageDownloader,
		function()
			UIUtil.SetIsVisible(ImgWidget, false)
		end
	)

    ImageDownloader:Start(Url, "", true)
	self.ImageDownloader = ImageDownloader
end

return OpsVersionNoticeMainPanelView