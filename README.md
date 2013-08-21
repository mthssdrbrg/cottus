# cottus

[![Build Status](https://travis-ci.org/mthssdrbrg/cottus.png?branch=master)](https://travis-ci.org/mthssdrbrg/cottus)
[![Coverage Status](https://coveralls.io/repos/mthssdrbrg/cottus/badge.png?branch=master)](https://coveralls.io/r/mthssdrbrg/cottus?branch=master)

Cottus is a HTTP wrapper library (currently around HTTParty) that manages
requests against several hosts, which is useful when one has a number of hosts
running the same type of service and cannot (or does not want to) use an
external load balancer, for example when you have internal REST services in EC2
and don't want to be bothered setting up HAProxy or the alike.
