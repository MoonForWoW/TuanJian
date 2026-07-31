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
local FB = "TOT"
local bossIndex = 4
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

    -- 自动标记
    local name = "rt" .. FB .. bossIndex
    do
        mainFrame.autoRT = name
        local instanceID = TJ.FBinfo[FB].ID
        TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
        TJ.autoRaidTargetInfo[instanceID][67966] = {
            [8] = true,
            [7] = true,
            [6] = true,
            np = true,
            hpMin = .5,
        }

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local icon = TJ.SetRaidTargetingTex(8, 7, 6)
        local ontext = {
        }
        local f = ns.O.CreateCheckButton(name, format(L["战斗中把旋龟标记为%s（需要团长/助理）"], icon),
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)

        mainFrame.SPELL_CAST_SUCCESS=function (...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == 136294 then
                TJ.WipeAutoRaidTargetActive()
            end
        end
    end

    -- 战术板
    local bossSpellID = 134920
    do
        local isload
        local init = function()
            isload = true
            local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
            local spellTbl = {
                {
                    title = L["1/5"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["2/6"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["3/7"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["4/8"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
            }
            local function AutoFuc()
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end

                local startIndex = #tbl + 1
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7)
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, 4, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        for i = 4, 1, -1 do
                            if not done[i] then
                                TJ.SetBoardEditFormNum(v, i, nil, s5)
                                done[i] = true
                                break
                            end
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = 4, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s1)
                            done[i] = true
                            break
                        end
                    end
                end
            end

            local tbl = {
                {
                    name = L["震地践踏减伤链"],
                    bossSpellID = bossSpellID,
                    arrange = 6,
                    icon = "spell_nature_earthquake",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = true,
                    autoNextSpell = true,
                    startIndex = 1,
                    maxIndex = nil,
                    bossTime = { 27, 48, },
                    autoHide = nil,
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                local t = TJ.Board_info[bossSpellID].updateFrame.t
                local nextTime = TJ.Board_info[bossSpellID].bossTime[1]
                if t and nextTime and nextTime - t > 10 then
                    TJ.Board_info[bossSpellID].updateFrame.t = nextTime - 10
                end
            end

            TJ.CreateBoard(FB, bossIndex, tbl)
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
            true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["小怪"])
    end

    -- 踢龟壳
    do
        local function AutoFuc(title)
        end
        local info = {
        }
        local text = L["此任务只能手动安排。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_thunderking_kickshell", L["踢龟壳"],
            text, nil, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["踢龟壳"])
        TJ.CreateEdit(FB, bossIndex, L["踢龟壳"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 落石
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                134539,
                            },
                            colorNum = 1
                        },
                    },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["落石"]), icon = 134539 }
            },
        }

        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_thunderking_rockfallhigh", L["落石"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 震地践踏
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { bossSpellID, },
                            colorNum = 2,
                        },
                    },
                },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_earthquake", L["震地践踏"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    68497, 67966,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_pet_bat", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
