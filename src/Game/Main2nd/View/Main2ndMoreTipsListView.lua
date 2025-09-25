---
--- Author: richyczhou
--- DateTime: 2025-04-11 16:56
--- Description:
---

local UIView = require("UI/UIView")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local LuaClass = require("Core/LuaClass")
local Main2ndPanelDefine = require("Game/Main2nd/Main2ndPanelDefine")
local OperationUtil = require("Utils/OperationUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIUtil = require("Utils/UIUtil")

local FLOG_INFO = _G.FLOG_INFO
local MoreMenuType = Main2ndPanelDefine.MoreMenuType

---@class Main2ndMoreTipsListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewEntrance UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Main2ndMoreTipsListView = LuaClass(UIView, true)

function Main2ndMoreTipsListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewEntrance = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Main2ndMoreTipsListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Main2ndMoreTipsListView:OnInit()
    FLOG_INFO("[Main2ndMoreTipsListView:OnInit] ")
    self.TableViewSubListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewEntrance)
    self.TableViewSubListAdapter:SetOnClickedCallback(self.OnMenuItemClicked)
end

function Main2ndMoreTipsListView:OnDestroy()

end

function Main2ndMoreTipsListView:OnShow()
    FLOG_INFO("[Main2ndMoreTipsListView:OnShow] ")
    local Params = self.Params
    if nil == Params then
        return
    end
    local SubListData = Params.Data
    if nil == SubListData then
        return
    end

    self.TableViewSubListAdapter:UpdateAll(SubListData)
end

function Main2ndMoreTipsListView:OnHide()

end

function Main2ndMoreTipsListView:OnRegisterUIEvent()

end

function Main2ndMoreTipsListView:OnRegisterGameEvent()

end

function Main2ndMoreTipsListView:OnRegisterBinder()

end

function Main2ndMoreTipsListView:OnMenuItemClicked(Index, ItemData, ItemView)
    if not ItemData then
        return
    end
    FLOG_INFO("[Main2ndMoreTipsListView:OnMenuItemClicked] ID:%d, Name:%s " , ItemData.ID, ItemData.BtnName)

    if ItemData.BtnEntranceID == MoreMenuType.XinYue then
      if _G.U2 ~= nil and _G.U2.U2pmMgr ~= nil then
        _G.U2.U2pmMgr:ExportSource()
      end
    elseif ItemData.BtnEntranceID == MoreMenuType.Questionnaire then
        _G.MURSurveyMgr:ShowOrHideRedDot(false)
        _G.MURSurveyMgr:OpenMURSurvey(1, false, true, "", false)
    elseif ItemData.BtnEntranceID == MoreMenuType.CustomService then
        OperationUtil.OpenCustomService(OperationUtil.CustomServiceSceneID.MainPanel)
    elseif ItemData.BtnEntranceID == MoreMenuType.GameCenter then
        _G.AccountUtil.OpenUrl(OperationUtil.GameCenterUrl, 1, false, true, "", false)
    elseif ItemData.OpenType == 0 and not string.isnilorempty(ItemData.Url) then
        local Url = ItemData.Url
        if ItemData.BtnEntranceID == MoreMenuType.XinYue then
            --心悦内置面板的url需要单独处理
            Url = OperationUtil.GetXinYuePanelUrl(Url)
        end
        _G.AccountUtil.OpenUrl(Url, 1, false, true, "", false)
    elseif ItemData.BtnEntranceID == MoreMenuType.InviteQQFriends then
        _G.ShareMgr:GetArkInfo()
    elseif ItemData.BtnEntranceID == MoreMenuType.InviteWXFriends then
        _G.ShareMgr:SendNativeFriends()
    elseif ItemData.BtnEntranceID == MoreMenuType.InviteWXMoments then
        _G.ShareMgr:SendNativeMoments()
    else
        _G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(10004), _G.LSTR(100001), nil)
    end

    UIViewMgr:HideView(UIViewID.OperationChannelPanel)
end

return Main2ndMoreTipsListView