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

def set_active(pidgin)
    puts "trying to set active"
    name = "Available"
    status = pidgin.PurpleSavedstatusGetCurrent[0]
    if pidgin.PurpleSavedstatusGetType(status)[0] != 2
        puts "setting status active"
        set_status(pidgin, 2, name, "")
    end
end

def set_away(pidgin)
    puts "trying to set away"
    name = "screensaver"
    msg = "screen saver auto away"
    status = pidgin.PurpleSavedstatusGetCurrent[0]
    if pidgin.PurpleSavedstatusGetType(status)[0] != 5
        set_status(pidgin, 5, name, msg)
    end
end

def set_status(pidgin, type, name, message)
    status = pidgin.PurpleSavedstatusFind(name)[0]
    if not status > 0
        status = pidgin.PurpleSavedstatusNew(name, type)[0]
    end
    
    pidgin.PurpleSavedstatusSetMessage(status, message)
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
