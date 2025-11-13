This repository contains code for reproducting the results from from the paper "[Optimizing alluvial plots](https://doi.org/10.48550/arXiv.2509.03761)" by Joseph Rich, Conrad Oakes, and Lior Pachter.

### Docker
We provide a Docker image for running wompwomp built on [rocker/tidyverse](https://rocker-project.org)

```
docker run -it -p 8787:8787 -e PASSWORD=<YOUR_PASS> josephrich98/ROP_2025:1.0
```

Then vist "http://localhost:8787" in a browser and use username: rstudio, password: <YOUR_PASS> (change password as desired after "-e").
