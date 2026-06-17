#!/usr/bin/env bash
#
# LetsWatch deployment setup. / LetsWatch 部署配置脚本。
#
# Generates a ready-to-use .env: it asks only for the values that are genuinely
# yours (media path, license id, activation secret, admin login) and
# auto-generates every random secret so you never have to run `openssl` by hand.
# Runs in English or Chinese.
#
# 生成可直接使用的 .env：只询问真正属于你的值（媒体路径、license id、
# 激活密钥、管理员账号），其余随机密钥全部自动生成，无需手动跑 openssl。
# 支持中英文。
#
# Safe to re-run: existing non-empty values in .env are kept.
# 可重复运行：.env 中已有的非空值会保留。
#
# Usage / 用法:
#   ./setup.sh && docker compose pull && docker compose up -d

set -euo pipefail

cd "$(dirname "$0")"

ENV_FILE=".env"
EXAMPLE_FILE=".env.example"

# --- language selection / 语言选择 -----------------------------------------

LW_LANG="en"
echo "Select language / 选择语言:"
echo "  1) English"
echo "  2) 中文"
read -r -p "[1/2] (default 1): " lang_sel || true
case "${lang_sel:-}" in
  2 | zh | cn | 中文) LW_LANG="zh" ;;
  *) LW_LANG="en" ;;
esac

# t "<english>" "<chinese>" -> prints the string for the chosen language.
t() {
  if [ "$LW_LANG" = "zh" ]; then printf '%s' "$2"; else printf '%s' "$1"; fi
}

# --- prerequisites ----------------------------------------------------------

if ! command -v openssl >/dev/null 2>&1; then
  echo "$(t "error: openssl is required to generate secrets but was not found in PATH" \
            "错误：生成密钥需要 openssl，但在 PATH 中找不到")" >&2
  exit 1
fi

if [ ! -f "$EXAMPLE_FILE" ]; then
  echo "$(t "error: $EXAMPLE_FILE not found; run this script from the repository root" \
            "错误：找不到 $EXAMPLE_FILE，请在仓库根目录运行本脚本")" >&2
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  cp "$EXAMPLE_FILE" "$ENV_FILE"
  echo "$(t "Created $ENV_FILE from $EXAMPLE_FILE" "已从 $EXAMPLE_FILE 创建 $ENV_FILE")"
else
  echo "$(t "Found existing $ENV_FILE — keeping any values already set" \
            "检测到已有 $ENV_FILE — 已设置的值将保留")"
fi

# --- helpers ----------------------------------------------------------------

# A URL-safe random secret with no characters that need escaping in .env.
gen_secret() {
  openssl rand -base64 36 | tr '+/' '-_' | tr -d '=\n'
}

get_val() {
  grep -E "^$1=" "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2- || true
}

set_val() {
  local key="$1" val="$2" tmp
  tmp="$(mktemp)"
  awk -v k="$key" -v v="$val" '
    $0 ~ "^"k"=" { print k"="v; done=1; next }
    { print }
    END { if (!done) print k"="v }
  ' "$ENV_FILE" >"$tmp"
  mv "$tmp" "$ENV_FILE"
}

ensure_secret() {
  local key="$1"
  if [ -z "$(get_val "$key")" ]; then
    set_val "$key" "$(gen_secret)"
    echo "  $(t "generated" "已生成") $key"
  fi
}

# prompt_required KEY "english label" "chinese label"
prompt_required() {
  local key="$1" label input
  label="$(t "$2" "$3")"
  if [ -n "$(get_val "$key")" ]; then
    echo "  $(t "$key already set, keeping it" "$key 已设置，保留原值")"
    return
  fi
  while :; do
    read -r -p "  $label: " input
    [ -n "$input" ] && break
    echo "    $(t "this value is required" "此项为必填")"
  done
  set_val "$key" "$input"
}

