---
--- Author: user
--- DateTime: 2023-03-03 10:03
--- Description:仙人仙彩中奖履历界面item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local LSTR = _G.LSTR
local JumboCactpotMgr = _G.JumboCactpotMgr

---@class JumboCactpotRecordItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FBtn_CheckPlayer UFButton
---@field Text_LotteryNumber UFTextBlock
---@field Text_Quarter UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotRecordItemView = LuaClass(UIView, true)

function JumboCactpotRecordItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.FBtn_CheckPlayer = nil
    --self.Text_LotteryNumber = nil
    --self.Text_Quarter = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotRecordItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotRecordItemView:OnInit()
   
end

function JumboCactpotRecordItemView:OnDestroy()
end

function JumboCactpotRecordItemView:OnShow()
    local Data = self.Params.Data
    if nil == Data then
        return
    end
    self.Data = Data
	self.Text_LotteryNumber:SetText(string.format(LSTR(240072) , Data.LotteryNum)) -- 中奖号码：%d
    local Time = _G.DateTimeTools.GetDateTable(math.floor(tonumber(Data.Riqi) / 1000))
    local Text = string.format(LSTR(240073), Data.Term) -- "第%d期y.m.d"
    Text = string.gsub(Text, "y", tostring(Time.year))
    Text = string.gsub(Text, "m", tostring(Time.month))
    Text = string.gsub(Text, "d", tostring(Time.day))

	self.Text_Quarter:SetText(Text)
end 

function JumboCactpotRecordItemView:OnHide()
end

function JumboCactpotRecordItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtn_CheckPlayer, self.OnClickCheckPlayer)
end

-- 查看中奖名单    事件参数：对应第几期
function JumboCactpotRecordItemView:OnClickCheckPlayer()
    JumboCactpotMgr:OnClickRecordList(self.Params.Index, self.Params.Data.Term)
end

function JumboCactpotRecordItemView:OnRegisterGameEvent()
end

function JumboCactpotRecordItemView:OnRegisterBinder()
end

return JumboCactpotRecordItemView
