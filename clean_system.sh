#!/bin/bash

################################################################################
# Linux 系统清理脚本
# 功能：清理系统缓存、临时文件、日志文件等，释放磁盘空间
# 作者：自动生成
# 日期：2025-11-12
################################################################################

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 全局变量
TOTAL_FREED=0
LOG_FILE="/tmp/system_clean_$(date +%Y%m%d_%H%M%S).log"

################################################################################
# 工具函数
################################################################################

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[信息]${NC} $1" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1" | tee -a "$LOG_FILE"
}

# 打印分隔线
print_separator() {
    echo -e "${BLUE}========================================${NC}"
}

# 检查是否为 root 用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "此脚本需要 root 权限运行"
        print_info "请使用: sudo $0"
        exit 1
    fi
}

# 获取目录大小（MB）
get_dir_size() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        du -sm "$dir" 2>/dev/null | awk '{print $1}'
    else
        echo "0"
    fi
}

# 获取磁盘使用情况
get_disk_usage() {
    df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}'
}

# 检测包管理器
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    else
        echo "unknown"
    fi
}

################################################################################
# 清理函数
################################################################################

# 清理包管理器缓存
clean_package_cache() {
    print_separator
    print_info "正在清理包管理器缓存..."
    
    local pkg_manager=$(detect_package_manager)
    local size_before=0
    local size_after=0
    
    case "$pkg_manager" in
        apt)
            size_before=$(get_dir_size "/var/cache/apt/archives")
            print_info "APT 缓存大小: ${size_before} MB"
            
            apt-get clean &>> "$LOG_FILE"
            apt-get autoclean &>> "$LOG_FILE"
            apt-get autoremove -y &>> "$LOG_FILE"
            
            size_after=$(get_dir_size "/var/cache/apt/archives")
            ;;
        yum)
            size_before=$(get_dir_size "/var/cache/yum")
            print_info "YUM 缓存大小: ${size_before} MB"
            
            yum clean all &>> "$LOG_FILE"
            
            size_after=$(get_dir_size "/var/cache/yum")
            ;;
        dnf)
            size_before=$(get_dir_size "/var/cache/dnf")
            print_info "DNF 缓存大小: ${size_before} MB"
            
            dnf clean all &>> "$LOG_FILE"
            
            size_after=$(get_dir_size "/var/cache/dnf")
            ;;
        *)
            print_warning "未检测到支持的包管理器"
            return
            ;;
    esac
    
    local freed=$((size_before - size_after))
    TOTAL_FREED=$((TOTAL_FREED + freed))
    print_success "包管理器缓存清理完成，释放空间: ${freed} MB"
}

# 清理临时文件
clean_temp_files() {
    print_separator
    print_info "正在清理临时文件..."
    
    local size_before=0
    local size_after=0
    
    # 清理 /tmp
    if [[ -d "/tmp" ]]; then
        size_before=$(get_dir_size "/tmp")
        print_info "/tmp 目录大小: ${size_before} MB"
        
        # 只删除超过 7 天的文件
        find /tmp -type f -atime +7 -delete 2>> "$LOG_FILE"
        find /tmp -type d -empty -delete 2>> "$LOG_FILE"
        
        size_after=$(get_dir_size "/tmp")
        local freed=$((size_before - size_after))
        TOTAL_FREED=$((TOTAL_FREED + freed))
        print_success "/tmp 清理完成，释放空间: ${freed} MB"
    fi
    
    # 清理 /var/tmp
    if [[ -d "/var/tmp" ]]; then
        size_before=$(get_dir_size "/var/tmp")
        print_info "/var/tmp 目录大小: ${size_before} MB"
        
        find /var/tmp -type f -atime +7 -delete 2>> "$LOG_FILE"
        find /var/tmp -type d -empty -delete 2>> "$LOG_FILE"
        
        size_after=$(get_dir_size "/var/tmp")
        local freed=$((size_before - size_after))
        TOTAL_FREED=$((TOTAL_FREED + freed))
        print_success "/var/tmp 清理完成，释放空间: ${freed} MB"
    fi
}

