#!/bin/bash

# Complete this script to deploy external-service and counter-service in two separate containers
# You will be using the conductor tool that you completed in task 3.

# Creating link to the tool within this directory
ln -s ../task3/conductor.sh conductor.sh
ln -s ../task3/config.sh config.sh

# use the above scripts to accomplish the following actions -

# Logical actions to do:
# 1. Build image for the container
# 2. Run two containers say c1 and c2 which should run in background. Tip: to keep the container running
#    in background you should use a init program that will not interact with the terminal and will not
#    exit. e.g. sleep infinity, tail -f /dev/null
# 3. Copy directory external-service to c1 and counter-service to c2 at appropriate location. You can
#    put these directories in the containers by copying them within ".containers/{c1,c2}/rootfs/" directory
# 4. Configure network such that:
#    4.a: c1 is connected to the internet and c1 has its port 8080 forwarded to port 3000 of the host
#    4.b: c2 is connected to the internet and does not have any port exposed
#    4.c: peer network is setup between c1 and c2
# 5. Get ip address of c2. You should use script to get the ip address. 
#    You can use ip interface configuration within the host to get ip address of c2 or you can 
#    exec any command within c2 to get it's ip address
# 6. Within c2 launch the counter service using exec [path to counter-service directory within c2]/run.sh
# 7. Within c1 launch the external service using exec [path to external-service directory within c1]/run.sh
# 8. Within your host system open/curl the url: http://localhost:3000 to verify output of the service
# 9. On any system which can ping the host system open/curl the url: `http://<host-ip>:3000` to verify
#    output of the service123

./conductor.sh build image1
bash -c "./conductor.sh run image1 eg1 \"sleep infinity\"" &
bash -c "./conductor.sh run image1 eg2 \"sleep infinity\"" &

sleep 10

./conductor.sh addnetwork eg1 -i -e 8080-3000
./conductor.sh addnetwork eg2 -i
./conductor.sh peer eg1 eg2

sleep 10
VAR=$(./conductor.sh exec eg1 "hostname -I")
echo $VAR
IP_1=$(echo $VAR | awk 'END{print $NF}')
VAR=$(./conductor.sh exec eg2 "hostname -I")
echo $VAR
IP_2=$(echo $VAR | awk 'END{print $NF}')
echo $IP_1
echo $IP_2
sleep 5


chmod 777 ./external-service/*
chmod 777 ./counter-service/*

cp -r ./external-service/ ./.containers/eg1/rootfs/home/
cp -r ./counter-service/ ./.containers/eg2/rootfs/home/

bash -c "./conductor.sh exec eg2 /home/counter-service/run.sh" &
bash -c "./conductor.sh exec eg1 /home/external-service/run.sh \"http://$IP_2:8080/\"" &

sleep 120
IP_HOST=$(echo "$IP_1" | sed -r 's/.$/1/g')
curl http://$IP_HOST:3000/
curl http://$IP_HOST:3000/
curl http://$IP_HOST:3000/
















