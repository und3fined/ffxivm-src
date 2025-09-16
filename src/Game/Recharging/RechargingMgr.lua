local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIUtil = require("Utils/UIUtil")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local EventMgr = require("Event/EventMgr")
local CommonUtil = require("Utils/CommonUtil")
local ObjectGCType = require("Define/ObjectGCType")
local ActorUtil = require("Utils/ActorUtil")
local EventID = require("Define/EventID")
local LightDefine = require("Game/Light/LightDefine")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MSDKDefine = require("Define/MSDKDefine")
local AccountUtil = require("Utils/AccountUtil")
local LoginMgr = require("Game/Login/LoginMgr")

local BagMgr = require("Game/Bag/BagMgr")
local QuestMgr = require("Game/Quest/QuestMgr")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local LightMgr = require("Game/Light/LightMgr")
local PayUtil = require("Utils/PayUtil")
local RechargeRewardCfg = require("TableCfg/RechargeRewardCfg")
local RechargeGlobalCfg = require("TableCfg/RechargeGlobalCfg")
local RechargingDefine = require("Game/Recharging/RechargingDefine")
local RechargingUtil = require("Game/Recharging/RechargingUtil")
local RechargingRewardVM = require("Game/Recharging/VM/RechargingRewardVM")
local RechargingMainVM = require("Game/Recharging/VM/RechargingMainVM")
local RechargingBgModelVM = require("Game/Recharging/VM/RechargingBgModelVM")
local RenderSceneDefine = require ("Game/Common/Render2D/RenderSceneDefine")
local SystemLightCfg = require("TableCfg/SystemLightCfg")

local CS_CMD = ProtoCS.CS_CMD
local CS_PAY_CMD = ProtoCS.CS_PAY_CMD
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR

local ShopkeeperNPCID = 2006191

---@class RechargingMgr : MgrBase
local RechargingMgr = LuaClass(MgrBase)

function RechargingMgr:OnInit()
	self.ParentView = nil

	self.CurrentRequestOrder = 0
	self.CurrentRequestCrystas = 0
	self.CurrentRequestBonus = 0
	self.CurrentRequestSum = 0
	self.Crystas = 0
	self.RewardState = RechargingDefine.RewardState.Exhausted
	self.NextRewardID = 0
	self.RestAmountToApplyReward = 0
	self.AlreadyGotRewardIDs = nil
	self.SceneActor = nil
	self.LightPreset = nil
	self.LightPresetRef = nil
	self.ShopkeeperEntityID = -1
	self.bIsReadyToShowMainPanel = false
	self.bIsPendingShowMainPanel = false
	self.LastVoucherTipTime = 0

	-- 全局配置
	self.MaxRewardCount = 0
	self.CharacterShowQuestID = 0
	self.CharacterShowAction = ""
	self.CharacterRewardApplyActions = nil
	self.CharacterRestActionID = 0
	self.CharacterInteractActionIDs = nil
	self.CharacterTransitionAction = ""
	self.InteractCD = 0
end

function RechargingMgr:OnBegin()
	self:LoginMidas()
end

function RechargingMgr:OnEnd()
end

function RechargingMgr:OnShutdown()

end

function RechargingMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PAY, CS_PAY_CMD.CS_CMD_PAY_QUERY_RECHARGE_AWARD, self.OnNetMsgRewardStateUpdate)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PAY, CS_PAY_CMD.CS_CMD_PAY_RECHARGE_AWARD, self.OnNetMsgRewardApplication)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PAY, CS_PAY_CMD.CS_CMD_PAY_DISTRIBUTE_NOTIFY, self.OnNetMsgPayNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ERR, 0, self.OnNetMsgErrNotify)
end

function RechargingMgr:OnRegisterGameEvent()
    -- self:RegisterGameEvent(EventID.Avatar_Update_Master, self.OnMainBodyUpdated)
    self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnMainBodyUpdated)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnLogin)
	self:RegisterGameEvent(EventID.MSDKLoginRetNotify, self.LoginMidas)
end

function RechargingMgr:OnRegisterTimer()
end

function RechargingMgr:LoginMidas()
	FLOG_INFO("RechargingMgr:LoginMidas()")
	PayUtil.Login(LoginMgr:GetRoleID(), LoginMgr:GetWorldID())
end

function RechargingMgr:ShowMainPanel()
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_REBATE, true) then
		FLOG_ERROR("Recharging system is not opened yet.")
		return
	end
	if self.bIsReadyToShowMainPanel or not self:ShouldShowShopkeeper() then
		self:DoShowMainPanel()
	else
		self.bIsPendingShowMainPanel = true
		if nil == self.SceneActor then
			self:PreloadScene()
		end
	end
