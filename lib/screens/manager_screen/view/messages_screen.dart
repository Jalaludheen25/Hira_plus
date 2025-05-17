import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../provider/messages_provider.dart';
import '../models/message_model.dart';

class ManagerMessagesScreen extends StatefulWidget {
  const ManagerMessagesScreen({Key? key}) : super(key: key);

  @override
  State<ManagerMessagesScreen> createState() => _ManagerMessagesScreenState();
}

class _ManagerMessagesScreenState extends State<ManagerMessagesScreen> {
  void _showAddMessageSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final provider = Provider.of<MessagesProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Message', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white,size: 24,),
                label: const Text('Send',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final title = titleController.text.trim();
                  final desc = descController.text.trim();
                  if (title.isEmpty || desc.isEmpty) return;
                  final created = await provider.createMessage(title, desc);
                  
                  if (created != null) {
                    await provider.sendMessage(created.id);
                  }
                  await provider.fetchMessages();
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessagesProvider()..fetchMessages(),
      child: Consumer<MessagesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          return Scaffold(
            
            body: provider.messages.isEmpty
                ? const Center(child: Text('No messages found.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical:  14),
                    itemCount: provider.messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final msg = provider.messages[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(msg.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(msg.description),
                          trailing: msg.sentToUsers
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.schedule, color: Colors.orange),
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddMessageSheet(context),
              backgroundColor: const Color(0xFF25D366),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
} 