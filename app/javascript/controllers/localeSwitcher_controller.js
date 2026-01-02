import { Controller } from "stimulus"

export default class extends Controller {
  switch(event) {
    // Store preference in cookie for non-logged-in users
    const locale = event.target.dataset.locale
    if (locale) {
      document.cookie = `locale=${locale};path=/;max-age=31536000;SameSite=Lax`
    }
  }
}