end

function RechargingMgr:DoShowMainPanel()
	UIViewMgr:ShowView(UIViewID.RechargingBgModelPanel)
	UIViewMgr:ShowView(UIViewID.RechargingMainPanel)
end

function RechargingMgr:CloseMainPanel()
	UIViewMgr:HideView(UIViewID.RechargingMainPanel)
	UIViewMgr:HideView(UIViewID.RechargingBgModelPanel)
end

function RechargingMgr:ShowGiftPanel()
	RechargingBgModelVM.bInGift = true
	UIViewMgr:ShowView(UIViewID.RechargingGiftPanel)
end

function RechargingMgr:OnGiftPanelStartHide(Delay)
	RechargingBgModelVM.bInGift = false
	self:RegisterTimer(function() UIViewMgr:ShowView(UIViewID.RechargingMainPanel, {bFromGift = true}) end, Delay)
end

function RechargingMgr:OnGiftPanelHide()
	RechargingBgModelVM.bInGift = false
end

function RechargingMgr:Recharge(Order, Crystas, Bonus, View)
	FLOG_INFO("Recharge amount: "..tostring(Crystas))
	FLOG_INFO("Recharge bonus: "..tostring(Bonus))
	self.CurrentRequestOrder = Order
	self.CurrentRequestCrystas = Crystas
	self.CurrentRequestBonus = Bonus
	self.CurrentRequestSum = Crystas + Bonus
	PayUtil.BuyCoins(Order,
	function(_, BillData) self:OnBillReceived(BillData) end,
	function(_) self:OnLoginExpired() end,
	nil, -- 切后台可能导致米大师回调丢失，不再使用
	function(_, GoodsData) self:OnGoodsReceived(GoodsData) end,
	View)
end

function RechargingMgr:OnBillReceived(BillData)
	if BillData == nil then
		FLOG_ERROR("Cannot get pay bill data")
		return
	end

	if BillData.URL == "" then
		FLOG_ERROR("Pay bill is empty")
	end
end

function RechargingMgr:OnLoginExpired()
	FLOG_ERROR("Login expired!")
end

function RechargingMgr:ShowMidasPayFinishedTips(PayReturnData)
	local ResultCode = PayReturnData.ResultCode
	FLOG_INFO("RechargingMgr:ShowMidasPayFinishedTips, ResultCode:%d", ResultCode)
	local TipsContent = ""
	if ResultCode == -1 then
		TipsContent = LSTR(940003)
	elseif ResultCode == 2 then
		TipsContent = LSTR(940002)
	elseif ResultCode == 3 then
		TipsContent = LSTR(940034)
	elseif ResultCode == 4 then
		TipsContent = LSTR(940035)
	elseif ResultCode == 5 then
		TipsContent = LSTR(940036)
	elseif ResultCode == 6 then
		TipsContent = LSTR(940034)
	elseif ResultCode == 8 then
		TipsContent = LSTR(940037)
	elseif ResultCode == 9 then
		TipsContent = LSTR(940038)
	elseif ResultCode == 10 then
		TipsContent = LSTR(940039)
	elseif ResultCode == 11 then
		TipsContent = LSTR(940039)
	elseif ResultCode == 13 then
		TipsContent = LSTR(940040)
	end

	if TipsContent ~= "" then
		MsgTipsUtil.ShowTips(TipsContent)
	end
end

function RechargingMgr:OnGoodsReceived(GoodsData)
	self:OnRechargeSucceed(self.CurrentRequestSum)
end

function RechargingMgr:OnRechargeSucceed(Quantity)
	FLOG_INFO("Recharge succeeded. Append %d crystas", Quantity)
	self.Crystas = self.Crystas + Quantity

	-- RechargingRewardVM:SetType(RechargingDefine.RewardType.Crystas)
	-- RechargingRewardVM:UpdateVM({Title = LSTR(940004), IsQuantity=true, Quantity=Quantity})
	-- UIViewMgr:ShowView(UIViewID.RechargingRewardWin)
	local ItemList = {{ResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS, Num = Quantity}}
	UIViewMgr:ShowView(UIViewID.CommonRewardPanel, {Title = LSTR(940004), ItemList = ItemList,
		CloseCallback = function() self:OnRewardWinHide(RechargingDefine.RewardType.Crystas) end})
end

