#!/bin/bash

# ============================================================
#  TCC Gestor de Permisos - Cámara & Micrófono
#  Requiere: tccplus (se descarga automáticamente si no existe)
# ============================================================

# ─── Auto-elevar a sudo si no es root ──────────────────────
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo "🔐  Este script requiere permisos de administrador."
    echo "    Por favor ingresa tu contraseña:"
    echo ""
    exec sudo bash "$0" "$@"
    exit $?
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

TCCPLUS_PATH="$HOME/Downloads/tccplus"

mostrar_banner() {
    clear
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║     🎥  Gestor de Permisos TCC       ║${NC}"
    echo -e "${CYAN}${BOLD}║       Cámara & Micrófono — macOS     ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════╝${NC}"
    echo ""
}

verificar_tccplus() {
    if [ ! -f "$TCCPLUS_PATH" ]; then
        echo -e "${YELLOW}⚠  tccplus no encontrado en $TCCPLUS_PATH${NC}"
        echo -e "${DIM}   Descargando desde GitHub...${NC}"
        echo ""
        curl -# -L "https://github.com/jslegendre/tccplus/releases/latest/download/tccplus" \
             -o "$TCCPLUS_PATH" 2>&1
        chmod +x "$TCCPLUS_PATH"
        echo ""
        echo -e "${GREEN}✓  tccplus descargado correctamente.${NC}"
        echo ""
    else
        echo -e "${GREEN}✓  tccplus encontrado en:${NC} ${DIM}$TCCPLUS_PATH${NC}"
        echo ""
    fi
}

elegir_permiso() {
    while true; do
        echo -e "${BOLD}¿Qué permiso deseas conceder?${NC}"
        echo ""
        echo -e "  ${CYAN}1)${NC}  🎥  Cámara"
        echo -e "  ${CYAN}2)${NC}  🎙  Micrófono"
        echo -e "  ${CYAN}0)${NC}  ✖   Salir"
        echo ""
        read -rp "$(echo -e "${BOLD}Selecciona [0-2]: ${NC}")" perm_choice
        echo ""

        case $perm_choice in
            1)
                PERMISSION="Camera"
                ENTITLEMENT="com.apple.security.device.camera"
                ICON="🎥"
                return 0
                ;;
            2)
                PERMISSION="Microphone"
                ENTITLEMENT="com.apple.security.device.microphone"
                ICON="🎙"
                return 0
                ;;
            0)
                echo -e "${DIM}Saliendo...${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}✗  Opción inválida. Intenta de nuevo.${NC}"
                echo ""
                ;;
        esac
    done
}

escanear_apps() {
    echo -e "${YELLOW}🔍  Buscando apps con entitlement de $PERMISSION...${NC}"
    echo -e "${DIM}    (esto puede tardar unos segundos)${NC}"
    echo ""

    APP_NAMES=()
    BUNDLE_IDS=()

    SEARCH_DIRS=(
        "/Applications"
        "$HOME/Applications"
        "/System/Applications"
    )

    for dir in "${SEARCH_DIRS[@]}"; do
        [ -d "$dir" ] || continue
        while IFS= read -r app; do
            if codesign -d --entitlements - "$app" 2>/dev/null | \
               strings 2>/dev/null | grep -q "$ENTITLEMENT"; then
                name=$(basename "$app" .app)
                bundle_id=$(mdls -name kMDItemCFBundleIdentifier -r "$app" 2>/dev/null)
                if [ -n "$bundle_id" ] && [ "$bundle_id" != "(null)" ]; then
                    APP_NAMES+=("$name")
                    BUNDLE_IDS+=("$bundle_id")
                fi
            fi
        done < <(find "$dir" -maxdepth 2 -name "*.app" 2>/dev/null)
    done
}

elegir_app() {
    while true; do
        if [ ${#APP_NAMES[@]} -eq 0 ]; then
            echo -e "${RED}✗  No se encontraron apps con acceso a $PERMISSION.${NC}"
            echo -e "${DIM}   Puede que estén en una ruta no estándar.${NC}"
            echo ""
            read -rp "$(echo -e "${DIM}Presiona Enter para volver al menú principal...${NC}")"
            return 1
        fi

        echo -e "${BOLD}Apps encontradas con entitlement $ICON $PERMISSION:${NC}"
        echo ""
        echo -e "${DIM}──────────────────────────────────────────────────────${NC}"

        for i in "${!APP_NAMES[@]}"; do
            printf "  ${CYAN}%2d)${NC}  ${BOLD}%-30s${NC}  ${DIM}%s${NC}\n" \
                "$((i+1))" "${APP_NAMES[$i]}" "${BUNDLE_IDS[$i]}"
        done

        echo -e "${DIM}──────────────────────────────────────────────────────${NC}"
        echo -e "  ${CYAN}  b)${NC}  ← Volver al menú de permisos"
        echo -e "  ${CYAN}  0)${NC}  ✖  Salir"
        echo ""
        read -rp "$(echo -e "${BOLD}Selecciona el número de la app: ${NC}")" app_choice
        echo ""

        if [ "$app_choice" = "0" ]; then
            echo -e "${DIM}Saliendo...${NC}"
            echo ""
            exit 0
        fi

        if [ "$app_choice" = "b" ] || [ "$app_choice" = "B" ]; then
            return 1
        fi

        if ! [[ "$app_choice" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}✗  Opción inválida. Intenta de nuevo.${NC}"
            echo ""
            continue
        fi

        index=$((app_choice - 1))

        if [ "$index" -lt 0 ] || [ "$index" -ge "${#APP_NAMES[@]}" ]; then
            echo -e "${RED}✗  Número fuera de rango. Intenta de nuevo.${NC}"
            echo ""
            continue
        fi

        SELECTED_APP="${APP_NAMES[$index]}"
        SELECTED_BUNDLE="${BUNDLE_IDS[$index]}"
        return 0
    done
}

aplicar_permiso() {
    echo -e "${YELLOW}⚙  Concediendo permiso de $PERMISSION a ${BOLD}$SELECTED_APP${NC}${YELLOW}...${NC}"
    echo -e "${DIM}   Bundle ID: $SELECTED_BUNDLE${NC}"
    echo ""

    "$TCCPLUS_PATH" add "$PERMISSION" "$SELECTED_BUNDLE"
    EXIT_CODE=$?

    echo ""
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}${BOLD}✓  ¡Listo! Permiso de $ICON $PERMISSION concedido a $SELECTED_APP.${NC}"
        echo ""
        echo -e "${DIM}   Cierra y vuelve a abrir la app para que tome efecto.${NC}"
    else
        echo -e "${RED}✗  Error al conceder el permiso (código: $EXIT_CODE).${NC}"
    fi
}

# ─── Flujo principal ───────────────────────────────────────

mostrar_banner
verificar_tccplus

while true; do
    elegir_permiso
    escanear_apps

    if elegir_app; then
        aplicar_permiso
        echo ""
        read -rp "$(echo -e "${DIM}¿Dar otro permiso? [s/N]: ${NC}")" otra
        echo ""
        if [[ "$otra" =~ ^[sS]$ ]]; then
            mostrar_banner
            verificar_tccplus
            continue
        else
            echo -e "${DIM}Saliendo...${NC}"
            echo ""
            break
        fi
    fi
done
