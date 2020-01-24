#!/usr/bin/env bash
echo "Running all integration tests:"
ls ./test_driver | grep -v "test" | while read line
do
 echo ""
 echo "############################################################"
 echo "         Execute flutter driver for [$line]:"
 echo "############################################################"
 echo ""
 flutter driver --target=test_driver/${line}
done
