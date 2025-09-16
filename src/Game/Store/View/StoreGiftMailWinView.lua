
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")
local StoreGiftMailVM = require("Game/Store/VM/StoreGiftMailVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local UTF8Util = require("Utils/UTF8Util")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local StoreDefine = require("Game/Store/StoreDefine")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ScoreCfg = require("TableCfg/ScoreCfg")
local StoreDefaultgiftmsgCfg = require("TableCfg/StoreDefaultgiftmsgCfg")
local ActorUtil = require("Utils/ActorUtil")
local ObjectGCType = require("Define/ObjectGCType")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local LightDefine = require("Game/Light/LightDefine")
local ProtoRes = require("Protocol/ProtoRes")
local StoreMgr = require("Game/Store/StoreMgr")
local UIBinderSetTextFormatForScore = require("Binder/UIBinderSetTextFormatForScore")
local UIBinderSetScoreIcon = require("Binder/UIBinderSetScoreIcon")
local StoreUtil = require("Game/Store/StoreUtil")
local StoreCfg = require("TableCfg/StoreCfg")
local StorePropsItemVM = require("Game/Store/VM/ItemVM/StorePropsItemVM")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local HelpInfoUtil = require("Utils/HelpInfoUtil")

local LSTR = _G.LSTR
local SceneCenter = LightDefine.LightLevelCreateLocation[LightDefine.LightLevelID.LIGHT_LEVEL_ID_EMAIL]
local PostmanNPCID = 1001174
local PriceColorRed = "DC5868FF"
local PriceColorBlack = "313131FF"

---@class StoreGiftMailWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnGift CommBtnLView
---@field BtnMax UFButton
---@field BtnPlus UFButton
---@field BtnReceive CommBtnLView
---@field BtnReduce UFButton
---@field BtnSub UFButton
---@field CommInforBtn CommInforBtnView
---@field CommonModelToImage CommonModelToImageView
---@field HorizontalPrice UFHorizontalBox
---@field ImgBlackBg_1 UFImage
---@field ImgDeadline UFImage
---@field ImgGoods UFImage
---@field ImgMoney UFImage
---@field MultilineInputBox CommMultilineInputBoxView
---@field PanelAmount UFCanvasPanel
---@field PanelAmountTextOnly UFTextBlock
---@field PanelDeadline UFCanvasPanel
---@field PanelDiscount UFCanvasPanel
---@field PanelGiftBtns UFCanvasPanel
---@field PanelGoodsShow UFCanvasPanel
---@field PanelInclude UFCanvasPanel
---@field PanelInfor UFCanvasPanel
---@field PanelLackStyle UFCanvasPanel
---@field PanelMax UFCanvasPanel
---@field PanelOriginal UFCanvasPanel
---@field PanelPropsShow UFCanvasPanel
---@field RichTextNum URichTextBox
---@field ShopGoods ShopGoodsListItemView
---@field Spine_Store_Mail USpineWidget
---@field TableViewInclude UTableView
---@field TableViewMailStyle UTableView
---@field TextBoxAmount UEditableTextBox
---@field TextCurrentPrice UFTextBlock
---@field TextDate UFTextBlock
---@field TextDeadline UFTextBlock
---@field TextDiscount UFTextBlock
---@field TextEditTips UFTextBlock
---@field TextFromName UFTextBlock
---@field TextInclude UFTextBlock
---@field TextItemName UFTextBlock
---@field TextLackStyle UFTextBlock
---@field TextMoneyHint UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextTitle UFTextBlock
---@field TextToName UFTextBlock
---@field VerticalBoxInfo UFVerticalBox
---@field AnimPack UWidgetAnimation
---@field AnimShow UWidgetAnimation
---@field AnimUnpack UWidgetAnimation
---@field ModelDistance float
---@field ModelHeight float
---@field ModelYaw float
---@field ModelPitch float
---@field ModelPan float
---@field ModelAnimationPath text
---@field CurveModelDistance CurveFloat
---@field CurveModelHeight CurveFloat
---@field CurveModelYaw CurveFloat
---@field CurveModelPitch CurveFloat
---@field CurveModelPan CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreGiftMailWinView = LuaClass(UIView, true)

function StoreGiftMailWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnClose = nil
	--self.BtnGift = nil
	--self.BtnMax = nil
	--self.BtnPlus = nil
	--self.BtnReceive = nil
	--self.BtnReduce = nil
	--self.BtnSub = nil
	--self.CommInforBtn = nil
	--self.CommonModelToImage = nil
	--self.HorizontalPrice = nil
	--self.ImgBlackBg_1 = nil
	--self.ImgDeadline = nil
	--self.ImgGoods = nil
	--self.ImgMoney = nil
	--self.MultilineInputBox = nil
	--self.PanelAmount = nil
	--self.PanelAmountTextOnly = nil
	--self.PanelDeadline = nil
	--self.PanelDiscount = nil
	--self.PanelGiftBtns = nil
	--self.PanelGoodsShow = nil
	--self.PanelInclude = nil
	--self.PanelInfor = nil
	--self.PanelLackStyle = nil
	--self.PanelMax = nil
	--self.PanelOriginal = nil
	--self.PanelPropsShow = nil
	--self.RichTextNum = nil
	--self.ShopGoods = nil
	--self.Spine_Store_Mail = nil
	--self.TableViewInclude = nil
	--self.TableViewMailStyle = nil
	--self.TextBoxAmount = nil
	--self.TextCurrentPrice = nil
	--self.TextDate = nil
	--self.TextDeadline = nil
	--self.TextDiscount = nil
	--self.TextEditTips = nil
	--self.TextFromName = nil
	--self.TextInclude = nil
	--self.TextItemName = nil
	--self.TextLackStyle = nil
	--self.TextMoneyHint = nil
	--self.TextOriginalPrice = nil
	--self.TextTitle = nil
	--self.TextToName = nil
	--self.VerticalBoxInfo = nil
	--self.AnimPack = nil
	--self.AnimShow = nil
	--self.AnimUnpack = nil
	--self.ModelDistance = nil
	--self.ModelHeight = nil
	--self.ModelYaw = nil
	--self.ModelPitch = nil
	--self.ModelPan = nil
	--self.ModelAnimationPath = nil
	--self.CurveModelDistance = nil
	--self.CurveModelHeight = nil
	--self.CurveModelYaw = nil
	--self.CurveModelPitch = nil
	--self.CurveModelPan = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreGiftMailWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnGift)
	self:AddSubView(self.BtnReceive)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommonModelToImage)
	self:AddSubView(self.MultilineInputBox)
	self:AddSubView(self.ShopGoods)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreGiftMailWinView:OnInit()
	self.AdapterInclude = UIAdapterTableView.CreateAdapter(self, self.TableViewInclude, self.TableViewIncludeSeceltedChanged, true)
	-- self.AdapterMailStyle = UIAdapterTableView.CreateAdapter(self, self.TableViewMailStyle, self.OnMailStyleSeceltedChanged, true, false)

	self.InitNumText = 1
	local DefaultMsg = StoreDefaultgiftmsgCfg:FindAllCfg()
	for _, value in pairs(DefaultMsg) do
		self.MultilineInputBox:SetText(value.Text)
		break
	end

	self.MainBinders =
	{
		{ "ContainsItemList", 		UIBinderUpdateBindableList.New(self, self.AdapterInclude) },
		-- { "StyleList", 				UIBinderUpdateBindableList.New(self, self.AdapterMailStyle) },
		{ "PropsPanelVisible", 	UIBinderSetIsVisible.New(self, self.PanelGoodsShow, true) },
		{ "PropsPanelVisible", 	UIBinderSetIsVisible.New(self, self.PanelInclude, true) },
		{ "BuyGoodIcon", 			UIBinderSetBrushFromAssetPath.New(self, self.ImgGoods, true) },
		{ "DiscountText", 			UIBinderSetText.New(self, self.TextDiscount) },
		{ "TimeSaleText", 			UIBinderSetText.New(self, self.TextDeadline) },
		{ "MultiBuyPurchaseNumber", UIBinderSetText.New(self, self.TextBoxAmount) },
		{ "AmountText", 			UIBinderSetText.New(self, self.PanelAmountTextOnly) },
		{ "DiscountPanelVisible", 	UIBinderSetIsVisible.New(self, self.PanelDiscount) },
		{ "DeadlinePanelVisible", 	UIBinderSetIsVisible.New(self, self.PanelDeadline) },
		{ "IsShowTimeSaleIcon", 	UIBinderSetIsVisible.New(self, self.ImgDeadline) },
		{ "PropsPanelVisible", 		UIBinderSetIsVisible.New(self, self.PanelPropsShow) },
		{ "PanelAmountVisible", 	UIBinderSetIsVisible.New(self, self.PanelAmount) },
	}

	self.PriceBinders =
	{
		{ "ScoreID", UIBinderSetScoreIcon.New(self, self.ImgMoney) },
		{ "BuyPrice", UIBinderSetTextFormatForScore.New(self, self.TextCurrentPrice) },
		{ "RawPrice", UIBinderSetTextFormatForScore.New(self, self.TextOriginalPrice) },
		{ "bShowRawPrice", UIBinderSetIsVisible.New(self, self.PanelOriginal) },
	}

	self.PriceVM = StoreMgr:GetGiftPriceVM()
	self.StorePropsItemVM = StorePropsItemVM.New()

	self.GoodsID = 0
