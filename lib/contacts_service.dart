import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> loadAllContactNames(Map<String, String> contactNames) async {
  // Request permissions if not already granted
  var status = await Permission.contacts.status;
  if (!status.isGranted) {
    status = await Permission.contacts.request();
  }

  if (status.isGranted) {
    final contacts = await ContactsService.getContacts(withThumbnails: false);
    for (var contact in contacts) {
      for (var phone in contact.phones!) {
        contactNames[phone.value!] = contact.displayName ?? '';
      }
    }
  }
}
