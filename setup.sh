#!/usr/bin/bash

PREFIX=${PWD}
PROGRAM=$(basename ${PWD})
PROG_ENV="${PROGRAM^^}"
BASENAME=$(basename $0)

show_help() {
  cat<<EOF

  [ Usage ]

  $(basename $0) install --- create execute shell script for luajit
  
  [ Requirement ]

  * luajit

  [ Exec EveryWhere ]
  * program will be ${PREFIX}/bin/${PROGRAM}
  * Add this path environment below:
  \$ echo "export PATH=\$PATH:${PREFIX}/bin/${PROGRAM}" >> ~/.bashrc"

EOF
}

check_luajit() {
  luajit -e 'print(_VERSION)'  | grep 'Lua 5.1' >/dev/null 2>&1
  [ $? != 0 ] && echo "Install Luajit 2.1.x please." && exit
}

shell_lua() {
  check_lua
}

bin_lua() {
  check_lua
}

do_install() {
  check_luajit
  cat<<EOF  > ${PREFIX}/bin/${PROGRAM}
#!/bin/sh
export LUA_PATH="${PREFIX}/lib/?.lua"
export ${PROG_ENV}=${PREFIX}
exec "${PREFIX}/lib/main.lua" "\$@"
EOF

  chmod u+x ${PREFIX}/bin/${PROGRAM}
  echo "--> ${PREFIX}/bin/${PROGRAM} is created!"
}

# ## Main
  
if [ $1 == 'install' ]; then
  check_luajit
  do_install
else
  show_help
fi
