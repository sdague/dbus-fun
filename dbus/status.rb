require "twitter"
module DBUS
    class Status
        
    end
    
    class Status::Twitter
        @user = ""
        @me = ""
        @passwd = ""
        @conn = nil
        def initialize(file)
            config = YAML.load_file(file)
            @user = config["twitter"]["user"]
            @me = config["twitter"]["me"]
            @passwd = config["twitter"]["passwd"]
            @conn = Twitter::Base.new(@user, @passwd)
        end
        
        def status
            msg = ""
            begin
                puts "Retrieving twitter status"
                msg = @conn.user(@me).status.text
            rescue => e
                puts "#{$!} => #{e}"
            end
            return msg
        end
        
        def status=(s)
            begin
                puts "Pushing '#{s}' to twitter"
                @conn.post(s)
            rescue => e
                puts "#{$!} => #{e}"
            end
        end
    end
end
