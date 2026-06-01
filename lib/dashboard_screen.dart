import 'dart:async';
import 'package:flutter/material.dart';
import 'controllers/lab_controller.dart';
import 'controllers/auth_controller.dart';
import 'models/patient.dart';
import 'views/patient_registration_view.dart';
import 'views/result_entry_view.dart';
import 'views/sample_receiving_view.dart';
import 'views/test_approve_view.dart';
import 'views/doctor_commission_view.dart';
import 'views/add_test_view.dart';
import 'views/normal_ranges_view.dart';
import 'views/statement_view.dart';
import 'views/general_settings_view.dart';
import 'views/branch_setup_view.dart';
import 'views/printer_settings_view.dart';
import 'views/lab_reference_view.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  String _currentViewTitle = 'Dashboard';

  void _navigateTo(String viewTitle) {
    setState(() {
      _currentViewTitle = viewTitle;
    });
  }

  Widget _buildCurrentView() {
    switch (_currentViewTitle) {
      case 'Dashboard':
        return const DashboardView();
      case 'Patient List':
        return const PatientListView();
      case 'New Patient':
      case 'Patient Registration':
        return const PatientRegistrationView();
      case 'Result Entry':
      case 'Pending Results':
        return const ResultEntryView();
      case 'Sample Receiving':
        return const SampleReceivingView();
      case 'Test Approval':
      case 'Approve Reports':
        return const TestApproveView();
      case 'Doctor Commission':
        return const DoctorCommissionView();
      case 'Lab Reference':
        return const LabReferenceView();
      case 'Add Test':
        return const AddTestView();
      case 'Normal Ranges':
        return const NormalRangesView();
      case 'Daily Summary':
        return const StatementView(initialTab: 0);
      case 'Monthly Report':
        return const StatementView(initialTab: 1);
      case 'Income Statement':
        return const StatementView(initialTab: 2);
      case 'General Settings':
        return const GeneralSettingsView();
      case 'Branch Setup':
        return const BranchSetupView();
      case 'Printer Settings':
        return const PrinterSettingsView();
      default:
        return PlaceholderView(title: _currentViewTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _AppHeader(),
          _NavBar(
            onNavigate: _navigateTo,
            currentView: _currentViewTitle,
          ),
          Expanded(
            child: _buildCurrentView(),
          ),

        ],
      ),
    );
  }
}

// --- Views ---

class PlaceholderView extends StatelessWidget {
  final String title;
  const PlaceholderView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '$title Screen',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('This screen is under construction.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class PatientListView extends StatefulWidget {
  const PatientListView({super.key});

  @override
  State<PatientListView> createState() => _PatientListViewState();
}

class _PatientListViewState extends State<PatientListView> {
  String _searchQuery = '';
  String _statusFilter = 'Show All';

  // Reuse same flag logic as TestApproveView
  String _determineFlag(String valueStr, String rangeStr) {
    final val = double.tryParse(valueStr.trim());
    if (val == null) return '';
    final parts = rangeStr.split('-');
    if (parts.length != 2) return '';
    final minVal = double.tryParse(parts[0].trim());
    final maxVal = double.tryParse(parts[1].trim());
    if (minVal == null || maxVal == null) return '';
    if (val < minVal) return 'LOW';
    if (val > maxVal) return 'HIGH';
    return 'NORMAL';
  }

  void _showPrintPreview(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 850,
          height: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Header bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.print, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Print Preview — ${patient.name}  |  Status: ${patient.status == PatientStatus.approved ? "Approved ✅" : patient.status.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report Slip sent to Laser Printer successfully!'),
                              backgroundColor: Colors.teal,
                            ),
                          );
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Confirm Print'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[800],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),

