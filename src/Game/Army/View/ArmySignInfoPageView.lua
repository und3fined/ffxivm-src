---
--- Author: Administrator
--- DateTime: 2025-01-06 16:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyMainVM
local ArmySignPanelVM
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIViewMgr = require("UI/UIViewMgr")
local CommonUtil = require("Utils/CommonUtil")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ArmyDefine = require("Game/Army/ArmyDefine")
local GlobalCfgType = ArmyDefine.GlobalCfgType
local FLinearColor = _G.UE.FLinearColor

--- 部队名字最大长度
local Name_Max_Limit = nil
--- 简称最大长度
local ShortName_Max_Limit = nil

local GrandCompanyTypeStyle = 
{
	[ArmyDefine.GrandCompanyType.HeiWo] = 2,
	[ArmyDefine.GrandCompanyType.ShuangShe] = 1,
	[ArmyDefine.GrandCompanyType.HengHui] = 2,
}

local ArmyFlagTextColors = ArmyDefine.ArmyFlagTextColors

local NewStyles = 
{
	[1] = ArmyFlagTextColors.Dark,
	[2] = ArmyFlagTextColors.Nomal,
}

---@class ArmySignInfoPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCreate CommBtnLView
---@field BtnCreate_1 CommBtnLView
---@field BtnLeaderInfo UFButton
---@field CommInforBtn CommInforBtnView
---@field CommonRedDot_UIBP CommonRedDotView
---@field ImgArmy UFImage
---@field ImgArmyIcon UFImage
---@field ImgBadge ArmyBadgeItemView
---@field InputName CommInputBoxView
---@field InputShortName CommInputBoxView
---@field PanelLeader UFCanvasPanel
---@field RichTextSign URichTextBox
---@field TableView_97 UTableView
---@field TextArmyNM UFTextBlock
---@field TextArmyName UFTextBlock
---@field TextCreateDate UFTextBlock
---@field TextSubtitle UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimCreate UWidgetAnimation
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySignInfoPageView = LuaClass(UIView, true)

function ArmySignInfoPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCreate = nil
	--self.BtnCreate_1 = nil
	--self.BtnLeaderInfo = nil
	--self.CommInforBtn = nil
	--self.CommonRedDot_UIBP = nil
	--self.ImgArmy = nil
	--self.ImgArmyIcon = nil
	--self.ImgBadge = nil
	--self.InputName = nil
	--self.InputShortName = nil
	--self.PanelLeader = nil
	--self.RichTextSign = nil
	--self.TableView_97 = nil
	--self.TextArmyNM = nil
	--self.TextArmyName = nil
	--self.TextCreateDate = nil
	--self.TextSubtitle = nil
	--self.AnimCheck = nil
	--self.AnimCreate = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySignInfoPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCreate)
	self:AddSubView(self.BtnCreate_1)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommonRedDot_UIBP)
	self:AddSubView(self.ImgBadge)
	self:AddSubView(self.InputName)
	self:AddSubView(self.InputShortName)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySignInfoPageView:OnInit()
	ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
	ArmySignPanelVM = ArmyMainVM:GetArmySignPanelVM()
	-- if ArmySignPanelVM and ArmySignPanelVM.ArmyShowInfoVM then
    --     local ShowInfoVM = ArmySignPanelVM.ArmyShowInfoVM
    --     self.ShowInfoPage:RefreshVM(ShowInfoVM)
    -- end
	self.TableViewSignAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_97, nil, nil, nil, nil, true, true)
	self.Binders = {
		{ "ArmyName", UIBinderSetText.New(self, self.InputName)},
		{ "ArmyShortName", UIBinderSetText.New(self, self.InputShortName)},
		{ "MemberAmount", UIBinderSetText.New(self, self.RichTextSign)},
		{ "GainTimeStr", UIBinderSetText.New(self, self.TextCreateDate)},
		{ "SignList", UIBinderUpdateBindableList.New(self, self.TableViewSignAdapter) },
		{ "GrandCompanyType", UIBinderValueChangedCallback.New(self, nil, self.GrandCompanyTypeChanged)},
		{ "Emblem", UIBinderValueChangedCallback.New(self, nil, self.EmblemChanged)},
		--{ "CreateRoleID", UIBinderValueChangedCallback.New(self, nil, self.CreateRoleIDChanged)},
		{ "CaptainName", UIBinderValueChangedCallback.New(self, nil, self.SetTextCaptainName)},
		{ "IsRoleQueryFinish", UIBinderValueChangedCallback.New(self, nil, self.OnIsRoleQueryFinishChange) },
		{ "UnionBGIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgArmy)},
		{ "UnionEditIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgArmyIcon)},
		{ "IsSignFull", UIBinderSetIsVisible.New(self, self.FCanvasPanel_2 ) },
	}
    Name_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.NameMaxLimit)
    ShortName_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.ShortNameMaxLimit)
	self.InputName:SetMaxNum(Name_Max_Limit)
	self.InputShortName:SetMaxNum(ShortName_Max_Limit)

