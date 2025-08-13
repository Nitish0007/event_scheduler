// NOT IN USE, USING CUSTOM JAVASCRIPT INSTEAD

// import { Controller } from "@hotwired/stimulus"

// export default class extends Controller {
//   static targets = ["container", "overlay", "panel"]

//   connect() {
//     // Add event listeners when modal is connected
//     document.addEventListener('keydown', this.handleKeydown.bind(this))
//     console.log("Modal controller connected", this.element)
//   }

//   disconnect() {
//     // Clean up event listeners when modal is disconnected
//     document.removeEventListener('keydown', this.handleKeydown.bind(this))
//   }

//   open() {
//     // Open the modal
//     this.container.classList.remove('hidden')
//     this.container.classList.add('block')
    
//     // Focus management
//     this.focusTrap()
    
//     // Trigger custom event for other components to listen to
//     this.dispatch('opened')
//   }

//   close() {
//     console.log("Closing modal", this.element)
//     // Close the modal
//     this.container.classList.add('hidden')
//     this.container.classList.remove('block')
//   }

//   stopPropagation(event) {
//     // Prevent clicks inside the modal from bubbling up
//     event.stopPropagation()
//   }

//   handleKeydown(event) {
//     // Close modal on Escape key
//     if (event.key === 'Escape') {
//       this.close()
//     }
//   }

//   focusTrap() {
//     // Focus the first focusable element in the modal
//     const focusableElements = this.panel.querySelectorAll(
//       'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
//     )
    
//     if (focusableElements.length > 0) {
//       focusableElements[0].focus()
//     }
//   }

//   // Custom actions that can be triggered from buttons
//   confirm() {
//     this.dispatch('confirmed')
//     this.close()
//   }

//   cancel() {
//     this.dispatch('cancelled')
//     this.close()
//   }

//   delete() {
//     this.dispatch('deleted')
//     this.close()
//   }
// } 