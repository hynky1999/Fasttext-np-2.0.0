#!/bin/bash
set -e -x

# Build a sdist
/opt/python/cp310-cp310/bin/python setup.py sdist
mkdir -p /io/dist/
mv dist/*.tar.gz /io/dist/

# Compile wheels
for PYBIN in /opt/python/cp3{8..12}*/bin; do
    "${PYBIN}/python" -m pip install build
    "${PYBIN}/python" -m build --wheel -o dist
done

# Bundle external shared libraries into the wheels
for whl in dist/fasttext*.whl; do
    auditwheel repair "$whl" -w /io/dist/
done
