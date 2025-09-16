---
--- Author: Administrator
--- DateTime: 2023-09-21 15:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ScoreCfg = require("TableCfg/ScoreCfg")
local RichTextUtil = require("Utils/RichTextUtil")

---@class CurrencyConvertWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnOK CommBtnLView
---@field SizeBox USizeBox
---@field TableViewContent UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CurrencyConvertWinView = LuaClass(UIView, true)

function CurrencyConvertWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnOK = nil
	--self.SizeBox = nil
	--self.TableViewContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CurrencyConvertWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnOK)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CurrencyConvertWinView:OnInit()
	self.AdapterTableViewContent = UIAdapterTableView.CreateAdapter(self, self.TableViewContent)
end

function CurrencyConvertWinView:OnDestroy()

end

function CurrencyConvertWinView:OnShow()
	self.BG:SetTitleText(LSTR(490005))		--- 转化详情
	self.BtnOK:SetBtnName(LSTR(490007))		--- 确定
	if #ScoreMgr.IterationConvertInfos ~= 0 then
		local TempItemInfos = self:OnUpdateTempItemInfos()
		self.AdapterTableViewContent:UpdateAll(TempItemInfos)
	end
end

function CurrencyConvertWinView:OnUpdateTempItemInfos()
	local TempInfos = {}
	for _, value in ipairs(ScoreMgr.IterationConvertInfos) do
		local Item = {}
		local SourceID = value.SourceID					-- 原积分ID
		local SourceValue = value.SourceValue			-- 原积分数量
		local DestID = value.DestID						-- 目标积分ID
		local DestValue = value.Added					-- 目标积分数量
		local Overed = value.Overed
		local TempSourceCfg = ScoreCfg:FindCfgByKey(SourceID)
		local DestCfg = ScoreCfg:FindCfgByKey(DestID)
		local LocStr
		local TextDes
		local LocStr1 = LSTR(1050007)
		local LocStr2 = LSTR(1050006)
		if Overed > 0 then
			LocStr = LocStr1
			TextDes = string.format(LocStr, SourceValue, TempSourceCfg.NameText, DestValue + Overed, DestCfg.NameText, Overed, DestCfg.NameText)
		else
			LocStr = LocStr2
			TextDes = string.format(LocStr, SourceValue, TempSourceCfg.NameText, DestValue, DestCfg.NameText)
		end
		Item.TextDes = TextDes
		table.insert(TempInfos, Item)
	end
	return TempInfos
end

function CurrencyConvertWinView:OnHide()
	_G.EventMgr:SendEvent(_G.EventID.EquipmentCurrencyConvertViewHide)
	ScoreMgr:SendScoreIterationConvert(true)
	--- 查看转化详情后删除数据
	ScoreMgr.IterationConvertInfos = {}
end

function CurrencyConvertWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnOK, self.OnClickBtnOK)
end

function CurrencyConvertWinView:OnClickBtnOK()
	self:Hide()
end

function CurrencyConvertWinView:OnRegisterGameEvent()

end

function CurrencyConvertWinView:OnRegisterBinder()

end

return CurrencyConvertWinView