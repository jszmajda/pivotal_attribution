module Outputters
  class Ansi
    attr_accessor :max_username
    attr_accessor :separator

    def initialize(sep)
      self.separator = sep
    end

    def configure_users(users)
      @max_username = users.max{|a,b| a.length<=>b.length}
    end

    def since_header(since)
      puts "\e[1;32mSince #{since || "Project Inception"}\e[0m"
    end

    def points_header
      puts "\n\e[1;32mPoints by user:\e[0m"
    end

    def points_per_user(user, complete, pending)
      u = user_color(user, max_username.length)
      complete = "\e[32mComplete:\e[0m #{col_num complete, 3}"
      pending = "\e[31mPending:\e[0m #{col_num pending, 3, true}"
      puts "#{u}#{separator}#{complete}#{separator}#{pending}"
    end

    def iterations_header(iterations)
      puts "\n\e[1;32m#{iterations.size} Iterations\e[0m"
    end

    def iterations_table_header(idates)
      puts "#{"".ljust(max_username.length)}#{separator}#{idates.collect{|itr| "\e[33m"+itr.strftime("%m/%d").ljust(5) +"\e[0m"}.join("#{separator}")}"
    end
    
    def iterations_for_user(user, iterations)
      puts "#{user_color(user,max_username.length)}#{separator}#{iterations.collect{|itr| col_num(itr[user], 5)}.join("#{separator}")}"
    end

    def iterations_total(iterations)
      puts "#{user_color("Total",max_username.length)}#{separator}#{iterations.collect{|itr| col_num(itr.values.inject{|sum, x| sum + x}, 5)}.join("#{separator}")}"
    end

    def complete!
    end

    private
      def col_num(val, pad, inverse=false)
        v = val.to_i
        s = case v
            when 0
              inverse ? "1;33" : "1;30"
            when (1..5)
              inverse ? "1;33" : "1;31"
            when (6..10)
              inverse ? "1;32" : "1;34"
            when (10..20)
              inverse ? "1;34" : "1;32"
            when (20..999999)
              inverse ? "1;31" : "1;33"
            end
        "\e[#{s}m#{v.to_s.ljust(pad)}\e[0m"
      end
      def user_color(user, pad)
        "\e[36m#{user.ljust(pad)}\e[0m"
      end

  end
end
