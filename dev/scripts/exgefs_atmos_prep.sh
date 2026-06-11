#! /usr/bin/env bash

echo "$(date -u) begin $(basename $BASH_SOURCE)"

set -xa
if [[ ${STRICT:-NO} == "YES" ]]; then
	# Turn on strict bash error checking
	set -eu
fi

export HOMEgfs=${HOMEgfs:-${HOMEglobal}}
export HOMEufs=${HOMEufs:-${HOMEgfs}}
export USHgfs=$USHglobal
export FIXgfs=$FIXglobal
export FIXfv3=${FIXfv3:-$FIXorog}
export FIXam=${FIXam:-$FIXgfs/am}
export VCOORD_FILE=${VCOORD_FILE:-$FIXam/global_hyblev.l${LEVS}.txt}

mem=$ENSMEM
sfc_mem=${sfc_mem:-$ENSMEM}

cd $DATA

# Run scripts
#############################################################
$USHglobal/gefs_atmos_prep.sh $mem
export err=$?
if [[ $err != 0 ]]; then
	echo "FATAL ERROR in $(basename $BASH_SOURCE): atmos_prep failed for $RUNMEM!"
	exit $err
fi
#############################################################

echo "$(date -u) end $(basename $BASH_SOURCE)"

exit $err
