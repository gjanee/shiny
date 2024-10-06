Demonstration of using R/Shiny to interactively explore a real-world,
multidimensional dataset, namely, building occupancy data.  How to run
and view this application:

1. From within RStudio.

2. Principally, it's hosted at <https://gjanee.shinyapps.io/waitz>.
   Deployment is through RStudio.  The application can also be
   deployed directly from GitHub, and deployment can even be
   automated, by creating a Docker build file (see next; the included
   `Dockerfile` is a start, but it will need to call
   `rsconnect::setAccountInfo` and `rsconnect::deployApp` instead of
   `shiny::runApp`), then creating a GitHub Action to build and run a
   container.  It will be necessary to pass authentication credentials
   in as GitHub repository secrets.  See
   [here](https://www.r-bloggers.com/2021/02/deploy-to-shinyapps-io-from-github-actions/)
   and
   [here](https://github.com/marketplace/actions/deploy-to-shinyapps-io)
   for examples.

3. As a container.  `Dockerfile` is an example Docker build file.
   Build a Docker image for the application using
   `docker built -t waitz .`, run using
   `docker run -p 8080:8080 waitz`, and view at
   http[]()://localhost:8080.  N.B.: the build process will fail
   unless newer versions of R and packages, as recorded in the renv
   lock file here, are used.

4. Using [shinylive](https://posit-dev.github.io/r-shinylive/), which
   obviates the need for a server and provides a means of running
   Shiny applications entirely within the user's browser: doesn't
   work, at least for this application.  The application doesn't run
   at all in Safari, and only partially works in Firefox.
   Additionally, it takes a long time to load the application, and the
   application runs so slowly as to be unusable.

5. On [Binder](https://mybinder.org), but only with great difficulty.
   First, `Dockerfile` must be removed; Binder will attempt to build a
   container if it detects `Dockerfile`, but that succeeds only if the
   build file performs several critical, Binder-specific actions.
   Second, renv must be removed or at least disabled (at minimum, by
   removing `.Rprofile`) and replaced with an old-style `install.R`
   script.  Then, bugs in Binder (as of this writing) prevent the
   application from launching by appending `/shiny/waitz` to the URL
   as stated in the Binder documentation; instead, it will be
   necessary to append `/rstudio` and then manually launch the
   application from within the RStudio instance hosted by Binder.
   Quite painful.

6. On Google Colab: not possible.  A Shiny application requires that a
   port be exposed.  Colab provides a way to map a port to the outside
   world from Python, but not from R.
