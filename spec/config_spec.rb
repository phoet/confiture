require 'spec_helper'

module Confiture
  describe Confiture do
    context "configuration" do
      it "should fail with wrong configuration key" do
        lambda { @helper.configure :wrong => 'key' }.should raise_error(NoMethodError)
      end

      it "should work with a configuration block" do
        conf = Confiture::Configuration.configure do |config|
          config.key = 'bla'
        end
        conf.key.should eql('bla')
      end

      it "should read configuration from yml" do
        config = Confiture::Configuration.configure :yaml => 'spec/config.yml'
        config.secret.should eql('secret_yml')
        config.key.should eql('key_yml')
      end

      it "should read configuration from yml with block" do
        conf = Confiture::Configuration.configure :yaml => 'spec/config.yml' do |config, yml|
          config.secret = nil
          config.key = yml['secret']
        end
        conf.secret.should be_nil
        conf.key.should eql('secret_yml')
      end
    end
  end
end
