---
--- Author: xingcaicao
--- DateTime: 2023-05-18 21:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PWorldQuestUtil = require("Game/PWorld/Quest/PWorldQuestUtil")
local TipsUtil = require("Utils/TipsUtil")
local UE = _G.UE
local ChatDefine = require("Game/Chat/ChatDefine")
local MakeLSTRAttrKey = require("Common/StringTools").MakeLSTRAttrKey
local MakeLSTRDict = require("Common/StringTools").MakeLSTRDict

local LSTR = _G.LSTR

---@class TeamRecruitDetailView : UIView
---@field ViewModel TeamRecruitDetailVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMaskProfDescTips UFButton
---@field BtnRecruit CommBtnLView
---@field BtnReport UFButton
---@field BtnReset CommBtnLView
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field CommInforBtn CommInforBtnView
---@field FCanvasPanel_89 UFCanvasPanel
---@field IconCrossServer UFImage
---@field ImgBg2 UFImage
---@field ImgBgLight UFImage
---@field ImgFrame1 UFImage
---@field ImgFrame2 UFImage
---@field ImgLimit UFImage
---@field ImgOnlineStatus2 UFImage
---@field ImgTypeIcon UFImage
---@field ImgUnlock UFImage
---@field ImgUnlock_1 UFImage
---@field PanelCode UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field PanelEquipLv UFCanvasPanel
---@field PanelPass UFCanvasPanel
---@field PanelProf UFCanvasPanel
---@field PanelRecruit UFCanvasPanel
---@field PanelReward UFCanvasPanel
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field RichTextBox URichTextBox
---@field TableViewLocProf UTableView
---@field TextClear UFTextBlock
---@field TextComment UFTextBlock
---@field TextContent UFTextBlock
---@field TextContentDesc UFTextBlock
---@field TextLimit UFTextBlock
---@field TextLv UFTextBlock
---@field TextLv2 UFTextBlock
---@field TextNone UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextProf UFTextBlock
---@field TextRecruit UFTextBlock
---@field TextRecruitSetting UFTextBlock
---@field TextReward UFTextBlock
---@field TextSetPassword UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimProfDescTipsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitDetailView = LuaClass(UIView, true)

function TeamRecruitDetailView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMaskProfDescTips = nil
	--self.BtnRecruit = nil
	--self.BtnReport = nil
	--self.BtnReset = nil
	--self.Comm2FrameL_UIBP = nil
	--self.CommInforBtn = nil
	--self.FCanvasPanel_89 = nil
	--self.IconCrossServer = nil
	--self.ImgBg2 = nil
	--self.ImgBgLight = nil
	--self.ImgFrame1 = nil
	--self.ImgFrame2 = nil
	--self.ImgLimit = nil
	--self.ImgOnlineStatus2 = nil
	--self.ImgTypeIcon = nil
	--self.ImgUnlock = nil
	--self.ImgUnlock_1 = nil
	--self.PanelCode = nil
	--self.PanelContent = nil
	--self.PanelEquipLv = nil
	--self.PanelPass = nil
	--self.PanelProf = nil
	--self.PanelRecruit = nil
	--self.PanelReward = nil
	--self.PlayerHeadSlot = nil
	--self.RichTextBox = nil
	--self.TableViewLocProf = nil
	--self.TextClear = nil
	--self.TextComment = nil
	--self.TextContent = nil
	--self.TextContentDesc = nil
	--self.TextLimit = nil
	--self.TextLv = nil
	--self.TextLv2 = nil
	--self.TextNone = nil
	--self.TextPlayerName = nil
	--self.TextProf = nil
	--self.TextRecruit = nil
	--self.TextRecruitSetting = nil
	--self.TextReward = nil
	--self.TextSetPassword = nil
	--self.AnimIn = nil
	--self.AnimProfDescTipsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitDetailView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnRecruit)
	self:AddSubView(self.BtnReset)
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitDetailView:OnPostInit()
	self.TableAdapterLocProf = UIAdapterTableView.CreateAdapter(self, self.TableViewLocProf, self.OnSelectProfChanged)

	local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
	self.Binders = {
		{ "TypeIcon", 			UIBinderSetImageBrush.New(self, self.ImgTypeIcon) },
		{ "ContentDesc",		UIBinderSetText.New(self, self.TextContentDesc) },
		{ "Message", 			UIBinderSetText.New(self, self.RichTextBox) },
		{ "RemainMemNumDesc", 	UIBinderSetText.New(self, self.TextRemainNum) },
		{ "EquipLv", 			UIBinderValueChangedCallback.New(self, nil, self.OnEquipLvChanged) },
		{ "IsMajor", 			UIBinderValueChangedCallback.New(self, nil, self.OnIsMajorChanged) },
		{ "SceneMode", 			UIBinderValueChangedCallback.New(self, nil, self.OnSceneModeChanged) },
		{ "HasPassword", 		UIBinderValueChangedCallback.New(self, nil, self.OnHasPasswordChanged) },
		{ "MemberProfVMList", 	UIBinderUpdateBindableList.New(self, self.TableAdapterLocProf) },
		{ "CompleteTask", 		UIBinderSetIsVisible.New(self, self.PanelPass)},
	}

	self.RoleBinders = {
		{ "Name", 		UIBinderSetText.New(self, self.TextPlayerName) },
		{ "CurWorldID", 	TeamRecruitUtil.NewCrossServerShowBinder(nil, self, self.IconCrossServer)},
	}
