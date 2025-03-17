import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/info_card.dart';
import '../widgets/device_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/responsive_builder.dart';
import '../../../core/models/ha_entity.dart';
import '../../../features/home_assistant/providers/ha_entities_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/service_providers.dart';

class DashboardContent extends ConsumerStatefulWidget {
  final VoidCallback? onMenuPressed;

  const DashboardContent({
    Key? key,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  ConsumerState<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<DashboardContent> {
  @override
  Widget build(BuildContext context) {
    final entitiesAsync = ref.watch(haEntitiesRealtimeProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard header
              DashboardHeader(
                title: 'Dashboard',
                subtitle: 'Welcome back to your smart home',
                onMenuPressed: widget.onMenuPressed,
              ),

              const SizedBox(height: 24),

              // Info cards
              ResponsiveBuilder(
                mobile: _buildInfoCards(context, crossAxisCount: 1),
                tablet: _buildInfoCards(context, crossAxisCount: 2),
                desktop: _buildInfoCards(context, crossAxisCount: 4),
              ),

              const SizedBox(height: 24),

              // Analytics section
              ResponsiveBuilder(
                mobile: _buildAnalyticsSection(context, isSmallScreen: true),
                desktop: _buildAnalyticsSection(context, isSmallScreen: false),
              ),

              const SizedBox(height: 24),

              // Devices section
              Text(
                'Smart Devices',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 16),

              entitiesAsync.when(
                data: (entities) => _buildDevicesGrid(entities),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context, {required int crossAxisCount}) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        InfoCard(
          title: 'Temperature',
          value: '22°C',
          icon: Icons.thermostat,
          color: Colors.blue,
          onTap: () {},
        ),
        InfoCard(
          title: 'Humidity',
          value: '45%',
          icon: Icons.water_drop,
          color: Colors.teal,
          onTap: () {},
        ),
        InfoCard(
          title: 'Energy',
          value: '5.4 kWh',
          icon: Icons.bolt,
          color: Colors.orange,
          onTap: () {},
        ),
        InfoCard(
          title: 'Devices',
          value: '12',
          icon: Icons.devices,
          color: Colors.purple,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(BuildContext context,
      {required bool isSmallScreen}) {
    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Energy Consumption',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildChart(context),
          const SizedBox(height: 24),
          _buildStatsList(context),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Energy Consumption',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildChart(context)),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildStatsList(context)),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildChart(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      const titles = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ];
                      final index = value.toInt();
                      if (index >= 0 && index < titles.length) {
                        return Text(
                          titles[index],
                          style: const TextStyle(fontSize: 12),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()} kWh',
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3),
                    FlSpot(1, 2),
                    FlSpot(2, 5),
                    FlSpot(3, 3.1),
                    FlSpot(4, 4),
                    FlSpot(5, 3),
                    FlSpot(6, 4),
                  ],
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsList(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatItem(context, 'Daily Average', '3.5 kWh', Colors.blue),
            const SizedBox(height: 16),
            _buildStatItem(context, 'Weekly', '21.8 kWh', Colors.green),
            const SizedBox(height: 16),
            _buildStatItem(context, 'Monthly', '87.2 kWh', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDevicesGrid(List<HAEntity> entities) {
    return ResponsiveBuilder(
      mobile: _buildDevicesGridLayout(entities, crossAxisCount: 1),
      tablet: _buildDevicesGridLayout(entities, crossAxisCount: 2),
      desktop: _buildDevicesGridLayout(entities, crossAxisCount: 4),
    );
  }

  Widget _buildDevicesGridLayout(List<HAEntity> entities,
      {required int crossAxisCount}) {
    // Filter entities to only include lights and switches
    final filteredEntities = entities
        .where((entity) =>
            entity.entityId.startsWith('light.') ||
            entity.entityId.startsWith('switch.'))
        .take(8)
        .toList();

    if (filteredEntities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No devices found'),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredEntities.length,
      itemBuilder: (context, index) {
        final entity = filteredEntities[index];
        return DeviceCard(
          title: entity.friendlyName,
          subtitle: entity.entityId.split('.').first.toUpperCase(),
          icon: _getIconForEntity(entity),
          isActive: entity.state == 'on',
          onToggle: () {
            _toggleEntity(ref, entity);
          },
        );
      },
    );
  }

  IconData _getIconForEntity(HAEntity entity) {
    if (entity.entityId.startsWith('light.')) {
      return Icons.lightbulb;
    } else if (entity.entityId.startsWith('switch.')) {
      return Icons.power_settings_new;
    } else if (entity.entityId.startsWith('sensor.')) {
      return Icons.sensors;
    } else {
      return Icons.device_unknown;
    }
  }

  Future<void> _toggleEntity(WidgetRef ref, HAEntity entity) async {
    final domain = entity.entityId.split('.').first;
    final service = entity.state == 'on' ? 'turn_off' : 'turn_on';

    try {
      // Use the provider from core/services/service_providers.dart
      final apiService = ref.read(haApiServiceProvider);
      await apiService.callService(domain, service, {
        'entity_id': entity.entityId,
      });

      // Refresh entity state
      ref.refresh(haEntitiesRealtimeProvider);
    } catch (e) {
      debugPrint('Error toggling entity: $e');
    }
  }
}
