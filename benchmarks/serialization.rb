# frozen_string_literal: true

require "benchmark"
require "benchmark/ips"
require "bson"
require "json"
require "msgpack"
require "oj"
require "rapidjson"
require "zlib"
require_relative "definitions/entities_pb"

# rubocop:disable Layout/SpaceInsideHashLiteralBraces, Layout/SpaceAroundOperators, Style/HashSyntax, Layout/LineLength
menu = [{:class=>"BombermanRuby::Inputs::Local"}, {:class=>"BombermanRuby::Inputs::Local"}, {:class=>"BombermanRuby::Steps::Menus::MapIcon", :index=>0}]
entities = [{:class=>"Blocks::Soft", :x=>160, :y=>16, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>112, :y=>32, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>144, :y=>32, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>176, :y=>32, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>32, :y=>48, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>48, :y=>48, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>80, :y=>48, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>96, :y=>48, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>128, :y=>48, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>160, :y=>48, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>192, :y=>48, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>16, :y=>64, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>48, :y=>64, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>80, :y=>64, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>144, :y=>64, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>176, :y=>64, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>208, :y=>64, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>16, :y=>80, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>32, :y=>80, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>48, :y=>80, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>64, :y=>80, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>80, :y=>80, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>96, :y=>80, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>112, :y=>80, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>144, :y=>80, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>176, :y=>80, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>208, :y=>80, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>16, :y=>96, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>48, :y=>96, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>80, :y=>96, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>112, :y=>96, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>144, :y=>96, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>176, :y=>96, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>16, :y=>112, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>32, :y=>112, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>48, :y=>112, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>64, :y=>112, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>112, :y=>112, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>160, :y=>112, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>176, :y=>112, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>192, :y=>112, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>208, :y=>112, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>48, :y=>128, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>80, :y=>128, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>144, :y=>128, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>176, :y=>128, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>48, :y=>144, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>64, :y=>144, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>80, :y=>144, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>96, :y=>144, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>144, :y=>144, :burning_index=>nil}, {:class=>"Blocks::Soft", :x=>160, :y=>144, :burning_index=>nil}, {:class=>"Items::SpeedUp", :x=>96, :y=>16, :burning_index=>nil}, {:class=>"Fire", :x=>16, :y=>16, :burning_index=>4, :type=>:center, :sound=>nil}, {:class=>"Fire", :x=>32, :y=>16, :burning_index=>4, :type=>:middle_right, :sound=>nil}, {:class=>"Fire", :x=>48, :y=>16, :burning_index=>4, :type=>:right, :sound=>nil}, {:class=>"Fire", :x=>16, :y=>32, :burning_index=>4, :type=>:middle_bottom, :sound=>nil}, {:class=>"Fire", :x=>16, :y=>48, :burning_index=>4, :type=>:bottom, :sound=>nil}, {:class=>"Player", :x=>46, :y=>24, :id=>0, :direction=>:down, :moving=>false, :skull_effect=>nil, :sound=>nil, :winning=>false, :dead_at=>nil, :current_death_sprite=>0, :stunned_at=>nil}, {:class=>"Player", :x=>208, :y=>136, :id=>1, :direction=>:down, :moving=>false, :skull_effect=>nil, :sound=>nil, :winning=>false, :dead_at=>nil, :current_death_sprite=>0, :stunned_at=>nil}]
# rubocop:enable Layout/SpaceInsideHashLiteralBraces, Layout/SpaceAroundOperators, Style/HashSyntax, Layout/LineLength

ITERATIONS = 6_000

# Serialization methods

def msgpack_serialize(data)
  data.to_msgpack
end

def protobuf_serialize(data)
  protobuf_entities = data.map do |i|
    Proto::Entity.new(i)
  end

  list = Proto::EntityList.new(entities: protobuf_entities)
  Proto::EntityList.encode(list)
end

def json_oj_serialize(data)
  Oj.dump(data)
end

def rapidjson_serialize(data)
  RapidJSON.encode(data)
end

def json_serialize(data)
  data.to_json
end

def bson_serialize(data)
  byte_buffer = data.to_bson
  byte_buffer.get_bytes(byte_buffer.length)
end

# Deserialization methods

def msgpack_deserialize(data)
  MessagePack.unpack(data)
end

def protobuf_deserialize(data)
  Proto::EntityList.decode(data).entities.map(&:to_h)
end

def json_oj_deserialize(data)
  Oj.load(data)
end

def rapidjson_deserialize(data)
  RapidJSON.parse(data)
