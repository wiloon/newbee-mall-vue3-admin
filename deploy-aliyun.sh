#!/bin/bash
rm -rf dist
npm run build:release
package_name="newbee-mall-admin.tar.gz"
gtar zcvf ${package_name} -C dist .
cp ${package_name} /Users/wiloon/tmp
scp ${package_name} aliyun:/tmp
# ansible -i 'wiloon.com,' all  -m shell -a 'ls /' -u root
ansible -i 'wiloon.com,' all  -m shell -a 'tar zxvf /tmp/newbee-mall-admin.tar.gz -C /root/volumes/nginx-www/_data/newbee-mall/' -u root
