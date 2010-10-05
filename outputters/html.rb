require 'haml'
require 'sass'

module Outputters
  class Html

    def initialize
      @model = Model.new
    end

    def configure_users(users); end
    def points_header; end

    def since_header(since)
      @model.since = "Since #{since || "Project Inception"}"
    end

    def points_per_user(user, complete, pending)
      @model.points_by_user << [user, complete, pending]
    end

    def iterations_header(iterations)
      @model.iterations_count = iterations.size
    end

    def iterations_table_header(idates)
      @model.iteration_dates = idates
    end
    
    def iterations_for_user(user, iterations)
      @model.users_and_iterations << [user, iterations.collect{|i| i[user]}]
    end

    def iterations_total(iterations)
      @model.users_and_iterations << ['Total', iterations.collect{|i| i.values.sum}]
    end

    def complete!
      # write html
      @model.style_sheet = Sass::Engine.new(File.read(File.join(File.dirname(__FILE__), 'templates', 'style.scss')), :syntax => :scss).render
      puts Haml::Engine.new(File.read(File.join(File.dirname(__FILE__), 'templates', 'attribution.haml'))).render(@model)
    end

    class Model
      attr_accessor :since, :style_sheet, :points_by_user, :iterations_count, :iteration_dates, :users_and_iterations

      def initialize
        @points_by_user = []
        @users_and_iterations = []
      end

      def class_for(val, invert=false)
        return '' if val.blank?
        v = val.to_i
        case v
        when 0
          invert ? :high : :low
        when (1..5)
          invert ? :mid_high : :low_mid
        when (6..10)
          :mid
        when (10..20)
          invert ? :low_mid : :mid_high
        when (20..999999)
          invert ? :low : :high
        end
      end

    end
  end
end
