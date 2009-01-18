require "twitter"

module DBUS
    class Status
        @services = []
        def initialize(pidgin, file)
            @services = []
            if s = Status::Twitter.new(file)
                @services << s
            end
            if s = Status::Identica.new(pidgin, file)
                @services << s
            end
        end
        
        def status=(s)
            @services.each do |svr|
                svr.status = s
            end
        end
        
        def status
            puts "Retrieving status"
            a = @services[0].status
            puts "Status: #{a}"
            return a
        end
    end

    class Status::Identica
        @account = ""
        @pidgin = nil
        def initialize(pidgin, file)
            config = YAML.load_file(file)
            @account = config["identica"]["user"]
            @pidgin = pidgin
        end
        
        def status=(s)
            @pidgin.send_im(@account, "update@identi.ca", s)
        end
    end
    
    class Status::Twitter
        @user = ""
        @me = ""
        @passwd = ""
        @conn = nil
        def initialize(file)
            config = YAML.load_file(file)
            begin
                @user = config["twitter"]["user"]
                @me = config["twitter"]["me"]
                @passwd = config["twitter"]["passwd"]
                @conn = Twitter::Base.new(@user, @passwd)
            rescue => e
                puts "#{$!} => #{e}"
                return nil
            end
        end
        
        def status
            msg = ""
            begin
                puts "Retrieving twitter status"
                msg = @conn.user(@me).status.text
                puts "Status #{msg}"
            rescue => e
                puts "#{$!} => #{e}"
            end
            return msg
        end
        
        def status=(s)
            return
            begin
                puts "Pushing '#{s}' to twitter"
                @conn.post(s)
            rescue => e
                puts "#{$!} => #{e}"
            end
        end
    end
end
