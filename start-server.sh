#!/bin/bash

# Copyright (c) 2016 Intel Corporation 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#provide the path to Node directory before starting the run
export PATH=/opt/local/node-v6.10.0-linux-x64/bin:$PATH

IMAGE_NAME=""  #if not set, workload uses image.jpeg by default

npm_ret=`which npm`
node_ret=`which node`

if [ ! -n "$npm_ret" ] || [ ! -n "$node_ret" ]; then
	echo "Node or npm binary not found. Please set the PATH and try again"
	exit 1
fi

CPU_COUNT=$1
if [ -n "${CPU_COUNT}" ]; then
  export CPU_COUNT=${CPU_COUNT}
fi

if [ -n "${IMAGE_NAME}" ]; then
  export IMAGE_NAME=${IMAGE_NAME}
fi

echo "Hello from start server script"

# Set proxy if needed
# export http_proxy
# export https_proxy

if [ -f server-input.txt ]; then
	port=`grep db_port server-input.txt | cut -d':' -f2`
	if [ "x$port" == "x" ]; then
		echo "Mongodb port is not set. Instance will not be started"
		exit 1
	fi
	mongod --dbpath ./mongodb.template --port $port > /dev/null &
else
	echo "Expected - mongodb to be running at the port specified in server config"
fi
echo "Installing npm modules"
npm install
echo "Starting server"
node server-cluster.js &
sleep 5
exit 0
