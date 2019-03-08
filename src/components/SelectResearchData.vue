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
              <b-button disabled variant="outline-primary">  Store data </b-button>
            </div>
            <div>
              <form method="get" :action="selectedResearchData.researchDataURL">
                <b-button        variant="outline-primary" type="submit" > Download data </b-button>
              </form>
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
        <b> Note: </b> If you download the research data you will leave the support of GeRDI: You will not be able to access it through the Process/Analyze service. Consider storing it to web instead.
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
      selectedResearchDataIndex: 1
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
