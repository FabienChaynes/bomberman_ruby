# frozen_string_literal: true

module BombermanRuby
  module Steps
    module Menus
      class Client < Base
        include Steps::Concerns::Clients::Networkable

        DESERIALIZABLE_CLASSES = [
          "BombermanRuby::Inputs::Local",
          "BombermanRuby::Inputs::Network",
          "BombermanRuby::Steps::Menus::MapIcon",
        ].freeze

        def update
          update_menu_state
        end

        private

        def update_menu_state
          return unless (entities = read_socket)

          @inputs = []
          @entities = []
          entities.each do |e|
            add_entity(e)
          end
        end

        def add_entity(entity_hash)
          entity = Object.const_get(entity_hash["class"]).deserialize(entity_hash)
          case entity
          when Inputs::Base
            @inputs << entity
          when MapIcon
            @map_icon = entity
          end
        end
      end
    end
  end
end
