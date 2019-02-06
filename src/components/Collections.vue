<template>
<div>
  <b-list-group>
    <b-list-group-item class="flex-column align-items-start" v-for="(collection) in collections" v-bind:key="collection._id"
      v-bind:id="'collection-'+collection._id">
      <div class="d-flex w-100 justify-content-between">
        <h4 class="mb-1">{{collection.name}}</h4>
        <b-btn variant="outline-primary" class="ml-auto" @click="prestore(collection)">Store Collection</b-btn>
      </div>
      <collection-entry :collection="collection"></collection-entry>
    </b-list-group-item>
  </b-list-group>
  <b-modal ref="myModalRef" title="Store selected data sets" ok-title="Store" size="lg" @ok="store()">
    Following data sets are selected for storage:
    <ul>
      <li v-for="it in storeData.docs">{{ it.split('/').pop() }}</li>
    </ul>
    Please select a storage provider to proceed:
    <b-form-select v-model="selected" :options="[{value:null, text:'Please select a provider'},{value:'a', text:'WebDAV'},{value:'b', text:'Jupyter Hub'}]" class="mb-3" />
  </b-modal>
  <b-modal ref="noDataModal" title="No storeable data found" :ok-only="true" size="lg" @ok="$refs.noDataModal.hide()">
    The collection you chose does not provide any downloadable data sets.
  </b-modal>
</div>
</template>

<script>
/* eslint-disable */

import axios from 'axios'
import usercookie from '../util/usercookie.js'
export default {
  name: 'collections',
  props: ['datasets'],
  data() {
    return {
      selected: null,
      collections: [],
      storeData: {
       'bookmarkId': null,
       'bookmarkName': null,
       'docs': [],
       'userId': null
      }
    }
  },

  created() {
    this.getCollections()
  },

  methods: {
    getCollections() {
      const self = this
      self.collections = []
      axios.get('/api/v1/collections/' + usercookie.getUsername())
        .then(function (response) {
          self.collections = response.data
        })
        .catch(function (error) {
          self.errMsg = error.response;
        });
    },
    prestore(collection) {
      const self = this
      axios.get('/api/v1/collections/' + usercookie.getUsername() + '/' + collection._id)
        .then(function (response) {
          let links = []
          response.data.forEach(function(elem){
            if (elem._source && elem._source.researchDataList) {
              let dataList = elem._source.researchDataList
              dataList.forEach(function(dataElem){
                links.push(dataElem.researchDataURL)
              })
            }
          })
          self.storeData.docs = links
          self.storeData.bookmarkId = collection._id
          self.storeData.bookmarkName = collection.name
          self.storeData.userId = usercookie.getUsername()
          if (links.length) {
            self.$refs.myModalRef.show()
          } else {
            self.$refs.noDataModal.show()
          }
        })
        .catch(function (error) {
          console.error(error)
        });
    },
    store(){
      const self = this
      var subdomain
      if (selected == 'a') {
        subdomain = 'store'
      } else {
        subdomain = 'store-jhub'
      }
      axios.post('/api/v1/' + subdomain + '/', self.storeData)
        .then(function (response) {
          location.href='/' + subdomain + '/files/' + response.data.sessionId
        })
        .catch(function (error) {
          console.error(error)
        });
    }
  }
}
</script>

<style scoped>
h4 {
  color: #43a59f;
}
.list-group{
  margin-top: 20px;
  margin-bottom: 20px
}
</style>