end

---设置部队长/创建人名
function ArmySignInfoPageView:OnIsRoleQueryFinishChange(IsRoleQueryFinish)
	if IsRoleQueryFinish then
		self:SetPlayerHeadSlotData()
	end
end

---设置部队长/创建人名
function ArmySignInfoPageView:SetTextCaptainName(CaptainName)
	if self.LeaderView and self.LeaderView.TextCaptainName then
		self.LeaderView.TextCaptainName:SetText(CaptainName)
	end
end

function ArmySignInfoPageView:GrandCompanyTypeChanged(GrandCompanyType)
	if GrandCompanyType then
		ArmyMainVM:SetBGIcon(GrandCompanyType)
		self:SetTextColor(GrandCompanyType)
	end
end

-- function ArmySignInfoPageView:GrandCompanyTypeChanged(CreateRoleID)
-- 	if CreateRoleID then
-- 		self:AddLeaderView()
-- 	end
-- end

function ArmySignInfoPageView:EmblemChanged(Emblem)
	if Emblem then
		self.ImgBadge:SetBadgeData(Emblem)
	end
end

function ArmySignInfoPageView:AddLeaderView()
	if self.LeaderView == nil then
		self.LeaderView = UIViewMgr:CreateViewByName("Army/ArmyShowInfoLeaderPage_UIBP", nil, self, true)
		if self.LeaderView then
			self.PanelLeader:AddChildToCanvas(self.LeaderView)
			local Anchor = _G.UE.FAnchors()
			Anchor.Minimum = _G.UE.FVector2D(0, 0)
			Anchor.Maximum = _G.UE.FVector2D(1, 1)
			UIUtil.CanvasSlotSetAnchors(self.LeaderView, Anchor)
			UIUtil.CanvasSlotSetSize(self.LeaderView, _G.UE.FVector2D(0, 0))
			---更新数据，防止数据变化时，LeaderView未加载导致数据没更新到
			if self.LeaderView then
				if ArmySignPanelVM == nil then
					return
				end
				if self.LeaderView.TextCaptainName then
					local CaptainName = ArmySignPanelVM:GetCaptainName()
					if CaptainName then
						self.LeaderView.TextCaptainName:SetText(CaptainName)
					end
				end
				local IsRoleQueryFinish = ArmySignPanelVM:GetIsRoleQueryFinish()
				if IsRoleQueryFinish then
					self:SetPlayerHeadSlotData()
				end
			end
		end
	end
end

function ArmySignInfoPageView:RemoveLeaderView()
	if self.LeaderView then
		self.PanelLeader:RemoveChild(self.LeaderView)
		UIViewMgr:RecycleView(self.LeaderView)
		self.LeaderView = nil
	end
end

function ArmySignInfoPageView:OnDestroy()

end

