import { Controller } from "stimulus"
import tippy from "tippy.js"
import entityPower from "../data/entityPower.json"

// Fixed generators - only these count for generation (not fuel-dependent)
const FIXED_GENERATORS = [2203, 2205, 2213] // Wind Turbine, Solar Panel, Geothermal

export default class extends Controller {
  static targets = ["consumption", "generation"]
  static values = { summary: Object }

  connect() {
    this.calculate()
  }

  calculate() {
    const summary = this.summaryValue
    if (!summary) return

    let consumptionIdle = 0
    let consumptionWork = 0
    let generation = 0
    const consumptionDetails = []
    const generationDetails = []

    // Calculate from buildings and inserters
    for (const category of ["buildings", "inserters"]) {
      const entities = summary[category] || {}
      for (const [entityId, data] of Object.entries(entities)) {
        const power = entityPower[entityId]
        if (!power) continue

        const idlePower = power.idle * data.tally
        const workPower = power.work * data.tally

        if (workPower > 0) {
          consumptionIdle += idlePower
          consumptionWork += workPower
          consumptionDetails.push({
            name: data.name,
            tally: data.tally,
            idle: idlePower,
            work: workPower
          })
        } else if (FIXED_GENERATORS.includes(parseInt(entityId))) {
          const genPower = Math.abs(workPower)
          generation += genPower
          generationDetails.push({
            name: data.name,
            tally: data.tally,
            power: genPower
          })
        }
      }
    }

    // Display consumption with tooltip
    if (consumptionWork > 0 && this.hasConsumptionTarget) {
      const tooltip = this.buildConsumptionTooltip(consumptionDetails, consumptionIdle, consumptionWork)
      this.consumptionTarget.innerHTML = `<strong>${this.formatPower(consumptionWork)}</strong> power consumption`
      this.consumptionTarget.style.display = ""
      tippy(this.consumptionTarget, {
        content: tooltip,
        allowHTML: true,
        placement: "bottom",
        duration: 200
      })
    }

    // Display generation with tooltip
    if (generation > 0 && this.hasGenerationTarget) {
      const tooltip = this.buildGenerationTooltip(generationDetails, generation)
      this.generationTarget.innerHTML = `<strong>${this.formatPower(generation)}</strong> power generation`
      this.generationTarget.style.display = ""
      tippy(this.generationTarget, {
        content: tooltip,
        allowHTML: true,
        placement: "bottom",
        duration: 200
      })
    }
  }

  buildConsumptionTooltip(details, idle, work) {
    // Sort by work power descending
    details.sort((a, b) => b.work - a.work)

    let html = `<div style="text-align: left; font-size: 12px;">`
    html += `<div style="margin-bottom: 6px; border-bottom: 1px solid rgba(255,255,255,0.3); padding-bottom: 4px;">`
    html += `<strong>Idle:</strong> ${this.formatPower(idle)}<br>`
    html += `<strong>Max:</strong> ${this.formatPower(work)}`
    html += `</div>`

    for (const item of details) {
      html += `<div style="margin: 2px 0;">`
      html += `${item.tally}x ${item.name}: ${this.formatPower(item.work)}`
      html += `</div>`
    }
    html += `</div>`
    return html
  }

  buildGenerationTooltip(details, total) {
    // Sort by power descending
    details.sort((a, b) => b.power - a.power)

    let html = `<div style="text-align: left; font-size: 12px;">`
    html += `<div style="margin-bottom: 6px; border-bottom: 1px solid rgba(255,255,255,0.3); padding-bottom: 4px;">`
    html += `<strong>Total:</strong> ${this.formatPower(total)}`
    html += `</div>`

    for (const item of details) {
      html += `<div style="margin: 2px 0;">`
      html += `${item.tally}x ${item.name}: ${this.formatPower(item.power)}`
      html += `</div>`
    }
    html += `</div>`
    return html
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
