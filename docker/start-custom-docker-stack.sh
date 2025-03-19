#!/bin/bash

# 사용자 정의 스택 이름 설정
STACK_NAME="docker-ragflow"

# 현재 디렉토리 저장
CURRENT_DIR=$(pwd)

# docker 디렉토리로 이동
cd "$(dirname "$0")"

# 기존 스택 중지 (있는 경우)
docker compose -p $STACK_NAME down

# 새 스택 이름으로 시작
docker compose -p $STACK_NAME up -d

# 원래 디렉토리로 돌아가기
cd "$CURRENT_DIR"

echo "Docker stack '$STACK_NAME' started successfully!"