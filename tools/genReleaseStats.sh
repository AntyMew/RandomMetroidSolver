#!/bin/bash

if [ $# -ne 1 ]; then
    echo "params: ROM"
    exit -1
fi

# cd to root dir
CWD=$(dirname $0)/..
cd ${CWD}
CWD=$(pwd)

ROM=$1

echo "checking total seeds"
[ -d ~/download/total_seeds_major ] || exit -1
[ -d ~/download/total_seeds_full ] || exit -1
echo "total seeds found"

function getDBParam {
    PARAM="$1"

    sed -e "s+.*${PARAM}='\([^']*\)'.*+\1+" ${CWD}/db_params.py
}
host=$(getDBParam "host")
user=$(getDBParam "user")
database=$(getDBParam "database")
password=$(getDBParam "password")

#################
# truncate tables
rm -rf ${CWD}/sql ${CWD}/logs

SQL="truncate table difficulties;
truncate table extended_stats;
truncate table item_locs;
truncate table solver_stats;
truncate table techniques;"
echo "${SQL}" | mysql -h ${host} -u ${user} -p${password} ${database}

#################
# compute stats

# 100 seeds pour tous les skill/setting presets
#${CWD}/tools/genExtStats.sh ${ROM} 100

# 900 seeds pour les skill/settings presets de tournoi
${CWD}/tools/genExtStats.sh ${ROM} 1000 new_rando
${CWD}/tools/genExtStats.sh ${ROM} 1000 Season_Races
#${CWD}/tools/genExtStats.sh ${ROM} 900 Playoff_Races
#${CWD}/tools/genExtStats.sh ${ROM} 900 SMRAT2020

# 900 seeds pour les skill preset inclus dans les rando presets
#${CWD}/tools/genExtStats.sh ${ROM} 900 default regular
#${CWD}/tools/genExtStats.sh ${ROM} 900 free noob
#${CWD}/tools/genExtStats.sh ${ROM} 900 hardway2hell master
#${CWD}/tools/genExtStats.sh ${ROM} 900 haste Season_Races
#${CWD}/tools/genExtStats.sh ${ROM} 900 highway2hell speedrunner
#${CWD}/tools/genExtStats.sh ${ROM} 900 stupid_hard master
#${CWD}/tools/genExtStats.sh ${ROM} 900 way_of_chozo regular

## 1000 seed pour les stats de prog speed
#${CWD}/tools/genProgSpeedStats.sh ${ROM} 500
#${CWD}/tools/genProgSpeedStats.sh ${ROM} 500 FULL
#
## Stats sur l'échantillon de seeds total
#${CWD}/tools/genTotalStats.sh ~/download/total_seeds_major
#${CWD}/tools/genTotalStats.sh ~/download/total_seeds_full FULL

#################
# load stats
${CWD}/tools/loadExtStats.sh

# dump stats
mysqldump -h ${host} -u ${user} -p${password} ${database} difficulties extended_stats item_locs techniques solver_stats > ${CWD}/new_stats.sql
gzip ${CWD}/new_stats.sql
