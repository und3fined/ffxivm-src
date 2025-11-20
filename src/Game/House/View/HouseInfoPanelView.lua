---
--- Author: mingyyzhang
--- DateTime: 2025-06-13 16:50
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseInfoPanelVM = require("Game/House/VM/HouseInfoPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local ProtoRes = require("Protocol/ProtoRes")
local GroupPermissionType = ProtoRes.GroupPermissionType
local HouseBaseView = require("Game/House/View/ViewBase/HouseInfoViewBase")
local ProtoCS = require("Protocol/ProtoCS")

---@class HouseInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnPhotograph UFButton
---@field BtnSettings CommBtnLView
---@field BtnTeleport CommBtnLView
---@field CommBackpackEmpty_UIBP CommBackpackEmptyView
---@field HouseInfoHomeowner1 HouseInfoHomeownerItemView
---@field HouseInfoHomeowner2 HouseInfoHomeownerItemView
---@field ImgAudit UFImage
---@field ImgPhoto UFImage
---@field PanelAuditTag UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelLoading UFCanvasPanel
---@field PanelRemakeTag UFCanvasPanel
---@field TableViewRoommate UTableView
---@field TableViewTag UTableView
---@field TextAudit UFTextBlock
---@field TextGreetingContent UFTextBlock
---@field TextGreetings UFTextBlock
---@field TextHouseName UFTextBlock
---@field TextLikes UFTextBlock
---@field TextLoading UFTextBlock
---@field TextLocation UFTextBlock
---@field TextRemake UFTextBlock
---@field TextTag UFTextBlock
---@field ToggleBtnLike UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoPanelView = LuaClass(HouseBaseView, true)
local LSTR = _G.LSTR
local EToggleButtonState = _G.UE.EToggleButtonState

function HouseInfoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnPhotograph = nil
	--self.BtnSettings = nil
	--self.BtnTeleport = nil
	--self.CommBackpackEmpty_UIBP = nil
	--self.HouseInfoHomeowner1 = nil
	--self.HouseInfoHomeowner2 = nil
	--self.ImgAudit = nil
	--self.ImgPhoto = nil
	--self.PanelAuditTag = nil
	--self.PanelEmpty = nil
	--self.PanelLoading = nil
	--self.PanelRemakeTag = nil
	--self.TableViewRoommate = nil
	--self.TableViewTag = nil
	--self.TextAudit = nil
	--self.TextGreetingContent = nil
	--self.TextGreetings = nil
	--self.TextHouseName = nil
	--self.TextLikes = nil
	--self.TextLoading = nil
	--self.TextLocation = nil
	--self.TextRemake = nil
	--self.TextTag = nil
	--self.ToggleBtnLike = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnSettings)
	self:AddSubView(self.BtnTeleport)
	self:AddSubView(self.CommBackpackEmpty_UIBP)
	self:AddSubView(self.HouseInfoHomeowner1)
	self:AddSubView(self.HouseInfoHomeowner2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoPanelView:OnInit()
	self.ViewModel = HouseInfoPanelVM.New()
	self.RoommatesTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRoommate)
	self.TagListTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTag)
	self.TagViewListTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTag)
	self.Binders = {
		{"RoommateTableList", UIBinderUpdateBindableList.New(self, self.RoommatesTableViewAdapter)},
		{"RoommateVisibility", UIBinderSetIsVisible.New(self, self.TableViewRoommate) },
		{"PanelLoadingVisibility", UIBinderSetIsVisible.New(self, self.PanelLoading) },
		{"HouseInfoHomeowner2Visibility", UIBinderSetIsVisible.New(self, self.HouseInfoHomeowner2) },
		{"PanelAuditTagVisibility", UIBinderSetIsVisible.New(self, self.PanelAuditTag) },
		{"GreetingsTittle", UIBinderSetText.New(self, self.TextGreetings) },
		{"HouseGreet", UIBinderSetText.New(self, self.TextGreetingContent) },
		{"TextTag", UIBinderSetText.New(self, self.TextTag) },
		{"LikesCount", UIBinderSetText.New(self, self.TextLikes) },
		{"HouseName", UIBinderSetText.New(self, self.TextHouseName) },
		{"HouseLoc", UIBinderSetText.New(self, self.TextLocation) },
		{"TextRemake", UIBinderSetText.New(self, self.TextRemake) },
		{"TeleportText", UIBinderSetText.New(self, self.BtnTeleport.TextContent)},
	}

	self.CommBackpackEmpty_UIBP:SetBtnText(HouseLocalDef.HouseInfoStr.PictureText)
	self.CommBackpackEmpty_UIBP:SetTipsContent(HouseLocalDef.HouseInfoStr.TipsText)
	self.ToggleBtnLike:SetCheckedState(EToggleButtonState.Locked)
	self.TextLoading:SetText(HouseLocalDef.HousePicLoading)
