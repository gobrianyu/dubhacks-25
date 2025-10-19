window.stripeInstances = {};

window.stripeRedirectToCheckout = function(publishableKey, sessionId) {
  if (!publishableKey) {
    console.error('Missing Stripe publishable key');
    return;
  }
  let stripe = window.stripeInstances[publishableKey];
  if (!stripe) {
    stripe = Stripe(publishableKey);
    window.stripeInstances[publishableKey] = stripe;
  }
  stripe.redirectToCheckout({ sessionId: sessionId }).then(function(result) {
    if (result.error) {
      console.error('Stripe Checkout error:', result.error.message);
      alert('Payment failed: ' + result.error.message);
    }
  });
};
