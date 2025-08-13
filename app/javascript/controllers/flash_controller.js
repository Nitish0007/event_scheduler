import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["flashBox"]
  connect() {
    this.showFlashMessage()
  }

  disconnect() {
    this.hideFlashMessage()
  }

  showFlashMessage() {
    if (this.flashBoxTarget.textContent) {
      this.flashBoxTarget.classList.remove("hidden")
      setTimeout(() => {
        this.hideFlashMessage()
      }, 3000)
    }
    if (this.flashBoxTarget.textContent) {
      this.flashBoxTarget.classList.remove("hidden")
      setTimeout(() => {
        this.hideFlashMessage()
      }, 3000)
    }
  }

  hideFlashMessage() {
    this.flashBoxTarget.classList.add("hidden")
  }
}
