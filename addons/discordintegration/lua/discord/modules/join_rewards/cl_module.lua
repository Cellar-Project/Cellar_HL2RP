local ratelimit = 0
function Discord:JoinDiscord()
    if ratelimit > CurTime() then
        Discord:Chat(Discord.Util:GetLang('RATELIMITED', {
            seconds = math.floor(ratelimit - CurTime()),
        }))
        return
    end

    ratelimit = CurTime() + 5

    if not Discord.RPC.discovered then
        Discord:Chat(Discord.Util:GetLang('DISCORD_NOT_FOUND'))
        gui.OpenURL(Discord.Backend.HTTP_URL .. 'auth/discord?token=' .. Discord.Backend.Key .. '&op=' .. Discord.OP.JOIN_DISCORD)
        return
    end

    Discord:Chat(Discord.Util:GetLang('CHECK_DISCORD'))
    Discord.RPC:Request({'identify', 'connections', 'guilds.join'}, Discord.Config.ClientID, function(err, data)
        if err and string.find(err, 'OAuth2 Error: access_denied: unknown error') then
            Discord:Chat(Discord.Util:GetLang('RPC_ABORTED'))
            return
        end

        if err or not data.code then
            Discord:Error(err or util.TableToJSON(data))
            Discord:Chat(Discord.Util:GetLang('SOMETHING_WENT_WRONG'))
            return
        end

        Discord.Backend.API:Send({
            op = Discord.OP.JOIN_DISCORD,
            d = data.code,
        })
    end)
end

net.Receive('Discord_JoinRewards_Activate', Discord.JoinDiscord)
concommand.Add(Discord.Config.JoinRewards.ConsoleCommand, Discord.JoinDiscord)

local function Query(query)
    local res = sql.Query(query)

    if res == false then
        Discord:Error('Failed running the following query: ' .. query .. '\nError: ' .. sql.LastError())
        return
    end

    return res
end

Query([[
CREATE TABLE IF NOT EXISTS discord_joinrewards (
    server_ip TEXT UNIQUE PRIMARY KEY
)
]])

local safeIP = string.Replace(string.Replace(Discord.Util:GetServerIP(), ':', '.'), '.', '_')
net.Receive('Discord_JoinDiscord', function(len)
    Query('INSERT INTO discord_joinrewards (server_ip) VALUES (' .. sql.SQLStr(safeIP) .. ')')
end)

