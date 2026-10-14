#!/bin/bash
export LD_LIBRARY_PATH=/opt/input-leap/lib
pkill input-leapc
exec /opt/input-leap/bin/input-leapc -f --name ZhaoPC --debug NOTE --disable-crypto 10.68.8.73:24800