end

function TeamRecruitDetailView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.RecruitClose, self.OnRecruitClose)
end

function TeamRecruitDetailView:OnShow()
	self.PlayerHeadSlot:SetInfo(self:GetRecruitRoleID())
	-- UIUtil.SetIsVisible(self.ProfDescTips, false)
	UIUtil.SetIsVisible(self.BtnMaskProfDescTips, false)

	local bShowReport = self.ViewModel and self.ViewModel.RoleID ~= MajorUtil.GetMajorRoleID()
	UIUtil.SetIsVisible(self.BtnReport, bShowReport, true)

	--职能详情提示
	-- if TeamRecruitVM.ShowProfBubbleTips then
	-- 	UIUtil.SetIsVisible(self.PanelProfBubbleTips, true)
	-- 	self:RegisterTimer(self.OnTimer, 5)

	-- else
	-- 	UIUtil.SetIsVisible(self.PanelProfBubbleTips, false)
	-- end

	local bJoinable = false
	if self.ViewModel then
		local BtnSureName
		if self.ViewModel.RoleID == MajorUtil.GetMajorRoleID() or _G.TeamMgr:IsTeamMemberByRoleID(self.ViewModel.RoleID) then
			BtnSureName = _G.LSTR(1310039)
		elseif self.ViewModel.UnOpenTask or _G.TeamRecruitMgr:IsRecruiting() then
			BtnSureName = _G.LSTR(1310041)
		else
			BtnSureName = _G.LSTR(1310045)
			bJoinable = true
		end
		self.BtnRecruit:SetBtnName(BtnSureName)
	end
	
	local UIDefine = require("Define/UIDefine")
	local CommBtnColorType = UIDefine.CommBtnColorType
	self.BtnRecruit.ParamColor = (self:GetRecruitRoleID() ~= MajorUtil.GetMajorRoleID() and not TeamRecruitVM.IsRecruiting and bJoinable) and CommBtnColorType.Recommend or CommBtnColorType.Normal
	self.BtnRecruit:SetIsEnabled(bJoinable, bJoinable)

	if self.ViewModel then
		UIUtil.SetIsVisible(self.PanelReward, self.ViewModel.WeeklyAward)
	end

	self.Comm2FrameL_UIBP:SetTitleText(_G.LSTR(1310046))
	self.TextContent:SetText(_G.LSTR(1310076))
	self.TextProf:SetText(_G.LSTR(1310081))
	self.TextRecruit:SetText(_G.LSTR(1310077))
	self.TextRecruitSetting:SetText(_G.LSTR(1310084))
	self.TextComment:SetText(_G.LSTR(1310080))

	self.BtnReset:SetBtnName(_G.LSTR(1310044))
	self.TextSetPassword:SetText(LSTR(1310085))
	self.TextLv:SetText(LSTR(1310086))
	self.TextReward:SetText(LSTR(1310111))
	self.TextClear:SetText(LSTR(1310110))
end

function TeamRecruitDetailView:OnHide()
	TeamRecruitVM.ShowProfBubbleTips = false
	TeamRecruitVM:ClearCurRecruitDetailInfo()

	if UIViewMgr:IsViewVisible(UIViewID.CommStorageTipsView) then
		UIViewMgr:HideView(UIViewID.CommStorageTipsView)
		return
	end
end

