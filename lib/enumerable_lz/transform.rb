# -- for Ruby1.9.x except for MacRuby

# add [Filter] and [Transform] classes.
class Enumerator
  # Lazy Transform Enumerator
  class Transform < Enumerator
    # @param [Enumerable] obj an Enumerable.
    # @yield transform block.
    def initialize obj, &transformer
      @org_enum = obj
      super() do |y|
        the_transformer = compile_transformer
        obj.each do |el|
          y << the_transformer[el]
        end
      end
      transform! &transformer if block_given?
    end

    # Apply another transformer block and return self. (bang method of transform)
    # @yield [el] transform block.
    # @return [Transform] self
    def transform! &block
      @transformer||=[]
      @transformer << block if block_given?
      self
    end

    # [override] for performance
    # @yield [el] transform block.
    # @see Enumerable#transform Enumerable#transform
    # @return [Transform]
    def transform &block
      # clone.transform! &block
      cp = Transform.new @org_enum
      @transformer.each do |org_block|
        cp.transform! &org_block
      end unless @transformer.nil?
      cp.transform! &block
    end

    # @yield [el, i] 
    # @overload with_index(offset=0, &block)
    #   @param [Numeric] offset offset.
    #   @yield [el, i] 
    #   @return [Transform]
    # @overload with_index(offset=0)
    #   @note same as with_index(offset) {|el, i| [el, i]}
    #   @param [Numeric] offset offset.
    #   @return [Transform]
    # @return [Transform]
    def with_index offset=0, &block
      src_enum = @transformer.nil? || @transformer.size.zero? ? @org_enum : self
      block ||= Proc.new{|el, i|[el, i]}
      TransformWithIndex.new src_enum, offset, &block
    end

    private
    def compile_transformer
      return Proc.new{|a|a} if @transformer.nil? || @transformer.size==0
      return @transformer[0] if @transformer.size==1
      lambda{|t|
        codes = t.size.times.inject "el" do |r,idx|
          "t[#{idx}][#{r}]"
        end
        eval "Proc.new{|el|"+codes+"}"
      }.call(@transformer)
    end
  end

  # @api private
  class TransformWithIndex < Transform
    def initialize obj, offset = 0, &transformer
      @org_enum = obj
      @transformer = transformer.nil? ? nil : [transformer]
      @offset = offset
    end

    def each
      return self unless block_given?
      the_transformer = @transformer[0] || Proc.new{|el,i|el}
      i = @offset - 1
      @org_enum.each do |el|
        yield the_transformer.call(el, i+=1)
      end
    end

    # @see Enumerable#filter Enumerable#filter
    # @return [Transform]
    def transform &block
      Transform.new self, &block
    end
    alias :transform! :transform
  end
  private_constant :TransformWithIndex if self.respond_to? :private_constant
end