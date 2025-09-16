--
-- Author: enqingchen
-- Date: 2020-12-10 20:04:06
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local ProtoCS = require ("Protocol/ProtoCS")
local ProtoCommon = require ("Protocol/ProtoCommon")
local ReviveCfg = require("TableCfg/ReviveCfg")
local MapCfg = require("TableCfg/MapCfg")
local DeathTipsBoxView = LuaClass(UIView, true)
local UIUtility = _G.UIUtil
function DeathTipsBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.CommonPlaySound_UIBP = nil
	--self.KeepBtn = nil
	--self.MessageLine1 = nil
	--self.MessageLine2 = nil
	--self.ReviveBtn = nil
	--self.RichText_Line01_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DeathTipsBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CommonPlaySound_UIBP)
	self:AddSubView(self.KeepBtn)
	self:AddSubView(self.ReviveBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DeathTipsBoxView:OnInit()
	-- if (self.PopUpBG ~= nil) then
	-- 	self.PopUpBG:SetCallback(self, self.OnClickKeep)
	-- end
	-- 长按压开启
	-- self.ReviveBtn.ParamLongPress = true
	-- self.ReviveBtn.ParamPressTime = 3 -- time 3s
end

function DeathTipsBoxView:OnDestroy()

end

--配置了复活类型为回城点，使用默认显示
local function IsUseDefaultShow()
	local PWorldTableCfg = _G.PWorldMgr:GetCurrPWorldTableCfg()
	if (PWorldTableCfg == nil) then
		return true;
	end
	local ReviveTableCfg = ReviveCfg:FindCfgByKey(PWorldTableCfg.ReviveRuleID)
	if (ReviveTableCfg == nil) then
		return true;
	end
	if (ProtoCommon.ReviveType.REVIVE_TYPE_BACK_POINT == ReviveTableCfg.ReviveType) then
		return true;
	end

	return false
end

local function SetVisibleForReturnPointText(self, isVisible)
	if (self.ReturnPointNameText ~= nil) then
		UIUtility.SetIsVisible(self.ReturnPointNameText, isVisible)
	end
end

function DeathTipsBoxView:OnShow()
	if (self.bUseDefault == nil) then
		self.bUseDefault = IsUseDefaultShow()
	end

	if (self.bUseDefault) then
		UIUtility.SetIsVisible(self.MessageLine1, false)
		UIUtility.SetIsVisible(self.MessageLine2, true)

		-- 这里去显示一下复活点的名字，如果是水晶则显示水晶名字，如果是地图，则显示地图的名字
		local _params = self.Params
		if (_params ~= nil) then
			local _mapID = _params.MapID
			if(_mapID ~= nil and _mapID > 0) then
				-- 去地图表格里面拿名字
				local MapTableCfg = MapCfg:FindCfgByKey(_mapID)
				if (MapTableCfg == nil) then
					print("MapResID is error, MapResID=" .. tostring(_mapID))
					SetVisibleForReturnPointText(self, false)
				else
					local _name = MapTableCfg.DisplayName
					SetVisibleForReturnPointText(self, true)
					if (self.ReturnPointNameText~=nil) then
						self.ReturnPointNameText:SetText(string.format(_G.LSTR(460005), _name)) --当前返回点:%s
					end
				end
			else 
				-- 这里看下是否有水晶ID
				local _cristalID = _params.CristalID
				if(_cristalID ~= nil and _cristalID > 0 ) then
					-- 这里取水晶点拿一下内容
					SetVisibleForReturnPointText(self, true)
				else
					-- 这里去报错，隐藏一下好了
					SetVisibleForReturnPointText(self, false)
				end
			end
		else
			SetVisibleForReturnPointText(self, false)
		end
	else
		UIUtility.SetIsVisible(self.MessageLine1, true)
		UIUtility.SetIsVisible(self.MessageLine2, false)
		SetVisibleForReturnPointText(self, false)

		local PWorldName = _G.LSTR(460007)  --神秘地带
		local PWorldTableCfg = _G.PWorldMgr:GetCurrPWorldTableCfg()
		if (PWorldTableCfg ~= nil) then
			PWorldName = PWorldTableCfg.PWorldName
		end
		self.RichText_Line01_1:SetText(string.format(_G.LSTR(460008), PWorldName))  --即将回到 "%s" 的开始地点
	end

	if self.AnimScale ~= nil then
		self:PlayAnimation(self.AnimScale)
	end
end

function DeathTipsBoxView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	self.BG:SetTitleText(_G.LSTR(460014))	--"无法战斗提示"
	self.KeepBtn:SetText(_G.LSTR(460012)) -- "保 留"
	self.ReviveBtn:SetButtonText(_G.LSTR(10002)) -- "确  认"
end

function DeathTipsBoxView:OnHide()
end

function DeathTipsBoxView:OnRegisterUIEvent()
	self.bUseDefault = IsUseDefaultShow()
	if (self.bUseDefault) then
		-- 长按压关闭
		self.ReviveBtn.ParamLongPress = false
		self.ReviveBtn.ParamPressTime = 0
	else
		-- 长按压开启
		self.ReviveBtn.ParamLongPress = true
		self.ReviveBtn.ParamPressTime = 3
	end

	if self.ReviveBtn.ParamLongPress then
		UIUtility.AddOnLongPressedEvent(self, self.ReviveBtn, self.OnClickRevive)
	else
		UIUtility.AddOnClickedEvent(self, self.ReviveBtn, self.OnClickRevive)
	end

	if self.KeepBtn.ParamLongPress then
		UIUtility.AddOnLongPressedEvent(self, self.KeepBtn, self.OnClickKeep)
	else
		UIUtility.AddOnClickedEvent(self, self.KeepBtn, self.OnClickKeep)
	end
end

function DeathTipsBoxView:OnRegisterGameEvent()

end

function DeathTipsBoxView:OnRegisterTimer()

end

function DeathTipsBoxView:OnRegisterBinder()

end

function DeathTipsBoxView:OnClickKeep()
	if self.AnimScale ~= nil then
		self:PlayAnimationReverse(self.AnimScale)
		_G.TimerMgr:AddTimer(nil, self.ShowDeatFloatButton, self.AnimScale:GetEndTime())
	else
		self:ShowDeatFloatButton()
	end
end

function DeathTipsBoxView:ShowDeatFloatButton()
	_G.UIViewMgr:ShowView(_G.UIViewID.DeathFloatButton)
	_G.UIViewMgr:HideView(_G.UIViewID.BeDeathView)
end

function DeathTipsBoxView:OnClickRevive()
	local MsgID = ProtoCS.CS_CMD.CS_CMD_REVIVE
    local SubMsgID = ProtoCS.CS_REVIVE_CMD.CS_REVIVE_CMD_CONFIRM
    local ReviveConfirm = { Type = ProtoCommon.ReviveChannelType.REVIVE_CHANNEL_DEFAULT, IsAccepted = nil};
    local MsgBody =
    {
        Cmd = SubMsgID,
        Confirm = ReviveConfirm,
    }

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	self:Hide()
end

return DeathTipsBoxView