function TeamRecruitDetailView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMaskProfDescTips, self.OnClickedMaskProfDescTips)
	UIUtil.AddOnClickedEvent(self, self.BtnRecruit, self.OnClickedJoin)
	UIUtil.AddOnClickedEvent(self, self.BtnReset, self.OnClickedShare)
	UIUtil.AddOnClickedEvent(self, self.BtnReport, self.OnClickReport)
end

function TeamRecruitDetailView:OnRegisterBinder()
	self.ViewModel = TeamRecruitVM.CurRecruitDetailVM
	self:RegisterBinders(self.ViewModel, self.Binders)
	self:RegisterBinders(_G.RoleInfoMgr:FindRoleVM(self.ViewModel.RoleID), self.RoleBinders)
end

function TeamRecruitDetailView:OnTimer(  )
	TeamRecruitVM.ShowProfBubbleTips = false
	-- UIUtil.SetIsVisible(self.PanelProfBubbleTips, false)
end

function TeamRecruitDetailView:OnEquipLvChanged(EquipLv)
	EquipLv = EquipLv or 0
	self.TextLv2:SetText((EquipLv > 0) and tostring(EquipLv) or LSTR(1310012))
end

function TeamRecruitDetailView:OnIsMajorChanged(IsMajor)
	-- UIUtil.SetIsVisible(self.PanelJoinBtn, false)

	-- if IsMajor then
	-- 	UIUtil.SetIsVisible(self.BtnEdit, true, true)
	-- 	UIUtil.SetIsVisible(self.BtnEndRecruit, true, true)
	-- 	return
	-- else
	-- 	UIUtil.SetIsVisible(self.BtnEdit, false)
	-- 	UIUtil.SetIsVisible(self.BtnEndRecruit, false)
	-- end

	-- if self:IsSelfRecruit(self.ViewModel.RoleID) then
	-- 	return
	-- end

	-- UIUtil.SetIsVisible(self.PanelJoinBtn, true)

	--任务是否开放(副本进入条件)
	-- if self.ViewModel.UnOpenTask then
	-- 	self.BtnJoin:SetIsEnabled(false)
	-- 	self.TextForbidTips:SetText(LSTR(1310013))
	-- 	return
	-- end

	--是否满足加入条件(装备平均品级+职位)
	-- local _, ErrJoinMsg = self:CanJoinRecruit()
	-- if ErrJoinMsg then
	-- 	self.BtnJoin:SetIsEnabled(false)
	-- 	self.TextForbidTips:SetText(ErrJoinMsg)
	-- 	return
	-- end

	--是否加入其他队伍
	-- if _G.TeamMgr:IsInTeam() then
	-- 	self.BtnJoin:SetIsEnabled(false)
	-- 	self.TextForbidTips:SetText(LSTR(1310014))
	-- 	return
	-- end

	-- self.TextForbidTips:SetText("")
	-- self.BtnJoin:SetIsEnabled(true)
end

---是否为玩家所在招募
function TeamRecruitDetailView:IsSelfRecruit( RoleID )
    return _G.TeamRecruitMgr:IsRecruiting()
end

-- function TeamRecruitDetailView:CanJoinRecruit()
-- 	--装备平均品级
-- 	local NeedLv = self.ViewModel.EquipLv or 0
-- 	if NeedLv > 0 then
-- 		local CurLv = _G.EquipmentMgr:CalculateEquipScore()
-- 		if CurLv < NeedLv then
-- 			return false, LSTR(1310015)
-- 		end
-- 	end

-- 	--剩余职位是否匹配
-- 	local bFitProf
-- 	local MProf = MajorUtil.GetMajorProfID()
-- 	for _, v in ipairs(self.ViewModel.MemberProfVMList:GetItems() or {}) do
-- 		if not v.HasRole and table.contain(v.Profs, MProf) then
-- 			bFitProf = true
-- 			break
-- 		end
-- 	end

-- 	if not bFitProf then
-- 		return bFitProf, LSTR(1310016)
-- 	end

-- 	return true
-- end

function TeamRecruitDetailView:OnSceneModeChanged(SceneMode)
	if nil == SceneMode then
		return
	end

	local Icon = PWorldQuestUtil.GetSceneModeIcon(SceneMode)
	if string.isnilorempty(Icon) then
		UIUtil.SetIsVisible(self.ImgLimit, false)

	else
		UIUtil.SetIsVisible(self.ImgLimit, true)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgLimit, Icon)
	end

	local Name = PWorldQuestUtil.GetSceneModeName(SceneMode) or ""
	self.TextLimit:SetText(Name)
