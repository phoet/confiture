require "yaml"

module Confiture
  module Configuration
    def self.included(base)
      base.extend ClassExtension
    end

    module ClassExtension

      # Set a hash of defaults.
      # Defaults will be used while configuring the options, but may be overridden.
      #
      def confiture_defaults(defaults)
        @defaults = defaults
      end

      # Set a list of allowed configuration options.
      # If set, trying to access an option that is not configured will result in an ArgumentError.
      #
      def confiture_allowed_keys(*allowed_keys)
        @allowed_keys = allowed_keys
      end

      # Set a list of mandatory configuration options.
      # If set, trying to access an option that is not configured properly will result in an ArgumentError.
      # The validation can be triggered manually by calling +validate!+
      #
      def confiture_mandatory_keys(*mandatory_keys)
        @mandatory_keys = mandatory_keys
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
      def configure(options={},reset=false)
        init_config(reset)
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

      # Run a block of code with temporary configuration.
      #
      def with_config(options={})
        current_data = data
        configure(options, true)
      ensure
        self.data = current_data
      end

      # Resets configuration to defaults
      #
      def reset!
        init_config(true)
      end

      # Raises an ArgumentError if the configuration is not valid.
      #
      def validate!
        unless valid?
          raise ArgumentError.new("you are missing mandatory configuration options. please set #{@mandatory_keys}")
        end
      end

      # Validates the configuration. All mandatory keys have to be not blank.
      #
      def valid?
        @mandatory_keys.nil? || @mandatory_keys.none? { |key| blank?(key) }
      end

      # Raises an ArgumentError if the given key is not allowed as a configuration option.
      #
      def validate_key!(key)
        unless valid_key?(key)
          raise ArgumentError.new("#{key} is not allowed, use one of #{@allowed_keys}")
        end
      end

      # Validates if a given key is valid for configuration.
      #
      def valid_key?(key)
        @allowed_keys.nil? || @allowed_keys.include?(key)
      end

      # Checks if a given key is nil or empty.
      #
      def blank?(key)
        val = self.send key
        val.nil? || val.empty?
      end

      private

      def data
        Thread.current[:confiture]
      end

      def data=(data)
        Thread.current[:confiture] = data
      end

      def init_config(force=false)
        return if @init && !force
        @init = true
        self.data = Data.new(@defaults)
      end

      def method_missing(meth, *args)
        meth = "#{meth}"
        if meth =~ /.+=/ && args.size == 1
          key = meth[0..-2].to_sym
          validate_key!(key)
          data.options[key] = args.last
        elsif args.size == 0
          key = meth.to_sym
          validate_key!(key)
          data.options[key]
        else
          super
        end
      end
    end
  end
end
