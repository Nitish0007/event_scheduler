import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay", "toggle", "close"]

  connect() {
    // this method is called when the controller is attached to the DOM (when the element it is attached to is added to the DOM)

    // The 'this' keyword refers to the current instance of the Stimulus controller.
    // It allows access to controller properties, targets, and methods.
    document.addEventListener('keydown', this.closeOnEscape.bind(this))
  }

  disconnect() {
    // The disconnect() method is called automatically by Stimulus when the controller is removed from the DOM,
    // for example when the element it is attached to is removed or replaced, or when navigating to a new page
    // in a Turbo-enabled application.
    // Clean up the global event listener
    document.removeEventListener('keydown', this.closeOnEscape.bind(this))
  }

  open() {
    console.log("Opening sidebar")
    this.sidebarTarget.classList.remove('-translate-x-full')
    this.sidebarTarget.classList.add('translate-x-0')
    this.overlayTarget.classList.remove('hidden')
    this.overlayTarget.classList.add('block')
  }

  close() {
    console.log("Closing sidebar")
    this.sidebarTarget.classList.remove('translate-x-0')
    this.sidebarTarget.classList.add('-translate-x-full')
    this.overlayTarget.classList.remove('block')
    this.overlayTarget.classList.add('hidden')
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
} 