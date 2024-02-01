# frozen_string_literal: true

module BombermanRuby
  module Entities
    module Concerns
      module Serializable
        SERIALIZABLE_VARS = %i[x y].freeze
        SERIALIZABLE_VARS_SYMBOLS = [].freeze

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def deserialize(map, data)
            entity = new(grid_x: 0, grid_y: 0, map:)
            entity.class::SERIALIZABLE_VARS.each do |var_name|
              entity.instance_variable_set(:"@#{var_name}", data[var_name.to_s])
            end
            entity.class::SERIALIZABLE_VARS_SYMBOLS.each do |var_name|
              entity.instance_variable_set(:"@#{var_name}", data[var_name.to_s]&.to_sym)
            end
            entity
          end
        end

        def serialize
          h = { class: self.class.to_s[Steps::Maps::Client::BASE_SERIALIZABLE_CLASSES.size..] }
          (self.class::SERIALIZABLE_VARS + self.class::SERIALIZABLE_VARS_SYMBOLS).each do |var_name|
            h[var_name] = instance_variable_get(:"@#{var_name}")
          end
          h
        end

        def skip_serialization?
          false
        end
      end
    end
  end
end
