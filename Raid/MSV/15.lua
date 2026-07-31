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
local FB = "TES"
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
    local bossSpellID = 123461
    do
        local isload
        local init = function()
            isload = true
            local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
            local spellTbl = {
                {
                    title = L["1/4"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["2/5"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["3/6"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
            }
            local function AutoFuc()
                local maxCount = #spellTbl
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                local startIndex = #tbl + 1
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s1)
                end
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s8)
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = maxCount, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = maxCount, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s11)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
                for i, v in ipairs(tbl) do
                    for i = maxCount, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s10)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = maxCount, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, TuanJian.talentInfo[v.name] == 1 and s5 or ns.s13)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
                for i, v in ipairs(tbl) do
                    for i = maxCount, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s14)
                            done[i] = true
                            break
                        end
                    end
                end
            end

            local name = L["滚开减伤链"]

            local tbl = {
                {
                    name = name,
                    bossSpellID = bossSpellID,
                    arrange = 6,
                    icon = "spell_shaman_measuredinsight",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_START",
                    canUpdate = nil,
                    autoNextSpell = nil,
                    startIndex = 1,
                    maxIndex = 3,
                    bossTime = { 1, 1, },
                    autoHide = true,
                    now = true,
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                TJ.Board_info[bossSpellID].canUpdate = true
            end
            mainFrame.Board_SPELL_CAST_START = function(info, ...)
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
/run TJ.Board_ENCOUNTER_START("HOF", 1)
/run TJ.Board_SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,122713)
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,122713)
/run TJ.Board_info[122713].index = 1
 ]]
        end
        tinsert(TJ.boardCallback, init)
        if TJ.boardInited and not isload then init() end
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

    -- 外场易伤叠层
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排猎人。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, 136163, L["外场易伤叠层"],
            text, nil, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["外场易伤叠层"])
        TJ.CreateEdit(FB, bossIndex, L["外场易伤叠层"])
        TJ.CreateEdit(FB, bossIndex, L["外场易伤叠层"])
    end

    -- 控制小怪
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER", "WARLOCK", "DRUID" }, nil, true)
            local done = {}
            for _, v in ipairs(tbl) do
                for _, i in ipairs({ 1, 3, 5, 7, 2, 4, 6, 8 }) do
                    if not done[i] then
                        TJ.SetEditTextFormNum(v, title, i)
                        done[i] = true
                        break
                    end
                end
            end
        end
        local text = L["安排猎人/术士/小德。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_cripple", L["控制小怪"],
            text, nil, nil, nil, nil,
            true, 2)
        TJ.CreateEdit(FB, bossIndex, L["3点"])
        TJ.CreateEdit(FB, bossIndex, L["3点"])
        TJ.CreateEdit(FB, bossIndex, L["6点"])
        TJ.CreateEdit(FB, bossIndex, L["6点"])
        TJ.CreateEdit(FB, bossIndex, L["9点"])
        TJ.CreateEdit(FB, bossIndex, L["9点"])
        TJ.CreateEdit(FB, bossIndex, L["12点"])
        TJ.CreateEdit(FB, bossIndex, L["12点"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 喷射
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 123121 },
                        combatRole = { "Istank" },
                    },
                },
                destNpcType = { "Player" },
                notShowStackCount = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135861, L["喷射"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 恐怖迷雾
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            123705,
                            -- 123712,
                        },
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 136163, L["恐怖迷雾"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 滚开
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 123461, },
                            colorNum = 2,
                        },
                    },
                },
            },
            isMany = true,
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shaman_measuredinsight", L["滚开"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 打醒小怪
    do
        local info = {
            broken = {
                type = "s",
                destNPCID = {
                    62995
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_cripple", L["打醒小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.frame[FB][bossIndex].SPELL_AURA_APPLIED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 123250 then -- 保护
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["保护"],
            })
        end
    end
end
