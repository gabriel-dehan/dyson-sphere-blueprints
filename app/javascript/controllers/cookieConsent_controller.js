import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "banner" ]

  connect() {
    // Check if consent has already been given/rejected
    const consent = this.getConsent()

    if (consent !== null) {
      // Hide banner if consent decision exists
      this.hideBanner()

      // Load analytics if consent was granted
      if (consent.analytics === true) {
        this.loadAnalytics()
      }
    } else {
      // Show banner for first-time visitors or expired consent
      this.showBanner()
    }
  }

  acceptAll(event) {
    event.preventDefault()

    // Store consent
    this.setConsent({ analytics: true })

    // Hide banner
    this.hideBanner()

    // Load Google Analytics
    this.loadAnalytics()
  }

  rejectAll(event) {
    event.preventDefault()

    // Store rejection
    this.setConsent({ analytics: false })

    // Hide banner
    this.hideBanner()

    // Delete any existing analytics cookies
    this.deleteAnalyticsCookies()
  }

  revokeConsent(event) {
    event.preventDefault()

    // Clear consent
    this.clearConsent()

    // Delete analytics cookies
    this.deleteAnalyticsCookies()

    // Show banner again
    this.showBanner()
  }

  // Private methods

  getConsent() {
    try {
      // Try localStorage first (faster)
      const stored = localStorage.getItem('dyson_sphere_blueprints_gdpr_consent')
      if (stored) {
        const consent = JSON.parse(stored)

        // Check if consent has expired (1 year)
        const consentDate = new Date(consent.timestamp)
        const oneYearAgo = new Date()
        oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1)

        if (consentDate < oneYearAgo) {
          // Consent expired, clear it
          this.clearConsent()
          return null
        }

        return consent
      }

      // Fallback to cookie
      const cookieValue = this.getCookie('dyson_sphere_blueprints_gdpr_consent')
      if (cookieValue) {
        return JSON.parse(decodeURIComponent(cookieValue))
      }

      return null
    } catch (error) {
      console.error('Error reading consent:', error)
      return null
    }
  }

  setConsent(data) {
    const consent = {
      ...data,
      timestamp: new Date().toISOString()
    }

    try {
      // Store in localStorage
      localStorage.setItem('dyson_sphere_blueprints_gdpr_consent', JSON.stringify(consent))

      // Also store in cookie as backup (365 days)
      this.setCookie('dyson_sphere_blueprints_gdpr_consent', JSON.stringify(consent), 365)
    } catch (error) {
      console.error('Error storing consent:', error)
    }
  }

  clearConsent() {
    try {
      localStorage.removeItem('dyson_sphere_blueprints_gdpr_consent')
      this.setCookie('dyson_sphere_blueprints_gdpr_consent', '', -1)
    } catch (error) {
      console.error('Error clearing consent:', error)
    }
  }

  loadAnalytics() {
    // Prevent loading twice
    if (window.analyticsLoaded) {
      return
    }

    const measurementId = window.GA_MEASUREMENT_ID
    if (!measurementId) {
      console.warn('GA_MEASUREMENT_ID not defined')
      return
    }

    // Create and append the gtag script
    const script = document.createElement('script')
    script.async = true
    script.src = `https://www.googletagmanager.com/gtag/js?id=${measurementId}`
    document.head.appendChild(script)

    // Initialize gtag
    window.dataLayer = window.dataLayer || []
    function gtag(){dataLayer.push(arguments)}
    gtag('js', new Date())
    gtag('config', measurementId, {
      'anonymize_ip': true  // GDPR best practice
    })

    window.analyticsLoaded = true
    console.log('Google Analytics loaded with consent')
  }

  deleteAnalyticsCookies() {
    // Delete all GA cookies
    const gaCookies = ['_ga', '_gid', '_gat', `_gat_gtag_${window.GA_MEASUREMENT_ID}`]
    gaCookies.forEach(cookieName => {
      this.setCookie(cookieName, '', -1, '/')
      // Also try to delete with domain
      this.setCookie(cookieName, '', -1, '/', window.location.hostname)
    })
  }

  showBanner() {
    if (this.hasBannerTarget) {
      this.bannerTarget.style.display = 'block'
    }
  }

  hideBanner() {
    if (this.hasBannerTarget) {
      this.bannerTarget.style.display = 'none'
    }
  }

  // Cookie helper methods

  getCookie(name) {
    const value = `; ${document.cookie}`
    const parts = value.split(`; ${name}=`)
    if (parts.length === 2) {
      return parts.pop().split(';').shift()
    }
    return null
  }

  setCookie(name, value, days, path = '/', domain = null) {
    let expires = ''
    if (days) {
      const date = new Date()
      date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000))
      expires = `; expires=${date.toUTCString()}`
    }

    let cookieString = `${name}=${encodeURIComponent(value)}${expires}; path=${path}`
    if (domain) {
      cookieString += `; domain=${domain}`
    }

    document.cookie = cookieString
  }
}
