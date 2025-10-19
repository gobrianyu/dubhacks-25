import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'token_manager.dart';

const String stripePublishableKey = 
    'pk_test_51SJfrBB27Af43sgBfvEtUs15NRiFYFY3xfZLKfyIJ5NXfiAKR8Xlxim9y0itYNrBLueOSOj2NR86YmDijIIpjqzO000z9ST79M';

Future<void> processPayment({
  required BuildContext context,
  required String clientSecret,
  required int tokenAmount,
}) async {
  try {
    // Show a loading indicator
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing payment...'),
              ],
            ),
          );
        },
      );
    }

    // Create and inject a payment form
    _createPaymentDialog(context, clientSecret, tokenAmount);
    
  } catch (e) {
    debugPrint('Error in web payment: $e');
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void _createPaymentDialog(BuildContext context, String clientSecret, int tokenAmount) {
  // Close the loading dialog
  if (context.mounted) {
    Navigator.of(context).pop();
  }

  // Create a unique ID for this payment session
  final dialogId = 'stripe-payment-${DateTime.now().millisecondsSinceEpoch}';
  
  // Inject the Stripe payment form
  final script = '''
    (async function() {
      const stripe = Stripe('$stripePublishableKey');
      
      // Create elements
      const elements = stripe.elements({ clientSecret: '$clientSecret' });
      const paymentElement = elements.create('payment');
      
      // Create container
      const container = document.createElement('div');
      container.id = '$dialogId';
      container.style.cssText = 'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 24px; border-radius: 8px; box-shadow: 0 4px 16px rgba(0,0,0,0.2); z-index: 10000; max-width: 450px; width: 90%; max-height: 80vh; overflow-y: auto;';
      
      const title = document.createElement('h2');
      title.textContent = 'Complete Payment';
      title.style.cssText = 'margin: 0 0 16px 0; font-family: system-ui; font-size: 18px;';
      
      const paymentDiv = document.createElement('div');
      paymentDiv.id = 'payment-element-$dialogId';
      paymentDiv.style.cssText = 'margin: 16px 0;';
      
      const buttonContainer = document.createElement('div');
      buttonContainer.style.cssText = 'display: flex; gap: 8px; margin-top: 16px;';
      
      const submitBtn = document.createElement('button');
      submitBtn.textContent = 'Pay Now';
      submitBtn.style.cssText = 'flex: 1; padding: 12px; background: #5469d4; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; font-weight: 500;';
      
      const cancelBtn = document.createElement('button');
      cancelBtn.textContent = 'Cancel';
      cancelBtn.style.cssText = 'flex: 1; padding: 12px; background: #6c757d; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px;';
      
      const message = document.createElement('div');
      message.style.cssText = 'margin-top: 12px; padding: 8px; border-radius: 4px; display: none; font-size: 14px;';
      
      buttonContainer.appendChild(cancelBtn);
      buttonContainer.appendChild(submitBtn);
      
      container.appendChild(title);
      container.appendChild(paymentDiv);
      container.appendChild(buttonContainer);
      container.appendChild(message);
      
      document.body.appendChild(container);
      
      // Mount payment element
      paymentElement.mount('#payment-element-$dialogId');
      
      // Handle cancel
      cancelBtn.onclick = () => {
        container.remove();
        window.stripePaymentResult = { success: false, cancelled: true };
      };
      
      // Handle submit
      submitBtn.onclick = async () => {
        submitBtn.disabled = true;
        submitBtn.textContent = 'Processing...';
        message.style.display = 'none';
        
        const { error } = await stripe.confirmPayment({
          elements,
          confirmParams: {
            return_url: window.location.href,
          },
          redirect: 'if_required',
        });
        
        if (error) {
          message.textContent = error.message;
          message.style.display = 'block';
          message.style.background = '#fee';
          message.style.color = '#c00';
          submitBtn.disabled = false;
          submitBtn.textContent = 'Pay Now';
          window.stripePaymentResult = { success: false, error: error.message };
        } else {
          message.textContent = 'Payment successful!';
          message.style.display = 'block';
          message.style.background = '#efe';
          message.style.color = '#060';
          setTimeout(() => {
            container.remove();
            window.stripePaymentResult = { success: true, tokens: $tokenAmount };
          }, 1500);
        }
      };
    })();
  ''';
  
  // Execute the script
  html.ScriptElement scriptElement = html.ScriptElement();
  scriptElement.text = script;
  html.document.body?.append(scriptElement);
  
  // Poll for result
  Future.delayed(const Duration(milliseconds: 500), () {
    _checkPaymentResult(context, tokenAmount);
  });
}

void _checkPaymentResult(BuildContext context, int tokenAmount) {
  try {
    final result = js.context['stripePaymentResult'];
    
    if (result != null) {
      final jsResult = js.JsObject.fromBrowserObject(result);
      final success = jsResult['success'];
      final cancelled = jsResult['cancelled'];
      
      if (success == true) {
        // Add tokens to user's balance
        final tokenManager = TokenManager();
        tokenManager.addTokens(tokenAmount, _getPriceForTokens(tokenAmount));
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment successful! $tokenAmount tokens added.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        // Clear the result
        js.context['stripePaymentResult'] = null;
      } else if (cancelled == true) {
        debugPrint('Payment cancelled by user');
        js.context['stripePaymentResult'] = null;
      } else {
        // Keep polling if no result yet
        Future.delayed(const Duration(milliseconds: 500), () {
          _checkPaymentResult(context, tokenAmount);
        });
      }
    } else {
      // Keep polling if no result yet
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkPaymentResult(context, tokenAmount);
      });
    }
  } catch (e) {
    debugPrint('Error checking payment result: $e');
    // Continue polling despite errors
    Future.delayed(const Duration(seconds: 1), () {
      _checkPaymentResult(context, tokenAmount);
    });
  }
}

double _getPriceForTokens(int tokens) {
  // Helper to get price from token amount
  const prices = {
    10: 4.99,
    25: 9.99,
    50: 17.99,
    100: 29.99,
  };
  return prices[tokens] ?? 0.0;
}
