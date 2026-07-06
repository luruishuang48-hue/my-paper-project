# Install packages for specr analysis
packages <- c('specr', 'estimatr', 'tidyverse', 'broom')
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, repos = 'https://cran.r-project.org')
  }
}
cat('✓ All packages ready\n')