end

function StoreGiftMailWinView:SequenceEvent_SetModelCamera()
	self:SetModelCameraValue()
	self.CommonModelToImage:SetDistance(self.ModelDistance)
	self.CommonModelToImage:SetHightOffset(self.ModelHeight)
	self.CommonModelToImage:SetPitchAngle(self.ModelPitch)
	self.CommonModelToImage:SetYawAngle(self.ModelYaw)
	self.CommonModelToImage:SetPan(self.ModelPan)
end

function StoreGiftMailWinView:SequenceEvent_SetModelAnimation(lPathIndex)
	self:SetModelAnimationPathValue(lPathIndex)
	local Actor = ActorUtil.GetActorByEntityID(self.CreatedNPCEntityID)
	if (Actor ~= nil) then
		local AnimationComponent = Actor:GetAnimationComponent()
		if self.MainPanelResidentAnimMontage ~= nil then
			AnimationComponent:StopMontage(self.MainPanelResidentAnimMontage)
			self.MainPanelResidentAnimMontage = nil
		end
		local ModelAnimationObj = _G.ObjectMgr:LoadObjectSync(self.ModelAnimationPath, ObjectGCType.LRU)
		self.MainPanelResidentAnimMontage = AnimationComponent:PlaySequenceToMontage(ModelAnimationObj, "WholeBody", nil, nil, 1.0, 0.25, 0.25, nil, 10000000, true)
	end
