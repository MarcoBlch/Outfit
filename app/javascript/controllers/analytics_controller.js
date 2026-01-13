import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="analytics"
// Handles Plausible analytics event tracking
export default class extends Controller {
  static values = {
    product: String
  }

  connect() {
    console.log("Analytics controller connected")
  }

  // Track product click with product name as property
  trackProductClick(event) {
    // Track affiliate click
    if (typeof window.plausible !== 'undefined') {
      const productName = this.hasProductValue ? this.productValue : 'Unknown Product';

      window.plausible('Affiliate Click', {
        props: { product: productName }
      });

      console.log('Tracked affiliate click:', productName);
    }
  }
}
