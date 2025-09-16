-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _1_1 = '[10214,10215,10216,10217,10218,10219,10220,10221,0,0]',
    _1_2 = '[10622,10623,10624,10625,10626,10628,10629,10631,0,0]',
    _1_3 = '[30212,30213,30214,30215,30216,0,0,0,0,0]',
    _1_4 = '[30315,30321,30322,0,0,0,0,0,0,0]',
    _1_5 = '[11037,11038,11039,11040,11041,11042,11043,11044,11045,0]',
    _1_6 = '[]',
    _3_1 = '[32,0,0,0]',
    _3_2 = '[0,0,0,0]',
    _3_3 = '[3,4,0,0]',
}

---@class RoleSkillInitCfg : CfgBase
local RoleSkillInitCfg = {
	TableName = "c_role_skill_init_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        ID = 1,
        IsReplaceSpec = 1,
        _PassiveList = '[0,0,0,0,0,0,0,0,0,0]',
        _SkillList = '[{"Index":0,"ID":11301},{"Index":1,"ID":11304},{"Index":2,"ID":11305},{"Index":3,"ID":11306},{"Index":4,"ID":11307},{"Index":5,"ID":11309},{"Index":6,"ID":11316},{"Index":7,"ID":11317},{"Index":8,"ID":11312},{"Index":9,"ID":11325},{"Index":10,"ID":1213},{"Index":11,"ID":2009},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1121},{"Index":17,"ID":1122},{"Index":18,"ID":1123},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        _Spectrum = '[11,0,0,0]',
        Type = 0,
    },
	LuaData = {
        {
            _PassiveList = '[10141,10129,10130,10131,10132,10133,10134,10135,10121,0]',
            _SkillList = '[{"Index":0,"ID":10101},{"Index":1,"ID":10104},{"Index":2,"ID":10106},{"Index":3,"ID":10107},{"Index":4,"ID":10108},{"Index":5,"ID":10109},{"Index":6,"ID":10113},{"Index":7,"ID":10110},{"Index":8,"ID":10114},{"Index":9,"ID":10115},{"Index":10,"ID":1201},{"Index":11,"ID":2001},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1011},{"Index":17,"ID":1012},{"Index":18,"ID":1013},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = '[2,0,0,0]',
        },
        {
            ID = 2,
            _PassiveList = '[20124,0,0,0,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":20101},{"Index":1,"ID":20106},{"Index":2,"ID":20107},{"Index":3,"ID":20108},{"Index":4,"ID":20104},{"Index":5,"ID":20112},{"Index":6,"ID":20124},{"Index":7,"ID":0},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":20083},{"Index":11,"ID":0},{"Index":12,"ID":20000},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_1,
            Type = 1,
        },
        {
            ID = 3,
            _PassiveList = '[10317,10318,10319,10320,10321,10323,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":10300},{"Index":1,"ID":10303},{"Index":2,"ID":10304},{"Index":3,"ID":10305},{"Index":4,"ID":10307},{"Index":5,"ID":10306},{"Index":6,"ID":10308},{"Index":7,"ID":10309},{"Index":8,"ID":10310},{"Index":9,"ID":10311},{"Index":10,"ID":1209},{"Index":11,"ID":2004},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1031},{"Index":17,"ID":1032},{"Index":18,"ID":1033},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = '[0,8,9,10]',
        },
        {
            ID = 4,
            _PassiveList = '[20308,0,0,0,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":20300},{"Index":1,"ID":20304},{"Index":2,"ID":20305},{"Index":3,"ID":20306},{"Index":4,"ID":20307},{"Index":5,"ID":20303},{"Index":6,"ID":20309},{"Index":7,"ID":0},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":20078},{"Index":11,"ID":0},{"Index":12,"ID":20007},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_1,
            Type = 1,
        },
        {
            ID = 5,
            _PassiveList = CS._1_1,
            _SkillList = '[{"Index":0,"ID":10200},{"Index":1,"ID":10201},{"Index":2,"ID":10202},{"Index":3,"ID":10203},{"Index":4,"ID":10225},{"Index":5,"ID":10205},{"Index":6,"ID":10206},{"Index":7,"ID":10207},{"Index":8,"ID":10208},{"Index":9,"ID":10212},{"Index":10,"ID":1203},{"Index":11,"ID":2003},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1021},{"Index":17,"ID":1022},{"Index":18,"ID":1023},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_3,
        },
        {
            ID = 6,
            _PassiveList = '[20220,0,0,0,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":20200},{"Index":1,"ID":20201},{"Index":2,"ID":20280},{"Index":3,"ID":20214},{"Index":4,"ID":20208},{"Index":5,"ID":20212},{"Index":6,"ID":20203},{"Index":7,"ID":0},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":20072},{"Index":11,"ID":0},{"Index":12,"ID":20002},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_1,
            Type = 1,
        },
        {
            ID = 7,
            IsReplaceSpec = 0,
            _PassiveList = CS._1_2,
            _SkillList = '[{"Index":0,"ID":10635},{"Index":1,"ID":10609},{"Index":2,"ID":10610},{"Index":3,"ID":10611},{"Index":4,"ID":10612},{"Index":5,"ID":10621},{"Index":6,"ID":10616},{"Index":7,"ID":10617},{"Index":8,"ID":10618},{"Index":9,"ID":10608},{"Index":10,"ID":1205},{"Index":11,"ID":2002},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1041},{"Index":17,"ID":1042},{"Index":18,"ID":1043},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = '[0]',
            Type = 2,
        },
        {
            ID = 8,
            _PassiveList = '[30112,30113,30114,30115,30116,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":30101},{"Index":1,"ID":30105},{"Index":2,"ID":30103},{"Index":3,"ID":30104},{"Index":4,"ID":30102},{"Index":5,"ID":30106},{"Index":6,"ID":0},{"Index":7,"ID":0},{"Index":8,"ID":0},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 9,
            _PassiveList = CS._1_3,
            _SkillList = '[{"Index":0,"ID":30201},{"Index":1,"ID":30205},{"Index":2,"ID":30203},{"Index":3,"ID":30204},{"Index":4,"ID":30202},{"Index":5,"ID":30206},{"Index":6,"ID":0},{"Index":7,"ID":0},{"Index":8,"ID":0},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 10,
            _PassiveList = CS._1_4,
            _SkillList = '[{"Index":0,"ID":30301},{"Index":1,"ID":30305},{"Index":2,"ID":30308},{"Index":3,"ID":30311},{"Index":4,"ID":30304},{"Index":5,"ID":30313},{"Index":6,"ID":30309},{"Index":7,"ID":30310},{"Index":8,"ID":30303},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 11,
            _PassiveList = '[10529,10530,10531,10532,10533,10534,10547,10548,10549,10550]',
            _SkillList = '[{"Index":0,"ID":10526},{"Index":1,"ID":10504},{"Index":2,"ID":10557},{"Index":3,"ID":10538},{"Index":4,"ID":10507},{"Index":5,"ID":10513},{"Index":6,"ID":10514},{"Index":7,"ID":10525},{"Index":8,"ID":10535},{"Index":9,"ID":10519},{"Index":10,"ID":1207},{"Index":11,"ID":2005},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1051},{"Index":17,"ID":1052},{"Index":18,"ID":1053},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = '[5,6,7,0]',
        },
        {
            ID = 12,
            _PassiveList = '[20429,20430,20431,20432,20433,20434,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":20426},{"Index":1,"ID":20404},{"Index":2,"ID":20406},{"Index":3,"ID":20407},{"Index":4,"ID":20418},{"Index":5,"ID":20435},{"Index":6,"ID":20411},{"Index":7,"ID":0},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":20076},{"Index":11,"ID":0},{"Index":12,"ID":20008},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":2041},{"Index":17,"ID":2042},{"Index":18,"ID":2043},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_1,
            Type = 1,
        },
        {
            ID = 13,
            _PassiveList = CS._1_2,
            _SkillList = '[{"Index":0,"ID":10601},{"Index":1,"ID":10641},{"Index":2,"ID":10605},{"Index":3,"ID":10606},{"Index":4,"ID":10607},{"Index":5,"ID":10642},{"Index":6,"ID":10614},{"Index":7,"ID":10615},{"Index":8,"ID":10618},{"Index":9,"ID":10608},{"Index":10,"ID":1205},{"Index":11,"ID":2002},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1041},{"Index":17,"ID":1042},{"Index":18,"ID":1043},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = '[12,13,14,0]',
        },
        {
            ID = 14,
            _PassiveList = '[20650,0,0,0,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":20601},{"Index":1,"ID":20606},{"Index":2,"ID":20630},{"Index":3,"ID":20604},{"Index":4,"ID":20611},{"Index":5,"ID":20605},{"Index":6,"ID":20612},{"Index":7,"ID":0},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":20074},{"Index":11,"ID":0},{"Index":12,"ID":20004},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_1,
            Type = 1,
        },
        {
            ID = 15,
            _PassiveList = CS._1_4,
            _SkillList = '[{"Index":0,"ID":30302},{"Index":1,"ID":30305},{"Index":2,"ID":30308},{"Index":3,"ID":30312},{"Index":4,"ID":30306},{"Index":5,"ID":30307},{"Index":6,"ID":30309},{"Index":7,"ID":30310},{"Index":8,"ID":30303},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 16,
            _PassiveList = '[30112,30113,30114,30115,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":30111},{"Index":1,"ID":30105},{"Index":2,"ID":30110},{"Index":3,"ID":30109},{"Index":4,"ID":30108},{"Index":5,"ID":30107},{"Index":6,"ID":0},{"Index":7,"ID":0},{"Index":8,"ID":0},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 17,
            IsReplaceSpec = 0,
            _SkillList = '[{"Index":0,"ID":10601},{"Index":1,"ID":10609},{"Index":2,"ID":10610},{"Index":3,"ID":10611},{"Index":4,"ID":10612},{"Index":5,"ID":10613},{"Index":6,"ID":10616},{"Index":7,"ID":10617},{"Index":8,"ID":10618},{"Index":9,"ID":10619},{"Index":10,"ID":0},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_2,
        },
        {
            ID = 18,
            _PassiveList = '[10750,10751,10752,10749,10754,10755,10756,0,0,0]',
            _SkillList = '[{"Index":0,"ID":10701},{"Index":1,"ID":10704},{"Index":2,"ID":10705},{"Index":3,"ID":10706},{"Index":4,"ID":10708},{"Index":5,"ID":10710},{"Index":6,"ID":10724},{"Index":7,"ID":10726},{"Index":8,"ID":10715},{"Index":9,"ID":10717},{"Index":10,"ID":1204},{"Index":11,"ID":2006},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1081},{"Index":17,"ID":1082},{"Index":18,"ID":1083},{"Index":19,"ID":10722},{"Index":20,"ID":10723},{"Index":21,"ID":0}]',
            _Spectrum = '[15,16,23,0]',
        },
        {
            ID = 19,
            _PassiveList = '[20730,20740,0,0,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":20701},{"Index":1,"ID":20725},{"Index":2,"ID":20704},{"Index":3,"ID":20707},{"Index":4,"ID":20715},{"Index":5,"ID":20711},{"Index":6,"ID":20731},{"Index":7,"ID":0},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":20073},{"Index":11,"ID":0},{"Index":12,"ID":20009},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":1081},{"Index":17,"ID":1082},{"Index":18,"ID":1083},{"Index":19,"ID":10722},{"Index":20,"ID":10723},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_1,
            Type = 1,
        },
        {
            ID = 20,
            _PassiveList = '[10828,10829,10830,10831,10832,10833,10834,0,0,0]',
            _SkillList = '[{"Index":0,"ID":10801},{"Index":1,"ID":10817},{"Index":2,"ID":10815},{"Index":3,"ID":10814},{"Index":4,"ID":10813},{"Index":5,"ID":10809},{"Index":6,"ID":10821},{"Index":7,"ID":10824},{"Index":8,"ID":10818},{"Index":9,"ID":10820},{"Index":10,"ID":1206},{"Index":11,"ID":2002},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1071},{"Index":17,"ID":1072},{"Index":18,"ID":1073},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = '[17,18,0,0]',
        },
        {
            ID = 21,
            _SkillList = '[{"Index":0,"ID":20801},{"Index":1,"ID":20818},{"Index":2,"ID":20816},{"Index":3,"ID":20814},{"Index":4,"ID":20813},{"Index":5,"ID":20811},{"Index":6,"ID":20850},{"Index":7,"ID":0},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":20075},{"Index":11,"ID":0},{"Index":12,"ID":20003},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_1,
            Type = 1,
        },
        {
            ID = 22,
            _PassiveList = '[10947,10935,10934,10931,10932,10933,10939,10940,10946,0]',
            _SkillList = '[{"Index":0,"ID":10901},{"Index":1,"ID":10906},{"Index":2,"ID":10907},{"Index":3,"ID":10909},{"Index":4,"ID":10910},{"Index":5,"ID":10912},{"Index":6,"ID":10914},{"Index":7,"ID":10921},{"Index":8,"ID":10913},{"Index":9,"ID":10919},{"Index":10,"ID":1202},{"Index":11,"ID":2001},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1061},{"Index":17,"ID":1062},{"Index":18,"ID":1063},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = '[31,0,0,0]',
        },
        {
            ID = 23,
            _PassiveList = '[20910,0,0,0,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":20901},{"Index":1,"ID":20909},{"Index":2,"ID":20906},{"Index":3,"ID":20907},{"Index":4,"ID":20904},{"Index":5,"ID":20912},{"Index":6,"ID":20908},{"Index":7,"ID":0},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":20071},{"Index":11,"ID":0},{"Index":12,"ID":20001},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":1061},{"Index":17,"ID":1062},{"Index":18,"ID":1063},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_1,
            Type = 1,
        },
        {
            ID = 24,
            _PassiveList = '[30412,30413,30414,0,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":30401},{"Index":1,"ID":30402},{"Index":2,"ID":30403},{"Index":3,"ID":30400},{"Index":4,"ID":0},{"Index":5,"ID":0},{"Index":6,"ID":30409},{"Index":7,"ID":30410},{"Index":8,"ID":0},{"Index":9,"ID":30411},{"Index":10,"ID":1200},{"Index":11,"ID":30404},{"Index":12,"ID":30405},{"Index":13,"ID":30406},{"Index":14,"ID":30407},{"Index":15,"ID":30408},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 25,
            _PassiveList = CS._1_5,
            _SkillList = '[{"Index":0,"ID":11001},{"Index":1,"ID":11013},{"Index":2,"ID":11046},{"Index":3,"ID":11006},{"Index":4,"ID":11008},{"Index":5,"ID":11004},{"Index":6,"ID":11015},{"Index":7,"ID":11016},{"Index":8,"ID":11047},{"Index":9,"ID":11026},{"Index":10,"ID":1210},{"Index":11,"ID":2002},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1101},{"Index":17,"ID":1102},{"Index":18,"ID":1103},{"Index":19,"ID":11010},{"Index":20,"ID":11011},{"Index":21,"ID":11012}]',
            _Spectrum = '[24,27,0,0]',
        },
        {
            ID = 26,
            _PassiveList = CS._1_5,
            _SkillList = '[{"Index":0,"ID":11001},{"Index":1,"ID":11013},{"Index":2,"ID":11046},{"Index":3,"ID":11006},{"Index":4,"ID":11008},{"Index":5,"ID":11004},{"Index":6,"ID":11015},{"Index":7,"ID":11016},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":20079},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":1101},{"Index":17,"ID":1102},{"Index":18,"ID":1103},{"Index":19,"ID":11010},{"Index":20,"ID":11011},{"Index":21,"ID":11012}]',
            _Spectrum = CS._3_1,
            Type = 1,
        },
        {
            ID = 27,
            _PassiveList = '[11130,11132,11135,11136,11137,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":11101},{"Index":1,"ID":11104},{"Index":2,"ID":11106},{"Index":3,"ID":11154},{"Index":4,"ID":11139},{"Index":5,"ID":11108},{"Index":6,"ID":11109},{"Index":7,"ID":11110},{"Index":8,"ID":11122},{"Index":9,"ID":11124},{"Index":10,"ID":1208},{"Index":11,"ID":2007},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1091},{"Index":17,"ID":1092},{"Index":18,"ID":1093},{"Index":19,"ID":11123},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = '[28,29,30,0]',
        },
        {
            ID = 28,
            _PassiveList = '[21104,0,0,0,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":21101},{"Index":1,"ID":21115},{"Index":2,"ID":21110},{"Index":3,"ID":21117},{"Index":4,"ID":21119},{"Index":5,"ID":21107},{"Index":6,"ID":21109},{"Index":7,"ID":0},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":20077},{"Index":11,"ID":0},{"Index":12,"ID":20010},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = '[33,0,0,0]',
            Type = 1,
        },
        {
            ID = 29,
            _PassiveList = '[30609,30610,30611,30612,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":30608},{"Index":1,"ID":30602},{"Index":2,"ID":30603},{"Index":3,"ID":30605},{"Index":4,"ID":30615},{"Index":5,"ID":30606},{"Index":6,"ID":30607},{"Index":7,"ID":30613},{"Index":8,"ID":30604},{"Index":9,"ID":30614},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":30601},{"Index":13,"ID":30607},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 30,
            _PassiveList = '[30709,30710,30711,30712,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":30708},{"Index":1,"ID":30702},{"Index":2,"ID":30703},{"Index":3,"ID":30705},{"Index":4,"ID":30715},{"Index":5,"ID":30706},{"Index":6,"ID":30707},{"Index":7,"ID":30713},{"Index":8,"ID":30704},{"Index":9,"ID":30714},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":30701},{"Index":13,"ID":30707},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 31,
            _PassiveList = '[30530,30511,30512,30513,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":30501},{"Index":1,"ID":30502},{"Index":2,"ID":30507},{"Index":3,"ID":30508},{"Index":4,"ID":30509},{"Index":5,"ID":30506},{"Index":6,"ID":30503},{"Index":7,"ID":30505},{"Index":8,"ID":30504},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 32,
            _PassiveList = '[30830,30811,30812,30813,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":30801},{"Index":1,"ID":30802},{"Index":2,"ID":30807},{"Index":3,"ID":30808},{"Index":4,"ID":30809},{"Index":5,"ID":30806},{"Index":6,"ID":30803},{"Index":7,"ID":30805},{"Index":8,"ID":30804},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 33,
            _PassiveList = '[30910,30911,30912,30913,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":30901},{"Index":1,"ID":30905},{"Index":2,"ID":30906},{"Index":3,"ID":30902},{"Index":4,"ID":30908},{"Index":5,"ID":30909},{"Index":6,"ID":30903},{"Index":7,"ID":30914},{"Index":8,"ID":30904},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 34,
            _PassiveList = '[31010,31011,31012,31013,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":31001},{"Index":1,"ID":31005},{"Index":2,"ID":31006},{"Index":3,"ID":31002},{"Index":4,"ID":31008},{"Index":5,"ID":31009},{"Index":6,"ID":31003},{"Index":7,"ID":31014},{"Index":8,"ID":31004},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 35,
            _PassiveList = '[31111,31112,31113,31114,31115,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":31101},{"Index":1,"ID":31106},{"Index":2,"ID":31105},{"Index":3,"ID":31107},{"Index":4,"ID":31108},{"Index":5,"ID":31109},{"Index":6,"ID":31102},{"Index":7,"ID":31103},{"Index":8,"ID":0},{"Index":9,"ID":31104},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":31110},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 36,
            _PassiveList = CS._1_3,
            _SkillList = '[{"Index":0,"ID":30211},{"Index":1,"ID":30205},{"Index":2,"ID":30210},{"Index":3,"ID":30209},{"Index":4,"ID":30208},{"Index":5,"ID":30207},{"Index":6,"ID":0},{"Index":7,"ID":0},{"Index":8,"ID":0},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
        },
        {
            ID = 37,
            _PassiveList = CS._1_1,
            _SkillList = '[{"Index":0,"ID":10222},{"Index":1,"ID":10201},{"Index":2,"ID":10202},{"Index":3,"ID":10203},{"Index":4,"ID":10225},{"Index":5,"ID":10205},{"Index":6,"ID":10206},{"Index":7,"ID":10207},{"Index":8,"ID":10208},{"Index":9,"ID":10212},{"Index":10,"ID":1203},{"Index":11,"ID":2003},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1021},{"Index":17,"ID":1022},{"Index":18,"ID":1023},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_3,
        },
        {
            ID = 38,
            _SkillList = '[{"Index":0,"ID":36000},{"Index":1,"ID":0},{"Index":2,"ID":0},{"Index":3,"ID":0},{"Index":4,"ID":0},{"Index":5,"ID":0},{"Index":6,"ID":0},{"Index":7,"ID":0},{"Index":8,"ID":0},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_2,
            Type = 2,
        },
        {
            ID = 39,
            _SkillList = '[{"Index":0,"ID":0},{"Index":1,"ID":102443},{"Index":2,"ID":0},{"Index":3,"ID":0},{"Index":4,"ID":0},{"Index":5,"ID":0},{"Index":6,"ID":0},{"Index":7,"ID":0},{"Index":8,"ID":0},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_2,
            Type = 2,
        },
        {
            ID = 40,
            _PassiveList = '[11228,0,0,0,0,0,0,0,0,0]',
            _SkillList = '[{"Index":0,"ID":11200},{"Index":1,"ID":11204},{"Index":2,"ID":11205},{"Index":3,"ID":11207},{"Index":4,"ID":11208},{"Index":5,"ID":11215},{"Index":6,"ID":11217},{"Index":7,"ID":11219},{"Index":8,"ID":11222},{"Index":9,"ID":11221},{"Index":10,"ID":1211},{"Index":11,"ID":2008},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1111},{"Index":17,"ID":1112},{"Index":18,"ID":1113},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = '[35,36,0,0]',
        },
        {
            ID = 41,
            _SkillList = '[{"Index":0,"ID":20300},{"Index":1,"ID":20304},{"Index":2,"ID":20305},{"Index":3,"ID":20306},{"Index":4,"ID":20307},{"Index":5,"ID":20303},{"Index":6,"ID":20309},{"Index":7,"ID":0},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":1209},{"Index":11,"ID":0},{"Index":12,"ID":20007},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_2,
            Type = 1,
        },
        {
            ID = 42,
            _SkillList = '[{"Index":0,"ID":36002},{"Index":1,"ID":0},{"Index":2,"ID":0},{"Index":3,"ID":0},{"Index":4,"ID":0},{"Index":5,"ID":0},{"Index":6,"ID":0},{"Index":7,"ID":0},{"Index":8,"ID":0},{"Index":9,"ID":0},{"Index":10,"ID":1200},{"Index":11,"ID":0},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_2,
            Type = 2,
        },
        {
            ID = 43,
            _PassiveList = CS._1_6,
            _SkillList = '[{"Index":0,"ID":10401},{"Index":1,"ID":10404},{"Index":2,"ID":10406},{"Index":3,"ID":10407},{"Index":4,"ID":10408},{"Index":5,"ID":10409},{"Index":6,"ID":10412},{"Index":7,"ID":10413},{"Index":8,"ID":10411},{"Index":9,"ID":10410},{"Index":10,"ID":1201},{"Index":11,"ID":2001},{"Index":12,"ID":0},{"Index":13,"ID":0},{"Index":14,"ID":0},{"Index":15,"ID":0},{"Index":16,"ID":1131},{"Index":17,"ID":1132},{"Index":18,"ID":1133},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = '[37,38,39,0]',
        },
        {
            ID = 44,
            _PassiveList = CS._1_6,
            _SkillList = '[{"Index":0,"ID":20101},{"Index":1,"ID":20106},{"Index":2,"ID":20107},{"Index":3,"ID":20108},{"Index":4,"ID":20104},{"Index":5,"ID":20112},{"Index":6,"ID":20125},{"Index":7,"ID":0},{"Index":8,"ID":20070},{"Index":9,"ID":0},{"Index":10,"ID":20083},{"Index":11,"ID":0},{"Index":12,"ID":20000},{"Index":13,"ID":20052},{"Index":14,"ID":20052},{"Index":15,"ID":0},{"Index":16,"ID":0},{"Index":17,"ID":0},{"Index":18,"ID":0},{"Index":19,"ID":0},{"Index":20,"ID":0},{"Index":21,"ID":0}]',
            _Spectrum = CS._3_1,
            Type = 1,
        },
        {
            ID = 45,
            _Spectrum = CS._3_2,
        },
        {
            ID = 46,
            _Spectrum = CS._3_2,
            Type = 1,
        },
	},
}

setmetatable(RoleSkillInitCfg, { __index = CfgBase })

RoleSkillInitCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function RoleSkillInitCfg:GetDuplicatedCfgByKey(ID)
    local Cfg = self:FindCfgByKey(ID)
    --local Copy = table.deepcopy(Cfg, false)
    --setmetatable(Copy, nil)
    
    if Cfg then
        local Copy = {}
        Copy.SkillList = table.deepcopy(Cfg.SkillList, false)
        Copy.PassiveList = table.deepcopy(Cfg.PassiveList, false)
        Copy.Spectrum = table.deepcopy(Cfg.Spectrum, false)
        Copy.ID = Cfg.ID
        Copy.Type = Cfg.Type
        Copy.IsReplaceSpec = Cfg.IsReplaceSpec
        return Copy
    end
end

return RoleSkillInitCfg