end

function StoreGiftMailWinView:OnDestroy()

end

function StoreGiftMailWinView:TableViewIncludeSeceltedChanged(Index, ItemData, ItemView)
	ItemTipsUtil.ShowTipsByResID(StoreMainVM.ContainsItemList.Items[Index].ResID, ItemView, {X = -self.TableViewInclude.EntrySpacing, Y = 0})
end

function StoreGiftMailWinView:OnMailStyleSeceltedChanged(Index, ItemData, ItemView)
	if StoreMainVM:CheckStyleIsUnlocked(Index) then
		
		UIUtil.SetIsVisible(self.BtnGift, true, true)
		UIUtil.SetIsVisible(self.HorizontalPrice, true)
		UIUtil.SetIsVisible(self.PanelLackStyle, false)
		--- 切换风格  待确认

	else
		UIUtil.SetIsVisible(self.BtnGift, false, true)
		UIUtil.SetIsVisible(self.HorizontalPrice, false)
		UIUtil.SetIsVisible(self.PanelLackStyle, true)
	end
end

function StoreGiftMailWinView:OnShow()
	if nil ~= self.Params then
		self.GoodsID = self.Params.GoodsID or 0
	end

	UIUtil.SetIsVisible(self.TableViewMailStyle, false)		---story=121735132 【系统】【商城系统】屏蔽赠礼包装自定义功能

	self.bLockUpdate = false
	self.TextTitle:SetText(LSTR(950049))		--- 赠礼
	self.TextInclude:SetText(LSTR(950058))		--- 包含以下物品
	self.TextEditTips:SetText(LSTR(950059))		--- （点击可进行编辑）
	self.BtnGift:SetBtnName(LSTR(950006))		--- 赠送
	self.BtnReceive:SetBtnName(LSTR(950039))	--- 收下了
	self.TextMoneyHint:SetText(LSTR(950092)) -- 赠礼水晶点不足
	self.CommInforBtn:SetButtonStyle(HelpInfoUtil.HelpInfoType.Tips)
	local IsExternal = nil ~= self.Params and self.Params.bIsExternal

	self:PlayAnimation(self.AnimShow)
	UIUtil.SetIsVisible(self.PanelLackStyle, false)
	UIUtil.SetIsVisible(self.VerticalBoxInfo, false)
	--- 数量 收礼用
	UIUtil.SetIsVisible(self.PanelAmountTextOnly, IsExternal and StoreGiftMailVM.IsProp)
	-- UIUtil.SetIsVisible(self.TableViewMailStyle, not IsExternal)
	UIUtil.SetIsVisible(self.BtnReceive, IsExternal)
	UIUtil.SetIsVisible(self.BtnGift, not IsExternal)
	UIUtil.SetIsVisible(self.HorizontalPrice, not IsExternal)
	UIUtil.SetIsVisible(self.TextEditTips, not IsExternal)
	UIUtil.SetIsVisible(self.MultilineInputBox.RichTextNumber, not IsExternal)
	self.MultilineInputBox:SetMaxNum(150)
	-- self.AdapterMailStyle:SetSelectedIndex(1)
	UIUtil.SetIsVisible(self.RichTextNum, not IsExternal)
	UIUtil.SetIsVisible(self.CommInforBtn, not IsExternal)
	if IsExternal then
		UIUtil.SetColorAndOpacityHex(self.ImgBlackBg, "0000008F")
		self:PlayAnimation(self.AnimUnpack)

		local SendGiftTime = TimeUtil.GetTimeFormat("%Y年%m月%d日", StoreGiftMailVM.GiftTime)
		self.TextDate:SetText(SendGiftTime)
		self.TextItemName:SetText(StoreGiftMailVM.ItemNameText)
		self.MultilineInputBox:SetText(StoreGiftMailVM.GiftMessage)
		if StoreGiftMailVM.AlreadyReceived then
			self.BtnReceive:SetButtonText(LSTR(950033))	--- "确认"
		else
			self.BtnReceive:SetButtonText(LSTR(950039))	--- 收下了
		end
		UIUtil.SetIsVisible(self.TextMoneyHint, false)
	else
		UIUtil.SetColorAndOpacityHex(self.ImgBlackBg, "00000059")
		self:UpdatePriceColor()
		self:UpdateLeftPriceText()
		self:UpdateTransactionHint()
		local NowServerTime = TimeUtil.GetServerTimeFormat("%Y年%m月%d日")
		self.TextDate:SetText(NowServerTime)
		if _G.StoreMgr:CheckMallTypeByIndex(StoreMainVM.TabSelecteIndex, ProtoRes.StoreMall.STORE_MALL_PROPS) then
			self.TextItemName:SetText(StoreMainVM.CurrentSelectedItem.Name)
		else
			self.TextItemName:SetText(StoreMainVM.CurrentSelectedItem.ItemNameText)
		end

		local UActorManager = _G.UE.UActorManager.Get()
		local Rotation = _G.UE.FRotator(0, 0, 0)
		local Params = _G.UE.FCreateClientActorParams()
		self.CreatedNPCEntityID = UActorManager:CreateClientActorByParams(_G.UE.EActorType.Npc, 0, PostmanNPCID, SceneCenter,
			Rotation, Params)
		_G.LightMgr:LoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_MAIL, LightDefine.LightLevelCreateLocation[LightDefine.LightLevelID.LIGHT_LEVEL_ID_EMAIL])
	end
	self.MultilineInputBox:SetIsReadOnly(IsExternal)
		
	local ToName = string.format(LSTR(950068), IsExternal and StoreGiftMailVM.ToName or StoreMainVM.ToName)	--- 亲爱的%s:
	self.TextToName:SetText(ToName)
	local FromName = string.format("%s%s", LSTR(950069), IsExternal and StoreGiftMailVM.FromName or MajorUtil.GetMajorName())	--- 来自:
	self.TextFromName:SetText(FromName)

	self:CheckGoodsCountButtonsState()

	local GoodsCfgData = StoreCfg:FindCfgByKey(self.GoodsID)
	self.StorePropsItemVM:UpdateVM({PropsData = {Cfg = GoodsCfgData}})
	if IsExternal then
		self.StorePropsItemVM.TagVisible = false
		self.StorePropsItemVM.TimeVisible = false
	end
	self.ShopGoods:SetParams({Data = self.StorePropsItemVM})
	self.ShopGoods:SetBuyViewItemStateEx(false)
