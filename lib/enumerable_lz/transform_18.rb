# for Ruby1.8.7
module Enumerable
  def transform &block
    Transform.new self, &block
  end

  class Transform < Enumerator
    def initialize obj, &transformer
      @org_enum = obj
      transform! &transformer if block_given?
    end

    def each &block
      return self unless block_given?
      @org_enum.each do |*el|
        block.call apply_transform(*el)
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