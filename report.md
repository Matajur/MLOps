### Comparing two Docker images:

#### Fat Image

![Fat image](./img/fat.png)

#### Slim Image

![Slim image](./img/slim.png)

#### Result of classification

![Classification result](./img/result.png)

#### Conclusin

![Images comparison](./img/comparison.png)

The optimized image is 30 MB lighter thanks to the multi-stage build, which allows you to clearly separate the build stage and the execution stage and not include unnecessary dependencies in the final build.
