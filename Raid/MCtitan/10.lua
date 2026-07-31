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
local FB = "MCtitan"
local bossIndex = 10
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
    -- 技能提醒
    if TJ.canUseTips then
        local name = "tips1" .. FB .. bossIndex

        local function SendMsg()
            SendChatMessage(L["马上击飞，近战准备后退！>> 3 <<"], "RAID_WARNING")
            After(1, function()
                SendChatMessage(L["马上击飞，近战准备后退！>> 2 <<"], "RAID_WARNING")
            end)
            After(2, function()
                SendChatMessage(L["马上击飞，近战准备后退！>> 1 <<"], "RAID_WARNING")
            end)
        end

        local f = CreateFrame("Frame")
        function f:Start(duration)
            f.t = duration - 3
            f:SetScript("OnUpdate", function(self, t)
                f.t = f.t - t
                if f.t <= 0 then
                    f:SetScript("OnUpdate", nil)
                    if TJ.IsLeader() and IsInRaid(1) then
                        SendMsg()
                    end
                end
            end)
        end
        
        local DBMCallback = function(event, id, msg, duration, icon, timerType, spellID)
            -- pt(event, id, msg, duration, icon, timerType, spellID)
            if TuanJian.options[name] == 1 and spellID == 20566 then
                if (event == "DBM_TimerStart" or event == "DBM_TimerBegin") then
                    f:Start(duration)
                elseif event == "DBM_TimerStop" then
                    f:SetScript("OnUpdate", nil)
                end
            end
        end
        tinsert(TJ.DBMCallback, DBMCallback)

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["拉格纳罗斯之怒团队提醒"],
            L["当拉格纳罗斯之怒即将施放时，你会在RW频道自动发送提醒。"],
            " ",
            L["需要你是团长或助理，且安装了DBM插件，该功能才生效。"],
        }
        local f = ns.O.CreateCheckButton(name, AddTexture(135827) .. L["拉格纳罗斯之怒团队提醒（需要团长/助理）"],
            TJ.frame[FB][bossIndex], 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
    end

    -- 站位图
    do
        local function Sort(team)
            return team
            -- local team = TJ.Copy(team)
            -- local new = {}
            -- for i = 1, #team do
            --     for i, v in ipairs(team) do
            --         if v.class == "WARLOCK" then
            --             tinsert(new, v)
            --             tremove(team, i)
            --         end
            --     end
            -- end
            -- for i, v in ipairs(team) do
            --     tinsert(new, v)
            -- end
            -- return new
        end
        local tbl = {
            { point = "TOPLEFT", xy = { 493, -116 } },
            { point = "TOPLEFT", xy = { 595, -178 } },
            { point = "TOPLEFT", xy = { 100, -318 } },
            { point = "TOPLEFT", xy = { 328, -410 } },
            { point = "TOPLEFT", xy = { 438, -360 } },
            { point = "TOPLEFT", xy = { 80, -181 } },
            { point = "TOPLEFT", xy = { 30, -260 } },
            { point = "TOPLEFT", xy = { 68, -405 } },
            { point = "TOPLEFT", xy = { 203, -388 } },
            { point = "TOPLEFT", xy = { 149, -456 } },
            { point = "TOPLEFT", xy = { 255, -466 } },
            { point = "TOPLEFT", xy = { 413, -446 } },
            { point = "TOPLEFT", xy = { 547, -378 } },
            { point = "TOPLEFT", xy = { 496, -275 } },
            { point = "TOPLEFT", xy = { 588, -284 } },

            [97] = {
                xy = { 242, -140 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["惩戒骑\n增强萨"],
                isNPC_icon = "Interface\\Icons\\Spell_Holy_AuraOfLight",
            },
            [98] = {
                xy = { 258, -245 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 378, -151 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 317, -194 }, isNPC = "b" .. bossIndex },
        }

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(TJ.healerClass, "healer", true)
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetMapIconPlayerFormNum(1, v)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetMapIconPlayerFormNum(2, v)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 1, max = 5 })
            end

            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["1-2：奶骑。"],
            L["3-5：其他治疗。"],
            L["6-15：远程DPS。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local map = TJ.CreateMap(FB, bossIndex, tbl, 650, 505)
    end

    -- 团员火抗
    TJ.CreateResistanceFrame(FB, bossIndex, "spell_fire_sealoffire", L["团员火抗"], 2, "LEFT")

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    TJ.SetEditTextFormNum(v, title, 1)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    TJ.SetEditTextFormNum(v, title, 2)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["BOSS优先安排DKT。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["BOSS1坦"])
        TJ.CreateEdit(FB, bossIndex, L["BOSS2坦"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
    -- 拉格纳罗斯之怒
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            20566,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_soulburn", L["拉格纳罗斯之怒"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
