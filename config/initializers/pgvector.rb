require "pgvector"

# Register pgvector types with PostgreSQL adapter
ActiveSupport.on_load(:active_record) do
  # Register PostgreSQL types for pgvector
  require "pgvector/pg"

  # Custom ActiveRecord type for vector columns
  class Pgvector::Type < ActiveRecord::Type::Value
    def type
      :vector
    end

    def cast(value)
      case value
      when Array
        value
      when String
        # Parse PostgreSQL vector format: "[1,2,3]"
        if value.start_with?('[') && value.end_with?(']')
          value[1..-2].split(',').map(&:to_f)
        else
          value
        end
      when nil
        nil
      else
        value
      end
    end

    def serialize(value)
      case value
      when Array
        Pgvector.encode(value)
      when nil
        nil
      else
        super
      end
    end

    def deserialize(value)
      return nil if value.nil?

      case value
      when String
        Pgvector.decode(value)
      else
        value
      end
    end
  end

  # Register the type with ActiveRecord
  ActiveRecord::Type.register(:vector, Pgvector::Type)

  # Register with the PostgreSQL adapter connection
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(Module.new do
    def initialize_type_map(m = type_map)
      super

      # Register vector type OIDs dynamically
      execute("SELECT oid FROM pg_type WHERE typname = 'vector'", "SCHEMA").each do |row|
        oid = row['oid'].to_i
        m.register_type(oid, Pgvector::Type.new)
      end
    rescue ActiveRecord::StatementInvalid
      # Extension might not be loaded yet
    end
  end)

  # Add has_neighbors class method to ActiveRecord::Base
  module Pgvector::HasNeighbors
    def has_neighbors(attribute_name, dimensions: nil)
      # Define instance method for finding neighbors
      define_method("nearest_neighbors") do |embedding, distance: :cosine, limit: 5|
        distance_operator = case distance
                           when :cosine
                             "<=>"
                           when :l2
                             "<->"
                           when :inner_product
                             "<#>"
                           else
                             raise ArgumentError, "Unknown distance: #{distance}"
                           end

        encoded_embedding = Pgvector.encode(embedding)

        # Use direct SQL with connection quote to bypass dangerous query detection
        distance_sql = self.class.connection.quote(encoded_embedding)

        self.class
            .where.not(id: id)
            .order(Arel.sql("#{attribute_name} #{distance_operator} #{distance_sql}::vector"))
            .limit(limit)
      end

      # Define class method for searching by embedding
      define_singleton_method("nearest_neighbors") do |embedding, distance: :cosine, limit: 5|
        distance_operator = case distance
                           when :cosine
                             "<=>"
                           when :l2
                             "<->"
                           when :inner_product
                             "<#>"
                           else
                             raise ArgumentError, "Unknown distance: #{distance}"
                           end

        encoded_embedding = Pgvector.encode(embedding)

        # Use direct SQL with connection quote to bypass dangerous query detection
        distance_sql = connection.quote(encoded_embedding)

        order(Arel.sql("#{attribute_name} #{distance_operator} #{distance_sql}::vector"))
          .limit(limit)
      end
    end
  end

  ActiveRecord::Base.extend(Pgvector::HasNeighbors)
end
