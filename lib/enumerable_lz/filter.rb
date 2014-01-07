# -- for Ruby1.9.x except for MacRuby

# add [Filter] and [Transform] classes.
class Enumerator
  # Lazy Filterring Enumerator
  class Filter < Enumerator
    # @param [Enumerable] obj an Enumerable.
    # @param [#===] the_filter filterring pattern or proc.
    def initialize obj, the_filter=nil
      @org_enum = obj
      super() do |y|
        compiled_filter = @filter.nil? ? Proc.new{true} : lambda{|f|
          break f[0] if f.size==1
          codes = f.size.times.map do |idx|
            "f[#{idx}]===el"
          end
          eval "Proc.new{|el|"+codes.join(" && ")+"}"
        }.call(@filter)
        catch :do_break do
          @org_enum.each do |el|
            y.yield el if compiled_filter===el
          end
        end
      end
      filter! the_filter if the_filter
    end

    # Apply filter pattern/block and return self. (bang method of filter)
    # @yield [el]
    # @return [Filter] self
    def filter! pattern=nil, &block
      @filter||=[]
      if pattern.is_a? Array
        pattern.each{|el| @filter << conv_proc(el)}
      else
        @filter << conv_proc(pattern || block)
      end
      self
    end

    # [override] for performance
    # @yield [el]
    # @overload filter(&block)
    #   @yield [el]
    # @overload filter(pattern)
    #   @param [#===] pattern
    # @see Enumerable#filter Enumerable#filter
    # @return [Filter]
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

    # @overload with_initializer(init_proc, &block)
    #   filter by block with initializer proc.
    #   @param [#call] init_proc initializer proc. (uses .call method)
    #   @yield filterring block.
    #   @return [Filter]
    # @overload with_initializer(init_proc, pattern)
    #   filter by pattern with initializer proc.
    #   @param [#call] init_proc initializer proc. (uses .call method)
    #   @param [#===] pattern filterring pattern. (uses === method)
    #   @return [Filter]
    # @return [Filter]
    def with_initializer init_proc, pattern = nil, &block
      src_enum = @filter.nil? ? @org_enum : self
      FilterWithInitializer.new src_enum, init_proc, pattern||block
    end

    # @param [Numeric] offset offset.
    # @yield [el, i] 
    # @return [Filter]
    def with_index offset=0, &block
      raise ArgumentError, "tried to call filter.with_index without a block" unless block_given?
      i = offset - 1
      with_initializer(Proc.new{i = offset - 1}) do |el|
        block.call(el, i += 1)
      end
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
  end

  # @api private
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

    # @see Enumerable#filter Enumerable#filter
    # @return [Filter]
    def filter pattern=nil, &block
      Filter.new self, pattern||block
    end
  end
  private_constant :FilterWithInitializer if self.respond_to? :private_constant
end
# against the Bug on JRuby < 1.6.2
if !(Proc.new{true}===true)
  # @private
  class Proc
    alias :=== :call
  end
end