module DBUS
    class SreenSaver
        @conn = nil
        @vol = 0
        def initialize(bus)
            ss_dbus = bus.service("org.gnome.ScreenSaver")
            @conn = ss_dbus.object("/org/gnome/ScreenSaver")
            @conn.introspect
            if @conn.has_iface? "org.gnome.ScreenSaver"
                @conn.default_iface = "org.gnome.ScreenSaver"
            end
        end
        
        def mute()
            return if @vol == 0

            IO.popen("aumix -wq") {|r|
                r.read.scan(/(\d+)/) {|m|
                    @vol = m
                    puts "saved volume: #{@vol}"
                    break
                }
            }
            puts "muting"
            system("aumix -w 0")
        end
        
        def unmute()
            puts "unmuting"
            system("aumix -w #{@vol}")
        end
        
        # if there is anything we haven't caught yet, just pass it on down
        def method_missing(sym, *args, &block)
            @conn.send sym, *args, &block
        end
    end
end
