import 'dart:async';
import 'package:flutter/material.dart';
import 'controllers/lab_controller.dart';
import 'dialogs/add_patient_dialog.dart';
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
          const _WhatsAppBanner(),
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

class PatientListView extends StatelessWidget {
  const PatientListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: labController,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Patient List', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Patient Name')),
                    DataColumn(label: Text('Test Name')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: labController.patients.map((p) {
                    return DataRow(cells: [
                      DataCell(Text(p.id.substring(p.id.length - 4))),
                      DataCell(Text(p.name)),
                      DataCell(Text(p.testName)),
                      DataCell(Text('Rs ${p.amount}')),
                      DataCell(Chip(
                        label: Text(p.status.name),
                        backgroundColor: p.status == PatientStatus.approved ? Colors.green[100] : Colors.orange[100],
                      )),
                      DataCell(Text('${p.date.day}/${p.date.month}/${p.date.year}')),
                    ]);
                  }).toList(),
                ),
              )
            ],
          ),
        );
      }
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

class _WhatsAppBanner extends StatelessWidget {
  const _WhatsAppBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Column(
        children: [
          Text(
            'WhatsApp : +92 321 944 711 3 | Email: info@apnilab.pk',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Website: www.apnilab.pk | More Info : www.info.apnilab.pk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A)),
                      children: [
                        TextSpan(text: 'A', style: TextStyle(color: Colors.orange)),
                        TextSpan(text: 'PNI'),
                        TextSpan(
                            text: 'LAB.pk',
                            style: TextStyle(color: Colors.lightBlue)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                tooltip: 'Profile Options',
                child: const Row(
                  children: [
                    Icon(Icons.person, color: Colors.teal, size: 18),
                    SizedBox(width: 4),
                    Text('Admin N/A',
                        style: TextStyle(
                            color: Colors.teal, fontWeight: FontWeight.w600)),
                    Icon(Icons.arrow_drop_down, color: Colors.teal, size: 16),
                  ],
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'profile', child: Text('Profile')),
                  const PopupMenuItem(value: 'settings', child: Text('Settings')),
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
                onSelected: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected $val')));
                },
              ),
            ],
          ),
          const Row(
            children: [
              Icon(Icons.monitor_heart, color: Colors.teal, size: 20),
              SizedBox(width: 4),
              Text('ApniLab.pk LMS Demo',
                  style: TextStyle(
                      color: Colors.teal, fontWeight: FontWeight.w600)),
            ],
          )
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
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                icon: const Icon(Icons.video_library, size: 16),
                label: const Text('Training Playlist'),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.error_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              const Text('-99', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              )
            ],
          )
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
              'ApniLab.pk Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 24),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(context: context, builder: (_) => const AddPatientDialog());
              },
              icon: const Icon(Icons.person_add),
              label: const Text('New Patient'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                 for (var p in labController.patients) {
                   if (p.status == PatientStatus.pendingSample) {
                     labController.updatePatientStatus(p.id, PatientStatus.pendingReport);
                   } else if (p.status == PatientStatus.pendingReport) {
                     labController.updatePatientStatus(p.id, PatientStatus.approved);
                   }
                 }
              },
              icon: const Icon(Icons.autorenew),
              label: const Text('Process Demo'),
            ),
            const SizedBox(width: 16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '© 2024 - ApniLab.Pk - Powered by ASH-Advance Software House | www.ash.com.pk',
                style: TextStyle(color: Colors.grey),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.message, size: 16),
                label: const Text('Set SMS'),
              ),
              Row(
                children: [
                  const Text('Get the App: ',
                      style: TextStyle(color: Colors.grey)),
                  Icon(Icons.android, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Icon(Icons.apple, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Icon(Icons.desktop_windows, color: Colors.blue[700]),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
