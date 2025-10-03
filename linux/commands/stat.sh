# General Stat command
stat <filename>

# stat usefull Format Options
# Reference https://www.gnu.org/software/coreutils/manual/html_node/stat-invocation.html - 03.10.2025
# %n --> Filename
# %N --> Filename with target when symlink
# %a --> Permissions digital (i.E. 775)
# %A --> Permission i.E (-rw-r--r--)
# %U --> Username 
# %G --> Groupname
# %s --> size
# %w --> CreationTime
# %y --> Last modified
# %x --> Last read

stat -c "%n %a %U %G %s %y" <filename>

# Stat Options with a little description
stat -c "Name: %N | Permissions: %a | User: %U | Group: %G | Size: %s | Last modified: %y" test_link 
# Name: 'test_link' -> 'test/test' | Permissions: 777 | User: scorpion | Group: scorpion | Size: 9 | Last modified: 2025-10-03 10:49:58.889475847 +0200