function RechargingMgr:OnRewardWinHide(RewardType)
	local TrueRewardType = nil ~= RewardType and RewardType or RechargingRewardVM.RewardType
	if TrueRewardType == RechargingDefine.RewardType.Crystas then
		RechargingMainVM:RechargeStall(self.CurrentRequestOrder)
		RechargingMainVM:RechargeStall(0) -- 归零避免重复值导致不触发OnValueChanged
		-- self:CheckRewardAction(RechargingDefine.RewardActionType.Recharge)
	end
	self:QueryRewardState()
end

function RechargingMgr:OnMainPanelShow()
	self:QueryRewardState()
end

function RechargingMgr:OnRewardReceived(RewardID)
	-- 奖品获取弹窗
	local RewardCfgData = RechargeRewardCfg:FindCfg(string.format("ID = %d", RewardID))
	local ItemList = {}
	for _, ItemID in pairs(RewardCfgData.RewardID) do
		local ItemData = {ResID = ItemID, Num = 1}
		table.insert(ItemList, ItemData)
	end
	UIViewMgr:ShowView(UIViewID.CommonRewardPanel, {Title = LSTR(940005), ItemList = ItemList})
	self:QueryRewardState()
	EventMgr:SendEvent(_G.EventID.RechargeRewardReceived, {RewardID = RewardID})
end

function RechargingMgr:OnServiceClicked()
	UIViewMgr:ShowView(UIViewID.RechargingServiceWin)
end

function RechargingMgr:OnHelpClicked()
	UIViewMgr:ShowView(UIViewID.RechargingHelpWin)
end

-- UI无关
function RechargingMgr:GetBalance()
	self.Crystas = RechargingUtil.GetBalance()
	return self.Crystas
end

function RechargingMgr:QueryRewardState()
	local MsgID = CS_CMD.CS_CMD_PAY
	local SubMsgID = CS_PAY_CMD.CS_CMD_PAY_QUERY_RECHARGE_AWARD
	local MsgBody = {
        Cmd = SubMsgID,
        QueryRechargeAward = {}
    }
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function RechargingMgr:ApplyForReward(RewardID)
	-- 检查是否可领取奖励
	local RewardCfgData = RechargeRewardCfg:FindCfg(string.format("ID = %d", RewardID))
	local BagLeftNum = BagMgr:GetBagLeftNum()
	if nil ~= BagLeftNum and BagLeftNum < #RewardCfgData.RewardID then
		FLOG_INFO(string.format("Reward count %d but bag left num is %d", #RewardCfgData.RewardID, BagLeftNum))
		MsgTipsUtil.ShowTips(LSTR(940006))
		return
	end

	-- 请求奖励
	local MsgID = CS_CMD.CS_CMD_PAY
	local SubMsgID = CS_PAY_CMD.CS_CMD_PAY_RECHARGE_AWARD
	local MsgBody = {
        Cmd = SubMsgID,
        RechargeAward = {
			RewardID = RewardID
		}
    }
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function RechargingMgr:OnNetMsgRewardStateUpdate(MsgBody)
	if nil == MsgBody or nil == MsgBody.QueryRechargeAward then
		return
	end

	local MaxRewardCount = self:GetMaxRewardCount()
	self.NextRewardID = MsgBody.QueryRechargeAward.NextRewardID
	self.AlreadyGotRewardIDs = MsgBody.QueryRechargeAward.AlreadyGet
	self.RewardState = RechargingDefine.RewardState.Exhausted
	local CanGotRewardCount = self.NextRewardID > 0 and self.NextRewardID - 1 or MaxRewardCount

	if #self.AlreadyGotRewardIDs < CanGotRewardCount then
		self.RewardState = RechargingDefine.RewardState.Ready
	elseif self.NextRewardID > 0 then
		self.RewardState = RechargingDefine.RewardState.NotReady
	end

	if self.NextRewardID > 0 then
		local RewardCfgData = RechargeRewardCfg:FindCfg(string.format("ID = %d", self.NextRewardID))
		if nil == RewardCfgData then
			_G.FLOG_ERROR(string.format("Reward %d not configured in c_recharge_reward_cfg! Reward not updated.", self.NextRewardID))
			return
		end

		self.RestAmountToApplyReward = (RewardCfgData.AccumulatedFund - MsgBody.QueryRechargeAward.TotalAmount) / 100
	else
		self.RestAmountToApplyReward = 0
	end

	if self.RewardState == RechargingDefine.RewardState.Ready then
		RedDotMgr:AddRedDotByID(RechargingDefine.RedDotID)
	else
		RedDotMgr:DelRedDotByID(RechargingDefine.RedDotID)
	end
	RechargingMainVM:SwitchRewardState(self.RewardState, self.RestAmountToApplyReward)
end

function RechargingMgr:OnNetMsgRewardApplication(MsgBody)
	if MsgBody.RecharAward.RewardID > 0 then
		FLOG_INFO("Reward received.")
		self:OnRewardReceived(MsgBody.RecharAward.RewardID)
	else
		_G.FLOG_ERROR("Reward application rejected.")
	end
end

function RechargingMgr:OnNetMsgPayNotify(MsgBody)
	self:QueryRewardState()
end

function RechargingMgr:OnNetMsgErrNotify(MsgBody)
	local Msg = MsgBody
	if nil == Msg then
		return
	end

	FLOG_INFO("[RechargingMgr:OnNetMsgErrNotify] %s", _G.table_to_string(MsgBody))
	if Msg.Cmd and Msg.SubCmd and Msg.Cmd == CS_CMD.CS_CMD_PAY and Msg.SubCmd == CS_PAY_CMD.CS_CMD_PAY_DISTRIBUTE_ORDER then
		if Msg.ErrCode == nil then
			FLOG_WARNING("[RechargingMgr:OnNetMsgErrNotify] ErrCode is nil")
			return
		end

		-- ErrCode:5 票据过期
		if Msg.ErrCode == 5 then
			-- 授权过期提示
			local function Callback()
				FLOG_INFO("[RechargingMgr:OnNetMsgErrNotify] Callback. ChannelID:%s", LoginMgr.ChannelID)
				if MSDKDefine.ChannelID.QQ == LoginMgr.ChannelID then
					_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.QQ, MSDKDefine.LoginPermissions.QQ.All, "", "")
				elseif MSDKDefine.ChannelID.WeChat == LoginMgr.ChannelID then
					if AccountUtil.IsWeChatInstalled() then
						_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.WeChat,
								table.concat(MSDKDefine.LoginPermissions.WeChat, ",") -- 获取所有权限
						, "", "")
					else
						_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.WeChat,
								table.concat(MSDKDefine.LoginPermissions.WeChat, ",") -- 获取所有权限
						, "", "{\"QRCode\":true}")
					end
				end
			end
			-- 940028 授权已过期，请重新授权
			MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(940028), Callback, nil, LSTR(10003), LSTR(10002))

		else
			-- ErrCode:137002 通用的背包满错误码
			if Msg.ErrCode > 137000 and Msg.ErrCode <= 138000 then
				MsgTipsUtil.ShowTipsByID(Msg.ErrCode, nil, table.unpack(Msg.ErrMsg))
			end
		end
	end
