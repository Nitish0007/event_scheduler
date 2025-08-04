import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["notice", "alert"]
  connect() {
    this.showFlashMessage()
  }

  disconnect() {
    this.hideFlashMessage()
  }

  showFlashMessage() {
    if (this.noticeTarget.textContent) {
      this.noticeTarget.classList.remove("hidden")
      setTimeout(() => {
        this.hideFlashMessage()
      }, 3000)
    }
    if (this.alertTarget.textContent) {
      this.alertTarget.classList.remove("hidden")
      setTimeout(() => {
        this.hideFlashMessage()
      }, 3000)
    }
  }

  hideFlashMessage() {
    this.noticeTarget.classList.add("hidden")
    this.alertTarget.classList.add("hidden")
  }
}
