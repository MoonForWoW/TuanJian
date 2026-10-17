local AddonName, ns = ...

ns.Interface =  "Interface\\AddOns\\" .. AddonName .. "\\"

local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
ns.ver = "v" .. GetAddOnMetadata(AddonName, "Version")

local L = setmetatable({}, {
    __index = function(table, key)
        return tostring(key)
    end
})
ns.L = L

local c1 = "|cff" .. "ffff66"
ns.c1 = c1

do --简体说明书
    ns.instructionsText = {
        "|cff00BFFF< 说明书 >（本插件支持MOP/CTM/WLK/时光服）",
        " ",
        "|cffFFFFFF-作者：|r苍穹之霜",
        "|cffFFFFFF-打开命令：|r/TuanJian或/TJ，或游戏设置里绑定按键。小地图图标：" .. "|T" .. ns.Interface .. "Media\\icon\\icon.png:0|t",
        "|cffFFFFFF-快捷操作：|r右键输入框可以清除内容",
        " ",
        -- "|cff00FF00" ..[[]] ,
        -- [[]] ,
        -- [[]] ,
        -- [[]] ,
        -- " " ,
    }
    ns.updateText_now = {

    }
    ns.updateText_before = {
        "|cff00FF00" ..[[10月17日更新v2.2.5]] ,
        [[-增加战斗分析：施法记录（支持从死亡记录里跳转）]],
        [[-<时光>观星坦克减伤链：增加熊+防骑、DKT+ZST组合]] ,
        [[-<时光>尤格萨隆站位图：站位编号调整为对应钟点方位]],
        [[-<时光>尤格萨隆：增加自动标记P2死缠目标]],
        " " ,
        "|cff00FF00" ..[[10月11日更新v2.2.4]] ,
        [[-<时光>观星坦克减伤链：]] ,
        [[ ○ 增加双防骑方案]] ,
        [[ ○ 增加防战+防骑方案]] ,
        [[ ○ 增加坦克嘲讽提醒]] ,
        [[ ○ 补充防骑的拯救之手]] ,
        [[ ○ 点击预览时间轴按钮可打开独立的时间轴窗口]] ,
        " " ,
        "|cff00FF00" .. [[10月10日更新v2.2.3]],
        [[-<时光>观星：增加坦克减伤链。增加"毛星"战斗分析]],
        [[-<时光>尤格萨隆：增加自动标记P1小怪和多项战斗分析]],
        [[-<时光>奥杜尔：为剩余BOSS增加常规战斗分析模板]],
        [[-设置：增加选项"战斗分析缓存数量"（默认值为3）。实现既能复盘多个BOSS，但又不过多占用内存]],
        " ",
        "|cff00FF00" ..[[10月7日更新v2.2.2]] ,
        [[-<时光>奥杜尔：增加托里姆和尤格萨隆的站位图]] ,
    }
end

local l = GetLocale()
if (l == "zhTW" or l == "enUS") then return end

local L = {}

do
    L["显示悬浮框"] = true
    L["悬浮框缩放"] = true
    L["调整悬浮框UI的大小。"] = true
    L["悬浮框层级"] = true
    L["左键：打开/关闭主界面"] = true
    L["右键：打开设置"] = true
    L["左键拖动：移动悬浮框"] = true
end
