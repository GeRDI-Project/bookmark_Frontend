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
						<b-button disabled variant="outline-primary">  &#x2b06 Store </b-button>
						<!-- A href looking like a button which suffices for a single dataset to be downloaded -->
						<a :href="selectedResearchData.researchDataURL" target="_blank" class="btn btn-md btn-outline-primary">&#x2b07 Download</a>
					</b-button-group>
				</b-col>
				<b-col>
					<div v-if="isOneResearchDataGiven">
						One dataset available:
					</div> <div v-else>
						1 of available {{ researchDataList.length + " datasets" }} selected: <br>
					</div>

					<!-- The form is not yet "multiple" -->
					<b-form-select
						:disabled="isOneResearchDataGiven"
						v-model="selectedResearchDataIdentifier"
						value-field="researchDataIdentifier"
						text-field="researchDataLabel"
						:options="researchDataList"
					/>
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
		selectedResearchDataIdentifier: null
	}
  },

  created() {   
    if (typeof(this.researchDataList) !== 'undefined') {
    	this.$data.selectedResearchDataIdentifier = this.researchDataList[0].researchDataIdentifier
    }
  },

  computed: {
  	isOneResearchDataGiven: function () { return this.researchDataList.length === 1 },
  	selectedResearchData: function () {
		for(var i = 0; i < this.researchDataList.length; i++) {
			if (this.$data.selectedResearchDataIdentifier === this.researchDataList[i].researchDataIdentifier) {
				return this.researchDataList[i]
			}
		}
  	}
  }

}
</script>


<style scoped>
	/* No changes in this component */
</style>
