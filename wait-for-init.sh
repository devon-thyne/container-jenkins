#!/bin/bash

##### Check docker container log until initialization finishes to run pipeline script inside container

DEBUG=true

POST_INIT_PATTERN="INFO: Jenkins is fully up and running"

while true
do
    if sudo docker logs jenkins-master 2>&1 | grep -q "$POST_INIT_PATTERN"; then
        if $DEBUG; then echo 'Jenkins server finished initializing.'; fi
        break
    else
        if $DEBUG; then echo 'Jenkins server still initializing'; fi
        sleep 2
    fi
done

# After server initialization finishes, run pipeline execution script in container
if $DEBUG; then echo 'Running jenkins pipeline execution script on jenkins-master container.'; fi
sudo docker exec -it jenkins-master bash /home/root/execute-pipeline.sh
