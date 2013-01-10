module Linkage
  class ImportBuffer
    # @param [Sequel::Dataset] dataset
    # @param [Array<Symbol>] headers List of fields you want to insert
    # @param [Fixnum] limit Number of records to insert at a time
    def initialize(dataset, headers, limit = 1000)
      @dataset = dataset
      @headers = headers
      @limit = limit
      @values = []
    end

    def add(values)
      @values << values
      if @values.length == @limit
        flush
      end
    end

    def flush
      return if @values.empty?
      @dataset.db.synchronize do
        @dataset.import(@headers, @values)
        @values.clear
      end
    end
  end
end
