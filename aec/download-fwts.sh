#!/bin/sh

set -e

FWT_PATH=${1:-$HOME/src/fwt/}

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