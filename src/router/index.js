/* eslint-disable */
import Vue from 'vue'
import Router from 'vue-router'

// Search Components

// Bookmark Components
import Collections from '@/components/Collections'

// Statical UI Elements Components
// import Start from '@/components/Start'

Vue.use(Router)

export default new Router({
  mode: 'history',
  routes: [
  { path: '/bookmark',
    name: 'collections',
    component: Collections,
    }
  ]
})
