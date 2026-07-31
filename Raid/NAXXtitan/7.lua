local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = "NAXXtitan"
local bossIndex = 7
--[[
"DEATHKNIGHT"
"PALADIN"
"WARRIOR"
"SHAMAN"
"HUNTER"
"DRUID"
"ROGUE"
"MAGE"
"WARLOCK"
"PRIEST"
 ]]

TJ.Load[FB .. bossIndex] = function()
    local mainFrame = TJ.frame[FB][bossIndex]
    -- 技能提醒
    if TJ.canUseTips then
        local name = "tips1" .. FB .. bossIndex

        local delay = 0.1
        local copyCount = 3
        local players = {}
        mainFrame.TipPlayers = players

        mainFrame.ENCOUNTER_START = function(...)
            wipe(players)
            if TuanJian.options[name] == 1 and TJ.IsLeader() then
                for i, v in ipairs(mainFrame.all[3].edits) do
                    local player = v.edit:GetText()
                    if player ~= "" then
                        player = TJ.ClearCode(player)
                        players[player] = 0
                    end
                end
            end
        end
        mainFrame.UNIT_DIED = function(...)
            local tbl = { ... }
            if TuanJian.options[name] == 1 and TJ.IsLeader() then
                local player = tbl[9]
                if players[player] then
                    players[player] = 0
                end
            end
        end

        local func = function(...)
            local tbl = { ... }
            local spellID = tbl[12]
            local player = tbl[9]
            if (spellID == 28059 or spellID == 28084) and players[player] and TuanJian.options[name] == 1 and TJ.IsLeader() then
                if players[player] == 0 then
                    players[player] = spellID
                    After(delay, function()
                        SendChatMessage(spellID == 28059 and string.rep(L["去左边！"], copyCount)
                            or string.rep(L["去右边！"], copyCount), "WHISPER", nil, player)
                    end)
                elseif players[player] == spellID then
                    players[player] = spellID
                    After(delay, function()
                        SendChatMessage(string.rep(L["别动！"], copyCount), "WHISPER", nil, player)
                    end)
                else
                    players[player] = spellID
                    After(delay, function()
                        SendChatMessage(string.rep(L["去对面！"], copyCount), "WHISPER", nil, player)
                    end)
                end
            end
        end
        mainFrame.SPELL_AURA_APPLIED = func
        mainFrame.SPELL_AURA_REFRESH = func

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["自动密语提醒电荷走位"],
            L["对你选定的几名玩家，每次电荷变化时，都会密语提醒他怎么走位：去左边、去右边、去对面或者别动。"],
            " ",
            L["需要你是团长或助理，该功能才生效。"],
        }
        local f = ns.O.CreateCheckButton(name, AddTexture(135769) .. L["自动密语提醒电荷走位"] .. L["（需要团长/助理）"],
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
        --[[
/run TJ.frame["NAXXtitan"][7].ENCOUNTER_START() SPELL_AURA_APPLIED=TJ.frame["NAXXtitan"][7].SPELL_AURA_APPLIED
/run SPELL_AURA_APPLIED(nil,nil,nil,nil,nil,nil,nil,nil,"苍穹之霜",nil,nil,28059) SPELL_AURA_APPLIED(nil,nil,nil,nil,nil,nil,nil,nil,"苍穹小号",nil,nil,28059)
/run SPELL_AURA_APPLIED(nil,nil,nil,nil,nil,nil,nil,nil,"苍穹的小骑士",nil,nil,28084) SPELL_AURA_APPLIED(nil,nil,nil,nil,nil,nil,nil,nil,"苍穹小号",nil,nil,28084)
/run TJ.frame["NAXXtitan"][7].UNIT_DIED(nil,nil,nil,nil,nil,nil,nil,nil,"苍穹的小骑士",nil,nil,28084)
/dump TJ.frame["NAXXtitan"][7].TipPlayers
]]
    end

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 46, -341 } },
            { point = "TOPLEFT", xy = { 646, -345 } },
            { point = "TOPLEFT", xy = { 45, -290 } },
            { point = "TOPLEFT", xy = { 646, -292 } },
            { point = "TOPLEFT", xy = { 45, -238 } },
            { point = "TOPLEFT", xy = { 644, -237 } },
            { point = "TOPLEFT", xy = { 46, -188 } },
            { point = "TOPLEFT", xy = { 645, -184 } },
            { point = "TOPLEFT", xy = { 114, -344 } },
            { point = "TOPLEFT", xy = { 582, -345 } },
            { point = "TOPLEFT", xy = { 113, -293 } },
            { point = "TOPLEFT", xy = { 581, -294 } },
            { point = "TOPLEFT", xy = { 113, -240 } },
            { point = "TOPLEFT", xy = { 579, -242 } },
            { point = "TOPLEFT", xy = { 113, -189 } },
            { point = "TOPLEFT", xy = { 578, -188 } },
            { point = "TOPLEFT", xy = { 181, -343 } },
            { point = "TOPLEFT", xy = { 512, -349 } },
            { point = "TOPLEFT", xy = { 179, -291 } },
            { point = "TOPLEFT", xy = { 511, -297 } },
            { point = "TOPLEFT", xy = { 180, -240 } },
            { point = "TOPLEFT", xy = { 511, -244 } },
            { point = "TOPLEFT", xy = { 178, -190 } },
            { point = "TOPLEFT", xy = { 510, -188 } },
            { point = "TOPLEFT", xy = { 248, -343 } },

        }

        --[[

]]

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(TJ.tankClass, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo(TJ.healerClassClass, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps1", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = L["把队伍的坦克、治疗、近战DPS、远程DPS按左右平均分配。"]

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 700
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1356 * 766, nil, nil, nil, "v1.26.2")
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["小怪左右分队"])
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["主坦克"])
        TJ.CreateEdit(FB, bossIndex, L["副坦克"])
    end

    -- 电荷走位提醒
    do
        local function AutoFuc(title)
        end
        local text = L["此任务只能手动安排。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_chargepositive", L["电荷走位提醒"],
            text, nil, nil, nil, nil,
            true, nil, true)
        for i = 1, 9 do
            TJ.CreateEdit(FB, bossIndex, L["玩家"] .. i)
        end
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 电荷
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            28059,
                        },
                        colorNum = 6,
                    },
                    {
                        spellID = {
                            28084,
                        },
                        colorNum = 8,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_chargepositive", L["电荷"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
