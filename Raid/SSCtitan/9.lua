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
    -- 自动标记
    local name = "rt" .. FB .. bossIndex
    do
        local instanceID = TJ.FBinfo[FB].ID
        TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
        TJ.autoRaidTargetInfo[instanceID][18806] = {
            [7] = true,
            [6] = true,
            np = true,
        }

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local icon = TJ.SetRaidTargetingTex(7,6)
        local ontext = {
        }
        local f = ns.O.CreateCheckButton(name, format(L["战斗中把日冕祭司标记为%s（需要团长/助理）"], icon),
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
    end

    -- 技能提醒
    if TJ.canUseTips then
        local name = "tips1" .. FB .. bossIndex

        local msg=L["你中了星术师之怒，请马上远离大团，否则将会灭团。"]

        mainFrame.SPELL_AURA_APPLIED = function(...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == 42783 and TuanJian.options[name] == 1 and TJ.IsLeader() and tbl[9] then
                SendChatMessage(msg, "WHISPER", nil, tbl[9])
            end
        end

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["自动密语提醒星术师之怒出人群"],
            L["当有人中了星术师之怒时，自动密语该团员出人群。"],
            L["需要你是团长或助理，该功能才生效。"],
            " ",
            L["密语内容如下："],
            msg,
        }
        local f = ns.O.CreateCheckButton(name, AddTexture(135734) .. L["自动密语提醒星术师之怒出人群"] .. L["（需要团长/助理）"],
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 45)
        f:SetHitRectInsets(0, 0, 0, 0)
        --[[
/run TJ.frame["TKtitan"][3].SPELL_AURA_APPLIED(nil,nil,nil,nil,nil,nil,nil,nil,"苍穹小号哈",nil,nil,42783)
 ]]
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

    -- 打断小怪
    do
        local function AutoFuc(title)
            local tbl = CopyTable(TJ.SortRaidRosterInfo({ "DEATHKNIGHT", "ROGUE", "WARRIOR", "SHAMAN" }, "dps1", true))
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    tbl[i].index = 1
                elseif v.class == "ROGUE" then
                    tbl[i].index = 2
                elseif v.class == "WARRIOR" then
                    tbl[i].index = 3
                elseif v.class == "SHAMAN" then
                    tbl[i].index = 4
                end
            end
            sort(tbl, function(a, b)
                if a.index and b.index then
                    return a.index < b.index
                end
                return false
            end)
            local done = {}
            for _, v in ipairs(tbl) do
                for _, i in ipairs({ 1, 3, 2, 4 }) do
                    if not done[i] then
                        TJ.SetEditTextFormNum(v, title, i)
                        done[i] = true
                        break
                    end
                end
            end
        end
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 33387 },
                        },
                    },
                },
                title = { name = L["漏打断"], color = { 1, 0, 0 } },
                canSend = "count",
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                33387
                            },
                        },
                    },
                },
                title = { name = L["成功打断"] }
            },
        }
        local text = TJ.IsTBC and L["优先安排盗贼/战士/增强萨。"] or L["优先安排DK/盗贼/战士/增强萨。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_heal", L["打断日晷祭司加血"],
            text, nil, nil, info, nil,
            true, 2)
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "chacha") .. L["叉叉1断"])
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "chacha") .. L["叉叉2断"])
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "fangkuai") .. L["方块1断"])
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "fangkuai") .. L["方块2断"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 星术师之怒
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            42783,
                        },
                        colorNum = 2,
                    }
                },
                showCount = true,
            },
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            42787,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
                showCount = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_arcane_arcanetorrent", L["星术师之怒"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火日晷祭司
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    18806
                },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_holysmite", L["转火日晷祭司"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.ENCOUNTER_START = function(...)
        TJ.setRTinCombat = TuanJian.options[name] == 1
    end
    mainFrame.UNIT_DIED = function(...)
        if TuanJian.options[name] == 1 then
            local tbl = { ... }
            if TJ.GetNPCID(tbl[8]) == 18806 then
                for i = 7, 8 do
                    TJ.ActiveAutoRaidTarget[i] = nil
                end
            end
        end
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match(L["我和虚空"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
    end
end
