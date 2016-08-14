

An app starter with docker set up so you can dev inside docker. 

Pros:
- my code is running in the same env / os as it would on prod
- my code runs in isolation
- my environment is reproducible
- can run my entire dev stack locally / it's portable
- ready to deploy immediately

Cons:
- more up front effort
- windows fs watchers are shit
- requires a separate dockerfile

Build the image:  

```
-p: project name
-r docker repository
-o build phase (this one does not push the image)  

$ ./build.sh -p dooker -r dotfold -o package
```

Then just run the container. Make sure you specify port 8800 in the run command, and open that port up to localhost on virtualmachine.

```
# TODO: verify this command actually works*
$ docker run dotfold/dooker -p 8800:8800 -f Dockerfile-local -v app:/src/app
```

Alternatively, can be specified in a compose file:

```
version '2
services:
    image: dotfold/dooker:latest
    build:
      # path to the app code
      context:  ./../dooker
      dockerfile: Dockerfile-local
    expose:
      - "8800"
    volumes:
      - "./../dooker/app:/src/app"
    environment:
      - NODE_ENV=development
```