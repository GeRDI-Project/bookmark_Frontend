<template>
  <div>
    <b-btn v-b-toggle="'datasets-'+collection.id" v-on:click="getDatasetsList(collection.id)" variant="link">
      <span class="when-opened">Hide </span>
      <span class="when-closed">Show </span>data sets</b-btn>
    <b-collapse v-bind:id="'datasets-'+collection.id" class="mt-2" accordion="datasets">
      <div v-if="datasetsForCollection !=='processing'">
        <div v-if="datasetsForCollection.length === 0">
          <b-alert show variant="info">
            This collection is empty!
          </b-alert>
        </div>
        <div v-else>
          <div class="m-2" v-for="dataset  in datasetsForCollection" :key="dataset.id" v-bind:id="'datasets-'+dataset.id">
            <b-card v-if="dataset._source">
              <document-media :doc="dataset"></document-media>
              <div slot="footer">
                <!-- Enable buttons buttons once they offer actual functionality -->
                <!--
                  <b-button-group>
                  <b-button disabled variant="link">Remove from collection</b-button>
                  <b-button disabled variant="link">More information</b-button>
                  </b-button-group>
                -->
                <select-research-data :research-data-list="dataset._source.researchDataList"></select-research-data>
              </div>
            </b-card>
            <div v-else>
              <h5>
                <b-alert show variant="info">We are sorry, but this data set is no more available.</b-alert>
              </h5>
            </div>
          </div>
        </div>
      </div>
      <div v-else>
        Loading
      </div>
    </b-collapse>
  </div>
</template>


<script>
/* eslint-disable */
import axios from 'axios'
export default {
  name: 'collection-entry',
  props: ['collection'],

  data() {
    return {
      datasets: [],
      datasetsForCollection: []
    }
  },
  created() {
    axios.defaults.timeout = 10000;
  },
  methods: {
    getTitle: function(dataset) {
      if (dataset._source.titles.length > 0) {
        return dataset._source.titles[0].value
      } else {
        return "This Document is missing"
      }
    },
    getDatasetsList: function(collectionID) {
      const self = this
      if (self.lastcollectionID && self.lastcollectionID === collectionID) {
        // this block is to ignore the api call when the datasets option is click 2nd time
        self.lastcollectionID = null
      } else {
        self.lastcollectionID = collectionID
        self.datasetsForCollection = "processing"
        axios.get('/api/v1/collections/' + this.$gerdi.aai.getUser().sub + '/' + collectionID)
          .then(function (response) {
            self.datasetsForCollection = []
            self.datasetsForCollection = response.data
          })
          .catch(function (error) {
            self.datasetsForCollection = []
            self.errMsg = error.response;
          });
      }
    },
    filterForViewURI(linksArray) {
      if(linksArray) {
        return linksArray.filter(elem => elem.webLinkType == 'ViewURL')[0].webLinkURI
      }
      return '#'
    },
    showPublicationYear(year) {
      return year
    },
    showPublisher(publisher) {
      return publisher
    },
    showDescription(description) {
      let result = description.replace(/(<([^>]+)>)/ig, '')
      let limit = 850
      if (result.length > limit) result = result.substr(0,limit) + ' [...]'
      return result
    },
    hasProviderLogo(linksArray) {
      if(linksArray) {
        let val = linksArray.filter(elem => elem.webLinkType == 'ProviderLogoURL')
        return val.length > 0
      }
      return false
    },
    getProviderLogo(linksArray) {
      let val = linksArray.filter(elem => elem.webLinkType == 'ProviderLogoURL')
      return val[0].webLinkURI
    }
  }
}
</script>


<style scoped>

.card {
  margin-top: 1rem;
}
.providerLogo {
  max-height: 100px;
  width: auto;
}
a {
  color: #43a59f;
}
.collapsed > .when-opened,
:not(.collapsed) > .when-closed {
  display: none;
}
.btn-primary-gerdi:focus, .btn-primary-gerdi:active:focus, .btn-primary-gerdi.active:focus {
  outline: 0 none;
}
.btn-primary-gerdi {
  padding: 10px 10px;
  border: 0 none;
  font-weight: 700;
  letter-spacing: 0.1px;
  outline: 0 none;
  background: transparent;
  color: #083f64;
}
.btn-primary-gerdi:hover, .btn-primary-gerdi:focus, .btn-primary-gerdi:active, .btn-primary-gerdi.active, .open > .dropdown-toggle.btn-primary-gerdi {
  background: #77d7d0;
  box-shadow: none;
}
.btn-primary-gerdi:active, .btn-primary-gerdi.active {
  background: #007299;
  box-shadow: none;
}
.btn-link {
  padding: 10px 10px;
  border: 0 none;
  font-weight: 700;
  letter-spacing: 0.1px;
  outline: 0 none;
  background: transparent;
  color: #083f64;
}
.year {
  margin-top: 20px;
}
.creators {
  margin-top: 20px;
}
.publisher {
  margin-top: 20px;
}
.descriptions {
  margin-top: 25px;
}
</style>
