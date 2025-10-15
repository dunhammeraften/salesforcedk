import { LightningElement, api, track } from "lwc";
import updateProduct from "@salesforce/apex/HomeOfficeController.updateProduct";
import updateVAS from "@salesforce/apex/HomeOfficeController.updateVAS";
import HONoResultsFound from "@salesforce/label/c.HONoResultsFound";
import HOFixedIP from "@salesforce/label/c.HOFixedIP";
import HOEmployeeIDLabel from "@salesforce/label/c.HOEmployeeIDLabel";

const customLabel = {
	HONoResultsFound,
	HOFixedIP,
	HOEmployeeIDLabel
}

export default class LocationLineProductQualification extends LightningElement {
	labels = customLabel;
	renderFlow = false;
	@api POQ_Items;
	@api LocationLines;
	@track wired_POQ_Items;
	@track wired_LocationLines;
	@api OpportunityID;
	@api HomeOfficeProductOptionsRanking;

	proxyToObj(obj) {
		try {
			return JSON.parse(JSON.stringify(obj));
		} catch (err) {
			console.log(err);
		}
	}

	updateUI(locationLineID, productCode) {
		try {
			// var spans_tech = this.template.querySelector('span.tech[data-id=' + locationLineID + ']');
			var spans_static = this.template.querySelector("span.static[data-id=" + locationLineID + "]");
			// var cbox_tech = spans_tech.querySelector('lightning-input[data-id=' + locationLineID + ']');
			var cbox_static = spans_static.querySelector("lightning-input[data-id=" + locationLineID + "]");

			const staticUnsupported = ["COAHOF02", "COAHOF03", "COAHOF04"];
			if (staticUnsupported.includes(productCode)) {
				cbox_static.disabled = true;
			} else {
				console.log("Supported!");
				cbox_static.disabled = false;
			}
			cbox_static.checked = false;

			// const technicianRequired = ['FIBHOF02', 'FIBHOF03'];
			// if (technicianRequired.includes(productCode)) {
			//     console.log('Required!')
			//     cbox_tech.checked = true;
			//     cbox_tech.disabled = true;
			// } else {
			//     console.log('Not Required!');
			//     cbox_tech.disabled = false;
			//     cbox_tech.checked = false;
			// }
		} catch (err) {
			console.log(err);
		}
	}

	handleChange(event) {
		console.log(this.wired_LocationLines);
		console.log(event.target.dataset.id);
		try {
			updateProduct({ locationLine: event.target.dataset.id, productCode: event.detail.value });
		} catch (err) {
			console.log(err);
			console.log("updateProduct FAILED)");
		}
		this.updateUI(event.target.dataset.id, event.detail.value);
		console.log(event.detail.value);
		console.log(event.target.dataset.id);
	}

	// checkboxChangeTech(event) {
	//     console.log(event.target.checked);
	//     console.log(event.target.dataset.id); // Location Line ID
	//     updateOTC({locationLine: event.target.dataset.id, technician: event.target.checked});
	// }

	checkboxChangeStatic(event) {
		console.log(event.target.checked);
		console.log(event.target.dataset.id);
		updateVAS({ locationLine: event.target.dataset.id, staticIP: event.target.checked });
	}

	renderedCallback() {
		var cboxes = this.template.querySelectorAll("lightning-combobox");
		for (let cbox of cboxes) {
			try {
				this.updateUI(cbox.getAttribute("data-id"), cbox.value);
			} catch (err) {
				console.log(err);
			}
		}
		console.log("rendered");
	}

	connectedCallback() {
		this.wired_LocationLines = this.proxyToObj(this.LocationLines);
		try {
			this.wired_POQ_Items = this.proxyToObj(this.POQ_Items);
		} catch (err) {
			console.log(err);
		}

		console.log("Check 1");
		try {
			if (this.wired_POQ_Items != undefined) {
				for (let item of this.wired_POQ_Items) {
					for (let line of this.wired_LocationLines) {
						if (line.hasOwnProperty("options") == false) {
							line.options = [];
						}
						if (line.Id == item.Location_Line__c) {
							var option = {
								value: item.priceplanCode__c,
								label: item.Pseudo_Product__c,
								rank: item.Rank__c
							};
							line.options.push(option);
						}
					}
				}
			}
		} catch (err) {
			console.log(err);
		}

		console.log("Check 2");

		for (let line of this.wired_LocationLines) {
			try {
				if (line.options.length > 1) {
					line.options = line.options.filter(function (obj) {
						return obj.value !== "DSLHOF01";
					});
				}

				line.options.sort((a, b) => a.rank - b.rank);

				// LOOK FOR PREFERENCE LIST HERE!!!!!!
				if (this.HomeOfficeProductOptionsRanking != undefined) {
					var order = this.HomeOfficeProductOptionsRanking.split("|");
					var sorted = line.options.sort((a, b) => {
						const indexA = order.findIndex((sequence) => String(a.rank) === sequence);
						const indexB = order.findIndex((sequence) => String(b.rank) === sequence);
						return indexA - indexB;
					});
					console.log("line.options");
					console.log(line.options);
				} else {
					console.log("Not sorting");
				}

				// console.log('line.options:', line.options);
				try {
					line.priceplanCode__c = line.options[0].value; // UI Product Set for Line
				} catch (err) {
					console.log(err);
				}

				console.log("line.id:", line.Id);
				line.ResultsExist = true;
				updateProduct({ locationLine: line.Id, productCode: line.options[0].value }); // Backend Product Set for Line
			} catch (err) {
				console.log("lime failed: " + err);
				console.log("lime failed: " + line.Id);
				line.ResultsExist = false;
			}
		}

		this.renderFlow = true;
	} // connectedCallback
}