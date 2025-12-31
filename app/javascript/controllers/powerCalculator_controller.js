import { Controller } from "stimulus"
import tippy from "tippy.js"
import entityPower from "../data/entityPower.json"

// Load entity icons via webpack require.context
const images = require.context("../../assets/images/game_icons", true)
const imagePath = name => images(name, true)

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
            id: entityId,
            name: data.name,
            tally: data.tally,
            idle: idlePower,
            work: workPower
          })
        } else if (FIXED_GENERATORS.includes(parseInt(entityId))) {
          const genPower = Math.abs(workPower)
          generation += genPower
          generationDetails.push({
            id: entityId,
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
      this.consumptionTarget.innerHTML = `<strong class="power-total">${this.formatPower(consumptionWork)}</strong>`
      this.consumptionTarget.style.display = ""
      tippy(this.consumptionTarget, {
        content: tooltip,
        theme: "power-tooltip",
        allowHTML: true,
        placement: "left",
        duration: 200
      })
    } else {
      this.consumptionTarget.innerHTML = `<strong class="power-total na">N/A</strong>`
      this.consumptionTarget.style.display = ""
    }

    // Display generation with tooltip
    if (generation > 0 && this.hasGenerationTarget) {
      const tooltip = this.buildGenerationTooltip(generationDetails, generation)
      this.generationTarget.innerHTML = `<strong class="power-total">${this.formatPower(generation)}</strong>`
      this.generationTarget.style.display = ""
      tippy(this.generationTarget, {
        content: tooltip,
        theme: "power-tooltip",
        allowHTML: true,
        placement: "left",
        duration: 200
      })
    } else {
      this.generationTarget.innerHTML = `<strong class="power-total na">N/A</strong>`
      this.generationTarget.style.display = ""
    }
  }

  getEntityIcon(entityId) {
    try {
      return imagePath(`./entities/${entityId}.png`)
    } catch {
      return imagePath("./entities/default.png")
    }
  }

  buildConsumptionTooltip(details, idle, work) {
    details.sort((a, b) => b.work - a.work)

    const rows = details.map(item => `
      <tr>
        <td><img src="${this.getEntityIcon(item.id)}" width="32" height="32"></td>
        <td>${item.tally}x</td>
        <td>${this.formatPower(item.work)}</td>
      </tr>
    `).join("")

    return `
      <div class="power-tooltip">
        <div class="power-tooltip__summary">
          <span><strong>Idle:</strong> ${this.formatPower(idle)}</span>
          <span><strong>Max:</strong> ${this.formatPower(work)}</span>
        </div>
        <table class="power-tooltip__table">
          <tbody>${rows}</tbody>
        </table>
      </div>
    `
  }

  buildGenerationTooltip(details, total) {
    details.sort((a, b) => b.power - a.power)

    const rows = details.map(item => `
      <tr>
        <td><img src="${this.getEntityIcon(item.id)}" width="32" height="32"></td>
        <td>${item.tally}x</td>
        <td>${this.formatPower(item.power)}</td>
      </tr>
    `).join("")

    return `
      <div class="power-tooltip">
        <div class="power-tooltip__summary">
          <span><strong>Max:</strong> ${this.formatPower(total)}</span>
        </div>
        <table class="power-tooltip__table">
          <tbody>${rows}</tbody>
        </table>
      </div>
    `
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
