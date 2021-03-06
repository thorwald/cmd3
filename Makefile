PATHNAME=$(shell pwd)
BASENAME=$(shell basename $(PATHNAME))

TAG=`echo "print __version__" > v.py;  cat cmd3/__init__.py v.py > /tmp/v1.py; python /tmp/v1.py; rm /tmp/v1.py v.py`

all:
	make -f Makefile force

#####################################################################
# NOVA CLIENT
######################################################################
nova:
	pip install --upgrade -e git://github.com/openstack/python-novaclient.git#egg=python-novaclient

######################################################################
# GIT INTERFACES
######################################################################
push:
	make -f Makefile clean
	git commit -a 
	git push

pull:
	git pull 

gregor:
	git config --global user.name "Gregor von Laszewski"
	git config --global user.email laszewski@gmail.com

git-ssh:
	git remote set-url origin git@github.com:cloudmesh/$(BASENAME).git


######################################################################
# INSTALLATION
######################################################################
pip:
	pip install -r requirements.txt

dist:
	make -f Makefile pip

sdist:
	make -f Makefile clean
	python setup.py sdist --formats=tar
#	gzip dist/*.tar


force:
	make -f Makefile nova
	make -f Makefile pip
	#pip install -U dist/*.tar.gz

install:
	pip install dist/*.tar.gz

test:
	make -f Makefile clean	
	make -f Makefile distall
	pip install --upgrade dist/*.tar.gz


######################################################################
# PYPI
######################################################################


pip-upload: clean
#	make -f Makefile sdist
#	python setup.py register
	python setup.py sdist --format=bztar,zip upload

pip-register:
	python setup.py register

######################################################################
# QC
######################################################################

qc-install:
	pip install pep8
	pip install pylint
	pip install pyflakes

# #####################################################################
# CLEAN
# #####################################################################


clean:
	rm -rf AUTHORS ChangeLog
	rm -rf cmd3-*
	rm -rf *.egg
	find . -name "*~" -exec rm {} \;  
	find . -name "*.pyc" -exec rm {} \;  
	rm -rf build dist 
	rm -f *~ 
	rm -rf *.egg-info
	cd doc; make clean

#############################################################################
# SPHINX DOC
###############################################################################

html:
	make -f Makefile sphinx


sphinx:
	cd doc; make html

view: html
	open doc/build/html/index.html

#############################################################################
# PUBLISH GIT HUB PAGES
###############################################################################

gh-pages:
	git checkout gh-pages
	make pages

######################################################################
# TAGGING
######################################################################

tag:
	@echo "VERSION: $(TAG)"
	make clean
	git tag $(TAG)
	git add .
	touch README.rst
	git commit -m "adding version $(TAG)"
	git push
	git push origin --tags

######################################################################
# ONLY RUN ON GH-PAGES
######################################################################

PROJECT=`basename $(PWD)`
DIR=/tmp/$(PROJECT)
DOC=$(DIR)/doc

pages: ghphtml ghpgit
	echo done

ghphtml:
	cd /tmp
	rm -rf $(DIR)
	cd /tmp; git clone git://github.com/cloudmesh/$(PROJECT).git
	cp $(DIR)/Makefile .
	cd $(DOC); ls; make html
	rm -fr _static
	rm -fr _source
	rm -fr *.html
	cp -r $(DOC)/build/html/* .

ghpgit:
	git add . _sources _static   
	git commit -a -m "updating the github pages"
	git push
	git checkout master

