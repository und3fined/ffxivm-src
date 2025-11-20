---
--- Author: muyanli
--- DateTime: 2025-06-26 16:11
--- Description:
---
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local HouseOthersInfoPanelViewVM = require("Game/House/VM/HouseOthersInfoPanelViewVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GroupEmblemTotemCfg = require("TableCfg/GroupEmblemTotemCfg")
local GroupEmblemBackgroundCfg = require("TableCfg/GroupEmblemBackgroundCfg")
local GroupEmblemIconCfg = require("TableCfg/GroupEmblemIconCfg")
local CommonUtil = require("Utils/CommonUtil")
local EToggleButtonState = _G.UE.EToggleButtonState
local HouseBaseView = require("Game/House/View/ViewBase/HouseInfoViewBase")
local ProtoCS = require("Protocol/ProtoCS")

---@class HouseOthersInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTeleport CommBtnLView
---@field CloseBtn CommonCloseBtnView
---@field CommEmpty CommBackpackEmptyView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field HouseInfoHomeowner1 HouseInfoHomeownerItemView
---@field HouseInfoHomeowner2 HouseInfoHomeownerItemView
---@field IconHouse UFImage
---@field ImgLocation UFImage
---@field ImgPaper UFImage
---@field ImgPhoto UFImage
---@field PanelMain UFCanvasPanel
---@field TableViewRoommate UTableView
---@field TableViewTag UTableView
---@field TextGreetingContent UFTextBlock
---@field TextGreetingContentEmpty UFTextBlock
---@field TextGreetings UFTextBlock
---@field TextHouseName UFTextBlock
---@field TextLikes UFTextBlock
---@field TextLocation UFTextBlock
---@field TextNoTag UFTextBlock
---@field TextTag UFTextBlock
---@field ToggleBtnLike UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseOthersInfoPanelView = LuaClass(HouseBaseView, true)

function HouseOthersInfoPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnTeleport = nil
    -- self.CloseBtn = nil
    -- self.CommEmpty = nil
    -- self.CommonBkg02_UIBP = nil
    -- self.CommonBkgMask_UIBP = nil
    -- self.CommonTitle = nil
    -- self.HouseInfoHomeowner1 = nil
    -- self.IconHouse = nil
    -- self.ImgLocation = nil
    -- self.ImgPhoto = nil
    -- self.TableViewRoommate = nil
    -- self.TableViewTag = nil
    -- self.TextGreetingContent = nil
    -- self.TextGreetings = nil
    -- self.TextHouseName = nil
    -- self.TextLikes = nil
    -- self.TextLocation = nil
    -- self.TextTag = nil
    -- self.ToggleBtnLike = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseOthersInfoPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnTeleport)
    self:AddSubView(self.CloseBtn)
    self:AddSubView(self.CommEmpty)
    self:AddSubView(self.CommonBkg02_UIBP)
    self:AddSubView(self.CommonBkgMask_UIBP)
    self:AddSubView(self.CommonTitle)
    self:AddSubView(self.HouseInfoHomeowner1)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseOthersInfoPanelView:OnInit()
    self.IsLike = false
    self.ViewModel = HouseOthersInfoPanelViewVM.New()
    self.TableViewRoommateAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRoommate)
    self.TableViewTagAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTag)
    self.Binders = {
            {"RoommateTableList", UIBinderUpdateBindableList.New(self, self.TableViewRoommateAdapter)},
            {"RoommateVisibility", UIBinderSetIsVisible.New(self, self.TableViewRoommate)},
            {"HouseTagList", UIBinderUpdateBindableList.New(self, self.TableViewTagAdapter)},
            {"TextHouseName", UIBinderSetText.New(self, self.TextHouseName)},
            {"TextLocation", UIBinderSetText.New(self, self.TextLocation)},
            {"TextGreetingContent", UIBinderSetText.New(self, self.TextGreetingContent)},
            {"TextGreetingContentEmptyVisible", UIBinderSetIsVisible.New(self, self.TextGreetingContentEmpty)},
            {"TextNoTagVisible", UIBinderSetIsVisible.New(self, self.TextNoTag)},
            {"TextLikes", UIBinderSetText.New(self, self.TextLikes)},
            {"ImgPhoto", UIBinderSetBrushFromAssetPath.New(self, self.ImgPhoto)},
            {"ImgPhotoVisibility", UIBinderSetIsVisible.New(self, self.ImgPhoto)},
            {"CanVisitEnter", UIBinderSetIsVisible.New(self, self.BtnTeleport)},
            {"CanBrowser", UIBinderSetIsVisible.New(self, self.PanelMain)},
            {"IconHouse", UIBinderSetBrushFromAssetPath.New(self, self.IconHouse)},
            {"TeleportText", UIBinderSetText.New(self, self.BtnTeleport.TextContent)},
        }

    self.CommonTitle:SetTextTitleName(HouseLocalDef.LocalTxtStr.HouseInfoTitle)
    self.BtnTeleport:SetText(HouseLocalDef.LandInfoStr.Transmit)
    self.TextGreetings:SetText(HouseLocalDef.LocationInfoStr.TextGeeting)
    self.TextGreetingContentEmpty:SetText(HouseLocalDef.LocalTxtStr.TextGreetingContentEmpty)
    self.TextTag:SetText(HouseLocalDef.LocationInfoStr.TextTag)
    self.TextNoTag:SetText(HouseLocalDef.LocalTxtStr.TextNoTag)
