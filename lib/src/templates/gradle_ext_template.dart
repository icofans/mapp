String gradleExtTemplate(String projectName) {
  return '''
// android项目的一些配置
ext {
  android = [
      compileSdkVersion: 29,
      minSdkVersion: 19,
      targetSdkVersion: 29,
      ndk: {
        abiFilters 'armeabi-v7a','arm64-v8a'
      }
  ]
  
  signingConfigs = [
    debug: {
        // keyAlias "demo"
        // keyPassword "demo"
        // storeFile file("./demo.jks")
        // storePassword "demo"
    },
    release: {
        // keyAlias "demo"
        // keyPassword "demo"
        // storeFile file("./demo.jks")
        // storePassword "demo"
    }
  ]
  manifestPlaceholders = [
    // 只是一个示例
    XG_ACCESS_ID : "",
  ]
  dependencies = {
    // implementation 'com.android.support:multidex:1.0.3'
  }
}
  ''';
}