end

--- 废弃   改用通用多行输入框
function StoreGiftMailWinView:OnMultiTextBoxWordsChanged(_, Text)
	if true then
		return
	end
	local Length = UTF8Util.Len(Text) - self.InitTextLen
	if self.TextLimit > 0 and Length > self.TextLimit then
		Length = self.TextLimit
		Text = UTF8Util.Sub(Text, self.InitTextLen, self.TextLimit)
		self.MultiTextBoxWords:SetText(Text)
	end
	if Length < 0 then
		self.MultiTextBoxWords:SetText(self.InitText)
		Length = 0
	end

	local TextNumber = string.format("%d/%d", Length, self.TextLimit)
	self.RichTextLimit:SetText(TextNumber)
end

function StoreGiftMailWinView:OnTextBoxAmountChanged(_, Text)
	local IsExternal = nil ~= self.Params and self.Params.bIsExternal
	if IsExternal or IsExternal == nil then
		return
	end
	if tonumber(Text, 10) == nil then
		self.TextBoxAmount:SetText(1)
		return
	end
	local Limit = self:GetMaxGoodsCount()
	if Limit < tonumber(Text) and Limit > 0 then
		StoreMainVM:SetMultiQuantity(Limit)
		self.TextBoxAmount:SetText(Limit)
	else
		StoreMainVM:SetMultiQuantity(tonumber(Text))
	end
	self:CheckGoodsCountButtonsState()
	self:UpdatePriceColor()
	self:UpdateTransactionHint()
	self:UpdateLeftPriceText()
