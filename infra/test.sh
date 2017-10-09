#!/bin/sh

set -e

FWT_PATH=${FWT_PATH:-$HOME/src/fwt/}
CSSWG_PATH=${CSSWG_PATH:-$HOME/src/web-platform-tests/css/CSS2}
THREADS=6

for FWT in \
    adventurewebsitetemplate airsportswebsitetemplate amusementparkwebsitetemplate applefarm \
    armyacademywebsitetemplate astronomywebsitetemplate backupsoftwarewebtemplate barwebsitetemplate \
    beachresort beachresortwebsitetemplate bikegearwebsitetemplate bookauthorportfoliowebtemplate \
    businessanalystwebsitetemplate businessexpertswebsitetemplate businessnewswebtemplate businesssolutions \
    businesssolutionwebtemplate businessworldtemplate cakewebsitetemplate cardiologywebsitetemplate \
    carracingwebtemplate carrepairshop cartoonappswebtemplate childrensappwebsitetemplate \
    cinematheaterwebsitetemplate coffeewebsitetemplate cookingrecipewebtemplate corporateconsultantwebtemplate \
    cruisevacationtemplate customshirtwebtemplate denimjeanswebtemplate displaywebsitetemplate \
    drinkingjuicewebtemplate ecoliving ecologicalwebsitetemplate eternalbeautyessentialswebtemplate \
    familychessclub fantasygamewebtemplate finemindsmarketingwebtemplate firefighterwebsitetemplate \
    fishingwebsitetemplate footballwebsitetemplate furnitureshopwebsitetemplate gadgetshopwebsitetemplate \
    gamewebsitetemplate gardenwalkthrough genericwebsitetemplate hairrepairwebsitetemplate \
    hairstylesalon healthylifetemplate helicoptertransportationwebtemplate herdesignswebtemplate \
    highfashion icecreamwebsitetemplate iphonegamewebtemplate islandhotelwebsitetemplate \
    lawfirm lawfirmwebsitetemplate logistics lollipops \
    madillustratorsportfoliotemplate magictree makeupwebsitetemplate medicalhospitalwebsitetemplate \
    morumallwebsitetemplate musicartistwebtemplate musicschoolwebsitetemplate mustacheenthusiast \
    neodance ngowebsitetemplate omorfiumgamingwebsite originarchitectswebsitetemplate \
    paintrepublic paredeswinerywebsitetemplate personalizedwebtemplate personalwebsitetemplate \
    petshoptemplate photographywebsitetemplate puppy rehabilitation-yoga \
    resortandcountryclubwebtemplate retrodiner running scienceclubwebsitetemplate \
    snackswebsitetemplate socialadvicewebsitetemplate space-science sportinggoodswebtemplate \
    summercamp sushihanii tailorshopwebsitetemplate themargaritafragrancewebtemplate \
    tourismsurfing treepreservation vinylrecordshopwebtemplate weddingblog \
    womenclothing woodworkingwebsitetemplate yogawebsitetemplate zerotype;
do
    FILE=$FWT_PATH/$FWT.zip

    if [ ! -f "$FILE" ]; then
        curl -L -s https://freewebsitetemplates.com/download/"$NAME"/ > "$FILE"
    fi

    if [ ! -s "$FILE" ]; then
        printf "ERROR! Downloaded empty file in %s\n" "$FILE"
        rm "$FILE"
        exit 1
    fi
done

make clean

for CSSWG in \
    abspos borders box-display box cascade floats-clear \
    floats linebox margin-padding-clear normal-flow positioning text;
do
    echo bench/css/$CSSWG.rkt
done | xargs make -j$THREADS bench/fwt.rkt

make FLAGS="--threads $THREADS" reports/fwt.html reports/vizassert.html reports/csswg.html

cp bench/fwt.rkt bench/css/*.rkt reports/