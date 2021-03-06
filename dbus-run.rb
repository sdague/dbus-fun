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

#     pidgin.on_signal("AccountStatusChanged") { |id, status, reason|
#         puts "AccountStatusChanged"
#         puts "Reason = #{reason}"
#         # this appears to be user changed
#         #    if reason == 1293
# #         s = pidgin.status
# #         if s.msg != "" and s.msg != @@msg
# #             sync_status(pidgin, online)
# #         end
#     }
    
    pidgin.on_signal("SentImMsg") { |id, who, msg| 
        s = pidgin.status
        puts "SendImMsg: #{id} - #{who}: #{msg}"
        if who =~ /twitter/ or who =~ /tweet.im/
            if not msg =~ /^(rt|@)/i 
                pidgin.active!(msg)
            end
        elsif s.away?
            begin
                puts "Setting status"
                pidgin.active!(online.status)
            rescue => e      
                puts "#{$!} => #{e}"
            end
        end
    }
    
#     pidgin.on_signal("SentImMsg") { |id, who, msg|
#         if who == "pingfm" and !(msg =~ /^(invite|off|track|help|follow|whois|d \w+|whois)/)
#             puts "setting twitter status"
#             pidgin.active!(online.status)
#         else
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
    
    # This function isn't nearly as good as it was before because
    # networkmanager 0.7 both got more useful (broadcasting lots more
    # signals), and less useful, not providing a generic connection
    # signal like it did before.
    netman.on_signal(system_bus, "PropertiesChanged") { |s|
        # This means something changed on the networking
        sleep 1
        pidgin.reconnect
    }

    main = DBus::Main.new
    main << session_bus
    main << system_bus
    main.run
end

# and actually run the program
run