end

--赠礼额度拆出来，不往StoreMainVM里面塞新东西了
function StoreGiftMailWinView:UpdateLeftPriceText()
	local VirtualNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_VIRTUAL_ACC_SENDGIFT)
	local AccRechargePoints = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_VIRTUAL_ACC_RECHARGE)
	local GiftQuotaNum = math.floor(AccRechargePoints * 0.33 - VirtualNum) 
	local IsGiftQuotaEnough = self.IsGiftBalanceEnough(self.PriceVM.BuyPrice)
	local GiftDiffNum = math.abs((math.floor(AccRechargePoints * 0.33 - VirtualNum - self.PriceVM.BuyPrice)))
	local IsBuyCoinEnough = self.IsBalanceEnough(self.PriceVM.BuyPrice, self.PriceVM.ScoreID)
	--赠礼，水晶都足够 
	if IsGiftQuotaEnough and IsBuyCoinEnough then
		self.BtnGift:SetBtnName(LSTR(950006))
		self.RichTextNum:SetText(string.format(LSTR(950099),self.PriceVM.BuyPrice, GiftQuotaNum))
	elseif not IsGiftQuotaEnough then --额度不足
		self.BtnGift:SetBtnName(LSTR(950100))
		self.RichTextNum:SetText(string.format(LSTR(950101),self.PriceVM.BuyPrice, GiftQuotaNum, GiftDiffNum))
	elseif not IsBuyCoinEnough then --水晶点不足
		self.BtnGift:SetBtnName(LSTR(950102))
		self.RichTextNum:SetText(string.format(LSTR(950099),self.PriceVM.BuyPrice, GiftQuotaNum))
	end
