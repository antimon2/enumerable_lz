# for Ruby1.8.7
module Enumerable
  def transform &block
    Enumerator::Transform.new self, &block
  end

  class Enumerator
    class Transform < Enumerator
      def initialize obj, &transformer
        @org_enum = obj
        transform! &transformer if block_given?
      end

      def each &block
        return self unless block_given?
        the_transformer = compile_transformer
        @org_enum.each do |el|
          block.call the_transformer[el]
        end
        self
      end

      def transform! &block
        @transformer||=[]
        @transformer << block if block_given?
        self
      end

      #[override]
      def transform &block
        # clone.transform! &block
        cp = Transform.new @org_enum
        @transformer.each do |org_block|
          cp.transform! &org_block
        end unless @transformer.nil?
        cp.transform! &block
      end

      #[override]
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

    # private
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

      #[override]
      def transform &block
        Transform.new self, &block
      end
      alias :transform! :transform
    end
  end
end