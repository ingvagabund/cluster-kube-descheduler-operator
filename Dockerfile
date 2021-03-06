FROM registry.svc.ci.openshift.org/openshift/release:golang-1.13 AS builder
WORKDIR /go/src/github.com/openshift/cluster-kube-descheduler-operator
COPY . .
# image-references file is not recognized by OLM
RUN rm manifests/4*/image-references
RUN go build -o cluster-kube-descheduler-operator ./cmd/cluster-kube-descheduler-operator

FROM registry.svc.ci.openshift.org/openshift/origin-v4.0:base
COPY --from=builder cluster-kube-descheduler-operator /usr/bin/
# Upstream bundle and index images does not support versioning so
# we need to copy a specific version under /manifests layout directly
COPY --from=builder manifests/4.4/* /manifests
COPY --from=builder metadata /metadata

LABEL io.k8s.display-name="OpenShift Descheduler Operator" \
      io.k8s.description="This is a component of OpenShift and manages the descheduler" \
      io.openshift.tags="openshift,cluster-kube-descheduler-operator" \
      com.redhat.delivery.appregistry=true \
      maintainer="AOS workloads team, <aos-workloads@redhat.com>"
