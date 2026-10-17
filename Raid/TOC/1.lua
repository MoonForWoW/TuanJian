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
local FB = "TOC"
local bossIndex = 1
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

    mainFrame.saveAura = {
        [66406] = true, -- 狗头人上身
    }

    -- 自动标记
    local name = "rt" .. FB .. bossIndex
    do
        mainFrame.autoRT = name
        local instanceID = TJ.FBinfo[FB].ID
        TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
        TJ.autoRaidTargetInfo[instanceID][34800] = {
            [8] = true,
            [7] = true,
            [5] = true,
            [4] = true,
            np = true,
        }

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local icon = TJ.SetRaidTargetingTex(8, 7, 5, 4)
        local ontext = {
        }
        local f = ns.O.CreateCheckButton(name, format(L["战斗中把狗头人标记为%s（需要团长/助理）"], icon),
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
    end

    -- 站位图
    do
        TJ.Once('map', 260601, function()
            TuanJian[FB][bossIndex].map = {}
        end)

        local tbl = {
            { point = "TOPLEFT", xy = { 271, -58 } },
            { point = "TOPLEFT", xy = { 441, -55 } },
            { point = "TOPLEFT", xy = { 348, -163 } },
            { point = "TOPLEFT", xy = { 310, -226 } },
            { point = "TOPLEFT", xy = { 381, -230 } },
            { point = "TOPLEFT", xy = { 228, -196 } },
            { point = "TOPLEFT", xy = { 428, -174 } },
            { point = "TOPLEFT", xy = { 159, -154 } },
            { point = "TOPLEFT", xy = { 181, -251 } },
            { point = "TOPLEFT", xy = { 115, -223 } },
            { point = "TOPLEFT", xy = { 253, -275 } },
            { point = "TOPLEFT", xy = { 198, -327 } },
            { point = "TOPLEFT", xy = { 340, -295 } },
            { point = "TOPLEFT", xy = { 424, -283 } },
            { point = "TOPLEFT", xy = { 286, -351 } },
            { point = "TOPLEFT", xy = { 400, -350 } },
            { point = "TOPLEFT", xy = { 488, -233 } },

            [80] = {
                xy = { 723, -20 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["空气\n图腾"],
                isNPC_icon = "Interface\\Icons\\spell_nature_slowingtotem",
            },
            [98] = {
                xy = { 241, -125 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["1队\n近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
                size = 35,
            },
            [99] = {
                xy = { 298, -123 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["2队\n近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
                size = 35,
            },
            [100] = {
                xy = { 268, -101 },
                isNPC = true,
                isNPC_text = L["酸喉"],
                isNPC_icon = "Interface\\Icons\\spell_nature_acid_01",
                size = 40,
            },
            [101] = {
                xy = { 441, -102 },
                isNPC = true,
                isNPC_text = L["恐鳞"],
                isNPC_icon = "Interface\\Icons\\spell_fire_burnout",
                size = 40,
            },
        }

        --[[

]]

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(nil, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 1, max = 2 })
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 3, max = 10 })
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 3, max = 17 })
            end
        end
        local text = {
            L["坦克：1-2号位。"],
            L["治疗：3-7号位。"],
            L["剩余位置：远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 700
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1394 * 784,
            nil, nil, nil, "v1.29.7", nil,
            nil, nil)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["P2站位"])
    end

    -- 战术板
    local bossSpellID = 66683
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
                name = L["冰喉重型撞击减伤链"],
                bossSpellID = bossSpellID,
                arrange = 2,
                icon = "ability_golemthunderclap",
                id = 1,
                spell = spellTbl,
                event = "SPELL_CAST_SUCCESS",
                canUpdate = nil,
                autoNextSpell = true,
                startIndex = 1,
                bossTime = { 44, 57, },
                -- bossTime = { 5, 8, },
                autoHide = nil,
            },
            AutoFuc = AutoFuc,
        }

        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            TJ.Board_info[bossSpellID].canUpdate = true
            TJ.Board_info[bossSpellID].updateFrame.t = 34
        end

        mainFrame.BOSS_SAY = function(msg)
            if msg:match(L["它们是酸喉和恐鳞！"]) then
                tinsert(TJ.GetNewCombatLog().otherTime, {
                    time = TJ.GetDurTime() + 14.5,
                    name = "P2",
                })
            elseif msg:match(L["它是冰吼，"]) and not TJ.SetCD(mainFrame, 2) then
                tinsert(TJ.GetNewCombatLog().otherTime, {
                    time = TJ.GetDurTime() + 10.5,
                    name = "P3",
                })
                TJ.Board_info[bossSpellID].canUpdate = true
                TJ.Board_info[bossSpellID].updateFrame.t = 0
            end
            local player = msg:match("等着(.+)，")
            if player and not TJ.SetCD(mainFrame, 2) then
                local playerGUID = UnitGUID(player)
                if playerGUID then
                    TJ.GetNewEvent()["TRIGGER"] =
                        TJ.GetNewEvent()["TRIGGER"] or {}
                    local tbl = {
                        TJ.GetDurTime(),
                        "TRIGGER",
                        nil,
                        playerGUID,
                        player,
                        nil,
                        nil,
                        nil,
                        nil,
                        nil,
                        nil,
                        1,
                        '',
                    }
                    tbl.i = 1
                    tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
                end
                return
            end
        end

        TJ.CreateBoard(FB, bossIndex, tbl)

        --[[
/run TJ.Board_ENCOUNTER_START(TuanJian.FB, TuanJian.bossIndex)
/run TJ.frame[TuanJian.FB][TuanJian.bossIndex].BOSS_SAY("它是冰吼，")
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,66683)
 ]]
    end)

    -- P1坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    TJ.SetEditText(v, title)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["1坦优先安排DKT，2坦/3坦其他坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_mount_mammoth_brown_3seater", L["P1坦克链"],
            text, TJ.tankClass, nil, nil, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["1坦"])
        TJ.CreateEdit(FB, bossIndex, L["2坦"])
        if TJ.IsWLK_80 then
            TJ.CreateEdit(FB, bossIndex, L["3坦"])
        end
    end
    -- P2坦克
    do
        -- local function AutoFuc(title)
        --     local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
        --     for i, v in ipairs(tbl) do
        --         if v.class == "DEATHKNIGHT" then
        --             TJ.SetEditTextFormNum(v, title, 2)
        --             tremove(tbl, i)
        --             break
        --         end
        --     end
        --     if #tbl >= 2 then
        --         for i, v in ipairs(tbl) do
        --             TJ.SetEditText(v, title)
        --         end
        --     elseif #tbl >= 1 then
        --         TJ.SetEditTextFormNum(tbl[1], title, 1)
        --     end
        -- end
        -- local text = L["恐鳞1坦优先安排DKT，恐鳞2坦和酸喉安排任意坦克。"]
        -- TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_creature_poison_05", L["P2主坦克"],
        --     text, TJ.tankClass, nil, nil, nil, true)
        -- TJ.CreateEdit(FB, bossIndex, L["酸喉"])
        -- if TJ.IsWLK_80 then
        --     TJ.CreateEdit(FB, bossIndex, L["恐鳞1坦"])
        --     TJ.CreateEdit(FB, bossIndex, L["恐鳞2坦"])
        -- else
        --     TJ.CreateEdit(FB, bossIndex, L["恐鳞"])
        -- end
    end
    -- P3坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    TJ.SetEditText(v, title)
                    return
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["优先安排DKT。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_hunter_pet_gorilla", L["P3主坦克"],
            text, TJ.tankClass, nil, info, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["冰喉"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 穿刺
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            66331,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_throw", L["穿刺"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 狗头人上身
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            66406,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_mage_tormentoftheweak", L["狗头人上身"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 喷吐
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                66820
                            },
                            combatRole = { "Isdps", "Ishealer" },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["熔岩喷射"]) },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                66819
                            },
                            combatRole = { "Isdps", "Ishealer" },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["强酸喷射"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_burnout", L["喷吐"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 麻痹毒素
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                66823,
                            },
                            colorNum = 1,
                        },
                        {
                            spellID = {
                                66830,
                            },
                            colorNum = 5,
                        },


                    },
                    destNpcType = { "Player" },
                },
                title = { name = L['麻痹毒素'], icon = 66823 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                66869,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L['灼热胆汁'], icon = 66869 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_creature_poison_03", L["麻痹毒素"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 重型撞击
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 66683, },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["Boss施放%s"]:format(L["重型撞击"]), icon = 66683 }
            },
            {
                trigger = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                1,
                            },
                            colorNum = 2,
                            tooltipText = TJ.AddIconBySpellID(66734) .. L["冰喉践踏点名"],
                            tooltip = "trigger",
                        },
                    },
                },
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                66734,
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["践踏点名&受到践踏伤害"] },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_golemthunderclap", L["重型撞击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        34800,
                    },
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                66406,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["狗头人上身"], icon = 66406 },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_kick", L["转火狗头人"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
