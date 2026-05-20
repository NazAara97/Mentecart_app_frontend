import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mentecart_app/features/services/bloc/service_bloc.dart';
import 'package:mentecart_app/features/services/bloc/service_event.dart';
import 'package:mentecart_app/features/services/bloc/service_state.dart';
import 'package:mentecart_app/features/services/service_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchText = "";
  String? selectedCategory;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ServiceBloc>().add(FetchServicesEvent());
      context.read<ServiceBloc>().add(FetchCategoriesEvent());
    });
  }

  Future<void> _refresh() async {
    searchText = "";
    selectedCategory = null;

    context.read<ServiceBloc>().add(FetchServicesEvent());
  }

  // ✅ GROUP SERVICES
  Map<String, List> _groupServicesByCategory(List services) {
    final Map<String, List> grouped = {};

    for (var service in services) {
      final category = service.category ?? "Others";

      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(service);
    }

    return grouped;
  }

  // ✅ LOCAL FILTER FUNCTION (IMPORTANT)
  List _filterServices(List services) {
    return services.where((service) {
      final matchesSearch = service.title
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchesCategory = selectedCategory == null ||
          selectedCategory!.isEmpty ||
          service.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Services")),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            // 🔎 SEARCH + FILTER
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Search services...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  BlocBuilder<ServiceBloc, ServiceState>(
                    builder: (context, state) {
                      if (state is CategoriesLoaded) {
                        return DropdownButtonFormField<String>(
                          value: selectedCategory,
                          hint: const Text("Select Category"),
                          items: state.categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),

            // 📋 LIST
            Expanded(
              child: BlocBuilder<ServiceBloc, ServiceState>(
                builder: (context, state) {
                  if (state is ServiceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ServiceError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is ServiceLoaded) {
                    // ✅ APPLY FILTER HERE
                    final filteredServices =
                        _filterServices(state.services);

                    if (filteredServices.isEmpty) {
                      return const Center(
                        child: Text("No matching services"),
                      );
                    }

                    final grouped =
                        _groupServicesByCategory(filteredServices);

                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: grouped.entries.map((entry) {
                        final category = entry.key;
                        final services = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CATEGORY TITLE
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // SERVICES
                            ...services.map((service) {
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  title: Text(service.title),
                                  subtitle: Text(service.description),
                                  trailing:
                                      Text("Rs ${service.price}"),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ServiceDetailScreen(
                                          serviceId: service.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),

                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}