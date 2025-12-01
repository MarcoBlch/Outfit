
require "pgvector"

ActiveSupport.on_load(:active_record) do
  class VectorType < ActiveRecord::Type::Value
    def type
      :vector
    end

    def cast(value)
      return value if value.is_a?(Array)
      return value unless value.is_a?(String)
      
      # Simple parsing for "[1,2,3]"
      if value.start_with?('[') && value.end_with?(']')
        value[1..-2].split(',').map(&:to_f)
      else
        value
      end
    end

    def serialize(value)
      if value.is_a?(Array)
        "[#{value.join(',')}]"
      else
        value
      end
    end
    
    def deserialize(value)
      cast(value)
    end
  end

  ActiveRecord::Type.register(:vector, VectorType)
  
  # Also register for the adapter to handle quoting correctly if needed
  # But ActiveRecord::Type.register should be enough for model attributes.
end
