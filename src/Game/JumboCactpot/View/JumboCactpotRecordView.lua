-- ---
-- --- Author: user
-- --- DateTime: 2023-03-03 10:04
-- --- Description:仙人仙彩中奖履历界面
-- ---

-- local UIView = require("UI/UIView")
-- local LuaClass = require("Core/LuaClass")
-- -- local UIUtil = require("Utils/UIUtil")
-- local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
-- local EventID = require("Define/EventID")
-- -- local ProtoCS = require("Protocol/ProtoCS")

-- local LSTR = _G.LSTR
-- local  JumboCactpotMgr =  _G.JumboCactpotMgr
-- ---@class JumboCactpotRecordView : UIView
-- ---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
-- ---@field BG Comm2FrameSView
-- ---@field PopUpBG CommonPopUpBGView
-- ---@field TableView_List UTableView
-- ---@field TableView_Record UTableView
-- ---@field Text_WinnerList UFTextBlock
-- ---@field AnimSidebarClose UWidgetAnimation
-- ---@field AnimSidebarOpen UWidgetAnimation
-- ---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
-- local JumboCactpotRecordView = LuaClass(UIView, true)

-- function JumboCactpotRecordView:Ctor()
-- 	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
-- 	--self.BG = nil
-- 	--self.PopUpBG = nil
-- 	--self.TableView_List = nil
-- 	--self.TableView_Record = nil
-- 	--self.Text_WinnerList = nil
-- 	--self.AnimSidebarClose = nil
-- 	--self.AnimSidebarOpen = nil
-- 	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
-- end

-- function JumboCactpotRecordView:OnRegisterSubView()
-- 	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
-- 	self:AddSubView(self.BG)
-- 	self:AddSubView(self.PopUpBG)
-- 	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
-- end

-- function JumboCactpotRecordView:OnInit()
-- 	self.AniIndex = 0   --查看对应期数中奖人数
-- 	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_Record)
-- 	self.TableViewAdapterList = UIAdapterTableView.CreateAdapter(self, self.TableView_List)
-- 	self.TableViewAdapter:SetOnClickedCallback(self.OnSelectChanged)
-- end

-- function JumboCactpotRecordView:OnSelectChanged(Index, ItemData, ItemView)

-- end

-- function JumboCactpotRecordView:OnDestroy()

-- end

-- function JumboCactpotRecordView:OnShow()
-- 	self.RecordItemsInfos = JumboCactpotMgr:GetRecordItemsInfos()
-- 	self.TableViewAdapter:UpdateAll(self.RecordItemsInfos)
-- end

-- function JumboCactpotRecordView:OnHide()

-- end

-- function JumboCactpotRecordView:OnRegisterUIEvent()

-- end

-- function JumboCactpotRecordView:OnRegisterGameEvent()
-- 	self:RegisterGameEvent(EventID.JumboCactpotCheckPlayer, self.OnClickCheckPlayer)
-- end

-- function JumboCactpotRecordView:OnClickCheckPlayer(Index, Term)
-- 	if Index == self.AniIndex then
-- 		self:PlayAnimation(self.AnimSidebarClose)
-- 		self.AniIndex = 0
-- 	else
-- 		-- 请求查看中奖名单（index）
-- 		self.RecordListItemsInfos = JumboCactpotMgr:GetRecordListItemInfos()
-- 		self:PlayAnimation(self.AnimSidebarOpen)
-- 		self.AniIndex = Index
-- 		self.Text_WinnerList:SetText(string.format("%s%d%s", LSTR("第"), Term, LSTR("期中奖人名单")))
-- 		self.TableViewAdapterList:UpdateAll(self.RecordListItemsInfos[Index].RewardList)
-- 	end
-- end

-- function JumboCactpotRecordView:OnRegisterBinder()

-- end

-- return JumboCactpotRecordView