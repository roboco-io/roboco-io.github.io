#!/bin/bash

# 필요한 도구 설치 여부 확인
check_dependencies() {
    local missing_deps=()
    
    # librsvg 확인
    if ! command -v rsvg-convert &> /dev/null; then
        missing_deps+=("librsvg")
    fi
    
    # ImageMagick 확인
    if ! command -v magick &> /dev/null; then
        missing_deps+=("imagemagick")
    fi
    
    # 누락된 의존성이 있다면 설치
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "⚠️ 누락된 의존성을 설치합니다: ${missing_deps[*]}"
        brew install "${missing_deps[@]}"
    fi
}

# 파비콘 생성
generate_favicons() {
    local source_svg="static/favicon/favicon.svg"
    local favicon_dir="static/favicon"
    local root_dir="static"
    
    # SVG 파일 존재 여부 확인
    if [ ! -f "$source_svg" ]; then
        echo "❌ 오류: $source_svg 파일을 찾을 수 없습니다."
        exit 1
    fi
    
    echo "🎨 파비콘 생성 시작..."
    
    # PNG 파비콘 생성
    echo "1. PNG 파비콘 생성 중..."
    rsvg-convert -w 16 -h 16 -b none "$source_svg" > "$favicon_dir/favicon-16x16.png"
    rsvg-convert -w 32 -h 32 -b none "$source_svg" > "$favicon_dir/favicon-32x32.png"
    rsvg-convert -w 96 -h 96 -b none "$source_svg" > "$favicon_dir/favicon-96x96.png"
    rsvg-convert -w 180 -h 180 -b none "$source_svg" > "$favicon_dir/apple-touch-icon.png"
    rsvg-convert -w 192 -h 192 -b none "$source_svg" > "$favicon_dir/android-chrome-192x192.png"
    rsvg-convert -w 512 -h 512 -b none "$source_svg" > "$favicon_dir/android-chrome-512x512.png"
    
    # Apple Touch 아이콘을 루트 디렉토리에 복사
    echo "2. Apple Touch 아이콘 복사 중..."
    cp "$favicon_dir/apple-touch-icon.png" "$root_dir/apple-touch-icon.png"
    
    # ICO 파일 생성
    echo "3. ICO 파일 생성 중..."
    magick convert "$favicon_dir/favicon-16x16.png" "$favicon_dir/favicon-32x32.png" "$favicon_dir/favicon-96x96.png" "$favicon_dir/favicon.ico"
    
    echo "✅ 파비콘 생성 완료!"
    echo "
생성된 파일:
- favicon-16x16.png (브라우저 탭)
- favicon-32x32.png (브라우저 탭)
- favicon-96x96.png (브라우저 탭)
- favicon.ico (16x16, 32x32, 96x96)
- apple-touch-icon.png (iOS 홈 화면)
- android-chrome-192x192.png (Android 홈 화면)
- android-chrome-512x512.png (Android 홈 화면)
"
}

# 메인 실행
echo "🔍 의존성 확인 중..."
check_dependencies
generate_favicons
