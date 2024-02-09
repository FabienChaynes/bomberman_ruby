# Application protocol

All the requests exchanged between the client(s) and the server are sent using UDP.

## Client requests

### Input connection

The client must be the first sending UDP packet(s) to the server. **One** packet must be sent per input the client wishes to register. In order to do so, it needs to send a single null byte (`\x00`):

| Label  | Size | Value | Description |
| ------ | ---- | ----- | ----------- |
| Instruction  | 1 byte  | `\x00` (0 as a 8-bit unsigned char) | The value for the "input connection" instruction |

The server will then reply with a packet including the `input_id` which will have to be provided in the subsequent client requests.

### Input state

The client can also send one of their inputs state (e.g. `\x01\x01\x88`):

| Label  | Size | Value | Description |
| ------ | ---- | ----- | ----------- |
| Instruction  | 1 byte  | `\x01` (1 as a 8-bit unsigned char) | The value for the "input data" instruction |
| `input_id`  | 1 byte  | example: `\x01` (1 as a 8-bit unsigned char) | The id of the input the client wish to send data for |
| Input state  | 1 byte  | example: `\x88` (`10001000` in binary representation) if Up and Bomb are pressed| Each bit represent a button and is set to 1 if the button is pressed. From MSB to LSB: Up, Down, Left, Right, Bomb, Action. |

When several packets for the same input are received by the server between two ticks, the last one will be kept. When no packet for some input is received between two ticks, the last previous packet for this input will be used.


## Server requests

### Input connected

When a client registers an input with the input connection instruction, the server will send a request to the client to provide the assigned `client_id` (e.g. `\x00\x01`):

| Label  | Size | Value | Description |
| ------ | ---- | ----- | ----------- |
| Instruction  | 1 byte  | `\x00` (0 as a 8-bit unsigned char) | The value for the "input connected" instruction |
| `input_id`  | 1 byte  | example: `\x01` (1 as a 8-bit unsigned char) | The id of the input which will have to be used by the client |

After the first client input registration, the server will start sending the following requests.

### Step change

When the game step changes, the server will send a request to each registered client. It'll contain some information about the new step (e.g. `\x01\x01\x03`):

 Label  | Size | Value | Description |
| ------ | ---- | ----- | ----------- |
| Instruction  | 1 byte  | `\x01` (1 as a 8-bit unsigned char) | The value for the "step change" instruction |
| `step_id`  | 1 byte  | example: `\x01` (1 as a 8-bit unsigned char) | The id of the new step. 0 for the menu, 1 for the map. |
| `sub_step_id`  | 1 byte  | example: `\x03` (3 as a 8-bit unsigned char) | A step can also optionnaly have a `sub_step_id`. For example for the map step, it represents the id of the specific map which was selected. If not needed, it'll be a null byte (`\x00`). |

### Game data

At the end of each game loop, the server will send a request containing the game state to each registered client.

It'll contain all the information required to render the game. Each step will have a different payload. However, the payload will always be an array of entities. An entity (which can be thought of as a distinct element to render) will always at least contain the `class` attribute which will contain the entity class. Each entity class will then have some specific attributes needed for the rendering.