end

function HouseInfoPanelView:OnDestroy()

end

function HouseInfoPanelView:OnShow()
	self:SendNetMessage()
end

function HouseInfoPanelView:OnHide()
	self.Super.OnHide(self)
end

function HouseInfoPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnLike, self.OnToggleButtonStateChanged)
	-- UIUtil.AddOnClickedEvent(self, self.ToggleBtnLike, self.OnToggleButtonClick)  目前不可以给自己的房屋点赞
	UIUtil.AddOnClickedEvent(self, self.BtnSettings, self.OnClickSetting)
	UIUtil.AddOnClickedEvent(self, self.BtnTeleport, self.OnClickTeleport)
	UIUtil.AddOnClickedEvent(self, self.CommBackpackEmpty_UIBP.Btn, self.OnClickPicture)
	UIUtil.AddOnClickedEvent(self, self.BtnPhotograph, self.OnClickPicture)
end

function HouseInfoPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.HouseRoleInfoUpdate, self.OnHouseRoleInfoUpdate)
	self:RegisterGameEvent(_G.EventID.HouseGroupInfoUpdate, self.OnHouseGroupInfoUpdate)
	self:RegisterGameEvent(_G.EventID.HouseDetailInfoUpdate, self.OnHouseDetailInfoUpdate)
	self:RegisterGameEvent(_G.EventID.HousePullMajorMemberRoom, self.OnHouseMajorMemberInfoUpdate)
	self:RegisterGameEvent(_G.EventID.HousePicUploadFinish, self.OnShow)
	self:RegisterGameEvent(_G.EventID.HouseInfoModifyRsp, self.OnShow)
	self:RegisterGameEvent(_G.EventID.HouseCreateMemberRoom, self.OnCreateRoomSuc)
	self:RegisterGameEvent(_G.EventID.HousePrivilegeModifyRsp, self.IsHousePrivilegeModifySuc)
	self:RegisterGameEvent(_G.EventID.HouseDissolveRoom, self.OnHouseDissolveRoom)  --房主解除室友
	self:RegisterGameEvent(_G.EventID.HouseBeDissolveRoomNtf, self.OnUpdateRoommate) --室友解除共享
	--self:RegisterGameEvent(_G.EventID.HouseInviteReplyNtf, self.OnUpdateRoommate) --室友邀请反馈
end

function HouseInfoPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end


function HouseInfoPanelView:UpdatePhotoShow()
	UIUtil.SetIsVisible(self.PanelRemakeTag, false)
	self.CommBackpackEmpty_UIBP:ShowPanelBtn(false)
	self.ViewModel.PanelLoadingVisibility = false
	---- 不存在照片 可以拍照(共享房屋室友不可拍 没权限的部队成员不可)
	if not self.ViewModel.PicUrl or self.ViewModel.PicUrl == "" then
		UIUtil.SetIsVisible(self.PanelEmpty, true)
		self.CommBackpackEmpty_UIBP:SetTipsContent(HouseLocalDef.HouseNoPic)
		if _G.HouseMineMainPanelVM.PageNum ~= 5 then     
			self.CommBackpackEmpty_UIBP:ShowPanelBtn(true)
		end

		if _G.HouseMineMainPanelVM.PageNum == 2 then
			if _G.ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.PermissionTypeEstateSetDisplayPicture) then
				self.CommBackpackEmpty_UIBP:ShowPanelBtn(true)
			else
				self.CommBackpackEmpty_UIBP:ShowPanelBtn(false)
			end
		end

		self.CommBackpackEmpty_UIBP:SetBtnText(HouseLocalDef.HouseGetPic)
		UIUtil.SetIsVisible(self.ImgPhoto, false)
	else
		local Icon = "MaterialInstanceConstant'/Game/UI/Material/UI_Desaturate_House.UI_Desaturate_House'"
		UIUtil.ImageSetBrushFromAssetPath(self.ImgPhoto, Icon)
		UIUtil.SetIsVisible(self.PanelEmpty, false)
		self:DownloadPic(self.ViewModel.PicUrl, self.ImgPhoto, self.TextLoading)
		if _G.HouseMineMainPanelVM.PageNum ~= 5 then       
			UIUtil.SetIsVisible(self.PanelRemakeTag, true) 
		end

		if _G.HouseMineMainPanelVM.PageNum == 2 then
			if _G.ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.PermissionTypeEstateSetDisplayPicture) then
				UIUtil.SetIsVisible(self.PanelRemakeTag, true)
			else
				UIUtil.SetIsVisible(self.PanelRemakeTag, false)
			end
		end
	end
end