              // A4 Preview
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Letterhead
                        Center(
                          child: Column(
                            children: [
                              Text(
                                labController.labName.toUpperCase(),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 2),
                              const Text('CLINICAL LABORATORY',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on, size: 12, color: Colors.grey[800]),
                                  const SizedBox(width: 4),
                                  Text(
                                    labController.labAddress.toUpperCase(),
                                    style: TextStyle(fontSize: 10, color: Colors.grey[800], fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(thickness: 1.5, color: Colors.black),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Patient info box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.black, fontSize: 13),
                                        children: [
                                          const TextSpan(text: "Patient's Name: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: patient.name.toUpperCase()),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.black, fontSize: 13),
                                        children: [
                                          const TextSpan(text: "Age / Gender: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${patient.age} Y / ${patient.gender.toUpperCase()}"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.black, fontSize: 13),
                                        children: [
                                          const TextSpan(text: "Date : ", style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${patient.date.day}/${patient.date.month}/${patient.date.year}"),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.black, fontSize: 13),
                                        children: [
                                          const TextSpan(text: "REF BY: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: patient.doctorName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Results header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            border: const Border(
                              top: BorderSide(color: Colors.grey),
                              bottom: BorderSide(color: Colors.grey),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 30, child: Text(patient.testName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                              const Expanded(flex: 15, child: Text('OBSERVED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              const Expanded(flex: 18, child: Text('UNIT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              const Expanded(flex: 25, child: Text('NORMAL VALUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Results rows
                        if (patient.results.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: Text('No results entered yet.', style: TextStyle(color: Colors.grey))),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: patient.results.length,
                            itemBuilder: (context, idx) {
                              final r = patient.results[idx];
                              final flag = _determineFlag(r.resultValue, r.referenceRange);
                              Color valColor = Colors.black;
                              FontWeight valWeight = FontWeight.normal;
                              String suffix = '';
                              if (flag == 'HIGH') { valColor = Colors.red[900]!; valWeight = FontWeight.bold; suffix = ' (H)'; }
                              if (flag == 'LOW')  { valColor = Colors.blue[900]!; valWeight = FontWeight.bold; suffix = ' (L)'; }

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Row(
                                  children: [
                                    Expanded(flex: 30, child: Text(r.testName, style: const TextStyle(fontSize: 13))),
                                    Expanded(flex: 15, child: Text('${r.resultValue}$suffix', style: TextStyle(fontSize: 13, color: valColor, fontWeight: valWeight))),
                                    Expanded(flex: 18, child: Text(r.unit, style: const TextStyle(fontSize: 13))),
                                    Expanded(flex: 25, child: Text(r.referenceRange, style: const TextStyle(fontSize: 13))),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: labController,
      builder: (context, _) {
        // Apply search + status filter
        final filtered = labController.patients.where((p) {
          final q = _searchQuery.toLowerCase();
          final matchSearch = q.isEmpty ||
              p.name.toLowerCase().contains(q) ||
              p.id.toLowerCase().contains(q) ||
              p.testName.toLowerCase().contains(q) ||
              p.doctorName.toLowerCase().contains(q);

          if (!matchSearch) return false;

          switch (_statusFilter) {
            case 'Approved':      return p.status == PatientStatus.approved;
            case 'Pending Sample': return p.status == PatientStatus.pendingSample;
            case 'Pending Report': return p.status == PatientStatus.pendingReport;
            case 'Pending Approval': return p.status == PatientStatus.pendingApproval;
            default:              return true;
          }
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Patient List', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Search + Filter bar
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search by Name / ID / Test / Doctor...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _statusFilter,
                          decoration: const InputDecoration(
                            labelText: 'Status Filter',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Show All',         child: Text('Show All 👥')),
                            DropdownMenuItem(value: 'Approved',         child: Text('Approved ✅')),
                            DropdownMenuItem(value: 'Pending Approval', child: Text('Pending Approval ⏳')),
                            DropdownMenuItem(value: 'Pending Report',   child: Text('Pending Results 📝')),
                            DropdownMenuItem(value: 'Pending Sample',   child: Text('Pending Sample 🧪')),
                          ],
                          onChanged: (v) { if (v != null) setState(() => _statusFilter = v); },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Table
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: Text('No patients match the filter.', style: TextStyle(color: Colors.grey, fontSize: 16))),
                      )
                    : DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.blue[900]!.withAlpha(10)),
                        columns: const [
                          DataColumn(label: Text('ID',          style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Patient Name',style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Test Name',   style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Amount',      style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status',      style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Date',        style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Print',       style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filtered.map((p) {
                          // Status chip color
                          Color chipBg = Colors.orange[100]!;
                          Color chipText = Colors.orange[900]!;
                          String chipLabel = p.status.name;
                          if (p.status == PatientStatus.approved) {
                            chipBg = Colors.green[100]!; chipText = Colors.green[900]!; chipLabel = 'Approved ✅';
                          } else if (p.status == PatientStatus.pendingApproval) {
                            chipBg = Colors.amber[100]!; chipText = Colors.orange[900]!; chipLabel = 'Awaiting Approval';
                          } else if (p.status == PatientStatus.pendingReport) {
                            chipBg = Colors.blue[100]!; chipText = Colors.blue[900]!; chipLabel = 'Pending Results';
                          } else if (p.status == PatientStatus.pendingSample) {
                            chipBg = Colors.purple[100]!; chipText = Colors.purple[900]!; chipLabel = 'Pending Sample';
                          }

                          return DataRow(cells: [
                            DataCell(Text(p.id.substring(p.id.length - 4), style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(p.name)),
                            DataCell(Text(p.testName, style: TextStyle(color: Colors.blue[900]))),
                            DataCell(Text('Rs ${p.amount}')),
                            DataCell(Chip(
                              label: Text(chipLabel, style: TextStyle(color: chipText, fontSize: 12, fontWeight: FontWeight.bold)),
                              backgroundColor: chipBg,
                            )),
                            DataCell(Text('${p.date.day}/${p.date.month}/${p.date.year}')),
                            DataCell(
                              IconButton(
                                icon: Icon(
                                  Icons.print,
                                  color: p.results.isNotEmpty ? Colors.teal : Colors.grey[400],
                                ),
                                tooltip: p.results.isNotEmpty ? 'Print Report' : 'No results yet',
                                onPressed: p.results.isNotEmpty
                                    ? () => _showPrintPreview(context, p)
                                    : null,
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardTitleRow(),
          SizedBox(height: 24),
          _StatsGrid(),
          SizedBox(height: 32),
          _ReferencesSection(),
          SizedBox(height: 48),
          _Footer(),
        ],
      ),
    );
  }
}


// --- Components ---



class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFDDEEE5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.science, color: Color(0xFF1E3A8A), size: 32),
                  const SizedBox(width: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A)),
                      children: [
                        TextSpan(text: 'SHAH-RUKN-ALAM ', style: TextStyle(color: Color(0xFF1E3A8A))),
                        TextSpan(text: 'LAB', style: TextStyle(color: Colors.lightBlue)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              ListenableBuilder(
                listenable: authController,
                builder: (context, _) {
                  final rawUsername = authController.currentUsername;
                  final displayUsername = rawUsername.isNotEmpty
                      ? '${rawUsername[0].toUpperCase()}${rawUsername.substring(1)}'
                      : 'Admin';

                  return PopupMenuButton<String>(
                    offset: const Offset(0, 40),
                    tooltip: 'Profile Options',
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.teal, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          displayUsername,
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.teal, size: 16),
                      ],
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            const Icon(Icons.account_circle, size: 18, color: Colors.teal),
                            const SizedBox(width: 8),
                            Text('$displayUsername\'s Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Logout Offline', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (val) {
                      if (val == 'logout') {
                        authController.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logged out successfully!'),
                            behavior: SnackBarBehavior.floating,
                            width: 250,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected $val'),
                            behavior: SnackBarBehavior.floating,
                            width: 250,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final Function(String) onNavigate;
  final String currentView;

  const _NavBar({required this.onNavigate, required this.currentView});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _NavButton('Dashboard', Icons.speed, isActive: currentView == 'Dashboard', onNavigate: onNavigate),
              _NavDropdown('Lab Settings', items: const ['General Settings', 'Branch Setup', 'Printer Settings'], onNavigate: onNavigate),
              _NavDropdown('Test Setting', items: const ['Add Test', 'Normal Ranges'], onNavigate: onNavigate),
              _NavDropdown('Patients', items: const ['New Patient', 'Patient List', 'Sample Receiving', 'Pending Results', 'Test Approval'], onNavigate: onNavigate),
              _NavDropdown('Statements', items: const ['Daily Summary', 'Monthly Report', 'Income Statement'], onNavigate: onNavigate),
              _NavDropdown('Reference Statements', items: const ['Doctor Commission', 'Lab Reference'], onNavigate: onNavigate),
            ],
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final Function(String) onNavigate;

  const _NavButton(this.title, this.icon, {this.isActive = false, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onNavigate(title),
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.blue[700] : Colors.grey[700]),
            const SizedBox(width: 4),
            Text(title,
                style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? Colors.blue[700] : Colors.grey[800])),
          ],
        ),
      ),
    );
  }
}

class _NavDropdown extends StatelessWidget {
  final String title;
  final List<String> items;
  final Function(String) onNavigate;

  const _NavDropdown(this.title, {this.items = const [], required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: title,
      offset: const Offset(0, 40),
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
        child: Row(
          children: [
            Text(title, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
      itemBuilder: (context) {
        return items.map((e) => PopupMenuItem<String>(value: e, child: Text(e))).toList();
      },
      onSelected: (val) {
        onNavigate(val);
      },
    );
  }
}

class _DashboardTitleRow extends StatefulWidget {
  const _DashboardTitleRow();

  @override
  State<_DashboardTitleRow> createState() => _DashboardTitleRowState();
}

class _DashboardTitleRowState extends State<_DashboardTitleRow> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.speed, size: 32),
            const SizedBox(width: 8),
            const Text(
              'SHAH-RUKN-ALAM LAB ',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 24),
            Text('All',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500)),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(
              'Updated: ${_formatDateTime(_now)}',
              style: TextStyle(
                  color: Colors.grey[700], fontWeight: FontWeight.w500),
            )
          ],
        )
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: labController,
      builder: (context, _) {
        if (labController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _MetricCard(
                title: 'Patients Today',
                value: '${labController.patientsToday}',
                icon: Icons.people,
                color: const Color(0xFF673AB7)),
            _MetricCard(
                title: 'Amount Today',
                value: labController.amountToday.toStringAsFixed(2),
                icon: Icons.money,
                color: const Color(0xFF1976D2)),
            _MetricCard(
                title: 'Discount Today',
                value: labController.discountToday.toStringAsFixed(2),
                icon: Icons.local_offer,
                color: const Color(0xFFFFB300)),
            _MetricCard(
                title: 'Revenue Today',
                value: labController.revenueToday.toStringAsFixed(2),
                icon: Icons.attach_money,
                color: const Color(0xFF2E7D32)),
            _MetricCard(
                title: 'Total Tests Today',
                value: '${labController.totalTestsToday}',
                icon: Icons.science,
                color: const Color(0xFF009688)),
            _MetricCard(
                title: 'Pending Sample',
                value: '${labController.pendingSamples}',
                icon: Icons.hourglass_empty,
                color: const Color(0xFF00ACC1)),
            _MetricCard(
                title: 'Pending Reports',
                value: '${labController.pendingReports}',
                icon: Icons.article,
                color: const Color(0xFFF57C00)),
            _MetricCard(
                title: 'Approved Reports',
                value: '${labController.approvedReports}',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF1B5E20)),
          ],
        );
      }
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferencesSection extends StatelessWidget {
  const _ReferencesSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: const Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green),
                SizedBox(width: 8),
                Text('Revenue References',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: const Row(
              children: [
                Icon(Icons.star, color: Colors.blue),
                SizedBox(width: 8),
                Text('Popular References',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                ' - SHAH-RUKN-ALAM LAB - Powered by Good Luck Software House ',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
