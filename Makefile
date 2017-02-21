CSSWG_PATH=$(HOME)/src/csswg-test
TEST_FILES=$(wildcard bench/*.rkt)
TESTS=$(TEST_FILES:bench/%.rkt=%:verify)
SRC=$(wildcard cassius/*)
TIME=$(shell date +%s)
FLAGS=

.PHONY: download deploy publish

deploy:
	rsync -r www/ $(shell ~/uwplse/getdir)

publish:
	rsync -rv reports/ uwplse.org:/var/www/cassius/reports/$(TIME)/
	ssh uwplse.org chmod a+x /var/www/cassius/reports/$(TIME)/
	ssh uwplse.org chmod -R a+r /var/www/cassius/reports/$(TIME)/
	@ echo "Uploaded to http://cassius.uwplse.org/reports/$(TIME)/"

bench/css/%.rkt: get_bench.py get_bench.js
	@ sh bench/css/get.sh $* $(patsubst %,file://%,$(wildcard $(CSSWG_PATH)/css21/$*/*.xht))

bench/freewebsitetemplates/%.rkt: get_bench.py get_bench.js
	sh bench/freewebsitetemplates/get.sh $*

# The file bench/css/index.json is generated by going to
# <http://test.csswg.org/suites/css2.1/20110323/html4/toc.html>
# and running the JavaScript
# k = {}; a = $$("td a"); for (var i = 0; i < a.length; i++) { p = a[i].parentNode; while (p.tagName!="TBODY") p = p.parentNode; k[a[i].textContent] = p.id }; p = document.createElement("pre"); document.body.appendChild(p); p.textContent = JSON.stringify(k)
# on every linked page, collecting the resulting JSON objects into a JSON array.

reports/csswg.html reports/csswg.json: $(wildcard bench/css/*.rkt)
	racket src/report.rkt $(FLAGS) --index bench/css/index.json -o reports/csswg regression $^

reports/fwt.html reports/fwt.json: $(wildcard bench/freewebsitetemplates/*.rkt)
	racket src/report.rkt $(FLAGS) -o reports/fwt regression $^

rerun-tests:
	racket src/report.rkt $(FLAGS) --supported --failed reports/csswg.json --index bench/css/index.json -o reports/csswg regression $(wildcard bench/css/*.rkt)
