# Redis sentinel deployment explained

## SHORT VERSION:
First we build the images:
```
docker-compose -f docker-compose-redis.yml build --no-cache redis-sentinel-alp
```

Then we start them:
```
docker-compose -f docker-compose-redis.yml scale redis-sentinel-alp=3
```
Cahnge the 3 number for the number of nodes needed
  
---
  
  
## LONG VERSION

### THE IMAGES:

- redis-sentinel-alp
	- Standard redis 3.2.12 image;
	- **Dockerfile**: copies redis.conf and a start script;
	- **docker-compose-redis.yml**: docker-compose file;
	- **redis.conf**: redis configuration;
	- **sentinel.conf**: sentinel2 configuration;
	- **start-redis.sh**: script to configurate the nodes;	

### HOW TO START EVERYTHING:

Then we start them. `NUMBER` is the number of redis instances you want:
```
docker-compose -f docker-compose-redis.yml scale redis-sentinel-alp=<NUMBER>
```

### Configurations:
- In docker-compose file, redis-cluster-manager image, environment variables:
	- **prefix_network**: prefix of the docker network to config nodes;
	- **init_ip**: initial last number ip of nodes to use in the process to select master node;
	- **last_ip**: last number ip of nodes to use in the process to select master node;

When containers are started, the script find ips availables in the range specified using prefix_network, init_ip and last_ip params, and set the node with the lowest ip with the master role, and other are slaves nodes of the master.

### Checking if everything is alright

The redis containers will be showing everything that happens on them in their console windows.

You can also connect to one of the containers
```
docker exec -it container_id /bin/bash

