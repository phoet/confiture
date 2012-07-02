require "yaml"
require "logger"

module Confiture
  module Configuration
    class << self

      attr_accessor :init, :options, :allowed_keys

      # set which ones to configure
      def confiture(*args)
        @allowed_keys = args
      end

      # Rails initializer configuration:
      #
      #   Confiture::Configuration.configure do |config|
      #     config.secret = 'your-secret'
      #     config.key    = 'your-key'
      #   end
      #
      # You may pass options as a hash as well:
      #
      #   Confiture::Configuration.configure :secret => 'your-secret', :key => 'your-key'
      #
      # Or configure everything using YAML:
      #
      #   Confiture::Configuration.configure :yaml => 'config/asin.yml'
      #
      #   Confiture::Configuration.configure :yaml => 'config/asin.yml' do |config, yml|
      #     config.key = yml[Rails.env]['key']
      #   end
      #
      # ==== Options:
      #
      # [yaml|yml] path to a yaml file with configuration
      #
      def configure(options={})
        init_config
        if yml_path = options[:yaml] || options[:yml]
          yml = File.open(yml_path) { |file| YAML.load(file) }
          if block_given?
            yield self, yml
          else
            yml.each do |key, value|
              send(:"#{key}=", value)
            end
          end
        elsif block_given?
          yield self
        else
          options.each do |key, value|
            send(:"#{key}=", value)
          end
        end
        self
      end

      # Resets configuration to defaults
      #
      def reset
        init_config(true)
      end

      private

      def init_config(force=false)
        return if @init && !force
        @init     = true
        @options  = {}
      end

      def method_missing(meth, *args)
        meth = "#{meth}"
        if meth =~ /.+=/ && args.size == 1
          @options[meth[0..-2]] = args.last
        elsif args.size == 0
          @options[meth]
        else
          super
        end
      end
    end
  end
end
