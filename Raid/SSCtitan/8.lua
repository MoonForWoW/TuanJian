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
local FB = "TKtitan"
local bossIndex = 2
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
    -- 战术板
    TJ.AddBoard(mainFrame, function()
        local s1, s2, s3 = ns.s1, ns.s2, ns.s3
        local spellTbl = {
            {
                title = L["1/10"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["2/11"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["3/12"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["4/13"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["5/14"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["6/15"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["7/16"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["8/17"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["9/18"],
                class = nil,
                spell = TJ.Board_TJ1
            },
        }
        local function AutoFuc()
            local done = {}
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for _, v in pairs(CopyTable(TJ.SortRaidRosterInfo({ "PALADIN", }, "tank", true))) do
                tinsert(tbl, v)
            end
            for i, v in ipairs(CopyTable(TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true))) do
                if TuanJian.talentInfo[v.name] == 4 then
                    tinsert(tbl, v)
                end
            end
            for i, v in ipairs(tbl) do
                for _, i in ipairs({ 1, 3, 5, 7, 9 }) do
                    if not done[i] then
                        TJ.SetBoardEditFormNum(v, i, 1, s1)
                        done[i] = true
                        break
                    end
                end
            end
        end

        local tbl = {
            {
                name = L["重击减伤链"],
                bossSpellID = 34162,
                arrange = 2,
                icon = "ability_thunderclap",
                id = 1,
                spell = spellTbl,
                event = "SPELL_CAST_SUCCESS",
                canUpdate = true,
                autoNextSpell = true,
                startIndex = 1,
                bossTime = { 6, 14, },
            },
            AutoFuc = AutoFuc,
        }

        TJ.frame[FB][bossIndex].Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
        end

        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 324, -477 } },
            { point = "TOPLEFT", xy = { 108, -313 } },
            { point = "TOPLEFT", xy = { 548, -330 } },
            { point = "TOPLEFT", xy = { 181, -98 } },
            { point = "TOPLEFT", xy = { 483, -101 } },
            { point = "TOPLEFT", xy = { 228, -453 } },
            { point = "TOPLEFT", xy = { 423, -456 } },
            { point = "TOPLEFT", xy = { 158, -400 } },
            { point = "TOPLEFT", xy = { 494, -409 } },
            { point = "TOPLEFT", xy = { 101, -238 } },
            { point = "TOPLEFT", xy = { 556, -247 } },
            { point = "TOPLEFT", xy = { 129, -163 } },
            { point = "TOPLEFT", xy = { 533, -173 } },
            { point = "TOPLEFT", xy = { 249, -58 } },
            { point = "TOPLEFT", xy = { 417, -57 } },
            { point = "TOPLEFT", xy = { 331, -44 } },

            [100] = { xy = { 328, -240 }, isNPC = "b" .. bossIndex },
        }

        --[[
        ]]

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(TJ.healerClass, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end

            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["1-5：治疗。"],
            L["剩余位置：远程DPS。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 650
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1360 * 1158, nil, nil, nil, "v1.28.7")
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
        if TJ.IsTBC then
            TJ.CreateEdit(FB, bossIndex, L["1坦克"])
            TJ.CreateEdit(FB, bossIndex, L["2坦克"])
            TJ.CreateEdit(FB, bossIndex, L["3坦克"])
        else
            TJ.CreateEdit(FB, bossIndex, L["主坦克"])
            TJ.CreateEdit(FB, bossIndex, L["副坦克"])
        end
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 重击
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                34162,
                            },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["Boss施放%s"]:format(L["重击"]) },
            },
        }
        tinsert(info, TJ.combatInfoMore)
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_thunderclap", L["重击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 奥术宝珠
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            34190,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            title = { name = L["受到%s伤害"]:format(L["奥术宝珠"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_wispsplode", L["奥术宝珠"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
