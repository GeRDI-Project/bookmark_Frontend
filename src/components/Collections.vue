<template>
  <div>
    <b-list-group>
      <b-list-group-item class="flex-column align-items-start" v-for="(collection) in collections" v-bind:key="collection.id" v-bind:id="'collection-'+collection.id">
        <div class="d-flex w-100 justify-content-between">
          <h4 class="mb-1">{{collection.name}}</h4>
          <b-button-group>
            <b-btn variant="outline-primary" class="ml-auto" :id="'del_coll_btn'+collection.id"> Delete Collection </b-btn>
            <b-btn variant="outline-primary" class="ml-auto" @click="prestore(collection)"> Store Collection </b-btn>
            <b-popover :title='"<h4>" + collection.name + "</h4>"' :target="'del_coll_btn'+collection.id" :ref="'collection_deletion_confirmation'+collection.id" placement="bottom" triggers="click blur">
              <b-btn variant="secondary" @click="close_popover('del_coll_btn'+collection.id)"                    > Cancel </b-btn>
              <b-btn variant="primary"   @click="close_popover('del_coll_btn'+collection.id); remove(collection)"> Delete permanently</b-btn>
            </b-popover>
          </b-button-group>
        </div>
        <collection-entry :collection="collection"></collection-entry>
      </b-list-group-item>
    </b-list-group>
    <b-modal centered ref="myModalRef" title="Store selected data sets" ok-title="Store" size="lg" @ok="store()">
      Following data sets are selected for storage:
      <ul>
        <li v-for="it in storeData.docs">{{ it.split('/').pop() }}</li>
      </ul>
      Please select a storage provider to proceed:
      <b-form-select v-model="selected" :options="[{value:null, text:'Please select a provider'},{value:'a', text:'WebDAV'},{value:'b', text:'Jupyter Hub'}]" class="mb-3" />
    </b-modal>
    <b-modal centered ref="noDataModal" title="No storeable data found" :ok-only="true" size="lg" @ok="$refs.noDataModal.hide()">
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
      collections: this.$store.getters.getCollectionList,
      storeData: {
        'bookmarkId': null,
        'bookmarkName': null,
        'docs': [],
        'userId': null
      }
    }
  },

  methods: {
    prestore(collection) {
      const self = this
      axios.get('/api/v1/collections/' + usercookie.getUsername() + '/' + collection.id)
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
          self.storeData.bookmarkId = collection.id
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
      if (this.selected == 'a') {
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
    },

    remove(collection) {
      this.$store.dispatch('deleteCollection', {
        collectionID: collection.id
      })
    },

    close_popover(id) {
      this.$root.$emit('bv::hide::popover', id)
    },
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