end

function RechargingMgr:OnLogin(Params)
	if _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_REBATE, true) then
		self:QueryRewardState()
	end
end

function RechargingMgr:OnMainBodyUpdated(Params)
	if nil == Params or Params.ULongParam1 ~= self.ShopkeeperEntityID then
		return
	end

	local Shopkeeper = self:GetShopkeeper()
	if nil == Shopkeeper then
		return
	end

	-- 保证相机未看向角色状态下锚定相机时，能获取到正确Socket位置
	Shopkeeper:GetMeshComponent().VisibilityBasedAnimTickOption = _G.UE.EVisibilityBasedAnimTickOption.AlwaysTickPoseAndRefreshBones
	FLOG_INFO("Ready to show recharging page!")
	if self.bIsPendingShowMainPanel then
		self:DoShowMainPanel()
		self.bIsPendingShowMainPanel = false
	end
	self.bIsReadyToShowMainPanel = true

    self.SceneActor:UpdateLights(Shopkeeper, self.LightPreset)
    LightMgr:RecordLightPreset(self.SceneActor, self.LightPreset)
end

--- 关闭按钮替换为返回
---@param Flag boolean 为true时替换为返回
function RechargingMgr:OnChangedMainPanelCloseBtnToBack(Flag)
	if self.MainPanel ~= nil then
		local PathBack = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Com_Btn_Close_png.UI_Com_Btn_Close_png'"
		if Flag then
			PathBack = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Com_Btn_Back_png.UI_Com_Btn_Back_png'"
		end
		UIUtil.ButtonSetBrush(RechargingMgr.MainPanel.ButtonClose.Btn_Close, PathBack)
	end
end

-- 全局表数据
function RechargingMgr:GetMaxRewardCount()
	if self.MaxRewardCount == 0 then
		self.MaxRewardCount = RechargeGlobalCfg:FindFirstAsInt(ProtoRes.recharge_global_cfg_id.RECHARGE_GLOBAL_CFG_REWARD_COUNT)
	end

	return self.MaxRewardCount
