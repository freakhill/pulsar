#!/bin/bash
start=$(date +%s)
echo -e "Current repo: $TRAVIS_REPO_SLUG Commit: $TRAVIS_COMMIT\n"

email="info@paralleluniverse.co"
username="PU Bot"
site_dir=docs/_site

if [ "$TRAVIS_BRANCH" == "master" ]; then
	# build site
	echo -e "Building Jekyll site...\n"
	cd docs
	jekyll build || error_exit "Error building Jekyll site"
	cd ..

	echo -e "Building Jekyll site done. Updating gh-pages...\n"
    # Any command that using GH_OAUTH_TOKEN must pipe the output to /dev/null to not expose your oauth token
    git submodule add -b gh-pages https://${GH_OAUTH_TOKEN}@github.com/${GH_OWNER}/${GH_PROJECT_NAME} site > /dev/null 2>&1
    cd site
    if git checkout gh-pages; then 
    	git checkout -b gh-pages
    fi
    git rm -r .
    cp -R ../$site_dir/* .
    cp ../$site_dir/.* .
    git add -f .
    git config user.email $email
    git config user.name $username
    git commit -am "Travis build $TRAVIS_BUILD_NUMBER, commit $TRAVIS_COMMIT, pushed to gh-pages"
    # Any command that using GH_OAUTH_TOKEN must pipe the output to /dev/null to not expose your oauth token
    git push https://${GH_OAUTH_TOKEN}@github.com/${GH_OWNER}/${GH_PROJECT_NAME} HEAD:gh-pages > /dev/null 2>&1 || error_exit "Error updating gh-pages"

	#git checkout -B gh-pages
	#git add -f dist/.
	#git commit -q -m "Travis build $TRAVIS_BUILD_NUMBER pushed to gh-pages"
	#git push -fq upstream gh-pages 2> /dev/null || error_exit "Error updating gh-pages"

	echo -e "Finished updating gh-pages\n"
fi

end=$(date +%s)
elapsed=$(( $end - $start ))
minutes=$(( $elapsed / 60 ))
seconds=$(( $elapsed % 60 ))
echo "Post-build process finished in $minutes minute(s) and $seconds seconds"