The payload will be serialized using [MessagePack](https://msgpack.org/index.html) and will then be compressed using [zlib](https://www.zlib.net/) before being sent to the client. It means that to access the data, the client will first have to inflate the raw received data before deserializing the result with MessagePack.

Here's an example of payload: `x\x9C\xAD\x8E=n\x021\x10\x85\x97\e\xA4\xC8\x01r\a\x94\x86\n\xD1\xA5\v\x8A\xA8\xADe=K,\xBCcd\x8F\xC3\xBA\xA7\xA0H\x17\x0E\x80\x11?\x02\x81D\xC1\x01,Z\xB6\xC8\x910?ED\x9DW\xCE\xFB4\xDF\x9B\x8C\x16\x99L\x8D\xD9\xB6\xA4\xCA\xFA\xA6\xD1\xF8P9\xF9\xB2\xDA{\xF7\xB2\xEBZ\x8D\x02{L \x872\xDC\xC9\xDD\eA\x11\xC1\x96*\xBA\x9DAD\xA7\xDE==\xA0\xDF7t\xF9.S\a\xDA\x97\xA7&\xFC\xD4c^\xBD;5\xDB!\x89y\x9E\t\x9E\xAC\xB9\xD0\x90\x91P8\x97\x90\xD3\xB2P_\xF1\xC9qk\xFAVJ\x06y\x1E\xCB\xB00\xCA\"\x0F\xAB\xA1\xC0\x8B\xE2\xB8\xE2\x90r\x96R8dVk@b\xF1@\x9F\xCC\f\xB4 H6\x86,\"\\\x89\xC7\x1D\xD5\xAFw\xD58\x9Ak\x7F\xCC\\\r\xF1\xDF\xCDgRU\x9A\xAD`.

In Ruby for example, it'd be handled like this:
```ruby
MessagePack.unpack(Zlib::Inflate.inflate(payload))

# [{"class"=>"Blocks::Soft", "x"=>176, "y"=>32, "burning_index"=>nil},
#  {"class"=>"Items::BombUp", "x"=>160, "y"=>16, "burning_index"=>nil},
#  {"class"=>"Player",
#   "x"=>172.60000000000005,
#   "y"=>71.00000000000028,
#   "id"=>0,
#   "direction"=>"left",
#   "moving"=>false,
#   "skull_effect"=>nil,
#   "sound"=>nil,
#   "winning"=>false,
#   "dead_at"=>nil,
#   "current_death_sprite"=>0,
#   "stunned_at"=>nil},
#  {"class"=>"Player",
#   "x"=>208,
#   "y"=>136,
#   "id"=>1,
#   "direction"=>"down",
#   "moving"=>false,
#   "skull_effect"=>nil,
#   "sound"=>nil,
#   "winning"=>false,
#   "dead_at"=>nil,
#   "current_death_sprite"=>0,
#   "stunned_at"=>nil}]
```

If we add the instruction byte, it'll look like `\x02x\x9C\xAD\x8E=n\x021\x10\x85\x97\e\xA4\xC8\x01r\a\x94\x86\n\xD1\xA5\v\x8A\xA8\xADe=K,\xBCcd\x8F\xC3\xBA\xA7\xA0H\x17\x0E\x80\x11?\x02\x81D\xC1\x01,Z\xB6\xC8\x910?ED\x9DW\xCE\xFB4\xDF\x9B\x8C\x16\x99L\x8D\xD9\xB6\xA4\xCA\xFA\xA6\xD1\xF8P9\xF9\xB2\xDA{\xF7\xB2\xEBZ\x8D\x02{L \x872\xDC\xC9\xDD\eA\x11\xC1\x96*\xBA\x9DAD\xA7\xDE==\xA0\xDF7t\xF9.S\a\xDA\x97\xA7&\xFC\xD4c^\xBD;5\xDB!\x89y\x9E\t\x9E\xAC\xB9\xD0\x90\x91P8\x97\x90\xD3\xB2P_\xF1\xC9qk\xFAVJ\x06y\x1E\xCB\xB00\xCA\"\x0F\xAB\xA1\xC0\x8B\xE2\xB8\xE2\x90r\x96R8dVk@b\xF1@\x9F\xCC\f\xB4 H6\x86,\"\\\x89\xC7\x1D\xD5\xAFw\xD58\x9Ak\x7F\xCC\\\r\xF1\xDF\xCDgRU\x9A\xAD`.

Here's the packet description:

 Label  | Size | Value | Description |
| ------ | ---- | ----- | ----------- |
| Instruction  | 1 byte  | `\x02` (2 as a 8-bit unsigned char) | The value for the "game data" instruction |
| Payload  | variable  | example: `x\x9C\x9B\xD4\xB849'\xB1\xB8x\x8FS~nRjQnb^PiR\xA5\x95\x95g^AiI\xB1\x95\x95O~rbN\x13D\xCDM\x154E\xC1%\xA9\x05@5\xBE\xA9y\xA5 *\xB1\xC039?oif^Jj\x05\x03\x00p$#\\` (arbitrary binary string, null padded)| Sequence of bytes representing the game data. Serialized with MessagePack, then compressed using zlib. |

## List of the different packets sent

| Type | Sender | Receiver | Instruction byte | Data | Format (cf. Ruby [`unpack`](https://apidock.com/ruby/String/unpack)) |
| ---- | ------ | -------- | ---------------- | ---- |--------------------------------------------------------------------- |
| Input connection | Client | Server | `0x00` | Instruction | C |
| Input state | Client | Server | `0x01` | Instruction/`input_id`/Input state | CCC |
| Input connected | Server | Client | `0x00` | Instruction/`input_id` | CC |
| Step change | Server | Client(s) | `0x01` | Instruction/`step_id`/`sub_step_id` | CCC |
| Game data | Server | Client(s) | `0x02` | Instruction/Payload | Ca* |

## Constants

- The value of the instructions sent by the client can be found in the [`BombermanRuby::Games::Client::NETWORK_INSTRUCTIONS`](lib/bomberman_ruby/games/client.rb#L6) constant.
- The bits used to send an input state from the client can be found in the [`BombermanRuby::Inputs::Local`](lib/bomberman_ruby/inputs/local.rb) class.
- The value of the instructions sent by the server can be found in the [`BombermanRuby::Games::Host::NETWORK_INSTRUCTIONS`](lib/bomberman_ruby/games/host.rb#L7) constant.
- The value of the steps sent by the server can be found in the [`BombermanRuby::Steps::Base::STEP_IDS`](lib/bomberman_ruby/steps/base.rb#L7) constant.
- The value of the map substeps sent by the server correspond to the array found in [`BombermanRuby::Steps::Menus::MapIcon::MAP_NAMES`](lib/bomberman_ruby/steps/menus/map_icon.rb#L15) constant. The index starts at 0, meaning that for example the value of "1" will represent the "Hi Power" map.
