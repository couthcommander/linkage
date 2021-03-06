module Linkage
  module Helpers
    module Database
      # Returns a `Sequel::Database`.
      #
      # @overload database_connection(connection_options = {}, default_options = {})
      #   @param connection_options [Hash] Options to establish a connection. Any
      #     options not explicitly listed below are passed directly to `Sequel.connect`.
      #   @option connection_options [String] :dir Parent directory to use for SQLite database
      #   @option connection_options [String] :filename SQLite database filename
      # @overload database_connection(url)
      #   @param url [String] Sequel-style connection url
      # @overload database_connection(database)
      #   @param database [Sequel::Database]
      def database_connection(connection_options = {}, default_options = {})
        sequel_options = nil
        connection_options ||= default_options

        case connection_options
        when Hash
          connection_options = default_options.merge(connection_options)
          sequel_options = connection_options.reject do |key, value|
            key == :dir || key == :filename
          end

          if sequel_options.empty?
            filename = connection_options[:filename] || 'linkage.db'
            if connection_options[:dir]
              dir = File.expand_path(connection_options[:dir])
              FileUtils.mkdir_p(dir)
              filename = File.join(dir, filename)
            end
            sequel_options[:adapter] = :sqlite
            sequel_options[:database] = filename
          end
        when String
          sequel_options = connection_options
        when Sequel::Database
          return connection_options
        else
          raise ArgumentError, "Expected Hash or String, got #{connection_options.class}"
        end
        Sequel.connect(sequel_options)
      end
    end
  end
end
