#!/usr/bin/ruby

require "rubygems"
require "dbus"
require "twitter"
require "pp"
require "dbus/pidgin"
require "dbus/status"
require "dbus/screensaver"
require "dbus/network"

@@msg = ""

def sync_status(pidgin, online)
    begin 
        puts "sync_status"
        @@msg = online.status
        pidgin.status_msg(@@msg)
    rescue => e
        puts "#{$!} => #{e}"
        @@msg = pidgin.status.msg
    end
end

def run()
    system_bus = DBus::SystemBus.instance
    session_bus = DBus::SessionBus.instance
    
    pidgin = DBUS::Pidgin.new(session_bus)
    online = DBUS::Status.new(pidgin, "accounts.yaml")
    netman = DBUS::Network.new(system_bus)
    screensaver = DBUS::ScreenSaver.new(session_bus)
    
    sync_status(pidgin, online)

    pidgin.on_signal("AccountStatusChanged") { |id, status, reason|
        puts "AccountStatusChanged"
        puts "Reason = #{reason}"
        # this appears to be user changed
        #    if reason == 1293
        s = pidgin.status
        if s.msg != "" and s.msg != @@msg
            sync_status(pidgin, online)
        end
    }

    pidgin.on_signal("SentImMsg") { |id, who, msg| 
        puts "#{id} - #{who}: #{msg}"
        begin 
            if pidgin.status.type == PIDGIN_AWAY
                puts "Setting status"
                pidgin.active!(online.status)
            end
        rescue => e      
            puts "#{$!} => #{e}"
        end
    }
    
    # pidgin.on_signal("SentImMsg") { |id, who, msg|
    #     if who == "twitter@twitter.com" and !(msg =~ /^(invite|off|track|help|follow|whois|d \w+|whois)/)
    #         puts "setting twitter status"
    #         set_status(pidgin, 2, "Available", msg)
    #     else
    #         set_active(pidgin)
    #     end
    #     puts "#{id} - #{who}: #{msg}"
    # }
    
    # pidgin.on_signal("WroteImMsg") { |a, b, c, d|
    #     pp a
    #     pp b
    #     pp c
    #     pp d
    # }

    screensaver.on_signal("ActiveChanged") {|state|
        if state
            screensaver.mute
            pidgin.away!
        else
            screensaver.unmute
        end
    }
    
    netman.on_signal(system_bus, "DeviceNowActive") { |d, n|
        puts "Device now active #{d} #{n}"
        pidgin.reconnect
        sync_status(pidgin, online)
    }

    main = DBus::Main.new
    main << system_bus
    main << session_bus
    main.run
end

# and actually run the program
run
