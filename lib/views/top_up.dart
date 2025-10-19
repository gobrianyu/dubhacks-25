import 'package:dubhacks_25/models/balance_manager.dart';
import 'package:dubhacks_25/views/token_purchase_page.dart';
import 'package:flutter/material.dart';
import '../models/account_manager.dart';

class TopUpPage extends StatefulWidget {
  final AccountManager accountManager;

  const TopUpPage({super.key, required this.accountManager});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  int? _selectedMaxTokens;

  final Color primaryTone = const Color.fromARGB(255, 78, 101, 112);
  final Color accentTone = const Color.fromARGB(255, 104, 135, 151);

  @override
  void initState() {
    super.initState();
    _selectedMaxTokens = widget.accountManager.balance.maxEarnablePerDay;
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.accountManager.balance;
    final topUpHistory = balance.getTopUpHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top-Up Tokens', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryTone,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ), 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              title: 'Add Tokens',
              child: ElevatedButton.icon(
                icon: const Icon(Icons.monetization_on),
                label: const Text('Add Tokens'),
                onPressed: () async {
                  final tokensBought = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(builder: (_) => TokenPurchasePage(accountManager: widget.accountManager)),
                  );

                  if (tokensBought != null && tokensBought > 0) {
                    widget.accountManager.purchaseTokens(tokensBought);
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA5D6A7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _BalanceDisplay(
              currentBalance: balance.tokenBalance,
              unearnedBalance: balance.unearnedBalance,
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Max Tokens Earnable Per Day',
              child: DropdownButton<int>(
                value: _selectedMaxTokens,
                isExpanded: true,
                items: [1, 2, 3, 4, 5, 10, 15, 20]
                    .map((val) => DropdownMenuItem(value: val, child: Text('$val tokens')))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMaxTokens = val;
                    if (val != null) {
                      widget.accountManager.balance.setMaxEarnablePerDay(val);
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            _TopUpHistoryList(topUpHistory: topUpHistory),
          ],
        ),
      ),
    );
  }
}

// Card wrapper with title for content grouping and consistent styling
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// Widget to display current and unearned token balances clearly
class _BalanceDisplay extends StatelessWidget {
  final int currentBalance;
  final int unearnedBalance;

  const _BalanceDisplay({
    required this.currentBalance,
    required this.unearnedBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Balance', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            Text('$currentBalance tokens',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 20),
            Text('Unearned Tokens', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            Text('$unearnedBalance tokens',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
      ),
    );
  }
}

// List view for token top-up history with proper spacing and dividers
class _TopUpHistoryList extends StatelessWidget {
  final List<TopUpEntry> topUpHistory;

  const _TopUpHistoryList({required this.topUpHistory});
  final Color accentTone = const Color.fromARGB(255, 104, 135, 151);

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Top-Up History',
      child: topUpHistory.isEmpty
          ? const Text('No top-ups yet.')
          : ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: topUpHistory.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final entry = topUpHistory[index];
                return ListTile(
                  leading: Icon(Icons.attach_money, color: accentTone),
                  title: Text('${entry.amount} tokens',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle:
                      Text('Added on ${entry.timestamp.toLocal().toString().split('.')[0]}'),
                );
              },
            ),
    );
  }
}