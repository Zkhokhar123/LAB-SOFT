import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';
import '../models/patient.dart';
import '../models/doctor.dart';

class StatementView extends StatefulWidget {
  final int initialTab;
  const StatementView({super.key, this.initialTab = 0});

  @override
  State<StatementView> createState() => _StatementViewState();
}

class _StatementViewState extends State<StatementView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDailyDate = DateTime.now();
  int _selectedMonthlyMonth = DateTime.now().month;
  int _selectedMonthlyYear = DateTime.now().year;
  String _searchQuery = '';

  // For Month Filter
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(StatementView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      _tabController.index = widget.initialTab;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper: Find Doctor's commission percentage
  double _getDoctorCommissionPercentage(String doctorName) {
    if (doctorName == 'Self') return 0.0;
    final doc = labController.doctors.firstWhere(
      (d) => d.name.toLowerCase() == doctorName.toLowerCase(),
      orElse: () => Doctor(name: doctorName, commissionPercentage: 0.0),
    );
    return doc.commissionPercentage;
  }

  // Helper: Calculate commission for a patient
  double _calculatePatientCommission(Patient patient) {
    final pct = _getDoctorCommissionPercentage(patient.doctorName);
    return patient.amount * (pct / 100);
  }

  // Date picker for Daily Summary
  Future<void> _selectDailyDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDailyDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDailyDate) {
      setState(() {
        _selectedDailyDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: labController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue[900],
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.blue[900],
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.today), text: 'Daily Summary'),
                  Tab(icon: Icon(Icons.calendar_month), text: 'Monthly Report'),
                  Tab(icon: Icon(Icons.receipt_long), text: 'Income Statement'),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDailySummaryTab(),
              _buildMonthlyReportTab(),
              _buildIncomeStatementTab(),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------
  // TAB 1: DAILY SUMMARY
  // ----------------------------------------------------
  Widget _buildDailySummaryTab() {
    // Filter patients by selected date
    final dailyPatients = labController.patients.where((p) {
      return p.date.year == _selectedDailyDate.year &&
             p.date.month == _selectedDailyDate.month &&
             p.date.day == _selectedDailyDate.day;
    }).toList();

    // Stats calculations
    final double grossRevenue = dailyPatients.fold(0.0, (sum, p) => sum + p.amount);
    final double totalDiscounts = dailyPatients.fold(0.0, (sum, p) => sum + p.discount);
    final double netRevenue = grossRevenue - totalDiscounts;
    final double totalCommissions = dailyPatients.fold(0.0, (sum, p) => sum + _calculatePatientCommission(p));
    final double netProfit = netRevenue - totalCommissions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.today, size: 28, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Summary: ${_selectedDailyDate.day}/${_selectedDailyDate.month}/${_selectedDailyDate.year}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _selectDailyDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Change Date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _printDailyStatement(_selectedDailyDate, dailyPatients, grossRevenue, totalDiscounts, netRevenue, totalCommissions, netProfit),
                icon: const Icon(Icons.print),
                label: const Text('Print Statement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Grid
          _buildFinancialStatsGrid(
            patientsCount: dailyPatients.length,
            gross: grossRevenue,
            discount: totalDiscounts,
            netCash: netRevenue,
            commission: totalCommissions,
            netProfit: netProfit,
          ),
          const SizedBox(height: 32),

          // Patients List Table Card
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Patient Fees Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      SizedBox(
                        width: 250,
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search patients...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  if (dailyPatients.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('No patients registered on this date.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                    )
                  else
                    _buildPatientsSummaryTable(dailyPatients),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 2: MONTHLY REPORT
  // ----------------------------------------------------
  Widget _buildMonthlyReportTab() {
    // Filter patients by selected month and year
    final monthlyPatients = labController.patients.where((p) {
      return p.date.year == _selectedMonthlyYear && p.date.month == _selectedMonthlyMonth;
    }).toList();

    // Stats calculations
    final double grossRevenue = monthlyPatients.fold(0.0, (sum, p) => sum + p.amount);
    final double totalDiscounts = monthlyPatients.fold(0.0, (sum, p) => sum + p.discount);
    final double netRevenue = grossRevenue - totalDiscounts;
    final double totalCommissions = monthlyPatients.fold(0.0, (sum, p) => sum + _calculatePatientCommission(p));
    final double netProfit = netRevenue - totalCommissions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 28, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Monthly Report: ${_months[_selectedMonthlyMonth - 1]} $_selectedMonthlyYear',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 24),
                  // Month selection dropdown
                  DropdownButton<int>(
                    value: _selectedMonthlyMonth,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(_months[index]),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMonthlyMonth = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  // Year selection dropdown
                  DropdownButton<int>(
                    value: _selectedMonthlyYear,
                    items: List.generate(7, (index) {
                      final yr = DateTime.now().year - 3 + index;
                      return DropdownMenuItem(
                        value: yr,
                        child: Text('$yr'),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMonthlyYear = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _printMonthlyStatement('${_months[_selectedMonthlyMonth - 1]} $_selectedMonthlyYear', monthlyPatients, grossRevenue, totalDiscounts, netRevenue, totalCommissions, netProfit),
                icon: const Icon(Icons.print),
                label: const Text('Print Statement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Grid
          _buildFinancialStatsGrid(
            patientsCount: monthlyPatients.length,
            gross: grossRevenue,
            discount: totalDiscounts,
            netCash: netRevenue,
            commission: totalCommissions,
            netProfit: netProfit,
          ),
          const SizedBox(height: 32),

          // Patients List Card
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monthly Patient Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      SizedBox(
                        width: 250,
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search patients...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  if (monthlyPatients.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('No patients registered in this month.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                    )
                  else
                    _buildPatientsSummaryTable(monthlyPatients),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 3: INCOME STATEMENT
  // ----------------------------------------------------
  Widget _buildIncomeStatementTab() {
    // Cumulative calculations for ALL data registered in the system
    final allPatients = labController.patients;
    final double grossRevenue = allPatients.fold(0.0, (sum, p) => sum + p.amount);
    final double totalDiscounts = allPatients.fold(0.0, (sum, p) => sum + p.discount);
    final double netRevenue = grossRevenue - totalDiscounts;
    final double totalCommissions = allPatients.fold(0.0, (sum, p) => sum + _calculatePatientCommission(p));
    final double netProfit = netRevenue - totalCommissions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Header Banner
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labController.labName.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          labController.labAddress,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _printIncomeStatement(grossRevenue, totalDiscounts, netRevenue, totalCommissions, netProfit),
                      icon: const Icon(Icons.print),
                      label: const Text('Print Statement'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),

              // Body Financial Statement
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Column(
                        children: [
                          Text('INCOME STATEMENT', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          SizedBox(height: 4),
                          Text('For All Accumulated Periods to Date', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Gross Revenue
                    _buildLedgerRow('Gross Lab Fees Revenue', grossRevenue, isPrimary: true),
                    const Divider(height: 24),

                    // Deductions: Discounts
                    _buildLedgerRow('Less: Customer Discounts Allowed', totalDiscounts, isSub: true),
                    const Divider(height: 24),

                    // Net Revenue
                    _buildLedgerRow('Net Cash Collections', netRevenue, isTotal: true),
                    const SizedBox(height: 32),

                    // Expenses: Doctor Commissions
                    _buildLedgerRow('Less: Direct Referral Doctor Commissions', totalCommissions, isSub: true),
                    const Divider(height: 24),

                    // Net Operating Income / Profit
                    _buildLedgerRow('NET OPERATING PROFIT', netProfit, isGrandTotal: true),
                    
                    const SizedBox(height: 48),
                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    
                    // Signatures or Summary Footer
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Prepared By: Lab Administrator', style: TextStyle(fontWeight: FontWeight.w500)),
                            SizedBox(height: 30),
                            Text('_________________________', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Approved By: Chief Pathologist', style: TextStyle(fontWeight: FontWeight.w500)),
                            SizedBox(height: 30),
                            Text('_________________________', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // REUSABLE HELPER UI COMPONENTS
  // ----------------------------------------------------

  // 1. Ledger Row for Income Statement
  Widget _buildLedgerRow(String title, double amount, {bool isPrimary = false, bool isSub = false, bool isTotal = false, bool isGrandTotal = false}) {
    TextStyle titleStyle = const TextStyle(fontSize: 16, color: Colors.black87);
    TextStyle amountStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black);

    if (isPrimary) {
      titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]);
      amountStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]);
    }
    if (isSub) {
      titleStyle = const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.redAccent);
      amountStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.redAccent);
    }
    if (isTotal) {
      titleStyle = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.teal);
      amountStyle = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.teal);
    }
    if (isGrandTotal) {
      titleStyle = const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.green);
      amountStyle = const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.green);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isSub) const SizedBox(width: 24),
              Text(title, style: titleStyle),
            ],
          ),
          Text('Rs ${amount.toStringAsFixed(2)}', style: amountStyle),
        ],
      ),
    );
  }

  // 2. Financial Stats Cards Grid
  Widget _buildFinancialStatsGrid({
    required int patientsCount,
    required double gross,
    required double discount,
    required double netCash,
    required double commission,
    required double netProfit,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 50) / 4;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard('Total Patients', '$patientsCount Patients', Icons.people, Colors.purple[700]!, cardWidth),
            _buildStatCard('Gross Billings', 'Rs ${gross.toStringAsFixed(0)}', Icons.payments, Colors.blue[800]!, cardWidth),
            _buildStatCard('Total Discounts', 'Rs ${discount.toStringAsFixed(0)}', Icons.local_offer, Colors.amber[700]!, cardWidth),
            _buildStatCard('Net Cash Collected', 'Rs ${netCash.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.teal[700]!, cardWidth),
            _buildStatCard('Dr. Commissions', 'Rs ${commission.toStringAsFixed(0)}', Icons.star, Colors.red[700]!, cardWidth),
            _buildStatCard('Net Profits', 'Rs ${netProfit.toStringAsFixed(0)}', Icons.trending_up, Colors.green[800]!, cardWidth),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, double width) {
    return Container(
      width: width < 180 ? 180 : width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 3. Patients Breakdown Table
  Widget _buildPatientsSummaryTable(List<Patient> patients) {
    final filtered = patients.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             p.doctorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             p.testName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SizedBox(
      width: double.infinity,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.blue[900]!.withAlpha(10)),
        columns: const [
          DataColumn(label: Text('Patient Name', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Referred Doctor', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Gross Fee (Rs)', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Discount (Rs)', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Net Fee (Rs)', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Dr. Comm (Rs)', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Net Profit (Rs)', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: filtered.map((p) {
          final commission = _calculatePatientCommission(p);
          final netFee = p.amount - p.discount;
          final profit = netFee - commission;

          return DataRow(cells: [
            DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(p.doctorName, style: TextStyle(color: p.doctorName == 'Self' ? Colors.grey : Colors.blue[800]))),
            DataCell(Text('Rs ${p.amount.toStringAsFixed(0)}')),
            DataCell(Text('Rs ${p.discount.toStringAsFixed(0)}', style: TextStyle(color: p.discount > 0 ? Colors.orange[800] : Colors.black))),
            DataCell(Text('Rs ${netFee.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w500))),
            DataCell(Text('Rs ${commission.toStringAsFixed(0)}', style: TextStyle(color: commission > 0 ? Colors.red[800] : Colors.grey))),
            DataCell(Text('Rs ${profit.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
          ]);
        }).toList(),
      ),
    );
  }

  // ----------------------------------------------------
  // PROFESSIONAL PRINT DIALOG SIMULATORS
  // ----------------------------------------------------



  void _printDailyStatement(DateTime date, List<Patient> patients, double gross, double discount, double net, double commission, double profit) {
    showDialog(
      context: context,
      builder: (context) => _buildStatementPrintPreview(
        title: 'DAILY SUMMARY REPORT',
        subtitle: 'Date: ${date.day}/${date.month}/${date.year}',
        patients: patients,
        gross: gross,
        discount: discount,
        net: net,
        commission: commission,
        profit: profit,
      ),
    );
  }

  void _printMonthlyStatement(String monthYear, List<Patient> patients, double gross, double discount, double net, double commission, double profit) {
    showDialog(
      context: context,
      builder: (context) => _buildStatementPrintPreview(
        title: 'MONTHLY STATEMENT REPORT',
        subtitle: 'Period: $monthYear',
        patients: patients,
        gross: gross,
        discount: discount,
        net: net,
        commission: commission,
        profit: profit,
      ),
    );
  }

  void _printIncomeStatement(double gross, double discount, double net, double commission, double profit) {
    showDialog(
      context: context,
      builder: (context) => _buildStatementPrintPreview(
        title: 'INCOME STATEMENT REPORT',
        subtitle: 'Cumulative Statement to Date',
        patients: [],
        gross: gross,
        discount: discount,
        net: net,
        commission: commission,
        profit: profit,
        isCorporateOnly: true,
      ),
    );
  }

  // Full Screen beautiful Print Preview Modal
  Widget _buildStatementPrintPreview({
    required String title,
    required String subtitle,
    required List<Patient> patients,
    required double gross,
    required double discount,
    required double net,
    required double commission,
    required double profit,
    bool isCorporateOnly = false,
  }) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 900,
        height: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Preview Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.print, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Print Preview (Optimized for A4/Laser)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Document successfully sent to laser printer!'), backgroundColor: Colors.teal),
                        );
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Confirm Print'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[800], foregroundColor: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close Preview'),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),

            // Paper Content Area (mimicking standard page)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(48),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Letterhead Header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              labController.labName.toUpperCase(),
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Address: ${labController.labAddress} | Ph: ${labController.labPhone}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Divider(thickness: 2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Document Meta
                      Center(
                        child: Column(
                          children: [
                            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                            const SizedBox(height: 4),
                            Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // corporate ledger summary
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildLedgerRow('Gross Revenue Billings', gross, isPrimary: true),
                            const Divider(),
                            _buildLedgerRow('Total Patient Discounts Given', discount, isSub: true),
                            const Divider(),
                            _buildLedgerRow('Total Net Cash Received', net, isTotal: true),
                            const Divider(),
                            _buildLedgerRow('Referred Doctor Commission Deductibles', commission, isSub: true),
                            const Divider(),
                            _buildLedgerRow('NET OPERATING PROFIT', profit, isGrandTotal: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Patient Breakdown Section (only shown if not corporate only)
                      if (!isCorporateOnly && patients.isNotEmpty) ...[
                        const Text('Detailed Audited Patient Register:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        Table(
                          border: TableBorder.all(color: Colors.grey[300]!, width: 1),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(1.2),
                            3: FlexColumnWidth(1.2),
                            4: FlexColumnWidth(1.2),
                            5: FlexColumnWidth(1.2),
                          },
                          children: [
                            // Table Header Row
                            TableRow(
                              decoration: BoxDecoration(color: Colors.grey[100]),
                              children: const [
                                Padding(padding: EdgeInsets.all(8), child: Text('Patient Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                Padding(padding: EdgeInsets.all(8), child: Text('Doctor Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                Padding(padding: EdgeInsets.all(8), child: Text('Gross (Rs)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                Padding(padding: EdgeInsets.all(8), child: Text('Disc. (Rs)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                Padding(padding: EdgeInsets.all(8), child: Text('Dr. Comm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                Padding(padding: EdgeInsets.all(8), child: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              ],
                            ),
                            ...patients.map((p) {
                              final comm = _calculatePatientCommission(p);
                              final netFee = p.amount - p.discount;
                              final prof = netFee - comm;

                              return TableRow(
                                children: [
                                  Padding(padding: const EdgeInsets.all(8), child: Text(p.name, style: const TextStyle(fontSize: 11))),
                                  Padding(padding: const EdgeInsets.all(8), child: Text(p.doctorName, style: const TextStyle(fontSize: 11))),
                                  Padding(padding: const EdgeInsets.all(8), child: Text(p.amount.toStringAsFixed(0), style: const TextStyle(fontSize: 11))),
                                  Padding(padding: const EdgeInsets.all(8), child: Text(p.discount.toStringAsFixed(0), style: const TextStyle(fontSize: 11))),
                                  Padding(padding: const EdgeInsets.all(8), child: Text(comm.toStringAsFixed(0), style: const TextStyle(fontSize: 11))),
                                  Padding(padding: const EdgeInsets.all(8), child: Text(prof.toStringAsFixed(0), style: const TextStyle(fontSize: 11))),
                                ],
                              );
                            }),
                          ],
                        ),
                      ],
                      const SizedBox(height: 60),

                      // Signatures area
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Prepared By: Lab Manager', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              SizedBox(height: 30),
                              Text('____________________', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Authorized Pathologist Signature', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              SizedBox(height: 30),
                              Text('____________________', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
