# cottus

[![Build Status](https://travis-ci.org/mthssdrbrg/cottus.png?branch=master)](https://travis-ci.org/mthssdrbrg/cottus)
[![Coverage Status](https://coveralls.io/repos/mthssdrbrg/cottus/badge.png?branch=master)](https://coveralls.io/r/mthssdrbrg/cottus?branch=master)

Cottus, named after one of the Hecatonchires of Greek mythology, is a multi limb
HTTP client that currently wraps HTTParty, and manages requests against several
hosts.

This is useful for example when you have internal HTTP-based services running in
EC2 and don't want to use an ELB (as this forces the service to be public) nor
setup HAProxy or any other load-balancing solution.

By default, Cottus will apply a round robin strategy, but you could very well
define your own strategy.

## Installation

```
gem install cottus
```

## Usage

```ruby
require 'cottus'

client = Cottus::Client.new(['http://n1.com', 'http://n2.com', 'http://n3.com'])

# This request will be made against http://n1.com
response = client.get('/any/path', query: {id: 1337})
puts response.body, response.code, response.message, response.headers.inspect

# This request will be made against http://n2.com
response = client.post('/any/path', query: {id: 1337}, body: { attribute: 'cool'})
puts response.body, response.code, response.message, response.headers.inspect
```

That's about it! Cottus exposes almost all of the same methods with the same semantics as
HTTParty does, with the exception of ```HTTParty#copy```.

## Strategy

A "Strategy" is merely a class implementing an ```execute``` method that is
responsible for carrying out the action specified by the passed ```meth```
argument.

The Strategy class must however also implement an ```#initialize``` method which
takes three parameters: ```hosts```, ```client``` and an ```options``` hash:

```ruby
class SomeStrategy
  def initialize(hosts, client, options={})
  end

  def execute(meth, path, options={}, &block)
    # do something funky here
  end
end
```

If you don't mind inheritance there's a base class (```Cottus::Strategy```) that
you can inherit from and the above class would instead become:

```ruby
class SomeStrategy < Strategy
  def execute(meth, path, options={}, &block)
    # do something funky here
  end
end
```

If you'd like to do some initialization on your own and override
```#initialize``` make sure to call ```#super``` or set the required instance
variables (```@hosts```, ```@client```) on your own.

It should be noted that I haven't decided on how strategies should be working to
a 100% yet, so this might change in future releases.

See ```lib/cottus/strategies.rb``` for further examples.

## Copyright
Copyright 2013 Mathias Söderberg

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
