String flutterwTemplate({
  String distributionUrl = 'https://github.com/flutter/flutter.git',
  String version = "1.22.5",
  String channel = 'stable',
}) {
  return '''
#!/usr/bin/env bash

# 修改flutter版本号
flutter_version="$version"
distribution_url="$distributionUrl"
flutter_channel="$channel"

bash_path=\$(cd `dirname \$0`; pwd) # work_path=\$(pwd)
download_dir="\$bash_path/.flutter"

# 初始化命令
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
if [[ "\$(uname)" == *NT* ]] #判断是否是Windows系统，嵌套中括号是支持正则使用
then
    flutter_command="\$download_dir/bin/flutter.bat"
    dart_command="\$download_dir/bin/cache/dart-sdk/bin/dart.exe"
else
    flutter_command="\$download_dir/bin/flutter"
    dart_command="\$download_dir/bin/cache/dart-sdk/bin/dart"
fi

# 执行方法封装，支持flutterw dart 来运行dart文件
execFlutter() {
if [[ \$1 == "dart" ]]
then
    str=\$*
    substr=\${str:4}
    \$dart_command \$substr
else
    \$flutter_command \$*
fi
}

# 更新dart sdk、处理 pub
handleSDK() {
	# 下载 或 更新 dart sdk
    \$flutter_command doctor
    # 获取版本号
    curflutter_version=`\$flutter_command --version | grep '^Flutter' | cut -d ' ' -f2`
    # 更新.android、.ios内部的flutter sdk路径
    \$flutter_command pub get
    echo "Flutter SDK 下载成功：\$curflutter_version"
}

# 下载 https://ec2-13-250-177-223.ap-southeast-1.compute.amazonaws.com
if [ ! -d \$download_dir ]
then
    echo "Flutter SDK安装路径: \$download_dir"
    mkdir \$download_dir
fi

if [ ! -r \$flutter_command ]
then
    echo "开始下载Flutter SDK：git clone -b \$flutter_channel \$distribution_url \$download_dir"
    git clone -b \$flutter_channel \$distribution_url \$download_dir
    if [ -r \$flutter_command ]
    then
        handleSDK
    else
        echo "Flutter SDK 下载失败"
        exit -1
    fi
fi

cur_flutter_version=`\$flutter_command --version | grep '^Flutter' | cut -d ' ' -f2`

# 切换版本
if [ \$cur_flutter_version == \$flutter_version ]
then
    execFlutter \$*
else    
    # \$flutter_command upgrade
    echo "当前版本为 \${cur_flutter_version}，切换版本为：\${flutter_version}"
	(cd \$download_dir && git reset --hard HEAD)
    \$flutter_command channel \$flutter_channel
    (cd \$download_dir && git reset --hard HEAD) 
	# (cd \$download_dir && git checkout "v\$flutter_version")
    yes | \$flutter_command version \$flutter_version
    # yes | \$flutter_command downgrade \$flutter_version
	# 预处理SDK
	handleSDK
    # 判断切换版本是否成功
    cur_flutter_version=`\$flutter_command --version | grep '^Flutter' | cut -d ' ' -f2`
    if [ \$cur_flutter_version == \$flutter_version ]
    then
        execFlutter \$*
    else
        echo "切换版本失败"
    fi
fi
  ''';
}
