# enumerable_lz

'enumerable_lz' provides filter and transformation methods in `Enumerable` module.
Also it provides lazy equivalents of some methods in `Enumerable`.
`Enumerable#filter` and `Enumerable#transform` methods 


## Fundamental Usage

When require 'enumerable_lz', these lazy methods are provided:

* `Enumerable#filter`
* `Enumerable#filter_with_initproc`
* `Enumerable#transform`

For example (in Ruby 1.9.x):

    require 'enumerable_lz'
    require 'prime'
    
    (1..Float::INFINITY).transform{|n|n**2+1}.filter{|m|m.prime?}.take(100)
    # => [2, 5, ... , 682277, 739601] for a few msec.


## Expanded Usage

When require 'enumerable_lz/enumerable_ex', some lazy methods equivalents to original `Enumerable` method with suffix '_lz' are provided:

* `Enumerable#select_lz`
* `Enumerable#find_all_lz`
* `Enumerable#reject_lz`
* `Enumerable#grep_lz`
* `Enumerable#map_lz`
* `Enumerable#collect_lz`
* `Enumerable#drop_lz`
* `Enumerable#drop_while_lz`
* `Enumerable#take_lz`
* `Enumerable#take_while_lz`


For example (in Ruby 1.9.x):

    require 'enumerable_lz'
    require 'enumerable_lz/enumerable_ex'
    require 'prime'
    
    (1..Float::INFINITY).map_lz{|n|n**2+1}.select_lz{|m|m.prime?}.take_lz(100).to_a
    # => [2, 5, ... , 682277, 739601] for a few msec.

These expanded methods are inplemented with fundamental filter and transformation methods.


== Supported Rubies

* Ruby 1.9.x (testing 1.9.2-p0, 1.9.2 p-136)
* Ruby 1.8.7 (testing 1.8.7-p330)
* JRuby 1.5.x (testing 1.5.6)
* MacRuby 0.8

== Installation

    gem install enumerable_lz

or

    gem install antimon2-enumerable_lz


== License

The MIT License  
Copyright (c) 2011 GOTOH Shunsuke (@antimon2)

Please see LICENSE.txt for details.