end

function RechargingMgr:GetCharacterShowQuestID()
	if self.CharacterShowQuestID == 0 then
		self.CharacterShowQuestID = RechargeGlobalCfg:FindFirstAsInt(ProtoRes.recharge_global_cfg_id.RECHARGE_CHARACTER_SHOW_QUEST_ID)
	end

	return self.CharacterShowQuestID
end

function RechargingMgr:GetCharacterShowAction()
	if self.CharacterShowAction == "" then
		self.CharacterShowAction = RechargeGlobalCfg:FindFirst(ProtoRes.recharge_global_cfg_id.RECHARGE_CHARACTER_SHOW_ACTION)
	end

	return self.CharacterShowAction
end

function RechargingMgr:GetCharacterRewardApplyAction(Index)
	if nil == self.CharacterRewardApplyActions then
		self.CharacterRewardApplyActions = RechargeGlobalCfg:FindValue(
			ProtoRes.recharge_global_cfg_id.RECHARGE_CHARACTER_REWARD_APPLY_ACTION, "Value")
	end

	if nil == self.CharacterRewardApplyActions then
		FLOG_ERROR("Cannot find reward apply action in database")
		return nil
	end

	return self.CharacterRewardApplyActions[Index]
end

-- function RechargingMgr:GetCharacterRewardActionID(Index)
-- 	if nil == self.CharacterRewardActionIDs then
-- 		self.CharacterRewardActionIDs = RechargeGlobalCfg:FindValue(
-- 			ProtoRes.recharge_global_cfg_id.RECHARGE_CHARACTER_REWARD_ACTION_ID, "Value")
-- 	end

-- 	if nil == self.CharacterRewardActionIDs[Index] then
-- 		return nil
-- 	end

-- 	return tonumber(self.CharacterRewardActionIDs[Index])
-- end

function RechargingMgr:GetCharacterRestActionID()
	if self.CharacterRestActionID == 0 then
		self.CharacterRestActionID = RechargeGlobalCfg:FindFirstAsInt(ProtoRes.recharge_global_cfg_id.RECHARGE_CHARACTER_REST_ACTION_ID)
	end

	return self.CharacterRestActionID
end

function RechargingMgr:GetCharacterInteractActionID(Index)
	if nil == self.CharacterInteractActionIDs then
		self.CharacterInteractActionIDs = RechargeGlobalCfg:FindValue(
			ProtoRes.recharge_global_cfg_id.RECHARGE_CHARACTER_INTERACT_ACTION_ID, "Value")
	end

	if nil == self.CharacterInteractActionIDs[Index] then
		return nil
	end

	return tonumber(self.CharacterInteractActionIDs[Index])
end

function RechargingMgr:GetCharacterTransitionAction()
	if self.CharacterTransitionAction == "" then
		self.CharacterTransitionAction = RechargeGlobalCfg:FindFirst(
			ProtoRes.recharge_global_cfg_id.RECHARGE_CHARACTER_TRANSITION_ACTION)
	end

	return self.CharacterTransitionAction
end

function RechargingMgr:GetInteractCD()
	if self.InteractCD == 0 then
		self.InteractCD = RechargeGlobalCfg:FindFirstAsInt(ProtoRes.recharge_global_cfg_id.RECHARGE_CHARACTER_INTERACT_CD)
	end

	return self.InteractCD
end

