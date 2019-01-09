<template>
<div>

  <b-list-group>
    <b-list-group-item class="flex-column align-items-start" v-for="(collection) in collections" v-bind:key="collection._id"
      v-bind:id="'collection-'+collection._id">
      <div class="d-flex align-items-center justify-content-between">
        <h4 class="mb-1">{{collection.name}}</h4>
        <div>
          <b-btn variant="outline-primary" class="ml-auto" @click="preremove(collection)">Delete Collection</b-btn>
          <b-btn variant="outline-primary" class="ml-auto" @click="prestore(collection)">Store Collection</b-btn>
        </div>
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
    <b-form-select v-model="selected" :options="[{value:null, text:'Please select a provider'},{value:'a', text:'WebDAV'}]" class="mb-3" />
  </b-modal>

  <b-modal ref="noDataModal" title="No storeable data found" :ok-only="true" size="lg" @ok="$refs.noDataModal.hide()">
    The collection you chose does not provide any downloadable data sets.
  </b-modal>

  <b-modal ref="deletionConfirmationModal" title="Confirm deletion of collections"
  ok-title="Delete" size="lg" @cancel="remove(false)" @ok="remove(true)">

    <div v-if="collectionsSelectedForDeletion.length === 1">
      This collection will be deleted: <br>
      {{ collectionsSelectedForDeletion[0].name }}
    </div>

    <div v-else>
      The following collections will be deleted:
      <ul>
        <li v-for="collection in collectionsSelectedForDeletion">{{collection.name}}</li>
      </ul>
    </div>

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
      collectionsSelectedForDeletion: [],
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
      axios.post('/api/v1/store/', self.storeData)
        .then(function (response) {
          location.href='/store/files/' + response.data.sessionId
        })
        .catch(function (error) {
          console.error(error)
        });
    },

    preremove(collection) {
      const self = this
      self.collectionsSelectedForDeletion.push(collection)
      self.$refs.deletionConfirmationModal.show()
    },

    remove(confirm) {
      const self = this

      if (confirm === true) {
        for (var i = 0; i < self.collectionsSelectedForDeletion.length; i++) {
          axios.delete('/api/v1/collections/' + usercookie.getUsername() + '/' + self.collectionsSelectedForDeletion[i]._id)
          .then( function (response) {
            // Nothing to be done
          })
          .catch( function (error) {
            console.error(error)
          })
        }
        this.getCollections()
      }

      self.collectionsSelectedForDeletion = []
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
