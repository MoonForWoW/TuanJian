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
local FB = "SSCtitan"
local bossIndex = 3
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
    local bossSpellID = 37640
    TJ.AddBoard(mainFrame, function()
        local s1, s2, s3 = ns.s1, ns.s2, ns.s3
        local spellTbl = {
            {
                title = L["1/3"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["2/4"],
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
                for i = 1, 2 do
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
                name = L["旋风斩减伤链"],
                bossSpellID = bossSpellID,
                arrange = 2,
                icon = "ability_whirlwind",
                id = 1,
                spell = spellTbl,
                event = "SPELL_CAST_SUCCESS",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                bossTime = { 4, 4, },
                autoHide = true,
            },
            AutoFuc = AutoFuc,
        }

        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            TJ.Board_info[bossSpellID].canUpdate = true
        end

        mainFrame.Board_SPELL_CAST_SUCCESS = function(info, ...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == bossSpellID then
                TJ.Board_info[bossSpellID].canUpdate = true
                TJ.Board_info[bossSpellID].updateFrame.t = 0
                After(0, function()
                    info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
                end)
            end
        end

        TJ.CreateBoard(FB, bossIndex, tbl)

        --[[
/run TJ.Board_ENCOUNTER_START("SSCtitan", 3)
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,37640)
 ]]
    end)

    -- 自动标记
    do
        local instanceID = TJ.FBinfo[FB].ID
        TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
        TJ.autoRaidTargetInfo[instanceID][21806] = {
            [8] = true,
            [7] = true,
            [6] = true,
        }
    end

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 203, -91 } },
            { point = "TOPLEFT", xy = { 503, -94 } },
            { point = "TOPLEFT", xy = { 241, -271 } },
            { point = "TOPLEFT", xy = { 478, -279 } },
            { point = "TOPLEFT", xy = { 354, -281 } },
            { point = "TOPLEFT", xy = { 279, -62 } },
            { point = "TOPLEFT", xy = { 420, -68 } },
            { point = "TOPLEFT", xy = { 267, -128 } },
            { point = "TOPLEFT", xy = { 437, -127 } },
            { point = "TOPLEFT", xy = { 178, -165 } },
            { point = "TOPLEFT", xy = { 540, -160 } },
            { point = "TOPLEFT", xy = { 258, -201 } },
            { point = "TOPLEFT", xy = { 445, -205 } },
            { point = "TOPLEFT", xy = { 173, -241 } },
            { point = "TOPLEFT", xy = { 538, -231 } },
            { point = "TOPLEFT", xy = { 293, -337 } },
            { point = "TOPLEFT", xy = { 425, -336 } },

            [98] = {
                xy = { 354, -115 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 353, -204 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 354, -161 }, isNPC = "b" .. bossIndex },
        }

        --[[
        ]]

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(TJ.healerClass, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 1, max = 5 })
            end

            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["1-5：治疗。"],
            L["6-17：远程DPS。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local map = TJ.CreateMap(FB, bossIndex, tbl, 700, 452)
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
    -- 远程坦
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "WARLOCK" }, nil, true)
            for i, v in ipairs(tbl) do
                if TuanJian.talentInfo[v.name] == 2 then
                    TJ.SetEditText(v, title)
                end
            end
        end
        local text = TJ.IsTBC and L["安排恶魔术。"] or L["优先安排DKT，其次恶魔术。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_fire_felflamebolt", L["远程坦"],
            text, nil, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["远程坦"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 旋风斩
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                37640
                            },
                            colorNum = 2,
                        }
                    },
                },
                title = { name = L["Boss施放%s"]:format(L["旋风斩"]), icon = 37640 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                37641
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["旋风斩"], icon = 37641 }
            }
        }
        tinsert(info, 2, TJ.combatInfoMore)
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_whirlwind", L["旋风斩"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 混乱冲击
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            37675
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            },
            title = { name = L["%s层数"]:format(L["混乱冲击"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_felflamebolt", L["混乱冲击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 诱惑低语
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            37676
                        },
                        tooltip = "aura+castAll",
                        colorNum = 1,
                    },
                    {
                        spellID = {
                            37749
                        },
                        tooltip = "aura",
                        colorNum = 5,
                    },
                },
                destNpcType = { "Player" },
            },
            title = L["点名"],
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_manafeed", L["诱惑低语"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local timer = {}
    mainFrame.ENCOUNTER_START = function()
        wipe(timer)
    end
    mainFrame.ENCOUNTER_END = function()
        wipe(timer)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match(L["滚开吧"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "恶魔",
            })
            local t = GetTime()
            timer[t] = true
            After(60, function()
                if timer[t] then
                    tinsert(TJ.GetNewCombatLog().otherTime, {
                        time = TJ.GetDurTime(),
                        name = "人",
                    })
                end
            end)
            return
        end
        if msg:match(L["我才是主宰"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            wipe(timer)
            return
        end
    end
end
