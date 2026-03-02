#!/bin/bash
set -e

echo "=== Mac Setup Script ==="
echo ""

# --------------------------------------------------
# 1. Homebrew
# --------------------------------------------------
echo "[1/9] Homebrew 설치..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "  -> 이미 설치됨. 건너뜀."
fi

# --------------------------------------------------
# 2. Homebrew Formulae
# --------------------------------------------------
echo "[2/9] Homebrew 패키지 설치..."

FORMULAE=(
  # 언어
  go

  # 컨테이너
  docker
  docker-completion
  colima

  # 클라우드 & 인프라
  google-cloud-sdk
  kubernetes-cli
  terraform

  # Protobuf / gRPC
  protobuf
  grpcui

  # CLI 도구
  ripgrep
  fzf
  git-lfs
)

for pkg in "${FORMULAE[@]}"; do
  if brew list "$pkg" &>/dev/null; then
    echo "  -> $pkg 이미 설치됨. 건너뜀."
  else
    echo "  -> $pkg 설치 중..."
    brew install "$pkg"
  fi
done

# --------------------------------------------------
# 3. Homebrew Casks
# --------------------------------------------------
echo "[3/9] 앱 설치..."

CASKS=(
  iterm2
  visual-studio-code
  dbeaver-community
  google-chrome
  slack
  discord
  kakaotalk
  notion
)

for app in "${CASKS[@]}"; do
  if brew list --cask "$app" &>/dev/null; then
    echo "  -> $app 이미 설치됨. 건너뜀."
  else
    echo "  -> $app 설치 중..."
    brew install --cask "$app"
  fi
done

# --------------------------------------------------
# 4. Claude Code
# --------------------------------------------------
echo "[4/9] Claude Code 설치..."
if command -v claude &>/dev/null; then
  echo "  -> 이미 설치됨. ($(claude --version))"
else
  curl -fsSL https://claude.ai/install.sh | sh
fi

# --------------------------------------------------
# 5. Go protobuf 플러그인
# --------------------------------------------------
echo "[5/9] Go protobuf 플러그인 설치..."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# --------------------------------------------------
# 6. Git LFS 초기화
# --------------------------------------------------
echo "[6/9] Git LFS 설정..."
git lfs install

# --------------------------------------------------
# 7. 설정 파일 복사
# --------------------------------------------------
echo "[7/9] 설정 파일 복사..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# .zshrc
cp "$SCRIPT_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
echo "  -> .zshrc 복사 완료"

# .zprofile
cp "$SCRIPT_DIR/dotfiles/.zprofile" "$HOME/.zprofile"
echo "  -> .zprofile 복사 완료"

# .gitconfig
cp "$SCRIPT_DIR/dotfiles/.gitconfig" "$HOME/.gitconfig"
echo "  -> .gitconfig 복사 완료"

# SSH (수동 복사 확인)
if [ ! -d "$HOME/.ssh" ]; then
  echo ""
  echo "  !! SSH 키가 없습니다."
  echo "  !! 기존 맥북에서 ~/.ssh/ 폴더를 복사한 뒤 아래 명령어를 실행하세요:"
  echo "     chmod 700 ~/.ssh"
  echo "     chmod 600 ~/.ssh/*"
  echo "     chmod 644 ~/.ssh/*.pub"
  echo ""
else
  echo "  -> SSH 키 이미 존재함."
fi

# --------------------------------------------------
# 8. 폰트 설치
# --------------------------------------------------
echo "[8/9] JetBrains Mono Nerd Font 설치..."
FONT_DIR="$HOME/Library/Fonts"
if ls "$FONT_DIR"/JetBrainsMonoNerd* &>/dev/null; then
  echo "  -> 이미 설치됨. 건너뜀."
else
  echo "  -> 다운로드 중..."
  TEMP_DIR=$(mktemp -d)
  curl -fsSL -o "$TEMP_DIR/JetBrainsMono.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -q "$TEMP_DIR/JetBrainsMono.zip" -d "$TEMP_DIR/JetBrainsMono"
  cp "$TEMP_DIR"/JetBrainsMono/*.ttf "$FONT_DIR/"
  rm -rf "$TEMP_DIR"
  echo "  -> 설치 완료"
fi

# --------------------------------------------------
# 9. macOS 설정
# --------------------------------------------------
echo "[9/9] macOS 설정 적용..."

# Dock 자동 숨김
defaults write com.apple.dock autohide -bool true

# Dock 아이콘 크기
defaults write com.apple.dock tilesize -int 54

# 키 반복 속도 (낮을수록 빠름)
defaults write NSGlobalDomain KeyRepeat -int 2

# 키 반복 시작까지 딜레이 (낮을수록 빠름)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# 트랙패드 탭으로 클릭
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Dock 재시작하여 설정 적용
killall Dock

echo ""
echo "=== 완료! ==="
echo ""
echo "수동으로 해야 할 것:"
echo "  1. SSH 키 복사 (기존 맥북 -> ~/.ssh/)"
echo "  2. iTerm2에서 폰트를 JetBrains Mono Nerd Font으로 설정"
echo "  3. Google Cloud 로그인: gcloud auth login"
echo "  4. GitHub SSH 연결 확인: ssh -T git@github.com"
