window.stripePayWithCard = async function(publishableKey, clientSecret, callbackName) {
  if (!window.Stripe) {
    alert("Stripe.js not loaded");
    return;
  }
  // Create modal overlay
  const overlay = document.createElement('div');
  overlay.id = 'stripe-modal-overlay';
  overlay.style.position = 'fixed';
  overlay.style.top = '0';
  overlay.style.left = '0';
  overlay.style.width = '100vw';
  overlay.style.height = '100vh';
  overlay.style.background = 'rgba(0,0,0,0.5)';
  overlay.style.display = 'flex';
  overlay.style.alignItems = 'center';
  overlay.style.justifyContent = 'center';
  overlay.style.zIndex = '9999';

  // Modal content
  const modal = document.createElement('div');
  modal.id = 'stripe-modal-content';
  modal.style.background = '#fff';
  modal.style.padding = '32px 24px';
  modal.style.borderRadius = '12px';
  modal.style.boxShadow = '0 4px 24px rgba(0,0,0,0.2)';
  modal.style.minWidth = '360px';
  modal.style.maxWidth = '90vw';
  modal.style.minHeight = '220px';
  modal.style.textAlign = 'center';
  modal.style.position = 'relative';

  // Card element container
  const cardDiv = document.createElement('div');
  cardDiv.id = 'card-element';
  cardDiv.style.margin = '24px 0';
  cardDiv.style.minHeight = '48px';

  // Pay button
  const payBtn = document.createElement('button');
  payBtn.id = 'pay-button';
  payBtn.textContent = 'Pay';
  payBtn.style.padding = '12px 24px';
  payBtn.style.fontSize = '18px';
  payBtn.style.background = '#4caf50';
  payBtn.style.color = '#fff';
  payBtn.style.border = 'none';
  payBtn.style.borderRadius = '6px';
  payBtn.style.cursor = 'pointer';

  // Close button
  const closeBtn = document.createElement('button');
  closeBtn.textContent = '×';
  closeBtn.style.position = 'absolute';
  closeBtn.style.top = '12px';
  closeBtn.style.right = '18px';
  closeBtn.style.background = 'transparent';
  closeBtn.style.border = 'none';
  closeBtn.style.fontSize = '28px';
  closeBtn.style.cursor = 'pointer';
  closeBtn.onclick = function() {
    document.body.removeChild(overlay);
    window[callbackName]({message: 'closed'}, null);
  };

  modal.appendChild(closeBtn);
  modal.appendChild(document.createTextNode('Enter your card details:'));
  modal.appendChild(cardDiv);
  modal.appendChild(payBtn);
  overlay.appendChild(modal);
  document.body.appendChild(overlay);

  const stripe = window.Stripe(publishableKey);
  const elements = stripe.elements();
  const card = elements.create('card');
  card.mount('#card-element');

  payBtn.onclick = async function() {
    payBtn.disabled = true;
    payBtn.textContent = 'Processing...';
    const {error, paymentIntent} = await stripe.confirmCardPayment(clientSecret, {
      payment_method: {card: card}
    });
    document.body.removeChild(overlay);
    window[callbackName](error, paymentIntent);
  };
};