# 清理用户缓存
clean_user_cache() {
    print_separator
    print_info "正在清理用户缓存目录..."
    
    local total_freed=0
    
    # 获取所有普通用户的家目录
    while IFS=: read -r username _ uid _ _ homedir _; do
        if [[ $uid -ge 1000 ]] && [[ -d "$homedir/.cache" ]]; then
            local size_before=$(get_dir_size "$homedir/.cache")
            
            if [[ $size_before -gt 0 ]]; then
                print_info "清理 $username 的缓存 (~/.cache): ${size_before} MB"
                
                # 清理缓存但保留目录结构
                find "$homedir/.cache" -type f -atime +30 -delete 2>> "$LOG_FILE"
                find "$homedir/.cache" -type d -empty -delete 2>> "$LOG_FILE"
                
                local size_after=$(get_dir_size "$homedir/.cache")
                local freed=$((size_before - size_after))
                total_freed=$((total_freed + freed))
                
                if [[ $freed -gt 0 ]]; then
                    print_success "用户 $username 缓存清理完成，释放: ${freed} MB"
                fi
            fi
        fi
    done < /etc/passwd
    
    TOTAL_FREED=$((TOTAL_FREED + total_freed))
    print_success "用户缓存清理完成，总共释放: ${total_freed} MB"
}

# 清理缩略图缓存
clean_thumbnails() {
    print_separator
    print_info "正在清理缩略图缓存..."
    
    local total_freed=0
    
    while IFS=: read -r username _ uid _ _ homedir _; do
        if [[ $uid -ge 1000 ]] && [[ -d "$homedir/.cache/thumbnails" ]]; then
            local size_before=$(get_dir_size "$homedir/.cache/thumbnails")
            
            if [[ $size_before -gt 0 ]]; then
                print_info "清理 $username 的缩略图: ${size_before} MB"
                
                rm -rf "$homedir/.cache/thumbnails"/* 2>> "$LOG_FILE"
                
                local size_after=$(get_dir_size "$homedir/.cache/thumbnails")
                local freed=$((size_before - size_after))
                total_freed=$((total_freed + freed))
                
                if [[ $freed -gt 0 ]]; then
                    print_success "用户 $username 缩略图清理完成，释放: ${freed} MB"
                fi
            fi
        fi
    done < /etc/passwd
    
    TOTAL_FREED=$((TOTAL_FREED + total_freed))
    print_success "缩略图缓存清理完成，总共释放: ${total_freed} MB"
}

# 清理系统日志
clean_system_logs() {
    print_separator
    print_info "正在清理系统日志文件..."
    
    local size_before=$(get_dir_size "/var/log")
    print_info "/var/log 目录大小: ${size_before} MB"
    
    # 清理 journal 日志（保留最近 7 天）
    if command -v journalctl &> /dev/null; then
        print_info "清理 systemd journal 日志..."
        journalctl --vacuum-time=7d &>> "$LOG_FILE"
    fi
    
    # 清理旧的日志文件
    find /var/log -type f -name "*.log.*" -mtime +30 -delete 2>> "$LOG_FILE"
    find /var/log -type f -name "*.gz" -mtime +30 -delete 2>> "$LOG_FILE"
    find /var/log -type f -name "*.old" -mtime +30 -delete 2>> "$LOG_FILE"
    
    # 清空大型日志文件（保留文件但清空内容）
    find /var/log -type f -name "*.log" -size +100M -exec truncate -s 0 {} \; 2>> "$LOG_FILE"
    
    local size_after=$(get_dir_size "/var/log")
    local freed=$((size_before - size_after))
    TOTAL_FREED=$((TOTAL_FREED + freed))
    print_success "系统日志清理完成，释放空间: ${freed} MB"
}

################################################################################
# 主程序
################################################################################

main() {
    clear
    print_separator
    echo -e "${GREEN}Linux 系统清理工具${NC}"
    print_separator
    
    # 检查 root 权限
    check_root
    
    # 显示初始磁盘使用情况
    print_info "当前磁盘使用情况: $(get_disk_usage)"
    print_info "日志文件: $LOG_FILE"
    echo ""
    
    # 显示将要执行的清理项目
    print_info "将执行以下清理操作："
    echo "  1. 包管理器缓存"
    echo "  2. 临时文件 (/tmp, /var/tmp)"
    echo "  3. 用户缓存目录 (~/.cache)"
    echo "  4. 缩略图缓存"
    echo "  5. 系统日志文件"
    echo ""
    
    # 用户确认
    read -p "$(echo -e ${YELLOW}是否继续？[y/N]:${NC} )" -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "操作已取消"
        exit 0
    fi
    
    # 记录开始时间
    local start_time=$(date +%s)
    
    # 执行清理操作
    clean_package_cache
    clean_temp_files
    clean_user_cache
    clean_thumbnails
    clean_system_logs
    
    # 计算耗时
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # 显示总结
    print_separator
    print_success "清理完成！"
    print_separator
    print_info "总共释放空间: ${TOTAL_FREED} MB ($(echo "scale=2; $TOTAL_FREED/1024" | bc) GB)"
    print_info "清理后磁盘使用: $(get_disk_usage)"
    print_info "耗时: ${duration} 秒"
    print_info "详细日志: $LOG_FILE"
    print_separator
}

# 执行主程序
main "$@"

