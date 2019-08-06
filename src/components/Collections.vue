<template>
  <div v-if="(!loaded || collections === null) && !(loaded && user === null)">
    <b-list-group>
      <b-list-group-item v-for="i in 5" :key="i">
        <ContentLoader class="test" :width="1110" :height="80">
          <rect x="0" y="0" rx="3" ry="3" width="130" height="34" />
          <rect x="810" y="0" rx="0" ry="0" width="285" height="38" />
          <rect x="10" y="48" rx="0" ry="0" width="110" height="44" />
        </ContentLoader>
      </b-list-group-item>
    </b-list-group>
  </div>
  <div v-else-if="collections !== null && collections.length === 0 && user !== null">
    <b-alert show variant="secondary">You have no Collections stored yet.</b-alert>
  </div>
  <div v-else-if="collections !== null && collections.length > 0 && user !== null">
    <b-list-group>
      <b-list-group-item class="flex-column align-items-start" v-for="(collection) in collections" v-bind:key="collection.id" v-bind:id="'collection-'+collection.id">
        <div class="d-flex w-100 justify-content-between">
          <h4 class="mb-1">{{collection.name}}</h4>
          <b-button-group>
            <b-btn variant="outline-primary" class="ml-auto" :id="'del_coll_btn'+collection.id"> Delete Collection </b-btn>
            <b-btn variant="outline-primary" class="ml-auto" @click="prestore(collection)"> Store Collection </b-btn>
            <b-popover :title='"<h4>" + collection.name + "</h4>"' :target="'del_coll_btn'+collection.id" :ref="'collection_deletion_confirmation'+collection.id" placement="bottom" triggers="click blur">
              <b-btn variant="secondary" @click="closePopover('del_coll_btn'+collection.id)"                    > Cancel </b-btn>
              <b-btn variant="primary"   @click="closePopover('del_coll_btn'+collection.id); remove(collection)"> Delete permanently</b-btn>
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
      <b-form-select v-model="selected" :options="options" class="mb-3" />
    </b-modal>
    <b-modal centered ref="noDataModal" title="No storeable data found" :ok-only="true" size="lg" @ok="$refs.noDataModal.hide()">
      The collection you chose does not provide any downloadable data sets.
    </b-modal>
  </div>
  <div v-else>
    <b-alert show variant="warning">You are not logged in. Please log in to use this feature.</b-alert>
  </div>
</template>

<script>
/* eslint-disable */
import { ContentLoader } from 'vue-content-loader'
import axios from 'axios'
export default {
  name: 'collections',
  props: ['datasets'],
  components: {
    ContentLoader
  },
  data() {
    return {
      loaded: false,
      selected: null,
      storeData: {
        'bookmarkId': null,
        'bookmarkName': null,
        'docs': [],
        'userId': null
      },
      options: [
        { value: null, text:'Please select a provider'}
      ]
    }
  },
  created() {
    const self = this
    //TODO: correct url for zuul
    axios.get('/api/v1/services/store')
      .then(function (response) {
        self.options = self.options.concat(response.data);
      })
      .catch(function (error) {
        console.error(error)
      });
  },
  watch: {
    isChecked: function () {
      var self = this
      this.$store.dispatch('refreshCollections', { vm: this }).then(function () {self.loaded = true })
    }
  },
  computed: {
    isChecked: function () {
      return this.$gerdi.aai.isChecked()
    },
    isLoading () {
      return this.$store.getters.isLoading
    },
    collections () {
      return this.$store.getters.getCollectionList
    },
    user () {
      return this.$gerdi.aai.getUser()
    }
  },
  methods: {
    prestore(collection) {
      const self = this
      axios.get('/api/v1/collections/' + collection.id,{
          headers: {'Authorization': "Bearer " + self.$gerdi.aai.getIdToken()}
        })
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
          self.storeData.userId = self.$gerdi.aai.getUser().sub
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
      var subdomain = this.selected
      if (subdomain === null) {
        return
      }
      axios.post('/api/v1' + subdomain + '/', self.storeData)
        .then(function (response) {
          location.href = subdomain + '/files/' + response.data.sessionId
        })
        .catch(function (error) {
          console.error(error)
        });
    },

    remove(collection) {
      this.$store.dispatch('deleteCollection', {
        collectionID: collection.id,
        vm: this
      })
    },

    closePopover(id) {
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
