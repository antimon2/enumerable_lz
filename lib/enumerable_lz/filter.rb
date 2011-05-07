# for Ruby1.9.x except for MacRuby
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
      super() do |y|
        @init_block.call unless @init_block.nil?
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

    def filter! pattern=nil, &block
      @filter||=[]
      if pattern.is_a? Array
        pattern.each{|el| @filter << conv_proc(el)}
      else
        @filter << conv_proc(pattern || block)
      end
      self
    end

    #[override]
    def filter pattern=nil, &block
      return super unless @init_block.nil?
      # clone.filter! pattern, &block
      patterns = @filter.nil? ? [] : @filter.clone
      if pattern.is_a? Array
        patterns.push(*pattern)
      else
        patterns<<(pattern || block)
      end
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
  end
end
#against the Bug on JRuby <1.6.2
if !(Proc.new{true}===true)
  class Proc
    alias :=== :call
  end
end