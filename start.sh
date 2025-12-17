#!/bin/bash
ttyd -W -p 7681 sh -c "./portfolio-v2; ./welcome.sh; exec bash"
