<template>
  <div>
    <div v-if="typeof(researchDataList) === 'undefined'">
      <b-alert show variant="info">
        No datasets directly accessible.
      </b-alert>
    </div>
    <div v-else>
      <b-container>
        <b-row>
          <b-col md="auto" id="horizontal_ruler_below">
            <div id="spacer_below">
              <b-button variant="outline-primary btn-block" disabled>  Store data </b-button>
            </div>
            <div>
              <b-button variant="outline-primary btn-block" :href="selectedResearchData.researchDataURL"> Download data </b-button>
            </div>
          </b-col>
          <b-col>
            <div v-if="isOneResearchDataGiven">
              One dataset available:
            </div> <div v-else>
              Select one of available {{ researchDataList.length }} datasets: <br>
            </div>
            <div id="spacer_below">
              <b-form-select v-model="selectedResearchDataIndex" :options="researchDataOptions"/>
            </div>
            <div>
              dataset file type: <strong> {{ selectedResearchData.researchDataType }} </strong>
            </div>
          </b-col>
        </b-row>
        <b> Note: </b>
          By clicking on "Download data" you will be redirected to the original data provider. Data files will be loaded onto your local machine without any further support from GeRDI infrastructure services. If you still want to make use of GeRDI infrastructure services including analyze service, please consider storing the data via the GeRDI store service.
      </b-container>
    </div>
  </div>
</template>


<script>
/* eslint-disable */
export default {
  name: 'storing-research-data-selection',
  props: ['researchDataList'],

  data: function () {
    return {
      selectedResearchDataIndex: 0
    }
  },

  created() {
    if (typeof(this.researchDataList) === 'undefined') {
      this.selectedResearchDataIndex = null;
    }
  },

  computed: {
    isOneResearchDataGiven: function () { return this.researchDataList.length === 1 },
    selectedResearchData: function() {
      return this.researchDataList[this.selectedResearchDataIndex]
    },
    researchDataOptions: function() {
      return Array.from(this.researchDataList).map((value, index) => ({ value: index, text: value.researchDataLabel}));
    }
  }
}
</script>


<style scoped>
#horizontal_ruler_below {
  border-bottom: 1px solid rgba(0, 0, 0, 0.125);
  margin-bottom: 1rem;
  padding-bottom: 1rem;
}
#spacer_below {
  padding-bottom: 0.5rem;
}
</style>
