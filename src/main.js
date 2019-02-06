// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
/* eslint-disable */
import Vue from 'vue'
import App from './App'
import router from './router'
import BootstrapVue from 'bootstrap-vue'
import sharedUI from 'shared-ui'
import axios from 'axios'
import CollectionEntry from '@/components/CollectionEntry'

import { store } from './store/store'

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

Vue.use(BootstrapVue)
// register shared-ui component
Vue.use(sharedUI)
// register components globally
Vue.component('collection-entry', CollectionEntry)

Vue.config.productionTip = false
axios.defaults.timeout = 15000;

/* eslint-disable no-new */
new Vue({
  el: '#app',
  data () {
    return {
    }
  },
  store: store,
  router,
  template: '<App/>',
  components: {
    App
  },
  created() {
    this.$store.dispatch('refreshCollections')
  }
})
