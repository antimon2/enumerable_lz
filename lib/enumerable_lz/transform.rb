# for Ruby1.9.x except for MacRuby
module Enumerable
  def transform &block
    Transform.new self, &block
  end

  class Transform < Enumerator
    def initialize obj, &transformer
      @org_enum = obj
      super() do |y|
        obj.each do |*el|
          y << apply_transform(*el)
        end
      end
      transform! &transformer if block_given?
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

#    def clone
#      cp = super
#      cp.instance_eval { @transformer = @transformer.nil? ? [] : @transformer.clone }
#      cp
#    end

    private
    def apply_transform *args
      result = args
      @transformer.each do |transformer|
        result = transformer[*result] unless transformer.nil?
      end unless @transformer.nil?
      result
    end
  end
end