echo "api host: ${API_HOST}"
echo "server port: ${PORT}"
echo "config server port: ${CONFIG_PORT}"

./easytier-web-embed --api-server-port ${PORT} --api-host ${API_HOST} --config-server-port ${CONFIG_PORT} --config-server-protocol tcp
