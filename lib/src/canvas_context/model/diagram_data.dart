import 'package:shape_editor/shape_editor.dart';

class DiagramData {
  final List<ComponentData> components;
  //TODO: Add clusters here? may not be necessary. Check conversion first

  /// Contains list of all components of the diagram
  DiagramData({
    required this.components,
  });

  DiagramData.fromJson(
    Map<String, dynamic> json, {
    Function(Map<String, dynamic> json)? decodeCustomComponentData,
  })  : components = (json['components'] as List).map((componentJson) => ComponentData.fromJson(
                  componentJson,
                  decodeCustomComponentData: decodeCustomComponentData,
                )).toList();

  Map<String, dynamic> toJson() => {
        'components': components,
      };
}
