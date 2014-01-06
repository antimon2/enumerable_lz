# enumerable_lz

'enumerable_lz' provides filter and transformation methods in `Enumerable` module.
Also it provides lazy equivalents of some methods in `Enumerable`.


## Fundamental Usage

When require 'enumerable_lz', these lazy methods are provided:

* `Enumerable#filter`
* `Enumerable#transform`

And some method-chains are provided:

* `Enumerable#filter.with_index`
* `Enumerable#filter.with_initializer`
* `Enumerable#transform.with_index`

For example (in Ruby 1.9.x or greater):

    require 'enumerable_lz'
    require 'prime'

    (1..Float::INFINITY).transform{|n|n**2+1}.filter{|m|m.prime?}.take(100)
    # => [2, 5, ... , 682277, 739601] for a few msec.

    Prime.filter.with_index{|q,i|i.odd?}.take(10)
    # => [3, 7, 13, 19, 29, 37, 43, 53, 61, 71]

    Prime.transform.with_index{|q,i|[q,i]}.take(10)
    # => [[2, 0], [3, 1], [5, 2], [7, 3], [11, 4], [13, 5], [17, 6], [19, 7], [23, 8], [29, 9]]

    # especially, when calling transform.with_index without a block
    Prime.transform.with_index.take(10)
    # => [[2, 0], [3, 1], [5, 2], [7, 3], [11, 4], [13, 5], [17, 6], [19, 7], [23, 8], [29, 9]]


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


For example (in Ruby 1.9.x or greater):

    require 'enumerable_lz'
    require 'enumerable_lz/enumerable_ex'
    require 'prime'
    
    (1..Float::INFINITY).map_lz{|n|n**2+1}.select_lz{|m|m.prime?}.take_lz(100).to_a
    # => [2, 5, ... , 682277, 739601] for a few msec.

These expanded methods are inplemented with fundamental filter and transformation methods.


## Supported Rubies

* Ruby 2.1.0 (testing 2.1.0-p0)
* Ruby 2.0.0 (testing 2.0.0-p247)
* Ruby 1.9.x (testing 1.9.3-p448)
* Ruby 1.8.7 (testing 1.8.7-p358)
* JRuby (testing 1.7.2)
* MacRuby (testing 0.12)

## Installation

    gem install enumerable_lz


## License

The MIT License  
Copyright (c) 2011, 2014 GOTOH Shunsuke (@antimon2)

Please see [LICENSE.txt](LICENSE.txt) for details.