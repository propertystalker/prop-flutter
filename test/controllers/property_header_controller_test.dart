import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/controllers/property_header_controller.dart';

void main() {
  // This line is crucial for tests that interact with Flutter's binding layer.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PropertyHeaderController', () {
    late PropertyHeaderController controller;

    setUp(() {
      controller = PropertyHeaderController();
    });

    test('initial state is not editing', () {
      // The controller should start with isEditingPrice as false
      expect(controller.isEditingPrice, isFalse);
    });

    test('editPrice() sets editing state to true and notifies listeners', () {
      bool listenerWasCalled = false;
      controller.addListener(() {
        listenerWasCalled = true;
      });

      // Call the method to change the state
      controller.editPrice();

      // Verify the state has changed
      expect(controller.isEditingPrice, isTrue);
      // Verify that listeners were notified of the change
      expect(listenerWasCalled, isTrue);
    });

    test('finishEditing() sets editing state to false and notifies listeners', () {
      // First, put the controller into the editing state
      controller.editPrice();

      // Reset the listener flag
      bool listenerWasCalled = false;
      controller.addListener(() {
        listenerWasCalled = true;
      });

      // Call the method to finish editing
      controller.finishEditing();

      // Verify the state has reverted
      expect(controller.isEditingPrice, isFalse);
      // Verify that listeners were notified
      expect(listenerWasCalled, isTrue);
    });
  });
}
