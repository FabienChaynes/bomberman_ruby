# BombermanRuby

A Bomberman Tournament Battle mode clone written in Ruby. Can be played locally or over a network.

Mainly built for educational purpose.

![gameplay](./assets/readme/gameplay.gif?raw=true)

[This Bomberman Wiki](https://bomberman.fandom.com/wiki/Bomberman_Tournament) was used to get some informations about the gameplay.

Sprites are mainly coming from [The Spriters Resource](https://www.spriters-resource.com/game_boy_advance/bombertourn/).


## Dependencies

- Ruby ([How to install it](https://www.ruby-lang.org/en/documentation/installation/))
- Gosu ([How to install it](https://github.com/gosu/gosu/wiki#installation))

## Installation

Install the required gems with:

```ruby
bundle install
```

## Usage

You can start a local game with `./bin/bomberman`.

Use `./bin/bomberman -h` to list the different options.

By default, if no options are provided, a server will be started locally. To connect to a running server, provide its IP address with the `-s` command option.

You can change the port (both on the client and on the server) using the `-p` option.

`-c` can be used to provide a path to an alternate configuration file. The configuration file is used to map your keys to the game commands.

By default, the game will have as many players as defined in the configuration file. If you want to host a lower number of local players, use the `-n` option.

### Configuration file

The configuration file uses [YAML](https://yaml.org/).

Each root element will represent a player. The sub-elements will contain the different actions possible in the game. Each action will then be mapped to one or several keys.

For example, the following config file will convert to a player using the arrow keys to move, the "X" key to drop a bomb and the "space" key to start:
```yml
0:
  up:
    - KB_UP
  down:
    - KB_DOWN
  left:
    - KB_LEFT
  right:
    - KB_RIGHT
  bomb:
    - KB_X
  start:
   - KB_SPACE
```

Two players defined in one configuration file will look like this (replacing `[...]` by the player configuration):
```yml
0:
  up:
  [...]
1:
  up:
  [...]
```


If you want to use several keys for the same action, define them like this:
```yml
0:
  up:
    - KB_UP
    - KB_W
  [...]
```

The key names can be found in the [Gosu documentation](https://www.rubydoc.info/gems/gosu/Gosu#KB_0%E2%80%A6KB_9-constant).

Gamepads can be mapped using the gamepads buttons names:
```yml
0:
  up:
    - GP_0_UP
  down:
    - GP_0_DOWN
  left:
    - GP_0_LEFT
  right:
    - GP_0_RIGHT
  bomb:
    - GP_0_BUTTON_0
  start:
   - GP_0_BUTTON_6
```
You can map several gamepads with `GP_1_*`, `GP_2_*`, etc...
