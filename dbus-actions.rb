#!/usr/bin/ruby

require "dbus"

@@vol = 0

def recycle_pidgin(pidgin)
    accounts = pidgin.PurpleAccountsGetAll
    for account in accounts[0]
        if pidgin.PurpleAccountIsConnected(account)[0] > 0
            pidgin.PurpleAccountDisconnect(account)
        end
        pidgin.PurpleAccountConnect(account)
    end
end

def set_away(pidgin)
    puts "trying to set away"
    name = "screensaver"
    status = pidgin.PurpleSavedstatusFind(name)[0]
    if not status > 0
        status = pidgin.PurpleSavedstatusNew(name, 5)[0]
    end
    puts "Status #{status}"

    pidgin.PurpleSavedstatusSetMessage(status, "screen saver auto away")
    pidgin.PurpleSavedstatusActivate(status)
end

def ip_to_str(ip)
    d = ip & 0xFF
    c = (ip >> 8) & 0xFF
    b = (ip >> 16) & 0xFF
    a = (ip >> 24) & 0xFF

    return "#{d}.#{c}.#{b}.#{a}"
end


def mute()
    IO.popen("aumix -vq") {|r|
        r.read.scan(/(\d+)/) {|m|
            @@vol = m
            puts "saved volume: #{@@vol}"
            break
        }
    }
    puts "muting"
    system("aumix -v 0")
end

def unmute()
    puts "unmuting"
    system("aumix -v #{@@vol}")
end
