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

## Usage

```ruby
require 'cottus'

client = Cottus::Client.new(['http://n1.com', 'http://n2.com', 'http://n3.com'])

response = client.get('/any/path', query: {id: 1337})
puts response.body, response.code, response.message, response.headers.inspect

response = client.post('/any/path', query: {id: 1337}, body: { attribute: 'cool'})
puts response.body, response.code, response.message, response.headers.inspect
```

That's about it! Cottus exposes almost all of the same methods with the same semantics as
HTTParty does, with the exception of ```HTTParty#copy```.