end

function TeamRecruitDetailView:OnHasPasswordChanged(HasPassword)
	self.TextNone:SetText(HasPassword and LSTR(1310017) or LSTR(1310012))
end

function TeamRecruitDetailView:OnSelectProfChanged(Index, ItemData, ItemView)
	if nil == ItemData or nil == ItemView then
		return
	end

	self:OnTimer()

	--职业描述
	-- self.TextProfDetail:SetText(TeamRecruitUtil.GetRecruitProfDesc(ItemData) or "")

	-- --位置计算
	-- local ViewportPos = ItemView:GetViewportPosition() 
	-- local LocalPos = UIUtil.ViewportToLocal(self.PanelProf, ViewportPos) 
    -- LocalPos.Y = LocalPos.Y - 5

	-- UIUtil.CanvasSlotSetPosition(self.ProfDescTips, LocalPos)

	-- UIUtil.SetIsVisible(self.ProfDescTips, true)
	-- UIUtil.SetIsVisible(self.BtnMaskProfDescTips, true, true)

	-- self:PlayAnimation(self.AnimProfDescTipsIn)

	if UIViewMgr:IsViewVisible(UIViewID.CommHelpInfoTipsView) then
		UIViewMgr:HideView(UIViewID.CommHelpInfoTipsView)
	end

	--local ViewportPos = ItemView:GetViewportPosition() 
	-- local LocalPos = UIUtil.ViewportToLocal(self.PanelProf, ViewportPos)
	-- LocalPos.Y = LocalPos.Y - 5
	local Width = self.TableViewLocProf.EntryWidth
	local Height = self.TableViewLocProf.EntryHeight

	TipsUtil.ShowInfoTips(TeamRecruitUtil.GetRecruitProfDesc(ItemData) or "", ItemView, _G.UE.FVector2D( - Width  + 10, -Height / 2 + 50), _G.UE.FVector2D(0, 1), true)

	UIUtil.SetIsVisible(self.BtnMaskProfDescTips, true, true)

end

-------------------------------------------------------------------------------------------------------
--- Component CallBack

function TeamRecruitDetailView:OnClickedProfBubble()
	self:OnTimer()
end

function TeamRecruitDetailView:OnClickedMaskProfDescTips()
	if UIViewMgr:IsViewVisible(UIViewID.CommHelpInfoTipsView) then
		UIViewMgr:HideView(UIViewID.CommHelpInfoTipsView)
	end
	UIUtil.SetIsVisible(self.BtnMaskProfDescTips, false)

	self.TableAdapterLocProf:CancelSelected()
end

function TeamRecruitDetailView:OnClickedPersonInfo()
	if nil == self.ViewModel then
		return
	end

	_G.PersonInfoMgr:ShowPersonalSimpleInfoView(self.ViewModel.RoleID)
end

function TeamRecruitDetailView:OnClickedJoin()
	if nil == self.ViewModel then
		return
	end

	local RoleID = self.ViewModel.RoleID
	if nil == RoleID then
		return
	end

	local ContentID = (self.ViewModel or {}).ContentID
	if self.ViewModel.HasPassword then
		UIViewMgr:ShowView(UIViewID.TeamRecruitCode, {RoleID=RoleID, FromView=self, ContentID = ContentID})
	else
		_G.TeamRecruitMgr:TryJoinRecruit(self, RoleID, nil, ContentID)
		self:Hide()
	end
end

function TeamRecruitDetailView:OnClickedEdit()
	if nil == self.ViewModel then
		return
	end

	local ProtoCS = require("Protocol/ProtoCS")
	_G.TeamRecruitMgr:SendCloseRecruitReq(ProtoCS.Team.TeamRecruit.CloseReason.CloseReasonEdit)
	UIViewMgr:ShowView(UIViewID.TeamRecruitEdit, self.ViewModel.ServerData)

	self:Hide()
end

---@deprecated
function TeamRecruitDetailView:OnClickedEndRecruit()
	-- _G.TeamRecruitMgr:SendCloseRecruitReq()
	self:Hide()
end

-------------------------------------------------------------------------------------------------------

local ShareCommCB = function(Key, CustCB)
	CustCB()

	if UIViewMgr:IsViewVisible(UIViewID.CommStorageTipsView) then
		UIViewMgr:HideView(UIViewID.CommStorageTipsView)
		return
	end
