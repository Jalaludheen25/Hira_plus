import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/provider/transportation_provider.dart';
import 'package:hira_plus/screens/manager_screen/view/add_vehicle_screen.dart';
import 'package:hira_plus/screens/manager_screen/view/add_route_screen.dart';
import 'package:hira_plus/screens/manager_screen/view/driver_selection_screen.dart';

class TransportationScreen extends StatefulWidget {
  const TransportationScreen({Key? key}) : super(key: key);

  @override
  State<TransportationScreen> createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransportationProvider>(context, listen: false)
          .fetchAllData();
    });
  }

  void _showAddOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorClass.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add New',
                  style: TextStyleClass.poppinsSemiBold(
                    fontSize: 18,
                    color: ColorClass.brandDarkGreen,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBottomSheetOption(
                  context,
                  icon: LucideIcons.car,
                  title: 'Add Vehicle',
                  subtitle: 'Add a new vehicle to the fleet',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddVehicleScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildBottomSheetOption(
                  context,
                  icon: LucideIcons.user,
                  title: 'Add Driver',
                  subtitle: 'Add a new driver to the system',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriverSelectionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildBottomSheetOption(
                  context,
                  icon: LucideIcons.navigation,
                  title: 'Add Route',
                  subtitle: 'Create a new transportation route',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddRouteScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorClass.neutral200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorClass.brandLightGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: ColorClass.brandDarkGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyleClass.poppinsRegular(
                      fontSize: 14,
                      color: ColorClass.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: ColorClass.neutral400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.bgWhite0,
      appBar: AppBar(
        backgroundColor: ColorClass.brandDarkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'Transportation',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 20,
            color: ColorClass.white,
          ),
        ),
      ),
      body: Consumer<TransportationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 48,
                    color: ColorClass.neutral400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: TextStyleClass.poppinsRegular(
                      fontSize: 16,
                      color: ColorClass.neutral400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchAllData(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Drivers Section
                _buildSectionHeader('Available Drivers', LucideIcons.users),
                const SizedBox(height: 12),
                _buildDriversList(provider.availableDrivers),

                const SizedBox(height: 24),

                // Available Vehicles Section
                _buildSectionHeader('Available Vehicles', LucideIcons.car),
                const SizedBox(height: 12),
                _buildVehiclesList(provider.vehicles),

                const SizedBox(height: 24),

                // In Route Section
                _buildSectionHeader('In Route', LucideIcons.navigation),
                const SizedBox(height: 12),
                _buildInRouteList(provider.inRouteItems),

                const SizedBox(height: 24),

                // Recent Routes Section
                _buildSectionHeader('Recent Routes', LucideIcons.clock),
                const SizedBox(height: 12),
                _buildRecentRoutesList(provider.recentRoutes),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddOptionsBottomSheet(context);
        },
        backgroundColor: ColorClass.brandDarkGreen,
        child: Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ColorClass.brandDarkGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 18,
            color: ColorClass.brandDarkGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildDriversList(List drivers) {
    if (drivers.isEmpty) {
      return _buildEmptyState('No drivers available', LucideIcons.users);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorClass.neutral200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: drivers.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: ColorClass.neutral200,
        ),
        itemBuilder: (context, index) {
          final driver = drivers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: ColorClass.brandLightGreen,
              child: Icon(
                LucideIcons.user,
                color: ColorClass.brandDarkGreen,
                size: 20,
              ),
            ),
            title: Text(
              driver.name ?? 'Unknown Driver',
              style: TextStyleClass.poppinsMedium(fontSize: 16),
            ),
            subtitle: Text(
              driver.department ?? 'No Department',
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: ColorClass.neutral500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorClass.brandLightGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Available',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 12,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehiclesList(List vehicles) {
    if (vehicles.isEmpty) {
      return _buildEmptyState('No vehicles available', LucideIcons.car);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorClass.neutral200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: vehicles.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: ColorClass.neutral200,
        ),
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: ColorClass.brandLightGreen,
              child: Icon(
                LucideIcons.car,
                color: ColorClass.brandDarkGreen,
                size: 20,
              ),
            ),
            title: Text(
              vehicle.vehicleName ?? 'Unknown Vehicle',
              style: TextStyleClass.poppinsMedium(fontSize: 16),
            ),
            subtitle: Text(
              '${vehicle.vehicleNumber ?? 'No Number'} • ${vehicle.vehicleType ?? 'Unknown Type'}',
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: ColorClass.neutral500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: vehicle.status == 'available'
                    ? ColorClass.brandLightGreen.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                vehicle.status?.toUpperCase() ?? 'UNKNOWN',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 12,
                  color: vehicle.status == 'available'
                      ? ColorClass.brandDarkGreen
                      : Colors.orange.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInRouteList(List routes) {
    if (routes.isEmpty) {
      return _buildEmptyState('No active routes', LucideIcons.navigation);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorClass.neutral200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: routes.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: ColorClass.neutral200,
        ),
        itemBuilder: (context, index) {
          final route = routes[index];
          return ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: Icon(
                LucideIcons.navigation,
                color: Colors.blue.shade700,
                size: 20,
              ),
            ),
            title: Text(
              '${route.vehicleName ?? 'Unknown Vehicle'} - ${route.driverName ?? 'Unknown Driver'}',
              style: TextStyleClass.poppinsMedium(fontSize: 16),
            ),
            subtitle: Text(
              route.routeName ?? 'Unknown Route',
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: ColorClass.neutral500,
              ),
            ),
            children: [
              if (route.description?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorClass.neutral100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      route.description!,
                      style: TextStyleClass.poppinsRegular(
                        fontSize: 14,
                        color: ColorClass.neutral600,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentRoutesList(List routes) {
    if (routes.isEmpty) {
      return _buildEmptyState('No recent routes', LucideIcons.clock);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorClass.neutral200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: routes.length > 5 ? 5 : routes.length, // Show only last 5
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: ColorClass.neutral200,
        ),
        itemBuilder: (context, index) {
          final route = routes[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: ColorClass.neutral300,
              child: Icon(
                LucideIcons.clock,
                color: ColorClass.neutral600,
                size: 20,
              ),
            ),
            title: Text(
              '${route.vehicleName ?? 'Unknown Vehicle'} - ${route.driverName ?? 'Unknown Driver'}',
              style: TextStyleClass.poppinsMedium(fontSize: 16),
            ),
            subtitle: Text(
              route.routeName ?? 'Unknown Route',
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: ColorClass.neutral500,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorClass.neutral200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                route.status?.toUpperCase() ?? 'COMPLETED',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 12,
                  color: ColorClass.neutral600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorClass.neutral200),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: ColorClass.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyleClass.poppinsRegular(
              fontSize: 16,
              color: ColorClass.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
