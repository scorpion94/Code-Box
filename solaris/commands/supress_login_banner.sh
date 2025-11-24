#!/bin/bash

var=$(ssh -q ${user}@${solaris_server} 'bash --noprofile' <<EOF
. .profile 2>/dev/null 1>/dev/null
echo "Hello"
EOF
)