function Discord:OpenPopup()
    if Discord.Config.JoinRewards.PopupOnJoin then
        local discord_popup = CreateClientConVar('discord_popup', 1, FCVAR_ARCHIVE, 'Enable "Join Discord" popups for Discord Integration?')
        if not discord_popup:GetBool() then return Discord:Debug('Popup enabled, but it is ignored by discord_popup convar.') end

        local res = Query('SELECT COUNT(server_ip) FROM discord_joinrewards WHERE server_ip = ' .. sql.SQLStr(safeIP))
        if not res or not res[1] or not res[1]['COUNT(server_ip)'] or not tonumber(res[1]['COUNT(server_ip)']) then return Discord:Error('Failed retrieving popup status.') end
        if tonumber(res[1]['COUNT(server_ip)']) > 0 then
            return Discord:Debug('Popup enabled, but it has already been displayed once or the user is already in Discord.')
        end

        if Discord.Popup and Discord.Popup:IsVisible() then
            Discord.Popup:Close()
        end

        Discord.Popup = vgui.Create('DFrame')
        Discord.Popup:SetSize(500, 185)
        Discord.Popup:ShowCloseButton(false)
        Discord.Popup:SetTitle('')
        Discord.Popup:Center()
        Discord.Popup:MakePopup()

        local shade = 55
        local backgroundColor = Color(shade, shade, shade)
        local titleColor = Color(60, 128, 200)
        local white = Color(255, 255, 255)
        local titleText = 'Discord Integration'
        local centerText = Discord.Lang.CENTER_TEXT
        local centerSmallerText = Discord.Lang.CENTER_BELOW_TEXT
        
        local font = 'Tahoma'
        surface.CreateFont('Discord_Popup_Title', {
            font = font,
            weight = 200,
            size = 20,
        })

        surface.CreateFont('Discord_Popup_Center', {
            font = font,
            weight = 100,
            size = 24,
        })

        surface.CreateFont('Discord_Popup_CenterSmaller', {
            font = font,
            weight = 100,
            size = 28,
        })
        
        local btnWidth = (Discord.Popup:GetWide() - 30) / 2
        local btnTall = 80
        local joinBoxBackground = Color(46, 184, 80)
        local joinButtonText = Discord.Lang.JOIN_BUTTON
        local laterBoxBackground = Color(184, 46, 80)
        local laterButtonText = Discord.Lang.LATER_BUTTON

        surface.CreateFont('Discord_Popup_Button', {
            font = font,
            weight = 100,
            size = 26,
        })

        Discord.Popup.Paint = function(self, w, h)
            draw.RoundedBoxEx(5, 0, 0, w, 25, titleColor, true, true)
            draw.RoundedBoxEx(5, 0, 25, w, h - 25, backgroundColor, false, false, true, true)

            surface.SetTextColor(white)

            surface.SetFont('Discord_Popup_Title')
            local titleW, titleH = surface.GetTextSize(titleText)
            surface.SetTextPos(w / 2 - titleW / 2, 25 / 2 - titleH / 2)
            surface.DrawText(titleText)

            local textCenter = 25 + (h - 25 - btnTall - 10) / 2

            surface.SetFont('Discord_Popup_Center')
            local centerW, centerH = surface.GetTextSize(centerText)
            surface.SetTextPos(w / 2 - centerW / 2, textCenter - centerH / 2)
            surface.DrawText(centerText)

            surface.SetFont('Discord_Popup_CenterSmaller')
            local centerSmallerW, centerSmallerH = surface.GetTextSize(centerSmallerText)
            surface.SetTextPos(w / 2 - centerSmallerW / 2, textCenter - centerH / 2 + centerH)
            surface.DrawText(centerSmallerText)
        end

        Discord.Popup.Join = vgui.Create('DButton', Discord.Popup)
        Discord.Popup.Join:SetText('')
        Discord.Popup.Join:SetSize(btnWidth, btnTall)
        Discord.Popup.Join:Dock(LEFT)
        Discord.Popup.Join:DockMargin(5, Discord.Popup:GetTall() - 10 - btnTall, Discord.Popup:GetWide() - btnWidth - 10, 5)

        Discord.Popup.Join.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, joinBoxBackground)
            
            surface.SetTextColor(white)
            surface.SetFont('Discord_Popup_Button')
            local textW, textH = surface.GetTextSize(joinButtonText)
            surface.SetTextPos(w / 2 - textW / 2, h / 2 - textH / 2)
            surface.DrawText(joinButtonText)
        end

        Discord.Popup.Later = vgui.Create('DButton', Discord.Popup)
        Discord.Popup.Later:SetText('')
        Discord.Popup.Later:SetSize(btnWidth, btnTall)
        Discord.Popup.Later:Dock(RIGHT)
        Discord.Popup.Later:DockMargin(Discord.Popup:GetWide() - btnWidth - 10, Discord.Popup:GetTall() - 10 - btnTall, 5, 5)

        Discord.Popup.Later.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, laterBoxBackground)

            surface.SetTextColor(white)
            surface.SetFont('Discord_Popup_Button')
            local textW, textH = surface.GetTextSize(laterButtonText)
            surface.SetTextPos(w / 2 - textW / 2, h / 2 - textH / 2)
            surface.DrawText(laterButtonText)
        end

        Discord.Popup.Join.DoClick = function()
            Discord:JoinDiscord()
            Discord.Popup:Close()
        end

        Discord.Popup.Later.DoClick = function()
            if Discord.Config.JoinRewards.OneTime then
                Query('INSERT INTO discord_joinrewards (server_ip) VALUES (' .. sql.SQLStr(safeIP) .. ')')
            end

            Discord.Popup:Close()
        end
    end
end

timer.Simple(1, Discord.OpenPopup)