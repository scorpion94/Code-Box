#!/bin/bash
# Desc: How to supress login banner on Solaris-Systems

var=$(ssh -q ${user}@${solaris_server} 'bash --noprofile' <<EOF
. .profile 2>/dev/null 1>/dev/null
echo "Hello"
EOF
)