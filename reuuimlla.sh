#!/bin/sh

. "${0%/*}/common.in"

git grep -li ReuuiMlla | while read f; do
	sed -i \
	       	-e 's|@Reuuimllatech.com|@allwinnertech.com|g' \
		-e 's|reuuimllatech.com|allwinnertech.com|g' \
		-e 's|Reuuimlla|Allwinner|g' \
		-e 's|ReuuiMlla|AllWinner|g' \
		-e 's|REUUIMLLA|ALLWINNER|g' \
		-- "$f"
done
git grep -li newbie | while  read f; do
	sed -i \
		-e 's|newbie Linux Platform|AllWinner Linux Platform|g' \
		-e 's|newbietech.com|allwinnertech.com|g' \
		-- "$f"
done