end

function StoreGiftMailWinView:OnClickBtnSubAndBtnAdd()
	local Tips = LSTR(950040)		--- "数量超出范围"
	MsgTipsUtil.ShowTips(Tips)
end

function StoreGiftMailWinView:OnButtonInfoClick()
	local ViewID = _G.UIViewID.CommHelpInfoTipsView
	local Params = {}
	local Content = LSTR(950098)
	local BtnSize =  UIUtil.GetWidgetSize(self.CommInforBtn.Imgnfor)
	Params.Data = table.is_nil_empty(Content) and {{Title = "", Content = {Content}}} or Content
	Params.Offset = _G.UE.FVector2D(20, BtnSize.Y - 50)
	Params.Alignment = _G.UE.FVector2D(0, 0.5)
	Params.InTargetWidget = self.CommInforBtn
	Params.HidePopUpBG = false
    _G.UIViewMgr:ShowView(ViewID, Params)
end

function StoreGiftMailWinView:OnHide()
	if self.CreatedNPCEntityID then
		_G.UE.UActorManager.Get():RemoveClientActor(self.CreatedNPCEntityID)
	end
	local IsExternal = nil ~= self.Params and self.Params.bIsExternal
	if IsExternal or IsExternal == nil then
		return
	end
	StoreMainVM:SetMultiQuantity(1)
	self.TextBoxAmount:SetText(1)
	StoreMainVM.GiftChooseImgBlackLucency = "000000BF"
	self.bLockUpdate = false
	_G.LightMgr:UnLoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_MAIL)
end

function StoreGiftMailWinView:OnRegisterUIEvent()
	UIUtil.AddOnTextChangedEvent(self, self.TextBoxAmount, self.OnTextBoxAmountChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnGift, self.OnClickBtnGift)
	UIUtil.AddOnClickedEvent(self, self.BtnPlus, self.OnClickBtnPlus)
	UIUtil.AddOnClickedEvent(self, self.BtnReduce, self.OnClickBtnReduce)
	UIUtil.AddOnClickedEvent(self, self.BtnMax, self.OnClickBtnMax)
	UIUtil.AddOnClickedEvent(self, self.BtnReceive, self.OnClickBtnReceive)
	UIUtil.AddOnClickedEvent(self, self.CommInforBtn.BtnInfor, self.OnButtonInfoClick)

	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnClickBtnSubAndBtnAdd)
	UIUtil.AddOnClickedEvent(self, self.BtnSub, self.OnClickBtnSubAndBtnAdd)
	
end

function StoreGiftMailWinView:OnClickBtnReceive()
	if not StoreGiftMailVM.AlreadyReceived then
		_G.MailMainVM:ReceiveGiftEmailAttachment()
	end
	self:Hide()
end

function StoreGiftMailWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.StoreMailCloseEvent, self.OnClose)
	self:RegisterGameEvent(_G.EventID.UpdateScore, self.OnScoreUpdate)