function ArmySignInfoPageView:OnShow()
    ---文本设置
    -- LSTR string:部队信息
    self.TextSubtitle:SetText(LSTR(910248))
	-- LSTR string:部队简称
	self.TextArmyNM:SetText(LSTR(910285))
	-- LSTR string:部队名字
	self.TextArmyName:SetText(LSTR(910284))
    -- LSTR string:提醒创建
	self.BtnCreate:SetText(LSTR(910355))
	-- LSTR string:取消署名
	self.BtnCreate_1:SetText(LSTR(910407))
	---头像设置
	if ArmySignPanelVM then
		self:AddLeaderView()
		if ArmySignPanelVM and ArmySignPanelVM:GetIsRoleQueryFinish() then
			self:SetPlayerHeadSlotData()
		end
		---署名后无选中逻辑，显示时设置一次背景
		local GrandCompanyType = ArmySignPanelVM:GetGrandCompanyType()
		if GrandCompanyType then
			ArmyMainVM:SetBGIcon(GrandCompanyType)
			self:SetTextColor(GrandCompanyType)
		end
	end
	self.InputName:SetIsEnabled(false)
	self.InputShortName:SetIsEnabled(false)
	---设置蒙版
	ArmyMainVM:SetIsMask(false)
end

---头像设置
function ArmySignInfoPageView:SetPlayerHeadSlotData()
	if self.LeaderView then
		if ArmySignPanelVM then
			local CurLeaderID = ArmySignPanelVM:GetCreateRoleID()
			local PlayerHeadSlot = self.LeaderView.CommPlayerHeadSlot_UIBP
			if PlayerHeadSlot and CommonUtil.IsObjectValid(PlayerHeadSlot) and CurLeaderID then
				PlayerHeadSlot:SetInfo(CurLeaderID)
			end
		end
	end
end

function ArmySignInfoPageView:OnHide()
	self:RemoveLeaderView()
end

function ArmySignInfoPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCreate, self.OnClickedRemind)
	UIUtil.AddOnClickedEvent(self, self.BtnCreate_1, self.OnClickedRefuse)
end

function ArmySignInfoPageView:OnClickedRemind()
	---打开聊天弹窗
	local RoleID = ArmySignPanelVM:GetCreateRoleID()
	if RoleID then
		_G.ChatMgr:GoToPlayerChatView(RoleID)
	end
end

function ArmySignInfoPageView:OnClickedRefuse()
	local RoleID = ArmySignPanelVM:GetCreateRoleID()
	---取消署名
	if RoleID then
		_G.ArmyMgr:ShowSignCancelMsgBox(RoleID)
	end
end

function ArmySignInfoPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ArmySignNumToc, self.OnSignNumToc)
end

function ArmySignInfoPageView:OnRegisterBinder()
	if ArmySignPanelVM then
		self:RegisterBinders(ArmySignPanelVM, self.Binders)
	end
end

---署名人数变化时，请求一下数据来刷新
function ArmySignInfoPageView:OnSignNumToc()
    _G.ArmyMgr:SendGroupSignQueryInvites()
end

function ArmySignInfoPageView:IsForceGC()
	return true
end

function ArmySignInfoPageView:SetTextColor(GrandCompanyType)
	if GrandCompanyType == nil then
        return
	end
	local GrandCompanyTypeStyle = GrandCompanyTypeStyle[GrandCompanyType]
	if GrandCompanyTypeStyle then
		if NewStyles[GrandCompanyTypeStyle] == nil then
			return
		end
		if self.LeaderView then
			local LeaderNameColor = FLinearColor.FromHex(NewStyles[GrandCompanyTypeStyle].LeaderNameColor)
			self.LeaderView.TextCaptainName:SetColorAndOpacity(LeaderNameColor)
			local LeaderTextColor = FLinearColor.FromHex(NewStyles[GrandCompanyTypeStyle].LeaderTextColor)
			self.LeaderView.TextCaptain:SetColorAndOpacity(LeaderTextColor)
		end
	end
end

return ArmySignInfoPageView