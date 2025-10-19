window.stripePayWithCard = async function(publishableKey, clientSecret, callbackName) {
  if (!window.Stripe) {
    alert("Stripe.js not loaded");
    return;
  }

  // Remove any existing modal
  const existingModal = document.getElementById('payment-modal');
  if (existingModal) {
    document.body.removeChild(existingModal);
  }

  // Create modal container
  const modal = document.createElement('div');
  modal.id = 'payment-modal';
  modal.style.position = 'fixed';
  modal.style.left = '0';
  modal.style.top = '0';
  modal.style.width = '100%';
  modal.style.height = '100%';
  modal.style.backgroundColor = 'rgba(0, 0, 0, 0.5)';
  modal.style.display = 'flex';
  modal.style.alignItems = 'center';
  modal.style.justifyContent = 'center';
  modal.style.zIndex = '1000';

  // Create modal content
  const modalContent = document.createElement('div');
  modalContent.style.backgroundColor = 'white';
  modalContent.style.padding = '32px';
  modalContent.style.borderRadius = '12px';
  modalContent.style.width = '400px';
  modalContent.style.maxWidth = '90%';
  modalContent.style.position = 'relative';
  modalContent.style.boxShadow = '0 4px 16px rgba(0, 0, 0, 0.2)';

  // Create close button
  const closeButton = document.createElement('button');
  closeButton.innerHTML = '×';
  closeButton.style.position = 'absolute';
  closeButton.style.right = '16px';
  closeButton.style.top = '16px';
  closeButton.style.border = 'none';
  closeButton.style.background = 'none';
  closeButton.style.fontSize = '24px';
  closeButton.style.cursor = 'pointer';
  closeButton.style.color = '#666';
  closeButton.onclick = () => {
    document.body.removeChild(modal);
    window[callbackName]({ message: 'Cancelled' }, null);
  };

  // Create title
  const title = document.createElement('h3');
  title.textContent = 'Enter Payment Details';
  title.style.margin = '0 0 24px 0';
  title.style.fontSize = '20px';
  title.style.color = '#32325d';
  title.style.fontFamily = '-apple-system, system-ui, sans-serif';

  // Create card container
  const cardContainer = document.createElement('div');
  cardContainer.id = 'card-element';
  cardContainer.style.padding = '12px';
  cardContainer.style.border = '1px solid #e0e0e0';
  cardContainer.style.borderRadius = '8px';
  cardContainer.style.backgroundColor = '#f8fafd';
  cardContainer.style.marginBottom = '24px';

  // Create form for the payment
  const form = document.createElement('form');
  form.id = 'payment-form';
  form.style.width = '100%';

  // Create pay button
  const payButton = document.createElement('button');
  payButton.textContent = 'Pay';
  payButton.type = 'submit';
  payButton.style.width = '100%';
  payButton.style.padding = '12px';
  payButton.style.border = 'none';
  payButton.style.borderRadius = '6px';
  payButton.style.backgroundColor = '#4caf50';
  payButton.style.color = 'white';
  payButton.style.fontSize = '16px';
  payButton.style.fontWeight = '600';
  payButton.style.cursor = 'pointer';
  payButton.style.transition = 'all 0.2s ease';

  payButton.onmouseover = () => {
    payButton.style.backgroundColor = '#43a047';
    payButton.style.transform = 'translateY(-1px)';
  };
  
  payButton.onmouseout = () => {
    payButton.style.backgroundColor = '#4caf50';
    payButton.style.transform = 'translateY(0)';
  };

  // Assemble form
  form.appendChild(cardContainer);
  form.appendChild(payButton);

  // Assemble modal
  modalContent.appendChild(closeButton);
  modalContent.appendChild(title);
  modalContent.appendChild(form);
  modal.appendChild(modalContent);
  document.body.appendChild(modal);

  // Initialize Stripe
  const stripe = window.Stripe(publishableKey);
  const elements = stripe.elements({
    appearance: {
      theme: 'stripe',
      variables: {
        colorPrimary: '#4caf50',
        fontFamily: '-apple-system, system-ui, BlinkMacSystemFont, "Segoe UI", sans-serif'
      }
    }
  });

  // Create and mount the card element
  const card = elements.create('card', {
    style: {
      base: {
        fontSize: '16px',
        color: '#424770',
        '::placeholder': {
          color: '#aab7c4'
        },
        padding: '16px'
      },
      invalid: {
        color: '#dc3545'
      }
    }
  });
  
  card.mount('#card-element');

  // Handle form submission
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    
    payButton.disabled = true;
    payButton.style.opacity = '0.7';
    payButton.textContent = 'Processing...';

    const {error, paymentIntent} = await stripe.confirmCardPayment(clientSecret, {
      payment_method: {card: card}
    });

    document.body.removeChild(modal);
    window[callbackName](error, paymentIntent);
  });

  // Close modal when clicking outside
  modal.onclick = (event) => {
    if (event.target === modal) {
      document.body.removeChild(modal);
      window[callbackName]({ message: 'Cancelled' }, null);
    }
  };
};