function RechargingMgr:CreateScene(Callback)
	if nil ~= self.SceneActor then
        FLOG_WARNING("RechargingMgr: Scene actor is already created")
        return
    end
    
	local SceneActorPath = "Class'/Game/UI/Render2D/Recharging/BP_Render2DRechargeActor_v02.BP_Render2DRechargeActor_v02_C'"
	local LightPresetPath = "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_Recharge/Recharge_c1101.Recharge_c1101'"
	local SystemLightCfgData = SystemLightCfg:FindCfgByKey(23)
    if nil ~= SystemLightCfgData and nil ~= SystemLightCfgData.LightPresetPaths[3] then
		LightPresetPath = SystemLightCfgData.LightPresetPaths[3]
	end
	if CommonUtil.IsWithEditor() then
		_G.LightMgr:PrintLightPreset(LightPresetPath)
	end

    local function SceneLoadCallback()
        local Class1 = _G.ObjectMgr:GetClass(SceneActorPath)
        if Class1 == nil then
            return
        end

		-- 创建场景Actor
		local OriginLocation = RenderSceneDefine.Location
		local Rotation = _G.UE.FRotator(0, 0, 0)
        self.SceneActor = CommonUtil.SpawnActor(Class1, OriginLocation, Rotation)

		-- 创建看板娘
		local Params = _G.UE.FCreateClientActorParams()
		Params.bUIActor = true
		self.ShopkeeperEntityID = _G.UE.UActorManager:Get():CreateClientActorByParams(_G.UE.EActorType.Npc, 0, ShopkeeperNPCID,
			OriginLocation, Rotation, Params)
		local Shopkeeper = ActorUtil.GetActorByEntityID(self.ShopkeeperEntityID)
		_G.UE.UVisionMgr.Get():RemoveFromVision(Shopkeeper)
		if nil ~= Shopkeeper then
			Shopkeeper:GetAvatarComponent():SwitchForceMipStreaming(true)
			Shopkeeper:SetOverrideFadeInTime(0.0)
		end
        self.LightPreset = _G.ObjectMgr:LoadObjectSync(LightPresetPath)
		self.LightPresetRef = _G.UnLua.Ref(self.LightPreset)
		local ChildActorComp = self.SceneActor:GetComponentByClass(_G.UE.UFMChildActorComponent)
		if nil ~= ChildActorComp then
			ChildActorComp.ChildActorReCreateDelegate = { self.SceneActor, function ()
				local SceneCaptureComp = self.SceneActor:GetComponentByClass(_G.UE.USceneCaptureComponent2D)
				SceneCaptureComp:ShowOnlyActorComponents(Shopkeeper, true)
        	end }
		end
		if nil ~= Callback then
            Callback()
        end
    end

	--edit by sammrli 预加载灯光关卡
	-- local function LightLevelLoadCallback()
	_G.ObjectMgr:LoadClassAsync(SceneActorPath, SceneLoadCallback, ObjectGCType.LRU)
	-- end
	-- _G.LightMgr:PreloadLightLevel(LightDefine.LightLevelID.LIGHT_LEVEL_ID_RECHARGE, LightLevelLoadCallback)
end

-- 预加载场景，建议在打开前置界面（如商城）时执行
function RechargingMgr:PreloadScene()
	local function PreloadCallback()
		if nil ~= self.SceneActor then
			self.SceneActor:SetActorHiddenInGame(true)
			_G.UE.UActorManager.Get():HideActor(self.ShopkeeperEntityID, true)
		end
	end
	self:CreateScene(PreloadCallback)
end

-- 开启/关闭场景
function RechargingMgr:SwitchScene(bOn)
	if nil == self.SceneActor or not CommonUtil.IsObjectValid(self.SceneActor) then
		return
	end

	self.SceneActor:SetActorHiddenInGame(not bOn)
	_G.UE.UActorManager.Get():HideActor(self.ShopkeeperEntityID, not bOn)

	-- local CameraMgr = _G.UE.UCameraMgr.Get()
	-- if CameraMgr == nil then
	-- 	return
	-- end
	-- if bOn then
	-- 	CameraMgr:SwitchCamera(self.SceneActor, 0)
	-- else
	-- 	CameraMgr:ResumeCamera(0, true, self.SceneActor)
	-- end
end

function RechargingMgr:OpenScene(Callback)
	local function DoOpenScene()
		self:SwitchScene(true)
		if nil ~= Callback then
			Callback()
		end
	end

	if nil == self.SceneActor then
		self:CreateScene(DoOpenScene)
	else
		DoOpenScene()
	end
end

function RechargingMgr:DestroyScene()
	self:SwitchScene(false)

	CommonUtil.DestroyActor(self.SceneActor)
	self.SceneActor = nil
	_G.UE.UActorManager.Get():RemoveClientActor(self.ShopkeeperEntityID)
	self.ShopkeeperEntityID = -1
	self.LightPresetRef = nil
	self.bIsReadyToShowMainPanel = false
end

function RechargingMgr:GetShopkeeper()
	if self.ShopkeeperEntityID <= 0 then
		return nil
	end
	return ActorUtil.GetActorByEntityID(self.ShopkeeperEntityID)
end