# prompt_default KEY "english label" "chinese label" DEFAULT
prompt_default() {
  local key="$1" label input default="$4"
  label="$(t "$2" "$3")"
  if [ -n "$(get_val "$key")" ]; then
    echo "  $(t "$key already set, keeping it" "$key 已设置，保留原值")"
    return
  fi
  read -r -p "  $label [$default]: " input
  set_val "$key" "${input:-$default}"
}

# --- prompts: the only things you actually provide --------------------------

echo
echo "$(t "== Values you provide ==" "== 需要你填写的值 ==")"
prompt_required LETSWATCH_MEDIA_PATH \
  "Absolute host path to your media library" "媒体库在宿主机上的绝对路径"
prompt_required LETSWATCH_LICENSE_ID \
  "License id issued to you" "发放给你的 license id"
prompt_required LETSWATCH_LICENSE_ACTIVATION_SECRET \
  "Activation secret issued to you" "发放给你的激活密钥"
prompt_default LETSWATCH_USERNAME \
  "Initial admin username" "初始管理员用户名" "admin"

# Admin password: leave blank to auto-generate (printed once at the end).
GENERATED_ADMIN_PASSWORD=""
if [ -z "$(get_val LETSWATCH_PASSWORD)" ]; then
  read -r -s -p "  $(t "Admin password (leave blank to auto-generate)" \
                       "管理员密码（留空则自动生成）"): " admin_pw || true
  echo
  if [ -z "$admin_pw" ]; then
    admin_pw="$(gen_secret)"
    GENERATED_ADMIN_PASSWORD="$admin_pw"
  fi
  set_val LETSWATCH_PASSWORD "$admin_pw"
else
  echo "  $(t "LETSWATCH_PASSWORD already set, keeping it" "LETSWATCH_PASSWORD 已设置，保留原值")"
fi

# --- auto-generated random secrets ------------------------------------------

echo
echo "$(t "== Auto-generated secrets ==" "== 自动生成的密钥 ==")"
ensure_secret LETSWATCH_POSTGRES_PASSWORD
ensure_secret LETSWATCH_INTERNAL_TOKEN
ensure_secret LETSWATCH_STREAM_TOKEN_SECRET
ensure_secret LETSWATCH_FRONTEND_SESSION_SECRET

# --- done -------------------------------------------------------------------

echo
echo "$(t "Done. $ENV_FILE is ready." "完成。$ENV_FILE 已就绪。")"
if [ -n "$GENERATED_ADMIN_PASSWORD" ]; then
  echo
  echo "$(t "  Admin password was auto-generated. Save it now — shown only once:" \
            "  管理员密码已自动生成，请立即保存——只显示这一次：")"
  echo "  ┌────────────────────────────────────────────────────────────┐"
  printf  "  │   %-58s │\n" "$GENERATED_ADMIN_PASSWORD"
  echo "  └────────────────────────────────────────────────────────────┘"
fi
echo
echo "$(t "Next:" "下一步：")"
echo "  docker compose pull"
echo "  docker compose up -d"

# --- how to reach the admin console ----------------------------------------

ADMIN_PORT="$(get_val LETSWATCH_ADMIN_PORT)"
ADMIN_PORT="${ADMIN_PORT:-18082}"
ADMIN_USER="$(get_val LETSWATCH_USERNAME)"
ADMIN_USER="${ADMIN_USER:-admin}"

echo
echo "$(t "Once the containers are up, open the admin console:" \
          "容器启动后，访问管理后台：")"
echo "  $(t "URL" "地址")      : http://<server-ip>:${ADMIN_PORT}"
echo "  $(t "Username" "用户名") : ${ADMIN_USER}"
if [ -n "$GENERATED_ADMIN_PASSWORD" ]; then
  echo "  $(t "Password" "密码")   : $(t "the auto-generated one shown above" "上面自动生成的那串")"
else
  echo "  $(t "Password" "密码")   : $(t "the admin password you set" "你设置的管理员密码")"
fi
echo "$(t "Replace <server-ip> with this machine's IP or hostname (use 127.0.0.1 if local)." \
          "把 <server-ip> 换成本机 IP 或域名（本机调试用 127.0.0.1）。")"
