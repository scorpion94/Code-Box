#!/bin/bash
# Desc: Ways to link output to /dev/null

echo "Hello" > /dev/null 2>&1
echo "Hello" &> /dev/null
echo "Hello" 1>/dev/null 2>/dev/null