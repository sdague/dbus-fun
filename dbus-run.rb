#!/usr/bin/ruby

require "dbus"
require "pp"
require "dbus-connect"
require "dbus-actions"
require "dbus/pidgin"
require "dbus/status"

bus = DBus::SystemBus.instance
session_bus = DBus::SessionBus.instance
pidgin = DBUS::Pidgin.new(session_bus)
online = DBUS::Status.new()

@@msg = pidgin.status.msg

netman = connect_netman(bus)
ss = connect_screensaver(session_bus)

pidgin.on_signal("AccountStatusChanged") { |id, status, reason|
    puts "AccountStatusChanged"
    puts "Reason = #{reason}"
    # this appears to be user changed
#    if reason == 1293
        s = pidgin.status
        if s.msg != "" and s.msg != @@msg
            online.status = s.msg
            @@msg = s.msg
        end
 #   end
}

pidgin.on_signal("SentImMsg") { |id, who, msg| 
    puts "#{id} - #{who}: #{msg}"
    pidgin.active!
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
ss.on_signal("ActiveChanged") {|s|
    if s
        mute
        pidgin.away!
    else
        unmute
    end
}

netman.on_signal(bus, "DeviceNowActive") { |d, n|
    pidgin.reconnect
    #dev = connect_netdev(bus, d)
    #puts "0x%08x" % dev.getIP4Address
    #pp d
    #pp n
    # recycle_pidgin(pidgin) 
}

main = DBus::Main.new
main << bus
main << session_bus
main.run
