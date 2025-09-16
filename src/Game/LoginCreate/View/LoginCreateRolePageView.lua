---
--- Author: chriswang
--- DateTime: 2023-10-23 11:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local ProtoCommon = require("Protocol/ProtoCommon")
local FUNCTION_TYPE = ProtoCommon.function_type

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

--@Binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

--@ViewModel
local LoginRoleProfVM = require("Game/LoginRole/LoginRoleProfVM")
local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")

---@class LoginCreateRolePageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCreate UFButton
---@field BtnTryRole UFButton
---@field ImgLogo UFImage
---@field TableViewJob UTableView
---@field TextFunction UFTextBlock
---@field TextHint UFTextBlock
---@field TextInfo UFTextBlock
---@field TextPreviewTips UFTextBlock
---@field TextRoleName UFTextBlock
---@field TextStart UFTextBlock
---@field AnimBtnChecked1 UWidgetAnimation
---@field AnimBtnChecked2 UWidgetAnimation
---@field AnimBtnChecked3 UWidgetAnimation
---@field AnimBtnTryRoleClick UWidgetAnimation
---@field AnimBtnUnchecked UWidgetAnimation
---@field AnimFold UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateRolePageView = LuaClass(UIView, true)

function LoginCreateRolePageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCreate = nil
	--self.BtnTryRole = nil
	--self.ImgLogo = nil
	--self.TableViewJob = nil
	--self.TextFunction = nil
	--self.TextHint = nil
	--self.TextInfo = nil
	--self.TextPreviewTips = nil
	--self.TextRoleName = nil
	--self.TextStart = nil
	--self.AnimBtnChecked1 = nil
	--self.AnimBtnChecked2 = nil
	--self.AnimBtnChecked3 = nil
	--self.AnimBtnTryRoleClick = nil
	--self.AnimBtnUnchecked = nil
	--self.AnimFold = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateRolePageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateRolePageView:OnInit()
	self.ViewModel = LoginRoleProfVM--.New()	方便记录数据，不过得在UIViewModelConfig中配置，否则无法绑定view
	self.ViewModel:InitProfInfoNew()

	self.AdapterJobTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewJob, self.OnJobTableViewSelectChange, true)
end

function LoginCreateRolePageView:OnDestroy()

end

function LoginCreateRolePageView:OnShow()
	self.ViewModel:RandomProf()

	self.AdapterJobTableView:ScrollToTop()
	self.AdapterJobTableView:SetSelectedIndex(self.ViewModel.CurSelectIndex)
	self.AdapterJobTableView:ScrollToIndex(self.ViewModel.CurSelectIndex)
	
	self.ScorllBoxProfDesc:ScrollToStart()

	self.TextPreviewTips:SetText(_G.LSTR(980055))	--当前外观仅为预览
	self.TextTryRole:SetText(_G.LSTR(980002))	--体验技能
	--预加载
	self:PreLoad()
end

function LoginCreateRolePageView:PreLoad()
	local SkillSystemConfig = require("Game/Skill/SkillSystem/SkillSystemConfig")
	local SkillUtil = require("Utils/SkillUtil")
	local SkillSystemConfigPath = SkillSystemConfig.SkillSystemConfigPath
	local SkillSystemRenderActor = SkillUtil.SkillSystemRenderActor
    _G.ObjectMgr:LoadObjectAsync(SkillSystemRenderActor, nil, 3)
    _G.ObjectMgr:LoadObjectAsync(SkillSystemConfigPath, nil, 3)
	local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
	local NewMainSkillBPClass = UIViewMgr:GetBPPath(SkillCommonDefine.NewMainSkillBPName)
    _G.ObjectMgr:LoadObjectAsync(NewMainSkillBPClass, nil, 3)
end

function LoginCreateRolePageView:OnHide()
	_G.LoginUIMgr:SetFeedbackAnimType(0)
	_G.LoginUIMgr:SetNextBtnVisible(true, true)
	
	if not _G.LoginUIMgr.IsShowPreviewing and not LoginRoleProfVM.bBackFromPreview then
		local Cfg = LoginRoleRaceGenderVM.CurrentRaceCfg
		if nil ~= Cfg then
			_G.LoginUIMgr:SetRaceBornEquips(Cfg)
		end
	end
end

function LoginCreateRolePageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTryRole, self.OnDemoSkillBtnClick)
end

function LoginCreateRolePageView:OnRegisterGameEvent()

end

function LoginCreateRolePageView:OnRegisterBinder()
	local Binders = {
		{ "ProfName", UIBinderSetText.New(self, self.TextRoleName) },
		{ "ProfDesc", UIBinderSetText.New(self, self.TextInfo) },
        {"ProfBGLogo", UIBinderSetBrushFromAssetPath.New(self, self.ImgLogo)},
		{ "ProfFuncDesc", UIBinderSetText.New(self, self.TextFunction) },
		{ "ProfHint", UIBinderSetText.New(self, self.TextHint) },
		{ "TextTips", UIBinderSetText.New(self, self.TextTips) },
        {"bShowTextTips", UIBinderSetIsVisible.New(self, self.TextTips)},
		{ "JobCfgList", UIBinderUpdateBindableList.New(self, self.AdapterJobTableView) },

	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function LoginCreateRolePageView:OnJobTableViewSelectChange(Index, ItemData, ItemView, IsByClick)
	local JobList = self.ViewModel.JobCfgList
	if Index >= 1 and Index <= #JobList then
		local Cfg = JobList[Index]
		if Cfg then
			_G.LoginUIMgr:SetFeedbackAnimType(2)

			self:PlayAnimation(self.AnimSwitch)
			LoginRoleProfVM:ClearSelectProf()
			LoginRoleProfVM:DoSelectProf(Cfg, Index)
			
			self.ScorllBoxProfDesc:ScrollToStart()

			if Cfg.Function == ProtoCommon.function_type.FUNCTION_TYPE_ATTACK then
				UIUtil.TextBlockSetColorAndOpacityHex(self.TextFunction, "dc5868FF")
			elseif Cfg.Function == ProtoCommon.function_type.FUNCTION_TYPE_GUARD then
				UIUtil.TextBlockSetColorAndOpacityHex(self.TextFunction, "4a81ffFF")
			elseif Cfg.Function == ProtoCommon.function_type.FUNCTION_TYPE_RECOVER then
				UIUtil.TextBlockSetColorAndOpacityHex(self.TextFunction, "89bd88FF")
			end
			
			self:RefreshNextBtn()
			
			_G.ObjectMgr:CollectGarbage(false)
		end
	end
end

function LoginCreateRolePageView:RefreshNextBtn()
	local Cfg = LoginRoleProfVM.CurrentProf
	if Cfg then
		if Cfg.IsShowWhenMore == 1 then
			UIUtil.SetIsVisible(self.PanelBtnCreate, false)
			_G.LoginUIMgr:SetNextBtnVisible(false)
		else
			UIUtil.SetIsVisible(self.PanelBtnCreate, true)
			_G.LoginUIMgr:SetNextBtnVisible(true)
		end
	end
end

function LoginCreateRolePageView:OnDemoSkillBtnClick()
	_G.LoginUIMgr:OnEnterDemoSkill()
end

return LoginCreateRolePageView