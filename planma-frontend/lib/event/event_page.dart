import 'package:flutter/material.dart';
import 'package:planma_app/event/create_event.dart';
import 'package:planma_app/event/widget/event_card.dart';
import 'package:planma_app/event/widget/section_title.dart';
import 'package:planma_app/Providers/events_provider.dart';
import 'package:provider/provider.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // List of events
            Expanded(
              child: ListView(
                children: [
                  const SectionTitle(title: 'Today'),
                  EventCard(
                    eventName: eventsProvider.eventName ?? 'No Event Name',
                    description: eventsProvider.eventDesc ?? 'No Description',
                    location: eventsProvider.location ?? 'No Location',
                    date: eventsProvider.date ?? 'No Date',
                    timePeriod: eventsProvider.time ?? 'No Time',
                    type: eventsProvider.eventType ?? 'No Type',
                  ),
                  // Hardcoded event
                  const EventCard(
                    eventName: 'Date with GF',
                    description: 'Monthsary Date',
                    location: 'SM Downtown',
                    date: '11 January 2024',
                    timePeriod: '11:00 AM - 12:30 PM',
                    type: 'Personal',
                  ),
                  const SectionTitle(title: 'December 18'),
                  const EventCard(
                    eventName: 'Team Meeting',
                    description: 'Discuss project progress',
                    location: 'Office Meeting Room',
                    date: '18 December 2024',
                    timePeriod: '10:00 AM - 11:30 AM',
                    type: 'Work',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEventState()),
          );
        },
        backgroundColor: const Color(0xFF173F70),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
