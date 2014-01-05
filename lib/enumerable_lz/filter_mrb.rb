# for MacRuby

module Enumerable
  def filter pattern = nil, &block
    Enumerator::Filter.new self, pattern||block
  end

  # @deprecated Use filter.with_initializer instead of this method
  def filter_with_initproc init_proc, pattern = nil, &block
    filter.with_initializer init_proc, pattern = nil, &block
  end
end

class Enumerator
  class Filter < Enumerator
    TrueProc = Proc.new{true}

    def initialize obj, the_filter = nil
      @org_enum = obj
      outer = self
      super Class.new {
        define_method :each do
          return outer unless block_given?
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
      Filter.new @org_enum, patterns
    end

    def with_initializer init_proc, pattern = nil, &block
      src_enum = @filter.nil? ? @org_enum : self
      FilterWithInitializer.new src_enum, init_proc, pattern||block
    end

    #[override]
    def with_index offset=0, &block
      raise ArgumentError, "tried to call filter.with_index without a block" unless block_given?
      i = offset - 1
      patterns = @filter.nil? ? [] : @filter.clone
      patterns << Proc.new{|el| block.call(el, i += 1)}
      FilterWithInitializer.new @org_enum, Proc.new{i = offset - 1}, patterns
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
      return Proc.new{true} if @filter.nil?
      return @filter[0] if @filter.size==1
      lambda{|f|
        codes = f.size.times.map do |idx|
          "f[#{idx}]===el"
        end
        eval "Proc.new{|el|"+codes.join(" && ")+"}"
      }.call(@filter)
    end
  end

  # private
  class FilterWithInitializer < Filter
    def initialize obj, init_block, the_filter = nil
      super obj, the_filter
      @initializer = init_block
    end

    def each &block
      return self unless block_given?
      @initializer.call
      super &block
    end

    #[override]
    def filter pattern=nil, &block
      Filter.new self, pattern||block
    end
  end
end