require 'spec_helper'

module Confiture
  class Config
    include Confiture::Configuration
  end

  class Valid
    include Confiture::Configuration
    confiture_mandatory_keys(:key)
  end

  class Allowed
    include Confiture::Configuration
    confiture_allowed_keys(:key)
  end

  class Default
    include Confiture::Configuration
    confiture_defaults(key: 'value')
  end

  describe Confiture do
    context "reset" do
      it "should reset the configuration" do
        Config.configure(key: "value").tap do |config|
          config.key.should eql("value")
          config.reset!
          config.key.should be_nil
        end
      end
    end

    context "validate" do
      it "should validate the configuration" do
        expect { Valid.configure.validate! }.should raise_error(ArgumentError, "you are missing mandatory configuration options. please set [:key]")
      end

      it "should warn if a mandatory key is set and no configuration given" do
        Valid.send :data=, nil
        expect { Valid.validate! }.should raise_error(ArgumentError, "you are working on an empty configuration. run configuration code first!")
      end
    end

    context "defaults" do
      it "should have default settings" do
        Default.configure.key.should eql('value')
      end

      it "should restore defaults" do
        Default.configure.key.should eql('value')
        Default.configure(key: 'bla').key.should eql('bla')
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
        Config.configure(yaml: 'spec/config.yml').tap do |config|
          config.secret.should eql('secret_yml')
          config.key.should eql('key_yml')
        end
      end

      it "should read configuration from yml with block" do
        conf = Config.configure yaml: 'spec/config.yml' do |config, yml|
          config.secret = nil
          config.key = yml['secret']
        end
        conf.secret.should be_nil
        conf.key.should eql('secret_yml')
      end
    end

    context "with_config" do
      it "should have a config on a per block basis" do
        Config.configure(key: "value")
        Config.key.should eql("value")
        Config.with_config(key: "bla") do
          Config.key.should eql("bla")
        end
        Config.key.should eql("value")
      end
    end

    context "scoping" do
      it "should scope to the configuration class" do
        mapping = {
          Config  => "bla",
          Valid   => "nups",
          Allowed => "blupp",
          Default => "nups",
        }
        mapping.each do |clazz, value|
          clazz.reset!
          clazz.configure(key: value)
        end
        mapping.each do |clazz, value|
          clazz.key.should eql(value)
        end
      end

      it "should allow threads to override configuration" do
        Config.reset!
        Config.configure(key: "nups")
        t = Thread.new do
          Config.key.should eql("nups")
          Thread.stop
          Config.key.should eql("nups")
        end
        sleep 0.1 while t.status != 'sleep'
        Config.with_config(key: "dups") do
          Config.key.should eql("dups")
          t.run
          t.join
          Config.key.should eql("dups")
        end
        Config.key.should eql("nups")
      end
    end
  end
end
