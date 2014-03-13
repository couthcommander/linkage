module Linkage
  # This class is for holding information about a particular field in a
  # dataset.
  class Field
    # @!attribute [r] name
    #   @return [Symbol] This object's name
    attr_reader :name

    # @return [Symbol] This field's schema information
    attr_reader :schema

    # Create a new instance of Field.
    #
    # @param [Symbol] name The field's name
    # @param [Hash] schema The field's schema information
    def initialize(name, schema)
      @name = name
      @schema = schema
    end

    # Convert the column schema information to a hash of column options, one of
    # which must be :type. The other options added should modify that type
    # (e.g. :size). If a database type is not recognized, return it as a String
    # type.
    #
    # @note This method comes more or less straight from Sequel
    #   (lib/sequel/extensions/schema_dumper.rb).
    def ruby_type
      unless @ruby_type
        hsh =
          case @schema[:db_type].downcase
          when /\A(medium|small)?int(?:eger)?(?:\((\d+)\))?( unsigned)?\z/o
            if !$1 && $2 && $2.to_i >= 10 && $3
              # Unsigned integer type with 10 digits can potentially contain values which
              # don't fit signed integer type, so use bigint type in target database.
              {:type=>Bignum}
            else
              {:type=>Integer}
            end
          when /\Atinyint(?:\((\d+)\))?(?: unsigned)?\z/o
            {:type =>schema[:type] == :boolean ? TrueClass : Integer}
          when /\Abigint(?:\((?:\d+)\))?(?: unsigned)?\z/o
            {:type=>Bignum}
          when /\A(?:real|float|double(?: precision)?|double\(\d+,\d+\)(?: unsigned)?)\z/o
            {:type=>Float}
          when 'boolean'
            {:type=>TrueClass}
          when /\A(?:(?:tiny|medium|long|n)?text|clob)\z/o
            {:type=>String, :text=>true}
          when 'date'
            {:type=>Date}
          when /\A(?:small)?datetime\z/o
            {:type=>DateTime}
          when /\Atimestamp(?:\((\d+)\))?(?: with(?:out)? time zone)?\z/o
            {:type=>DateTime, :size=>($1.to_i if $1)}
          when /\Atime(?: with(?:out)? time zone)?\z/o
            {:type=>Time, :only_time=>true}
          when /\An?char(?:acter)?(?:\((\d+)\))?\z/o
            {:type=>String, :size=>($1.to_i if $1), :fixed=>true}
          when /\A(?:n?varchar|character varying|bpchar|string)(?:\((\d+)\))?\z/o
            {:type=>String, :size=>($1.to_i if $1)}
          when /\A(?:small)?money\z/o
            {:type=>BigDecimal, :size=>[19,2]}
          when /\A(?:decimal|numeric|number)(?:\((\d+)(?:,\s*(\d+))?\))?\z/o
            s = [($1.to_i if $1), ($2.to_i if $2)].compact
            {:type=>BigDecimal, :size=>(s.empty? ? nil : s)}
          when /\A(?:bytea|(?:tiny|medium|long)?blob|(?:var)?binary)(?:\((\d+)\))?\z/o
            {:type=>File, :size=>($1.to_i if $1)}
          when /\A(?:year|(?:int )?identity)\z/o
            {:type=>Integer}
          else
            {:type=>String}
          end

        hsh.delete_if { |k, v| v.nil? }
        @ruby_type = {:type => hsh.delete(:type)}
        @ruby_type[:opts] = hsh if !hsh.empty?
      end
      @ruby_type
    end

    def primary_key?
      schema && schema[:primary_key]
    end
  end
end
