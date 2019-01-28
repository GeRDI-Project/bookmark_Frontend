<template>
  <div>
    <b-list-group>
      <b-list-group-item class="flex-column align-items-start" v-for="(collection) in collections" v-bind:key="collection.id" v-bind:id="'collection-'+collection.id">
        <div class="d-flex w-100 justify-content-between">
          <h4 class="mb-1">{{collection.name}}</h4>
          <div>
            <b-btn variant="outline-primary" class="ml-auto" @click="preremove(collection)">Delete Collection</b-btn>
            <b-btn variant="outline-primary" class="ml-auto" @click="prestore(collection)">Store Collection</b-btn>
          </div>
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
      <b-form-select v-model="selected" :options="[{value:null, text:'Please select a provider'},{value:'a', text:'WebDAV'}]" class="mb-3" />
    </b-modal>
    <b-modal centered ref="noDataModal" title="No storeable data found" :ok-only="true" size="lg" @ok="$refs.noDataModal.hide()">
      The collection you chose does not provide any downloadable data sets.
    </b-modal>
    <b-modal centered ref="deletionConfirmationModal" title="Delete collection" ok-title="Delete" size="lg" @ok="remove()">
      The collection <b>"{{ collectionSelectedForDeletion == null ? "undefined" : collectionSelectedForDeletion.name }}"</b> will be deleted permanently.
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
      collectionSelectedForDeletion: null,
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
      axios.post('/api/v1/store/', self.storeData)
        .then(function (response) {
          location.href='/store/files/' + response.data.sessionId
        })
        .catch(function (error) {
          console.error(error)
        });
    },

    preremove(collection) {
      this.collectionSelectedForDeletion = collection
      this.$refs.deletionConfirmationModal.show()
    },

    remove() {
      this.$store.dispatch('deleteCollection', {
        collectionID: this.collectionSelectedForDeletion.id
      })
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
