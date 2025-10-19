# Stripe Payment Integration for Web

This implementation provides Stripe payment functionality for the web version of the Math Kids app, allowing users to purchase tokens through a secure payment sheet.

## Features

- ✅ **Platform-specific implementation**: Automatically uses the correct payment method for web vs mobile
- ✅ **Stripe.js integration**: Uses Stripe.js for secure web payments
- ✅ **Multiple token packages**: Users can choose from 10, 25, 50, or 100 token packages
- ✅ **Payment Intent API**: Server-side payment intent creation for security
- ✅ **User-friendly dialogs**: Clean UI for selecting and purchasing tokens

## Files Modified/Created

1. **`web/index.html`** - Added Stripe.js script tag
2. **`lib/services/payment_service.dart`** - Main payment service with token packages and dialog
3. **`lib/services/payment_service_web.dart`** - Web-specific Stripe implementation using dart:js
4. **`lib/services/payment_service_mobile.dart`** - Mobile-specific Stripe implementation
5. **`lib/views/parental_controls_page.dart`** - Updated to use payment service
6. **`pubspec.yaml`** - Added http package dependency

## How It Works

### 1. User Flow
```
User clicks "Add Tokens" 
  → Dialog shows token packages
  → User selects a package
  → Payment sheet opens
  → User enters payment details
  → Payment processed
  → Success/failure notification shown
```

### 2. Technical Flow (Web)

```dart
// 1. User selects token package
PaymentService.showTokenPurchaseDialog(context);

// 2. Payment service creates payment intent on backend
POST http://localhost:3000/create-payment-intent
Body: { "amount": 499 } // $4.99 in cents

// 3. Backend returns clientSecret
Response: { "clientSecret": "pi_xxx_secret_xxx" }

// 4. Web implementation uses Stripe.js to confirm payment
Stripe.confirmPayment({
  clientSecret: clientSecret,
  confirmParams: { return_url: current_url },
  redirect: 'if_required'
})

// 5. Show success/failure to user
```

## Server Requirements

Your Node.js server (`server/index.js`) must be running and should have:

```javascript
app.post('/create-payment-intent', async (req, res) => {
    const { amount } = req.body;
    const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(amount),
        currency: 'usd',
        automatic_payment_methods: { enabled: true },
    });
    res.json({ clientSecret: paymentIntent.client_secret });
});
```

## Testing

### 1. Start the server
```bash
cd server
npm install
node index.js
```

### 2. Run the Flutter web app
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

Note: The `--disable-web-security` flag is needed for local development to bypass CORS restrictions.

### 3. Test the payment flow
1. Navigate to Parental Controls page
2. Enter password (default: `1234`)
3. Click "Add Tokens" button
4. Select a token package
5. Use Stripe test card: `4242 4242 4242 4242`
   - Expiry: Any future date
   - CVC: Any 3 digits
   - ZIP: Any 5 digits

## Stripe Test Cards

| Card Number | Scenario |
|------------|----------|
| 4242 4242 4242 4242 | Success |
| 4000 0000 0000 9995 | Declined - insufficient funds |
| 4000 0000 0000 0002 | Declined - card declined |
| 4000 0025 0000 3155 | Requires authentication |

## Environment Variables

Ensure your `.env` file contains:
```
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxx
STRIPE_SECRET_KEY=sk_test_xxxxx
```

The publishable key is also hardcoded in `payment_service_web.dart` for web builds (since .env assets don't work reliably on web).

## Token Packages

| Tokens | Price | Package ID |
|--------|-------|-----------|
| 10 | $4.99 | Small |
| 25 | $9.99 | Medium |
| 50 | $17.99 | Large |
| 100 | $29.99 | X-Large |

## Customization

### Change Token Packages
Edit the `tokenPackages` list in `lib/services/payment_service.dart`:

```dart
static const List<Map<String, dynamic>> tokenPackages = [
  {'tokens': 10, 'price': 4.99, 'description': '10 Tokens'},
  // Add more packages here
];
```

### Change Server URL
Update the `serverUrl` in `lib/services/payment_service.dart`:

```dart
static const String serverUrl = 'https://your-server.com';
```

### Update Stripe Keys
For production, update the publishable key in `payment_service_web.dart`:

```dart
const String stripePublishableKey = 'pk_live_xxxxx';
```

## Production Deployment

### 1. Update CORS settings on server
```javascript
app.use(cors({
  origin: 'https://your-domain.com',
  credentials: true
}));
```

### 2. Use live Stripe keys
- Update `.env` with live keys
- Update hardcoded key in `payment_service_web.dart`

### 3. Build for web
```bash
flutter build web --release
```

### 4. Deploy server and web app
Ensure both are accessible and the server URL is updated in the Flutter app.

## Troubleshooting

### Payment not working on web
- ✅ Check browser console for errors
- ✅ Ensure Stripe.js is loaded (check Network tab)
- ✅ Verify server is running and accessible
- ✅ Check CORS configuration

### "Network error" message
- ✅ Verify server URL is correct
- ✅ Check server is running on port 3000
- ✅ Ensure no firewall blocking

### Payment succeeds but no confirmation
- ✅ Check promise handling in `payment_service_web.dart`
- ✅ Verify context is still mounted
- ✅ Look for JavaScript errors in console

## Security Notes

⚠️ **Never expose your secret key in client code**
- Secret key should only be in server-side code
- Publishable key is safe to use in client code
- Always validate payments server-side
- Implement webhook handlers for payment confirmation

## Future Enhancements

- [ ] Add webhook handling for payment confirmation
- [ ] Store token balance in database
- [ ] Add payment history with real transactions
- [ ] Implement refund functionality
- [ ] Add support for multiple currencies
- [ ] Add Apple Pay / Google Pay support
- [ ] Implement subscription-based token packages

## Support

For Stripe-specific issues, consult:
- [Stripe Web Payments Documentation](https://stripe.com/docs/payments/quickstart)
- [Stripe.js Reference](https://stripe.com/docs/js)
- [Flutter Web Documentation](https://flutter.dev/web)
