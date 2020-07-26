#! /bin/bash

## This is a function for building a provided Dockerfile in the current directory,
## and then running it.

run_dock() {

echo "Starting docker image build..."
  ## This will captuire <Successfully built [ID]> from a sucessful docker build.
docker build . | grep "Successfully built" > tmp.txt  | echo "Image ID:"
 ## Removes any unnessary text from the ID that we want.
sed -i 's/\<Successfully built\>//g' tmp.txt
cont_id=$(cat tmp.txt)
echo $cont_id
echo "Now starting docker image.."
 ## Runs the docker image that was built in previous steps with the ID passed down from the build.
docker run -d --name mule $cont_id      | echo "Docker container 'mule' built and started!"
}
run_dock