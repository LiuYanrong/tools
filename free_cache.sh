#!/bin/bash
	# 清理之前显示内存使用情况
	echo "清理之前:"
	free -m

	# 每一小时清除一次缓存
	echo "开始清除缓存..."
	sync;sync;sync #写入硬盘，防止数据丢失

	sleep 10 #延迟10秒
	echo 1 > /proc/sys/vm/drop_caches
	echo 2 > /proc/sys/vm/drop_caches
	echo 3 > /proc/sys/vm/drop_caches
	echo "清理完成."

	# 清理之后显示内存使用情况
	echo "清理之后:"
	free -m
