# mstar - Luajit star search tool

## Intro

* Small luajit script program
* Linux base command line star search program
* star database : HYG-Data(Star Object), DSO-Data(Deep-Skey Object)
* Fancy Nerd font icons and colored terminal display
* No dependency except `luajit`
* Portable

## Star DataBase
* It's all from astronexus github: Thanks to
 - <https://github.com/astronexus/HYG-Database>

## Requirement

* on `Linux` or `unix` base system
* `luajit-2.1`
* `Nerd Font` on Terminal

## Install

```console
$ git clone https://github.com/neosolaris/mstar.git
$ cd mstar/
$ ./setup.sh --help
$ ./setup.sh install # create shellscript command to 'bin/mstar'
$ export PATH=$PATH:<your_lemo_path>/bin
$ star -h
```

## Usage

* Usage
```console
Usage: mstar m31      -- deep-skey search (m,ngc...) HYG
       mstar hd22036  -- star search (hd,hip,hr...) DSO
```

## TODO

* More Detailed Search Options
* Static View
