# vim: set filetype=sh ts=4 sw=4 tw=0 et :
#!/usr/bin/env bash

BASE_INSTALL="pipenv install --dev "
ANACONDA=( yapf flake8 autoflake isort importmagic python-language-server pyls-isort pyls-mypy epc pylint )
LSP=( yapf flake8 autoflake isort importmagic jedi json-rpc service_factory epc pylint )

while [[ $# -gt 0 ]]
do
    key="${1}"
    case ${key} in
        -b|--backend)
            backend="${2}"
            shift
            shift
            ;;
        -h|--help)
            echo "Option: -b | --backend : lsp or anaconda"
            ;;
        *)
            shift
            ;;
    esac
done

case $backend in
    lsp)
        packages=$(printf " %s" "${LSP[@]}")
        ;;
    anaconda)
        packages=$(printf " %s" "${ANACONDA[@]}")
        ;;
    *)
    echo 'Backend can only be "lsp" or "anaconda"'
    exit 1
esac


packages=${packages:1}
echo "Running.." $BASE_INSTALL $packages
eval $BASE_INSTALL $packages