end

function StoreGiftMailWinView:OnClose()
	self:PlayAnimation(self.Animpack)
	local Actor = ActorUtil.GetActorByEntityID(self.CreatedNPCEntityID)
	if(Actor ~= nil)then
		self.CommonModelToImage:Show(Actor, nil, SceneCenter, {X=512, Y=512}) --[sammrli]临时改成512，等引擎那边处理RT复用问题
		Actor:GetAvatarComponent():SetForcedLODForAll(0)
	end
	local AnimDuringTime = self.Animpack:GetEndTime()
	self:RegisterTimer(function() self:Hide() end, AnimDuringTime, 0, 1)
	_G.UIViewMgr:HideView(_G.UIViewID.StoreGiftChooseFriendWin)
end

function StoreGiftMailWinView:OnScoreUpdate(Params)
	if nil == Params or nil == self.PriceVM then
		return
	end
	local RelatedScoreIDs = {ProtoRes.SCORE_TYPE.SCORE_TYPE_VIRTUAL_ACC_RECHARGE,
		ProtoRes.SCORE_TYPE.SCORE_TYPE_VIRTUAL_ACC_SENDGIFT, self.PriceVM.ScoreID}
	if not table.contain(RelatedScoreIDs, Params) then
		return
	end
	self:UpdatePriceColor()
	self:UpdateTransactionHint()
	if not self.bLockUpdate then
		self:UpdateLeftPriceText()
	end
end

function StoreGiftMailWinView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		self:SetParams({bIsExternal = false})				-- Params 是否外部打开
	end
	if nil ~= Params and Params.bIsExternal then
		self:RegisterBinders(StoreGiftMailVM, self.MainBinders)
	else
		self:RegisterBinders(StoreMainVM, self.MainBinders)
	end
	self:RegisterBinders(self.PriceVM, self.PriceBinders)
end

function StoreGiftMailWinView:OnClickBtnGift()
	local GoodData = StoreMainVM.GoodFilterDataList[StoreMainVM.GoodSelecteIndex]
    if nil == GoodData or nil == GoodData.Cfg or nil == self.PriceVM then
        MsgTipsUtil.ShowTipsByID(StoreDefine.BuyError)
		return
    end
	local Price = self.PriceVM.BuyPrice
	local function JumpToRecharge()
		-- 打开充值界面
		RechargingMgr:ShowMainPanel()
		RechargingMgr:OnChangedMainPanelCloseBtnToBack(true)
	end
	if self.IsGiftBalanceEnough(Price) then
		if self.IsBalanceEnough(Price, self.PriceVM.ScoreID) then
			self.bLockUpdate = true
			self:SendGiftRequest()
		else
			local ScoreCfgData = ScoreCfg:FindCfgByKey(self.PriceVM.ScoreID)
			if nil == ScoreCfgData then
				return
			end
			JumpToRecharge()
		end
	else
		local AccRechargePoints = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_VIRTUAL_ACC_RECHARGE)
		local VirtualNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_VIRTUAL_ACC_SENDGIFT)
		local GiftDiffNum = math.ceil((self.PriceVM.BuyPrice - (AccRechargePoints * 0.33 - VirtualNum)) / 100 / 0.33)
		local MsgBoxParams = {}
		MsgBoxUtil.ShowMsgBoxTwoOp(
			self,
			LSTR(950074),		--- "提示"
			string.format(LSTR(950104), GiftDiffNum),     --- "赠礼水晶点不足提示"
			JumpToRecharge,
			nil,
			LSTR(950030),	--- "取消"
			LSTR(950033),	--- "确认"
			MsgBoxParams
		)
	end
	StoreUtil.ReportGiftClickFlow(GoodData.Cfg.ID, StoreDefine.GiftOperationType.ClickMailGiftButton)
end

