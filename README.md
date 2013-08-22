# Cottus

[![Build Status](https://travis-ci.org/mthssdrbrg/cottus.png?branch=master)](https://travis-ci.org/mthssdrbrg/cottus)
[![Coverage Status](https://coveralls.io/repos/mthssdrbrg/cottus/badge.png?branch=master)](https://coveralls.io/r/mthssdrbrg/cottus?branch=master)

Cottus, named after one of the Hecatonchires of Greek mythology, is a multi limb
HTTP client that currently wraps HTTParty, and manages requests against several
hosts.

This is useful for example when you have internal HTTP-based services running in
EC2 and don't want to use an ELB (as this forces the service to be public) nor
setup HAProxy or any other load-balancing solution.

By default, Cottus will apply a round robin strategy, but you could define your
own strategy (more on that later).
