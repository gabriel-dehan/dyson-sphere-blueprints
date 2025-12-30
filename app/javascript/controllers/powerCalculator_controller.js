import { Controller } from "stimulus"
import entityPower from "../data/entityPower.json"

// Fixed generators - only these count for generation (not fuel-dependent)
const FIXED_GENERATORS = [2203, 2205, 2213] // Wind Turbine, Solar Panel, Geothermal

export default class extends Controller {
  static targets = ["consumption", "generation"]
  static values = { summary: Object }

  connect() {
    console.log('connecting')
    console.log('Has summaryValue:', this.hasSummaryValue)
    console.log('Raw summaryValue:', this.summaryValue)
    console.log('Type:', typeof this.summaryValue)
    console.log('Keys:', Object.keys(this.summaryValue))
    this.calculate()
  }

  calculate() {
    const summary = this.summaryValue
    if (!summary) return

    let consumption = 0
    let generation = 0
    console.log("entities", this.summaryValue)

    // Calculate from buildings and inserters
    for (const category of ["buildings", "inserters"]) {
      const entities = summary[category] || {}
      for (const [entityId, data] of Object.entries(entities)) {
        const power = entityPower[entityId]
        if (!power) continue

        const workPower = power.work * data.tally
        console.log(data, "workPower", workPower)
        if (workPower > 0) {
          consumption += workPower
        } else if (FIXED_GENERATORS.includes(parseInt(entityId))) {
          generation += Math.abs(workPower)
        }
      }
    }

    // Display results
    console.log(consumption, generation)
    if (consumption > 0 && this.hasConsumptionTarget) {
      this.consumptionTarget.innerHTML = `<strong>${this.formatPower(consumption)}</strong> power consumption`
      this.consumptionTarget.style.display = ""
    }
    if (generation > 0 && this.hasGenerationTarget) {
      this.generationTarget.innerHTML = `<strong>${this.formatPower(generation)}</strong> power generation`
      this.generationTarget.style.display = ""
    }
  }

  formatPower(watts) {
    if (watts >= 1_000_000_000) {
      return `${(watts / 1_000_000_000).toFixed(2)} GW`
    } else if (watts >= 1_000_000) {
      return `${(watts / 1_000_000).toFixed(2)} MW`
    } else {
      return `${(watts / 1_000).toFixed(2)} kW`
    }
  }
}
