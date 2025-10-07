git checkout --orphan gh-pages
git --work-tree=build/web add --all
git --work-tree=build/web commit -m "Deploy latest version"
git push origin gh-pages --force
git checkout main
