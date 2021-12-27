#!/bin/bash

cat <<EOF > ~/.vimrc
set shiftwidth=4
set softtabstop=4
set nu
set autoindent
EOF

source ~/.vimrc