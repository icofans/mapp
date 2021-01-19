# 项目说明

基于 dart 实现的 flutter 脚手架

### 安装

安装 mapp 至全局

```
dart pub global activate -sgit https://github.com/icofans/mapp.git
```

如果提示如下,则需要配置环境变量

```
Warning: Pub installs executables into $HOME/.pub-cache/bin, which is not on your path.
You can fix that by adding this to your shell's config file (.bashrc, .bash_profile, etc.):

  export PATH="$PATH":"$HOME/.pub-cache/bin"

```

打开或创建您使用的 shell 的 rc 文件，比如 ~/.bashrc、~/.zshrc 等,添加以下文件

```
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

执行使其生效

```
source ~/.zshrc
```

### 使用

使用 mapp 创建 xxx_app,根据提示配置包名等

```

mapp create xxx_app

```

### 移除

```

dart pub global list
dart pub global deactivate mapp

```

### 功能

通过远程模版创建一个新项目,可以指定一些简单的配置参数

### Features

- 可以动态配置是否生成某模块
- 单独生成项目中使用的单文件
- ......
