import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submitButton", "cardErrors", "cardElement", "paymentMethod"]
  static values = { 
    stripeKey: String,
    successUrl: String,
    userName: String,
    userEmail: String
  }

  connect() {
    this.stripeInitialized = false
    
    // Only proceed if we have a valid Stripe key
    if (!this.stripeKeyValue || this.stripeKeyValue === 'undefined' || this.stripeKeyValue === '') {
      this.showError('Payment system not configured. Please contact support.')
      this.disableForm()
      return
    }
    
    this.initializeStripe()
    this.setupEventListeners()
    this.initializePaymentFields()
  }

  initializeStripe() {
    try {
      this.stripe = Stripe(this.stripeKeyValue)
      this.elements = this.stripe.elements()
      this.stripeInitialized = true
    } catch (error) {
      console.error('Failed to initialize Stripe:', error)
      this.showError('Payment system failed to initialize. Please refresh the page.')
      this.disableForm()
    }
  }

  disableForm() {
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent = 'Payment Unavailable'
    this.submitButtonTarget.classList.add('bg-gray-400', 'cursor-not-allowed')
    this.submitButtonTarget.classList.remove('bg-blue-600', 'hover:bg-blue-700')
  }

  setupEventListeners() {
    // Payment method change listeners
    this.paymentMethodTargets.forEach(radio => {
      radio.addEventListener('change', () => this.togglePaymentFields())
    })

    // Form submission - IMPORTANT: Prevent submission if Stripe isn't working
    this.formTarget.addEventListener('submit', (event) => {
      if (!this.stripeInitialized) {
        event.preventDefault()
        this.showError('Payment system not ready. Please refresh the page.')
        return
      }
      this.handleFormSubmit(event)
    })
  }

  initializePaymentFields() {
    this.togglePaymentFields()
  }

  togglePaymentFields() {
    const selectedMethod = this.paymentMethodTargets.find(radio => radio.checked)
    if (!selectedMethod) return

    // Hide all payment method fields
    document.querySelectorAll('.payment-method-fields').forEach(field => {
      field.classList.add('hidden')
    })

    // Show selected method's fields
    const selectedFields = document.getElementById(selectedMethod.value + '-fields')
    if (selectedFields) {
      selectedFields.classList.remove('hidden')
    }

    // Initialize card element if Stripe is selected
    if (selectedMethod.value === 'stripe' && this.stripeInitialized) {
      this.mountCardInput()
    }
  }

  mountCardInput() {
    if (!this.cardElementTarget || !this.stripeInitialized) return

    // Clear existing content
    this.cardElementTarget.innerHTML = ''

    // Create and mount card element
    this.card = this.createCardElement()
    this.card.mount(this.cardElementTarget)

    // Add card change listener
    this.card.addEventListener('change', (event) => this.handleCardChange(event))
  }

  createCardElement() {
    return this.elements.create('card', {
      style: {
        base: {
          fontSize: '16px',
          color: '#424770',
          '::placeholder': { color: '#aab7c4' },
        },
        invalid: { color: '#9e2146' },
      },
    })
  }

  handleCardChange(event) {
    if (event.error) {
      this.showError(event.error.message)
    } else {
      this.hideError()
    }
  }

  handleFormSubmit(event) {
    event.preventDefault()
    
    // Double-check Stripe is initialized
    if (!this.stripeInitialized) {
      this.showError('Payment system not ready. Please refresh the page.')
      return
    }
    
    this.setProcessingState(true)

    const selectedMethod = this.paymentMethodTargets.find(radio => radio.checked)
    if (!selectedMethod) {
      this.showError('Please select a payment method')
      this.setProcessingState(false)
      return
    }

    if (selectedMethod.value === 'stripe') {
      this.handleStripePayment()
    } else {
      this.handleOtherPaymentMethods(selectedMethod.value)
    }
  }

  async handleStripePayment() {
    try {
      // Create payment on server
      const response = await fetch(this.formTarget.action, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({
          payment: { payment_method: 'stripe' }
        })
      })

      const data = await response.json()
      if (data.error) throw new Error(data.error)

      // Confirm payment with Stripe
      const result = await this.confirmStripePayment(data.client_secret)
      
      if (result.error) {
        this.showError(result.error.message)
        this.setProcessingState(false)
      } else {
        this.redirectToSuccess()
      }
    } catch (error) {
      this.showError(error.message)
      this.setProcessingState(false)
    }
  }

  confirmStripePayment(clientSecret) {
    return this.stripe.confirmCardPayment(clientSecret, {
      payment_method: {
        card: this.card,
        billing_details: {
          name: this.userNameValue,
          email: this.userEmailValue
        }
      }
    })
  }

  async handleOtherPaymentMethods(method) {
    try {
      const formData = new FormData()
      formData.append('payment[payment_method]', method)

      // Add method-specific fields
      if (method === 'upi') {
        const upiId = document.querySelector('input[name="payment[upi_id]"]')
        const mobileNumber = document.querySelector('input[name="payment[mobile_number]"]')
        
        if (upiId && mobileNumber) {
          formData.append('payment[upi_id]', upiId.value)
          formData.append('payment[mobile_number]', mobileNumber.value)
        }
      }

      const response = await fetch(this.formTarget.action, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: formData
      })

      const data = await response.json()
      if (data.error) throw new Error(data.error)

      this.redirectToSuccess()
    } catch (error) {
      this.showError(error.message)
      this.setProcessingState(false)
    }
  }

  showError(message) {
    this.cardErrorsTarget.textContent = message
    this.cardErrorsTarget.classList.remove('hidden')
  }

  hideError() {
    this.cardErrorsTarget.classList.add('hidden')
    this.cardErrorsTarget.textContent = ''
  }

  setProcessingState(processing) {
    this.submitButtonTarget.disabled = processing
    this.submitButtonTarget.innerText = processing ? 'Processing...' : 'Pay Now'
    this.submitButtonTarget.classList.toggle('bg-gray-400', processing)
    this.submitButtonTarget.classList.toggle('bg-blue-600', !processing)
    this.submitButtonTarget.classList.toggle('cursor-not-allowed', !processing)
    this.submitButtonTarget.classList.toggle('cursor-pointer', processing)
  }

  redirectToSuccess() {
    window.location.href = this.successUrlValue
  }
}
