#!/bin/bash
set -e -u -x

function repair_wheel {
    wheel="$1"
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        auditwheel repair "$wheel" --plat "$PLAT" -w /io/wheelhouse/
    fi
}

for PYBIN in /opt/python/*/bin; do
    if [[ $PYBIN == *"36"* ]] || [[ $PYBIN == *"37"* ]] || [[ $PYBIN == *"38"* ]] || [[ $PYBIN == *"39"* ]]; then
        "${PYBIN}/pip" install -r /io/dev-requirements.txt
        "${PYBIN}/pip" wheel /io/ -w wheelhouse/
    fi
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/spglib*.whl; do
    repair_wheel "$whl"
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    if [[ $PYBIN == *"36"* ]] || [[ $PYBIN == *"37"* ]] || [[ $PYBIN == *"38"* ]] || [[ $PYBIN == *"39"* ]]; then
        "${PYBIN}/pip" install spglib --no-index -f ./wheelhouse
    fi
done
