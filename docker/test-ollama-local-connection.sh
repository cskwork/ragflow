#!/bin/bash

# 로컬 IP 주소 감지
get_local_ip() {
    # 여러 방법으로 IP 주소 찾기 시도
    local ip=""
    
    # 방법 1: ip 명령어 사용
    if command -v ip &> /dev/null; then
        ip=$(ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
    fi
    
    # 방법 2: ifconfig 명령어 사용 (방법 1이 실패한 경우)
    if [ -z "$ip" ] && command -v ifconfig &> /dev/null; then
        ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1)
    fi
    
    # 방법 3: hostname 명령어 사용 (방법 1, 2가 실패한 경우)
    if [ -z "$ip" ] && command -v hostname &> /dev/null; then
        ip=$(hostname -I | awk '{print $1}')
    fi
    
    echo "$ip"
}

# Ollama 서버 URL 설정
LOCAL_IP=$(get_local_ip)
OLLAMA_PORT=${1:-11434}  # 기본 포트는 11434, 명령줄 인수로 변경 가능
OLLAMA_URL="http://${LOCAL_IP}:${OLLAMA_PORT}"

echo "로컬 IP 주소: ${LOCAL_IP}"
echo "Ollama 서버 URL: ${OLLAMA_URL}"

# Ollama 서버 연결 테스트
echo "Ollama 서버 연결 테스트 중..."
if command -v curl &> /dev/null; then
    # 모델 목록 가져오기 시도
    response=$(curl -s "${OLLAMA_URL}/api/tags" || echo "연결 실패")
    
    if [[ "$response" == *"연결 실패"* ]]; then
        echo "Ollama 서버에 연결할 수 없습니다. 서버가 실행 중인지 확인하세요."
    else
        echo "Ollama 서버 연결 성공!"
        echo "사용 가능한 모델 목록:"
        echo "$response" | grep -o '"name":"[^"]*' | sed 's/"name":"/- /'
        
        # 환경 변수 설정 방법 안내
        echo -e "\n환경 변수 설정 방법:"
        echo "export OLLAMA_BASE_URL=${OLLAMA_URL}"
        
        # .env 파일에 추가하는 방법 안내
        echo -e "\n.env 파일에 추가하는 방법:"
        echo "OLLAMA_BASE_URL=${OLLAMA_URL}"
    fi
else
    echo "curl 명령어를 찾을 수 없습니다. curl을 설치한 후 다시 시도하세요."
fi