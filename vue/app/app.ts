import Vue from 'nativescript-vue'
import Login from './components/Login.vue'
import Home from './components/Home.vue'
import authService from './services/auth.service'

declare let __DEV__: boolean;

// Ошибка 1: silent - используем приведение типа
(Vue.config as any).silent = !__DEV__

async function startApp() {
  const session = await authService.getSession();
  const initialComponent = session ? Home : Login;

  // Ошибки 2 и 3: конструктор и параметр h
  const app = new (Vue as any)({
    render: (h: any) => h('frame', [h(initialComponent)]),
  });
  app.$start();
}

startApp();