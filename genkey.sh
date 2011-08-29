openssl genrsa -out /tmp/q-private.pem 1024
openssl rsa -in /tmp/q-private.pem -out /tmp/q-public.pem -outform PEM -pubout
echo "Get generated keys in /tmp"
echo "Deploy the public key ONLY on the receiver node"
echo "Deploy the private key ONLY on the sending nodes"