function HouseInfoPanelView:UpdateView()
	self:UpdatePhotoShow()
	self.ViewModel:UpdateRoommate()                                --更新室友列表
	self.ViewModel:UpdateTagList()								--更新tag
	local RoleID = self.ViewModel.OwnerID
	_G.RoleInfoMgr:QueryRoleSimple(RoleID, function()
		local RoleVM, IsValid = _G.RoleInfoMgr:FindRoleVM(RoleID, true)
		if RoleVM and self.ViewModel.OwnerID == RoleID then
			self.ViewModel.HouseOwnerName = RoleVM.Name
		end
	end, nil, true)
	self.TagListTableViewAdapter:UpdateAll(self.ViewModel.ShowTagList)
	table.clear(self.ViewModel.ShowTagList)
	if _G.HouseMineMainPanelVM.PageNum ~= 2 then       --部队长信息在部队信息获取回调中设置
		self.HouseInfoHomeowner1:UpdateView(nil, self.ViewModel.OwnerID, self.OwnerTittle)
	else
		self:UpdateMyArmyInfo()
	end
end

function HouseInfoPanelView:OnToggleButtonStateChanged(ToggleButton, State)
	if State == EToggleButtonState.Locked then
		MsgTipsUtil.ShowTips(HouseLocalDef.HouseInfoStr.DoLikeText)
	end
end

function HouseInfoPanelView:OnClickSetting()
	if _G.HouseMineMainPanelVM.PageNum == 5 then          --共享房屋解除共享
		local function RCallback()
			_G.HouseInfoMgr:SendDissolveRoom(self.ViewModel.HouseID)
		end
		local function LCallback()
			_G.MsgBoxUtil.CloseMsgBox()
		end
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(
			self,
			HouseLocalDef.HouseDissolveBoxStr.Tittle,
			string.format(HouseLocalDef.HouseDissolveBoxStr.Content, self.ViewModel.HouseOwnerName),
			RCallback,
			LCallback
		)
	else                                              --打开房屋设置
	   local Params = {
		HouseID = self.ViewModel.HouseID,
		IsGroup = _G.HouseMineMainPanelVM.PageNum == 2,
		TagTable = self.ViewModel.TagTable,
		VisitPrivilege = self.ViewModel.VisitPrivilege,
		HouseGreet = self.ViewModel.HouseGreet,
		Roommates = self.ViewModel.Roommates,
		HouseName = self.ViewModel.HouseName,
		HouseType = self.ViewModel.HouseType,
		OwnerID = self.ViewModel.OwnerID
	}
		_G.UIViewMgr:ShowView(_G.UIViewID.HouseInfoSettingsWinView,Params)
	end
end

function HouseInfoPanelView:OnHouseRoleInfoUpdate(MsgBody)
	self.ViewModel:HouseRoleInfoUpdate(MsgBody, 1)
	self:UpdateView()
end

function HouseInfoPanelView:OnHouseGroupInfoUpdate(MsgBody)
	self.ViewModel:HouseGroupInfoUpdate(MsgBody)
	self:UpdateView()
end

function HouseInfoPanelView:OnHouseDetailInfoUpdate(MsgBody)
	self.ViewModel:HouseRoleInfoUpdate(MsgBody, 3)
	self:UpdateView()
end

function HouseInfoPanelView:OnHouseMajorMemberInfoUpdate(MsgBody)
	if MsgBody and MsgBody.RoomDetail and _G.HouseMineMainPanelVM.PageNum == 3 then
		self.ViewModel:HouseRoleInfoUpdate(MsgBody.RoomDetail, 2, MsgBody.Index)
		self:UpdateView()
	end
end

