#!/bin/bash

set -e

for cluster in \
eks-control-plane \
eks-origin-plane \
eks-data-plane
do

aws eks update-cluster-config \
--name ${cluster} \
--resources-vpc-config \
endpointPublicAccess=false,endpointPrivateAccess=true

done
``