end

local function SendRecruitCardToChat(Ty, Callback)
	TeamRecruitUtil.ShareRecruitToChat(Ty, nil, Callback)
end

local function PopShareTips(Title)
	_G.MsgTipsUtil.ShowTips(string.sformat(_G.LSTR(1310114), Title))
end

local ShareTransTB = {
	["Near"] = {
		["Item"] = MakeLSTRDict({
			[MakeLSTRAttrKey("Content")] = 1310019,
			ClickItemCallback = function()
				ShareCommCB("Near", function()
					SendRecruitCardToChat(ChatDefine.ChatChannel.Nearby, function()
						PopShareTips(_G.LSTR(1310019))
					end)
				end)
			end
		}),

		["EnableCheck"] = function()
			return _G.ChatMgr:IsInChannel(ChatDefine.ChatChannel.Nearby)
		end,

		["ChatChannel"] = ChatDefine.ChatChannel.Nearby,
	},

	["Recruit"] = {
		["Item"] = MakeLSTRDict({
			[MakeLSTRAttrKey("Content")] = 50100,
			ClickItemCallback = function()
				ShareCommCB("Recruit", function()
					SendRecruitCardToChat(ChatDefine.ChatChannel.Recruit, function()
						PopShareTips(_G.LSTR(50100))
					end)
				end)
			end
		}),

		["EnableCheck"] = function()
			return _G.ChatMgr:IsInChannel(ChatDefine.ChatChannel.Recruit)
		end,

		["ChatChannel"] = ChatDefine.ChatChannel.Recruit,
	},

	["Team"] = {
		["Item"] = MakeLSTRDict({
			[MakeLSTRAttrKey("Content")] = 1310020,
			ClickItemCallback = function()
				ShareCommCB("Team", function()
					SendRecruitCardToChat(ChatDefine.ChatChannel.Team, function()
						PopShareTips(_G.LSTR(1310020))
					end)
				end)
			end
		}),

		["EnableCheck"] = function()
			return _G.ChatMgr:IsInChannel(ChatDefine.ChatChannel.Team)
		end,

		["ChatChannel"] = ChatDefine.ChatChannel.Team,
	},

	["Army"] = {
		["Item"] = MakeLSTRDict({
			[MakeLSTRAttrKey("Content")] = 1310021,
			ClickItemCallback = function()
				ShareCommCB("Army", function()
					SendRecruitCardToChat(ChatDefine.ChatChannel.Army, function()
						PopShareTips(_G.LSTR(1310021))
					end)
				end)
			end
		}),

		["EnableCheck"] = function()
			return _G.ChatMgr:IsInChannel(ChatDefine.ChatChannel.Army)
		end,

		["ChatChannel"] = ChatDefine.ChatChannel.Army,
	},
}

function TeamRecruitDetailView:OnClickedShare()
	if UIViewMgr:IsViewVisible(UIViewID.CommStorageTipsView) then
		UIViewMgr:HideView(UIViewID.CommStorageTipsView)
		return
	end

	local TransData = {}

	for _, Sub in pairs(ShareTransTB) do
		if Sub["EnableCheck"]() then
			table.insert(TransData, Sub["Item"])
		end
	end

	table.insert(TransData, MakeLSTRDict({
		[MakeLSTRAttrKey("Content")] = 1310023,
		ClickItemCallback = function()
			ShareCommCB("Clipboard", function()
				_G.TeamRecruitMgr:SetClipboard(TeamRecruitUtil.GatherShareData())
			end)
		end,
		View = self,
	}))

	TipsUtil.ShowStorageBtnsTips(TransData, self.BtnReset, UE.FVector2D(-362 + 8, -100* #TransData), UE.FVector2D(0, 0), true)
end

function TeamRecruitDetailView:OnClickReport()
	if not self.ViewModel then
		return
	end

	_G.ReportMgr:OpenViewByTeamRecruitment({ 
		ReporteeRoleID = self.ViewModel.RoleID,
		ReportContent = self.ViewModel.Message,
	})
end

function TeamRecruitDetailView:OnRecruitClose(ID)
	if self.ViewModel and ID and ID == self.ViewModel.RoleID then
		self:Hide()
	end
end

function TeamRecruitDetailView:GetRecruitRoleID()
	if self.ViewModel then
		return self.ViewModel.RoleID
	end
end


return TeamRecruitDetailView