function RechargingMgr:CameraFocusScreenLocation(ViewportPos, SocketName, bInterp)
	if nil == self.SceneActor then
		FLOG_ERROR("Scene actor is nil")
		return
	end

	local Shopkeeper = self:GetShopkeeper()
	if nil == Shopkeeper then
		FLOG_ERROR("Shopkeeper is nil")
		return
	end

	-- 计算反投影向量单位向量
    local CamLocation = _G.UE.FVector()
	local TargetDirection = _G.UE.FVector()
	local DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(_G.FWORLD())
	UIUtil.DeprojectScreenToWorld(ViewportPos * DPIScale, CamLocation, TargetDirection, 0)

	-- 计算反投影向量长度
	local FOV = _G.UE.UCameraMgr.Get():GetCurrentPlayerManagerLockedFOV()
	local AspectRatio = _G.UE.UCameraMgr.Get():GetAspectRatio()
	local TanHalfFOVY = (1 / AspectRatio) * math.tan(math.rad(FOV) * 0.5)
	local ShopkeeperHalfHeight = Shopkeeper:GetAvatarComponent():GetExactHeight() * 0.5
	local ShopkeeperVisibleRatio = 0.9
	local Depth = ShopkeeperVisibleRatio * ShopkeeperHalfHeight / TanHalfFOVY

	local CameraForward = _G.UE.FVector(-1, 0, 0) -- 这里假设相机朝向固定
	local CosTargetForward = CameraForward:Dot(TargetDirection)
	-- FLOG_INFO("Angle: "..tostring(math.deg(math.acos(CosTargetForward))))
	local DirectionLength = Depth / CosTargetForward

	-- 反推相机偏移量
	local TargetLocation = CamLocation + TargetDirection * DirectionLength
	local SocketLocation = Shopkeeper:GetSocketLocationByName(SocketName)
	-- FLOG_INFO("Socket location: "..tostring(SocketLocation))
	local NeedMoveVector = TargetLocation - SocketLocation
	TargetLocation = self:GetSpringArmLocation() - NeedMoveVector
	self:SetSpringArmLocation(TargetLocation, bInterp)
end

function RechargingMgr:FocusSceneCapture(OffsetCenterRatioY, EID)
	if nil == self.SceneActor then
		FLOG_ERROR("Scene actor is nil")
		return
	end

	local Shopkeeper = self:GetShopkeeper()
	if nil == Shopkeeper then
		FLOG_ERROR("Shopkeeper is nil")
		return
	end

	-- 根据角色在视口中纵向占比计算深度值
	local SceneCaptureComp = self.SceneActor:GetComponentByClass(_G.UE.USceneCaptureComponent2D)
	local SizeX = 1
	local SizeY = 1
	if nil ~= SceneCaptureComp.TextureTarget then
		SizeX = SceneCaptureComp.TextureTarget.SizeX
		SizeY = SceneCaptureComp.TextureTarget.SizeY
	end
	local FOVX = SceneCaptureComp.FOVAngle
	local TanHalfFOVY = SizeY / SizeX * math.tan(math.rad(FOVX) * 0.5)
	local ShopkeeperHalfHeight = Shopkeeper:GetAvatarComponent():GetExactHeight() * 0.5
	local ShopkeeperVisibleRatio = 0.88
	local Depth = ShopkeeperVisibleRatio * ShopkeeperHalfHeight / TanHalfFOVY

	-- 根据视口在当前深度的半高与目标点在屏幕上Y轴方向偏移率，利用相似三角形，算出相机注视点的高度偏差
	local ViewHalfHeight = Depth * TanHalfFOVY
	local HeightOffset = ViewHalfHeight * OffsetCenterRatioY

	local ActorTransform = self.SceneActor:GetTransform()
	local SocketLocation = Shopkeeper:GetSocketLocationByName(EID)
	local FocusLoc = _G.UE.UKismetMathLibrary.InverseTransformLocation(ActorTransform, SocketLocation) - 
		_G.UE.FVector(0, 0, HeightOffset)
	RechargingMgr:SetSpringArmLocation(FocusLoc)
	RechargingMgr:GetSpringArmComp().TargetArmLength = Depth
end

function RechargingMgr:GetSpringArmComp()
	if nil == self.SceneActor then
		FLOG_ERROR("Scene actor is not initialized!")
		return nil
	end

	local SpringArmComp = self.SceneActor:GetComponentByClass(_G.UE.USpringArmComponent)
	if nil == SpringArmComp then
		FLOG_ERROR("Spring arm is nil")
		return nil
	end
	return SpringArmComp
end

function RechargingMgr:GetSpringArmLocation()
	local SpringArmComp = self:GetSpringArmComp()
	if nil == SpringArmComp then
		return _G.UE.FVector(0, 0, 0)
	end
	return SpringArmComp:GetRelativeLocation()
end

