# for MacRuby
module Enumerable
  def filter pattern = nil, &block
    Filter.new self, pattern||block
  end

  def filter_with_initproc init_proc, pattern = nil, &block
    Filter.new self, init_proc, pattern||block
  end

  class Filter < Enumerator
    def initialize obj, *args
      the_filter = args.shift
      init_block, the_filter = [the_filter, args.shift] unless args.empty?
      @org_enum = obj
      @init_block = init_block unless init_block.nil?
      outer = self
      super Class.new {
        define_method :each do
          return outer unless block_given?
          init_block.call unless init_block.nil?
          compiled_filter = outer.__send__(:compile_filter)
          catch :do_break do
            obj.each do |el|
              yield el if compiled_filter===el
            end
          end
          outer
        end
      }.new
      filter! the_filter if the_filter
    end

    def filter! pattern=nil, &block
      @filter||=[]
      if pattern.is_a? Array
        pattern.each{|el| @filter << conv_proc(el)}
      else
        @filter<<conv_proc(pattern || block)
      end
      self
    end

    #[override]
    def filter pattern=nil, &block
      # clone.filter! pattern, &block
      patterns = @filter.nil? ? [] : @filter.clone
      if pattern.is_a? Array
        patterns.push(*pattern)
      else
        patterns<<(pattern || block)
      end
      return Filter.new @org_enum, @init_block, patterns unless @init_block.nil?
      Filter.new @org_enum, patterns
    end

    private
    def conv_proc pattern
      case pattern
      when nil
        Proc.new{true}
      else  # Proc#=== is equal to Proc#call on Ruby1.9.x
        pattern.respond_to?(:to_proc) ? pattern.to_proc : pattern
      end
    end
    def compile_filter
      @filter.inject do |r,f|
        Proc.new{|el| r===el && f===el}
      end
    end
  end
end