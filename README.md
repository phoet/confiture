## Infos

![Status](http://stillmaintained.com/phoet/confiture.png "Status")
![Build](https://travis-ci.org/phoet/confiture.png "Build")

## Installation

    gem install confiture

or in your Gemfile:

    gem "confiture"

## Usage

In order to use confiture, just include it into a configuration klass:

    module Your
      class Configuration
        include Confiture::Configuration
        
        confiture_allowed_keys(:secret, :key)
        confiture_defaults(secret: 'SECRET_STUFF', key: 'EVEN_MOAR_SECRET')
      end
    end

Rails style initializer (config/initializers/asin.rb):

    Your::Configuration.configure do |config|
      config.secret = 'your-secret'
      config.key    = 'your-key'
    end

YAML style configuration:

    Your::Configuration.configure :yaml => 'config/some.yml'

Inline style configuration:

    Your::Configuration.configure :secret => 'your-secret', :key => 'your-key'
    # or
    client.configure :secret => 'your-secret', :key => 'your-key'

## License

"THE BEER-WARE LICENSE" (Revision 42):
ps@nofail.de[mailto:ps@nofail.de] wrote this file. As long as you retain this notice you
can do whatever you want with this stuff. If we meet some day, and you think
this stuff is worth it, you can buy me a beer in return Peter Schröder
