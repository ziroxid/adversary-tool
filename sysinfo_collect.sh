#!/bin/bash

OUTPUT_FILE="${1:-sysinfo.txt}"
exec > >(tee "$OUTPUT_FILE") 2>&1

echo "$SEP"
echo " collect system information - $(date)"

# ------------------------------------
# T1082 - System Information Discovery
# ------------------------------------
echo -e "\n[T1082] 시스템 정보 "
echo "$DIV"
uname -e
cat /etc/os-release 2>/dev/null
hostnamectl 2>/dev/null
cat /proc/version 2>/dev/null
cat /proc/cpuinfo 2>/dev/null | grep "model name" | head -1
cat /proc/meminfo 2>/dev/null | grep -E "MemTotal|MemFree|MemAvailable"
df -h
uptime
dmesg | tail -20 2>/dev/null

# ------------------------------------
# T1033 - System Owner/User Discovery
# ------------------------------------
echo -e "\n[T1033] 사용자 정보"
echo "$DIV"
whoami
id
whoamiw
last | head -20
lastlog 2>/dev/null | head -20

# ------------------------------------
# T1087 - Account Discovery
# ------------------------------------
echo -e "\n[T1087] 계정 목록"
echo "$DIV"
cat /etc/passwd
cat /etc/shadow 2>/dev/null
cat /etc/group
grep -E 'sudo|wheel' /etc/group 2>dev/null
grep -v '/nologin\|/false' /etc/passwd

# ------------------------------------
# T1069 - Permission Groups Discovery
# ------------------------------------
echo -e "\n[T1069] 권한 그룹"
echo "$DIV"
groups
getent group 2>/dev/null
cat /etc/sudoers 2>/dev/null
ls -la /etc/sudoers.d/ 2>/dev/null
find /home -name ".ssh" -type d 2>/dev/null
find /root -name ".ssh" -type d 2>/dev/null

# ------------------------------------
# T1057 - Process Discovery
# ------------------------------------
echo -e "\n[T1057] 프로세스 목록"
echo "$DIV"
ps aux
ps -ef
ps aux | grep root
find /proc -maxdepth 1 -type d -name '[0-9]*' 2>/dev/null | while read pid; do
    cat "$pid/cmdline" 2>/dev/null | tr '\0' ' '
    echo
done | sort -u | head -50

# ------------------------------------
# T1007 - System Service Discovery
# ------------------------------------
echo -e "\n[T1007] 서비스 목록"
echo "$DIV"
systemctl list-units --type=service 2>/dev/null
systemctl list-units --type=service --state=running 2>/dev/null
service --status-all 2>/dev/null
chkconfig --list 2>/dev/null

# ------------------------------------
# T1016 - System Network Configuration Discovery
# ------------------------------------
echo -e "\n[T1016] 네트워크 설정"
echo "$DIV"
ifconfig 2>/dev/null || ip addr
ip route 2>/dev/null || route -n
cat /etc/resolv.conf
cat /etc/hosts
arp -a 2>/dev/null
ip neigh 2>/dev/null
# 공인 IP
curl -s ifconfig.me
echo ""
# 방화벽 규칙
iptables -L -n 2>/dev/null
iptables -t nat -L -n 2>/dev/null
firewall-cmd --list-all 2>/dev/null


# ------------------------------------
# T1049 - System Network Connection Discovery
# ------------------------------------
echo -e "\n[T1049] 네트워크 연결"
echo "$DIV"
netstat -an 2>/dev/null | grep -i listen
netstat -an 2>/dev/null | grep -i established
netstat -tulpn 2>/dev/null
ss -tulpn 2>/dev/null
lsof -i 2>/dev/null

# ------------------------------------
# T1083 - File and Directory Discovery
# ------------------------------------
echo -e "\n[T1083] 파일 및 디렉터리"
echo "$DIV"
ls -lhart
ls -lhart /home 2>/dev/null
ls -lhart /root 2>/dev/null
ls -lhart /tmp 2>/dev/null
ls -lhart /var/tmp/ 2>/dev/null
# SUID/SGID 파일 탐색
find / -perm -4000 -type f 2>/dev/null
find / -perm -2000 -type f 2>/dev/null
# 최근 수정된 파일 (24시간 이내)
find / -mtime -l -type f 2>/dev/null | grep -v proc | head -30
# 숨김 파일 검색
find /home /root /tmp -name ".*" -type f 2>/dev/null
# 민감 파일 탐색
find / -name "*.pem" -o -name "*.key" -o -name "id_rsa" -o -name "*.conf" 2>/dev/null | head -30

# ------------------------------------
# T1518 - Software Discovery
# ------------------------------------
echo -e "\n[T1518] 설치된 소프트웨어"
echo "$DIV"
rpm -qa 2>/dev/null
dpkg --list 2>/dev/null
pip list 2>/dev/null
pip3 list 2>/dev/null
# 보안 소프트웨어 탐지
ps aux | grep -iE 'antivirus|crowdstrike|falcon|defender|clamav|ossec|wazuh|aide'
find /opt /usr/local -maxdepth 2 -type d 2>/dev/null

# 추가
cat ~/.bash_history 2>/dev/null