function StoreGiftMailWinView:OnClickBtnPlus()
	if StoreMainVM:CheckNumAdd() then
		StoreMainVM:SetMultiQuantity(StoreMainVM.MultiBuyPurchaseNumber + 1)
	end
end

function StoreGiftMailWinView:OnClickBtnReduce()
	if StoreMainVM:CheckNumSub() then
		StoreMainVM:SetMultiQuantity(StoreMainVM.MultiBuyPurchaseNumber - 1)
	end
end

function StoreGiftMailWinView:OnClickBtnMax()
	StoreMainVM:ChangeNumToLimit()
end

function StoreGiftMailWinView:CheckGoodsCountButtonsState()
	local MaxCount = self:GetMaxGoodsCount()
	local bBtnReduceEnable = tonumber(self.TextBoxAmount:GetText()) > 1
	local bBtnPlusEnable = tonumber(self.TextBoxAmount:GetText()) < MaxCount
	self.BtnPlus:SetIsEnabled(bBtnPlusEnable)
	self.BtnMax:SetIsEnabled(bBtnPlusEnable)
	self.BtnReduce:SetIsEnabled(bBtnReduceEnable)

	UIUtil.SetIsVisible(self.BtnSub, not bBtnReduceEnable, true)
	UIUtil.SetIsVisible(self.BtnAdd, not bBtnPlusEnable, true)
end

function StoreGiftMailWinView:GetMaxGoodsCount()
	local GoodsCfgData = StoreMainVM:GetCurrentGoodsCfgData()
	local MaxCount = nil ~= GoodsCfgData and GoodsCfgData.OnceLimitation or 1
	return MaxCount
end

function StoreGiftMailWinView:UpdatePriceColor()
	if nil == self.PriceVM then
		return
	end
	local GoodsCfgData = StoreMainVM:GetCurrentGoodsCfgData()
	if nil == GoodsCfgData then
		return
	end
	local Price = self.PriceVM.BuyPrice
	local bEnoughBalance = self.IsBalanceEnough(self.PriceVM.BuyPrice, self.PriceVM.ScoreID)
	local bEnoughGiftBalance = self.IsGiftBalanceEnough(Price)
	if bEnoughBalance and bEnoughGiftBalance then
		UIUtil.SetColorAndOpacityHex(self.TextCurrentPrice, PriceColorBlack)
	else
		UIUtil.SetColorAndOpacityHex(self.TextCurrentPrice, PriceColorRed)
	end
end

function StoreGiftMailWinView:UpdateTransactionHint()
	local bExternal = self.Params and self.Params.bIsExternal
	if nil == self.PriceVM or bExternal then
		UIUtil.SetIsVisible(self.TextMoneyHint, false)
		return
	end
	UIUtil.SetIsVisible(self.TextMoneyHint, false)
end

function StoreGiftMailWinView:SendGiftRequest()
	local ReqData =
	{
		FriendID = StoreMainVM.TargetRoleID,
		GoodID = self.GoodsID,
		DecorativeStyle = StoreMainVM.SelectedStyleIndex,
		GiftMessage = self.MultilineInputBox:GetText(),
		GiftNum = StoreMgr:CheckMallTypeByIndex(StoreMainVM.TabSelecteIndex, ProtoRes.StoreMall.STORE_MALL_PROPS) and
			StoreMainVM.MultiBuyPurchaseNumber or 1
	}
	StoreMgr:SendNetGiftReq(ReqData)
end

function StoreGiftMailWinView.IsBalanceEnough(Price, BalanceScoreID)
	local Balance = ScoreMgr:GetScoreValueByID(BalanceScoreID)
	return Balance >= Price
end

function StoreGiftMailWinView.IsGiftBalanceEnough(Price)
	local AccRechargePoints = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_VIRTUAL_ACC_RECHARGE)
	local AccGiftPoints = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_VIRTUAL_ACC_SENDGIFT)
	return (AccRechargePoints * 0.33 - AccGiftPoints - Price) >= 0
end

return StoreGiftMailWinView