end

def json_deserialize(data)
  JSON.parse(data)
end

def bson_deserialize(data)
  Array.from_bson(BSON::ByteBuffer.new(data))
end

# Compression methods

def zlib_compress(data)
  Zlib::Deflate.deflate(data)
end

# Decompression methods

def zlib_decompress(data)
  Zlib::Inflate.inflate(data)
end

def stringify_hash(hash)
  hash.transform_keys(&:to_s).transform_values { _1.is_a?(Symbol) ? _1.to_s : _1 }
end

hashes = {
  entities: entities.map { stringify_hash(_1) },
  menu: menu.map { stringify_hash(_1) },
}.freeze

serialization_methods = {
  msgpack_zlib: ->(arr) { zlib_compress(msgpack_serialize(arr)) },
  protobuf_zlib: ->(arr) { zlib_compress(protobuf_serialize(arr)) },
  json_oj_zlib: ->(arr) { zlib_compress(json_oj_serialize(arr)) },
  rapidjson_zlib: ->(arr) { zlib_compress(rapidjson_serialize(arr)) },
  json_zlib: ->(arr) { zlib_compress(json_serialize(arr)) },
  bson_zlib: ->(arr) { zlib_compress(bson_serialize(arr)) },

  msgpack: ->(arr) { msgpack_serialize(arr) },
  protobuf: ->(arr) { protobuf_serialize(arr) },
  json_oj: ->(arr) { json_oj_serialize(arr) },
  rapidjson: ->(arr) { rapidjson_serialize(arr) },
  json: ->(arr) { json_serialize(arr) },
  bson: ->(arr) { bson_serialize(arr) },
}

deserialization_methods = {
  msgpack_zlib: ->(data) { msgpack_deserialize(zlib_decompress(data)) },
  protobuf_zlib: ->(data) { protobuf_deserialize(zlib_decompress(data)) },
  json_oj_zlib: ->(data) { json_oj_deserialize(zlib_decompress(data)) },
  rapidjson_zlib: ->(data) { rapidjson_deserialize(zlib_decompress(data)) },
  json_zlib: ->(data) { json_deserialize(zlib_decompress(data)) },
  bson_zlib: ->(data) { bson_deserialize(zlib_decompress(data)) },

  msgpack: ->(data) { msgpack_deserialize(data) },
  protobuf: ->(data) { protobuf_deserialize(data) },
  json_oj: ->(data) { json_oj_deserialize(data) },
  rapidjson: ->(data) { rapidjson_deserialize(data) },
  json: ->(data) { json_deserialize(data) },
  bson: ->(data) { bson_deserialize(data) },
}

serialized_strings = Hash.new { |hash, key| hash[key] = {} }
hashes.each_key do |type|
  serialization_methods.each do |serialization_method, l|
    serialized_strings[type][serialization_method] = l.call(hashes[type])
  end
end

puts "Serialization"
puts "#{ITERATIONS} iterations"
puts "================================================================="
puts ""
hashes.each do |type, arr|
  puts "Type: #{type}"
  Benchmark.bmbm do |x|
    serialization_methods.each do |serialization_method, l|
      x.report("#{serialization_method} (#{l.call(arr).bytesize})") { ITERATIONS.times { l.call(arr) } }
    end
  end
  puts ""

  puts "------------------ IPS ------------------"
  Benchmark.ips do |x|
    serialization_methods.each do |serialization_method, l|
      x.report("#{serialization_method} (#{l.call(arr).bytesize})") { l.call(arr) }
      x.compare!
    end
  end
  puts "================== END =================="
  puts ""
end

puts "================================================================================================================="
puts ""

puts "Deserialization"
puts "#{ITERATIONS} iterations"
puts "================================================================="
puts ""
serialized_strings.each do |type, data|
  puts "Type: #{type}"
  Benchmark.bmbm do |x|
    deserialization_methods.each do |deserialization_method, l|
      x.report("#{deserialization_method} (#{l.call(data[deserialization_method]) == hashes[type]})") do
        ITERATIONS.times do
          l.call(data[deserialization_method])
        end
      end
    end
  end
  puts ""

  puts "------------------ IPS ------------------"
  Benchmark.ips do |x|
    deserialization_methods.each do |deserialization_method, l|
      x.report("#{deserialization_method} (#{l.call(data[deserialization_method]) == hashes[type]})") do
        l.call(data[deserialization_method])
      end
      x.compare!
    end
  end
  puts "================== END =================="
  puts ""
end
