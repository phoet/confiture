require 'spec_helper'

module Confiture
  class Config
    include Confiture::Configuration
  end

  class Allowed
    include Confiture::Configuration
    confiture_allowed_keys(:key)
  end

  class Default
    include Confiture::Configuration
    confiture_defaults(:key => 'value')
  end

  describe Confiture do
    context "defaults" do
      it "should have default settings" do
        Default.configure.key.should eql('value')
      end

      it "should restore defaults" do
        Default.configure.key.should eql('value')
        Default.configure(:key => 'bla').key.should eql('bla')
        Default.reset!
        Default.configure.key.should eql('value')
      end
    end
    context "allowed_keys" do
      it "should have access to allowed fields" do
        Allowed.configure do |config|
          config.key = 'bla'
        end.key.should eql('bla')
      end

      it "should raise an error for not allowed keys" do
        expect do
          Allowed.configure do |config|
            config.not_allowed_key = 'bla'
          end
        end.should raise_error(ArgumentError, "not_allowed_key is not allowed, use one of [:key]")
      end

      it "should access any field if not restricted" do
        Config.configure do |config|
          config.not_allowed_key = 'bla'
        end.not_allowed_key.should eql('bla')
      end
    end

    context "configuration" do
      it "should work with a configuration block" do
        Config.configure do |config|
          config.key = 'bla'
        end.key.should eql('bla')
      end

      it "should read configuration from yml" do
        config = Config.configure :yaml => 'spec/config.yml'
        config.secret.should eql('secret_yml')
        config.key.should eql('key_yml')
      end

      it "should read configuration from yml with block" do
        conf = Config.configure :yaml => 'spec/config.yml' do |config, yml|
          config.secret = nil
          config.key = yml['secret']
        end
        conf.secret.should be_nil
        conf.key.should eql('secret_yml')
      end
    end

    context "with_config" do
      it "should have a config on a per block basis" do
        config = Config.configure(:key => "value")
        config.with_config(:key => "bla") do
          Config.key.should eql("bla")
        end
        Config.key.should eql("value")
      end
    end
  end
end
