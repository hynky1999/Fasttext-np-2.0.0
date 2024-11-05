#!/bin/bash
set -e -x

SYSROOT=`$TARGET_CC --print-sysroot`

# Compile wheels
for PY_MINOR in 8 9 10 11 12; do
  PYTHON="python3.${PY_MINOR}"
  PYTHON_ABI="cp3${PY_MINOR}-cp3${PY_MINOR}"
  if [ "$PY_MINOR" = "7" ]; then
     PYTHON_ABI="${PYTHON_ABI}m"
  fi
  $PYTHON -m pip install crossenv
  # $PYTHON -m pip install https://github.com/virtuald/crossenv/archive/refs/heads/master.zip
  $PYTHON -m crossenv "/opt/python/${PYTHON_ABI}/bin/python3" --cc $TARGET_CC --cxx $TARGET_CXX --sysroot $SYSROOT "venv-py3${PY_MINOR}"
  . "venv-py3${PY_MINOR}/bin/activate"
  pip install wheel setuptools
  pip install pybind11
  python setup.py bdist_wheel --plat-name "manylinux2014_$ARCH" --dist-dir /tmp/dist/
  deactivate
done

# auditwheel symbols
python3 -m pip install -U auditwheel-symbols
for whl in /tmp/dist/fasttext*.whl; do
    auditwheel repair "$whl" -w /io/dist/
done

# Bundle external shared libraries into the wheels
# for whl in dist/fasttext*.whl; do
#     python3.9 -m auditwheel repair "$whl" -w /io/dist/
# done
