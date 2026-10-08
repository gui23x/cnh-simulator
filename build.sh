#!/usr/bin/env bash

set -Eeuo pipefail

APP_NAME="TouriiRoute"
PACKAGE_NAME="touriiroute"
VERSION="2.0"
MAINTAINER="gui23x"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OUTPUT_DIR="${SCRIPT_DIR}/build_complete"
BUILD_DIR="${SCRIPT_DIR}/build"
DIST_DIR="${SCRIPT_DIR}/dist"
ICON_PATH="${SCRIPT_DIR}/assets/icon.png"

if ! command -v uv >/dev/null 2>&1; then
    echo "Erro: uv não está instalado ou não está disponível no PATH." >&2
    exit 1
fi

if ! command -v dpkg-deb >/dev/null 2>&1; then
    echo "Erro: dpkg-deb não está instalado. Instale o pacote dpkg." >&2
    exit 1
fi

if [[ ! -f "${SCRIPT_DIR}/main.py" || ! -f "$ICON_PATH" ]]; then
    echo "Erro: main.py ou assets/icon.png não foi encontrado." >&2
    exit 1
fi

ARCH="$(dpkg --print-architecture)"
DEB_DIR="${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}_${ARCH}"
DEB_FILE="${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"
LEGACY_DEB_DIR="${SCRIPT_DIR}/ToriiRoute_${VERSION}_${ARCH}"
LEGACY_DEB_FILE="${SCRIPT_DIR}/ToriiRoute_${VERSION}_${ARCH}.deb"

echo "Limpando artefatos de builds anteriores..."
rm -rf -- "$BUILD_DIR" "$DIST_DIR" "$OUTPUT_DIR" "$LEGACY_DEB_DIR" "$LEGACY_DEB_FILE"
mkdir -p "$OUTPUT_DIR"

echo "Construindo o executável Linux..."
uv run pyinstaller \
    --name "$APP_NAME" \
    --onefile \
    --windowed \
    --noconfirm \
    --add-data "assets:assets" \
    --add-data "json:json" \
    main.py

if [[ ! -x "${DIST_DIR}/${APP_NAME}" ]]; then
    echo "Erro: o PyInstaller não gerou o executável esperado em ${DIST_DIR}/${APP_NAME}." >&2
    exit 1
fi

cp -- "${DIST_DIR}/${APP_NAME}" "${OUTPUT_DIR}/${APP_NAME}-linux"
chmod +x "${OUTPUT_DIR}/${APP_NAME}-linux"

echo "Montando o pacote Debian..."
mkdir -p \
    "${DEB_DIR}/DEBIAN" \
    "${DEB_DIR}/opt/${APP_NAME}" \
    "${DEB_DIR}/usr/share/applications" \
    "${DEB_DIR}/usr/bin"

cat > "${DEB_DIR}/DEBIAN/control" <<EOF
Package: ${PACKAGE_NAME}
Version: ${VERSION}
Architecture: ${ARCH}
Maintainer: ${MAINTAINER}
Description: TouriiRoute - Preparatório para a Prova Teórica
 Um aplicativo desktop para preparação para o exame teórico da CNH.
 Suporta simulados offline e geração de questões usando Inteligência Artificial.
EOF

cat > "${DEB_DIR}/usr/share/applications/${PACKAGE_NAME}.desktop" <<EOF
[Desktop Entry]
Name=${APP_NAME} V${VERSION}
Comment=Estude para a CNH com banco local ou IA
Exec=/opt/${APP_NAME}/${APP_NAME}
Icon=/opt/${APP_NAME}/icon.png
Terminal=false
Type=Application
Categories=Education;
EOF

install -m 755 "${OUTPUT_DIR}/${APP_NAME}-linux" "${DEB_DIR}/opt/${APP_NAME}/${APP_NAME}"
install -m 644 "$ICON_PATH" "${DEB_DIR}/opt/${APP_NAME}/icon.png"
ln -s "../../opt/${APP_NAME}/${APP_NAME}" "${DEB_DIR}/usr/bin/${PACKAGE_NAME}"

dpkg-deb --build "$DEB_DIR" "${OUTPUT_DIR}/${DEB_FILE}"

rm -rf -- "$BUILD_DIR" "$DIST_DIR"

echo "Build concluído. Arquivos gerados em ${OUTPUT_DIR}:"
printf '  - %s\n' "${APP_NAME}-linux" "$DEB_FILE"