function RechargingMgr:SetSpringArmLocation(TargetLocation, bInterp)
	local SpringArmComp = self:GetSpringArmComp()
	if nil == SpringArmComp then
		return
	end
	if nil ~= bInterp and bInterp then
		SpringArmComp.bEnableCameraLag = true
		SpringArmComp.CameraLagSpeed = 10
	else
		SpringArmComp.bEnableCameraLag = false
	end
	SpringArmComp:K2_SetRelativeLocation(TargetLocation, false, nil, false)
end

function RechargingMgr:TurnShopkeeperToCamera()
	if nil == self.SceneActor then
		FLOG_ERROR("Scene actor is nil")
		return
	end

	local Shopkeeper = self:GetShopkeeper()
	if nil == Shopkeeper then
		FLOG_ERROR("Shopkeeper is nil")
		return
	end

	local CameraComp = self.SceneActor:GetComponentByClass(_G.UE.UCameraComponent)
	if nil == CameraComp then
		FLOG_ERROR("Camera is nil")
		return
	end

	local DirectionVec = CameraComp:K2_GetComponentLocation() - Shopkeeper:K2_GetActorLocation()
	DirectionVec.Z = 0
	local OldShopkeeperRotator = Shopkeeper:K2_GetActorRotation()
	local NewShopkeeperRotator = DirectionVec:ToRotator()
	local DeltaRotator = NewShopkeeperRotator - OldShopkeeperRotator
	Shopkeeper:K2_SetActorRotation(NewShopkeeperRotator, false)

	-- -- 平行光随角色一起转
	-- local DirectionalLightComp = self.SceneActor:GetComponentByClass(_G.UE.UDirectionalLightComponent)
	-- if nil ~= DirectionalLightComp then
	-- 	DirectionalLightComp:K2_SetRelativeRotation(DirectionalLightComp:GetRelativeRotation() + DeltaRotator, false, nil, false)
	-- end
end

function RechargingMgr:PlayActionTimeline(ID, Position)
	local Shopkeeper = self:GetShopkeeper()
	if nil == Shopkeeper then
		return
	end

	Shopkeeper:GetAnimationComponent():PlayActionTimeline(ID)
	if nil ~= Position then
		Shopkeeper:GetAnimationComponent():GetAnimInstance():Montage_SetPosition(nil, Position)
	end
	EventMgr:SendEvent(EventID.RechargeShopkeeperPlayAction)
end

function RechargingMgr:PlayAnimation(AnimPath)
	local Shopkeeper = self:GetShopkeeper()
	if nil == Shopkeeper then
		return
	end

	Shopkeeper:GetAnimationComponent():PlayAnimation(AnimPath)
	EventMgr:SendEvent(EventID.RechargeShopkeeperPlayAction)
end

-- function RechargingMgr:CheckRewardAction(ActionType)
-- 	if RechargingMainVM.RewardState == RechargingDefine.RewardState.Ready then
-- 		RechargingMgr:PlayActionTimeline(RechargingMgr:GetCharacterRewardActionID(ActionType))
-- 		FLOG_INFO("Reward is ready!")
-- 	end
-- end

function RechargingMgr:ShouldShowShopkeeper()
	return QuestMgr:GetQuestStatus(RechargingMgr:GetCharacterShowQuestID()) == ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_FINISHED
end

---------------------------------代金券相关-------------------------------------
---检查是否可以使用代金券
function RechargingMgr:CheckCanUseVoucher()
	--return _G.LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_COUPON)
	return false
end

---检查代金券是否足够
---@param Cost number 需要代金券数量
function RechargingMgr:CheckVoucherIsEnough(Cost)
	local RechargeParamCfg = require("TableCfg/RechargeParamCfg") 
	local BagMgr = _G.BagMgr
	local VoucherCfg = RechargeParamCfg:FindCfgByKey(ProtoRes.recharge_param_cfg_id.RECHARGE_PRAMETER_VOUCHERSID)
	if VoucherCfg and next(VoucherCfg) then
		local VoucherItemID = VoucherCfg.Value[1]
		local HasNum = BagMgr:GetItemNum(tonumber(VoucherItemID))
		if Cost and HasNum < Cost then
			local CurTime = TimeUtil.GetLocalTimeMS()
			if CurTime - self.LastVoucherTipTime > 3000 then
				--错误提示3000ms一条
				MsgTipsUtil.ShowErrorTips(LSTR("您背包内【代金券】数量不足，无法购买"))
				self.LastVoucherTipTime = TimeUtil.GetLocalTimeMS()
			end
			return false
		else
			return true
		end
	end
end

return RechargingMgr
