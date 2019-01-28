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
          <b-col md="auto">
            <b-button-group vertical>
              <b-button disabled variant="outline-primary">  Store research data </b-button>
              <!-- A href looking like a button which suffices for a single dataset to be downloaded -->
              <a 
                :href="selectedResearchData.researchDataURL" 
                target="_blank" 
                class="btn btn-md btn-outline-primary"
                data-toggle="tooltip" 
                title="If you download the research data you will leave the support of GeRDI: You will not be able to access it through the Process/Analyze service. Consider storing it to web instead."
                >
                Download research data
              </a>
            </b-button-group>
          </b-col>
          <b-col>
            <div v-if="isOneResearchDataGiven">
              One dataset available:
            </div> <div v-else>
              Select one of available {{ researchDataList.length }} datasets: <br>
            </div>
            <!-- The form is not yet "multiple" -->
            <select v-model="selectedResearchDataIndex" :disabled="isOneResearchDataGiven" >
                <option v-for="(value, index) in researchDataList" :value="index">
                  {{ value.researchDataLabel }}
                </option> 
            </select>
            <br>
               dataset file type: <strong> {{ selectedResearchData.researchDataType }} </strong>
          </b-col>
        </b-row>
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
      selectedResearchDataIdentifier: null,
      selectedResearchDataIndex: 0
    }
  },

  created() {
    if (typeof(this.researchDataList) !== 'undefined') {
      this.selectedResearchDataIdentifier = this.researchDataList[0].researchDataIdentifier
    }
  },

  computed: {
    isOneResearchDataGiven: function () { return this.researchDataList.length === 1 },
    selectedResearchData: function() {
          return this.researchDataList[this.selectedResearchDataIndex]
    }
  }
}
</script>


<style scoped>
/* No changes in this component */
</style>
