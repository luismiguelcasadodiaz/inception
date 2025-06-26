#!/bin/sh

# Check that the Adminer index.php is responding
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
  exit 0
else
  echo "Adminer is not responding properly"
  exit 1
fi