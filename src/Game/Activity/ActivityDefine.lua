---@author: fishhong 2023-02-02 16:58:46
---@活动的常量定义

local LSTR = _G.LSTR

local MainTabs = {
    {
        PageName = LSTR("未成年人保护"),
    },
}

local DemoActivityNoticeTitle = [=[未成年人防沉迷系统规则简介]=]
local DemoActivityNoticeContent = [=[各位光之战士：

          《最终幻想14：水晶世界》手游已经完成未成年人防沉迷新规接入，主要规则如下，请大家知晓：

1、游戏时长限制：未成年用户仅可在周五、周六、周日和法定节假日的20时至21时进行游戏；

2、游戏消费限制：未满12周岁的用户无法进行游戏充值；12周岁（含）以上未满16周岁的用户，单次充值上限50元人民币，每月充值上限200元人民币；16周岁（含）以上未成年玩家，单次充值上限100元人民币，每月充值上限400元人民币。

          具体规则请见国家新闻出版署《关于防止未成年人沉迷网络游戏的通知》，健康系统新规则覆盖后，所有玩家每日时长刷新时间改为每日0点，通过健康系统强制的时段、时长和消费管理，我们希望可以帮助孩子建立健康的游戏习惯，同时也尽量避免因为孩子的游戏行为可能导致的家庭矛盾。

          感谢大家的理解与支持！]=]

local ActivityDefine = {
    MainTabs = MainTabs,
    ActivityNotice = {Title = DemoActivityNoticeTitle, Content = DemoActivityNoticeContent}
}

return ActivityDefine