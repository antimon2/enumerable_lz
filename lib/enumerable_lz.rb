if RUBY_VERSION > "1.8.7"
  if RUBY_DESCRIPTION !~ /^macruby/i
    require File.dirname(__FILE__)+'/enumerable_lz/filter'
    require File.dirname(__FILE__)+'/enumerable_lz/transform'
  else
    require File.dirname(__FILE__)+'/enumerable_lz/filter_mrb'
    require File.dirname(__FILE__)+'/enumerable_lz/transform_mrb'
  end
else
  require File.dirname(__FILE__)+'/enumerable_lz/filter_18'
  require File.dirname(__FILE__)+'/enumerable_lz/transform_18'
end

module Enumerable
  module EnumerableLz
    VERSION = "0.1.4"
  end
end