--发送网络包更新内容
function HouseInfoPanelView:SendNetMessage()
	UIUtil.SetIsVisible(self.BtnSettings, true, true)
	self.OwnerTittle = ""
	self.ViewModel.HouseInfoHomeowner2Visibility = false
	if _G.HouseMineMainPanelVM.PageNum == 0 then               --个人信息界面
		if self.ViewModel.HouseID == 0 then
			_G.HouseMineMainPanelVM.CommEmptyVisibility = true
			_G.HouseMineMainPanelVM.InfoPanelVisibility = false
		else
			_G.HouseMineMainPanelVM.CommEmptyVisibility = false
			_G.HouseInfoMgr:SendHouseRoleInfo()
			UIUtil.SetIsVisible(self.PanelEmpty, false)
			self.ViewModel.RoommateVisibility = true
			self.BtnSettings:SetButtonText(HouseLocalDef.HouseInfoStr.HouseSettingText)
			self.OwnerTittle = HouseLocalDef.HouseInfoStr.OwnerText
		end
	elseif _G.HouseMineMainPanelVM.PageNum == 2 then           --部队房屋界面
		local ArmyID = _G.ArmyMgr:GetArmyID()
		if ArmyID == 0 then
			_G.HouseMineMainPanelVM.CommEmptyVisibility = true
			_G.HouseMineMainPanelVM.InfoPanelVisibility = false
		else
			_G.HouseMineMainPanelVM.CommEmptyVisibility = false
			self.OwnerTittle = HouseLocalDef.HouseInfoStr.ArmyOwnerText
			self.ViewModel.RoommateVisibility = false
			self.ViewModel.HouseInfoHomeowner2Visibility = true
			self.HouseInfoHomeowner2.TextTittle:SetText(HouseLocalDef.HouseInfoStr.ArmyText)
			local IsShowBtn = _G.ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.PermissionTypeEstateGuestAccessAndTagSettings) or 
			_G.ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.PermissionTypeEstateEditNameAndGreeting) 
			UIUtil.SetIsVisible(self.BtnSettings, IsShowBtn, IsShowBtn)
			self.BtnSettings:SetButtonText(HouseLocalDef.HouseInfoStr.HouseSettingText)
			_G.HouseInfoMgr:SendGroupHouseInfo(ArmyID)
		end
	elseif _G.HouseMineMainPanelVM.PageNum == 3 then             --部队个人房间
		local ArmyID = _G.ArmyMgr:GetArmyID()
		self.OwnerTittle = HouseLocalDef.HouseInfoStr.OwnerText
		if ArmyID == 0 then
			_G.HouseMineMainPanelVM.CommEmptyVisibility = true
			_G.HouseMineMainPanelVM.InfoPanelVisibility = false
			--_G.EventMgr:SendEvent(_G.EventID.HousePullMajorMemberRoom, nil)
		else
			local ArmyLevel = _G.ArmyMgr:GetArmyLevel()
			if ArmyLevel and ArmyLevel < 10 then   
				_G.HouseMineMainPanelVM.CommEmptyVisibility = true
				_G.HouseMineMainPanelVM.InfoPanelVisibility = false
			else
				_G.HouseInfoMgr:SendPullMajorMemberRoom(ArmyID)
			end
		end
	elseif _G.HouseMineMainPanelVM.PageNum == 5 then          --共享房屋界面
		_G.HouseMineMainPanelVM.CommEmptyVisibility = false
		if _G.HouseInfoMgr.SharedHouseID then
			_G.HouseInfoMgr:SendHouseDetailInfo(_G.HouseInfoMgr.SharedHouseID)
			self.ViewModel.RoommateVisibility = true
			self.OwnerTittle = HouseLocalDef.HouseInfoStr.OwnerText
			self.BtnSettings:SetButtonText(HouseLocalDef.HouseInfoStr.DisSolveShare)
		end
	end
end

function HouseInfoPanelView:OnHouseDissolveRoom(MsgBody)
	MsgTipsUtil.ShowTips(string.format(HouseLocalDef.RoommatesSettingInfoStr.UnShareTipsOwner, self.ViewModel.HouseOwnerName))
end

function HouseInfoPanelView:OnCreateRoomSuc(MsgBody)
	self:OnShow()
end

function HouseInfoPanelView:OnClickPicture()
	local HouseID = self.ViewModel.HouseID
	local Params = {
		HouseID = HouseID,
		Url = self.ViewModel.PicUrl and self.ViewModel.PicUrl or nil
	}
	_G.PhotoMgr:OpenPhotoAndLogCropType(PhotoDefine.UIEditCropType.House, Params)
end

function HouseInfoPanelView:OnUpdateRoommate(MsgBody)
	self:OnShow()
end

function HouseInfoPanelView:IsHousePrivilegeModifySuc(MsgBody)
	if MsgBody and MsgBody.Setting then
		if MsgBody and MsgBody.Setting and MsgBody.HouseID == self.ViewModel.HouseID then
			self.ViewModel.VisitPrivilege = MsgBody.Setting
		end
	end
end

function HouseInfoPanelView:OnClickTeleport()
	if not self.ViewModel then return end
	if self.ViewModel.HouseType and self.ViewModel.HouseType == ProtoCS.HouseType.HouseType_HouseType_GroupMemberRoom then
        local Params = {
            HouseID = self.ViewModel.HouseID,
        }
        _G.HouseLandMgr:SendLandTransmit(HouseLocalDef.LandTransmitType.Room, Params)
	else
		_G.HouseInfoMgr:TransToHouse(self.ViewModel.HouseID, self.ViewModel.Addr, self.ViewModel.EtherGid, self.ViewModel.WorldID)
	end

	_G.UIViewMgr:HideView(_G.UIViewID.HouseLandMianPanelView)
end

return HouseInfoPanelView