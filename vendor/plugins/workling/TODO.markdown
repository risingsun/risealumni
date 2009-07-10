# Todos for 0.5.0

* refactor starling* to be memcache*. add aliased classes into deprecated.rb.
* gemify
* move all runner/invoker implementations out of workling
* move backend discovery code out of workling
* decide on a single backend to include in workling

# Todos for 1.0

* add phusion daemon starter option so that workling_client doesn't need to be started manually. 
* merb support
* test on jruby
* more runners: sqs, beanstalkd
* add a linting runner for tests. should check that no ar objects are being passed around
* there are FIXMEs in the code. 