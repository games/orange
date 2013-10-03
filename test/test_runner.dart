import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'src/vector_test.dart' as vector_test;

void main() {
  useHtmlEnhancedConfiguration();
  group('vector tests', vector_test.main);
}