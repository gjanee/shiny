Demonstration of using R Shiny to interactively explore a real-world,
multidimensional dataset, namely, building occupancy data.  Hosted at
<https://gjanee.shinyapps.io/waitz>.

`Dockerfile` is an example of how the application can be containerized
into a Docker image.  The image can be built using `docker built -t
shiny .` and run using `docker run -p 8080:8080 shiny`.
