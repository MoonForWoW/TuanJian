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
local bossIndex = 6
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
    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 237, -244 } },
            { point = "TOPLEFT", xy = { 386, -254 } },
            { point = "TOPLEFT", xy = { 447, -185 } },
            { point = "TOPLEFT", xy = { 389, -108 } },
            { point = "TOPLEFT", xy = { 252, -114 } },
            { point = "TOPLEFT", xy = { 106, -390 } },
            { point = "TOPLEFT", xy = { 291, -447 } },
            { point = "TOPLEFT", xy = { 488, -420 } },
            { point = "TOPLEFT", xy = { 582, -301 } },
            { point = "TOPLEFT", xy = { 585, -196 } },
            { point = "TOPLEFT", xy = { 530, -109 } },
            { point = "TOPLEFT", xy = { 462, -55 } },
            { point = "TOPLEFT", xy = { 341, -40 } },
            { point = "TOPLEFT", xy = { 240, -52 } },
            { point = "TOPLEFT", xy = { 145, -88 } },
            { point = "TOPLEFT", xy = { 92, -141 } },
            { point = "TOPLEFT", xy = { 68, -274 } },

            [100] = { xy = { 321, -167 }, isNPC = "b" .. bossIndex },
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
        local map = TJ.CreateMap(FB, bossIndex, tbl, 650, 520)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["P2站位"])
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 25, "OUTLINE")
        t:SetPoint("BOTTOM", -30, 10)
        t:SetText(L["入口"])
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
    -- 根基图腾
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["优先安排奶萨，其次其他萨满。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_groundingtotem", L["根基图腾"],
            text, { "SHAMAN" }, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["根基图腾"])
        TJ.CreateEdit(FB, bossIndex, L["根基图腾"])
    end
    -- 风筝长脚
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["扰乱射击"],
                        colorNum = 1
                    },
                },
                destNPCID = { 22056, }
            }
        }
        local text = L["仅安排猎人。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_arcane_blink", L["风筝长脚"],
            text, nil, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["风筝长脚"])
        TJ.CreateEdit(FB, bossIndex, L["风筝长脚"])
    end
    -- 传核
    do
        local function AutoFuc(title)
        end
        local info = {
            {
                trigger = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                31088,
                            },
                            colorNum = 2,
                            tooltipText = AddTexture(136030) .. L["拾取污染之核"],
                            tooltip = "trigger",
                        },
                    },
                    showCount = true,
                },
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                38134
                            },
                            colorNum = 1,
                        },
                    },
                },
                notShowDead = true,
            },
            {
                trigger = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                -1,
                            },
                            colorNum = 1,
                            tooltipText = L["毒元素出现"],
                            tooltip = "trigger",
                        },
                        {
                            spellID = {
                                -2,
                            },
                            colorNum = 7,
                            tooltipText = L["成功击杀毒元素"],
                            tooltip = "trigger",
                        },
                        {
                            spellID = {
                                -3,
                            },
                            colorNum = 5,
                            tooltipText = L["毒元素消失，没有被击杀"],
                            tooltip = "trigger",
                        },
                    },
                },
                title={name=L["毒元素击杀情况"]}
            },
        }
        local text = L["此任务只能手动安排。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_elementalshields", L["传核"],
            text, nil, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["传核"])
        TJ.CreateEdit(FB, bossIndex, L["传核"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
    -- 多重射击
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            38310
                        },
                    },
                },
                destNpcType = { "Player" },
            },
            title = { name = L["受到%s伤害"]:format(L["多重射击"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_upgrademoonglaive", L["多重射击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 震爆
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                38509
                            },
                            colorNum = 2,
                        },
                    },
                },
                notShowDead = true,
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                8177
                            },
                        },
                    },
                },
                notShowDead = true,
                title = { name = L["使用根基图腾"], icon = 8177 }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_wispheal", L["震爆"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 静电充能
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                38280
                            },
                            colorNum = 2,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = L["点名"],
            },
            {
                damageFriend = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                38281
                            },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["误伤队友"], }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_lightningoverload", L["静电充能"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 缠绕
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                38316
                            },
                            colorNum = 2,
                        },
                        {
                            spellID = ns.sp["自由"],
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
                notShowDead = true,
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["自由"],
                        },
                    },
                },
                notShowDead = true,
                title = { name = L["给自由"], icon = 1044 }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_stranglevines", L["缠绕"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 顺劈斩
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            38260
                        },
                        combatRole = { "Isdps", "Ishealer" },
                    },
                },
                destNpcType = { "Player" },
            },
            title = { name = L["受到%s伤害"]:format(L["顺劈斩"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["顺劈斩"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火精英
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    22055
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["转火精英"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火长脚
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    22056
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_psychicscream", L["转火长脚"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火水元素
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    22009, 21958
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_summonwaterelemental_2", L["转火水元素"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火孢子蝠
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    22140,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_pet_sporebat", L["转火孢子蝠"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转P3清场伤害
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    22009, 21958, 22056, 22055
                },
                startTime = "P3",
                endTime = "duration",
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_summonwaterelemental_2", L["转P3清场伤害"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local new = true
    local notDead
    mainFrame:SetScript("OnEvent", function(self, event, msg, ...)
        if event == "CHAT_MSG_LOOT" then
            local lootplayer, link, count
            link, count = strmatch(msg, string.gsub(string.gsub(LOOT_ITEM_SELF_MULTIPLE, "%%s", "(.+)"), "%%d", "(%%d+)"));
            if (not link) then
                link, count = strmatch(msg, string.gsub(string.gsub(LOOT_ITEM_PUSHED_SELF_MULTIPLE, "%%s", "(.+)"), "%%d", "(%%d+)"));
                if (not link) then
                    link = msg:match(LOOT_ITEM_SELF:gsub("%%s", "(.+)"));
                    if (not link) then
                        link = msg:match(LOOT_ITEM_PUSHED_SELF:gsub("%%s", "(.+)"));

                        if (not link) then
                            lootplayer, link, count = strmatch(msg, string.gsub(string.gsub(LOOT_ITEM_MULTIPLE, "%%s", "(.+)"), "%%d", "(%%d+)"));
                            if (not link) then
                                lootplayer, link, count = strmatch(msg, string.gsub(string.gsub(LOOT_ITEM_PUSHED_MULTIPLE, "%%s", "(.+)"), "%%d", "(%%d+)"));
                                if (not link) then
                                    lootplayer, link = msg:match("^" .. LOOT_ITEM:gsub("%%s", "(.+)"));
                                    if (not link) then
                                        lootplayer, link = msg:match("^" .. LOOT_ITEM_PUSHED:gsub("%%s", "(.+)"));
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if link then
                local itemID = tonumber(link:match("item:(%d+):"))
                if itemID == 31088 then
                    lootplayer = lootplayer or TJ.playerName
                    TJ.GetNewEvent()["TRIGGER"] =
                        TJ.GetNewEvent()["TRIGGER"] or {}
                    local tbl = {
                        TJ.GetDurTime(),
                        "TRIGGER",
                        nil,
                        UnitGUID(lootplayer),
                        lootplayer,
                        nil,
                        nil,
                        nil,
                        nil,
                        nil,
                        nil,
                        31088,
                        L["污染之核"],
                    }
                    tbl.i = 1
                    tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
                end
            end
        end
    end)
    mainFrame.ENCOUNTER_START = function(...)
        mainFrame:RegisterEvent("CHAT_MSG_LOOT")
        new = true
        notDead = nil
    end
    mainFrame.ENCOUNTER_END = function(...)
        mainFrame:UnregisterEvent("CHAT_MSG_LOOT")
        new = true
        notDead = nil
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match(L["机会来了"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
        if msg:match(L["掩护"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P3",
            })
            return
        end
    end

    mainFrame.SPELL_CAST_START = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 38253 and new then
            new = nil
            notDead = true

            TJ.GetNewEvent()["TRIGGER"] =
                TJ.GetNewEvent()["TRIGGER"] or {}
            local tbl = {
                TJ.GetDurTime(),
                "TRIGGER",
                nil,
                "",
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
                -1,
            }
            tbl.i = 1
            tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)

            After(16, function()
                new = true
                if notDead then
                    TJ.GetNewEvent()["TRIGGER"] =
                        TJ.GetNewEvent()["TRIGGER"] or {}
                    local tbl = {
                        TJ.GetDurTime(),
                        "TRIGGER",
                        nil,
                        "",
                        nil,
                        nil,
                        nil,
                        nil,
                        nil,
                        nil,
                        nil,
                        -3,
                    }
                    tbl.i = 1
                    tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
                end
            end)
        end
    end

    mainFrame.UNIT_DIED = function(...)
        local tbl = { ... }
        if TJ.GetNPCID(tbl[8]) == 22009 then
            notDead = nil
            TJ.GetNewEvent()["TRIGGER"] =
                TJ.GetNewEvent()["TRIGGER"] or {}
            local tbl = {
                TJ.GetDurTime(),
                "TRIGGER",
                nil,
                "",
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
                -2,
            }
            tbl.i = 1
            tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
        end
    end
end
