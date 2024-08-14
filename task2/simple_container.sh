#!/bin/bash

SIMPLE_CONTAINER_ROOT=container_root

mkdir -p $SIMPLE_CONTAINER_ROOT

gcc -o container_prog container_prog.c

## Subtask 1: Execute in a new root filesystem

cp container_prog $SIMPLE_CONTAINER_ROOT/

# 1.1: Copy any required libraries to execute container_prog to the new root container filesystem 
mkdir -p $chr/{bin,lib,lib64}
list="$(ldd /bin/bash | egrep -o '/lib.*\.[0-9]')"

for i in $list;
do 
    cp -v --parents "$i" "${SIMPLE_CONTAINER_ROOT}"
done

cp /usr/bin/nsenter $SIMPLE_CONTAINER_ROOT/

newlist="$(ldd /usr/bin/nsenter | egrep -o '/lib.*\.[0-9]')"

for i in $newlist;
do 
    cp -v --parents "$i" "${SIMPLE_CONTAINER_ROOT}"
done


cp /usr/bin/unshare $SIMPLE_CONTAINER_ROOT/

newlist="$(ldd /usr/bin/unshare | egrep -o '/lib.*\.[0-9]')"

for i in $newlist;
do 
    cp -v --parents "$i" "${SIMPLE_CONTAINER_ROOT}"
done



echo -e "\n\e[1;32mOutput Subtask 2a\e[0m"
# 1.2: Execute container_prog in the new root filesystem using chroot. You should pass "subtask1" as an argument to container_prog
/usr/sbin/chroot $SIMPLE_CONTAINER_ROOT ./container_prog subtask1


echo "__________________________________________"
echo -e "\n\e[1;32mOutput Subtask 2b\e[0m"
## Subtask 2: Execute in a new root filesystem with new PID and UTS namespace
# The pid of container_prog process should be 1
# You should pass "subtask2" as an argument to container_prog



unshare -p -u /usr/sbin/chroot $SIMPLE_CONTAINER_ROOT ./container_prog subtask2 

echo -e "\nHostname in the host: $(hostname)"


## Subtask 3: Execute in a new root filesystem with new PID, UTS and IPC namespace + Resource Control
# Create a new cgroup and set the max CPU utilization to 50% of the host CPU. (Consider only 1 CPU core)
mkdir /sys/fs/cgroup/new_cgroup
echo "50000 100000" > /sys/fs/cgroup/new_cgroup/cpu.max


echo "__________________________________________"
echo -e "\n\e[1;32mOutput Subtask 2c\e[0m"
# Assign pid to the cgroup such that the container_prog runs in the cgroup
# Run the container_prog in the new root filesystem with new PID, UTS and IPC namespace
# You should pass "subtask1" as an argument to container_prog

echo $$ > /sys/fs/cgroup/new_cgroup/cgroup.procs
unshare -p -u -i /usr/sbin/chroot $SIMPLE_CONTAINER_ROOT ./container_prog subtask3


# Remove the cgroup


# If mounted dependent libraries, unmount them, else ignore
