#!/bin/bash -x

OK_STATE=0
WARNING_STATE=1
CRITICAL_STATE=2
JMAPFILE="/usr/local/nagios/results/jmap-tmp.oxapp.result"
OWNER=vault
WARNING=97
CRITICAL=99


PERCENT=`cat "$JMAPFILE"`

OLDHEAP=$PERCENT


OLDHEAP=`awk -v var=$PERCENT 'BEGIN{ printf"%0.f\n", var}'`

if [ "$OLDHEAP" -gt "$CRITICAL" ]; then
                echo "CRITICAL: $OLDHEAP check Garbage Collection|oldheap=$OLDHEAP;$WARNING;$CRITICAL;0"
                exit $CRITICAL_STATE
        else
        if       [ "$OLDHEAP" -gt "$WARNING" ]; then
                        echo "WARNING: $OLDHEAP check Garbage Collection|oldheap=$OLDHEAP;$WARNING;$CRITICAL;0"
                        exit $WARNING_STATE
                else
                if       [ "$OLDHEAP" -lt 90 ]; then
                                echo "OK: $OLDHEAP is within bounderies|oldheap=$OLDHEAP;$WARNING;$CRITICAL;0"
                                exit $OK_STATE
                fi
        fi
fi
echo "OK: $OLDHEAP is within bounderies|percent=$OLDHEAP;$WARNING;$CRITICAL;0"
