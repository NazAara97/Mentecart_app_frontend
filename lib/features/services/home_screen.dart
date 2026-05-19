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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ServiceBloc>().add(FetchServicesEvent());
    });
  }

  Future<void> _refresh() async {
    context.read<ServiceBloc>().add(FetchServicesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Services")),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: BlocBuilder<ServiceBloc, ServiceState>(
          builder: (context, state) {

            if (state is ServiceLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ServiceError) {
              return Center(child: Text(state.message));
            }

            if (state is ServiceLoaded) {
              final services = state.services;

              if (services.isEmpty) {
                return const Center(child: Text("No services available"));
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),

                        onTap: () {
                          print("Tapped: ${service.title}");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceDetailScreen(
                                serviceId: service.id,
                              ),
                            ),
                          );
                        },

                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(service.title),
                            subtitle: Text(service.description),
                            trailing: Text("Rs ${service.price}"),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}