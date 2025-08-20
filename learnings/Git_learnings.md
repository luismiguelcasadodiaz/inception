

#### Add a new remote for the current repository

At some point during the project, I realized that, in addition to having a copy of my files on GitHub, I needed to upload the work to the 42 exam repository.

I added a new remote to it

```bash
$ git remote add delivery git@vogsphere.42barcelona.com:vogsphere/intra-uuid-da3fabda-c64b-44a3-b510-16adb506a2a1-6567596-luicasad
```

#### Check current remote repositories

```bash
$ git remote -v

delivery	git@vogsphere.42barcelona.com:vogsphere/intra-uuid-da3fabda-c64b-44a3-b510-16adb506a2a1-6567596-luicasad (fetch)
delivery	git@vogsphere.42barcelona.com:vogsphere/intra-uuid-da3fabda-c64b-44a3-b510-16adb506a2a1-6567596-luicasad (push)
origin	git@github.com:luismiguelcasadodiaz/inception.git (fetch)
origin	git@github.com:luismiguelcasadodiaz/inception.git (push)

```

### Pull changes from one repository

```bash
git fetch delivery
git checkout main
git merge delivery/main
git push origin main
git push delivery main
```

### Avoid saving secrets in the repositories
I configured .gitignore
```
*.iso
*.iso.sha256
secrets/*.txt
tests/data/*
.ash_history
```
