#!/usr/bin/ruby

require "rubygems"
require "dbus"
require "twitter"
require "yaml"
require "pp"

@@vol = 0
@@msg = ""
config = YAML.load_file("accounts.yaml")
@@user = config["twitter"]["user"]
@@me = config["twitter"]["me"]

@@twitter = Twitter::Base.new(@@user, config["twitter"]["passwd"])

def ip_to_str(ip)
    d = ip & 0xFF
    c = (ip >> 8) & 0xFF
    b = (ip >> 16) & 0xFF
    a = (ip >> 24) & 0xFF

    return "#{d}.#{c}.#{b}.#{a}"
end


def mute()
    IO.popen("aumix -wq") {|r|
        r.read.scan(/(\d+)/) {|m|
            @@vol = m
            puts "saved volume: #{@@vol}"
            break
        }
    }
    puts "muting"
    system("aumix -w 0")
end

def unmute()
    puts "unmuting"
    system("aumix -w #{@@vol}")
end
