const webpack = require('@nativescript/webpack');

module.exports = (env) => {
  webpack.init(env);
  
  // Полностью заменяем обработку Vue файлов
  webpack.chainWebpack(config => {
    // Удаляем существующие правила для Vue
    config.module.rules.delete('vue');
    
    // Добавляем своё правило
    config.module
      .rule('vue')
      .test(/\.vue$/)
      .use('vue-loader')
      .loader(require.resolve('vue-loader'))
      .options({
        compilerOptions: {
          whitespace: 'condense',
          preserveWhitespace: false
        },
        hotReload: false // Отключаем hot reload для стабильности
      });
    
    // Настройка алиасов
    config.resolve.alias
      .set('vue', 'nativescript-vue');
  });
  
  return webpack.resolveConfig();
};