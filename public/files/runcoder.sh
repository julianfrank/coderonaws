sudo docker run --name coder -t -p 0.0.0.0:80:8443 -v "/home/ec2-user:/root/project" codercom/code-server --port=8443 --allow-http --password=PASSword