end

function HouseOthersInfoPanelView:OnShow()
    if self.Params and self.ViewModel then
        self.ViewModel.HouseID = self.Params.HouseID
        _G.HouseInfoMgr:SendHouseDetailInfo(self.Params.HouseID)
    end
end 

function HouseOthersInfoPanelView:OnHide()
    self.Super.OnHide(self)
end

function HouseOthersInfoPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnTeleport, self.OnBtnTransmitClick)
    UIUtil.AddOnClickedEvent(self, self.ToggleBtnLike, self.OnBtnLikeClick)
end

function HouseOthersInfoPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.HouseDetailInfoUpdate, self.OnHouseInfoUpdate)
    self:RegisterGameEvent(_G.EventID.DoLikeRsp, self.OnHouseDolikeRsp)
end

function HouseOthersInfoPanelView:UpdateView()
    self.ViewModel:UpdateRoommate()
    self:UpdateLikeToggleState()
    self:UpdatePhotoShow()
    self:SetOwnerRoleID()
end

function HouseOthersInfoPanelView:UpdatePhotoShow()
    local NoPic = not self.ViewModel.PicUrl or self.ViewModel.PicUrl == ""
    local EmptyTextTips = ""
    if self.ViewModel.CanBrowser and NoPic then
        EmptyTextTips = HouseLocalDef.LocalTxtStr.HouseNoPhoto
    end

    if not self.ViewModel.CanBrowser then 
        EmptyTextTips = HouseLocalDef.LocalTxtStr.HouseCannotBrowser
    end

    UIUtil.SetIsVisible(self.ImgPhoto, not NoPic)
	if NoPic or not self.ViewModel.CanBrowser then
		self.CommEmpty:SetTipsContent(HouseLocalDef.HouseNoPic)
        UIUtil.SetIsVisible(self.ImgPaper, false)
        UIUtil.SetIsVisible(self.CommEmpty, true)
	else
		local Icon = "MaterialInstanceConstant'/Game/UI/Material/UI_Desaturate_House.UI_Desaturate_House'"
		UIUtil.ImageSetBrushFromAssetPath(self.ImgPhoto, Icon)
		self:DownloadPic(self.ViewModel.PicUrl, self.ImgPhoto)
        UIUtil.SetIsVisible(self.ImgPaper, true)
        UIUtil.SetIsVisible(self.CommEmpty, false)
	end

    self.CommEmpty:SetTipsContent(EmptyTextTips)
end

function HouseOthersInfoPanelView:UpdateLikeToggleState()
    local IsLike = _G.HouseInfoMgr:IsCurHouseHasLiked(self.ViewModel.HouseID)
    self.ToggleBtnLike:SetCheckedState(IsLike and EToggleButtonState.Checked or  EToggleButtonState.Unchecked)
    self.IsLike = IsLike
end

function HouseOthersInfoPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function HouseOthersInfoPanelView:OnHouseInfoUpdate(HouseInfo)
    local Basic = HouseInfo and HouseInfo.Basic or {}
    if self.ViewModel and self.ViewModel.HouseID == (Basic.HouseID or 0) then
        self.ViewModel:UpdateVM(HouseInfo)
        self:UpdateView()
    end
end

function HouseOthersInfoPanelView:OnHouseDolikeRsp(DoLikeData)
    if self.ViewModel and self.ViewModel.HouseID == DoLikeData.HouseID then
        local Num = self.ViewModel.TextLikes
        if DoLikeData.IsLike then
            self.ViewModel:SetDolikeNum(Num + 1)
        else
            self.ViewModel:SetDolikeNum(Num - 1)
        end

        self:UpdateLikeToggleState()
    end
end

function HouseOthersInfoPanelView:OnBtnTransmitClick()
    if self.ViewModel ~= nil then
        if self.ViewModel.HouseType == ProtoCS.HouseType.HouseType_HouseType_GroupMemberRoom then
            local Params = {
                HouseID = self.ViewModel.HouseID,
            }
            _G.HouseLandMgr:SendLandTransmit(HouseLocalDef.LandTransmitType.Room, Params)
        else
            _G.HouseInfoMgr:TransToHouse(self.ViewModel.HouseID, self.ViewModel.Addr, self.ViewModel.EtherGid, self.ViewModel.WorldID)
        end
    
        self:Hide()
    end
end

function HouseOthersInfoPanelView:SetOwnerRoleID()
    UIUtil.SetIsVisible(self.HouseInfoHomeowner2, false)
    local OwnerID = self.ViewModel and self.ViewModel.OwnerID
    if OwnerID and OwnerID ~= 0 then
        if self.ViewModel.HouseType == ProtoCS.HouseType.HouseType_HouseType_Personal or self.ViewModel.HouseType == ProtoCS.HouseType.HouseType_HouseType_GroupMemberRoom  then
            self.HouseInfoHomeowner1:UpdateView(nil, OwnerID, HouseLocalDef.HouseInfoStr.OwnerText)
        else
            if _G.ArmyMgr.SelfArmyID == OwnerID and _G.ArmyMgr.SelfArmyID > 0 then
                self:UpdateMyArmyInfo()
            else
                _G.ArmyMgr:QueryArmySimple(OwnerID, function(VM)
                    self.HouseInfoHomeowner1:UpdateView("", VM.LeaderID, HouseLocalDef.HouseInfoStr.ArmyOwnerText)
                    UIUtil.SetIsVisible(self.HouseInfoHomeowner2, true)
                    self.HouseInfoHomeowner2.TextTittle:SetText(HouseLocalDef.HouseInfoStr.ArmyText)
                    local ArmyName = CommonUtil.GetTextFromStringWithSpecialCharacter(VM.Name .. " <10006>" .. VM.ShortName .. "<10007>")
                    local TotemIconPath = GroupEmblemTotemCfg:GetEmblemTotemIconByID(VM.Emblem.TotemID)
                    local EmblemIconPath = GroupEmblemIconCfg:GetEmblemIconByID(VM.Emblem.IconID)
                    local ColorHex = GroupEmblemBackgroundCfg:GetEmblemBgColorByID(VM.Emblem.BackgroundID)
                    self.HouseInfoHomeowner2:SetArmy(ArmyName, TotemIconPath, EmblemIconPath, ColorHex)
                end)
            end
        end
    end
end

function HouseOthersInfoPanelView:OnBtnLikeClick()
    local CurHouseID = self.ViewModel.HouseID
    if _G.HouseInfoMgr.ArmyHouseID ~= CurHouseID and _G.HouseInfoMgr.MajorHouseID ~= CurHouseID and _G.HouseInfoMgr.SharedHouseID ~= CurHouseID then
        _G.HouseLandMgr:SendDoLikeReq(self.ViewModel.HouseID, not self.IsLike)
    else
        local MsgTipsUtil = require("Utils/MsgTipsUtil")
        MsgTipsUtil.ShowTips(HouseLocalDef.HouseInfoStr.DoLikeText)
        self.ToggleBtnLike:SetCheckedState(_G.UE.EToggleButtonState.Unchecked)
    end
end

return HouseOthersInfoPanelView
